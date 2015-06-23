//misc_logic_l2.h

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
 *   Michel Morneau
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


#ifndef MISC_LOGIC_L2_H
#define MISC_LOGIC_L2_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"

/**
	@description The goal of this module is to handle any logic that doesn't 
	really fitanywhere and to avoid putting in the top module in order to keep
	things clean.  You could also call this a "glue logic" module.  At this
	moment, the module includes:
	   - UnitID clumping logic
	   - Frequency changing logic
	   - Glue logic (ldtstopx registering)

   UnitID clumping logic. 
   ======================
   
   When reordering packets, we must take into account
   that some packets can not pass other packets when they are from the same
   UnitID.  But some UnitIDs can be "clumped" together so that two distinct
   unitID values represent the same logical unitID.  
   
   In the CSR, there is a vector that holds what unitIDs are clumped together.
   The logic here takes that vector and tranforms it into 32 number that
   the clumped unitID value for every individual real unitID.


   Frequency changing logic
   ========================

   The system always starts at a frequency of 200 MHz, that will most often
   be changed to a faster frequency later on.  The frequency is set in a
   register of the CSR, but it does not take effect immediately, we must
   wait for either 2us after resetx is asserted or when we are disconnected
   in an ldtstop sequence.

   This module takes the output from the CSR, the reset and the disconnected
   signal from the link and updates the value of the frequency sent to the 
   output of the tunnel for the circuit handling the clocking.

   @author Ami Castonguay
*/
class misc_logic_l2 : public sc_module{
	
public:

	///Main clock signal
	sc_in<bool> clk;

	///Warm reset
	sc_in<bool> resetx;

	///Cold reset
	sc_in<bool> pwrok;

	///LDTSTOP sequence
	sc_in<bool> ldtstopx;

	///When the link is completely disconnected for LDTSTOP (side 0)
	sc_in<bool> lk0_ldtstop_disconnected;
	///When the link is completely disconnected for LDTSTOP (side 0)
	sc_in<bool> lk1_ldtstop_disconnected;

	///Frequency set in the CSR for side 0
	sc_in<sc_bv<4> > csr_link_frequency0;
	///Frequency set in the CSR for side 1
	sc_in<sc_bv<4> > csr_link_frequency1;

	///Frequency requested to clocking logic for side 0
	sc_out<sc_bv<4> > link_frequency0_phy;
	///Frequency requested to clocking logic for side 1
	sc_out<sc_bv<4> > link_frequency1_phy;

	///Contains what unitIDs should be clumped
	sc_in<sc_bv<32> > csr_clumping_configuration;

	///Second of two registers to store ldtstopx
	sc_out<bool> registered_ldtstopx;

#ifdef ENABLE_REORDERING
	/// Calculated clumping configuration
	sc_out<sc_bv<5> > clumped_unit_id[32];
#else
	/// Calculated clumping configuration
	sc_out<sc_bv<5> > clumped_unit_id[4];
#endif

	//////////////////////////////////
	// Signals for frequency changing
	//////////////////////////////////

	///A counter to know when 2us has elapsed
	sc_signal<sc_uint<NUMBER_BITS_REPRESENT_2US> > freq_counter;

	//////////////////////////////////
	// Signals for glue logic
	//////////////////////////////////

	///First of two registers to store ldtstopx
	sc_signal<bool> registered1_ldtstopx;



	///SystemC Macro
	SC_HAS_PROCESS(misc_logic_l2);

	///Module constructor
	misc_logic_l2(sc_module_name name);

	///Process that handles changing frequency
	void change_frequency_process();

	/// Some flip-flops for various signals like ldtstopx
	void register_signals();

	/// Calculation of clumped unit IDs
	/**
		UnitID represents devices in the chain.  But each unitID can only initiate
		32 non-posted transactions on the chain at one time.  To circumvent this
		limitation, devices can requests multiples UnitIDs.  Usually, traffic from
		different Unit ID's have no ordering rules between them, which can cause
		problem for a device that has mutltiple unitID's.  To solve this problem,
		unitID's can be "clumped" together to represent the same device so that
		ordering rules are respected for "clumped" unit ID's.

		The CSR contains the clumping configuration and this process converts it
		into 32 5-bit vectors which represent the "clumped" unitID represented
		by the 32 non-clumped unitIDs.  This can then be used by both side of
		the tunnel to enforce ordering rules.
	*/
	void find_clumped_ids();

#ifdef SYSTEMC_SIM
	~misc_logic_l2(){}
#endif

};

#endif
