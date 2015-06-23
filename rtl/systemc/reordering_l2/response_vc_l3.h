//response_vc_l3.h

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

#ifndef RESPONSE_VC_L3_H
#define RESPONSE_VC_L3_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"


/// Response Virtual Channel
/** Used for Response Command (RC)
	This module stores and reorganizes response packets.
	The most important/recent packet is sent to the output buffer when
	it is free.
*/
class response_vc_l3: public sc_module
{
public:
	/// The Clock
	sc_in<bool> clk;

	/// Reset signal
	/** Warm_Reset and Cold_Reset does the same thing*/
	sc_in<bool> resetx;

	//***********************************
	// Interface with nopHandler
	//***********************************
	sc_out<sc_bv<2> > buffers_cleared;

	//***********************************
	// Interface with Final_Reordering module
	//***********************************

	/// Most important packet in the VC for the 3 destinations
	sc_out<sc_uint<LOG2_NB_OF_BUFFERS> > out_packet_addr[2];
#ifdef ENABLE_REORDERING
	sc_out<bool > out_packet_passpw[2];
#endif
	/// Indicates that a packet is available for the destinations
	sc_out<bool> packet_available[2];

	/** Even if a packet is selected as the most important in the current VC,
	it doesn't means it will be the one selected between the 3 VCs. Thus, an
	acknowledge signal is received whenever the packet chosen for the corresponding
	module (CSR, User, FC) is sent.*/
	sc_in<bool> acknowledge[2];


	//***********************************
	// Interface with Entrance_Reordering module
	//***********************************

	/// Entrance packet
	sc_in<sc_uint<LOG2_NB_OF_BUFFERS> > in_packet_addr;

#ifdef ENABLE_REORDERING
	sc_in<bool > in_packet_passpw;
#endif

	/// Indicates that a packet is available on the New_Packet port
	sc_in<bool>					 in_packet_destination[2];
	//All the buffers are filled with packets
	sc_out<bool>					vc_overflow;

	//***********************************
	// Interface with CSR
	//***********************************

#ifdef ENABLE_REORDERING
	/// this flag disables the reordering
	/**See chapter 7.5.10.6 of hyperTransport specs 1.10*/
	sc_in<bool> unitid_reorder_disable;
#endif

	//***********************************
	// intern Signals
	//***********************************

	///Buffers containing the destination of a packet (no destionation == no valid packet)
	sc_signal<sc_bv<2> > destination_registers[NB_OF_BUFFERS];
	///Buffers containing the packet
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS> > packet_addr_register[NB_OF_BUFFERS];

#ifdef ENABLE_REORDERING
	///Buffers containing the destination of a packet (no destionation == no valid packet)
	sc_signal<bool > packet_passpw_register[NB_OF_BUFFERS];

	///The number of time a packet is passed.
	/**A limit to the number of time a packet can be passed is set so that packet
	   with passPW unasserted do not get stuck indefinitely in the buffers.*/
	sc_signal<sc_uint<MAX_PASSPW_P1_LOG2_COUNT+1> >	pass_count[NB_OF_BUFFERS];


	///If packets should be compared with the higher packet (or the low one)
	/** When packets are reordered, they need to be compared.  To limit the
		combinatorial path, not all packets can be compared at the same time.
		There is one comparator for every two packet and one cycle, the comparator
		compares it's packet to the lower packet, and the next cycle to the higher
		packet.  This bit holds if it should compare with higher or not, and it is
		toggled every clock cycle
	*/
	sc_signal<bool> compare_with_higher;
#endif

	//Packet selected to be output to accepted destination
	sc_signal<sc_bv<NB_OF_BUFFERS> > 	selected_accepted;
	//Packet selected to be output to forward destination
	sc_signal<sc_bv<NB_OF_BUFFERS> > 	selected_forward;

public:

	///SystemC Macro
	SC_HAS_PROCESS(response_vc_l3);

	///Takes the top packets selected and outputs them 
	/**
		@description Will only output the found accepted and forward packet if there 
			is no packet currently being outputed or if the current packet is consumed
		@param selected_accepted The packet selected to be output to accepted destination
			(the position is one-hot encoded)
		@param selected_accepted_found A packet was found to be output to accepted destination
		@param selected_forward The packet selected to be output to forward destination
			(the position is one-hot encoded)
		@param selected_forward_found A packet was found to be output to forward destination
	*/
	void drive_output(sc_bv<NB_OF_BUFFERS> selected_accepted,
								bool selected_accepted_found,
								sc_bv<NB_OF_BUFFERS> selected_forward,
								bool selected_forward_found);
	///Manages the internal buffers, new packets, deleted packets and reordering
	/**
		@param selected_accepted The packet selected to be output to accepted destination
			(the position is one-hot encoded)
		@param selected_forward The packet selected to be output to forward destination
			(the position is one-hot encoded)
	*/
	void update_internal_registers();

	///Clocked process (only process of the module) and reset
	void clocked_process();

#ifdef ENABLE_REORDERING
	///Evaluate if two packet should be switched
	bool evaluate_switch_packets(bool high_passPW,bool low_passPW,
					bool high_buffer_free,bool low_buffer_free,
				    sc_uint<MAX_PASSPW_P1_LOG2_COUNT> high_pass_count,
					   sc_uint<MAX_PASSPW_P1_LOG2_COUNT> low_pass_count,
					bool compare_with_higher);
#endif

	///Selects from the buffers the most important packet to output for forward and accepted
	/**
		@param selected_accepted The packet selected to be output to accepted destination
			(return by address)
		@param selected_accepted_found A packet was found to be output to accepted destination
			(return by address)
		@param selected_forward The packet selected to be output to forward destination
			(return by address)
		@param selected_forward_found A packet was found to be output to forward destination
			(return by address)
	*/
	void select_top_packet(sc_bv<NB_OF_BUFFERS> &selected_accepted,
								bool &selected_accepted_found,
								sc_bv<NB_OF_BUFFERS> &selected_forward,
								bool &selected_forward_found);

	/**
		Method that select the packet with the most priority and outputs it.
	*/
	void select_and_drive_output();

	/// Basic constructor
	response_vc_l3(sc_module_name name);

#ifdef SYSTEMC_SIM
	~response_vc_l3();
#endif

};

#endif

