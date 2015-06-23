//link_frame_rx_l3_tb.h
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

#ifndef LINK_FRAME_RX_L3_TB_H
#define LINK_FRAME_RX_L3_TB_H

#include "../../../rtl/systemc/core_synth/synth_datatypes.h"
#include "../../../rtl/systemc/core_synth/constants.h"
#include <queue>

///struct regrouping dword and CTL values to send on link
struct LinkTransmission{
	sc_bv<32>	dword;
	bool		lctl;
	bool		hctl;
};

//Forward declaration
class link_rx_transmitter;

///Testbench for the link_frame_rx_l3 module
/**
	@class link_frame_rx_l3_tb
	@author Ami Castonguay
	@description 
		Using the link_rx_transmitter to send traffic, this
		testbench setups different sequences to test the
		reception and initialization of the RX part of the
		link

		There are multiple signals coming from the link
		that must be verified.  To verify them, member variables
		named expect_* are used.  These expect variables are
		ints.  When the variable is supposed to be false, it is
		0.  When it should be 1, it has the value of 1. When the
		variable is 0 and is expected to become 1 within n cycles, it has
		the value n.  When it is 1 and is expected to become
		0 within n cycles, it takes the value of -n.

*/
class link_frame_rx_l3_tb : public sc_module{

public:

	///Main clock of the system
	sc_in<bool >					clk;

	///CTL value sent to the HT tunnel
	sc_out<sc_bv<CAD_IN_DEPTH> >	phy_ctl_lk;
	/** Every element of the array represent one input of the tunnel
		that was deserialized to a factor of CAD_IN_DEPTH*/
	sc_out<sc_bv<CAD_IN_DEPTH> >	phy_cad_lk[CAD_IN_WIDTH];
	///If CAD and CTL values are available to be consumed
	/** True when a dword is sent through the transmitter, false
		otherwise*/
	sc_out<bool>					phy_available_lk;
	///Allows to disable receivers to save power and prevent problems when driver is tristate
	sc_in<bool>						lk_disable_receivers_phy;

	///The framed cad bits produced by the link_frame_rx_l3
	sc_in<sc_bv<32> >				framed_cad;
	///The framed lctl produced by the link_frame_rx_l3
	sc_in<bool>						framed_lctl;
	///The framed hctl produced by the link_frame_rx_l3
	sc_in<bool >					framed_hctl;
	///If there is framed data available
	sc_in<bool>						framed_data_available;
	///If the RX part of the link is connected
	sc_in<bool>						lk_rx_connected;

	///Reset signal
	sc_out<bool>					resetx;
	///PowerOK signal (cold reset and to sample the link)
	sc_out<bool>					pwrok;
	///If in a LDTSTOP sequence (power saving mode)
	sc_out<bool>					ldtstopx;

	/**
	Link widths
	
	000 8 bits 
	100 2 bits 
	101 4 bits 
	111  Link physically not connected 
	*/
	sc_out<sc_bv<3> >	csr_rx_link_width_lk;

	///If we are the last element of the chain (input should be ignored)
	sc_out<bool >		csr_end_of_chain;
	///If we are in a sync flood (input should be ignored)
	sc_out<bool >		csr_sync;
	///If the timout period before generating a CTL low error is extended
	sc_out<bool >		csr_extended_ctl_timeout_lk;

	///To update the link width registered in the CSR with the new value
	sc_in<bool>			lk_update_link_width_csr;
	///The link width that is being sampled
	sc_in<sc_bv<3> >	lk_sampled_link_width_csr;

	
	///Update the link failure flag in CSR with the lk_link_failure_csr signal
	sc_in<bool>		lk_update_link_failure_property_csr;
	///This signal should only be evaluated at lk_update_link_failure_property_csr
	sc_in<bool>		lk_link_failure_csr;

	///Link commands a ltdstop disconnect
	sc_out<bool>	ldtstop_disconnect_rx;

#ifdef RETRY_MODE_ENABLED
	///If we are in retry mode
	sc_out<bool>			csr_retry;
	///Start a retry sequence
	sc_in<bool>		lk_initiate_retry_disconnect;
	///Command decoder commands a retry disconnect
	sc_out<bool>			cd_initiate_retry_disconnect;
#endif

	///If a transition error in the CTL input was detected
	sc_in<bool>		ctl_transition_error;
	///Active when the RX part is waiting for the CTL to become asserted
	sc_in<bool>		rx_waiting_for_ctl_tx;

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	///High speed deserializer should stall shifting bits for lk_deser_stall_cycles_phy cycles
	/** Cannot be asserted with a lk_deser_stall_cycles_phy value of 0*/
	sc_in<bool > lk_deser_stall_phy;
	///Number of bit times to stall deserializing incoming data when lk_deser_stall_phy is asserted
	sc_in<sc_uint<LOG2_CAD_IN_DEPTH> > lk_deser_stall_cycles_phy;
#endif

	///The transmitter module that formats the traffic
	link_rx_transmitter * transmitter;
	///Framed transmissions that we are expected to receive
	std::queue< LinkTransmission >	expected_transmission;

	///Expected behavior of lk_rx_connected
	int expect_connected;
	///Expected behavior of lk_disable_receivers_phy
	int expect_disable_receivers_phy;


	///Expected behavior of lk_update_link_width_csr
	int expect_link_width_update;
	///Expected value of lk_sampled_link_width_csr when update becomes true
	sc_bv<3> expected_link_width;

	///Expected behavior of lk_link_failure_csr
	int expect_link_failure;
	///Expected behavior of ctl_transition_error
	int expect_ctl_transition_error;
	///Expected behavior of lk_initiate_retry_disconnect
	int expect_lk_initiate_retry_disconnect;

	///If the value of the received framed data is verified from expected list
	bool check_dword_reception;


	///SystemC Macro
	SC_HAS_PROCESS(link_frame_rx_l3_tb);

	///Constructor
	link_frame_rx_l3_tb(sc_module_name name);

	///Generates traffic to test the design
	void stimulate_inputs();

	///Checks that the output are valid in function of the inputs sent
	void validate_outputs();

	///Resets the internal state of the TB to start a new test
	void init();

	///Desctructor
	~link_frame_rx_l3_tb();

};

#endif