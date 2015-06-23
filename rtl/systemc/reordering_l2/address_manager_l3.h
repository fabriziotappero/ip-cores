//address_manager_l3.h

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

#ifndef ADDRESS_MANAGER_l3_L3_H
#define ADDRESS_MANAGER_l3_L3_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"


/// Manages available addresses for command buffers
/** Command packets are stored in embedded memories but must be retrieved out
	of order.  This module manages what locations in the memory are available,
	issues addresses when a new packet is sent to the buffers and frees
	memory locations where packets are retrieved
*/
class address_manager_l3: public sc_module
{
public:

	///////////////////////////////////
	// Clock and reset
	///////////////////////////////////
	///Clock signal
	sc_in<bool>	clk;
	///Reset signal (active low)
	sc_in<bool> resetx;

	////////////////////////////////////
	// Inputs and outputs
	////////////////////////////////////
	///When asserted, the address at the output is used to write a new packet
	sc_in<bool> use_address;
	///If a packet is available for the three VCs
	sc_in<bool> new_packet_available[3];

	///The address of the first free buffer of the VC of the packet that arrives (new_packet_available)
	/**
		Equivalent to ro_command_packet_wr_addr but includes two bits of address for the VC in the mem
	*/
	sc_out<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro_command_packet_wr_addr;
	///The address of the first free buffer of the VC of the packet that arrives (new_packet_available)
	/**
		Address bits only within a VC
	*/
	sc_out<sc_uint<LOG2_NB_OF_BUFFERS> > new_packet_addr;

	///Address to memory being read
	/**
		Two read ports : one for accepted packet and the other for non-accepted
	*/
	sc_in<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro_command_packet_rd_addr[2];

	/// When a memory position is freed and cleared
	/**
		When a packet position is read, it does not immediately mean that the packet is being consumed,
		or if it is, it might need to be consumed twice (Broadcast are both accepted and non-accepted).
		These bits come from the three VCs (hence the array of 3) and the two bits represent both
		accepted and non-accepted destinations.
	*/
	sc_in<sc_bv<2> > buffers_cleared[3];

	////////////////////////////////////
	// Registers
	////////////////////////////////////

	///What memory locations are used
	sc_signal<bool> buffer_used[3][NB_OF_BUFFERS];

	//Last value of the lower read address bits
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS> > last_lower_rd_addr[2];

	////////////////////////////////////
	// Misc
	////////////////////////////////////
	///Interprocess signal : the first buffer that is free, one hot encoded
	sc_signal<sc_uint<NB_OF_BUFFERS> > first_free_one_hot[3];
		
	///SystemC Macro
	SC_HAS_PROCESS(address_manager_l3);

	///Constructor
	address_manager_l3(sc_module_name name);

	///Process to update all registers
	void clocked_process();

	///Process that finds the first free buffer and encodes it
	void find_first_free_buffers();

	///Process that takes the first free buffer and outputs it to a write adderss
	void output_write_address();

#ifdef SYSTEMC_SIM
	///Desctructor
	virtual ~address_manager_l3(){}
#endif

};

#endif

