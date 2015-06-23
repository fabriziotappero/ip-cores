//fetch_packet_l3.h
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

#ifndef FETCH_PACKET_L3_H
#define FETCH_PACKET_L3_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"

///Fetches complete packets from embedded memory
/** 
	@description To minimize the number of flip-flops
		necessary in the buffers, most of the fields of
		packets are stored in an embedded memory and only
		a pointer to that data is reorganized in the buffers.
		
		This module takes that pointer, fetches the data and
		reconstructs the original packet that was received
		by the entrance_reordering_l3 module.

	@author Ami Castonguay

*/
class fetch_packet_l3: public sc_module
{
public:
	///////////////////////////////////
	// Clock and resetx
	///////////////////////////////////
	///System clock
	sc_in<bool> clk;
	///System reset (active low)
	sc_in<bool> resetx;

	///////////////////////////////////
	// Inputs
	///////////////////////////////////
	
	///Packet from posted buffers
	//@{
	sc_in<sc_uint<LOG2_NB_OF_BUFFERS> > posted_packet_addr[2];
#ifdef ENABLE_REORDERING
	sc_in<bool > posted_packet_passpw[2];
	sc_in<sc_uint<4> > posted_packet_seqid[2];
	sc_in<bool > posted_packet_chain[2];
	sc_in<sc_uint<LOG2_NB_OF_BUFFERS+1> >	posted_packet_nposted_refid[2];
	sc_in<sc_uint<LOG2_NB_OF_BUFFERS+1> >	posted_packet_response_refid[2];
#endif
	sc_in<bool> posted_available[2];
	//@}

	//Packet from nposted buffers
	//@{
	sc_in<sc_uint<LOG2_NB_OF_BUFFERS> > nposted_packet_addr[2];
#ifdef ENABLE_REORDERING
	sc_in<bool > nposted_packet_passpw[2];
	sc_in<sc_uint<4> > nposted_packet_seqid[2];
#endif
	sc_in<bool> nposted_available[2];
	//@}

	///Packet from response buffers
	//@{
	sc_in<sc_uint<LOG2_NB_OF_BUFFERS> > response_packet_addr[2];
#ifdef ENABLE_REORDERING
	sc_in<bool > response_packet_passpw[2];
#endif
	sc_in<bool> response_available[2];
	//@}

	///Data from memory
	sc_in<sc_bv<CMD_BUFFER_MEM_WIDTH> > command_packet_rd_data_ro[2];

	///Packet types requested
	sc_in<bool> posted_requested[2];
	sc_in<bool> nposted_requested[2];
	sc_in<bool> response_requested[2];

	///////////////////////////////////
	// Outputs
	///////////////////////////////////
	///If posted packets are being consumed
	sc_out<bool> ack_posted[2];
	///If nposted packets are being consumed
	sc_out<bool> ack_nposted[2];
	///If response packets are being consumed
	sc_out<bool> ack_response[2];

	///Address to retrieve data from memory
	sc_out<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro_command_packet_rd_addr[2];

	///The fetched retrieved packet (for both destinations)
	sc_out<syn_ControlPacketComplete> fetched_packet[2];
	///If there is a fetched packet available (for both destinations)
	sc_out<bool> fetched_packet_available[2];
	///The virtual channel of the fetched packet (for both destinations)
	sc_out<VirtualChannel> fetched_packet_vc[2];

	///The nposted refid for packet fetched  (order it arrived relative to posted packets) (for both destinations)
	sc_out<sc_uint<LOG2_NB_OF_BUFFERS+1> > fetched_packet_nposted_refid[2];
	///The response refid for packet fetched  (order it arrived relative to posted packets) (for both destinations)
	sc_out<sc_uint<LOG2_NB_OF_BUFFERS+1> > fetched_packet_response_refid[2];

	////////////////////////////////////
	// Registers
	////////////////////////////////////
#ifdef ENABLE_REORDERING
	/**
		Selected packets are deleted in the actual buffers immediately, but the data
		from the memory only arrives a cycle later.  So for that cycle, packet data
		from the VC's are stored in registers
	*/
	///Passpw value of the packet
	sc_signal<bool > packet_passpw[2];
	///SeqID value of the packet
	sc_signal<sc_uint<4> > packet_seqid[2];
	///chain value of the packet
	sc_signal<bool > packet_chain[2];
#else
	///If we are in the middle of a chain
	/** When reordering is active, the chain bit needs to be identified
		when it arrives in the buffers because it affects the reordering
		rules.  But when reordering is no activated, we can wait to 
		calculate it until after the buffers.  Actually, it could probably
		be calculated even later and save a tad bit of resources, but doing
		it here is easy to implement and to understand.

		This is to know if a packet is part of a chain (produced from the
		chain field of the packet).
	*/
	sc_signal<bool > currently_posted_chain[2];
#endif

	///Virtual channel of the packet
	sc_signal<VirtualChannel> packet_vc[2];
	///If there was a packet fetched of the packet
	sc_signal<bool> packet_fetched[2];

	////////////////////////////////////
	// Misc signals
	////////////////////////////////////

	///Inter-process communication - the virtual channel of the packet selected
	sc_signal<VirtualChannel> selected_vc[2];
	///If there was a packet that was selected
	sc_signal<bool> packet_selected[2];

	////////////////////////////////////
	// Processes and consctructor
	////////////////////////////////////

	///Select a packet to extract from the buffers and ack it
	void select_and_ack_packet();
	///Handle everything that is registered
	void register_signals();
	///Once data arrives from the memory, the final packet must be reconstructed
	/**
		Some fields of packets that are sent to the virtual
		channels buffers (registers) because they are needed to evaluate
		reordering rules.  Because those bits are stored in registers, there is
		no need to store them in the memory too, so the position of these bits
		are re-used for other applications
	*/
	void reconstruct_packet();

	///SystemC Macro
	SC_HAS_PROCESS(fetch_packet_l3);

	///Consctructor
	fetch_packet_l3(sc_module_name name);

#if SYSTEMC_SIM
	///Destructor
	virtual ~fetch_packet_l3(){}
#endif
};

#endif

