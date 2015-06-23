//user_fifo_l3_tb.cpp
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

#include "user_fifo_l3_tb.h"
#include "../../../rtl/systemc/flow_control_l2/user_fifo_l3.h"
#include "../../core/PacketContainer.h"
#include <cstdlib>

user_fifo_l3_tb::user_fifo_l3_tb(sc_module_name name) : sc_module(name){
	//Create thread
	SC_THREAD(maintain_internal_state);
	sensitive_pos(clk);

	//Initialise internal variables
	tag_count = 0;
	last_cycle_posted_blocking_nposted = false;
	last_cycle_posted_blocking_response = false;
}


void user_fifo_l3_tb::generate_packets(){
	//Check if packets are allowed to be sent in the design
	bool posted_allowed = posted_fifo.size() < USER_FIFO_DEPTH;
	bool nposted_allowed = nposted_fifo.size() < USER_FIFO_DEPTH;
	bool response_allowed = response_fifo.size() < USER_FIFO_DEPTH;

	//Build a list of what vc's are allowed.  This list will be read
	//with a random number to choose a VC.
	int pos = 0;//>Number of vcs allowed
	VirtualChannel vcs_allowed[3];
	if(posted_allowed) 
		vcs_allowed[pos++] = VC_POSTED;
	if(nposted_allowed) 
		vcs_allowed[pos++] = VC_NON_POSTED;
	if(response_allowed) 
		vcs_allowed[pos++] = VC_RESPONSE;

	// 4/10 chance of sending a packet
	bool send = rand() % 10 < 4;


	//If pos is 0, no vcs are available.  So if pos!=0 and we decided to send and we're not in reset
	if(pos && send && resetx.read()){
		//Choose a vc to send to
		VirtualChannel vc = vcs_allowed[rand() % pos];
		//Build a random 64 bit vector
		sc_uint<32> lsb = (rand() & 0xFF) | (( rand() & 0xFF) << 8) | (( rand() & 0xFF) << 16) | (( rand() & 0xFF) << 24);
		sc_uint<32> msb = (rand() & 0xFF) | (( rand() & 0xFF) << 8) | (( rand() & 0xFF) << 16) | (( rand() & 0xFF) << 24);

		//Create a random command packet based on the different types of packets available
		sc_bv<6> command = sc_uint<32>(rand()).range(5,0);
		if(vc == VC_POSTED){
			int type = rand()%3;
			if(type == 0){
				command.range(5,3) = "101";
			}
			else if(type == 1){
				command = "111010";
			}
			else{
				command = "111100";
			}
		}
		else if(vc == VC_NON_POSTED){
			int type = rand()%4;
			if(type == 0){
				command= "000010";
			}
			else if(type == 1){
				command.range(5,3) = "001";
			}
			else if(type == 2){
				command.range(5,4) = "01";
			}
			else{
				command = "111101";
			}

		}
		else{
			msb = 0;
			int type = rand()%2;
			if(type == 0){
				command= "110000";
			}
			else {
				command= "110011";
			}
		}

		//Apply that command packet
		lsb.range(5,0) = command;
		sc_bv<64> packet;
		packet.range(31,0) = lsb;
		packet.range(63,32) = msb;

		ui_available_fc = true;
		ui_packet_fc = packet;
	}
	else{
		ui_available_fc = false;
	}
}


void user_fifo_l3_tb::maintain_internal_state(){
	//Initialize some variables and send reset
	resetx = false;
	predicted_has_output = false;
	error = false;
	hold_user_fifo = false;

	for(int n = 0; n < 5; n++){
		wait();
	}

	//Come out of reset
	resetx = true;

	//Main testing loop
	while(true){
		//Wait for the next cycle to begin
		wait();

		//////////////////////////////////
		// Check GE2
		//////////////////////////////////
		if( fc_user_fifo_ge2_ui.read()[VC_POSTED] != (posted_fifo.size() >= 2) ||
			fc_user_fifo_ge2_ui.read()[VC_NON_POSTED] != (nposted_fifo.size() >= 2) ||
			fc_user_fifo_ge2_ui.read()[VC_RESPONSE] != (response_fifo.size() >= 2))
		{
			cout << "Error with GE2 output" << endl;
			break;
		}

		//////////////////////////////////
		// Read output
		//////////////////////////////////

		if(predicted_has_output && (predicted_output != fifo_user_packet.read())){
			cout << "Expected packet: " << predicted_output.to_string(SC_HEX) << " Received: " << fifo_user_packet.read().to_string(SC_HEX) << endl;
			resetx = false;
			break;
		}
		if(predicted_has_output != fifo_user_available.read()){
			cout << "Expected available: " << predicted_has_output << " Received: " << fifo_user_available.read() << endl;
			resetx = false;
			break;
		}

		///////////////////////////////////
		// Remove consumed packet
		///////////////////////////////////

		if(consume_user_fifo.read()){
			VirtualChannel vc = ControlPacket::createPacketFromQuadWord(fifo_user_packet.read())->getVirtualChannel();
			if(vc == VC_POSTED){
				if(posted_fifo.empty())
					cout << "Error!  Trying to read from empty fifo (posted)!" << endl;
				else
					posted_fifo.pop_front();
			}
			else if(vc == VC_NON_POSTED){
				if(nposted_fifo.empty())
					cout << "Error!  Trying to read from empty fifo (nposted)!" << endl;
				else
					nposted_fifo.pop_front();
			}
			else if(vc == VC_RESPONSE){
				if(response_fifo.empty())
					cout << "Error!  Trying to read from empty fifo (response)!" << endl;
				else
					response_fifo.pop_front();
			}
			else{
				cout << "Internal error: invalid VC received!" << endl;
				break;
			}
		}


		//////////////////////////////////////
		// Generate random next buffer status
		//////////////////////////////////////
		fwd_next_node_buffer_status_ro = sc_uint<6>(rand() & 0x3F);


		//////////////////////////////////
		// Predict next output
		//////////////////////////////////
		predicted_has_output = false;


		//This is similar to what the user fifo does, choose packets by priority if they can
		//be sent
		if(!response_fifo.empty() && (sc_bit)fwd_next_node_buffer_status_ro.read()[USR_FIFO_VC_R_POS] &&
			((sc_bit)response_fifo.front().packet[0] || (sc_bit)fwd_next_node_buffer_status_ro.read()[USR_FIFO_VC_R_DATA_POS]) &&
			( (sc_bit)(response_fifo.front().packet[15]) || posted_fifo.empty() || !last_cycle_posted_blocking_response))
		{
			predicted_has_output = true;
			predicted_output = response_fifo.front().packet;

		}
		else if(!posted_fifo.empty() && (sc_bit)fwd_next_node_buffer_status_ro.read()[USR_FIFO_VC_P_POS] &&
			((sc_bit)posted_fifo.front().packet[4] || (sc_bit)fwd_next_node_buffer_status_ro.read()[USR_FIFO_VC_P_DATA_POS])
			)
		{
			predicted_has_output = true;
			predicted_output = posted_fifo.front().packet;

		}
		else if(!nposted_fifo.empty() && (sc_bit)fwd_next_node_buffer_status_ro.read()[USR_FIFO_VC_NP_POS] &&
			(nposted_fifo.front().packet.range(5,3) == "000" || nposted_fifo.front().packet.range(5,4) == "01" || 
			(sc_bit)fwd_next_node_buffer_status_ro.read()[USR_FIFO_VC_NP_DATA_POS]) &&
			( (sc_bit)nposted_fifo.front().packet[15] || posted_fifo.empty() || !last_cycle_posted_blocking_nposted))
		{
			predicted_has_output = true;
			predicted_output = nposted_fifo.front().packet;
		}

		//A nposted or response packet cannot pass a posted packet, so we check the tag number
		//of what is in the buffers to know if the posted packets are blocking nposted and
		//response packets
		int first_posted_tag_number = 0;
		int first_nposted_tag_number = 0;
		int first_response_tag_number = 0;

		if(!posted_fifo.empty()) first_posted_tag_number = posted_fifo.front().tag_number;
		if(!nposted_fifo.empty()) first_nposted_tag_number = nposted_fifo.front().tag_number;
		if(!response_fifo.empty()) first_response_tag_number = response_fifo.front().tag_number;

		last_cycle_posted_blocking_response = first_response_tag_number > first_posted_tag_number;
		last_cycle_posted_blocking_nposted = first_nposted_tag_number > first_posted_tag_number;

		//////////////////////////////////////////////////////
		//	Consume packets
		//////////////////////////////////////////////////////
		bool read = rand() % 10 < 4;
		if(predicted_has_output && read){
			consume_user_fifo =	true;
		}
		else{
			consume_user_fifo =	false;
		}


		//////////////////////////////////
		// Add new packets
		//////////////////////////////////
		if(ui_available_fc.read()){
			UserFifoEntry entry;
			entry.tag_number = tag_count++;
			entry.packet = ui_packet_fc.read();

			VirtualChannel vc = ControlPacket::createPacketFromQuadWord(ui_packet_fc.read())->getVirtualChannel();
			if(vc == VC_POSTED){
				//cout << "************* POSTED PACKET : " << ui_packet_fc.read() << endl;
				posted_fifo.push_back(entry);
			}
			else if(vc == VC_NON_POSTED){
				nposted_fifo.push_back(entry);
			}
			else if(vc == VC_RESPONSE){
				response_fifo.push_back(entry);
			}
			else{
				cout << "Internal error: invalid VC from FIFO output!" << endl;
				break;
			}
		}
		
		////////////////////////////////////////
		// Generate Packets to send to FIFO
		///////////////////////////////////////
		generate_packets();
	}
	error = true;
}
