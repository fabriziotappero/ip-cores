//entrance_reordering_l3.cpp

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


#include "entrance_reordering_l3.h"

entrance_reordering_l3::entrance_reordering_l3(sc_module_name name) : sc_module(name){
	SC_METHOD(packet_directing);
	sensitive << in_packet << packet_available << csr_io_space_enable 
#ifdef ENABLE_DIRECTROUTE
		<< csr_direct_route_enable 
#endif
		<< unit_id << csr_memory_space_enable 
		<< increment_nposted_refid_upon_posted_accepted << nposted_refid_accepted
		<< increment_response_refid_upon_posted_accepted << response_refid_accepted
		<< increment_nposted_refid_upon_posted_rejected << nposted_refid_rejected
		<< increment_response_refid_upon_posted_rejected << response_refid_rejected;

	SC_METHOD(clocked_process);
	sensitive_pos(clk);
	sensitive_neg(resetx);
}

void entrance_reordering_l3::clocked_process(){
	if(!resetx.read()){
		increment_nposted_refid_upon_posted_accepted = false;
		nposted_refid_accepted = 0;
		increment_response_refid_upon_posted_accepted = false;
		response_refid_accepted = 0;
		increment_nposted_refid_upon_posted_rejected = false;
		nposted_refid_rejected = 0;
		increment_response_refid_upon_posted_rejected = false;
		response_refid_rejected = 0;
	}
	else{
		sc_bv<64> in_packet_bits = in_packet.read().packet;

		increment_nposted_refid_upon_posted_rejected = increment_nposted_refid_upon_posted_rejected.read() && 
			!(destination_pc[FWD_DEST].read() && packet_available.read())
			|| (destination_npc[FWD_DEST].read() && packet_available.read() && !(sc_bit)in_packet_bits[15]);
		increment_response_refid_upon_posted_rejected = increment_response_refid_upon_posted_rejected.read() && 
			!(destination_pc[FWD_DEST].read() && packet_available.read())
			|| (destination_rc[FWD_DEST].read() && packet_available.read() && !(sc_bit)in_packet_bits[15]);
		nposted_refid_rejected = new_packet_nposted_refid_rejected.read();
		response_refid_rejected = new_packet_response_refid_rejected.read();

		increment_nposted_refid_upon_posted_accepted = increment_nposted_refid_upon_posted_accepted.read() && 
			!(destination_pc[ACCEPTED_DEST].read() && packet_available.read())
			|| (destination_npc[ACCEPTED_DEST].read() && packet_available.read() && !(sc_bit)in_packet_bits[15]);
		increment_response_refid_upon_posted_accepted = increment_response_refid_upon_posted_accepted.read() && 
			!(destination_pc[ACCEPTED_DEST].read() && packet_available.read())
			|| (destination_rc[ACCEPTED_DEST].read() && packet_available.read() && !(sc_bit)in_packet_bits[15]);
		nposted_refid_accepted = new_packet_nposted_refid_accepted.read();
		response_refid_accepted = new_packet_response_refid_accepted.read();
	}
}


	
void entrance_reordering_l3::packet_directing(void)
{
	//Give default values to signals
	for(int n = 0; n < 2; n++){
		new_packet_available[n] = false;

		destination_pc[n] = false;
		destination_npc[n] = false;
		destination_rc[n] = false;
	}

	//Default values
	new_packet_available[VC_POSTED] = false;
	new_packet_available[VC_NON_POSTED] = false;
	new_packet_available[VC_RESPONSE] = false;

	//Well, directly send the packet to the virtual channels
	sc_bv<64> in_packet_bits = in_packet.read().packet;
	sc_bv<BUFFERS_ADDRESS_WIDTH> in_packet_data_addr = in_packet.read().data_address;

#ifdef ENABLE_REORDERING
	new_packet_passPW = (sc_bit)in_packet_bits[15];
	new_packet_chain = (sc_bit)in_packet_bits[19];
	sc_uint<4> seqid_tmp;
	seqid_tmp.range(1,0) = (sc_bv<2>)in_packet_bits.range(14,13);
	seqid_tmp.range(3,2) = (sc_bv<2>)in_packet_bits.range(7,6);
	new_packet_seqid = seqid_tmp;

	sc_uint<5> unitID = getUnitID(in_packet.read().packet);
	new_packet_clumped_unitid = clumped_unit_id[unitID].read();
#endif

	/// Sends the incoming packet to the proper VC.

	//Analyze basic packet features
	sc_bv<64> pkt = in_packet.read().packet;
	bool error64BitExtension = in_packet.read().error64BitExtension;
	PacketCommand cmd = getPacketCommand(pkt.range(5,0));
	VirtualChannel vc = getVirtualChannel(pkt, cmd);

#ifdef RETRY_MODE_ENABLED
	//Output the VC so that the nophandler can know from which VC to free a flow control credit
	//when a stomped packet is received (available is not asserted in that case, but the packet
	//is valid
	input_packet_vc = vc;
#endif

	//The destinations that will be set
	//bool destinationCsr = false;
	bool request_goes_csr_or_user = request_goes_to_csr(pkt,error64BitExtension,cmd) ||
										request_goes_to_user(pkt,error64BitExtension,cmd);
	bool destination_accepted_posted_nposted = request_goes_csr_or_user || (cmd == BROADCAST);
	bool destination_forward_posted_nposted = !request_goes_csr_or_user || (cmd == BROADCAST);

	bool destination_accepted_response = response_goes_to_user(pkt);


	// Grab the packet and direct it to the proper VC, depending on it's VC
	bool vc_is_posted = vc == VC_POSTED;
	bool destination_pc_accepted = destination_accepted_posted_nposted && vc_is_posted && packet_available.read();
	bool destination_pc_fwd = destination_forward_posted_nposted && vc_is_posted && packet_available.read();
	new_packet_available[VC_POSTED] = vc_is_posted && packet_available.read();

	bool vc_is_nposted = vc == VC_NON_POSTED;
	bool destination_npc_accepted = destination_accepted_posted_nposted && vc_is_nposted && packet_available.read();
	bool destination_npc_fwd = destination_forward_posted_nposted && vc_is_nposted && packet_available.read();
	new_packet_available[VC_NON_POSTED] = vc_is_nposted && packet_available.read();

	bool vc_is_response = vc == VC_RESPONSE;
	bool destination_rc_accepted = destination_accepted_response && vc_is_response && packet_available.read();
	bool destination_rc_fwd = !destination_accepted_response && vc_is_response && packet_available.read();
	new_packet_available[VC_RESPONSE] = vc_is_response && packet_available.read();
	
	//Output what was calculated
	destination_pc[ACCEPTED_DEST] = destination_pc_accepted;
	destination_pc[FWD_DEST] = destination_pc_fwd;
	destination_npc[ACCEPTED_DEST] = destination_npc_accepted;
	destination_npc[FWD_DEST] = destination_npc_fwd;
	destination_rc[ACCEPTED_DEST] = destination_rc_accepted;
	destination_rc[FWD_DEST] = destination_rc_fwd;

	//Use it to find if packet is accepted or not
	bool in_packet_forward_tmp = destination_pc_fwd || destination_npc_fwd || destination_rc_fwd;
	bool in_packet_accepted_tmp = destination_pc_accepted || destination_npc_accepted || destination_rc_accepted;

	//Output the new refids for forward (rejected) destination
	sc_uint<LOG2_NB_OF_BUFFERS+1> new_packet_nposted_refid_rejected_tmp;
	sc_uint<LOG2_NB_OF_BUFFERS+1> new_packet_response_refid_rejected_tmp;
	if(packet_available.read() && vc_is_posted && 
			increment_nposted_refid_upon_posted_rejected.read() && in_packet_forward_tmp)
		new_packet_nposted_refid_rejected_tmp = nposted_refid_rejected.read()+1;
	else
		new_packet_nposted_refid_rejected_tmp = nposted_refid_rejected.read();
	if(packet_available.read() && vc_is_posted && 
			increment_response_refid_upon_posted_rejected.read() && in_packet_forward_tmp)
		new_packet_response_refid_rejected_tmp = response_refid_rejected.read()+1;
	else
		new_packet_response_refid_rejected_tmp = response_refid_rejected.read();

	//Output the new refids for accepted destination
	sc_uint<LOG2_NB_OF_BUFFERS+1> new_packet_nposted_refid_accepted_tmp;
	sc_uint<LOG2_NB_OF_BUFFERS+1> new_packet_response_refid_accepted_tmp;
	if(packet_available.read() && vc_is_posted && 
			increment_nposted_refid_upon_posted_accepted.read() && in_packet_accepted_tmp)
		new_packet_nposted_refid_accepted_tmp = nposted_refid_accepted.read()+1;
	else
		new_packet_nposted_refid_accepted_tmp = nposted_refid_accepted.read();
	if(packet_available.read() && vc_is_posted && 
			increment_response_refid_upon_posted_accepted.read() && in_packet_accepted_tmp)
		new_packet_response_refid_accepted_tmp = response_refid_accepted.read()+1;
	else
		new_packet_response_refid_accepted_tmp = response_refid_accepted.read();

	////////////////////////////////////////////////////////////////////////////////////////
	// Packet content, from this point (entrance reordering), is divided in two.
	// A first part is sent to registers which can reorder the packets.  The strict
	// minimum number of bits is sent to registers because of their expensive nature.
	//
	// The rest of the packet is sent to an embedded memory.  Fields of the packets which
	// are sent to the registers can now be re-used to minimize the width of data sent
	// to the embedded memory.  Which bits can be re-used depends on the packet type.
	// This part packs the most information depending on the virtual channel of the packet.
	//
	// Fields of packets that can be used are fields that are either reserved or sent to the
	// registers :
	//  For Posted and non-posted packets
	//		-seqID is sent to registers : bits 7..6 and 14..13
	//		-passPW is sent to registers : bit 15
	//  For Response packets
	//		-Reserved bits : 6 and 13
	//      -passPW : 15
	//      -constant : command bits 5..2
	//      -unused bits : 63..32
	////////////////////////////////////////////////////////////////////////////////////////

	//LOG2_NB_OF_BUFFERS
	sc_bv<CMD_BUFFER_MEM_WIDTH> ro_command_packet_wr_data_tmp;
	ro_command_packet_wr_data_tmp.range(63,0) = in_packet.read().packet;

#ifndef ENABLE_REORDERING
	ro_command_packet_wr_data_tmp[64] = in_packet.read().error64BitExtension;
	ro_command_packet_wr_data_tmp.range(BUFFERS_ADDRESS_WIDTH+64,65) = in_packet_data_addr;
	ro_command_packet_wr_data_tmp.range(LOG2_NB_OF_BUFFERS+BUFFERS_ADDRESS_WIDTH+65,BUFFERS_ADDRESS_WIDTH+65) = new_packet_nposted_refid_rejected_tmp;
	ro_command_packet_wr_data_tmp.range(2 * LOG2_NB_OF_BUFFERS+BUFFERS_ADDRESS_WIDTH+66,LOG2_NB_OF_BUFFERS+BUFFERS_ADDRESS_WIDTH+66) = new_packet_response_refid_rejected_tmp;
	ro_command_packet_wr_data_tmp.range(3 * LOG2_NB_OF_BUFFERS+BUFFERS_ADDRESS_WIDTH+67,2*LOG2_NB_OF_BUFFERS + BUFFERS_ADDRESS_WIDTH+67) = new_packet_nposted_refid_accepted_tmp;
	ro_command_packet_wr_data_tmp.range(4 * LOG2_NB_OF_BUFFERS+BUFFERS_ADDRESS_WIDTH+68,3 * LOG2_NB_OF_BUFFERS+BUFFERS_ADDRESS_WIDTH+68) = new_packet_response_refid_accepted_tmp;
#else
	//Store error64bit at passPW position
	ro_command_packet_wr_data_tmp[15] = in_packet.read().error64BitExtension;
	//Store the refid
	//For other field, place differently depending on if it is a response or not
	if(vc == VC_RESPONSE){
  #if LOG2_NB_OF_BUFFERS < 5
		ro_command_packet_wr_data_tmp.range(1 + BUFFERS_ADDRESS_WIDTH,2) = in_packet_data_addr;
  #else
		ro_command_packet_wr_data_tmp.range(5,2) = in_packet_data_addr.range(3,0);
		ro_command_packet_wr_data_tmp.range(27 + BUFFERS_ADDRESS_WIDTH,32) = 
			in_packet_data_addr.range(BUFFERS_ADDRESS_WIDTH-1,4);
  #endif
  #if BUFFERS_ADDRESS_WIDTH < 5
		if(in_packet_forward_tmp)
			ro_command_packet_wr_data_tmp.range(LOG2_NB_OF_BUFFERS+64,64) = new_packet_response_refid_rejected_tmp;
		else
			ro_command_packet_wr_data_tmp.range(LOG2_NB_OF_BUFFERS+64,64) = new_packet_response_refid_accepted_tmp;
  #else
		if(in_packet_forward_tmp)
			ro_command_packet_wr_data_tmp.range(60+LOG2_NB_OF_BUFFERS + BUFFERS_ADDRESS_WIDTH,60+BUFFERS_ADDRESS_WIDTH) = new_packet_response_refid_rejected_tmp;
		else
			ro_command_packet_wr_data_tmp.range(60+LOG2_NB_OF_BUFFERS + BUFFERS_ADDRESS_WIDTH,60+BUFFERS_ADDRESS_WIDTH) = new_packet_response_refid_accepted_tmp;
  #endif
	}
	else{
  #if BUFFERS_ADDRESS_WIDTH < 3
		ro_command_packet_wr_data_tmp.range(BUFFERS_ADDRESS_WIDTH+5,6) = in_packet_data_addr;
  #elif BUFFERS_ADDRESS_WIDTH < 5
		ro_command_packet_wr_data_tmp.range(7,6) = in_packet_data_addr.range(1,0);
		ro_command_packet_wr_data_tmp.range(BUFFERS_ADDRESS_WIDTH+10,13) = in_packet_data_addr.range(BUFFERS_ADDRESS_WIDTH-1,2);
  #else
		ro_command_packet_wr_data_tmp.range(7,6) = in_packet_data_addr.range(1,0);
		ro_command_packet_wr_data_tmp.range(14,13) = in_packet_data_addr.range(3,2);
		ro_command_packet_wr_data_tmp.range(59+BUFFERS_ADDRESS_WIDTH,64) = in_packet_data_addr.range(BUFFERS_ADDRESS_WIDTH-1,4);
  #endif
  #if BUFFERS_ADDRESS_WIDTH < 5
		if(in_packet_forward_tmp)
			ro_command_packet_wr_data_tmp.range(LOG2_NB_OF_BUFFERS+64,64) = new_packet_nposted_refid_rejected_tmp;
		else
			ro_command_packet_wr_data_tmp.range(LOG2_NB_OF_BUFFERS+64,64) = new_packet_nposted_refid_accepted_tmp;
  #else
		if(in_packet_forward_tmp)
			ro_command_packet_wr_data_tmp.range(60+LOG2_NB_OF_BUFFERS + BUFFERS_ADDRESS_WIDTH,60+BUFFERS_ADDRESS_WIDTH) = new_packet_nposted_refid_rejected_tmp;
		else
			ro_command_packet_wr_data_tmp.range(60+LOG2_NB_OF_BUFFERS + BUFFERS_ADDRESS_WIDTH,60+BUFFERS_ADDRESS_WIDTH) = new_packet_nposted_refid_accepted_tmp;
  #endif
	}
#endif
	ro_command_packet_wr_data = ro_command_packet_wr_data_tmp;
}

// Determine if the current buffer goes to the CSR
bool entrance_reordering_l3::request_goes_to_csr(sc_bv<64> &pkt, bool error64BitExtension, 
												 const PacketCommand &cmd)
{
	sc_bv<5> unitID = getUnitID(pkt);
	/**
		If the packet had a 64 bit extension or if the request is upstream,
		the in both case the packet is forwarded.  In the case of a 64 bit
		error, even if the packet is sent to the forward side, the packet will\
		not be forwarded but will be handled by the error handler.
	*/
	sc_bv<16> csr_top_addr = "1111110111111110";
	sc_bv<40> pkt_top_addr = getRequestAddr(pkt,cmd);
	if (!error64BitExtension && request_isDownstream(unitID) &&
		sc_bv<16>(pkt_top_addr.range(39,24)) == csr_top_addr
				&& pkt_top_addr.range(15,11) == unit_id.read()
				&& request_getCompatOrIsoc(pkt) == false)
	{
		return true;
	}
	else
		return false;
}

// Determine if the current buffer goes to the User
bool entrance_reordering_l3::request_goes_to_user(sc_bv<64> &pkt, bool error64BitExtension,
												   const PacketCommand &cmd)
{
	//default value
	bool request_goes_to_user_return_val = false;

	//Extract some information from the packet
	sc_bv<40> request_addr = getRequestAddr(pkt,cmd);
	sc_bv<5> pkt_unidID = getUnitID(pkt);

#ifdef ENABLE_DIRECTROUTE
	//Check if it's from direct_route
	sc_bv<6> direct_route_interdict_top_addr = "111111";
	//Is the packet coming from a direcroute enable unitID?
	bool from_direct_route_enabled = (sc_bit)csr_direct_route_enable.read()[
		(sc_uint<5>) pkt_unidID];
	//There is range of addresses which are not allowed for directroute traffic
	//FD_0000_0000_0000h - FF_FFFF_FFFFh
	bool dr_interdict_zone = request_addr.range(39,34) == direct_route_interdict_top_addr &&
		((sc_bit)request_addr[33] || (sc_bit)request_addr[32]);
#endif

	bool barAddress = isBarAddress(request_addr);

	sc_bv<12> messaging_top_addr = "111111100000";
	sc_bv<4> messaging_cmd_part = "1011";

	// If The packet is a broadcast, we don't care about the address
	/* Commented because a broadcast is dectected higher in the hierarchy
		(before this function is actually called)
	if(cmd == BROADCAST)
	{
		request_goes_to_user_return_val = true;
	}
	// In the case of a downstream or directroute packet
	else */

	//To go to user, the packet must either be downstream
	//or from a directroute enabled source
	request_goes_to_user_return_val = ((request_isDownstream(pkt_unidID)
#ifdef ENABLE_DIRECTROUTE
		|| (from_direct_route_enabled && !dr_interdict_zone)
#endif
		)&& !error64BitExtension) &&

        (
			// We verify if the address is in the User range
			(barAddress  &&
			// We verify if the Compat bit == 0
			request_getCompatOrIsoc(pkt) == false
			// and we verify if the packet is a write or a read
			&& (cmd == WRITE ||
			cmd == READ || cmd == ATOMIC))
		||
			//device messaging goes to user
			(sc_bv<12>(request_addr.range(39,28)) == messaging_top_addr
				&& request_addr.range(15,11) == unit_id.read() &&
				/*posted write*/ pkt.range(5,2) == messaging_cmd_part)
				);

	return request_goes_to_user_return_val;
}

// We check if the address correspond to a range described by a csr_bar register
bool entrance_reordering_l3::isBarAddress( const sc_bv<40>& address)
{
	bool found_bar_bar[NbRegsBars];
	bool found_bar = false;
		
	found_bar_bar[0] = (address.range(39, Header_BarLowerPos0) == csr_bar[0].read().range(39,Header_BarLowerPos0)
		&& (Header_BarIOSpace[0] && csr_io_space_enable.read() || !Header_BarIOSpace[0] && csr_memory_space_enable.read()));
	
#if (NbRegsBars > 1)
	found_bar_bar[1] = (address.range(39, Header_BarLowerPos1) == csr_bar[1].read().range(39,Header_BarLowerPos1)
		&& (Header_BarIOSpace[1] && csr_io_space_enable.read() || !Header_BarIOSpace[1] && csr_memory_space_enable.read()));
#endif
	
#if (NbRegsBars > 2)
	found_bar_bar[2] = (address.range(39, Header_BarLowerPos2) == csr_bar[2].read().range(39,Header_BarLowerPos2)
		&& (Header_BarIOSpace[2] && csr_io_space_enable.read() || !Header_BarIOSpace[2] && csr_memory_space_enable.read()));
#endif
		
#if (NbRegsBars > 3)
	found_bar_bar[3] = (address.range(39, Header_BarLowerPos3) == csr_bar[3].read().range(39,Header_BarLowerPos3)
		&& (Header_BarIOSpace[3] && csr_io_space_enable.read() || !Header_BarIOSpace[3] && csr_memory_space_enable.read()));
#endif
		
#if (NbRegsBars > 4)
	found_bar_bar[4] = (address.range(39, Header_BarLowerPos4) == csr_bar[4].read().range(39,Header_BarLowerPos4)
		&& (Header_BarIOSpace[4] && csr_io_space_enable.read() || !Header_BarIOSpace[4] && csr_memory_space_enable.read()));
#endif
		
#if (NbRegsBars > 5)
	found_bar_bar[5] = (address.range(39, Header_BarLowerPos5) == csr_bar[5].read().range(39,Header_BarLowerPos5)
		&& (Header_BarIOSpace[5] && csr_io_space_enable.read() || !Header_BarIOSpace[5] && csr_memory_space_enable.read()));
#endif

	for(int n = 0; n < NbRegsBars; n++)
		found_bar = found_bar || found_bar_bar[n];
	return found_bar;	
}

// Determine if the current buffer goes to the User
bool entrance_reordering_l3::response_goes_to_user(sc_bv<64> &pkt)
{
	// We verify the unit_id and the bridge bit
	if (sc_bv<5>(getUnitID(pkt)) == unit_id.read()
			&& pkt[14] == true)
		return true;
	else
		return false;
}

bool entrance_reordering_l3::request_isDownstream(sc_bv<5> &pkt_unidID){
	sc_uint<2> tmp_lower_unitID = (sc_bv<2>)pkt_unidID.range(1,0);
	//Equivalent of: not_clumped_0 = pkt_unidID < 4;
	bool not_clumped_0 = !((sc_bit)pkt_unidID[4] || (sc_bit)pkt_unidID[3] || (sc_bit)pkt_unidID[2]);

	if (not_clumped_0 && (sc_uint<5>)(clumped_unit_id[tmp_lower_unitID].read()) == 0)
		return true;
	else
		return false;
	
}

#ifndef SYSTEMC_SIM
#include "../core_synth/synth_control_packet.cpp"
#endif

