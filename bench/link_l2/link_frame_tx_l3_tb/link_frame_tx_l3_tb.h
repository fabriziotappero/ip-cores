//link_frame_tx_l3_tb.h
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

#ifndef LINK_FRAME_TX_L3_TB_H
#define LINK_FRAME_TX_L3_TB_H

#include <queue>
#include "../../../rtl/systemc/core_synth/synth_datatypes.h"
#include "../../../rtl/systemc/core_synth/constants.h"
#include "link_tx_validator.h"

///Testbench for the link_frame_tx_l3 module
/**
	@class link_frame_tx_l3_tb
	@author Ami Castonguay
	@description 
		Using the link_tx_validator to verify that received
		traffic is correct, this testbench setups different sequences 
		to test the transmission and initialization of the TX part of the
		link
*/
class link_frame_tx_l3_tb : public sc_module {

public:
	///Main system clock
	sc_in<bool >		clk;

	///CTL bits sent by the TX link
	sc_in<sc_bv<CAD_OUT_DEPTH> >	lk_ctl_phy;
	///CAD bits sent by the TX link
	sc_in<sc_bv<CAD_OUT_DEPTH> >	lk_cad_phy[CAD_OUT_WIDTH];
	///If the TX link disables the drives
	sc_in<bool >	disable_drivers;
	///If the data to frame sent to the TX is consumed
	sc_in<bool>		tx_consume_data;


	/**
	Link widths
	
	000 8 bits 
	100 2 bits 
	101 4 bits 
	111  Link physically not connected 
	*/
	///The link width for the RX side
	sc_out<sc_bv<3> >	csr_tx_link_width_lk;
	///If this is the last element of the chain
	sc_out<bool >		csr_end_of_chain;

	///Link commands a ltdstop disconnect
	sc_out<bool>		ldtstop_disconnect_tx;
	///If RX side is still waiting for CTL to be activated
	sc_out<bool>		rx_waiting_for_ctl_tx;

	///Reset of the system
	sc_out<bool>			resetx;
	///If the power is stable (to do a cold reset)
	sc_out<bool>			pwrok;
	///For LDTSTOP sequence (power saving)
	sc_out<bool>			ldtstopx;

	///If we consume the CTL and CAD signals
	sc_out<bool>		phy_consume_lk;
	///Data to frame and to sent on the link
	sc_out<sc_bv<32> >	cad_to_frame;
	///LCTL to grame and send on the link
	sc_out<bool>		lctl_to_frame;
	///HCTL to grame and send on the link
	sc_out<bool >		hctl_to_frame;

#ifdef RETRY_MODE_ENABLED
	///The flow control asks us to disconnect the link
	sc_out<bool>			fc_disconnect_lk;
#endif

	///SystemC Macro
	SC_HAS_PROCESS(link_frame_tx_l3_tb);

	///Module that validates the input received from TX link
	link_tx_validator * validator;

	///Constructor
	link_frame_tx_l3_tb(sc_module_name name);

	///Create sequences of events to test the link
	void stimulate_inputs();

	///Reset the testbench to an initial state 
	void init();

	///Desctructor
	~link_frame_tx_l3_tb(){delete validator;}

};

#endif
