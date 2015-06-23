//final_reordering_l3.cpp

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

#include "final_reordering_l3.h"

#ifdef SYSTEMC_SIM
using namespace std;
#endif

/// Main constructor.
final_reordering_l3::final_reordering_l3(sc_module_name name) : sc_module(name)
{
	
	
	SC_METHOD(clocked_process);
	sensitive_pos << clk;
	sensitive_neg << resetx;

	SC_METHOD(output_request);
	sensitive << posted_packet_buffer_accepted_loaded[0] 
		      << posted_packet_buffer_accepted_loaded[1]
		      << nposted_packet_buffer_accepted_loaded[0]
		      << nposted_packet_buffer_accepted_loaded[1]
		      << response_packet_buffer_accepted_loaded[0]
		      << response_packet_buffer_accepted_loaded[1]
			  << posted_packet_buffer_rejected_loaded[0] 
		      << posted_packet_buffer_rejected_loaded[1]
		      << nposted_packet_buffer_rejected_loaded[0]
		      << nposted_packet_buffer_rejected_loaded[1]
		      << response_packet_buffer_rejected_loaded[0]
		      << response_packet_buffer_rejected_loaded[1]
			  << fetched_packet_vc[0] << fetched_packet_vc[1]
			  << fetched_packet_available[0]
			  << fetched_packet_available[1];

	SC_METHOD(find_next_packet_buf_workaround);
	sensitive << posted_packet_buffer_accepted_loaded[0] 
		      << posted_packet_buffer_accepted_loaded[1]
		      << nposted_packet_buffer_accepted_loaded[0]
		      << nposted_packet_buffer_accepted_loaded[1]
		      << response_packet_buffer_accepted_loaded[0]
		      << response_packet_buffer_accepted_loaded[1]
			  << posted_packet_buffer_rejected_loaded[0] 
		      << posted_packet_buffer_rejected_loaded[1]
		      << nposted_packet_buffer_rejected_loaded[0]
		      << nposted_packet_buffer_rejected_loaded[1]
		      << response_packet_buffer_rejected_loaded[0]
		      << response_packet_buffer_rejected_loaded[1]
			  << posted_packet_buffer_accepted[0] 
		      << posted_packet_buffer_accepted[1]
		      << nposted_packet_buffer_accepted[0]
		      << nposted_packet_buffer_accepted[1]
		      << response_packet_buffer_accepted[0]
		      << response_packet_buffer_accepted[1]
			  << posted_packet_buffer_rejected[0] 
		      << posted_packet_buffer_rejected[1]
		      << nposted_packet_buffer_rejected[0]
		      << nposted_packet_buffer_rejected[1]
		      << response_packet_buffer_rejected[0]
		      << response_packet_buffer_rejected[1]
			  << posted_packet_wait_count_accepted[0]
			  << posted_packet_wait_count_accepted[1]
			  << nposted_packet_wait_count_accepted[0]
			  << nposted_packet_wait_count_accepted[1]
			  << response_packet_wait_count_accepted[0]
			  << response_packet_wait_count_accepted[1]
			  << posted_packet_wait_count_rejected[0]
			  << posted_packet_wait_count_rejected[1]
			  << nposted_packet_wait_count_rejected[0]
			  << nposted_packet_wait_count_rejected[1]
			  << response_packet_wait_count_rejected[0]
			  << response_packet_wait_count_rejected[1]
			  ;
}

void final_reordering_l3::doFinalReorderingFWD(void){

    //syn_ControlPacketComplete rc_packet;
	sc_uint<LOG2_NB_OF_BUFFERS+1> response_refid;

    //syn_ControlPacketComplete pc_packet;
 	sc_uint<LOG2_NB_OF_BUFFERS+1> posted_nposted_refid;
	sc_uint<LOG2_NB_OF_BUFFERS+1> posted_response_refid;

	//syn_ControlPacketComplete npc_packet;
	sc_uint<LOG2_NB_OF_BUFFERS+1> nposted_refid;

	// Select the response packet
	bool rc_packet_available = response_packet_buffer_rejected_loaded[0].read() ||
							   response_packet_buffer_rejected_loaded[1].read();
	//rc_packet.packet.range(63,32) = 0;
	//rc_packet.error64BitExtension = false;
	//rc_packet.isPartOfChain = false;
	if(response_packet_buffer_rejected_loaded[0].read()){
		//rc_packet.packet.range(31,0) =  response_packet_buffer_rejected[0].read().packet;
		//rc_packet.data_address = response_packet_buffer_rejected[0].read().data_address;
		response_refid = response_packet_buffer_rejected_refid[0].read();
	}
	else{
		//rc_packet.packet.range(31,0) =  response_packet_buffer_rejected[1].read().packet;
		//rc_packet.data_address = response_packet_buffer_rejected[1].read().data_address;
		response_refid = response_packet_buffer_rejected_refid[1].read();
	}

	// Select the posted packet
	bool pc_packet_available = posted_packet_buffer_rejected_loaded[0].read() ||
							   posted_packet_buffer_rejected_loaded[1].read();
	if(posted_packet_buffer_rejected_loaded[0].read()){
		//pc_packet =  posted_packet_buffer_rejected[0].read();
		posted_response_refid = posted_packet_buffer_rejected_response_refid[0].read();
		posted_nposted_refid = posted_packet_buffer_rejected_nposted_refid[0].read();
	}
	else{
		//pc_packet =  posted_packet_buffer_rejected[1].read();
		posted_response_refid = posted_packet_buffer_rejected_response_refid[1].read();
		posted_nposted_refid = posted_packet_buffer_rejected_nposted_refid[1].read();
	}

	// Select the non-posted packet
	bool npc_packet_available = nposted_packet_buffer_rejected_loaded[0].read() ||
							   nposted_packet_buffer_rejected_loaded[1].read();
	if(nposted_packet_buffer_rejected_loaded[0].read()){
		//npc_packet =  nposted_packet_buffer_rejected[0].read();
		nposted_refid = nposted_packet_buffer_rejected_refid[0].read();
	}
	else{
		//npc_packet =  nposted_packet_buffer_rejected[1].read();
		nposted_refid = nposted_packet_buffer_rejected_refid[1].read();
	}


	////////////////////////////////////////////////////////
	// Compare refids to know the order the packet arrived
	// relatively to the posted channel
	////////////////////////////////////////////////////////
	sc_uint<LOG2_NB_OF_BUFFERS+1> nposted_refid_compared =
		nposted_refid - posted_nposted_refid;
	bool nposted_ordering_ok = !pc_packet_available || nposted_refid_compared[LOG2_NB_OF_BUFFERS];

	sc_uint<LOG2_NB_OF_BUFFERS+1> response_refid_compared =
		response_refid - posted_response_refid;
	bool response_ordering_ok = !pc_packet_available || response_refid_compared[LOG2_NB_OF_BUFFERS];



	sc_bv<64> rc_packet_bits = rc_packet_rejected.read().packet;
	sc_bv<64> pc_packet_bits = pc_packet_rejected.read().packet;
	sc_bv<64> npc_packet_bits = npc_packet_rejected.read().packet;

	PacketCommand rc_packet_cmd = getPacketCommand(rc_packet_bits.range(5,0));
	PacketCommand pc_packet_cmd = getPacketCommand(pc_packet_bits.range(5,0));
	PacketCommand npc_packet_cmd = getPacketCommand(npc_packet_bits.range(5,0));

	bool rchasDataAssociated = hasDataAssociated(rc_packet_cmd); 
	//Check if there is enough buffers in the next node to send the packet
	//and check that all data has arrived if it has an associated data packet
	bool rcFreeWithData = (
		//Check if it has data and there is room in the next buffer
		//for a control and data packet, if it is a packet with data
		(rchasDataAssociated 
		&& (sc_bit)(fwd_next_node_buffer_status_ro.read()[BIT_RC_FREE_DATA]) && 
		(sc_bit)(fwd_next_node_buffer_status_ro.read()[BIT_RC_FREE])) ||
		//If there is no data associated, only check if there is a
		//control buffer available
		(!rchasDataAssociated 
		&& (sc_bit)(fwd_next_node_buffer_status_ro.read()[BIT_RC_FREE]) ))
		//If there is data associated, make sure that the data has finished
		//coming in
		 &&!(rc_packet_rejected.read().data_address == cd_data_pending_addr_ro &&
		rchasDataAssociated &&
		cd_data_pending_ro.read());
	

	bool pchasDataAssociated = hasDataAssociated(pc_packet_cmd);
	//Check if there is enough buffers in the next node to send the packet
	//and check that all data has arrived if it has an associated data packet
	bool pcFreeWithData = (
		//Check if it has data and there is room in the next buffer
		//for a control and data packet, if it is a packet with data
		(pchasDataAssociated 
		&& (sc_bit)(fwd_next_node_buffer_status_ro.read()[BIT_PC_FREE_DATA]) && 
		(sc_bit)(fwd_next_node_buffer_status_ro.read()[BIT_PC_FREE])) ||
		//If there is no data associated, only check if there is a
		//control buffer available
		(!pchasDataAssociated 
		&& (sc_bit)(fwd_next_node_buffer_status_ro.read()[BIT_PC_FREE])))
		//If there is data associated, make sure that the data has finished
		//coming in
		 &&!(pc_packet_rejected.read().data_address == cd_data_pending_addr_ro &&
		pchasDataAssociated &&
		cd_data_pending_ro.read());
	
	bool npchasDataAssociated = hasDataAssociated(npc_packet_cmd);
	//Check if there is enough buffers in the next node to send the packet
	//and check that all data has arrived if it has an associated data packet
	bool npcFreeWithData = (
		//Check if it has data and there is room in the next buffer
		//for a control and data packet, if it is a packet with data
		(npchasDataAssociated 
		&& (sc_bit)(fwd_next_node_buffer_status_ro.read()[BIT_NPC_FREE_DATA]) && 
		(sc_bit)(fwd_next_node_buffer_status_ro.read()[BIT_NPC_FREE])) ||
		//If there is no data associated, only check if there is a
		//control buffer available
		(!npchasDataAssociated 
		&& (sc_bit)(fwd_next_node_buffer_status_ro.read()[BIT_NPC_FREE])) )
		//If there is data associated, make sure that the data has finished
		//coming in
		 &&!(npc_packet_rejected.read().data_address == cd_data_pending_addr_ro &&
		npchasDataAssociated &&
		cd_data_pending_ro.read());


		
	//Most important packet is Response with passPW, if there is room
	//in the next device
	/**
	   This first condition makes it so a packet is only issued once every
	   two cycles.  Because most packets are 64 bits, this should not cause
	   too much slowdown.  This is done because to output a packet every cycle
	   would require an extra buffer, at least for the posted channel.
	*/
	if(rejected_output_loaded.read() && ack[FWD_DEST].read() || csr_sync.read()){
		out_packet_fwd = out_packet_fwd.read();
		out_packet_vc_fwd = out_packet_vc_fwd.read();
		rejected_vc_decoded = 0;
		out_packet_available_fwd = false;
		rejected_output_loaded = false;
	}
	//Most important packet is Response with passPW, if there is room
	//in the next device
	else if(rc_packet_available && 
		getPassPW(rc_packet_bits) &&
		rcFreeWithData && 
		(! (pcFreeWithData && pc_packet_rejected_maxwait_reached.read() ||
		    npcFreeWithData && npc_packet_rejected_maxwait_reached.read())
			|| rc_packet_rejected_maxwait_reached.read()))
	{
		out_packet_fwd = rc_packet_rejected.read();
		out_packet_vc_fwd = VC_RESPONSE;
		rejected_vc_decoded = "100";
		out_packet_available_fwd = true;
		rejected_output_loaded = true;	
	}
	//After that, it's the posted channel, whatever passPW is, also if
	//there is room in the next device
	else if(pc_packet_available &&
		pcFreeWithData && 
		(! (rcFreeWithData && rc_packet_rejected_maxwait_reached.read() ||
		    npcFreeWithData && npc_packet_rejected_maxwait_reached.read())
			|| pc_packet_rejected_maxwait_reached.read()))
	{
		out_packet_fwd = pc_packet_rejected.read();
		out_packet_vc_fwd = VC_POSTED;
		rejected_vc_decoded = "001";
		out_packet_available_fwd = true;
		rejected_output_loaded = true;	
	}
	//Next, we go back to the response channel if there is room in the 
	//next device. but also only if there are no posted request that arrived
	//ahead of that response packet (ordering restriction)
	else if(rc_packet_available &&
		rcFreeWithData && response_ordering_ok  && 
		(! (npcFreeWithData && npc_packet_rejected_maxwait_reached.read())
			|| rc_packet_rejected_maxwait_reached.read()))
	{
		out_packet_fwd = rc_packet_rejected.read();
		out_packet_vc_fwd = VC_RESPONSE;
		rejected_vc_decoded = "100";
		out_packet_available_fwd = true;
		rejected_output_loaded = true;	
	}
	//After that, we fo with the NPC with passPW or no posted packet blocking
	//the transmission
	else if(npc_packet_available &&
		(getPassPW(npc_packet_bits) ||
			nposted_ordering_ok) &&
		npcFreeWithData)
	{
		out_packet_fwd = npc_packet_rejected.read();
		out_packet_vc_fwd = VC_NON_POSTED;
		rejected_vc_decoded = "010";
		out_packet_available_fwd = true;
		rejected_output_loaded = true;	
	}
	//If there is nothing, output zeros
	else{
		out_packet_fwd = out_packet_fwd.read();
		out_packet_vc_fwd = out_packet_vc_fwd.read();
		rejected_vc_decoded = 0;
		out_packet_available_fwd = false;
		rejected_output_loaded = false;	
	}
}


void final_reordering_l3::doFinalReorderingAccepted(){

    //syn_ControlPacketComplete rc_packet;
	sc_uint<LOG2_NB_OF_BUFFERS+1> response_refid;

    //syn_ControlPacketComplete pc_packet;
 	sc_uint<LOG2_NB_OF_BUFFERS+1> posted_nposted_refid;
	sc_uint<LOG2_NB_OF_BUFFERS+1> posted_response_refid;

	//syn_ControlPacketComplete npc_packet;
	sc_uint<LOG2_NB_OF_BUFFERS+1> nposted_refid;

	// Select the response packet
	bool rc_packet_available = response_packet_buffer_accepted_loaded[0].read() ||
							   response_packet_buffer_accepted_loaded[1].read();
	//rc_packet.packet.range(63,32) = 0;
	//rc_packet.error64BitExtension = false;
	//rc_packet.isPartOfChain = false;
	if(response_packet_buffer_accepted_loaded[0].read()){
		//rc_packet.packet.range(31,0) =  response_packet_buffer_accepted[0].read().packet;
		//rc_packet.data_address = response_packet_buffer_accepted[0].read().data_address;
		response_refid = response_packet_buffer_accepted_refid[0].read();
	}
	else{
		//rc_packet.packet.range(31,0) =  response_packet_buffer_accepted[1].read().packet;
		//rc_packet.data_address = response_packet_buffer_accepted[1].read().data_address;
		response_refid = response_packet_buffer_accepted_refid[1].read();
	}

	// Select the posted packet
	bool pc_packet_available = posted_packet_buffer_accepted_loaded[0].read() ||
							   posted_packet_buffer_accepted_loaded[1].read();
	if(posted_packet_buffer_accepted_loaded[0].read()){
		//pc_packet =  posted_packet_buffer_accepted[0].read();
		posted_response_refid = posted_packet_buffer_accepted_response_refid[0].read();
		posted_nposted_refid = posted_packet_buffer_accepted_nposted_refid[0].read();
	}
	else{
		//pc_packet =  posted_packet_buffer_accepted[1].read();
		posted_response_refid = posted_packet_buffer_accepted_response_refid[1].read();
		posted_nposted_refid = posted_packet_buffer_accepted_nposted_refid[1].read();
	}

	// Select the non-posted packet
	bool npc_packet_available = nposted_packet_buffer_accepted_loaded[0].read() ||
							   nposted_packet_buffer_accepted_loaded[1].read();
	if(nposted_packet_buffer_accepted_loaded[0].read()){
		//npc_packet =  nposted_packet_buffer_accepted[0].read();
		nposted_refid = nposted_packet_buffer_accepted_refid[0].read();
	}
	else{
		//npc_packet =  nposted_packet_buffer_accepted[1].read();
		nposted_refid = nposted_packet_buffer_accepted_refid[1].read();
	}

	////////////////////////////////////////////////////////
	// Compare refids to know the order the packet arrived
	// relatively to the posted channel
	////////////////////////////////////////////////////////
	sc_uint<LOG2_NB_OF_BUFFERS+1> nposted_refid_compared =
		nposted_refid - posted_nposted_refid;
	bool nposted_ordering_ok = !pc_packet_available || nposted_refid_compared[LOG2_NB_OF_BUFFERS];

	sc_uint<LOG2_NB_OF_BUFFERS+1> response_refid_compared =
		response_refid - posted_response_refid;
	bool response_ordering_ok = !pc_packet_available || response_refid_compared[LOG2_NB_OF_BUFFERS];

	sc_bv<64> rc_packet_bits = rc_packet_accepted.read().packet;
	sc_bv<64> pc_packet_bits = pc_packet_accepted.read().packet;
	sc_bv<64> npc_packet_bits = npc_packet_accepted.read().packet;

	PacketCommand rc_packet_cmd = getPacketCommand(rc_packet_bits.range(5,0));
	PacketCommand pc_packet_cmd = getPacketCommand(pc_packet_bits.range(5,0));
	PacketCommand npc_packet_cmd = getPacketCommand(npc_packet_bits.range(5,0));
	
	bool rcFreeWithData = 
		//If there is data associated, make sure that the data has finished
		//coming in
		!(rc_packet_accepted.read().data_address == cd_data_pending_addr_ro &&
		hasDataAssociated(rc_packet_cmd) &&
		cd_data_pending_ro.read());

	bool pcFreeWithData = 
		//If there is data associated, make sure that the data has finished
		//coming in
		!(pc_packet_accepted.read().data_address == cd_data_pending_addr_ro &&
		hasDataAssociated(pc_packet_cmd) &&
		cd_data_pending_ro.read());
	
	bool npcFreeWithData = 
		//If there is data associated, make sure that the data has finished
		//coming in
		 !(npc_packet_accepted.read().data_address == cd_data_pending_addr_ro &&
		hasDataAssociated(npc_packet_cmd) &&
		cd_data_pending_ro.read());
	
	//Most important packet is Response with passPW	
	/**
	   This first condition makes it so a packet is only issued once every
	   two cycles.  Because most packets are 64 bits, this should not cause
	   too much slowdown.  This is done because to output a packet every cycle
	   would require an extra buffer, at least for the posted channel.
	*/
	if(accepted_output_loaded.read() && 
		(ack[UI_DEST].read() || ack[CSR_DEST].read() || csr_sync.read()) ){
		out_packet_accepted = out_packet_accepted.read();
		out_packet_available_ui = false;
		out_packet_available_csr = false;
		accepted_output_loaded = false;
		accepted_vc_decoded = "000";
	}
	else if(rc_packet_available && 
		getPassPW(rc_packet_bits) &&
		rcFreeWithData && 
		(! (pcFreeWithData && pc_packet_accepted_maxwait_reached.read() ||
		    npcFreeWithData && npc_packet_accepted_maxwait_reached.read())
			|| rc_packet_accepted_maxwait_reached.read()))
	{
		out_packet_accepted = rc_packet_accepted.read();
		out_packet_available_ui = true;
		out_packet_available_csr = false;
		accepted_output_loaded = true;
		accepted_vc_decoded = "100";
	}
	//After that, it's the posted channel, whatever passPW is, also if
	//there is room in the next device
	else if(pc_packet_available &&
		pcFreeWithData && 
		(! (rcFreeWithData && rc_packet_accepted_maxwait_reached.read() ||
		    npcFreeWithData && npc_packet_accepted_maxwait_reached.read())
			|| pc_packet_accepted_maxwait_reached.read()))
	{
		out_packet_accepted = pc_packet_accepted.read();
		bool pc_packet_goes_to_csr = 
			request_goes_to_csr(pc_packet_bits);
		out_packet_available_ui = !pc_packet_goes_to_csr;
		out_packet_available_csr = pc_packet_goes_to_csr;
		accepted_output_loaded = true;
		accepted_vc_decoded = "001";
	}
	//Next, we go back to the response channel  if there are no posted request waiting
	//to be sent that aren't selected because it's data is not fully arrived
	else if(rc_packet_available &&
		rcFreeWithData && response_ordering_ok  && 
		(! (npcFreeWithData && npc_packet_accepted_maxwait_reached.read())
			|| rc_packet_accepted_maxwait_reached.read()))
	{
		out_packet_accepted = rc_packet_accepted.read();
		out_packet_available_ui = true;
		out_packet_available_csr = false;
		accepted_output_loaded = true;
		accepted_vc_decoded = "100";
	}
	//After that, we fo with the NPC with passPW or non passPW if not packets
	//in posted
	else if(npc_packet_available &&
		(getPassPW(npc_packet_bits) ||
			nposted_ordering_ok)&&
		npcFreeWithData)
	{
		out_packet_accepted = npc_packet_accepted.read();
		bool npc_packet_goes_to_csr = 
			request_goes_to_csr(npc_packet_bits);

		out_packet_available_ui = !npc_packet_goes_to_csr;
		out_packet_available_csr = npc_packet_goes_to_csr;
		accepted_output_loaded = true;
		accepted_vc_decoded = "010";
	}
	//If there is nothing, output zeros
	else{
		out_packet_accepted = out_packet_accepted.read();
		out_packet_available_ui = false;
		out_packet_available_csr = false;
		accepted_output_loaded = false;
		accepted_vc_decoded = "000";
	}
}

void final_reordering_l3::updateBufferContent(){
	//////////////////////////////////////////////////////////////
	// Manage accepted registers
	//////////////////////////////////////////////////////////////

	// Posted channel registers
	posted_packet_buffer_accepted_loaded[0] = 
			(posted_packet_buffer_accepted_loaded[0].read() ||
			posted_packet_buffer_accepted_loaded[1].read() ||
			fetched_packet_available[ACCEPTED_DEST].read() && 
			fetched_packet_vc[ACCEPTED_DEST].read() == VC_POSTED) 
				&&
			!((ack[UI_DEST].read() || ack[CSR_DEST].read()) && (sc_bit)accepted_vc_decoded.read()[0]);

	bool increment_posted_accepted = registered_ack_accepted.read() && 
		!(sc_bit)registered_accepted_vc_decoded.read()[VC_POSTED];
	bool posted_accepted_counter_saturate[2];
	posted_accepted_counter_saturate[0] = posted_packet_wait_count_accepted[0].read() == MAX_PASSPW_COUNT;
	posted_accepted_counter_saturate[1] = posted_packet_wait_count_accepted[1].read() == MAX_PASSPW_COUNT;

	if(!posted_packet_buffer_accepted_loaded[0].read()){
		if(posted_packet_buffer_accepted_loaded[1].read()){
			posted_packet_buffer_accepted[0] = posted_packet_buffer_accepted[1];
			posted_packet_wait_count_accepted[0] = posted_packet_wait_count_accepted[1].read() + 
				sc_uint<1>(increment_posted_accepted && !posted_accepted_counter_saturate[1]);
			posted_packet_buffer_accepted_nposted_refid[0] = 
				posted_packet_buffer_accepted_nposted_refid[1];
			posted_packet_buffer_accepted_response_refid[0] = 
				posted_packet_buffer_accepted_response_refid[1];
		}
		else{
			posted_packet_buffer_accepted[0] = fetched_packet[ACCEPTED_DEST];
			posted_packet_wait_count_accepted[0] = 0;
			posted_packet_buffer_accepted_nposted_refid[0] = 
				fetched_packet_nposted_refid[ACCEPTED_DEST];
			posted_packet_buffer_accepted_response_refid[0] = 
				fetched_packet_response_refid[ACCEPTED_DEST];
		}
	}
	else{
		posted_packet_wait_count_accepted[0] = posted_packet_wait_count_accepted[0].read() + 
			sc_uint<1>(increment_posted_accepted && !posted_accepted_counter_saturate[0]);
	}

	posted_packet_buffer_accepted_loaded[1] = !posted_requested[ACCEPTED_DEST].read();


	if(!posted_packet_buffer_accepted_loaded[1].read()){
		posted_packet_buffer_accepted[1] = fetched_packet[ACCEPTED_DEST];
		posted_packet_wait_count_accepted[1] = 0;
		posted_packet_buffer_accepted_nposted_refid[1] = 
			fetched_packet_nposted_refid[ACCEPTED_DEST];
		posted_packet_buffer_accepted_response_refid[1] = 
			fetched_packet_response_refid[ACCEPTED_DEST];
	}
	else{
		posted_packet_wait_count_accepted[1] = posted_packet_wait_count_accepted[1].read() + 
			sc_uint<1>(increment_posted_accepted && !posted_accepted_counter_saturate[1]);
	}

	// NON-Posted channel registers
	nposted_packet_buffer_accepted_loaded[0] = 
			(nposted_packet_buffer_accepted_loaded[0].read() ||
			nposted_packet_buffer_accepted_loaded[1].read() ||
			fetched_packet_available[ACCEPTED_DEST].read() && 
			fetched_packet_vc[ACCEPTED_DEST].read() == VC_NON_POSTED) 
				&&
			!((ack[UI_DEST].read() || ack[CSR_DEST].read()) && (sc_bit)accepted_vc_decoded.read()[1]);

	bool increment_nposted_accepted = registered_ack_accepted.read() && 
		!(sc_bit)registered_accepted_vc_decoded.read()[VC_NON_POSTED];
	bool nposted_counter_saturate[2];
	nposted_counter_saturate[0] = nposted_packet_wait_count_accepted[0].read() == 3;
	nposted_counter_saturate[1] = nposted_packet_wait_count_accepted[1].read() == 3;

	if(!nposted_packet_buffer_accepted_loaded[0].read()){
		if(nposted_packet_buffer_accepted_loaded[1].read()){
			nposted_packet_buffer_accepted[0] = nposted_packet_buffer_accepted[1];
			nposted_packet_wait_count_accepted[0] = nposted_packet_wait_count_accepted[1].read() + 
				sc_uint<1>(increment_nposted_accepted && !nposted_counter_saturate[1]);
			nposted_packet_buffer_accepted_refid[0] = 
				nposted_packet_buffer_accepted_refid[1];
		}
		else{
			nposted_packet_buffer_accepted[0] = fetched_packet[ACCEPTED_DEST];
			nposted_packet_wait_count_accepted[0] = 0;
			nposted_packet_buffer_accepted_refid[0] = 
				fetched_packet_nposted_refid[ACCEPTED_DEST];
		}
	}
	else{
		nposted_packet_wait_count_accepted[0] = nposted_packet_wait_count_accepted[0].read() + 
			sc_uint<1>(increment_nposted_accepted && !nposted_counter_saturate[0]);
	}

	nposted_packet_buffer_accepted_loaded[1] = !nposted_requested[ACCEPTED_DEST].read();

	if(!nposted_packet_buffer_accepted_loaded[1].read()){
		nposted_packet_buffer_accepted[1] = fetched_packet[ACCEPTED_DEST];
		nposted_packet_wait_count_accepted[1] = 0;
		nposted_packet_buffer_accepted_refid[1] = 
			fetched_packet_nposted_refid[ACCEPTED_DEST];
	}
	else{
		nposted_packet_wait_count_accepted[1] = nposted_packet_wait_count_accepted[1].read() + 
			sc_uint<1>(increment_nposted_accepted && !nposted_counter_saturate[1]);
	}

	// Response channel registers
	response_packet_buffer_accepted_loaded[0] = 
			(response_packet_buffer_accepted_loaded[0].read() ||
			response_packet_buffer_accepted_loaded[1].read() ||
			fetched_packet_available[ACCEPTED_DEST].read() && 
			fetched_packet_vc[ACCEPTED_DEST].read() == VC_RESPONSE) 
				&&
			!((ack[UI_DEST].read() || ack[CSR_DEST].read()) && (sc_bit)accepted_vc_decoded.read()[2]);

	bool increment_response_accepted =  registered_ack_accepted.read() && 
		!(sc_bit)registered_accepted_vc_decoded.read()[VC_RESPONSE];
	bool response_counter_saturate[2];
	response_counter_saturate[0] = response_packet_wait_count_accepted[0].read() == 3;
	response_counter_saturate[1] = response_packet_wait_count_accepted[1].read() == 3;


	syn_ResponseControlPacketComplete acceptedInputResponsePacket;
	sc_bv<64> fetched_accepted_packet_bits = fetched_packet[ACCEPTED_DEST].read().packet;
	acceptedInputResponsePacket.packet = fetched_accepted_packet_bits.range(31,0);
	acceptedInputResponsePacket.data_address = fetched_packet[ACCEPTED_DEST].read().data_address;

	if(!response_packet_buffer_accepted_loaded[0].read()){
		if(response_packet_buffer_accepted_loaded[1].read()){
			response_packet_buffer_accepted[0] = response_packet_buffer_accepted[1];
			response_packet_wait_count_accepted[0] = response_packet_wait_count_accepted[1].read() + 
				sc_uint<1>(increment_response_accepted && !response_counter_saturate[1]);
			response_packet_buffer_accepted_refid[0] = 
				response_packet_buffer_accepted_refid[1];
		}
		else{
			response_packet_buffer_accepted[0] = acceptedInputResponsePacket;
			response_packet_wait_count_accepted[0] = 0;
			response_packet_buffer_accepted_refid[0] = 
				fetched_packet_nposted_refid[ACCEPTED_DEST];
		}
	}
	else{
		response_packet_wait_count_accepted[0] = response_packet_wait_count_accepted[0].read() + 
			sc_uint<1>(increment_response_accepted && !response_counter_saturate[0]);
	}

	response_packet_buffer_accepted_loaded[1] = !response_requested[ACCEPTED_DEST].read();

	if(!response_packet_buffer_accepted_loaded[1].read()){
		response_packet_buffer_accepted[1] = acceptedInputResponsePacket;
		response_packet_wait_count_accepted[1] = 0;
		response_packet_buffer_accepted_refid[1] = 
			fetched_packet_nposted_refid[ACCEPTED_DEST];
	}
	else{
		response_packet_wait_count_accepted[1] = response_packet_wait_count_accepted[1].read() + 
			sc_uint<1>(increment_response_accepted && !response_counter_saturate[1]);
	}


	//////////////////////////////////////////////////////////////
	// Manage rejected registers
	//////////////////////////////////////////////////////////////

	// Posted channel registers
	posted_packet_buffer_rejected_loaded[0] = 
			(posted_packet_buffer_rejected_loaded[0].read() ||
			posted_packet_buffer_rejected_loaded[1].read() ||
			fetched_packet_available[FWD_DEST].read() && 
			fetched_packet_vc[FWD_DEST].read() == VC_POSTED) 
				&&
			!(ack[FWD_DEST].read() && (sc_bit)rejected_vc_decoded.read()[0]);

	bool increment_posted_rejected = registered_ack_rejected.read() && 
		!(sc_bit)registered_rejected_vc_decoded.read()[VC_POSTED];
	bool posted_rejected_counter_saturate[2];
	posted_rejected_counter_saturate[0] = posted_packet_wait_count_rejected[0].read() == MAX_PASSPW_COUNT;
	posted_rejected_counter_saturate[1] = posted_packet_wait_count_rejected[1].read() == MAX_PASSPW_COUNT;

	if(!posted_packet_buffer_rejected_loaded[0].read()){
		if(posted_packet_buffer_rejected_loaded[1].read()){
			posted_packet_buffer_rejected[0] = posted_packet_buffer_rejected[1];
			posted_packet_wait_count_rejected[0] = posted_packet_wait_count_rejected[1].read() + 
				sc_uint<1>(increment_posted_rejected && !posted_rejected_counter_saturate[1]);
			posted_packet_buffer_rejected_nposted_refid[0] = 
				posted_packet_buffer_rejected_nposted_refid[1];
			posted_packet_buffer_rejected_response_refid[0] = 
				posted_packet_buffer_rejected_response_refid[1];
		}
		else{
			posted_packet_buffer_rejected[0] = fetched_packet[FWD_DEST];
			posted_packet_wait_count_rejected[0] = 0;
			posted_packet_buffer_rejected_nposted_refid[0] = 
				fetched_packet_nposted_refid[FWD_DEST];
			posted_packet_buffer_rejected_response_refid[0] = 
				fetched_packet_response_refid[FWD_DEST];
		}
	}
	else{
		posted_packet_wait_count_rejected[0] = posted_packet_wait_count_rejected[0].read() + 
			sc_uint<1>(increment_posted_rejected && !posted_rejected_counter_saturate[0]);
	}

	posted_packet_buffer_rejected_loaded[1] = !posted_requested[FWD_DEST].read();

	if(!posted_packet_buffer_rejected_loaded[1].read()){
		posted_packet_buffer_rejected[1] = fetched_packet[FWD_DEST];
		posted_packet_wait_count_rejected[1] = 0;
		posted_packet_buffer_rejected_nposted_refid[1] = 
			fetched_packet_nposted_refid[FWD_DEST];
		posted_packet_buffer_rejected_response_refid[1] = 
			fetched_packet_response_refid[FWD_DEST];
	}
	else{
		posted_packet_wait_count_rejected[1] = posted_packet_wait_count_rejected[1].read() + 
			sc_uint<1>(increment_posted_rejected && !posted_rejected_counter_saturate[1]);
	}

	// NON-Posted channel registers
	nposted_packet_buffer_rejected_loaded[0] = 
			(nposted_packet_buffer_rejected_loaded[0].read() ||
			nposted_packet_buffer_rejected_loaded[1].read() ||
			fetched_packet_available[FWD_DEST].read() && 
			fetched_packet_vc[FWD_DEST].read() == VC_NON_POSTED) 
				&&
			!(ack[FWD_DEST].read() && (sc_bit)rejected_vc_decoded.read()[1]);

	bool increment_nposted_rejected = registered_ack_rejected.read() && 
		!(sc_bit)registered_rejected_vc_decoded.read()[VC_NON_POSTED];
	bool nposted_rejected_counter_saturate[2];
	nposted_rejected_counter_saturate[0] = nposted_packet_wait_count_rejected[0].read() == MAX_PASSPW_COUNT;
	nposted_rejected_counter_saturate[1] = nposted_packet_wait_count_rejected[1].read() == MAX_PASSPW_COUNT;

	if(!nposted_packet_buffer_rejected_loaded[0].read()){
		if(nposted_packet_buffer_rejected_loaded[1].read()){
			nposted_packet_buffer_rejected[0] = nposted_packet_buffer_rejected[1];
			nposted_packet_wait_count_rejected[0] = nposted_packet_wait_count_rejected[1].read() + 
				sc_uint<1>(increment_nposted_rejected && !nposted_rejected_counter_saturate[1]);
			nposted_packet_buffer_rejected_refid[0] = 
				nposted_packet_buffer_rejected_refid[1];
		}
		else{
			nposted_packet_buffer_rejected[0] = fetched_packet[FWD_DEST];
			nposted_packet_wait_count_rejected[0] = 0;
			nposted_packet_buffer_rejected_refid[0] = 
				fetched_packet_nposted_refid[FWD_DEST];
		}
	}
	else{
		nposted_packet_wait_count_rejected[0] = nposted_packet_wait_count_rejected[0].read() + 
			sc_uint<1>(increment_nposted_rejected && !nposted_rejected_counter_saturate[0]);
	}

	nposted_packet_buffer_rejected_loaded[1] = !nposted_requested[FWD_DEST].read();

	if(!nposted_packet_buffer_rejected_loaded[1].read()){
		nposted_packet_buffer_rejected[1] = fetched_packet[FWD_DEST];
		nposted_packet_wait_count_rejected[1] = 0;
		nposted_packet_buffer_rejected_refid[1] = 
			fetched_packet_nposted_refid[FWD_DEST];
	}
	else{
		nposted_packet_wait_count_rejected[1] = nposted_packet_wait_count_rejected[1].read() + 
			sc_uint<1>(increment_nposted_rejected && !nposted_rejected_counter_saturate[1]);
	}

	// Response channel registers
	response_packet_buffer_rejected_loaded[0] = 
			(response_packet_buffer_rejected_loaded[0].read() ||
			response_packet_buffer_rejected_loaded[1].read() ||
			fetched_packet_available[FWD_DEST].read() && 
			fetched_packet_vc[FWD_DEST].read() == VC_RESPONSE) 
				&&
			!(ack[FWD_DEST].read() && (sc_bit)rejected_vc_decoded.read()[2]);

	bool increment_response_rejected = registered_ack_rejected.read() && 
		!(sc_bit)registered_rejected_vc_decoded.read()[VC_RESPONSE];
	bool response_rejected_counter_saturate[2];
	response_rejected_counter_saturate[0] = response_packet_wait_count_rejected[0].read() == MAX_PASSPW_COUNT;
	response_rejected_counter_saturate[1] = response_packet_wait_count_rejected[1].read() == MAX_PASSPW_COUNT;

	syn_ResponseControlPacketComplete rejectedInputResponsePacket;
	sc_bv<64> fetched_rejected_packet_bits = fetched_packet[FWD_DEST].read().packet;
	rejectedInputResponsePacket.packet = fetched_rejected_packet_bits.range(31,0);
	rejectedInputResponsePacket.data_address = fetched_packet[FWD_DEST].read().data_address;

	if(!response_packet_buffer_rejected_loaded[0].read()){
		if(response_packet_buffer_rejected_loaded[1].read()){
			response_packet_buffer_rejected[0] = response_packet_buffer_rejected[1];
			response_packet_wait_count_rejected[0] = response_packet_wait_count_rejected[1].read() + 
				sc_uint<1>(increment_response_rejected && !response_rejected_counter_saturate[1]);
			response_packet_buffer_rejected_refid[0] = 
				response_packet_buffer_rejected_refid[1];
		}
		else{
			response_packet_buffer_rejected[0] = rejectedInputResponsePacket;
			response_packet_wait_count_rejected[0] = 0;
			response_packet_buffer_rejected_refid[0] = 
				fetched_packet_nposted_refid[FWD_DEST];
		}
	}
	else{
		response_packet_wait_count_rejected[0] = response_packet_wait_count_rejected[0].read() + 
			sc_uint<1>(increment_response_rejected && !response_rejected_counter_saturate[0]);
	}

	response_packet_buffer_rejected_loaded[1] = !response_requested[FWD_DEST].read();

	if(!response_packet_buffer_rejected_loaded[1].read()){
		response_packet_buffer_rejected[1] = rejectedInputResponsePacket;
		response_packet_wait_count_rejected[1] = 0;
		response_packet_buffer_rejected_refid[1] = 
			fetched_packet_nposted_refid[FWD_DEST];
	}
	else{
		response_packet_wait_count_rejected[1] = response_packet_wait_count_rejected[1].read() + 
			sc_uint<1>(increment_response_rejected && !response_rejected_counter_saturate[1]);
	}

}


void final_reordering_l3::clocked_process(){
	if(!resetx.read()){
		syn_ControlPacketComplete default_syn_packet_complete;
		initialize_syn_ControlPacketComplete(default_syn_packet_complete);

		syn_ResponseControlPacketComplete default_response_syn_packet_complete;
		initialize_syn_ResponseControlPacketComplete(default_response_syn_packet_complete);

		out_packet_fwd = default_syn_packet_complete;
		out_packet_vc_fwd = 0;
		out_packet_accepted = default_syn_packet_complete;
		accepted_output_loaded = false;
		rejected_output_loaded = false;
		out_packet_available_csr = false;
		out_packet_available_ui = false;
		out_packet_available_fwd = false;
		accepted_vc_decoded = 0;
		rejected_vc_decoded = 0;

		for(int depth = 0; depth < 2; depth++){
			posted_packet_buffer_accepted[depth] = default_syn_packet_complete;
			posted_packet_wait_count_accepted[depth] = 0;
			posted_packet_buffer_accepted_loaded[depth] = false;
			posted_packet_buffer_accepted_nposted_refid[depth] = 0;
			posted_packet_buffer_accepted_response_refid[depth] = 0;

			nposted_packet_buffer_accepted[depth] = default_syn_packet_complete;
			nposted_packet_wait_count_accepted[depth] = 0;
			nposted_packet_buffer_accepted_loaded[depth] = false;
			nposted_packet_buffer_accepted_refid[depth] = 0;

			response_packet_buffer_accepted[depth] = default_response_syn_packet_complete;
			response_packet_wait_count_accepted[depth] = 0;
			response_packet_buffer_accepted_loaded[depth] = false;
			response_packet_buffer_accepted_refid[depth] = 0;

			posted_packet_buffer_rejected[depth] = default_syn_packet_complete;
			posted_packet_wait_count_rejected[depth] = 0;
			posted_packet_buffer_rejected_loaded[depth] = false;
			posted_packet_buffer_rejected_nposted_refid[depth] = 0;
			posted_packet_buffer_rejected_response_refid[depth] = 0;

			nposted_packet_buffer_rejected[depth] = default_syn_packet_complete;
			nposted_packet_wait_count_rejected[depth] = 0;
			nposted_packet_buffer_rejected_loaded[depth] = false;
			nposted_packet_buffer_rejected_refid[depth] = 0;

			response_packet_buffer_rejected[depth] = default_response_syn_packet_complete;
			response_packet_wait_count_rejected[depth] = 0;
			response_packet_buffer_rejected_loaded[depth] = false;
			response_packet_buffer_rejected_refid[depth] = 0;
		}

		registered_accepted_vc_decoded = 0;
		registered_rejected_vc_decoded = 0;
		registered_ack_rejected = false;
		registered_ack_accepted = false;
	}
	else{
		doFinalReorderingFWD();
		doFinalReorderingAccepted();
		updateBufferContent();

		registered_accepted_vc_decoded = accepted_vc_decoded;
		registered_rejected_vc_decoded = rejected_vc_decoded;
		registered_ack_rejected = ack[FWD_DEST].read();
		registered_ack_accepted = ack[UI_DEST].read() || ack[CSR_DEST].read();
	}
}

void final_reordering_l3::output_request(){
	posted_requested[ACCEPTED_DEST] = 
			 !((posted_packet_buffer_accepted_loaded[0].read() &&
			 posted_packet_buffer_accepted_loaded[1].read()) ||
				(fetched_packet_available[ACCEPTED_DEST].read() && 
				fetched_packet_vc[ACCEPTED_DEST].read() == VC_POSTED) && 
				(posted_packet_buffer_accepted_loaded[0].read() ^ 
				 posted_packet_buffer_accepted_loaded[1].read()));

	posted_requested[FWD_DEST] = 
			 !((posted_packet_buffer_rejected_loaded[0].read() &&
			 posted_packet_buffer_rejected_loaded[1].read()) ||
				(fetched_packet_available[FWD_DEST].read() && 
				fetched_packet_vc[FWD_DEST].read() == VC_POSTED) && 
				(posted_packet_buffer_rejected_loaded[0].read() ^ 
				 posted_packet_buffer_rejected_loaded[1].read()));

	nposted_requested[ACCEPTED_DEST] = 
			 !((nposted_packet_buffer_accepted_loaded[0].read() &&
			 nposted_packet_buffer_accepted_loaded[1].read()) ||
				(fetched_packet_available[ACCEPTED_DEST].read() && 
				fetched_packet_vc[ACCEPTED_DEST].read() == VC_NON_POSTED) && 
				(nposted_packet_buffer_accepted_loaded[0].read() ^ 
				 nposted_packet_buffer_accepted_loaded[1].read()));

	nposted_requested[FWD_DEST] = 
			 !((nposted_packet_buffer_rejected_loaded[0].read() &&
			 nposted_packet_buffer_rejected_loaded[1].read()) ||
				(fetched_packet_available[FWD_DEST].read() && 
				fetched_packet_vc[FWD_DEST].read() == VC_NON_POSTED) && 
				(nposted_packet_buffer_rejected_loaded[0].read() ^ 
				 nposted_packet_buffer_rejected_loaded[1].read()));

	response_requested[ACCEPTED_DEST] = 
			 !((response_packet_buffer_accepted_loaded[0].read() &&
			 response_packet_buffer_accepted_loaded[1].read()) ||
				(fetched_packet_available[ACCEPTED_DEST].read() && 
				fetched_packet_vc[ACCEPTED_DEST].read() == VC_RESPONSE) && 
				(response_packet_buffer_accepted_loaded[0].read() ^ 
				 response_packet_buffer_accepted_loaded[1].read()));

	response_requested[FWD_DEST] = 
			 !((response_packet_buffer_rejected_loaded[0].read() &&
			 response_packet_buffer_rejected_loaded[1].read()) ||
				(fetched_packet_available[FWD_DEST].read() && 
				fetched_packet_vc[FWD_DEST].read() == VC_RESPONSE) && 
				(response_packet_buffer_rejected_loaded[0].read() ^ 
				 response_packet_buffer_rejected_loaded[1].read()));
}

void final_reordering_l3::find_next_packet_buf_workaround(){
	//This function checks for the next packets to send.
	//Yes, this could be done in the registered process, but
	//the %!@$^% compiler to verilog generates invalid code
	//when done in the same process because it generates
	//unsized concatenations.  By forcing the result to
	//be in a signal, the right operation is done.

	////////////////////////////////////
	// Rejected
	////////////////////////////////////

    syn_ControlPacketComplete rc_packet_rejected_tmp;

	initialize_syn_ControlPacketComplete(rc_packet_rejected_tmp);
	if(response_packet_buffer_rejected_loaded[0].read()){
		rc_packet_rejected_tmp.packet.range(31,0) =  response_packet_buffer_rejected[0].read().packet;
		rc_packet_rejected_tmp.data_address = response_packet_buffer_rejected[0].read().data_address;
		rc_packet_rejected_maxwait_reached = response_packet_wait_count_rejected[0].read() == MAX_PASSPW_COUNT;
	}
	else{
		rc_packet_rejected_tmp.packet.range(31,0) =  response_packet_buffer_rejected[1].read().packet;
		rc_packet_rejected_tmp.data_address = response_packet_buffer_rejected[1].read().data_address;
		rc_packet_rejected_maxwait_reached = response_packet_wait_count_rejected[1].read() == MAX_PASSPW_COUNT &&
			response_packet_buffer_rejected_loaded[1].read();
	}
	rc_packet_rejected = rc_packet_rejected_tmp;

	// Select the posted packet
	if(posted_packet_buffer_rejected_loaded[0].read()){
		pc_packet_rejected =  posted_packet_buffer_rejected[0].read();
		pc_packet_rejected_maxwait_reached = posted_packet_wait_count_rejected[0].read() == MAX_PASSPW_COUNT;
	}
	else{
		pc_packet_rejected =  posted_packet_buffer_rejected[1].read();
		pc_packet_rejected_maxwait_reached = posted_packet_wait_count_rejected[1].read() == MAX_PASSPW_COUNT &&
			posted_packet_buffer_rejected_loaded[1].read();
	}

	// Select the non-posted packet
	if(nposted_packet_buffer_rejected_loaded[0].read()){
		npc_packet_rejected =  nposted_packet_buffer_rejected[0].read();
		npc_packet_rejected_maxwait_reached = posted_packet_wait_count_rejected[0].read() == MAX_PASSPW_COUNT;
	}
	else{
		npc_packet_rejected =  nposted_packet_buffer_rejected[1].read();
		npc_packet_rejected_maxwait_reached = posted_packet_wait_count_rejected[0].read() == MAX_PASSPW_COUNT &&
			nposted_packet_buffer_rejected_loaded[1].read();
	}

	////////////////////////////////////
	// Accepted
	////////////////////////////////////

    syn_ControlPacketComplete rc_packet_accepted_tmp;

	initialize_syn_ControlPacketComplete(rc_packet_accepted_tmp);
	if(response_packet_buffer_accepted_loaded[0].read()){
		rc_packet_accepted_tmp.packet.range(31,0) =  response_packet_buffer_accepted[0].read().packet;
		rc_packet_accepted_tmp.data_address = response_packet_buffer_accepted[0].read().data_address;
		rc_packet_accepted_maxwait_reached = response_packet_wait_count_accepted[0].read() == MAX_PASSPW_COUNT;
	}
	else{
		rc_packet_accepted_tmp.packet.range(31,0) =  response_packet_buffer_accepted[1].read().packet;
		rc_packet_accepted_tmp.data_address = response_packet_buffer_accepted[1].read().data_address;
		rc_packet_accepted_maxwait_reached = response_packet_wait_count_accepted[1].read() == MAX_PASSPW_COUNT &&
			response_packet_buffer_accepted_loaded[1].read();
	}
	rc_packet_accepted = rc_packet_accepted_tmp;

	if(posted_packet_buffer_accepted_loaded[0].read()){
		pc_packet_accepted =  posted_packet_buffer_accepted[0].read();
		pc_packet_accepted_maxwait_reached = posted_packet_wait_count_accepted[0].read() == MAX_PASSPW_COUNT;
	}
	else{
		pc_packet_accepted =  posted_packet_buffer_accepted[1].read();
		pc_packet_accepted_maxwait_reached = 
			posted_packet_wait_count_accepted[1].read() == MAX_PASSPW_COUNT &&
			posted_packet_buffer_accepted_loaded[1].read();
	}

	if(nposted_packet_buffer_accepted_loaded[0].read()){
		npc_packet_accepted =  nposted_packet_buffer_accepted[0].read();
		npc_packet_accepted_maxwait_reached = posted_packet_wait_count_accepted[0].read() == MAX_PASSPW_COUNT;
	}
	else{
		npc_packet_accepted = nposted_packet_buffer_accepted[1].read();
		npc_packet_accepted_maxwait_reached = posted_packet_wait_count_accepted[1].read() == MAX_PASSPW_COUNT &&
			nposted_packet_buffer_accepted_loaded[1].read();
	}

}


// Determine if the current buffer goes to the CSR
bool final_reordering_l3::request_goes_to_csr(const sc_bv<64> &pkt) const
{
	/** No need to check if the packet is upstream of if it was a 64 bit error
	since those cases were ruled out in the entrance reordering	*/
	sc_bv<16> csr_top_addr = "1111110111111110";
	sc_bv<16> pkt_top_addr = pkt.range(63,48);

	if (pkt_top_addr == csr_top_addr
			/* No need to check this either as this is also tested in the entrance reordering
			&& pkt.range(39,35) == unit_id.read()
			&& request_getCompatOrIsoc(pkt) == false*/)
		return true;
	else
		return false;
}

#ifndef SYSTEMC_SIM
#include "../core_synth/synth_control_packet.cpp"
#endif

