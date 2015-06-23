//csr_l2_tb.cpp

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

#include "csr_l2_tb.h"
#include <cstdlib>

using namespace std;

csr_l2_tb::csr_l2_tb(sc_module_name name) : sc_module(name){
	SC_THREAD(send_packets_csr);
	sensitive_pos(clk);
	SC_THREAD(verify_csr_response);
	sensitive_pos(clk);
	SC_THREAD(simulate_databuffer);
	sensitive_pos(clk);
	SC_THREAD(flow_control_read_signals);
	sensitive_pos(clk);
	sensitive << csr_available_fc0 << csr_available_fc1;

	SC_THREAD(grant_access_databuffer);
	sensitive_pos(clk);
	sensitive << csr_request_databuffer0_access_ui << csr_request_databuffer1_access_ui;

	generate_csr_requests_and_responses();
	srand(4623);
}

void csr_l2_tb::send_packets_csr(){
	//Initialize startup values
	ro0_available_csr = false;
	data_sent0 = 0;
	ro0_packet_csr = to_send0.front().pkt_cplt;

	ro1_available_csr = false;
	ro1_packet_csr = to_send1.front().pkt_cplt;
	data_sent1 = 0;

	syn_ControlPacketComplete default_syn_pkt;
	initialize_syn_ControlPacketComplete(default_syn_pkt);

	//Start with a reset
	resetx = false;
	for(int n = 0; n <5; n++){
		wait();
	}
	resetx = true;

	while(true){
		wait();
		/**
			At first, send packets from to_send0 and to_send1.  When the two
			queues are empty, send packets to both sides from to_send.  Having
			to_send0 and to_send1 makes sure that the CSR can truly receive from
			the two sides.  Then, having the same packet sent to both sides eases
			testing.
		*/
		if(!(to_send0.empty() && to_send1.empty())){
			ro0_available_csr = ((rand() % 10 < 4)
				|| (ro0_available_csr.read() && !csr_ack_ro0.read())) && !to_send0.empty() ;
			ro1_available_csr = ((rand() % 10 < 4)
				|| (ro1_available_csr.read() && !csr_ack_ro1.read())) && !to_send1.empty() ;
		}
		else{
			ro0_available_csr = ((rand() % 10 < 4) || 
				(ro0_available_csr.read() && (!csr_ack_ro0.read() || !csr_ack_ro1.read()) ))&&
				!to_send.empty();
			ro1_available_csr = ((rand() % 10 < 4) ||
				(ro1_available_csr.read() && (!csr_ack_ro0.read() || !csr_ack_ro1.read()) ))&&
				!to_send.empty();
		}

		if(!to_send0.empty()){
			ro0_packet_csr = to_send0.front().pkt_cplt;
		}
		else if(!to_send.empty()){
			ro0_packet_csr = to_send.front().pkt_cplt;
		}
		else
			ro0_packet_csr = default_syn_pkt;

		if(!to_send1.empty()){
			ro1_packet_csr = (syn_ControlPacketComplete)to_send1.front().pkt_cplt;
		}
		else if(!to_send.empty()){
			ro1_packet_csr = (syn_ControlPacketComplete)to_send.front().pkt_cplt;
		}
		else
			ro1_packet_csr = default_syn_pkt;

		//When sent packet is acked
		if(csr_ack_ro0.read()){
			//Packet left from side 0
			side_pkt_sent = 0;
			//Check that if the previous packet had data associated, that it was all sent
			if(data_size0 != 0)
				cout << "ERROR:Not all data sent side 0"<< endl;
			//Reset the data sent counter
			data_sent0 = 0;

			/**
				Set the variables necessary to simulate the databuffer to send the data
				associated with the packet sent.

				Once the data is extracted, pop the packet from it's queue.
			*/
			if(!to_send0.empty()){
				if(to_send0.front().pkt_cplt.packet->hasDataAssociated())
					data_size0 = to_send0.front().pkt_cplt.packet->getDataLengthm1()+1;
				data_address0 = to_send0.front().pkt_cplt.data_address;
				data_vc0 = to_send0.front().pkt_cplt.packet->getVirtualChannel();
				for(int n = 0; n < 16;n++){
					data0[n] = to_send0.front().data[n];
				}
				to_send0.pop_front();
			}
			else if(!to_send.empty()){
				if(to_send.front().pkt_cplt.packet->hasDataAssociated())
					data_size0 = to_send.front().pkt_cplt.packet->getDataLengthm1()+1;
				data_address0 = to_send.front().pkt_cplt.data_address;
				data_vc0 = to_send.front().pkt_cplt.packet->getVirtualChannel();
				for(int n = 0; n < 16;n++){
					data0[n] = to_send.front().data[n];
				}
				to_send.pop_front();
			}
			else cout << "ERROR : Side0 read and no packet to send" << endl;
		}

		//When sent packet is acked
		if(csr_ack_ro1.read()){
			//Packet left from side 1
			side_pkt_sent = 1;
			//Check that if the previous packet had data associated, that it was all sent
			if(data_size1 != 0)
				cout << "ERROR:Not all data sent side 1" << endl;
			//Reset the data sent counter
			data_sent1 = 0;

			/**
				Set the variables necessary to simulate the databuffer to send the data
				associated with the packet sent.

				Once the data is extracted, pop the packet from it's queue.
			*/
			if(!to_send1.empty()){
				if(to_send1.front().pkt_cplt.packet->hasDataAssociated())
					data_size1 = to_send1.front().pkt_cplt.packet->getDataLengthm1()+1;
				data_address1 = to_send1.front().pkt_cplt.data_address;
				data_vc1 = to_send1.front().pkt_cplt.packet->getVirtualChannel();
				for(int n = 0; n < 16;n++){
					data1[n] = to_send1.front().data[n];
				}
				to_send1.pop_front();
			}
			else if(!to_send.empty()){
				if(to_send.front().pkt_cplt.packet->hasDataAssociated())
					data_size1 = to_send.front().pkt_cplt.packet->getDataLengthm1()+1;
				data_address1 = to_send.front().pkt_cplt.data_address;
				data_vc1 = to_send.front().pkt_cplt.packet->getVirtualChannel();
				for(int n = 0; n < 16;n++){
					data1[n] = to_send.front().data[n];
				}
				to_send.pop_front();
			}
			else cout << "ERROR : Side1 read and no packet to send" << endl;
		}
	}
}

void csr_l2_tb::verify_csr_response(){
	//No response dwords received yet
	received0 = 0;
	received1 = 0;

	while(true){
		wait();

		//If response available for side 0
		if(csr_available_fc0.read()){
			//Check if it's from wrong side side
			/** This can happen when sending data : in the case csr_ack_ro0 is zero and side_pkt_sent is 1
				Or when receiving a new command packet from side 1*/
			if(!csr_ack_ro0.read() && side_pkt_sent != 0 || csr_ack_ro1.read())
				cout << "ERROR : Response not received on expected side : " << side_pkt_sent << endl;
			//If data is consumed from flow control and we still have expected data from side 0
			else if(!to_receive0.empty() && fc0_ack_csr.read()){
				//Check that it is the right dword
				if(to_receive0.front().dwords[received0] != sc_uint<32>(csr_dword_fc0.read())){
					cout << "ERROR in dword received from CSR (side 0)" << endl;
					cout << "  received0: " << received0 << endl;
					cout << "  Expected " << sc_uint<32>(to_receive0.front().dwords[received0]).to_string(SC_HEX)
						<< " Received " << csr_dword_fc0.read().to_string(SC_HEX) << endl;
				}

				//increment the number of dwords received
				received0++;
				//Remove the entry from the queue if the entry is finished
				if(received0 == to_receive0.front().size_with_data){
					received0 = 0;
					to_receive0.pop_front();
				}
			}
			//When all data from side0 has been receive, we then check if there is data that
			//had any side as a destination
			else if(!to_receive.empty() && fc0_ack_csr.read()){
				//Check if it is the correct dword
				if(to_receive.front().dwords[received0] != sc_uint<32>(csr_dword_fc0.read())){
					cout << "ERROR in dword received from CSR (side 0)" << endl;
					cout << "  received0: " << received0 << endl;
					cout << "  Expected " << sc_uint<32>(to_receive.front().dwords[received0]).to_string(SC_HEX)
						<< " Received " << csr_dword_fc0.read().to_string(SC_HEX) << endl;
				}

				//increment the number of dwords received
				received0++;
				//Remove the entry from the queue if the entry is finished
				if(received0 == to_receive.front().size_with_data){
					received0 = 0;
					to_receive.pop_front();
				}			
			}
			//If no respionse expected and some received, display ERROR
			else if(fc0_ack_csr.read())
				cout << "CSR Response (side 0) not expected!" << endl;
		}

		//If response available for side 1
		if(csr_available_fc1.read()){
			//Check if it's from wrong side side
			/** This can happen when sending data : in the case csr_ack_ro0 is zero and side_pkt_sent is 1
				Or when receiving a new command packet from side 1*/
			if(!csr_ack_ro1.read() && side_pkt_sent != 1 || csr_ack_ro0.read())
				cout << "ERROR : Response not received on expected side : " << side_pkt_sent << endl;
			//If data is consumed from flow control and we still have expected data from side 0
			else if(!to_receive1.empty() && fc1_ack_csr.read()){
				//Check that it is the right dword
				if(to_receive1.front().dwords[received1] != sc_uint<32>(csr_dword_fc1.read())){
					cout << "ERROR in dword received from CSR (side 1)" << endl;
					cout << "  received1: " << received1 << endl;
					cout << "  Expected " << sc_uint<32>(to_receive1.front().dwords[received1]).to_string(SC_HEX)
						<< " Received " << csr_dword_fc1.read().to_string(SC_HEX) << endl;
				}
				//increment the number of dwords received
				received1++;
				//Remove the entry from the queue if the entry is finished
				if(received1 == to_receive1.front().size_with_data){
					received0 = 0;
					to_receive1.pop_front();
				}
			}
			//When all data from side0 has been receive, we then check if there is data that
			//had any side as a destination
			else if(!to_receive.empty() && fc1_ack_csr.read()){
				//Check if it is the correct dword
				if(to_receive.front().dwords[received1] != sc_uint<32>(csr_dword_fc1.read()))
					cout << "ERROR in dword received from CSR (side 1)" << endl;

				//increment the number of dwords received
				received1++;
				//Remove the entry from the queue if the entry is finished
				if(received1 == to_receive.front().size_with_data){
					received1 = 0;
					to_receive.pop_front();
				}			
			}
			//If no respionse expected and some received, display ERROR
			else if(fc1_ack_csr.read())
				cout << "CSR Response (side 1) not expected!" << endl;
		}
	}

}

void csr_l2_tb::simulate_databuffer(){
	data_sent0 = 0;
	data_sent1 = 0;
	data_size0 = 0;
	data_size1 = 0;
	valid_output0 = false;
	valid_output1 = false;

	bool expect_erase_after_read0 = false;
	bool expect_erase_after_read1 = false;

	while(true){
		wait();

		//If what is outputed from databuffer is valid data : false by default
		valid_output0 = false;

		if(csr_erase_db0.read() != expect_erase_after_read0){
			cout << "ERROR: csr_erase_db0 asserted at wrong time" << endl;
		}
		//By default, don't expect the CSR to erase data packet
		expect_erase_after_read0 = false;

		//If reading data from side 0
		if(csr_read_db0.read()){
			//Check that there is data
			if(data_size0 == 0) 
				cout << "ERROR : CSR reading databuffer while no data to send 0" << endl;
			//If it was not valid output, display error
			else if(!valid_output0.read())
				cout << "ERROR : CSR reading invalid output 0" << endl;
			//If done, reset the data position
			else{
				if(++data_sent0 == data_size0){
					data_size0 = 0;
					data_sent0 = 0;
					expect_erase_after_read0 = true;
				}
			}
		}
		//If there is no data, output 0
		if(data_size0 == 0){
			db0_data_csr = 0;
		}
		//If address is correct, output data and set valid output
		if((csr_address_db0.read() == data_address0 && csr_vctype_db0.read() == data_vc0 ||
			data_sent0 > 0) && data_size0 != 0)
		{
			valid_output0 = true;
			db0_data_csr = data0[data_sent0];
		}

		//Read from side 1
		valid_output1 = false;

		if(csr_erase_db1.read() != expect_erase_after_read1){
			cout << "ERROR: csr_erase_db1 asserted at wrong time" << endl;
		}
		expect_erase_after_read1 = false;

		//If reading data from side 1
		if(csr_read_db1.read()){
			//Check that there is data
			if(data_size1 == 0) 
				cout << "ERROR : CSR reading databuffer while no data to send 1" << endl;
			//If it was not valid output, display error
			else if(!valid_output1.read())
				cout << "ERROR : CSR reading invalid output 1" << endl;
			//If done, reset the data position
			else{
				if(++data_sent1 == data_size1){
					data_size1 = 0;
					data_sent1 = 0;
					expect_erase_after_read1 = true;
				}
			}
		}

		//If there is no data, output 0
		if(data_size1 == 0){
			db1_data_csr = 0;
		}
		//If address is correct, output data and set valid output
		if((csr_address_db1.read() == data_address1 && csr_vctype_db1.read() == data_vc1 ||
			data_sent1 > 0) && data_size1 != 0)
		{
			valid_output1 = true;
			db1_data_csr = data1[data_sent1];
		}
	}

}

void csr_l2_tb::generate_csr_requests_and_responses(){

	//A smart packet container
	PacketContainer pkt;
	PacketContainerWithData pkt_wdata;
	ExpectedResponse response;

	///////////////////////////////////////////////////
	//Generate a read to a static position (RevisionID)
	///////////////////////////////////////////////////

	pkt_wdata.pkt_cplt.packet.takeControl(
		new ReadPacket(0 /*seqID*/ ,0 /*unitID*/ ,0 /*srcTag*/ ,0 /*maskCount*/,
			(sc_bv<38>)sc_uint<40>(0xFDFE000000005C).range(39,2) /*address*/ ,
			true /*doubleWordDataLength*/ ,false /*passPW*/ ,
			false /*responsePassPW*/ ,true /*memoryCoherent*/ ,
			false /*compat*/ ,false /*isoc*/ ));

	pkt_wdata.pkt_cplt.error64BitExtension = false;
	pkt_wdata.pkt_cplt.data_address = 0;
	pkt_wdata.pkt_cplt.isPartOfChain = false;
	to_send0.push_back(pkt_wdata);

	//Generate the expected response for comparison
	pkt.takeControl(
		new ReadResponsePacket(0 /*unitID*/ ,0 /*srcTag*/ ,0 /*rqUID*/ ,
			0 /*count*/ ,false /*bridge*/ ,RE_NORMAL /*error*/ ,
			false /*passPW*/ ,false /*isoc*/ ));

	response.size_with_data = 2;
	response.dwords[0] = sc_uint<32>((sc_bv<32>)pkt->getVector().range(31,0));
	response.dwords[1] = sc_uint<32>(0x88406008);
	to_receive0.push_back(response);

	///////////////////////////////////////////////////
	//Generate a write to the BARS - Posted
	///////////////////////////////////////////////////

	pkt_wdata.pkt_cplt.packet.takeControl(
		new WritePacket(0 /*seqID*/ ,0 /*unitID*/ ,1 /*maskCount*/,
			(sc_bv<38>)sc_uint<40>(0xFDFE0000000010).range(39,2) /*address*/ ,
			true /*doubleWordDataLength*/ ,false /*passPW*/ ,
			false /*dataError*/ ,false /*chain*/ ,true /*memoryCoherent*/ ,
			false /*compat*/ ,false /*isoc*/ ));

	pkt_wdata.pkt_cplt.error64BitExtension = false;
	pkt_wdata.pkt_cplt.data_address = rand() % 16;
	pkt_wdata.pkt_cplt.isPartOfChain = false;
	pkt_wdata.data[0] = 0xFFFFFFFF;
	pkt_wdata.data[1] = 0xF0F0F0F0;
	to_send1.push_back(pkt_wdata);

	///////////////////////////////////////////////////
	//Generate a write to the BARS - Non Posted
	///////////////////////////////////////////////////
	/*WritePacket(  const sc_bv<4> &seqID,
					  const sc_bv<5> &unitID,
					  const sc_bv<5> &srcTag,
					  const sc_bv<4> &maskCount,
					  const sc_bv<38> &address,
					  int doubleWordDataLength,
					  bool passPW = false,
					  bool memoryCoherent = true,
					  bool compat = false,
					  bool isoc = false) :*/

	pkt_wdata.pkt_cplt.packet.takeControl(
		new WritePacket(5 /*seqID*/ ,5 /*unitID*/ ,3 /*srcTag*/,1 /*maskCount*/,
			(sc_bv<38>)sc_uint<40>(0xFDFE0000000018).range(39,2) /*address*/ ,
			true /*doubleWordDataLength*/ ,false /*passPW*/ ,
			true /*memoryCoherent*/ ,
			false /*compat*/ ,false /*isoc*/ ));
	pkt_wdata.pkt_cplt.data_address = rand() % 16;
	to_send1.push_back(pkt_wdata);

	//Generate the expected response for comparison
	pkt.takeControl(
		new TargetDonePacket(0 /*unitID*/,
						 3 /*srcTag*/,
						 1 /*rqUID*/,
						 false /*bridge*/,
						 RE_NORMAL /*error*/,
						 0 /*passPW*/,
						 0 /*isoc*/));


	response.size_with_data = 1;
	response.dwords[0] = sc_uint<32>((sc_bv<32>)pkt->getVector().range(31,0));
	to_receive1.push_back(response);

	
	///////////////////////////////////////////////////
	//Read the BARS - Non Posted
	///////////////////////////////////////////////////

	pkt_wdata.pkt_cplt.packet.takeControl(
		new ReadPacket(0 /*seqID*/ ,0 /*unitID*/ ,7 /*srcTag*/ ,3 /*maskCount*/,
			(sc_bv<38>)sc_uint<40>(0xFDFE0000000010).range(39,2) /*address*/ ,
			true /*doubleWordDataLength*/ ,false /*passPW*/ ,
			false /*responsePassPW*/ ,true /*memoryCoherent*/ ,
			false /*compat*/ ,false /*isoc*/ ));

	pkt_wdata.pkt_cplt.error64BitExtension = false;
	pkt_wdata.pkt_cplt.data_address = 0;
	pkt_wdata.pkt_cplt.isPartOfChain = false;
	to_send.push_back(pkt_wdata);

	//Generate the expected response for comparison
	pkt.takeControl(
		new ReadResponsePacket(0 /*unitID*/ ,7 /*srcTag*/ ,0 /*rqUID*/ ,
			3 /*count*/ ,false /*bridge*/ ,RE_NORMAL /*error*/ ,
			false /*passPW*/ ,false /*isoc*/ ));

	response.size_with_data = 5;
	response.dwords[0] = sc_uint<32>((sc_bv<32>)pkt->getVector().range(31,0));
	response.dwords[1] = sc_uint<32>(0xFFFFFC00);
	response.dwords[2] = sc_uint<32>(0xF0F0F000);
	response.dwords[3] = sc_uint<32>(0xFFFFFC00);
	response.dwords[4] = sc_uint<32>(0xF0F0F000);
	to_receive.push_back(response);

	///////////////////////////////////////////
	// Test Byte write
	///////////////////////////////////////////
	pkt_wdata.pkt_cplt.packet.takeControl(
		new WritePacket(0 /*seqID*/ ,0 /*unitID*/ ,1 /*maskCount*/,
			(sc_bv<38>)sc_uint<40>(0xFDFE0000000014).range(39,2) /*address*/ ,
			false /*doubleWordDataLength*/ ,false /*passPW*/ ,
			false /*dataError*/ ,false /*chain*/ ,true /*memoryCoherent*/ ,
			false /*compat*/ ,false /*isoc*/ ));

	pkt_wdata.pkt_cplt.error64BitExtension = false;
	pkt_wdata.pkt_cplt.data_address = rand() % 16;
	pkt_wdata.pkt_cplt.isPartOfChain = false;
	pkt_wdata.data[0] = 0x00C00000;
	pkt_wdata.data[1] = 0xCD0F0FF0;
	to_send.push_back(pkt_wdata);

	//Read where we wrote
	pkt_wdata.pkt_cplt.packet.takeControl(
		new ReadPacket(0 /*seqID*/ ,0 /*unitID*/ ,7 /*srcTag*/ ,0 /*maskCount*/,
			(sc_bv<38>)sc_uint<40>(0xFDFE0000000014).range(39,2) /*address*/ ,
			true /*doubleWordDataLength*/ ,false /*passPW*/ ,
			false /*responsePassPW*/ ,true /*memoryCoherent*/ ,
			false /*compat*/ ,false /*isoc*/ ));

	pkt_wdata.pkt_cplt.error64BitExtension = false;
	pkt_wdata.pkt_cplt.data_address = 0;
	pkt_wdata.pkt_cplt.isPartOfChain = false;
	to_send.push_back(pkt_wdata);

	//Generate the expected response for comparison
	pkt.takeControl(
		new ReadResponsePacket(0 /*unitID*/ ,7 /*srcTag*/ ,0 /*rqUID*/ ,
			0 /*count*/ ,false /*bridge*/ ,RE_NORMAL /*error*/ ,
			false /*passPW*/ ,false /*isoc*/ ));

	response.size_with_data = 5;
	response.dwords[0] = sc_uint<32>((sc_bv<32>)pkt->getVector().range(31,0));
	response.dwords[1] = sc_uint<32>(0xCD0FF000);
	to_receive.push_back(response);
}

void csr_l2_tb::flow_control_read_signals(){
	while(true){
		//Randomly read when there is data available
		bool read = (rand() % 10 < 9);
		fc0_ack_csr = read && csr_available_fc0.read();
		fc1_ack_csr = read && csr_available_fc1.read();
		wait();
	}

}

void csr_l2_tb::grant_access_databuffer(){
	bool delay = false;
	while(true){
		//Randomly grant access, with a minimum delay of one cycle
		bool grant = (rand() % 10 < 2) && delay;
		//Delay the request until next cycke
		delay = csr_request_databuffer0_access_ui.read() || csr_request_databuffer1_access_ui.read();
		//Once access granted, keep it granted until request is done
		if(csr_request_databuffer0_access_ui.read() || csr_request_databuffer1_access_ui.read())
			ui_databuffer_access_granted_csr = ui_databuffer_access_granted_csr.read() || grant;
		else
			ui_databuffer_access_granted_csr = false;
		wait();
	}
}


