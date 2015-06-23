//user_fifo_l3.cpp

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

#include "user_fifo_l3.h"

user_fifo_l3::user_fifo_l3(sc_module_name name) : sc_module(name){
	SC_METHOD(registered_process);
	sensitive_pos << clock;
	sensitive_neg << resetx;

	SC_METHOD(output_available_buffers);
	sensitive << buffer_count_posted << buffer_count_nposted << buffer_count_response;

}


void user_fifo_l3::registered_process(){
	if(!resetx.read()){
		for(int n = 0; n < USER_FIFO_DEPTH; n++){
			packet_buffer_posted[n] = 0;
			packet_buffer_nposted[n] = 0;
			packet_buffer_response[n] = 0;

			othervc_send_count_nposted[n] = 0;
			othervc_send_count_posted[n] = 0;

			posted_pointer_when_response_received[n];
			posted_pointer_when_nposted_received[n];
			response_after_posted[n];
			nposted_after_posted[n];
		}
		write_pointer_posted = 0;
		write_pointer_nposted = 0;
		write_pointer_response = 0;
		
		read_pointer_posted = 0;
		read_pointer_nposted = 0;
		read_pointer_response = 0;

		buffer_count_posted = 0;
		buffer_count_nposted = 0;
		buffer_count_response = 0;

		fifo_user_packet = 0;
		fifo_user_available = false;
		fifo_user_packet_vc = VC_NONE;
		fifo_user_packet_dword = false;
		fifo_user_packet_data_asociated = false;
#ifdef RETRY_MODE_ENABLED
		fifo_user_packet_command = NOP;
#endif
		fifo_user_packet_data_count_m1 = 0;
		fifo_user_packet_isChain = false;
	}
	else{

		//***************************************************
		// Some generic calcuations
		//***************************************************
		sc_uint<USER_FIFO_ADDRESS_WIDTH> read_pointer_posted_p1;
		if(read_pointer_posted.read() == USER_FIFO_DEPTH - 1)
			read_pointer_posted_p1 = 0;
		else
			read_pointer_posted_p1 = (read_pointer_posted.read() + 1);

		sc_uint<USER_FIFO_ADDRESS_WIDTH> read_pointer_nposted_p1;
		if(read_pointer_nposted.read() == USER_FIFO_DEPTH - 1)
			read_pointer_nposted_p1 = 0;
		else
			read_pointer_nposted_p1 = (read_pointer_nposted.read() + 1);

		sc_uint<USER_FIFO_ADDRESS_WIDTH> read_pointer_response_p1;
		if(read_pointer_response.read() == USER_FIFO_DEPTH - 1)
			read_pointer_response_p1 = 0;
		else
			read_pointer_response_p1 = (read_pointer_response.read() + 1);


		/**
			The next two sections deserve some explanation.  The signal that
			consumes the output of this module comes VERY late, so we cannot
			use it to calculate the next output...at least not at the beginning.
			So we calculate for the possibility of it being 1 and 0.  A MUX
			at then selects the correct output at the very end.
		*/

		//**********************************************************
		// Select a packet to output if the output is not consummed
		//**********************************************************

		sc_bv<64> tmp_fifo_user_packet_nc;
		bool tmp_fifo_user_available_nc;
		VirtualChannel next_vc_output_nc;

		bool posted_loaded = buffer_count_posted.read() != 0;
		sc_bv<64> posted_packet = packet_buffer_posted[read_pointer_posted.read()];
		bool posted_max_count_reached = othervc_send_count_posted[read_pointer_posted.read()].read() == 
			USER_FIFO_SHIFT_PRIORITY_MAX_COUNT;

		bool nposted_loaded = buffer_count_nposted.read() != 0;
		sc_bv<64> nposted_packet = packet_buffer_nposted[read_pointer_nposted.read()];
		bool nposted_behind_posted = nposted_after_posted[read_pointer_nposted.read()].read();
		bool nposted_max_count_reached = othervc_send_count_nposted[read_pointer_nposted.read()].read() == 
			USER_FIFO_SHIFT_PRIORITY_MAX_COUNT;

		bool response_loaded = buffer_count_response.read() != 0;
		sc_bv<32> response_packet = packet_buffer_response[read_pointer_response.read()];
		bool response_behind_posted = response_after_posted[read_pointer_response.read()].read();

		tmp_fifo_user_available_nc = 
		getNextPacketToOutput(posted_loaded, posted_packet,posted_max_count_reached,
						   nposted_loaded, nposted_packet,nposted_behind_posted,nposted_max_count_reached,
						   response_loaded, response_packet,response_behind_posted,
						   tmp_fifo_user_packet_nc,next_vc_output_nc);

		sc_bv<6> user_cmd_bits_nc;
		user_cmd_bits_nc = tmp_fifo_user_packet_nc.range(5,0);
		PacketCommand user_cmd_nc = getPacketCommand(user_cmd_bits_nc);
		//sc_uint<5> packet_size_with_data_m1_nc = getPacketSizeWithDatam1(tmp_fifo_user_packet_nc,user_cmd_nc);

		//**********************************************************
		// Select a packet to output if the output is consummed
		//**********************************************************

		sc_bv<64> tmp_fifo_user_packet_c;
		bool tmp_fifo_user_available_c;
		VirtualChannel next_vc_output_c;

		bool posted_loaded_c;
		sc_bv<64> posted_packet_c;
		bool posted_max_count_reached_c;

		if(fifo_user_packet_vc.read() == VC_POSTED){
			posted_loaded_c
				= buffer_count_posted.read() != 0 && buffer_count_posted.read() != 1;
			posted_packet_c = packet_buffer_posted[read_pointer_posted_p1];
			posted_max_count_reached_c = othervc_send_count_posted[read_pointer_posted_p1].read() == 
				USER_FIFO_SHIFT_PRIORITY_MAX_COUNT;
		}
		else{
			posted_loaded_c = buffer_count_posted.read() != 0;
			posted_packet_c = packet_buffer_posted[read_pointer_posted.read()];
			posted_max_count_reached_c = othervc_send_count_posted[read_pointer_posted.read()].read() == 
				USER_FIFO_SHIFT_PRIORITY_MAX_COUNT;
		}

		bool nposted_loaded_c;
		sc_bv<64> nposted_packet_c;
		bool nposted_after_posted_c;
		bool nposted_max_count_reached_c;

		if(fifo_user_packet_vc.read() == VC_NON_POSTED){
			nposted_loaded_c
				= buffer_count_nposted.read() != 0 && buffer_count_nposted.read() != 1;
			nposted_packet_c = packet_buffer_nposted[read_pointer_nposted_p1];
			nposted_after_posted_c = nposted_after_posted[read_pointer_nposted_p1].read();
			nposted_max_count_reached_c = othervc_send_count_posted[read_pointer_nposted_p1].read() == 
				USER_FIFO_SHIFT_PRIORITY_MAX_COUNT;
		}
		else{
			nposted_loaded_c = buffer_count_nposted.read() != 0;
			nposted_packet_c = packet_buffer_nposted[read_pointer_nposted.read()];
			nposted_after_posted_c = nposted_after_posted[read_pointer_nposted.read()].read();
			nposted_max_count_reached_c = othervc_send_count_posted[read_pointer_nposted.read()].read() == 
				USER_FIFO_SHIFT_PRIORITY_MAX_COUNT;
		}

		bool response_loaded_c;
		sc_bv<32> response_packet_c;
		bool response_after_posted_c;

		if(fifo_user_packet_vc.read() == VC_RESPONSE){
			response_loaded_c
				= buffer_count_response.read() != 0 && buffer_count_response.read() != 1;
			response_packet_c = packet_buffer_response[read_pointer_response_p1];
			response_after_posted_c = response_after_posted[read_pointer_nposted_p1].read();
		}
		else{
			response_loaded_c = buffer_count_response.read() != 0;
			response_packet_c = packet_buffer_response[read_pointer_response.read()];
			response_after_posted_c = response_after_posted[read_pointer_response.read()].read();
		}

		tmp_fifo_user_available_c = 
		getNextPacketToOutput(posted_loaded_c, posted_packet_c,posted_max_count_reached_c,
						   nposted_loaded_c, nposted_packet_c,nposted_after_posted_c,nposted_max_count_reached_c,
						   response_loaded_c, response_packet_c,response_after_posted_c,
						   tmp_fifo_user_packet_c,next_vc_output_c);

		sc_bv<6> user_cmd_bits_c;
		user_cmd_bits_c = tmp_fifo_user_packet_c.range(5,0);
		PacketCommand user_cmd_c = getPacketCommand(user_cmd_bits_c);
		//sc_uint<5> packet_size_with_data_m1_c = getPacketSizeWithDatam1(tmp_fifo_user_packet_c,user_cmd_c);
		
		//***************************************************
		// Output the packet 
		//***************************************************

		//Output the correct thing depending on if the output was consummed or not
		sc_uint<2> selector;
		selector[0] = consume_user_fifo.read();
		selector[1] = hold_user_fifo.read();

		switch(selector){
		case 1:
			{
			fifo_user_packet = tmp_fifo_user_packet_c;
			fifo_user_available = tmp_fifo_user_available_c;
			fifo_user_packet_vc = next_vc_output_c;

			//Decode the packet here.  After performance analysis after synthesis,
			//it is found that the fifo_user_packet is part of the critical path.
			//To solve this, part of the packet decoding is pipelined, hence done
			//here before storing the packet in registers

			fifo_user_packet_dword = isDwordPacket(tmp_fifo_user_packet_c,user_cmd_c);
			fifo_user_packet_data_asociated = hasDataAssociated(user_cmd_c);
#ifdef RETRY_MODE_ENABLED
			fifo_user_packet_command = user_cmd_c;
#endif
			fifo_user_packet_data_count_m1 = getDataLengthm1(sc_bv<64>(tmp_fifo_user_packet_c));
			fifo_user_packet_isChain = isChain(tmp_fifo_user_packet_c);
			}
			break;
		case 0:
			{
			fifo_user_packet = tmp_fifo_user_packet_nc;
			fifo_user_available = tmp_fifo_user_available_nc;
			fifo_user_packet_vc = next_vc_output_nc;

			//Decode the packet here.  After performance analysis after synthesis,
			//it is found that the fifo_user_packet is part of the critical path.
			//To solve this, part of the packet decoding is pipelined, hence done
			//here before storing the packet in registers
			fifo_user_packet_dword = isDwordPacket(tmp_fifo_user_packet_nc,user_cmd_nc);
			fifo_user_packet_data_asociated = hasDataAssociated(user_cmd_nc);
#ifdef RETRY_MODE_ENABLED
			fifo_user_packet_command = user_cmd_nc;
#endif
			fifo_user_packet_data_count_m1 = getDataLengthm1(sc_bv<64>(tmp_fifo_user_packet_nc));
			fifo_user_packet_isChain = isChain(tmp_fifo_user_packet_nc);
			}
			break;
		//Hold
		default:
			//Everything stays the same
			fifo_user_packet = fifo_user_packet;
			fifo_user_available = fifo_user_available;
			fifo_user_packet_vc = fifo_user_packet_vc;
			fifo_user_packet_dword = fifo_user_packet_dword;
			fifo_user_packet_data_asociated = fifo_user_packet_data_asociated;
#ifdef RETRY_MODE_ENABLED
			fifo_user_packet_command = fifo_user_packet_command;
#endif
			fifo_user_packet_data_count_m1 = fifo_user_packet_data_count_m1;
			fifo_user_packet_isChain = fifo_user_packet_isChain;
		}


		//*********************************************
		// Update the actual fifos
		//*********************************************
		PacketCommand in_cmd = getPacketCommand(ui_packet_fc.read().range(5,0));
		VirtualChannel in_vc = getVirtualChannel(ui_packet_fc.read(), in_cmd);
  		bool in_data = hasDataAssociated(in_cmd);


		/// UPDATE THE PASS COUNT BIT ///
		//Start by updating "othervc send count" registers.  What is calculated
		//is overriden by code below if it is for a position that is being
		//written to by a new packet arriving
		for(int n = 0; n < USER_FIFO_DEPTH; n++){
			if(!response_after_posted[n].read() && consume_user_fifo.read() && fifo_user_packet_vc.read() != VC_POSTED){
				othervc_send_count_posted[n] = othervc_send_count_posted[n].read() 
					+ sc_uint<1>(othervc_send_count_posted[n].read() == USER_FIFO_SHIFT_PRIORITY_MAX_COUNT);
			}
			if(!nposted_after_posted[n].read() && consume_user_fifo.read() && fifo_user_packet_vc.read() != VC_NON_POSTED){
				othervc_send_count_nposted[n] = othervc_send_count_nposted[n].read() 
					+ sc_uint<1>(othervc_send_count_nposted[n].read() == USER_FIFO_SHIFT_PRIORITY_MAX_COUNT);
			}
		}

		/// POSTED ///
		sc_uint<USER_FIFO_ADDRESS_WIDTH>	new_read_pointer_posted = read_pointer_posted.read();
		bool update_read_pointer_posted = consume_user_fifo.read() && fifo_user_packet_vc.read() == VC_POSTED;
		if(update_read_pointer_posted)
		{
			new_read_pointer_posted = read_pointer_posted_p1;
		}
		read_pointer_posted = new_read_pointer_posted;
		
		if(ui_available_fc.read() && in_vc == VC_POSTED){
			packet_buffer_posted[write_pointer_posted.read()] = ui_packet_fc.read();
			othervc_send_count_posted[write_pointer_posted.read()] = 0;
			if(write_pointer_posted.read() == USER_FIFO_DEPTH - 1)
				write_pointer_posted = 0;
			else
				write_pointer_posted = (write_pointer_posted.read() + 1);
		}

		if((consume_user_fifo.read() && fifo_user_packet_vc.read() == VC_POSTED) &&
			!(ui_available_fc.read() && in_vc == VC_POSTED)){
			buffer_count_posted = buffer_count_posted.read() - 1;
		}
		else if(!(consume_user_fifo.read() && fifo_user_packet_vc.read() == VC_POSTED) &&
			(ui_available_fc.read() && in_vc == VC_POSTED)){
			buffer_count_posted = buffer_count_posted.read() + 1;
		}


		/// UPDATE NON POSTED AND RESPONSE BEHIND POSTED BITS ///
		//Start by updating "behind posted" registers.  What is calculated
		//is overriden by code below if it is for a position that is being
		//written to by a new packet arriving
		for(int n = 0; n < USER_FIFO_DEPTH; n++){
			//If the read pointer is at the pos of the write pointer at the moment a posted
			//or nposted packet was received, it means that the packet is no longer behind
			//a posted packet because it has been sent!
			if(new_read_pointer_posted == posted_pointer_when_response_received[n].read() && update_read_pointer_posted)
				response_after_posted[n] = false;
			if(new_read_pointer_posted == posted_pointer_when_nposted_received[n].read() && update_read_pointer_posted)
				nposted_after_posted[n] = false;
		}

		/// NON POSTED ///
		if(consume_user_fifo.read() && fifo_user_packet_vc.read() == VC_NON_POSTED)
		{
			read_pointer_nposted = read_pointer_nposted_p1;
		}

		if(ui_available_fc.read() && in_vc == VC_NON_POSTED){
			packet_buffer_nposted[write_pointer_nposted.read()] = ui_packet_fc.read();
			posted_pointer_when_nposted_received[write_pointer_nposted.read()] = write_pointer_posted.read();
			nposted_after_posted[write_pointer_nposted.read()] = buffer_count_posted.read() != 0;
			othervc_send_count_nposted[write_pointer_nposted.read()] = 0;

			if(write_pointer_nposted.read() == USER_FIFO_DEPTH - 1)
				write_pointer_nposted = 0;
			else
				write_pointer_nposted = (write_pointer_nposted.read() + 1);
		}

		if((consume_user_fifo.read() && fifo_user_packet_vc.read() == VC_NON_POSTED) &&
			!(ui_available_fc.read() && in_vc == VC_NON_POSTED)){
			buffer_count_nposted = buffer_count_nposted.read() - 1;
		}
		else if(!(consume_user_fifo.read() && fifo_user_packet_vc.read() == VC_NON_POSTED) &&
			(ui_available_fc.read() && in_vc == VC_NON_POSTED)){
			buffer_count_nposted = buffer_count_nposted.read() + 1;
		}

		/// RESPONSE ///
		if(consume_user_fifo.read() && fifo_user_packet_vc.read() == VC_RESPONSE)
		{
			read_pointer_response = read_pointer_response_p1;
		}

		if(ui_available_fc.read() && in_vc == VC_RESPONSE){
			packet_buffer_response[write_pointer_response.read()] = ui_packet_fc.read().range(31,0);
			posted_pointer_when_response_received[write_pointer_response.read()] = write_pointer_posted.read();
			response_after_posted[write_pointer_response.read()] = buffer_count_posted.read() != 0;
			if(write_pointer_response.read() == USER_FIFO_DEPTH - 1)
				write_pointer_response = 0;
			else
				write_pointer_response = (write_pointer_response.read() + 1);
		}

		if((consume_user_fifo.read() && fifo_user_packet_vc.read() == VC_RESPONSE) &&
			!(ui_available_fc.read() && in_vc == VC_RESPONSE))
		{
			buffer_count_response = buffer_count_response.read() - 1;
		}
		else if(!(consume_user_fifo.read() && fifo_user_packet_vc.read() == VC_RESPONSE) &&
			(ui_available_fc.read() && in_vc == VC_RESPONSE)){
			buffer_count_response = buffer_count_response.read() + 1;
		}
	}
}

void user_fifo_l3::output_available_buffers(){
	sc_bv<3> fc_user_fifo_ge2_ui_tmp;

	//Commented so that the comparator operator is not used since it makes
	//a long chain.
	/*
	fc_user_fifo_ge2_ui_tmp[VC_POSTED] = buffer_count_posted.read() >= 2;
	fc_user_fifo_ge2_ui_tmp[VC_NON_POSTED] = buffer_count_nposted.read() >= 2;
	fc_user_fifo_ge2_ui_tmp[VC_RESPONSE] = buffer_count_response.read() >= 2;
	*/

	bool ge2[3] = {false,false,false};
	for(int n = 1; n < USER_FIFO_COUNT_WIDTH; n++){
		ge2[VC_POSTED] = ge2[VC_POSTED] || buffer_count_posted.read()[n];
		ge2[VC_NON_POSTED] = ge2[VC_NON_POSTED] || buffer_count_nposted.read()[n];
		ge2[VC_RESPONSE] = ge2[VC_RESPONSE] || buffer_count_response.read()[n];
	}

	fc_user_fifo_ge2_ui_tmp[VC_POSTED] = ge2[VC_POSTED];
	fc_user_fifo_ge2_ui_tmp[VC_NON_POSTED] = ge2[VC_NON_POSTED];
	fc_user_fifo_ge2_ui_tmp[VC_RESPONSE] = ge2[VC_RESPONSE];

	fc_user_fifo_ge2_ui = fc_user_fifo_ge2_ui_tmp;
}

bool user_fifo_l3::getNextPacketToOutput(
		bool posted_loaded, sc_bv<64> posted_packet,bool posted_max_count_reached,
		bool nposted_loaded, sc_bv<64> nposted_packet,bool nposted_behind_posted,bool nposted_max_count_reached,
		bool response_loaded, sc_bv<32> response_packet,bool response_behind_posted,
		sc_bv<64> & tmp_fifo_user_packet,VirtualChannel &next_vc_output)
{

	bool posted_data = ! (sc_bit)posted_packet[4];
	bool nposted_data = nposted_packet.range(4,3) == "01" || (sc_bit)nposted_packet[5];
	bool response_data = !(sc_bit)response_packet[0];
	
	
	///Next value of output, if the data is consumed
	bool tmp_fifo_user_available;

	/**
		Ok, now select the packet that has the most priority:
	*/

	sc_bv<64> full_response;
	full_response.range(31,0) = response_packet;
	full_response.range(63,32) = 0;

	bool responsePassPw = getPassPW(full_response);

	bool npostedPassPw = getPassPW(nposted_packet);

	//Condition, must have a valid packet && must be a cmd buffer free &&
	//(either have a data buffer free or a packet that does not have data)
	bool postedPacketCanBeSent = posted_loaded && 
		(sc_bit)(fwd_next_node_buffer_status_ro.read()[USR_FIFO_VC_P_POS]) &&
		((sc_bit)(fwd_next_node_buffer_status_ro.read()[USR_FIFO_VC_P_DATA_POS]) || !posted_data);

	bool npostedPacketCanBeSent = nposted_loaded && 
		(sc_bit)(fwd_next_node_buffer_status_ro.read()[USR_FIFO_VC_NP_POS]) &&
		((sc_bit)(fwd_next_node_buffer_status_ro.read()[USR_FIFO_VC_NP_DATA_POS]) || !nposted_data) && 
		(npostedPassPw || !nposted_behind_posted);

	bool responsePacketCanBeSent = response_loaded && 
		(sc_bit)(fwd_next_node_buffer_status_ro.read()[USR_FIFO_VC_R_POS]) &&
		((sc_bit)(fwd_next_node_buffer_status_ro.read()[USR_FIFO_VC_R_DATA_POS]) || !response_data) && 
		(responsePassPw || !response_behind_posted);

	/** By default, response has max priority, but if max_count_reached is asserted, it means that another
		packet type has been ignore for too long and is taking over priority.  The same is true for posted
		packets.  The next code calculate if response has priority over others, and below if posted has
		priority over nposted packets.
	*/
	bool response_priority = responsePacketCanBeSent && !(posted_max_count_reached && postedPacketCanBeSent
		|| nposted_max_count_reached && npostedPacketCanBeSent);
	bool posted_priority = postedPacketCanBeSent && (posted_max_count_reached || 
		!(nposted_max_count_reached && npostedPacketCanBeSent));

	//Response has most priority if there is no posted packet or if it has the passPW flag
	if(response_priority){
		next_vc_output = VC_RESPONSE;
	}
	//After it is the posted packets
	else if(posted_priority){
		next_vc_output = VC_POSTED;
	}
	//Then the nposted, but it can't pass a posted packet if it does not have the passPw flag
	//on.
	else if(npostedPacketCanBeSent ){
		next_vc_output = VC_NON_POSTED;
	}
	else{
		next_vc_output = VC_NONE;
	}

	tmp_fifo_user_available = responsePacketCanBeSent || postedPacketCanBeSent || npostedPacketCanBeSent;

	if(response_priority){
		tmp_fifo_user_packet = full_response;
	}
	else if(posted_priority){
		tmp_fifo_user_packet = posted_packet;
	}
	else
		tmp_fifo_user_packet = nposted_packet;

	return tmp_fifo_user_available;

}


#ifndef SYSTEMC_SIM

#include "../core_synth/synth_control_packet.cpp"

#endif

