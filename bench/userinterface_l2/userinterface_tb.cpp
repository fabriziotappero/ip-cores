//userinterface_tb.cpp
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

#include "userinterface_tb.h"
#include "../core/ht_datatypes.h"
#include "../../rtl/systemc/core_synth/synth_datatypes.h"
#include "../core/require.h"
#include <math.h>

using namespace std;

userinterface_tb::userinterface_tb(sc_module_name name): sc_module(name){
	std::cout << "Constructing UserInterfaceTest..." << endl;

	SC_THREAD(testRxInterface);
	sensitive_pos	<<	clk;
	SC_THREAD(testTxUserWrInterface);
	sensitive_pos	<<	clk;
	SC_THREAD(testTxSendSchedulerRdInterface);
	sensitive_pos	<<	clk;

	SC_THREAD(manage_memories);
	sensitive_pos	<<	clk;

	SC_METHOD(clockOutputSeparator)
	sensitive_neg << clk;

	SC_METHOD(testRxInterfaceSensitive);
	sensitive_pos << clk;
	sensitive << ui_available_usr << 
		ui_consume_db1 << ui_consume_db0;

	clockCycleNumber = 0;

	// Find the size of the memories
	// memory_size = 2^USER_MEMORY_ADDRESS_WIDTH (exponent)
	int memory_size = 1;
	for(int n = 0; n < USER_MEMORY_ADDRESS_WIDTH; n++)
		memory_size *= 2;

	//Allocate the memory
	memory0 = new int[memory_size];
	memory1 = new int[memory_size];

	//Initialise memory
	for(int n = memory_size -1; n > 0; n--){
		memory0[n] = 0;
		memory1[n] = 0;
	}

	std::cout << "Construction done..." << endl;
}

userinterface_tb::~userinterface_tb(){
	delete[] memory0;
	delete[] memory1;
}

/**
	Packets à envoyer :
	Response : TgtDone, RdResponse
	Request : Read, Write Posted, Write non posted, Atomic, Broadcast
*/
void userinterface_tb::testRxInterface(){
	
	//We do the general initialization of the module here.  Could be done in
	//any SC_THREAD actually.
	generalInitialisation();

	rxDataValue = 101;

	//Fill a vector of test packets
	//Randomly generate a series of packets
	
	for(int side = 0; side <= 1; side++){
		addPacketsToQueue(sendPackets[side],10);
	}
	
	///Make some packets available
    bool ctlbuf0_availableBuffer = true;
	bool ctlbuf1_availableBuffer = true;

	if(!sendPackets[0].empty()){
		/** Output the packet in front of the queue
			Note : an internal buffer (packetSendBuffer0) is used because I originally
			thought that like VHDL, that outputs could not be read
		*/
		packetSendBuffer0  = sendPackets[0].front();
		ro0_packet_ui = syn_ControlPacketComplete(packetSendBuffer0);
	}
	else{
		ctlbuf0_availableBuffer = false;
	}

	if(!sendPackets[0].empty()){
		packetSendBuffer1  = sendPackets[1].front();
		ro1_packet_ui = syn_ControlPacketComplete(packetSendBuffer1);
	}
	else{
		ctlbuf1_availableBuffer = false;
	}


	

    //Start sending test packets
	while(true){
		wait();

		//Don't send anything if the reset is on
		if(resetx.read() == false) continue;

		//Randomly make a packet available
		if(!sendPackets[0].empty())
			ctlbuf0_availableBuffer = (bool)(rand() % 2);
		else
			ctlbuf0_availableBuffer = false;

		//If side 0 packet is consumed
		if(ui_consume_ro0){
			//Check that there was a packet to consume
			if(!ro0_available_ui.read()){
				cout << "ERROR: Packet consumed while none were available" << endl;
				return;
			}
			
			//Debugging output
			if(outputRdMessages){
				cout << "Packet was sent from side 0 : " << packetSendBuffer0 << endl;
				if(packetSendBuffer0.packet->hasDataAssociated()){
					cout << "Data length with packet : " << (int)(packetSendBuffer0.packet->getDataLengthm1() + 1) << endl;
				}
			}

			/**
				Store information about the packet that can be checked when it is sent to the
				user and when data will be retrieved from the databuffer
			*/
			sideFromWhereSendData = false;
			channelToAccess = packetSendBuffer0.packet->getVirtualChannel();
			dataAddress = (int)packetSendBuffer0.data_address;
			dataLeftToSend = (int)(packetSendBuffer0.packet->getDataLengthm1() + 1);

			//Remove current packet and output the next packet
			sendPackets[0].pop_front();
			if(!sendPackets[0].empty()){
				packetSendBuffer0  = sendPackets[0].front();
			}
			else{
				ctlbuf0_availableBuffer = false;
			}
		}

		//Randomly make a packet available
		if(!sendPackets[1].empty())
			ctlbuf1_availableBuffer = (bool)(rand() % 2);
		else
			ctlbuf1_availableBuffer = false;

		//If side 0 packet is consumed
		if(ui_consume_ro1){
			//Check that there was a packet to consume
			if(!ro1_available_ui.read()){
				cout << "ERROR: Packet consumed while none were available" << endl;
				return;
			}
			
			//Debugging output
			if(outputRdMessages){
				cout << "Packet was sent from side 1 : " << packetSendBuffer1 << endl;
				if(packetSendBuffer1.packet->hasDataAssociated()){
					cout << "Data length with packet : " << (int)(packetSendBuffer1.packet->getDataLengthm1() + 1) << endl;
				}
			}

			/**
				Store information about the packet that can be checked when it is sent to the
				user and when data will be retrieved from the databuffer
			*/
			sideFromWhereSendData = true;
			channelToAccess = packetSendBuffer1.packet->getVirtualChannel();
			dataAddress = (int)packetSendBuffer1.data_address;
			dataLeftToSend = (int)(packetSendBuffer1.packet->getDataLengthm1() + 1);


			//Remove current packet and output the next packet
			sendPackets[1].pop_front();
			if(!sendPackets[1].empty()){
				packetSendBuffer1  = sendPackets[1].front();
			}
			else{
				ctlbuf1_availableBuffer = false;
			}
		}

		//Output the temporary buffers that were used until now
		ro0_available_ui = ctlbuf0_availableBuffer;
		ro1_available_ui = ctlbuf1_availableBuffer;
		ro0_packet_ui =	packetSendBuffer0;
		ro1_packet_ui =	packetSendBuffer1;

		//Debugging messages
		if(outputRdMessages && outputSide0){
			cout << "ro0_available_ui = " << ctlbuf0_availableBuffer << endl;
			cout << "Packet on output0 = " << packetSendBuffer0 << endl;
		}
		if(outputRdMessages && outputSide1){
			cout << "ro1_available_ui = " << ctlbuf1_availableBuffer << endl;
			cout << "Packet on output1 = " << packetSendBuffer1 << endl;
		}

	}

}

void userinterface_tb::testRxInterfaceSensitive(){
	/** This is a very poor test...  The validity of the data
		received is not even checked automatically...  Some work
		would be needed to make this a completely autonomous test, but
		at least the framework is there.  
	*/

	//Consume data for user where there is some available
	if(ui_available_usr.read() || dataLeftToSend > 0){
		if(clk.event() && outputRdMessages){
			cout << "User received data : " << ui_packet_usr.read() << endl;
		}
		usr_consume_ui = true;
	}
	else
		usr_consume_ui = false;

	//
	if(ui_consume_db1.read()){
		if(clk.event() && resetx.read() == true){
			/*
			require(dataLeftToSend > 0,"No more data to send!");
			require(sideFromWhereSendData == true,"Reading from wrong side!");
			require(channelToAccess == ui_vctype_db1.read(),"Reading from wrong vc! side");
			require(dataAddress == ui_address_db1.read(),"Reading from wrong address!");
			*/

			dataLeftToSend--;
			rxDataValue ++;
			if(outputRdMessages){
				cout << "Just sent data side 1 : " << rxDataValue << endl;
				cout << "VC being accessed : " << ui_vctype_db1.read() << endl;
			}
			
		}

		db1_data_ui = sc_uint<32>(rxDataValue);
		if(outputRdMessages){
			cout << "Data left to send : " << dataLeftToSend << endl;
		}
	}
	else if(ui_consume_db0.read()){
		if(clk.event() && resetx.read() == true){
			/*
			require(dataLeftToSend > 0,"No more data to send!");
			require(sideFromWhereSendData == false,"Reading from wrong side!");
			require(channelToAccess == ui_vctype_db0.read(),"Reading from wrong vc!");
			require(dataAddress == ui_address_db0.read(),"Reading from wrong address!");
			*/

			dataLeftToSend--;
			rxDataValue++;
			if(outputRdMessages){
				cout << "Just sent data side 0 : " << rxDataValue << endl;
				cout << "VC being accessed : " << ui_vctype_db0.read() << endl;
			}
		}

		db0_data_ui = sc_uint<32>(rxDataValue);

		if(outputRdMessages){
			cout << "Data left to send : " << dataLeftToSend << endl;
		}
	}

}


void userinterface_tb::testTxUserWrInterface(){

	int dataValue = 202;

	usr_packet_ui = sc_bv<64>();
	usr_available_ui = false;
	usr_side_ui = false;

	addPacketsToQueue(userPacketQueue,50,9999999);

	PacketContainer usr_packetBuffer ;

	int dataLengthToSend = (int)usr_packetBuffer->getDataLengthm1();

	bool done = false;

	while(!done){
		wait();

		//Wait for reset to be done
		if(resetx.read() == false) continue;
		
		//If a packet is being sent
		if(usr_available_ui.read() ){
			if(outputTxMessages){
				cout << "Packet was sent : " << usr_packetBuffer << endl;
			}
			//If data associated with the packet, send it
			if(usr_packetBuffer->hasDataAssociated()){
				if(outputTxMessages){
					cout << "Sending data : " << dataValue << endl;
				}
				dataLengthToSend = (int)usr_packetBuffer->getDataLengthm1();
				cout << "Sent : " << sc_uint<64>(dataValue) << endl;
				usr_packet_ui = sc_uint<64>(dataValue++);
				usr_available_ui = false;
			}
			//Otherwise, if there are packets left in the queue, send them
			else if(!userPacketQueue.empty()){
				usr_packetBuffer = userPacketQueue.front();
				usr_packet_ui = usr_packetBuffer;
				userPacketQueue.pop_front();
				usr_available_ui = true;
			}
			//If no packets left, we're done
			else{
				usr_available_ui = false;
				done = true;
			}
		}
		//Si il reste des données à envoyer, on envoie ces données
		else if(dataLengthToSend > 0){
			if(outputTxMessages){
				cout << "Sending data : " << dataValue << endl;
			}
			dataLengthToSend-- ;
			usr_packet_ui = sc_uint<64>(dataValue++);
			usr_available_ui = false;
		}
		//No more data to send, output next message if any left to send
		else{
			if(outputTxMessages){
				cout << "Finished sending data, putting new packet on line" << endl;
			}
			if(!userPacketQueue.empty()){
				usr_packetBuffer = userPacketQueue.front();
				userPacketQueue.pop_front();
				usr_packet_ui = usr_packetBuffer;
				usr_available_ui = true;
			}
			else{
				usr_available_ui = false;
				done = true;
			}

		}
	}
	usr_available_ui = false;
}

void userinterface_tb::testTxSendSchedulerRdInterface(){

	//Initialize flow control interface to an initial value
	fc0_datavc_ui = VC_POSTED;
	fc0_consume_data_ui = false;
	fc0_user_fifo_ge2_ui = sc_bv<3>();

	fc1_datavc_ui = VC_POSTED;
	fc1_consume_data_ui = false;
	fc1_user_fifo_ge2_ui = sc_bv<3>();

	//Represents the USER fifo : [side][VC]
	std::deque<PacketContainer> packetQueue[2][3];
	int dataLeftToReceive[2] = {0,0};
	VirtualChannel dataToReceiveFromVc[2];

	while(true){
		wait();
	
		//Wait for reset to be over
		if(resetx.read() == false) continue;

		//Set some default values
		fc0_datavc_ui = VC_POSTED;
		fc0_consume_data_ui = false;
		fc1_datavc_ui = VC_POSTED;
		fc1_consume_data_ui = false;

		/**
			The following two lines are to force to NEVER read
			the data of the user interface to test the buffers
			filling up.
		*/
		//dataLeftToReceive[0] = 0;
		//dataLeftToReceive[1] = 0;

		//****************************************************************
		//Read data if any left to read, or
		//maybe read from the FIFO
		//*****************************************************************
		if(dataLeftToReceive[0] > 0){
			if(rand() % 10){
				//Randomly read data 90% of the time
				fc0_consume_data_ui = true;
				fc0_datavc_ui = dataToReceiveFromVc[0];
				dataLeftToReceive[0]--;
				if(outputTxMessages){
					cout << "Reading data from 0 : " << (sc_uint<32>) ui_data_fc0 << " left = " << dataLeftToReceive[0] << endl;
				}
			}
		}
		//If there are data received from FIFO
		else if(!packetQueue[0][0].empty() || 
			    !packetQueue[0][1].empty() || 
				!packetQueue[0][2].empty()){
			if(rand() % 4){
				//Select vc to read from
				VirtualChannel vc;
				if(!packetQueue[0][VC_RESPONSE].empty()) vc = VC_RESPONSE;
				else if(!packetQueue[0][VC_POSTED].empty()) vc = VC_POSTED;
				else vc = VC_NON_POSTED;

				//Get the packet
				PacketContainer &packet = packetQueue[0][vc].front();
				//and find how much data it has
				if(packet->hasDataAssociated()){
					dataLeftToReceive[0] = (int)(packet->getDataLengthm1() + 1);
					dataToReceiveFromVc[0] = packet->getVirtualChannel();
				}
				if(outputTxMessages){
					cout << "Reading packet from fifo0 "  << endl <<
						packet << endl;
				}
				//Remove packet from queue (virtual user fifo)
				packetQueue[0][vc].pop_front();
			}			
		};

		if(dataLeftToReceive[1] > 0){
			if(rand() % 10){
				//Randomly read data 90% of the time
				fc1_consume_data_ui = true;
				fc1_datavc_ui = dataToReceiveFromVc[1];
				dataLeftToReceive[1]--;
				if(outputTxMessages){
					cout << "Reading data from 1 " << endl;
				}
			}
		}
		else if(!packetQueue[1][0].empty() || 
			    !packetQueue[1][1].empty() || 
				!packetQueue[1][2].empty()){
			if(rand() % 4){
				//Select vc to read from
				VirtualChannel vc;
				if(!packetQueue[1][VC_RESPONSE].empty()) vc = VC_RESPONSE;
				else if(!packetQueue[1][VC_POSTED].empty()) vc = VC_POSTED;
				else vc = VC_NON_POSTED;

				//Get the packet
				PacketContainer &packet = packetQueue[1][vc].front();
				//and find how much data it has
				if(packet->hasDataAssociated()){
					dataLeftToReceive[1] = (int)(packet->getDataLengthm1() + 1);
					dataToReceiveFromVc[1] = (int)packet->getVirtualChannel();
				}
				if(outputTxMessages){
					cout << "Reading packet from fifo1 "  << endl <<
						packet << endl;
				}
				//Remove packet from queue (virtual user fifo)
				packetQueue[1][vc].pop_front();
			}			
		};

		//****************************************************************
		//Add the received packet to the FIFO
		//Check if the received packet is valid
		//*****************************************************************
		if(ui_available_fc0.read()){
			PacketContainer ui_packet_fc0_sim = ControlPacket::createPacketFromQuadWord(ui_packet_fc0.read());
			VirtualChannel vc = ui_packet_fc0_sim->getVirtualChannel();
			bool hasData = ui_packet_fc0_sim->hasDataAssociated();

			require(vc < 4,"Invalid virtual channel packet received from 0\n");

			require(packetQueue[0][vc].size() <= USER_FIFO_DEPTH,
					"ERROR: trying to write in a full FIFO!\n");

			packetQueue[0][vc].push_back(ui_packet_fc0_sim);
			if(outputTxMessages){
				cout << "Adding Packet to fifo0" << endl
					<< ui_packet_fc0.read() << endl;
			}
		}

		if(ui_available_fc1.read()){
			PacketContainer ui_packet_fc1_sim = ControlPacket::createPacketFromQuadWord(ui_packet_fc1.read());
			VirtualChannel vc = ui_packet_fc1_sim->getVirtualChannel();
			bool hasData = ui_packet_fc1_sim->hasDataAssociated();

			require(vc < 4,"Invalid virtual channel packet received from 1\n");

			require(packetQueue[1][vc].size() <= USER_FIFO_DEPTH,
					"ERROR: trying to write in a full FIFO!\n");

			packetQueue[1][vc].push_back(ui_packet_fc1_sim);
			if(outputTxMessages){
				cout << "Adding Packet to queue1" << endl
					<< ui_packet_fc1.read() << endl;
			}
		}

		//****************************************************************
		//Calculate the FreeVC signal to send to the user interface
		//*****************************************************************
		sc_bv<3> send0_ge2_buf;
		for(int n = 0; n < 3 ; n++){
			send0_ge2_buf[n] = packetQueue[0][n].size() >= 2;
		}
		fc0_user_fifo_ge2_ui = send0_ge2_buf;

		sc_bv<3> send1_ge2_buf;
		for(int n = 0; n < 3 ; n++){
			send1_ge2_buf[n] = packetQueue[1][n].size() >= 2;
		}
		fc1_user_fifo_ge2_ui = send1_ge2_buf;
	}

}

void userinterface_tb::generalInitialisation(){
	ControlPacket::outputExtraInformation = true;
	csr_default_dir = true;
	csr_masterhost = false;
	dataLeftToSend = 0;
	maxDataAddress = (int)pow(2,BUFFERS_ADDRESS_WIDTH);

	for(int n = 0 ; n < DirectRoute_NumberDirectRouteSpaces;n++){
		csr_direct_route_oppposite_dir[n] = false;
		csr_direct_route_base[n] = sc_bv<32>();
		csr_direct_route_limit[n] = sc_bv<32>();
	}
	csr_direct_route_oppposite_dir[0] = true;
	csr_direct_route_base[0] = sc_bv<32>("0x12950468");
	csr_direct_route_limit[0] = sc_bv<32>("0x16359203");
}

void userinterface_tb::addPacketsToQueue(
	std::deque<PacketContainer> &queue,int number,int seed){

	//Randomly generate chains, this is the number of packets that are
	//part of the chain left to generate
	int chainLengthLeft = 0;
	//Temp variable to store generate packets
	PacketContainer pkt;
	//Seed the random generator
	if(seed > 0){
		srand(seed);
	}
	
	//If adding packets to queue, verify if the last packet was part of the
	//chain and add a last packet for that chani
	if(!queue.empty()){
		pkt = queue.back();
		if(pkt->isChain()){
			chainLengthLeft = 1;
		}
	}

	//Add packets to the queue
	for(int n = 0; n < number;n++){
		getRandomPacket(pkt,chainLengthLeft);
		queue.push_back(pkt);
	}
}

void userinterface_tb::addPacketsToQueue(
		std::deque<ControlPacketComplete> &queue,int number,int seed){

	//Randomly generate chains, this is the number of packets that are
	//part of the chain left to generate
	int chainLengthLeft = 0;
	//Temp variable to store generate packets
	ControlPacketComplete pkt;
	sc_uint<BUFFERS_ADDRESS_WIDTH> randomDataAddress = rand() % maxDataAddress;

	//Seed the random generator
	if(seed > 0){
		srand(seed);
	}

	//If adding packets to queue, verify if the last packet was part of the
	//chain and add a last packet for that chani
	if(!queue.empty()){
		pkt = queue.back();
		if(pkt.packet->isChain()){
			chainLengthLeft = 1;
		}
	}

	//Add packets to the queue
	for(int n = 0; n < number;n++){
		getRandomPacket(pkt.packet,chainLengthLeft);
	
		pkt.data_address = randomDataAddress;
		queue.push_back(pkt);
	}
}

void userinterface_tb::getRandomPacket(PacketContainer &lastPacketToUpdateWithNew,
												   int &chainLengthLeft){
	/** Generate random elements to create random packets
	*/
	int randomPacketValue = rand() % 7;
	sc_bv<4> randomDataLength = sc_uint<4>(rand() % 16);
	sc_bv<4> randomSeqID = sc_uint<4>(rand() % 16);
	sc_bv<5> randomUnitID = sc_uint<5>(rand() % 32);
	sc_bv<2> randomRqUID = sc_uint<2>(rand() % 4);
	sc_bv<5> randomSrcTag = sc_uint<5>(rand() % 32);
	bool randomBridge = rand() % 2;
	bool randomPassPW = rand() % 2;
	bool randomResponsePassPW = rand() % 2;
	bool randomDoubleWordDataLength = rand() % 2;
	bool randomDataError = rand() % 2;
	
	sc_bv<40> randomAddress;
	for(int j = 0; j < 40; j++){
		bool randomBool = rand() % 2;
		randomAddress[j] = randomBool;
	}
	bool randomStartChain = !(rand() % 10);

	//If part of chain
	if(chainLengthLeft > 0){
		//The last packet of a chain of packets does not have the chain bit active
		bool chainBitOn = chainLengthLeft != 1;
		chainLengthLeft--;

		//Create a new Posted write which is to the same destination using the last packet valeus
		//and some new random values
		WritePacket* oldPacket = dynamic_cast<WritePacket*>(lastPacketToUpdateWithNew.getPacketRef());
		ControlPacket* newPacket = new WritePacket( 
			oldPacket->getSeqID(),
			oldPacket->getUnitID(),
			randomDoubleWordDataLength,
			randomAddress.range(39,2),
			randomDoubleWordDataLength,
			oldPacket->getPassPW(),
			oldPacket->getDataError(),
			chainBitOn); 
		lastPacketToUpdateWithNew.takeControl(newPacket);
		
	}
	//If starting a new chain
	else if(randomStartChain){
		//Generate a random chain length (1 to 7)
		chainLengthLeft = rand() % 7+1;
		
		//Create a random posted write packet with chain bit on
		lastPacketToUpdateWithNew.takeControl(
			new WritePacket( randomSeqID,
			randomUnitID,
			randomDoubleWordDataLength,
			randomAddress.range(39,2),
			randomDoubleWordDataLength,
			randomPassPW,
			randomDataError,
			true) ); //Est de type Chain
		
	}
	else{
		//Otherwise, create a completely new random packet
		switch(randomPacketValue) {
		case 0 :
			lastPacketToUpdateWithNew.takeControl(
				new TargetDonePacket(randomUnitID,
				randomSrcTag,
				randomRqUID,
				randomBridge,
				RE_NORMAL,
				randomPassPW));
			break;
			
		case 1 :
			lastPacketToUpdateWithNew.takeControl(
				new ReadResponsePacket(randomUnitID,
				randomSrcTag,
				randomRqUID,
				randomDataLength,
				randomBridge,
				RE_NORMAL,
				randomPassPW));
			break;
			
		case 2 :
			lastPacketToUpdateWithNew.takeControl(
				new ReadPacket(randomSeqID,
				randomUnitID,
				randomSrcTag,
				randomDataLength,
				randomAddress.range(39,2),
				randomDoubleWordDataLength,
				randomPassPW,
				randomResponsePassPW)) ;
			
			break;
			
		case 3 :
			lastPacketToUpdateWithNew.takeControl(
				new WritePacket( randomSeqID,
				randomUnitID,
				randomDataLength,
				randomAddress.range(39,2),
				randomDoubleWordDataLength,
				randomPassPW,
				randomDataError,
				false)) ; //Pas de type Chain
			break;
		case 4 :
			lastPacketToUpdateWithNew.takeControl(
				new WritePacket(  randomSeqID,
				randomUnitID,
				randomSrcTag,
				randomDataLength,
				randomAddress.range(39,2),
				randomDoubleWordDataLength,
				randomPassPW));
			
			break;
		case 5 :
			lastPacketToUpdateWithNew.takeControl(
				new AtomicPacket( randomSeqID,
				randomUnitID,
				randomSrcTag,
				randomDataLength,
				randomAddress.range(39,2),
				randomPassPW));
			
			break;
			
		case 6 :
			lastPacketToUpdateWithNew.takeControl(new BroadcastPacket(
				randomSeqID,
				randomUnitID,
				randomPassPW,
				randomAddress.range(39,2) 
				));
		}
	}
	
}

void userinterface_tb::manage_memories(){

	while(true){
		wait();
		//Manage writing
		if(ui_memory_write0.read()){
			memory0[(sc_uint<7>)ui_memory_write_address.read()] = (int)(sc_uint<32>)(ui_memory_write_data.read());
		}
		if(ui_memory_write1.read()){
			memory1[(sc_uint<7>)ui_memory_write_address.read()] = (int)(sc_uint<32>)(ui_memory_write_data.read());
		}

		//Manage reading
		ui_memory_read_data0 = memory0[(sc_uint<7>)ui_memory_read_address0.read()];
		ui_memory_read_data1 = memory1[(sc_uint<7>)ui_memory_read_address1.read()];

	}
}
