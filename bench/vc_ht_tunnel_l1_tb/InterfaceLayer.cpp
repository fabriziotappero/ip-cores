//InterfaceLayer.cpp

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
#include "InterfaceLayer.h"

#include <iostream>

using namespace std;


InterfaceLayer::InterfaceLayer(sc_module_name name) : sc_module(name){
	SC_THREAD(rx_process);
	sensitive_pos(clk);

	SC_THREAD(tx_process);
	sensitive_pos(clk);

	receivePacket = NULL;
	tx_state = TX_IDLE;
	rx_state = RX_IDLE;
}

InterfaceLayer::~InterfaceLayer(){
	///Free all packet and data allocated memory
	for(deque<PacketAndData>::iterator i = packetQueue.begin();
		i != packetQueue.end(); i++)
	{
		delete (*i).packet;
		delete [] (*i).data;
	}
	//Might still be NULL, that's OK
	delete receivePacket;
}

void InterfaceLayer::tx_process(){
	while(true){
		if(!resetx.read()) tx_state = TX_IDLE;
		else{
		switch(tx_state){
		case TX_SEND_DATA:
		{
			sc_bv<64> bv;
			bv.range(63,32) = 0;
			bv.range(31,0) = packetQueue.front().data[tx_data_sent];
			usr_packet_ui = bv;
			
			//Send data until we reached the data count for that packet
			if(tx_data_sent++ == packetQueue.front().packet->getDataLengthm1()){
				delete packetQueue.front().packet;
				delete [] packetQueue.front().data;
				packetQueue.pop_front();
				tx_state = TX_IDLE;
			}
		}
			break;
		default:
			//If nothing to send, don't activate user available
			if(packetQueue.empty()) usr_available_ui = false;
			else{
				///Check the VC of the next packet to send, and if it has data
				VirtualChannel vc = packetQueue.front().packet->getVirtualChannel();
				bool hasData = packetQueue.front().packet->hasDataAssociated();

				///Check if there is enough buffers so that it can be sent
				bool canSend;
				if(vc == VC_POSTED){
					canSend = (sc_bit)ui_freevc0_usr.read()[5] && (sc_bit)ui_freevc1_usr.read()[5] &&
						(!hasData || (sc_bit)ui_freevc0_usr.read()[4] && (sc_bit)ui_freevc1_usr.read()[4]);					
				}
				else if(vc == VC_NON_POSTED){
					canSend = (sc_bit)ui_freevc0_usr.read()[3] && (sc_bit)ui_freevc1_usr.read()[3] &&
						(!hasData || (sc_bit)ui_freevc0_usr.read()[2] && (sc_bit)ui_freevc1_usr.read()[2]);					
				}
				else{
					canSend = (sc_bit)ui_freevc0_usr.read()[1] && (sc_bit)ui_freevc1_usr.read()[1] &&
						(!hasData || (sc_bit)ui_freevc0_usr.read()[0] && (sc_bit)ui_freevc1_usr.read()[0]);					
				}

				///If enough buffers
				if(canSend){
					///Make the next dword available
					usr_available_ui = true;
					///Output the packet
					usr_packet_ui = packetQueue.front().packet->getVector();
					///If it has data associated, go to the state to send it
					if(hasData){
						tx_state = TX_SEND_DATA;
						tx_data_sent = 0;
					}
					//otherwise delete the current packet entry
					else{
						delete packetQueue.front().packet;
						delete [] packetQueue.front().data;
						packetQueue.pop_front();
					}
				}
				else  usr_available_ui = false;
			}
		}
		}
		wait();
	}
}

void InterfaceLayer::rx_process(){
	//Always consume what is received
	usr_consume_ui = true;
	while(true){
		if(!resetx.read()) rx_state = RX_IDLE;
		else{

		switch(rx_state){
		case RX_RECEIVE_DATA:
			//store data
			receiveData[rx_received_data] = ui_packet_usr.read().range(31,0).to_int();
			//If receiving data is done, go back to an idle state
			if(rx_received_data++ == receivePacket->getDataLengthm1()){
				handler->receivedInterfacePacketEvent(receivePacket,receiveData,
					receiveDirecRoute,receiveSide,this);
				rx_state = RX_IDLE;
			}
			break;
		default:
			//If there is data available
			if(ui_available_usr.read()){
				//Create a packet from the quad word
				PacketContainer c = ControlPacket::createPacketFromQuadWord(ui_packet_usr);
				//Delete the previous received packet and replace with new
				delete receivePacket;
				receivePacket = c.giveControl();
				receiveSide = ui_side_usr.read();
				receiveDirecRoute = ui_directroute_usr.read();

				//If it has data, go to data receiving state
				if(receivePacket->hasDataAssociated()){
					rx_state = RX_RECEIVE_DATA;
					rx_received_data = 0;
				}
				//Otherwise, launch event that packet is received
				else{
					handler->receivedInterfacePacketEvent(receivePacket,NULL,
						receiveDirecRoute,receiveSide,this);
				}
			}
		}
		}
		wait();		

	}
}

void InterfaceLayer::sendPacket(ControlPacket * packet,int * data,bool side){
	//Add the packet to the queue
	PacketAndData pad;
	pad.packet = packet;
	pad.data = data;
	pad.side = side;
	packetQueue.push_back(pad);
}

void InterfaceLayer::flush(){
	//wait until the send queue is empty
	while(!packetQueue.empty()) wait();
}



