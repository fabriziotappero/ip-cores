//final_reordering_l3.h
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

#ifndef FINAL_REORDERING_L3_H
#define FINAL_REORDERING_L3_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"

/*
	bit 5 = There is space in the PC VC
	bit 4 = There is space in the PC data VC
	bit 3 = There is space in the NPC VC
	bit 2 = There is space in the NPC data VC
	bit 1 = There is space in the R VC
	bit 0 = There is space in the R data VC
*/

#define BIT_PC_FREE 5
#define BIT_PC_FREE_DATA 4
#define BIT_NPC_FREE 3
#define BIT_NPC_FREE_DATA 2
#define BIT_RC_FREE 1
#define BIT_RC_FREE_DATA 0
     

/// Sends the most important packet to the User, CSR and FC
/** This module is the last module of Reordering.  All virtual
	channels are sending use their highest priority packet for
	every destination.  This last modules chooses one packet
	for every distination*/
class final_reordering_l3 : public sc_module
{

public:
	///Main clock of the system
	sc_in<bool> clk;
	///Low logic reset signal
	sc_in<bool> resetx;
	


	//***********************************
	// Control signal from Flow Control 
	//***********************************

	/// Contains information about the Command buffers of the upper module. 
	/**A set bit indicates:
	bit 5 = There is space in the PC VC
	bit 4 = There is space in the PC data VC
	bit 3 = There is space in the NPC VC
	bit 2 = There is space in the NPC data VC
	bit 1 = There is space in the R VC
	bit 0 = There is space in the R data VC
	A command packet cannot be sent if ther is room in both data and command 
	buffers of the upper module*/
	sc_in<sc_bv<6> > fwd_next_node_buffer_status_ro;//24


	//***********************************
	// Interface with VCs
	//***********************************

	/// Packets Received from the differents VCs. 
	/** The most important packet is then chosen for each output modules.
	YY_Packet_XX -> YY means the VC that sends the packet, XX the destination
	of the packet*/
	sc_in<syn_ControlPacketComplete> fetched_packet[2];

	//Decoded virtual channel of the fetched packet
	sc_in<VirtualChannel> fetched_packet_vc[2];

	/// Indicates if a packet is available on the input packet signal	
	sc_in<bool> fetched_packet_available[2];

	sc_in<sc_uint<LOG2_NB_OF_BUFFERS+1> > fetched_packet_nposted_refid[2];
	sc_in<sc_uint<LOG2_NB_OF_BUFFERS+1> > fetched_packet_response_refid[2];

	/// Request the different types of packets from the VCs
	/** */
	//@{
	sc_out<bool> posted_requested[2];
	sc_out<bool> nposted_requested[2];
	sc_out<bool> response_requested[2];
	//@}

	//***********************************
	// Interface with CSR, User and FC
	//***********************************

	sc_out<syn_ControlPacketComplete> out_packet_accepted;
	/// Packet sent to the FC module
	sc_out<syn_ControlPacketComplete> out_packet_fwd;
	sc_out<VirtualChannel> out_packet_vc_fwd;

	/// Indicates if a packet is available on the CSR output port
	sc_out<bool> out_packet_available_csr;
	/// Indicates if a packet is available on the User output port
	sc_out<bool> out_packet_available_ui;
	/// Indicates if a packet is available on the FC output port
	sc_out<bool> out_packet_available_fwd;

	/// Acknowledge signal form the CSR, User and FC modules
	/** Indicates if the sent packet will be consummed by the module
		If the Acknowledge signal is not set, the packet will not be consummed and thus
		must stay in the VC.*/
	sc_in<bool> ack[3];

	/**If the cd is currently receiving data.  This is used to know if a packet
		that has associated data can be sent*/
	sc_in<bool>						cd_data_pending_ro;
	/**Where the cd is storing data.   This is used to know if a packet
		that has associated data can be sent*/
	sc_in<sc_uint<BUFFERS_ADDRESS_WIDTH> >	cd_data_pending_addr_ro;
	
	///If we are currently in sync mode
	sc_in<bool> csr_sync;
	
	/**
		Register what was done last cycle
	*/
	sc_signal<sc_bv<3> > registered_accepted_vc_decoded;
	sc_signal<sc_bv<3> > registered_rejected_vc_decoded;
	sc_signal<bool> registered_ack_rejected;
	sc_signal<bool> registered_ack_accepted;

	
	/**
		With two buffers, it is possible to send a packet every TWO cycles.  If
		we try to output a packet every cycle, we might empty a buffer of a
		vc.  This MUST NOT happen or we might break an ordering rule.  To output
		a packet every cycle, buffers must have a depth of 3 (at least the posted
		VC needs it)!
	*/

	sc_signal<syn_ControlPacketComplete> posted_packet_buffer_accepted[2];
	sc_signal<sc_uint<MAX_PASSPW_P1_LOG2_COUNT> > posted_packet_wait_count_accepted[2];
	sc_signal<bool> posted_packet_buffer_accepted_loaded[2];
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> > posted_packet_buffer_accepted_nposted_refid[2];
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> > posted_packet_buffer_accepted_response_refid[2];

	sc_signal<syn_ControlPacketComplete> nposted_packet_buffer_accepted[2];
	sc_signal<sc_uint<MAX_PASSPW_P1_LOG2_COUNT> > nposted_packet_wait_count_accepted[2];
	sc_signal<bool> nposted_packet_buffer_accepted_loaded[2];
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> > nposted_packet_buffer_accepted_refid[2];

	sc_signal<syn_ResponseControlPacketComplete> response_packet_buffer_accepted[2];
	sc_signal<sc_uint<MAX_PASSPW_P1_LOG2_COUNT> > response_packet_wait_count_accepted[2];
	sc_signal<bool> response_packet_buffer_accepted_loaded[2];
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> > response_packet_buffer_accepted_refid[2];

	/// Packet sent to the FC module
	sc_signal<syn_ControlPacketComplete> posted_packet_buffer_rejected[2];
	sc_signal<sc_uint<MAX_PASSPW_P1_LOG2_COUNT> > posted_packet_wait_count_rejected[2];
	sc_signal<bool> posted_packet_buffer_rejected_loaded[2];
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> > posted_packet_buffer_rejected_nposted_refid[2];
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> > posted_packet_buffer_rejected_response_refid[2];

	sc_signal<syn_ControlPacketComplete> nposted_packet_buffer_rejected[2];
	sc_signal<sc_uint<MAX_PASSPW_P1_LOG2_COUNT> > nposted_packet_wait_count_rejected[2];
	sc_signal<bool> nposted_packet_buffer_rejected_loaded[2];
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> > nposted_packet_buffer_rejected_refid[2];

	sc_signal<syn_ResponseControlPacketComplete> response_packet_buffer_rejected[2];
	sc_signal<sc_uint<MAX_PASSPW_P1_LOG2_COUNT> > response_packet_wait_count_rejected[2];
	sc_signal<bool> response_packet_buffer_rejected_loaded[2];
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+1> > response_packet_buffer_rejected_refid[2];

	
	sc_signal<bool> rejected_output_loaded;
	sc_signal<bool> accepted_output_loaded;
	
	///If there is a valid packet in the accepted output register
	sc_signal<sc_bv<3> > accepted_vc_decoded;
	///If there is a valid packet in the forward output register
	sc_signal<sc_bv<3> > rejected_vc_decoded;


    sc_signal<syn_ControlPacketComplete> rc_packet_rejected;
    sc_signal<bool> rc_packet_rejected_maxwait_reached;
    sc_signal<syn_ControlPacketComplete> pc_packet_rejected;
    sc_signal<bool> pc_packet_rejected_maxwait_reached;
    sc_signal<syn_ControlPacketComplete> npc_packet_rejected;
    sc_signal<bool> npc_packet_rejected_maxwait_reached;

    sc_signal<syn_ControlPacketComplete> rc_packet_accepted;
    sc_signal<bool> rc_packet_accepted_maxwait_reached;
    sc_signal<syn_ControlPacketComplete> pc_packet_accepted;
    sc_signal<bool> pc_packet_accepted_maxwait_reached;
    sc_signal<syn_ControlPacketComplete> npc_packet_accepted;
    sc_signal<bool> npc_packet_accepted_maxwait_reached;

	void clocked_process();
	///Choose the packet to be sent to the CSR/CSR
	void doFinalReorderingAccepted();
	///Choose the packet to be sent to the FWD/EH
	void doFinalReorderingFWD();

	void updateBufferContent();
	void output_request();
	
	///Verify if an accepted packet goes to the CSR
	/**
		@param pkt The packet to check
		@return true if the accepted packet goes to CSR
	*/
	bool request_goes_to_csr(const sc_bv<64> &pkt) const;

	void find_next_packet_buf_workaround();

	//SystemC Macro
	SC_HAS_PROCESS(final_reordering_l3);

	/// Main constructor.
	final_reordering_l3(sc_module_name name);

};


#endif

