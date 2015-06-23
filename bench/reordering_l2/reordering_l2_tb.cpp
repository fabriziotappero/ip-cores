//reordering_l2_tb.cpp
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

#include "reordering_l2_tb.h"

using namespace std;

reordering_l2_tb::reordering_l2_tb(sc_module_name name){
	SC_THREAD(simulate);
	sensitive_pos(clk);

	SC_METHOD(consume_data);
	sensitive << ro_available_csr << ro_available_ui << ro_available_fwd;
	sensitive << read_csr << read_fwd << read_ui;

	SC_METHOD(manage_memories);
	sensitive_pos << clk;

	srand(7941);

}

void reordering_l2_tb::simulate(){
	//Start with a reset
	resetx = false;

	//Randomly set par addresses
	sc_uint<40> tmp_40b[NbRegsBars];
	for(int n = 0; n < NbRegsBars; n++){
		//Generate a random 40-bit vector
		tmp_40b[n].range(14,0) = sc_uint<32>(rand()).range(14,0);
		tmp_40b[n].range(29,15) = sc_uint<32>(rand()).range(14,0);
		tmp_40b[n].range(39,30) = sc_uint<32>(rand()).range(9,0);
	}

	//Lower part of bar is zero, set the random part to zero
	tmp_40b[0].range(Header_BarSlotHarwireSize0_m1,0) = 0;
	if(NbRegsBars > 0) tmp_40b[1].range(Header_BarSlotHarwireSize1_m1,0) = 0;
	if(NbRegsBars > 1) tmp_40b[2].range(Header_BarSlotHarwireSize2_m1,0) = 0;
	if(NbRegsBars > 2) tmp_40b[3].range(Header_BarSlotHarwireSize3_m1,0) = 0;
	if(NbRegsBars > 3) tmp_40b[4].range(Header_BarSlotHarwireSize4_m1,0) = 0;
	if(NbRegsBars > 4) tmp_40b[5].range(Header_BarSlotHarwireSize5_m1,0) = 0;

	for(int n = 0; n < NbRegsBars; n++){
		//Set the bar address
		csr_bar[n] = tmp_40b[n];
	}
	//Choose a random unitID for this node
	csr_unit_id = (sc_uint<5>)sc_uint<32>(rand()).range(4,0);

	//////////////////////////////////////////////
	// Set some initial values
	//////////////////////////////////////////////	

	csr_ack_ro = false;
	ui_ack_ro = false;	
	fwd_ack_ro = false;
	eh_ack_ro = false;

	fc_nop_sent = true;

	cd_available_ro = false;

	cd_data_pending_ro = false;

	csr_memory_space_enable = true;
	csr_io_space_enable = true;

	csr_direct_route_enable = true;
	csr_sync = false;

	//csr_clumping_configuration = "00000000111000000000000000000000";
	/**ID's 20 to 23 are clumped together*/
	for(int n = 0; n < 32; n++)
		clumped_unit_id[n] = n;
	clumped_unit_id[21] = 20;
	clumped_unit_id[22] = 20;
	clumped_unit_id[23] = 20;

    //The unitID's that have directRoute enabled
	csr_direct_route_enable =    "00000000000000000000000000000000";

#ifdef ENABLE_REORDERING
	csr_unitid_reorder_disable = false;
#endif
	fwd_next_node_buffer_status_ro = "111111";
	

#ifdef RETRY_MODE_ENABLED
	lk_rx_connected = true;
	csr_retry = false;
#endif

	//Hold reset for a some cycles
	for(int n = 0; n < 3; n++)
		wait();

	//Stop reset
	resetx = true;

	//A temporary packet variable to reuse
	ReorderTBPacket tb_pkt;

	/////////////////////////////////////////
	// Send Misc packets, no reordering
	// Test one VC at the time
	// This tests the proper operation of the entrance reordering
	// dans the buffers when not being reordered
	/////////////////////////////////////////
	fc_nop_sent = true;
	cd_data_pending_ro = false;
	cout << "Begin test: Send Misc packets, no reordering" << endl;

	for(int vc = 0; vc < 3; vc++){
		cout << "Begin test for vc: " << vc << endl;

		int packet_to_send = 25;
		int packets_received = 0;

		int idle_counter = 0;

		while(packets_received != 25){

			////////////////////////////////////////////
			// Read reordering output
			////////////////////////////////////////////

			//Make sure we don't fall in an infinite loop
			if(!ro_available_csr.read() &&
				!ro_available_ui.read() &&
				!ro_available_fwd.read() && 
				!packet_sent.empty())
			{
				idle_counter++;
				if(idle_counter > 10){
					cout << "ERROR: No packets are being received!" << endl;
					return;
				}
			}
			else{
				idle_counter = 0;
			}

			//80% chance of reading from the many destination
			read_csr = (rand() % 10) < 8;
			read_fwd = (rand() % 10) < 8;
			read_ui = (rand() % 10) < 8;

			//Find the first packet in the list of packets 
			//Start by creating an iterator
			deque<ReorderTBPacket>::iterator first_accepted = packet_sent.begin();
			bool found_accepted = false;
			//loop over all elements until an accepted is found
			while(first_accepted != packet_sent.end()){
				if(first_accepted->accepted){
					found_accepted = true;
					break;
				}
				first_accepted++;
			}

			//Accepted packet can only be sent to one destination, CSR or UI
			if(ui_ack_ro.read() && csr_ack_ro.read()){
				cout << "ERROR: Packets sent to UI and CSR simulaneoulsy" << endl;
				return;					
			}
					
			//If CSR acks a packet
			if(csr_ack_ro.read()){
				//Check if there is a packet to send
				if(packet_sent.size() == 0 || !found_accepted){
					cout << "ERROR: Packet available when none in buffers..." << endl;
					return;					
				}
				//If not the correct packet, display an error 
				if(ro_packet_csr.read().packet != first_accepted->pkt.packet 
					|| ! first_accepted->csr)
				{
					cout << "ERROR: Packet sent to CSR by error" << endl;
					return;					
				}
				//If correct, remove from queue
				else{
					packet_sent.erase(first_accepted);
					packets_received++;
				}

			}
			//If UI acks 
			if(ui_ack_ro.read()){
				//Check if there was a packet to sent
				if(packet_sent.size() == 0 || !found_accepted){
					cout << "ERROR: Packet available when none in buffers..." << endl;
					return;					
				}
				//If not the correct packet, display an error 
				if(ro_packet_ui.read().packet != first_accepted->pkt.packet 
					|| first_accepted->csr)
				{
					cout << "ERROR: Packet sent to UI by error, " << 
						ro_packet_ui.read().packet.to_string(SC_HEX) << endl;
					cout << "   expected: " << 
						first_accepted->pkt.packet.to_string(SC_HEX) << endl;
					resetx = false;
					return;					
				}
				else{
					//If the packet must also go to forward (like for a broadcast), just
					//erase the fact that it must go to accepted
					if(first_accepted->forward) first_accepted->accepted = false;
					//Otherwise, erase the packet
					else{
						packet_sent.erase(first_accepted);
						packets_received++;
					}

				}
			}

			//Find the first packet for the forward destination in the list of packet sent
			deque<ReorderTBPacket>::iterator first_forward = packet_sent.begin();;
			bool found_forward = false;
			while(first_forward != packet_sent.end()){
				if(first_forward->forward){
					found_forward = true;
					break;
				}
				first_forward++;
			}
					

			//If packet is acked
			if(fwd_ack_ro.read()){
				//Check that there is a packet to ack
				if(packet_sent.size() == 0 || !found_forward){
					cout << "ERROR: Packet available when none in buffers..." << endl;
					return;					
				}
				//If it is not the correct packet, display error
				if(ro_packet_fwd.read().packet != first_forward->pkt.packet)
				{
					cout << "ERROR: Packet sent to FWD by error, " << 
						ro_packet_fwd.read().packet.to_string(SC_HEX) << 
						" expected: " << first_forward->pkt.packet.to_string(SC_HEX) << endl;
					return;					
				}
				else{
					//If the packet must also go to accepted (like for a broadcast), just
					//erase the fact that it must go to forward
					if(first_forward->accepted) first_forward->forward = false;
					//Otherwise, erase the packet
					else{
						packet_sent.erase(first_forward);
						packets_received++;
					}
				}

			}

			////////////////////////////////////////////
			// Send packets
			////////////////////////////////////////////

			//80% chance of sending packet
			bool send = (rand() % 10) < 8;

			//If there is room in buffers, we still have packet to send (from the initial
			//number that was set and we want to send
			if(packet_sent.size() < NB_OF_BUFFERS && packet_to_send > 0 && send){
				if(vc == VC_POSTED){
					generate_random_posted_pkt(tb_pkt,POSTED_ANY);
					//Make sure  passpw = false
					tb_pkt.pkt.packet[15] = false;
				}
				else if(vc == VC_NON_POSTED){
					generate_random_nposted_pkt(tb_pkt,NPOSTED_ANY);
					//Make sure  passpw = false
					tb_pkt.pkt.packet[15] = false;
				}
				else{
					generate_random_response_pkt(tb_pkt,RESPONSE_ANY);
					//Make sure  passpw = false
					tb_pkt.pkt.packet[15] = false;
				}

				cd_available_ro = true;
				cd_packet_ro = tb_pkt.pkt;
				packet_to_send--;
				packet_sent.push_back(tb_pkt);
			}
			else{
				cd_available_ro = false;
			}
			wait();
		}
		cout << "Test done for vc: " << vc << endl;
	}
	
	cout << "Test successful" << endl << endl;

	/////////////////////////////////////////
	// Send Misc packets, reordering
	/////////////////////////////////////////

	/**
		The previous tests sent completely random packets and checked
		that they were still in order and correct.  For the reordering,
		it is not so easy, so this sends a series of pre-defined
		vectors and makes sure they are received in the also pre-defined
		correct order.

		Only send packets for the forward destination to simplify tests.
	*/

	wait();
		
	cout << "Begin packet reordering test"<< endl;

	read_csr = false;
	read_fwd = false;
	read_ui = false;

	//There are 4 tests to make
	deque<ReorderTBPacket> to_send[4];
	deque<ReorderTBPacket> to_receive[4];

	//Test 1 & 2 - passPW and sequence for posted and non-posted
	//Create a bunch of packets alternating passPW = true and false
	tb_pkt.pkt.isPartOfChain = false;
	tb_pkt.pkt.data_address = sc_uint<32>(rand()).range(BUFFERS_ADDRESS_WIDTH-1,0);
	tb_pkt.accepted = false;
	tb_pkt.forward = true;
	tb_pkt.pkt.error64BitExtension = false;

	for(int n = 0; n < 8; n++){
		generate_random_forward_posted_pkt(tb_pkt.pkt.packet,false);
		tb_pkt.pkt.packet[15] = n % 2 || n == 0;
		to_send[0].push_back(tb_pkt);
		generate_random_forward_nposted_pkt(tb_pkt.pkt.packet);
		tb_pkt.pkt.packet[15] = n % 2 || n == 0;
		to_send[1].push_back(tb_pkt);
	}

	//Insert a sequence in the packets, also testing unitID clumping
	for(int n = 3; n < 6; n++){
		to_send[0][n].pkt.packet.range(7,6) = "01";
		to_send[0][n].pkt.packet.range(14,10) = "10101";
		//Different unitID, but same clumped UnitID
		to_send[0][n].pkt.packet.range(9,8) = sc_uint<2>(n-3);
		to_send[1][n].pkt.packet.range(7,6) = "01";
		to_send[1][n].pkt.packet.range(14,10) = "10101";
		//Different unitID, but same clumped UnitID
		to_send[1][n].pkt.packet.range(9,8) = sc_uint<2>(n-3);
	}

	//Generate the order which the packet should be received
	to_receive[0].push_back(to_send[0][0]);
	to_receive[1].push_back(to_send[1][0]);
	to_receive[0].push_back(to_send[0][1]);
	to_receive[1].push_back(to_send[1][1]);
	to_receive[0].push_back(to_send[0][3]);
	to_receive[1].push_back(to_send[1][3]);
	to_receive[0].push_back(to_send[0][2]);
	to_receive[1].push_back(to_send[1][2]);
	to_receive[0].push_back(to_send[0][4]);
	to_receive[1].push_back(to_send[1][4]);
	to_receive[0].push_back(to_send[0][5]);
	to_receive[1].push_back(to_send[1][5]);
	to_receive[0].push_back(to_send[0][7]);
	to_receive[1].push_back(to_send[1][7]);
	to_receive[0].push_back(to_send[0][6]);
	to_receive[1].push_back(to_send[1][6]);

	//Test 3 - posted chains
	//Create a bunch of packets alternating passPW = true and false
	for(int n = 0; n < 8; n++){
		generate_random_forward_posted_pkt(tb_pkt.pkt.packet,n == 4 || n==5);
		tb_pkt.pkt.packet[15] = n % 2 || n == 0;
		to_send[2].push_back(tb_pkt);
	}

	//Generate the order which the packet should be received
	to_receive[2].push_back(to_send[2][0]);
	to_receive[2].push_back(to_send[2][1]);
	to_receive[2].push_back(to_send[2][3]);
	to_receive[2].push_back(to_send[2][2]);
	to_receive[2].push_back(to_send[2][4]);
	to_receive[2].push_back(to_send[2][5]);
	to_receive[2].push_back(to_send[2][6]);
	to_receive[2].push_back(to_send[2][7]);

	//Test 4 - PassPW responses
	//Create a bunch of responses with different passPW values
	for(int n = 0; n < 8; n++){
		generate_random_forward_response_pkt(tb_pkt.pkt.packet);
		tb_pkt.pkt.packet[15] = (n == 0 || n == 1 || n == 4 || n == 5 || n == 7);
		to_send[3].push_back(tb_pkt);
	}
	to_receive[3].push_back(to_send[3][0]);
	to_receive[3].push_back(to_send[3][1]);
	to_receive[3].push_back(to_send[3][4]);
	to_receive[3].push_back(to_send[3][5]);
	to_receive[3].push_back(to_send[3][7]);
	to_receive[3].push_back(to_send[3][2]);
	to_receive[3].push_back(to_send[3][3]);
	to_receive[3].push_back(to_send[3][6]);

	//Run through the 4 tests
	for(int test = 0; test < 4; test++){
		//Send packets until they are all sent
		while(!to_send[test].empty()){
			cd_available_ro = true;
			cd_packet_ro = to_send[test].front().pkt;
			to_send[test].pop_front();
			wait();
		}
		cd_available_ro = false;

		//Wait for packets to reorganize
		for(int n = 0; n < 16; n++) wait();

		int idle = 0;

		//until all packet are ceived
		while(!to_receive[test].empty()){
			//80% chance of reading the packet if available
			read_fwd = (rand() % 10) < 8;
			//If it is acked
			if(fwd_ack_ro.read()){
				idle = 0;
				//display error if not the correct packet received
				if(ro_packet_fwd.read().packet != 
					to_receive[test].front().pkt.packet)
				{
					cout << "ERROR in reordering test: " << test << endl
						 << "    Received: " << ro_packet_fwd.read().packet.to_string(SC_HEX)
						 << " Expected: " << to_receive[test].front().pkt.packet.to_string(SC_HEX)
						 << endl;
					return;
				}
				to_receive[test].pop_front();
			}
			else{
				//If read is active but no packet available, increment an idle counter to make
				//sure the reordering doesn't just sit idle until the end of the simulation
				if(read_fwd.read()){
					idle++;
				}
				if(idle > 5){
					cout << "ERROR: reordering idle for too long in test: " << test << endl;
					return;
				}
			}
			wait();
		}
		read_fwd = false;
	}
	cout << "Test successful" << endl << endl;

	/////////////////////////////////////////
	// Test data packet not commited before
	// completely received
	/////////////////////////////////////////
	cout << "Test waiting for data to be commited"<< endl;
	cd_data_pending_ro = true;
	sc_uint<BUFFERS_ADDRESS_WIDTH> pending_addr = rand() % DATABUFFER_NB_BUFFERS;
	cd_data_pending_addr_ro = pending_addr;
	generate_random_posted_pkt(tb_pkt,POSTED_FORWARD);
	generate_random_64b_vector(tb_pkt.pkt.packet);
	//Posted write, not configured in BARs
	tb_pkt.pkt.packet.range(5,3) = "101";

	sc_bv<40> addr;
	generate_random_not_bar_address(addr);
	tb_pkt.pkt.packet.range(63,25) = addr.range(39,2);

	tb_pkt.pkt.data_address = pending_addr;

	cd_available_ro = true;
	cd_packet_ro = tb_pkt.pkt;
	read_ui = false;	
	wait();
	cd_available_ro = false;

	for(int n = 0; n <5; n++){
		if(ro_available_fwd.read()){
			cout << "ERROR: Packet sent out even if data not fully commited"<< endl;
			return;
		}
		wait();
	}

	cd_data_pending_addr_ro = pending_addr + 1;

	bool received = false;
	read_ui = true;	
	for(int n = 5; !received; n--){
		if(ro_available_fwd.read()) received = true;
		if(n == 0){
			cout << "ERROR: Packet not sent out even if data fully commited"<< endl;
			return;
		}
		wait();
	}
	read_ui = false;	
	cout << "Test successful" << endl << endl;

	/////////////////////////////////////////
	// Test directroute
	/////////////////////////////////////////

	cout << "Test DirectRoute" << endl ;

	csr_direct_route_enable =    "00000000000001110000000000000000";

	generate_random_64b_vector(tb_pkt.pkt.packet);
	//Write to bar address
	int bar = rand() % NbRegsBars;
	tb_pkt.pkt.packet.range(5,3) = "101";
	tb_pkt.pkt.packet.range(63,63-Header_BarLength[bar] + 1) = 
		csr_bar[bar].read().range(39,Header_BarSlotSize[bar]);
	//Don't want compat on
	tb_pkt.pkt.packet[21] = 0;
	//make it from 
	tb_pkt.pkt.packet.range(12,8) = sc_uint<5>(17);
	//adjust if chain
	tb_pkt.pkt.packet[19] = false;
	tb_pkt.pkt.error64BitExtension = false;

	cd_available_ro = true;
	cd_packet_ro = tb_pkt.pkt;
	read_ui = false;	
	wait();
	cd_available_ro = false;

	received = false;
	read_ui = true;	
	for(int n = 5; !received; n--){
		if(ro_available_ui.read()) received = true;
		if(n == 0){
			cout << "ERROR: Packet not correctly directrouted to UI: "
				<< tb_pkt.pkt.packet.to_string(SC_HEX) << endl;
			return;
		}
		wait();
	}
	read_ui = false;	
	csr_direct_route_enable =    "00000000000000000000000000000000";

	cout << "Test successful" << endl << endl;



	/////////////////////////////////////////
	// Test overflow
	/////////////////////////////////////////

	cout << "Test overflow" << endl;

	generate_random_posted_pkt(tb_pkt,POSTED_ANY);
	cd_packet_ro = tb_pkt.pkt;
	read_ui = false;	
	read_fwd = false;	
	read_csr = false;	
	for(int n = 0; n < 9; n++){
		cd_available_ro = true;
		wait();
	}

	for(int n = 0; n <3; n++){
		if(ro_overflow_csr.read()){
			cout << "Buffer overflow activated without real overflow" << endl;
			return;
		}
	}
	cd_available_ro = true;
	wait();
	cd_available_ro = false;

	bool got_overflow = false;
	for(int n = 0; !got_overflow; n++){
		if(ro_overflow_csr.read()){
			got_overflow = true;
		}
		if(n > 3){
			cout << "Buffer overflow not activated with real overflow" << endl;
			return;
		}
	}
	cout << "Test successful" << endl << endl;

	/////////////////////////////////////////
	// Test buffer count features
	/////////////////////////////////////////

	resetx = false;
	for(int n = 0; n <3; n++) wait();
	resetx = true;

	/////////////////////////////////////////
	// Test clearing buffer status in retry mode
	/////////////////////////////////////////

	/////////////////////////////////////////
	// Test disabling reordering
	/////////////////////////////////////////

	//not done

	/////////////////////////////////////////
	// Test io and memory space enable
	/////////////////////////////////////////

	//not done

	/////////////////////////////////////////
	// Send the three types (p,np,r)
	/////////////////////////////////////////

	//not done

}

void reordering_l2_tb::consume_data(){
	csr_ack_ro = ro_available_csr.read() && read_csr.read();
	ui_ack_ro = ro_available_ui.read() && read_ui.read();	
	fwd_ack_ro = ro_available_fwd.read() && read_fwd.read();
}


void reordering_l2_tb::generate_random_posted_pkt(ReorderTBPacket &tb_pkt,
												 PostedType posted_type){
	tb_pkt.csr = false;

	switch(posted_type){
	case POSTED_ACCEPTED:
		tb_pkt.csr = generate_random_accepted_posted_pkt(tb_pkt.pkt.packet,false);
		tb_pkt.accepted = true;
		tb_pkt.forward = false;
		tb_pkt.pkt.error64BitExtension = false;
		break;
	case POSTED_FORWARD:
		generate_random_forward_posted_pkt(tb_pkt.pkt.packet,false);
		tb_pkt.accepted = false;
		tb_pkt.forward = true;
		tb_pkt.pkt.error64BitExtension = rand() % 2;
		break;
	default:
		int type = rand()%3;
		if(type == 0){
			tb_pkt.csr = generate_random_accepted_posted_pkt(tb_pkt.pkt.packet,false);
			tb_pkt.accepted = true;
			tb_pkt.forward = false;
			tb_pkt.pkt.error64BitExtension = false;
		}
		else if(type == 1){
			generate_random_forward_posted_pkt(tb_pkt.pkt.packet,false);
			tb_pkt.accepted = false;
			tb_pkt.forward = true;
			tb_pkt.pkt.error64BitExtension = rand() % 2;
		}
		else{
			generate_random_broadcast_posted_pkt(tb_pkt.pkt.packet);
			tb_pkt.accepted = true;
			tb_pkt.forward = true;
			tb_pkt.pkt.error64BitExtension = false;
		}
	}

	tb_pkt.pkt.isPartOfChain = false;
	tb_pkt.pkt.data_address = sc_uint<32>(rand()).range(BUFFERS_ADDRESS_WIDTH-1,0);
}

bool reordering_l2_tb::generate_random_accepted_posted_pkt(sc_bv<64> &pkt, 
														  bool chain){
	//Randomly generate a 64-bit packet
	generate_random_64b_vector(pkt);
	//Now, we'll choose where the packet goes and set some of the bits accordingly
	//Choose a type randomly :
	// 0 : goes to CSR
	// 1 : goes to user (normal traffic)
	// 2 : goes to user (device message)
	int type = rand() % 3;

	//If in the middle of the chain
	if(curently_sending_chain){
		//Set the new value depending on if a chain packet is selected
		curently_sending_chain = chain;
		//Set same type as before
		if(chain_destination = POSTED_DESTINATION_CSR) type = 0;
		else if(chain_destination = POSTED_DESTINATION_USER) type = 1;
		else type = 2;
	}
	else if(chain){
		if(type == 0) chain_destination = POSTED_DESTINATION_CSR;
		else if(type == 1) chain_destination = POSTED_DESTINATION_USER;
		else chain_destination = POSTED_DESTINATION_USER_DEVICE_MSG;
	}

	//Go to CSR if the type is 0
	int csr = type == 0;

	pkt.range(5,3) = "101";
	if(type == 0){
		//CSR write
		pkt.range(63,48) = 
			"1111110111111110";
		pkt.range(39,35) = csr_unit_id.read();
	}
	else if(type == 1 || chain){
		//Write to bar address
		int bar = rand() % NbRegsBars;
		pkt.range(63,63-Header_BarLength[bar] + 1) = 
			csr_bar[bar].read().range(39,Header_BarSlotSize[bar]);

	}
	else{
		//Device message
		pkt.range(63,52) = 
			"111111100000";
		pkt.range(39,35) = csr_unit_id.read();
		pkt[2] = true;//always byte
	}
	//Don't want compat on
	pkt[21] = 0;
	//make it downstream
	pkt.range(12,8) = 0;
	//adjust if chain
	pkt[19] = chain;
	return csr;
}

void reordering_l2_tb::generate_random_forward_posted_pkt(sc_bv<64> &pkt, bool chain){
	generate_random_64b_vector(pkt);
	int type = rand()%2;
	if(type || chain){
		//Posted write, not configured in BARs
		pkt.range(5,3) = "101";

		sc_bv<40> addr;
		generate_random_not_bar_address(addr);
		pkt.range(63,25) = addr.range(39,2);

	}
	else{
		//Posted fence
		pkt.range(5,0) = "111100";
	}
	pkt[19] = chain;
}

void reordering_l2_tb::generate_random_broadcast_posted_pkt(sc_bv<64> &pkt){
	generate_random_64b_vector(pkt);
	pkt.range(5,0) = "111010";
}

void reordering_l2_tb::generate_random_64b_vector(sc_bv<64> &pkt){
	sc_uint<32> r;
	for(int n = 0; n < 4;n++){
		r = rand();
		pkt(15*(n+1)-1,15*n) = sc_uint<32>(rand()).range(14,0);
	}
	r = rand();
	pkt(63,60) = sc_uint<32>(rand()).range(3,0);
}

bool reordering_l2_tb::generate_random_accepted_nposted_pkt(sc_bv<64> &pkt){
	generate_random_64b_vector(pkt);
	int type = rand() % 3;
	int csr = rand() % 2;

	if(type == 0){
		//Non posted write
		pkt.range(5,3) = "001";
	}
	else if(type == 1){
		//Read
		pkt.range(5,4) = "01";
	}
	else{
		//Atomic
		pkt.range(5,0) = "0111101";
	}
	//Don't want compat on
	pkt[21] = 0;
	//make it downstream
	pkt.range(12,8) = 0;

	//If CSR, adjust address
	if(csr){
		pkt.range(63,48) = 
			"1111110111111110";
		pkt.range(39,35) = csr_unit_id.read();
	}
	else{
		int bar = rand() % NbRegsBars;
		pkt.range(63,63-Header_BarLength[bar] + 1) = 
			csr_bar[bar].read().range(39,Header_BarSlotSize[bar]);
	}
	return csr;
}

void reordering_l2_tb::generate_random_nposted_pkt(ReorderTBPacket &tb_pkt,
												 NPostedType nposted_type){
	tb_pkt.csr = false;

	switch(nposted_type){
	case NPOSTED_ACCEPTED:
		tb_pkt.csr = generate_random_accepted_nposted_pkt(tb_pkt.pkt.packet);
		tb_pkt.accepted = true;
		tb_pkt.forward = false;
		tb_pkt.pkt.error64BitExtension = false;
		break;
	case NPOSTED_FORWARD:
		generate_random_forward_nposted_pkt(tb_pkt.pkt.packet);
		tb_pkt.accepted = false;
		tb_pkt.forward = true;
		tb_pkt.pkt.error64BitExtension = rand() % 2;
		break;
	default:
		int type = rand()%2;
		if(type == 0){
			tb_pkt.csr = generate_random_accepted_nposted_pkt(tb_pkt.pkt.packet);
			tb_pkt.accepted = true;
			tb_pkt.forward = false;
			tb_pkt.pkt.error64BitExtension = false;
		}
		else{
			generate_random_forward_nposted_pkt(tb_pkt.pkt.packet);
			tb_pkt.accepted = false;
			tb_pkt.forward = true;
			tb_pkt.pkt.error64BitExtension = rand() % 2;
		}
	}

	tb_pkt.pkt.isPartOfChain = false;
	tb_pkt.pkt.data_address = sc_uint<32>(rand()).range(BUFFERS_ADDRESS_WIDTH-1,0);
}

void reordering_l2_tb::generate_random_forward_nposted_pkt(sc_bv<64> &pkt){
	generate_random_64b_vector(pkt);
	sc_bv<40> addr;
	generate_random_not_bar_address(addr);

	int type = rand()%4;
	switch(type){
	case 0:
		//flush
		pkt.range(5,0) = "000010";
		break;
	case 1:
		//Non posted write
		pkt.range(5,3) = "001";
		pkt.range(63,26) = addr.range(39,2);
		break;
	case 2:
		//Read
		pkt.range(5,4) = "01";
		pkt.range(63,26) = addr.range(39,2);
		break;
	default:
		//Atomic
		pkt.range(5,0) = "0111101";
		pkt.range(63,27) = addr.range(39,3);
	}
}

void reordering_l2_tb::generate_random_not_bar_address(sc_bv<40> &addr){
	//Generate random adresses until we find one not in bars
	/**
		Probably not the most efficient way of doing this!!!  But it's quick
		to code and it works.  Care must be taken that the majority of the address
		space is not used by BARs!
	*/
	bool in_bar;
	do{
		//Generate random address
		addr.range(9,0) = sc_uint<32>(rand()).range(9,0);
		addr.range(34,10) = sc_uint<32>(rand()).range(14,0);
		addr.range(39,35) = sc_uint<32>(rand()).range(14,0);

		//Check if it in bar
		in_bar = false;
		for(int n = 0; n < NbRegsBars; n++){
			if(		addr.range(39,Header_BarSlotSize[n]) == 
					csr_bar[n].read().range(39,Header_BarSlotSize[n])
				) in_bar = true;
		}
	//Repeat procedure until we have an address not in the bar
	}while(in_bar);
}

void reordering_l2_tb::generate_random_accepted_response_pkt(sc_bv<64> &pkt){
	generate_random_64b_vector(pkt);
	pkt.range(63,32) = 0;
	int type = rand() % 2;
	if(type){
		//Read response
		pkt.range(5,0) = "110000";
	}
	else{
		//Target done
		pkt.range(5,0) = "110011";
	}
	//bridge bit set
	pkt[14] = true;
	//unit_id owned by the node
	pkt.range(12,8) = csr_unit_id.read();

}

void reordering_l2_tb::generate_random_response_pkt(ReorderTBPacket &tb_pkt,
												 ResponseType response_type){

	switch(response_type){
	case RESPONSE_ACCEPTED:
		generate_random_accepted_response_pkt(tb_pkt.pkt.packet);
		tb_pkt.accepted = true;
		tb_pkt.forward = false;
		tb_pkt.pkt.error64BitExtension = false;
		break;
	case NPOSTED_FORWARD:
		generate_random_forward_response_pkt(tb_pkt.pkt.packet);
		tb_pkt.accepted = false;
		tb_pkt.forward = true;
		tb_pkt.pkt.error64BitExtension = rand() % 2;
		break;
	default:
		int type = rand()%2;
		if(type == 0){
			generate_random_accepted_response_pkt(tb_pkt.pkt.packet);
			tb_pkt.accepted = true;
			tb_pkt.forward = false;
			tb_pkt.pkt.error64BitExtension = false;
		}
		else{
			generate_random_forward_response_pkt(tb_pkt.pkt.packet);
			tb_pkt.accepted = false;
			tb_pkt.forward = true;
			tb_pkt.pkt.error64BitExtension = rand() % 2;
		}
	}

	tb_pkt.csr = false;
	tb_pkt.pkt.isPartOfChain = false;
	tb_pkt.pkt.data_address = sc_uint<32>(rand()).range(BUFFERS_ADDRESS_WIDTH-1,0);

}

void reordering_l2_tb::generate_random_forward_response_pkt(sc_bv<64> &pkt){
	generate_random_accepted_response_pkt(pkt);
	pkt.range(63,32) = 0;

	int forward_cause = rand() % 3;
	if(forward_cause == 0 || forward_cause == 2){
		//bridge bit unset
		pkt[14] = false;
	}
	if(forward_cause == 1 || forward_cause == 2){
	//unit_id owned by the node
	pkt.range(12,8) = ~csr_unit_id.read();
	}
}

void reordering_l2_tb::manage_memories(){
		////////////////////////////////////
		// CoommandBuffer Memories
		////////////////////////////////////
		for(int n = 0; n < 2; n++){
			command_packet_rd_data_ro[n] = 
				command_memory[ro_command_packet_rd_addr[n].read().to_int()];
		}

		if(ro_command_packet_write.read()) 
			command_memory[ro_command_packet_wr_addr.read().to_int()] = 
				ro_command_packet_wr_data.read();
}
