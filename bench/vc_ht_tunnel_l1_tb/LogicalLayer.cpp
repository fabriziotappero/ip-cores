//LogicalLayer.cpp

/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is HyperTransport Tunnel IP Core.
 *
 * The Initial Developer of the Original Code is
 * Ecole Polytechnique de Montreal.
 * Portions created by the Initial Developer are Copyright (C) 2005
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Ami Castonguay <acastong@grm.polymtl.ca>
 *
 * Alternatively, the contents of this file may be used under the terms
 * of the Polytechnique HyperTransport Tunnel IP Core Source Code License 
 * (the  "PHTICSCL License", see the file PHTICSCL.txt), in which case the
 * provisions of PHTICSCL License are applicable instead of those
 * above. If you wish to allow use of your version of this file only
 * under the terms of the PHTICSCL License and not to allow others to use
 * your version of this file under the MPL, indicate your decision by
 * deleting the provisions above and replace them with the notice and
 * other provisions required by the PHTICSCL License. If you do not delete
 * the provisions above, a recipient may use your version of this file
 * under either the MPL or the PHTICSCL License."
 *
 * ***** END LICENSE BLOCK ***** */

#include "../core/PacketContainer.h"
#include "../core/InfoPacket.h"
#include "../core/RequestPacket.h"
#include "LogicalLayer.h"


const int LogicalLayer::PER_PACKET_CRC_POLY = 0x04C11DB7;
const int LogicalLayer::MAX_BUFFERS = 8;

#include <iostream>

using namespace std;

LogicalLayer::LogicalLayer(sc_module_name name) : sc_module(name){
	SC_THREAD(reset_thread);
	sensitive_pos(clk);
	sensitive_neg(resetx);

	inter = NULL;
	physicalLayer = NULL;

	packetIdCounter = 0;
	retry_mode = false;
	retry_mode_after_reset = false;
	initiate_retry_disconnect = false;

	receivedPacket = NULL;
	receivedDataCount = 0;
	receive_state = RECEIVE_IDLE;
	rx_ack_value = 0;
	rx_retry_waiting_for_nop = false;


	nopSendPacket = NULL;
	currentSendPacket.data = NULL;
	currentSendPacket.packet = NULL;
	disconNop = false;
	ignoreIncoming = false;
	displayReceivedDword = false;

	for(int n = 0; n < 3; n++){
		nextNodeCommandBuffersFree[n] = 0;
		nextNodeDataBuffersFree[n] = 0;

		commandBuffersAdvertised[n] = 0;
		dataBuffersAdvertised[n] = 0;
		commandBuffersFree[n] = MAX_BUFFERS;
		dataBuffersFree[n] = MAX_BUFFERS;
	}
}

LogicalLayer::~LogicalLayer(){
	delete nopSendPacket;
	//currentSendPacket is deleted after it's used, no need to delete immediately
	delete receivedPacket;
	//Packets are both in history and packetQueue.  Clear packetQueue and delete 
	//the entries in packetHistory
	packetQueue.clear();

	//Delete packets in the history
	deque<PacketAndData>::iterator i;
	for(i = packetHistory.begin(); i != packetHistory.end();i++){
		delete (*i).packet;
		delete [] (*i).data;
	}
}

void LogicalLayer::reset_thread(){
	while(true){
		if(!resetx.read()){
			retry_mode = retry_mode_after_reset;

			packetIdCounter = 0;
			receivedDataCount = 0;
			rx_ack_value = 0;
			receive_state = RECEIVE_IDLE;

			//Packets are both in history and packetQueue.  Clear packetQueue and delete 
			//the entries in packetHistory
			packetQueue.clear();

			//Delete packets in the history
			deque<PacketAndData>::iterator i;
			for(i = packetHistory.begin(); i != packetHistory.end();i++){
			delete (*i).packet;
			delete [] (*i).data;
			}
			packetHistory.clear();

			for(int n = 0; n < 3; n++){
				nextNodeCommandBuffersFree[n] = 0;
				nextNodeDataBuffersFree[n] = 0;

				commandBuffersAdvertised[n] = 0;
				dataBuffersAdvertised[n] = 0;
			}
		}
		wait();
	}
}

void LogicalLayer::receivedDwordEvent(sc_bv<32> &dword,bool lctl,bool hctl){
	if(displayReceivedDword) cout << "Received dword: " << dword.to_string(SC_HEX) << endl;

	//If reset or during a retry sequence, ignore the received data
	if(!resetx.read() || initiate_retry_disconnect || ignoreIncoming)return;

	if(receive_state == RECEIVE_SECOND_DWORD){
		//Set the seconde dword of the packet (it only had the first dword set)
		receivedPacket->setSecondDword(dword);

		//If there is any data with that packet, go into receiving data state
		if(receivedPacket->hasDataAssociated()){
			receivedDataCount = 0;
			receive_state = RECEIVE_DATA;
		}
		else{
			//If in retry mode, start by receiving the CRC
			if(retry_mode){
				receive_state = RECEIVE_CRC;
			}
			else{
				//Generate event of received packet and wait for next packet
				receive_state = RECEIVE_IDLE;
				inter->receivedHtPacketEvent(receivedPacket,NULL,this);
				updateRxBufferCount(receivedPacket);
			}
		}
	}


	else if(receive_state == RECEIVE_DATA){
		//If CTL is activated, it is a nop inside data
		if(lctl || hctl){
			if(retry_mode){
				firstReceivedDword = dword;
				receive_state = RECEIVE_NOP_CRC;
			}
			else handleNopPacket(dword);
		}
		else{
			//Set the received data
			receivedData[receivedDataCount] = dword.to_int();

			//Check if receiving data is done
			if(receivedDataCount++ == receivedPacket->getDataLengthm1()){
				if(retry_mode){
					receive_state = RECEIVE_CRC;
				}
				else{
					//When it's done, generate event that packet is received
					inter->receivedHtPacketEvent(receivedPacket,receivedData,this);
					updateRxBufferCount(receivedPacket);
					receive_state = RECEIVE_IDLE;
				}
			}
		}
	}


	else if(receive_state == RECEIVE_CRC){
		//Calculate the packet CRC
		int crc = calcultatePacketCrc(receivedPacket,receivedData);

		//CRC is inversed before being sent out, check if it's invalid
		if(~crc != dword.to_int()){
			cout << "Wrong CRC received for packet: " << (*receivedPacket) << endl;
			initiateRetrySequence();
		}
		/**If valid, handle the packet*/
		else{
			//If nop, update the buffer count
			if(receivedPacket->getPacketCommand() == NOP)
				handleNopPacket(firstReceivedDword);
			//Otherwise, notify of received packet and update ack value
			else{
				rx_ack_value++;
				inter->receivedHtPacketEvent(receivedPacket,receivedData,this);
				updateRxBufferCount(receivedPacket);
			}
		}
		receive_state = RECEIVE_IDLE;
	}

	//RECEIVE_NOP_CRC is a state for receiving nops inside data packets.  Check
	//if the crc is correct, handle the nop packet and go back to receiving data,
	//or initiate retry sequence if crc is incorrect
	else if(receive_state == RECEIVE_NOP_CRC){
		PacketContainer c = ControlPacket::createPacketFromDword(firstReceivedDword);
		int crc = calcultatePacketCrc(c.getPacketRef(),NULL);
		if(~crc != dword.to_int()) initiateRetrySequence();
		else handleNopPacket(firstReceivedDword);
		receive_state = RECEIVE_DATA;
	}

	//Otherwise in IDLE state
	else{
		//store the received dword
		firstReceivedDword = dword;

		//Create a packet object from the dword
		PacketContainer c = ControlPacket::createPacketFromDword(dword);

		//If its a nop
		if(c->getPacketCommand() == NOP){
			if(retry_mode){
				//Delete any previously allocated packet
				delete receivedPacket;
				receivedPacket = c.giveControl();
				receive_state = RECEIVE_CRC;
			}
			else handleNopPacket(dword);
		}
		//If if only has one dword
		else if(c->isDwordPacket()){
			//If it has any data associated to it, go to receiving data state
			if(c->hasDataAssociated()){
				receive_state = RECEIVE_DATA;
				receivedDataCount = 0;
				//Delete any previously allocated packet
				delete receivedPacket;
				receivedPacket = c.giveControl();
			}
			else{
				//packet received, either receive CRC if in retry mode or generate event
				if(retry_mode){
					receive_state = RECEIVE_CRC;
					//Delete any previously allocated packet
					delete receivedPacket;
					receivedPacket = c.giveControl();
				}
				else{
					inter->receivedHtPacketEvent(c.getPacketRef(),NULL,this);
					updateRxBufferCount(c.getPacketRef());
				}
			}
		}
		//If not dword packet, go to receive second dword state
		else{
			receive_state = RECEIVE_SECOND_DWORD;
			delete receivedPacket;
			receivedPacket = c.giveControl();
		}
	}
}

void LogicalLayer::handleNopPacket(sc_bv<32> &dword){
	//Create a nop packet
	NopPacket* nop = new NopPacket(dword);

	//Update the next node buffer free count
	nextNodeCommandBuffersFree[VC_POSTED] += (int)nop->getFreeBufPostedCmd();
	nextNodeDataBuffersFree[VC_POSTED] += (int)nop->getFreeBufPostedData();
	nextNodeCommandBuffersFree[VC_NON_POSTED] += (int)nop->freeBufNonPostedCmd();
	nextNodeDataBuffersFree[VC_NON_POSTED] += (int)nop->freeBufNonPostedData();
	nextNodeCommandBuffersFree[VC_RESPONSE] += (int)nop->freeBufResponseCmd();
	nextNodeDataBuffersFree[VC_RESPONSE] += (int)nop->freeBufResponseData();
	packetIdCounter = (int)nop->getRxNextPacketToAck();

	//If in retry mode, delete old entries in the history
	if(retry_mode){
		bool done = packetHistory.empty();
		while(!done){
			if(((packetIdCounter - packetHistory.front().id + 256) % 256) < 128){
				delete packetHistory.front().packet;
				delete [] packetHistory.front().data;
				packetHistory.pop_front();
				done = packetHistory.empty();
			}
			else done = true;
		}
	}
}

void LogicalLayer::dwordToSendRequested(sc_bv<32> &dword,bool &lctl,bool &hctl){
	//during reset, don't send anything
	if(!resetx.read()) return;

	if(send_state == SEND_SECOND_DWORD){
		//get the second dword from the packet
		dword = currentSendPacket.packet->getVector().range(63,32);
		//Command packet have CTL=1
		lctl = true; hctl = true;
		
		//Go to the correct state depending on packet type
		if(currentSendPacket.packet->hasDataAssociated()){
			sendDataCount = 0;
			send_state = SEND_DATA;
		}
		else{
			if(retry_mode){
				send_state = SEND_CRC;
			}
			/** In retry mode, packets are stored in history and can be
				deleted when history is acknowleged.  When not in retry mode,
				this does not happen so delete immediately after send*/
			else{
				delete currentSendPacket.packet;
				send_state = SEND_IDLE;
			}
		}
	}
	//If sending an address extension.  This is not supported by the tunnel but
	//should be handle cleanly by responding with an error response.  If here,
	//the address extension has already been sent, now send the actual packet
	else if(send_state == SEND_ADDR_EXT){
		//send first dword
		dword = currentSendPacket.packet->getVector().range(31,0);

		//go to correct state depending on packet content
		bool has_data = currentSendPacket.packet->hasDataAssociated();
		VirtualChannel vc = currentSendPacket.packet->getVirtualChannel();

		if(!currentSendPacket.packet->isDwordPacket()){
			send_state = SEND_SECOND_DWORD;
		}
		else if(has_data){
			send_state = SEND_DATA;
		}
		else if(retry_mode){
			send_state = SEND_CRC;
		}
		/** In retry mode, packets are stored in history and can be
			deleted when history is acknowleged.  When not in retry mode,
			this does not happen so delete immediately after send*/
		else{
			send_state = SEND_IDLE;
			delete currentSendPacket.packet;
		}
	}
	else if(send_state == SEND_DATA){
		//Check if sending a nop in the middle of the data is necessary
		if(isSendingNopRequired()){
			//Delete any previous nop packet
			delete nopSendPacket;
			nopSendPacket = generateNopPacket();
			dword = nopSendPacket->getVector().range(31,0);
			lctl = true; hctl = true;
			if(retry_mode){
				send_state = SEND_NOP_CRC;
			}
		}
		//otherwise keep sending data
		else{
			lctl = false; hctl = false;
			dword = currentSendPacket.data[sendDataCount];
			if(sendDataCount++ == currentSendPacket.packet->getDataLengthm1()){
				if(retry_mode){
					send_state = SEND_CRC;
				}
				/** In retry mode, packets are stored in history and can be
					deleted when history is acknowleged.  When not in retry mode,
					this does not happen so delete immediately after send*/
				else{
					send_state = SEND_IDLE;
					delete currentSendPacket.packet;
					delete[] currentSendPacket.data;
				}
			}
		}
	}
	else if(send_state == SEND_NOP_CRC){
		int crc = calcultatePacketCrc(nopSendPacket,NULL);
		dword = ~crc;
		lctl = true; hctl = false;
		send_state = SEND_DATA;
	}
	else if(send_state == SEND_CRC){
		int crc = calcultatePacketCrc(currentSendPacket.packet,currentSendPacket.data);
		dword = ~crc;
		//Value of lctl and hctl depends on if the packet has data or not
		if(currentSendPacket.packet->hasDataAssociated()){
			lctl = false; hctl = true;
		}
		else{
			lctl = true; hctl = false;
		}
		send_state = SEND_IDLE;

		//If what was just sent a disconnect nop, then we must complete the retry sequence
		if(disconNop){
			//reset retry initiation variables
			initiate_retry_disconnect = false;
			disconNop = false;

			//Start the retry disconnect and reconnect on the physical level
			physicalLayer->retryDisconnectAndReconnect();

			//Clear current list of packets to send
			packetQueue.clear();
			packetQueue = packetHistory;
			for(int n = 0; n < 3; n++){
				commandBuffersAdvertised[n] = 0;
				dataBuffersAdvertised[n] = 0;
			}
		}
	}
	else{
		//If a retry sequence should be initiated
		if(initiate_retry_disconnect){
			//Generate a disconnect nop
			delete nopSendPacket;
			nopSendPacket = new NopPacket(0,0,0,0,0,0,
			  true, false, false, 0);
			currentSendPacket.packet = nopSendPacket;
			currentSendPacket.data = NULL;
			disconNop = true;

			//Send that disconnect nop
			dword = nopSendPacket->getVector().range(31,0); lctl = true; hctl = true;
			send_state = SEND_CRC;
		}
		//Send nop if it is required (for buffer reasons, or if nothing else to send|)
		else if(isSendingNopRequired() || packetQueue.empty()){
			//Delete any previous nop packet
			delete nopSendPacket;
			//create a new not
			nopSendPacket = generateNopPacket();
			currentSendPacket.packet = nopSendPacket;
			currentSendPacket.data = NULL;

			//Send the nop
			dword = currentSendPacket.packet->getVector().range(31,0);
			lctl = true; hctl = true;
			if(retry_mode){
				send_state = SEND_CRC;
			}
		}
		//Otherwise, attempt to send the packet on top of the queue
		else{

			//Check if the top packet can be sent : check if the next
			//node has sufficient buffers to receive it
			ControlPacket * cmd = packetQueue.front().packet;
			bool has_data = cmd->hasDataAssociated();
			VirtualChannel vc = cmd->getVirtualChannel();
			bool canBeSent = false;
			if(vc <= 2){
				canBeSent = nextNodeCommandBuffersFree[vc] && 
					(nextNodeDataBuffersFree[vc] || !has_data);
			}
			bool delete_command = false;

			//If it can be sent, go to the appropriate state to send it
			if(cmd->getPacketCommand() == NOP){
				currentSendPacket = packetQueue.front();
				packetQueue.pop_front();
				if(retry_mode){
					send_state = SEND_CRC;
				}
				else delete_command = true;
			}
			if(canBeSent){
				nextNodeCommandBuffersFree[vc]--;
				if(has_data) nextNodeDataBuffersFree[vc]--;

				currentSendPacket = packetQueue.front();
				packetQueue.pop_front();
				if(cmd->getPacketCommand() == ADDR_EXT){
					send_state = SEND_ADDR_EXT;
				}
				else if(!cmd->isDwordPacket()){
					send_state = SEND_SECOND_DWORD;
				}
				else if(has_data){
					sendDataCount = 0;
					send_state = SEND_DATA;
				}
				else if(retry_mode){
					send_state = SEND_CRC;
				}
				/** In retry mode, packets are stored in history and can be
					deleted when history is acknowleged.  When not in retry mode,
					this does not happen so delete immediately after send*/
				else delete_command = true;
			}
			//Otherwise, send a nop
			else{
				//cout << "Not enough buffers, sending nop instead" << endl;
				delete nopSendPacket;
				nopSendPacket = generateNopPacket();
				currentSendPacket.packet = nopSendPacket;
				currentSendPacket.data = NULL;
				if(retry_mode){
					send_state = SEND_CRC;
				}
			}

			//If the packet is an address extension, send the address extension first
			if(currentSendPacket.packet->getPacketCommand() == ADDR_EXT){
				dword = ((AddressExtensionPacket*)(currentSendPacket.packet))->getAddressExtension();
			}
			//otherwise, send the first dword
			else{
				dword = currentSendPacket.packet->getVector().range(31,0);
			}
			if(delete_command) delete cmd;
			lctl = true; hctl = true;
		}
	}
}

void LogicalLayer::crcErrorDetected(){
	//If in retry mode, periodic CRC is not checked.  In retry mode,
	//pass the message up to the next layer
	if(!retry_mode)
		inter->crcErrorDetected();
}

void LogicalLayer::sendPacket(ControlPacket * packet,int * data){
	//Add the packet to the queue
	PacketAndData pad;
	pad.packet = packet;
	pad.data = data;
	pad.id = ++packetIdCounter;
	packetQueue.push_back(pad);

	//If in retry mode, also add it to history
	if(retry_mode)
		packetHistory.push_back(pad);
}

void LogicalLayer::flush(){
	//Wait (block) until all packet are sent
	while(!packetQueue.empty())wait();
}

int LogicalLayer::calcultatePacketCrc(ControlPacket * pkt,int * data){
	int crc = 0xFFFFFFFF;
	sc_bv<32> dword;

	if(pkt->getPacketCommand() == ADDR_EXT){
		dword = ((AddressExtensionPacket*)(currentSendPacket.packet))->getAddressExtension();
		calcultateDwordCrc(crc,dword,true);
	}

	dword = pkt->getVector().range(31,0);
	calcultateDwordCrc(crc,dword,true);

	if(!pkt->isDwordPacket()){
		dword = pkt->getVector().range(63,32);
		calcultateDwordCrc(crc,dword,true);
	}
	
	if(pkt->hasDataAssociated()){
		int max = (int)pkt->getDataLengthm1();
		for(int n = 0; n <= max; n++){
			dword = data[n];
			calcultateDwordCrc(crc,dword,false);
		}
	}
	return crc;
}

void LogicalLayer::calcultateDwordCrc(int &crc,sc_bv<32> &dword,bool ctl){
	for(int n = 0; n < 2; n++){
		int ctl_or = ctl ? 0x10000 : 0;
		int data = (dword.to_int() >> (n*16)) & 0xFFFF | ctl_or;

		for(int i = 0; i < 17; i++){
			//xor highest bit w/ message
			int tmp = ((crc >> 31 & 1)^((data >> i) & 1));
			//substract poly if greater
			crc = (tmp) ? (crc << 1) ^ PER_PACKET_CRC_POLY : ((crc << 1) | tmp);
		}
	}
}


void LogicalLayer::initiateRetrySequence(){
	//initiate_retry_disconnect will make the link send a disconnect nop and ignore RX
	initiate_retry_disconnect = true;
	//Go to idle RX state to be ready for a new packet when coming out of retry sequence
	receive_state = RECEIVE_IDLE;

	//Clear the current buffer count
	for(int n = 0; n < 3; n++){
		nextNodeCommandBuffersFree[n] = 0;
		nextNodeDataBuffersFree[n] = 0;
	}
}

bool LogicalLayer::isSendingNopRequired(){
	bool required = false;
	for(int n = 0; n < 3; n++){
		if((commandBuffersFree[n] - commandBuffersAdvertised[n]) > 2) required = true;
		if((dataBuffersFree[n] - dataBuffersAdvertised[n]) > 2) required = true;
	}
	return required;
}

void LogicalLayer::updateRxBufferCount(ControlPacket * receivedPacket){
	VirtualChannel vc = receivedPacket->getVirtualChannel();
	bool hasData = receivedPacket->hasDataAssociated();

	if(vc == VC_NONE) return;
	if(hasData) dataBuffersAdvertised[vc]--;
	else commandBuffersAdvertised[vc]--;
}

NopPacket * LogicalLayer::generateNopPacket(){
	sc_uint<2> responseBuffersToSend = min((commandBuffersFree[VC_RESPONSE] - commandBuffersAdvertised[VC_RESPONSE]),3);
	sc_uint<2> responseDataBuffersToSend = min((dataBuffersFree[VC_RESPONSE] - dataBuffersAdvertised[VC_RESPONSE]),3);
	sc_uint<2> postedBuffersToSend = min((commandBuffersFree[VC_POSTED] - commandBuffersAdvertised[VC_POSTED]),3);
	sc_uint<2> postedDataBuffersToSend = min((dataBuffersFree[VC_POSTED] - dataBuffersAdvertised[VC_POSTED]),3);
	sc_uint<2> npostedBuffersToSend = min((commandBuffersFree[VC_NON_POSTED] - commandBuffersAdvertised[VC_NON_POSTED]),3);
	sc_uint<2> npostedDataBuffersToSend = min((dataBuffersFree[VC_NON_POSTED] - dataBuffersAdvertised[VC_NON_POSTED]),3);

	commandBuffersAdvertised[VC_RESPONSE] += (int)responseBuffersToSend;
	dataBuffersAdvertised[VC_RESPONSE] += (int)responseDataBuffersToSend;
	commandBuffersAdvertised[VC_POSTED] += (int)postedBuffersToSend;
	dataBuffersAdvertised[VC_POSTED] += (int)postedDataBuffersToSend;
	commandBuffersAdvertised[VC_NON_POSTED] += (int)npostedBuffersToSend;
	dataBuffersAdvertised[VC_NON_POSTED] += (int)npostedDataBuffersToSend;

	return new NopPacket(responseBuffersToSend,
		      responseDataBuffersToSend,
			  postedBuffersToSend,
		      postedDataBuffersToSend,
			  npostedBuffersToSend,
		      npostedDataBuffersToSend,
			  false, false, false, rx_ack_value);
}

