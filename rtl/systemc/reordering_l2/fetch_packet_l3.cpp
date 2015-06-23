//fetch_packet_l3.cpp
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

#include "fetch_packet_l3.h"

fetch_packet_l3::fetch_packet_l3(sc_module_name name) : sc_module(name){
	SC_METHOD(register_signals);
	sensitive_pos(clk);
	sensitive_neg(resetx);

	SC_METHOD(select_and_ack_packet);
	for(int destination = 0; destination < 2; destination++){
		sensitive << posted_available[destination] 
				  << nposted_available[destination]
				  << response_available[destination]
				  << posted_requested[destination]
				  << nposted_requested[destination]
				  << response_requested[destination]
				  << posted_packet_addr[destination]
				  << nposted_packet_addr[destination]
				  << response_packet_addr[destination];
	}

	SC_METHOD(reconstruct_packet);
	sensitive << command_packet_rd_data_ro[0] << command_packet_rd_data_ro[1]
#ifdef ENABLE_REORDERING
			  << packet_passpw[0] << packet_passpw[1]
			  << packet_seqid[0] << packet_seqid[1]
			  << packet_chain[0] << packet_chain[1]
#endif
			  << packet_vc[0] << packet_vc[0]
			  << packet_fetched[0] << packet_fetched[1];

}

void fetch_packet_l3::select_and_ack_packet(){
	for(int destination = 0; destination < 2; destination++){
		sc_uint<LOG2_NB_OF_BUFFERS+2> ro_command_packet_rd_addr_tmp;

		//Some default values for outputs
		ack_posted[destination] = false;
		ack_nposted[destination] = false;
		ack_response[destination] = false;
		selected_vc[destination] = VC_NONE;
		packet_selected[destination] = false;
		ro_command_packet_rd_addr_tmp = 0;

		//Retrieve posted packets first, if there is a packet of that type available
		//and it is being requested
		if(posted_requested[destination].read() && posted_available[destination].read()){
			ack_posted[destination] = true;
			selected_vc[destination] = VC_POSTED;
			packet_selected[destination] = true;
			ro_command_packet_rd_addr_tmp.range(LOG2_NB_OF_BUFFERS+1,LOG2_NB_OF_BUFFERS) = VC_POSTED;
			ro_command_packet_rd_addr_tmp.range(LOG2_NB_OF_BUFFERS-1,0) = posted_packet_addr[destination];
		}
		//Then responses
		else if(response_requested[destination].read() && response_available[destination].read()){
			ack_response[destination] = true;
			selected_vc[destination] = VC_RESPONSE;
			packet_selected[destination] = true;
			ro_command_packet_rd_addr_tmp.range(LOG2_NB_OF_BUFFERS+1,LOG2_NB_OF_BUFFERS) = VC_RESPONSE;
			ro_command_packet_rd_addr_tmp.range(LOG2_NB_OF_BUFFERS-1,0) = response_packet_addr[destination];
		}
		//Finally nposted packets
		else if(nposted_requested[destination].read() && nposted_available[destination].read()){
			ack_nposted[destination] = true;
			selected_vc[destination] = VC_NON_POSTED;
			packet_selected[destination] = true;
			ro_command_packet_rd_addr_tmp.range(LOG2_NB_OF_BUFFERS+1,LOG2_NB_OF_BUFFERS) = VC_NON_POSTED;
			ro_command_packet_rd_addr_tmp.range(LOG2_NB_OF_BUFFERS-1,0) = nposted_packet_addr[destination];
		}

		//Output the result
		ro_command_packet_rd_addr[destination] = ro_command_packet_rd_addr_tmp;
	}
}

void fetch_packet_l3::register_signals(){
	if(!resetx.read()){
		for(int destination = 0; destination < 2; destination++){
#ifdef ENABLE_REORDERING
			packet_passpw[destination] = false;
			packet_seqid[destination] = 0;
			packet_chain[destination] = false;
#else
			currently_posted_chain[destination] = false;
#endif

			packet_vc[destination] = VC_NONE;
			packet_fetched[destination] = false;
		}
	}
	else{
		for(int destination = 0; destination < 2; destination++){
			//Register the decision from the other combinatorial process
			packet_vc[destination] = selected_vc[destination].read();
			packet_fetched[destination] = packet_selected[destination].read();


#ifdef ENABLE_REORDERING
			//Register information about the packet depending on the virtual channel
			//of the packet
			switch(selected_vc[destination].read()){
				case VC_NON_POSTED:
					packet_passpw[destination] = nposted_packet_passpw[destination].read();
					packet_seqid[destination] = nposted_packet_seqid[destination].read();
					packet_chain[destination] = false;
					break;
				case VC_RESPONSE:
					packet_passpw[destination] = response_packet_passpw[destination].read();
					packet_seqid[destination] = 0;
					packet_chain[destination] = false;

					break;
				default:
					packet_passpw[destination] = posted_packet_passpw[destination].read();
					packet_seqid[destination] = posted_packet_seqid[destination].read();
					packet_chain[destination] = posted_packet_chain[destination].read();
			}
#else
			if(packet_vc[destination].read() == VC_POSTED)
				currently_posted_chain[destination] = (sc_bit)command_packet_rd_data_ro[destination].read()[19];
#endif
		}
	}
	
}

void fetch_packet_l3::reconstruct_packet(){
	//The role of this function is to reconstruct packets for output by merging
	//the information coming from the buffers and the information from the
	//embedded memory.  The reconstruction is exactly the inverse of what was
	//done in the entrance reordering.  There is a better explanation about what
	//is going on in that module (entrance reordering) if it is needed to understand 
	//this code.
	for(int destination = 0; destination < 2; destination++){
		fetched_packet_available[destination] = packet_fetched[destination];
		fetched_packet_vc[destination] = packet_vc[destination];

		syn_ControlPacketComplete fetched_packet_tmp;

		//A default value, might be mofidied below depending on preprocessor directives
		fetched_packet_tmp.packet = command_packet_rd_data_ro[destination].read().range(63,0);

#ifndef ENABLE_REORDERING
		bool posted_part_of_chain = packet_vc[destination].read() == VC_POSTED &&
			((sc_bit)command_packet_rd_data_ro[destination].read()[19] || 
			 (sc_bit)currently_posted_chain[destination].read());

		fetched_packet_tmp.error64BitExtension = (sc_bit)command_packet_rd_data_ro[destination].read()[64];
		fetched_packet_tmp.data_address = (sc_bv<BUFFERS_ADDRESS_WIDTH>)command_packet_rd_data_ro[destination].read().range(LOG2_NB_OF_BUFFERS+64,65);
		fetched_packet_tmp.isPartOfChain = posted_part_of_chain;
		if(destination == FWD_DEST){
			fetched_packet_nposted_refid[destination] = (sc_bv<LOG2_NB_OF_BUFFERS+1>)command_packet_rd_data_ro[destination].read().range(LOG2_NB_OF_BUFFERS+BUFFERS_ADDRESS_WIDTH+65,BUFFERS_ADDRESS_WIDTH+65);
			fetched_packet_response_refid[destination] = (sc_bv<LOG2_NB_OF_BUFFERS+1>)command_packet_rd_data_ro[destination].read().range(2 * LOG2_NB_OF_BUFFERS+BUFFERS_ADDRESS_WIDTH+66,LOG2_NB_OF_BUFFERS+BUFFERS_ADDRESS_WIDTH+66);
		}
		else{
			fetched_packet_nposted_refid[destination] = (sc_bv<LOG2_NB_OF_BUFFERS+1>)command_packet_rd_data_ro[destination].read().range(3*LOG2_NB_OF_BUFFERS+BUFFERS_ADDRESS_WIDTH+67,2*LOG2_NB_OF_BUFFERS+BUFFERS_ADDRESS_WIDTH+67);
			fetched_packet_response_refid[destination] = (sc_bv<LOG2_NB_OF_BUFFERS+1>)command_packet_rd_data_ro[destination].read().range(4 * LOG2_NB_OF_BUFFERS+BUFFERS_ADDRESS_WIDTH+68,3*LOG2_NB_OF_BUFFERS+BUFFERS_ADDRESS_WIDTH+68);
		}
#else
		//Recover error64bit at passPW position
		fetched_packet_tmp.error64BitExtension = (sc_bit)command_packet_rd_data_ro[destination].read()[15];
		fetched_packet_tmp.packet[15] = packet_passpw[destination].read();

		//Recover the refid
		if(packet_vc[destination].read() == VC_POSTED){
			fetched_packet_nposted_refid[destination] =  posted_packet_nposted_refid[destination];
 			fetched_packet_response_refid[destination] =  posted_packet_response_refid[destination];
		}
		else{
			//If the packet is NPOSTED, only the nposted_refid will be read
			//If the packet is RESPONSE, only the response_refid will be read
			//This is why we output the same thing for both values (simplifies logic)
#if BUFFERS_ADDRESS_WIDTH < 5
			fetched_packet_nposted_refid[destination] =  (sc_bv<LOG2_NB_OF_BUFFERS+1>)command_packet_rd_data_ro[destination].read().range(LOG2_NB_OF_BUFFERS+64,64);
 			fetched_packet_response_refid[destination] =  (sc_bv<LOG2_NB_OF_BUFFERS+1>)command_packet_rd_data_ro[destination].read().range(LOG2_NB_OF_BUFFERS+64,64);
  #else
			fetched_packet_nposted_refid[destination] = (sc_bv<LOG2_NB_OF_BUFFERS+1>)command_packet_rd_data_ro[destination].read().range(60+LOG2_NB_OF_BUFFERS + BUFFERS_ADDRESS_WIDTH,60+BUFFERS_ADDRESS_WIDTH);
			fetched_packet_response_refid[destination] = (sc_bv<LOG2_NB_OF_BUFFERS+1>)command_packet_rd_data_ro[destination].read().range(60+LOG2_NB_OF_BUFFERS + BUFFERS_ADDRESS_WIDTH,60+BUFFERS_ADDRESS_WIDTH);
  #endif
		}

		//For other field, place differently depending on if it is a response or not
		if(packet_vc[destination].read() == VC_RESPONSE){
 			fetched_packet_tmp.packet.range(5,2) = "1100";
  #if BUFFERS_ADDRESS_WIDTH < 5
			fetched_packet_tmp.data_address = (sc_bv<BUFFERS_ADDRESS_WIDTH>)command_packet_rd_data_ro[destination].read().range(1 + BUFFERS_ADDRESS_WIDTH,2);
  #else
			fetched_packet_tmp.data_address.range(3,0) = command_packet_rd_data_ro[destination].read().range(5,2);
			fetched_packet_tmp.data_address.range(BUFFERS_ADDRESS_WIDTH-1,4) 
				= command_packet_rd_data_ro[destination].read().range(27 + BUFFERS_ADDRESS_WIDTH,32);
  #endif
		}
		else{
	//		-seqID is sent to registers : bits 7..6 and 14..13
  #if BUFFERS_ADDRESS_WIDTH < 3
			fetched_packet_tmp.data_address = (sc_bv<BUFFERS_ADDRESS_WIDTH>)command_packet_rd_data_ro[destination].read().range(BUFFERS_ADDRESS_WIDTH+5,6);
			fetched_packet_tmp.packet.range(7,6) = packet_seqid[destination].read().range(3,2);
  #elif BUFFERS_ADDRESS_WIDTH < 5
			fetched_packet_tmp.data_address.range(1,0) = (sc_bv<2>)command_packet_rd_data_ro[destination].read().range(7,6);
			fetched_packet_tmp.packet.range(7,6) = packet_seqid[destination].read().range(3,2);
			fetched_packet_tmp.data_address.range(BUFFERS_ADDRESS_WIDTH-1,2) = (sc_bv<BUFFERS_ADDRESS_WIDTH-2>)command_packet_rd_data_ro[destination].read().range(BUFFERS_ADDRESS_WIDTH+10,13);
			fetched_packet_tmp.packet.range(14,13) = packet_seqid[destination].read().range(1,0);
  #else
			fetched_packet_tmp.data_address.range(1,0) = (sc_bv<2>)command_packet_rd_data_ro[destination].read().range(7,6);
			fetched_packet_tmp.packet.range(7,6) = packet_seqid[destination].read().range(3,2);
			fetched_packet_tmp.data_address.range(3,2) = command_packet_rd_data_ro[destination].read().range(14,13);
			fetched_packet_tmp.packet.range(14,13) = packet_seqid[destination].read().range(1,0);
			fetched_packet_tmp.data_address.range(BUFFERS_ADDRESS_WIDTH-1,4) = command_packet_rd_data_ro[destination].read().range(59+BUFFERS_ADDRESS_WIDTH,64);
  #endif
		}
#endif

		fetched_packet[destination] = fetched_packet_tmp;
	}
}

