//nposted_vc_l3.cpp

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
 *   Laurent Aubray
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

#include "nposted_vc_l3.h"

/// Basic constructor
nposted_vc_l3::nposted_vc_l3(sc_module_name name): sc_module(name)
{

	SC_METHOD(clocked_process);
	sensitive_pos << clk;
	sensitive_neg << resetx;

	SC_METHOD(select_and_drive_output);
	for(int n = 0; n < NB_OF_BUFFERS;n++){
		sensitive << packet_addr_register[n]
#ifdef ENABLE_REORDERING
				  << packet_passpw_register[n]
				  << packet_seqid_register[n]
				  << clumped_unitid_registers[n]
#endif
				  << destination_registers[n];
	}
}

#ifdef SYSTEMC_SIM
	nposted_vc_l3::~nposted_vc_l3(){
	}
#endif

#ifdef ENABLE_REORDERING
/**
	@description  To determine if two packets should be switched because the low packet is
	more important than the high packet.

	-If low packet has more priority than high packet and passing does not break
	 ordering rules, returns 1
	-If high packet has more priority than low packet and passing does not break
	 ordering rules, returns 0
	-If two packets have identical priority or passing one another breaks ordering
	 rules, returns compare_with_higher

  @param high_pkt_complete The higher packet (packet currently ahead)
  @param low_pkt_complete The lower packet (packet currently behind)
  @param low_buffer_free If low_pkt_complete is a valid packet
  @param high_buffer_free If high_pkt_complete is a valid packet
  @param compare_with_higher If the packet (low) is currently compared with
	the higher packet, or the lower packet. Normally, this function should make abstraction 
	that the high_pkt_complete can actually be lower, but when two packets
	have the same priority, we don't want them to be switched
	so we return the compare_with_higher value as an answer  
  @return if the low packet should pass the high packet
*/
bool nposted_vc_l3::evaluate_switch_packets(bool high_passPW,bool low_passPW,
					sc_uint<4> high_seqID, sc_uint<4> low_seqID,
					sc_uint<5> high_clumped_unitid, sc_uint<5> low_clumped_unitid,
					bool high_buffer_free, bool low_buffer_free,
				    sc_uint<MAX_PASSPW_P1_LOG2_COUNT> high_pass_count,
					   sc_uint<MAX_PASSPW_P1_LOG2_COUNT> low_pass_count,
					bool compare_with_higher)
{

	bool select_low;
	if( 
		/* We verify if the packet is part of a sequence. This case MUST be put
		before the passPW test because it is more important to respect this condition
		than the passPW condtion*/					
		(high_seqID != 0
		&& high_seqID == low_seqID
		&& high_clumped_unitid == low_clumped_unitid) ||

		//If a packet has been switched the maximum of time, we don't switch it!
		(high_pass_count == MAX_PASSPW_COUNT || low_pass_count == MAX_PASSPW_COUNT)
		)
		select_low = compare_with_higher;
	else{
		if(low_passPW && !high_passPW) select_low = true;
		else if(!low_passPW && high_passPW) select_low = false;
		else select_low = compare_with_higher;
	}

	return (select_low || low_buffer_free) && !high_buffer_free;
}
#endif

void nposted_vc_l3::clocked_process()
{
	if(!resetx.read()){
		///////////////////////////////////////////
		// Reset of internal registers
		///////////////////////////////////////////
		syn_ControlPacketComplete default_syn;
		initialize_syn_ControlPacketComplete(default_syn);

		for(int n = 0; n < NB_OF_BUFFERS; n++){
			destination_registers[n] = 0;
			packet_addr_register[n] = 0;
#ifdef ENABLE_REORDERING
			clumped_unitid_registers[n] = 0;
			packet_passpw_register[n] = false;
			packet_seqid_register[n] = 0;
			pass_count[n] = 0;
#endif
		}
#ifdef ENABLE_REORDERING
		compare_with_higher = 0;
#endif
		buffers_cleared = 0;
		vc_overflow = false;
	}
	else{
		update_internal_registers();
	}
}

void nposted_vc_l3::select_and_drive_output(){
	//Packet selected to be output to accepted destination
	sc_bv<NB_OF_BUFFERS> 	selected_accepted_tmp;
	//Packet selected to be output to forward destination
	sc_bv<NB_OF_BUFFERS> 	selected_forward_tmp;
	//If a packet was found for accepted destination
	bool	selected_accepted_found;
	//If a packet was found for forward destination
	bool	selected_forward_found;

	select_top_packet(selected_accepted_tmp,selected_accepted_found,
		              selected_forward_tmp,selected_forward_found);
	drive_output(selected_accepted_tmp,selected_accepted_found,
		         selected_forward_tmp,selected_forward_found);

	selected_accepted = selected_accepted_tmp;
	selected_forward = selected_forward_tmp;
}

void nposted_vc_l3::update_internal_registers()
{
	//First, handle deletion of buffers : modify the destination vector
	//so that it takes into account buffers deleted
	sc_bv<2> destination_with_deletion[NB_OF_BUFFERS];
	bool deleted_packet_for_accepted = false;
	bool deleted_packet_for_forward = false;

	for(int n = 0; n < NB_OF_BUFFERS; n++){
		//Now, is that packet being output and deleted?
		bool accepted_deleted = (acknowledge[ACCEPTED_DEST].read())
			&& (sc_bit)selected_accepted.read()[n];

		//If deleted, update it's value
		if(accepted_deleted){
			destination_with_deletion[n][ACCEPTED_DEST] = 0;
		}
		else{
			destination_with_deletion[n][ACCEPTED_DEST] = 
				(sc_bit)destination_registers[n].read()[ACCEPTED_DEST];
		}

		//Now, is that packet being output and deleted?
		bool forward_deleted = (acknowledge[FWD_DEST].read())
			&& (sc_bit)selected_forward.read()[n];

		//If deleted, update it's value
		if(forward_deleted){
			destination_with_deletion[n][FWD_DEST] = 0;
		}
		else{
			destination_with_deletion[n][FWD_DEST] = 
				(sc_bit)destination_registers[n].read()[FWD_DEST];
		}

		//If the packet was consumed for the accepted destination and 
		//does not have any more destination, the packet has been deleted
		if(accepted_deleted &&
			(!(sc_bit)destination_with_deletion[n][ACCEPTED_DEST] &&
			!(sc_bit)destination_with_deletion[n][FWD_DEST])){
			deleted_packet_for_accepted = true;
		}

		//If the packet was consumed for the forward destination and 
		//does not have any more destination, the packet has been deleted
		if(forward_deleted &&
			(!(sc_bit)destination_with_deletion[n][FWD_DEST] &&
			!(sc_bit)destination_with_deletion[n][FWD_DEST])){
			deleted_packet_for_forward = true;
		}
	}

	///////////////////////////////////////////////////////////
	//Send to the nophandler how many packets have been deleted
	///////////////////////////////////////////////////////////

	bool same_position_accepted_forward_packets = 
		selected_accepted.read() == selected_forward.read();

	sc_bv<2> buffers_cleared_tmp;
	if(deleted_packet_for_forward && deleted_packet_for_accepted){
		if(same_position_accepted_forward_packets){
			buffers_cleared_tmp = "01";
		}
		else{
			buffers_cleared_tmp = "11";
		}
	}
	else{
		buffers_cleared_tmp[ACCEPTED_DEST] = deleted_packet_for_accepted;	
		buffers_cleared_tmp[FWD_DEST] = deleted_packet_for_forward;	
	}
	buffers_cleared = buffers_cleared_tmp;


	/**
		We're trying to keep the packets compacted on the bottom.  Every
		time a new packet is received though, packets must moved up.
		
		  We could directly use the in_packet_destination to calculate
		if packets should be moved up, but it takes quite a while to
		computer so it's not a good idea.  A compromise is to attempt
		to keep the first buffer free unless all buffers are taken.

		So we move up when the first buffer has a packet, all buffers
		are full.
	*/
	bool buffer_full[NB_OF_BUFFERS];
	for(int n = 0; n < NB_OF_BUFFERS; n++){
		buffer_full[n] = (sc_bit)destination_registers[n].read()[0] || 
		(sc_bit)destination_registers[n].read()[1];
	}

	//Check if the buffers are all full
	bool all_full = true;
	for(int n = 1; n < NB_OF_BUFFERS; n++){
		all_full = all_full && buffer_full[n];
	}

	//Move things up if packet in first buffer unless everything is full
	bool moving_up = buffer_full[0] &&
		!(all_full);

	//Calculate individual move_up vectors, to compact any holes left by
	//consumed packets.  Packets will move_up until a hole is filled
	bool move_up[NB_OF_BUFFERS];
	move_up[0] = moving_up;


	//Create the new first destination vector
	sc_bv<2>	new_first_destination;
	new_first_destination[0] = in_packet_destination[0].read();
	new_first_destination[1] = in_packet_destination[1].read();

#ifndef ENABLE_REORDERING
	////////////////////////////////////////
	// Simple algorithm without reordering
	//   Packets move up in the buffers when there is free room
	////////////////////////////////////////

	for(int n = 1; n < NB_OF_BUFFERS; n++){
		bool all_full_above_entry = true;
		for(int i = 1; i < NB_OF_BUFFERS; i++){
			if(i > n) 
				all_full_above_entry = all_full_above_entry && buffer_full[i];
		}
		move_up[n] = moving_up && !all_full_above_entry;
	}

	//Unless all buffers are full, read the incoming packet.  This avoids
	//using the in_packet_destination which comes late
	if(!((sc_bit)destination_registers[NB_OF_BUFFERS-1].read()[0] || (sc_bit)destination_registers[NB_OF_BUFFERS-1].read()[1])){
		packet_addr_register[0] = in_packet_addr.read();
		destination_registers[0] = new_first_destination;
	}
	else{
		packet_addr_register[0] = packet_addr_register[0];
		destination_registers[0] = destination_registers[0];
	}

	for(int n = 1; n < NB_OF_BUFFERS; n++){
		if(move_up){
			packet_addr_register[n] = packet_addr_register[n-1].read();
			destination_registers[n] = destination_with_deletion[n-1];
		}
		else{
			packet_addr_register[n] = packet_addr_register[n].read();
			destination_registers[n] = destination_with_deletion[n];
		}
	}
#else
	//toggle compare_with_higher at every clock cycle
	//except don't toggle when move_up is true, because packets are
	//shifted one pos
	compare_with_higher = compare_with_higher.read() ^ !moving_up;


	for(int n = 0; n < (NB_OF_BUFFERS/2); n++){
		bool all_full_above_entry = true;
		for(int i = 1; i < NB_OF_BUFFERS; i++){
			if(i > n*2+2) 
				all_full_above_entry = all_full_above_entry && buffer_full[i];
		}

		//This is tad bit hard to explain.  The only reason that we don't want
		//to move up is if the buffer is free and that the new packet can come
		//in the buffer 1 without having move_up.
		//Assume impair number of buffers
		move_up[n*2+1] = moving_up && 
			(!all_full_above_entry || !buffer_full[n*2+1] || !buffer_full[n*2+2] ||
			!buffer_full[n*2] && !compare_with_higher.read() && !unitid_reorder_disable.read());
		move_up[n*2+2] = moving_up && 
			(!all_full_above_entry || !buffer_full[n*2+2] || 
			!buffer_full[n*2+1] && compare_with_higher.read() && !unitid_reorder_disable.read());
	}

	////////////////////////////////////////
	//Decide what buffers should be switched
	////////////////////////////////////////
	bool switch_packets[NB_OF_BUFFERS/2];
	bool lower_buffer_free[NB_OF_BUFFERS/2];

	sc_bv<NB_OF_BUFFERS> buffer_free;

	//Look at which registers are free and store in vector.
	for(int n = 0; n < NB_OF_BUFFERS; n++){
		buffer_free[n] = 
			!(sc_bit)destination_registers[n].read()[ACCEPTED_DEST] &&
			!(sc_bit)destination_registers[n].read()[FWD_DEST];
	}

	//With the compare_with_higher signal, choose which packets are
	//to be compared
	sc_uint<5> lower_clumped_unitid[NB_OF_BUFFERS/2];
	sc_uint<MAX_PASSPW_P1_LOG2_COUNT> lower_pass_count[NB_OF_BUFFERS/2];
	bool lower_passPW[NB_OF_BUFFERS];
	sc_uint<4> lower_seqID[NB_OF_BUFFERS];
	for(int n = 0; n < NB_OF_BUFFERS/2; n++){
		if(compare_with_higher.read()){
			lower_buffer_free[n] = (sc_bit)buffer_free[2 * (n + 1)];
			lower_clumped_unitid[n] = clumped_unitid_registers[2 * (n + 1)].read();
			lower_passPW[n] = packet_passpw_register[2 * (n + 1)].read();
			lower_seqID[n] = packet_seqid_register[2 * (n + 1)].read();
			lower_pass_count[n] = pass_count[2 * (n + 1)].read();
		}
		else{
			lower_buffer_free[n] = (sc_bit)buffer_free[2 * n];
			lower_clumped_unitid[n] = clumped_unitid_registers[2 * n].read();
			lower_passPW[n] = packet_passpw_register[2 * n].read();
			lower_seqID[n] = packet_seqid_register[2 * n].read();
			lower_pass_count[n] = pass_count[2 * n].read();
		}
	}

	//Calculate if packets should be switched
	for(int n = 0; n < NB_OF_BUFFERS/2; n++){
		if(unitid_reorder_disable.read()){
			switch_packets[n] = compare_with_higher.read();
		}
		else{
			switch_packets[n] = evaluate_switch_packets(
				packet_passpw_register[2*n+1].read(),lower_passPW[n],
				packet_seqid_register[2*n+1].read(), lower_seqID[n],
				clumped_unitid_registers[2 * n + 1].read(),lower_clumped_unitid[n],
				(sc_bit)buffer_free[2 * n + 1],lower_buffer_free[n],
				pass_count[2*n+1].read(),lower_pass_count[n],
				compare_with_higher.read());
		}
	}

	//////////////////////////////////////////////////////////////////////
	//With the deleted packets and switch signals, store the right packets
	//////////////////////////////////////////////////////////////////////
	
	//It's the same logic for pair and impair registers, with the exception
	//of the first, second and last buffer.  That's why there's a minimum of
	//3 buffers
	
	//Special case : first register
	sc_uint<3> first_case_selector;
	first_case_selector[0] = !(((sc_bit)destination_registers[NB_OF_BUFFERS-1].read()[0] 
		|| (sc_bit)destination_registers[NB_OF_BUFFERS-1].read()[1]) &&
		((sc_bit)destination_registers[0].read()[0] 
		|| (sc_bit)destination_registers[0].read()[1]));//buffer not full
	first_case_selector[1] = compare_with_higher.read();
	first_case_selector[2] = (sc_bit)switch_packets[0];


	switch(first_case_selector){
	case 1:
	case 3:
	case 5:
	case 7:
		destination_registers[0] = new_first_destination;
		clumped_unitid_registers[0] = in_packet_clumped_unitid;
		packet_addr_register[0] = in_packet_addr;
		packet_passpw_register[0] = in_packet_passpw;
		packet_seqid_register[0] = in_packet_seqid;
		pass_count[0] = 0;
		break;

	case 4:
		destination_registers[0] = destination_with_deletion[1];
		clumped_unitid_registers[0] = clumped_unitid_registers[1];
		packet_addr_register[0] = packet_addr_register[1];
		packet_passpw_register[0] = packet_passpw_register[1];
		packet_seqid_register[0] = packet_seqid_register[1];
		pass_count[0] = pass_count[1].read()+1;
		break;

	default:
		destination_registers[0] = destination_with_deletion[0];
		clumped_unitid_registers[0] = clumped_unitid_registers[0];
		packet_addr_register[0] = packet_addr_register[0];
		packet_passpw_register[0] = packet_passpw_register[0];
		packet_seqid_register[0] = packet_seqid_register[0];
		pass_count[0] = pass_count[0];
	}


	//Special case : second register
	sc_uint<4> second_case_selector;
	second_case_selector[0] = move_up[1];
	second_case_selector[1] = compare_with_higher.read();
	second_case_selector[2] = (sc_bit)switch_packets[0];
	second_case_selector[3] = !((sc_bit)destination_registers[0].read()[0] 
		|| (sc_bit)destination_registers[0].read()[1]);//register 0 empty

	sc_uint<MAX_PASSPW_P1_LOG2_COUNT+1>	original_pass_count1;
	switch(second_case_selector){
	case 1:
	case 3:
	case 4:
	case 7:
	case 11:
	case 15:
		destination_registers[1] = destination_with_deletion[0];
		clumped_unitid_registers[1] = clumped_unitid_registers[0];
		packet_addr_register[1] = packet_addr_register[0];
		packet_passpw_register[1] = packet_passpw_register[0];
		packet_seqid_register[1] = packet_seqid_register[0];
		original_pass_count1 = pass_count[0].read();
		break;

	case 2:
	case 10:
		destination_registers[1] = destination_with_deletion[2];
		clumped_unitid_registers[1] = clumped_unitid_registers[2];
		packet_addr_register[1] = packet_addr_register[2];
		packet_passpw_register[1] = packet_passpw_register[2];
		packet_seqid_register[1] = packet_seqid_register[2];
		original_pass_count1 = pass_count[2].read();
		break;

	default:
		destination_registers[1] = destination_with_deletion[1];
		clumped_unitid_registers[1] = clumped_unitid_registers[1];
		packet_addr_register[1] = packet_addr_register[1];
		packet_passpw_register[1] = packet_passpw_register[1];
		original_pass_count1 = pass_count[1].read();
		packet_seqid_register[1] = packet_seqid_register[1];
	}

	bool increase_pass_count1;
	switch(second_case_selector){
	case 2:
	case 5:
	case 10:
		increase_pass_count1 = true;
		break;

	default:
		increase_pass_count1 = false;
	}
	pass_count[1] = original_pass_count1+sc_uint<1>(increase_pass_count1);

	//Special case : last register
	sc_uint<3> last_case_selector;
	last_case_selector[0] = move_up[NB_OF_BUFFERS - 1];
	last_case_selector[1] = compare_with_higher.read();
	last_case_selector[2] = (sc_bit)switch_packets[NB_OF_BUFFERS/2 - 1];

	switch(last_case_selector){
	case 1:
	case 2:
	case 3:
	case 7:
		destination_registers[NB_OF_BUFFERS - 1] = destination_with_deletion[NB_OF_BUFFERS - 2];
		clumped_unitid_registers[NB_OF_BUFFERS - 1] = clumped_unitid_registers[NB_OF_BUFFERS - 2];
		packet_addr_register[NB_OF_BUFFERS - 1] = packet_addr_register[NB_OF_BUFFERS - 2];
		packet_passpw_register[NB_OF_BUFFERS - 1] = packet_passpw_register[NB_OF_BUFFERS - 2];
		packet_seqid_register[NB_OF_BUFFERS - 1] = packet_seqid_register[NB_OF_BUFFERS - 2];
		pass_count[NB_OF_BUFFERS - 1] = pass_count[NB_OF_BUFFERS - 2];
		break;

	case 5:
		destination_registers[NB_OF_BUFFERS - 1] = destination_with_deletion[NB_OF_BUFFERS - 3];
		clumped_unitid_registers[NB_OF_BUFFERS - 1] = clumped_unitid_registers[NB_OF_BUFFERS - 3];
		packet_addr_register[NB_OF_BUFFERS - 1] = packet_addr_register[NB_OF_BUFFERS - 3];
		packet_passpw_register[NB_OF_BUFFERS - 1] = packet_passpw_register[NB_OF_BUFFERS - 3];
		packet_seqid_register[NB_OF_BUFFERS - 1] = packet_seqid_register[NB_OF_BUFFERS - 3];
		pass_count[NB_OF_BUFFERS - 1] = pass_count[NB_OF_BUFFERS - 3];
		break;

	default:
		destination_registers[NB_OF_BUFFERS - 1] = destination_with_deletion[NB_OF_BUFFERS - 1];
		clumped_unitid_registers[NB_OF_BUFFERS - 1] = clumped_unitid_registers[NB_OF_BUFFERS - 1];
		packet_addr_register[NB_OF_BUFFERS - 1] = packet_addr_register[NB_OF_BUFFERS - 1];
		packet_passpw_register[NB_OF_BUFFERS - 1] = packet_passpw_register[NB_OF_BUFFERS - 1];
		packet_seqid_register[NB_OF_BUFFERS - 1] = packet_seqid_register[NB_OF_BUFFERS - 1];
		pass_count[NB_OF_BUFFERS - 1] = pass_count[NB_OF_BUFFERS - 1];
	}

	//Generic case
	for(int n = 0; n < NB_OF_BUFFERS/2 - 1; n++){
		//Pair register (if starting from 0)
		sc_uint<4> pair_case_selector;
		pair_case_selector[0] = (sc_bit)switch_packets[n + 1];
		pair_case_selector[1] = (sc_bit)switch_packets[n];
		pair_case_selector[2] = move_up[2 * n + 3];
		pair_case_selector[3] = compare_with_higher.read();

		sc_uint<MAX_PASSPW_P1_LOG2_COUNT+1>	original_pass_count_pair;
		switch(pair_case_selector){
		case 1:
		case 3:
		case 4:
		case 6:
		case 14:
		case 15:
			destination_registers[2 * n + 3] = destination_with_deletion[2 * n + 2];
			clumped_unitid_registers[2 * n + 3] = clumped_unitid_registers[2 * n + 2];
			packet_addr_register[2 * n + 3] = packet_addr_register[2 * n + 2];
			packet_passpw_register[2 * n + 3] = packet_passpw_register[2 * n + 2];
			packet_seqid_register[2 * n + 3] = packet_seqid_register[2 * n + 2];
			original_pass_count_pair = pass_count[2 * n + 2].read();
			break;

		case 8:
		case 10:
			destination_registers[2 * n + 3] = destination_with_deletion[2 * n + 4];
			clumped_unitid_registers[2 * n + 3] = clumped_unitid_registers[2 * n + 4];
			packet_addr_register[2 * n + 3] = packet_addr_register[2 * n + 4];
			packet_passpw_register[2 * n + 3] = packet_passpw_register[2 * n + 4];
			packet_seqid_register[2 * n + 3] = packet_seqid_register[2 * n + 4];
			original_pass_count_pair = pass_count[2 * n + 4].read();
			break;

		case 12:
		case 13:
			destination_registers[2 * n + 3] = destination_with_deletion[2 * n + 1];
			clumped_unitid_registers[2 * n + 3] = clumped_unitid_registers[2 * n + 1];
			packet_addr_register[2 * n + 3] = packet_addr_register[2 * n + 1];
			packet_passpw_register[2 * n + 3] = packet_passpw_register[2 * n + 1];
			packet_seqid_register[2 * n + 3] = packet_seqid_register[2 * n + 1];
			original_pass_count_pair = pass_count[2 * n + 1].read();
			break;

		default:
			destination_registers[2 * n + 3] = destination_with_deletion[2 * n + 3];
			clumped_unitid_registers[2 * n + 3] = clumped_unitid_registers[2 * n + 3];
			packet_addr_register[2 * n + 3] = packet_addr_register[2 * n + 3];
			packet_passpw_register[2 * n + 3] = packet_passpw_register[2 * n + 3];
			packet_seqid_register[2 * n + 3] = packet_seqid_register[2 * n + 3];
			original_pass_count_pair = pass_count[2 * n + 3].read();
		}

		bool increment_pair_pass_count;
		switch(pair_case_selector){
		case 8:
		case 10:
			increment_pair_pass_count = buffer_full[2 * n + 3];
			break;
		case 5:
		case 7:
			increment_pair_pass_count = buffer_full[2 * n + 2];
			break;

		default:
			increment_pair_pass_count = false;
		}
		pass_count[2 * n + 3] = original_pass_count_pair + sc_uint<1>(increment_pair_pass_count);

		//Impair register (if starting from 0)
		sc_uint<4> impair_case_selector;
		impair_case_selector[0] = (sc_bit)switch_packets[n + 1];
		impair_case_selector[1] = (sc_bit)switch_packets[n];
		impair_case_selector[2] = move_up[2 * n + 2];
		impair_case_selector[3] = compare_with_higher.read();

		sc_uint<MAX_PASSPW_P1_LOG2_COUNT+1>	original_pass_count_impair;
		switch(impair_case_selector){
		case 4:
		case 5:
		case 8:
		case 9:
		case 14:
		case 15:
			destination_registers[2 * n + 2] = destination_with_deletion[2 * n + 1];
			clumped_unitid_registers[2 * n + 2] = clumped_unitid_registers[2 * n + 1];
			packet_addr_register[2 * n + 2] = packet_addr_register[2 * n + 1];
			packet_passpw_register[2 * n + 2] = packet_passpw_register[2 * n + 1];
			packet_seqid_register[2 * n + 2] = packet_seqid_register[2 * n + 1];
			original_pass_count_impair = pass_count[2 * n + 1].read();
			break;

		case 1:
		case 3:
			destination_registers[2 * n + 2] = destination_with_deletion[2 * n + 3];
			clumped_unitid_registers[2 * n + 2] = clumped_unitid_registers[2 * n + 3];
			packet_addr_register[2 * n + 2] = packet_addr_register[2 * n + 3];
			packet_passpw_register[2 * n + 2] = packet_passpw_register[2 * n + 3];
			packet_seqid_register[2 * n + 2] = packet_seqid_register[2 * n + 3];
			original_pass_count_impair = pass_count[2 * n + 3].read();
			break;

		case 6:
		case 7:
			destination_registers[2 * n + 2] = destination_with_deletion[2 * n];
			clumped_unitid_registers[2 * n + 2] = clumped_unitid_registers[2 * n];
			packet_addr_register[2 * n + 2] = packet_addr_register[2 * n];
			packet_passpw_register[2 * n + 2] = packet_passpw_register[2 * n];
			packet_seqid_register[2 * n + 2] = packet_seqid_register[2 * n];
			original_pass_count_impair = pass_count[2 * n].read();
			break;

		default:
			destination_registers[2 * n + 2] = destination_with_deletion[2 * n + 2];
			clumped_unitid_registers[2 * n + 2] = clumped_unitid_registers[2 * n + 2];
			packet_addr_register[2 * n + 2] = packet_addr_register[2 * n + 2];
			packet_passpw_register[2 * n + 2] = packet_passpw_register[2 * n + 2];
			packet_seqid_register[2 * n + 2] = packet_seqid_register[2 * n + 2];
			original_pass_count_impair = pass_count[2 * n + 2].read();
		}

		bool increment_impair_pass_count;
		switch(impair_case_selector){
		case 1:
		case 3:
			//destination_registers[2 * n + 2] = destination_with_deletion[2 * n + 3];
			increment_impair_pass_count = buffer_full[2 * n + 2];
			break;

		case 12:
		case 13:
			increment_impair_pass_count = buffer_full[2 * n + 1];
			break;
		default:
			increment_impair_pass_count = false;
		}
		pass_count[2 * n + 2] = original_pass_count_impair + sc_uint<1>(increment_impair_pass_count);

	}
#endif

	//Check to log overflow errors
	vc_overflow = ((sc_bit)destination_registers[NB_OF_BUFFERS-1].read()[0] 
		|| (sc_bit)destination_registers[NB_OF_BUFFERS-1].read()[1]) && 
		((sc_bit)destination_registers[0].read()[0] 
		|| (sc_bit)destination_registers[0].read()[1]) &&
		((sc_bit)new_first_destination[0] || (sc_bit)new_first_destination[1]);
}



void nposted_vc_l3::drive_output(sc_bv<NB_OF_BUFFERS> selected_accepted,
								bool selected_accepted_found,
								sc_bv<NB_OF_BUFFERS> selected_forward,
								bool selected_forward_found)
{
	//================================================
	//Output the packet that were found by the encoder
	//================================================
	sc_uint<LOG2_NB_OF_BUFFERS> out_packet_addr_accepted = 0;
#ifdef ENABLE_REORDERING
	bool out_packet_passpw_accepted = false;
	sc_uint<4> out_packet_seqid_accepted = 0;
#endif

	//This is a AND-OR
	for(int n = 0; n < NB_OF_BUFFERS; n++){
		//AND the packet with the selected bit

		sc_uint<LOG2_NB_OF_BUFFERS> select_out_packet_addr;
#ifdef ENABLE_REORDERING
		bool  select_out_packet_passpw;
		sc_uint<4>  select_out_packet_seqid;
#endif

		for(int i = 0; i < LOG2_NB_OF_BUFFERS; i++)
			select_out_packet_addr[i] = (sc_bit)packet_addr_register[n].read()[i] && (sc_bit)selected_accepted[n];
#ifdef ENABLE_REORDERING
		select_out_packet_passpw = packet_passpw_register[n].read() && (sc_bit)selected_accepted[n];
		for(int i = 0; i < 4; i++)
			select_out_packet_seqid[i] = (sc_bit)packet_seqid_register[n].read()[i] && (sc_bit)selected_accepted[n];
#endif


		//OR together all packets.  Since only one packet is selected, the output will be that packet
		out_packet_addr_accepted = out_packet_addr_accepted | select_out_packet_addr;
#ifdef ENABLE_REORDERING
		out_packet_passpw_accepted = out_packet_passpw_accepted || select_out_packet_passpw;
		out_packet_seqid_accepted = out_packet_seqid_accepted | select_out_packet_seqid;
#endif
	}

	out_packet_addr[ACCEPTED_DEST] = out_packet_addr_accepted;
#ifdef ENABLE_REORDERING
	out_packet_passpw[ACCEPTED_DEST] = out_packet_passpw_accepted;
	out_packet_seqid[ACCEPTED_DEST] = out_packet_seqid_accepted;
#endif

	sc_uint<LOG2_NB_OF_BUFFERS> out_packet_addr_forward = 0;
#ifdef ENABLE_REORDERING
	bool out_packet_passpw_forward = false;
	sc_uint<4> out_packet_seqid_forward = 0;
#endif

	for(int n = 0; n < NB_OF_BUFFERS; n++){
		//AND the packet with the selected bit
		sc_uint<LOG2_NB_OF_BUFFERS> select_out_packet_addr;
#ifdef ENABLE_REORDERING
		bool  select_out_packet_passpw;
		sc_uint<4>  select_out_packet_seqid;
#endif

		for(int i = 0; i < LOG2_NB_OF_BUFFERS; i++)
			select_out_packet_addr[i] = (sc_bit)packet_addr_register[n].read()[i] && (sc_bit)selected_forward[n];
#ifdef ENABLE_REORDERING
		select_out_packet_passpw = packet_passpw_register[n].read() && (sc_bit)selected_forward[n];
		for(int i = 0; i < 4; i++)
			select_out_packet_seqid[i] = (sc_bit)packet_seqid_register[n].read()[i] && (sc_bit)selected_forward[n];
#endif

		//OR together all packets.  Since only one packet is selected, the output will be that packet
		out_packet_addr_forward = out_packet_addr_forward | select_out_packet_addr;
#ifdef ENABLE_REORDERING
		out_packet_passpw_forward = out_packet_passpw_forward || select_out_packet_passpw;
		out_packet_seqid_forward = out_packet_seqid_forward | select_out_packet_seqid;
#endif
	}
	out_packet_addr[FWD_DEST] = out_packet_addr_forward;
#ifdef ENABLE_REORDERING
	out_packet_passpw[FWD_DEST] = out_packet_passpw_forward;
	out_packet_seqid[FWD_DEST] = out_packet_seqid_forward;
#endif

	packet_available[ACCEPTED_DEST] = selected_accepted_found;
	packet_available[FWD_DEST] = selected_forward_found;
}

void nposted_vc_l3::select_top_packet(sc_bv<NB_OF_BUFFERS> &selected_accepted,
								bool &selected_accepted_found,
								sc_bv<NB_OF_BUFFERS> &selected_forward,
								bool &selected_forward_found)
{
	//====================================
	//Encoder for the Accepted destination
	//====================================
	sc_bv<NB_OF_BUFFERS> accepted_to_encode;

	//Start by copying the signal
	for(int n = 0; n < NB_OF_BUFFERS; n++){
		accepted_to_encode[n] = (sc_bit)destination_registers[n].read()[ACCEPTED_DEST];
	}

	//Tree of or to find if there is a packet
	bool found_accepted = accepted_to_encode.or_reduce();
	//Find what is the highest packet in the buffers
	sc_bv<NB_OF_BUFFERS> accepted_one_hot;
	//If top packet if full, then it is the chosen packet
	accepted_one_hot[NB_OF_BUFFERS-1] = accepted_to_encode[NB_OF_BUFFERS-1];
	//For all other positions, check that it is full and all higher buffers are empty
	for(int n = 0; n < (NB_OF_BUFFERS-1); n++){
        //Commented because SystemC synthesis tool cannot take part vectors
        //that use a loop variable *even* if the loop is unrolled
        //...go figure
		//accepted_one_hot[n] = (sc_bit)accepted_to_encode[n] && 
		//	(~(accepted_to_encode.range(NB_OF_BUFFERS-1,n+1))).and_reduce();

        //I really hope the synthesis simplifies this because it's an awfull hack...
        bool accepted_ahead = false;
        for(int i = NB_OF_BUFFERS-1; i > 0;i--){
                if(i>n) accepted_ahead = accepted_ahead || (sc_bit)accepted_to_encode[i];
        }
        accepted_one_hot[n] = (sc_bit)accepted_to_encode[n] && !accepted_ahead;
	}

	//===================================
	//Encoder for the Forward destination
	//===================================
	sc_bv<NB_OF_BUFFERS> forward_to_encode;

	//Start by copying the signal
	for(int n = 0; n < NB_OF_BUFFERS; n++){
		forward_to_encode[n] = (sc_bit)destination_registers[n].read()[FWD_DEST];
	}

	//Tree of or to find if there is a packet
	bool found_forward = forward_to_encode.or_reduce();
	//Find what is the highest packet in the buffers
	sc_bv<NB_OF_BUFFERS> forward_one_hot;
	//If top packet if full, then it is the chosen packet
	forward_one_hot[NB_OF_BUFFERS-1] = forward_to_encode[NB_OF_BUFFERS-1];
	//For all other positions, check that it is full and all higher buffers are empty
	for(int n = 0; n < (NB_OF_BUFFERS-1); n++){
        //Same as for accepted loop, RTL compiler problems
        //forward_one_hot[n] = (sc_bit)forward_to_encode[n] &&
        //      (~(forward_to_encode.range(NB_OF_BUFFERS-1,n+1))).and_reduce();
        bool forwarded_ahead = false;
        for(int i = NB_OF_BUFFERS-1; i > 0;i--){
                if(i>n) forwarded_ahead = forwarded_ahead || (sc_bit)forward_to_encode[i];
        }
        forward_one_hot[n] = (sc_bit)forward_to_encode[n] && !forwarded_ahead;
	}

	//Share the result with the rest of the module for the deletion of packets
	selected_accepted = accepted_one_hot;
	selected_forward = forward_one_hot;
	selected_accepted_found = found_accepted;
	selected_forward_found = found_forward;

}

#ifndef SYSTEMC_SIM
#include "../core_synth/synth_control_packet.cpp"
#endif


