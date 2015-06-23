//link_frame_rx_l3.h
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

#ifndef LINK_FRAME_RX_L3_H
#define LINK_FRAME_RX_L3_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"
#include "link_l2.h"


/**Possible internal states of the link_frame_rx_l3 module*/
enum rx_frame_state {
	RX_FRAME_INACTIVE_ST,///<Inactive, initial state, waiting for CAD to become 00
	RX_FRAME_WAIT_FRAME_ST,///<Waiting for CAD to become 1 
	RX_FRAME_ACTIVE_ST,///<Normal operating state
#ifdef RETRY_MODE_ENABLED
	RX_FRAME_RETRY_DISCONNECT_ST,///< Retry disconnect sequence
#endif
	RX_FRAME_LDTSTOP_DISCONNECT_ST///< LDTSTOP disconnect sequence
};

///Frames incoming bit stream from the physical link
/**	
	@author Ami Castonguay
	@description The module also takes care of correctly initializing the
		communication.
*/
class link_frame_rx_l3 : public sc_module {

public:

	///Main module clock
	sc_in<bool >		clk;
	///RX CTL - Higher is newer, lower is older
	sc_in<sc_bv<CAD_IN_DEPTH> >		phy_ctl_lk;
	///RX CAD - Higher is newer, lower is older
	/**
		Bits received from the link are simple shifter with
		a shift register before being sent to the link.  Every
		bit has a shift register : an 8 bit link has CAD_IN_WIDTH = 8
		and a shift register of size 4.

		Bits are shifted from most significant toward least significant.
	*/
	sc_in<sc_bv<CAD_IN_DEPTH> >	phy_cad_lk[CAD_IN_WIDTH];
	///Asserted whe PHY layer has data available
	sc_in<bool>						phy_available_lk;
	///Allows to disable receivers to save power and prevent problems when driver is tristate
	sc_out<bool>					lk_disable_receivers_phy;

	///The data that was framed
	sc_out<sc_bv<32> >	framed_cad;
	///LCTL value of the framed dword
	sc_out<bool>	framed_lctl;
	///HCTL value of the framed dword
	sc_out<bool >	framed_hctl;
	///If there is a framed dword available
	sc_out<bool>	framed_data_available;

	///If the link is currently connected (active)
	sc_out<bool>	lk_rx_connected;

	/**
		External global system signals
	*/
	//@{
	///Reset the system
	sc_in<bool>			resetx;
	///If power is stabilized - defines wether resetx represents a cold or warm reset
	sc_in<bool>			pwrok;
	///Indicates an ldtstop sequence
	sc_in<bool>			ldtstopx;
	//@}


	/**
	Link widths
	
	000 8 bits 
	100 2 bits 
	101 4 bits 
	111  Link physically not connected 
	*/
	///The link width for the RX side
	sc_in<sc_bv<3> >	csr_rx_link_width_lk;
	///If this link should be deactivated because it's at the end of chain
	sc_in<bool >		csr_end_of_chain;
	///If the link is in sync mode
	sc_in<bool >		csr_sync;
	///The timeout for CTL being low too long is extended
	sc_in<bool >		csr_extended_ctl_timeout_lk;

	///To update the link width registered in the CSR with the new value
	sc_out<bool>		lk_update_link_width_csr;
	///The link width that is being sampled
	sc_out<sc_bv<3> >	lk_sampled_link_width_csr;

	
	///Update the link failure flag in CSR with the lk_link_failure_csr signal
	sc_out<bool>		lk_update_link_failure_property_csr;
	///This signal should only be evaluated at lk_update_link_failure_property_csr
	sc_out<bool>		lk_link_failure_csr;

	///Link commands a ltdstop disconnect
	sc_in<bool>			ldtstop_disconnect_rx;

#ifdef RETRY_MODE_ENABLED
	///The flow control asks us to disconnect the link
	//Eliminated because the retry sequence is always initiated
	//by either the CD or the link.  fc_disconnect_lk is used by
	//the TX part of the link because it must wait until the FC
	//has sent an Discon NOP before disconnecting
	//sc_in<bool>			fc_disconnect_lk;
	///If we are in retry mode
	sc_in<bool>			csr_retry;
	///Start a retry sequence
	sc_out<bool>		lk_initiate_retry_disconnect;
	///Command decoder commands a retry disconnect
	sc_in<bool>			cd_initiate_retry_disconnect;
#endif

	///Asserted when a transition error on CTL is detected
	sc_out<bool> lk_protocol_error_csr;
	///RX framer is waiting for CTL to be activated (during init sequence)
	sc_out<bool>		rx_waiting_for_ctl_tx;

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	///High speed deserializer should stall shifting bits for lk_deser_stall_cycles_phy cycles
	/** Cannot be asserted with a lk_deser_stall_cycles_phy value of 0*/
	sc_out<bool > lk_deser_stall_phy;
	///Number of bit times to stall deserializing incoming data when lk_deser_stall_phy is asserted
	sc_out<sc_uint<LOG2_CAD_IN_DEPTH> > lk_deser_stall_cycles_phy;
#endif

	///Sampled resetx after coldreset
	sc_signal<bool>				ready_to_sample_link_width;
	///Sampled resetx after coldreset (a second time to prevent async effects)
	sc_signal<bool>				ready_to_sample_link_width2;
	///If the link has been sampled (do it only once per coldreset)
	sc_signal<bool>				link_width_sampled	;
	///Link width from CSR (3 bits) is encoded to an internal value (2 bit)S
	sc_signal<sc_uint<2> >		rx_link_width_encoded;
	///Reordered CAD vector - it is updated with every new data that arrives
	sc_signal<sc_bv<32> >		reordered_cad;
	///Reordered CTL vector - it is updated with every new data that arrives
	sc_signal<sc_bv<16> >		reordered_ctl;
	///Asserted when there is framed data ready
	/**Not always equal to framed_data_available depending on the state*/
	sc_signal<bool>		reordered_data_ready;
	///Frame shift calculated to properly frame the input dwords
	/**This is only valid at the exact moment CAD makes a 
	transition from 1 to 0 during init sequence */
	sc_signal<sc_uint<LOG2_CAD_IN_DEPTH> >		calculated_frame_shift_div_width;
	///Registered value of ::calculated_frame_shift_div_width
	/** The transition from 0 to 1 is detected with a delay of one cycle,
	so registering the calculated frame shift is necessary to store the
	correct value once it is detected*/
	sc_signal<sc_uint<LOG2_CAD_IN_DEPTH> >		delayed_calculated_frame_shift_div_width;
#ifdef INTERNAL_SHIFTER_ALIGNMENT
	///The actual stored valid value of frame shift once init is complete
	sc_signal<sc_uint<LOG2_CAD_IN_DEPTH> >		frame_shift_div_width;
	///Last reordered CAD
	/** It is necessary to register the reordered CAD as depending on the
	alligment of data, a valid dword might be spread in two reordered cad.*/
	sc_signal<sc_bv<32> >		delayed_reordered_cad;
	///Last reordered CTL
	sc_signal<sc_bv<16> >		delayed_reordered_ctl;
#endif

#if CAD_IN_WIDTH == 4
	///Internal count to know when reordered_cad is ready
	sc_signal<sc_uint<1> >		phy_cad_lk_count;
#elif CAD_IN_WIDTH == 8
	///Internal count to know when reordered_cad is ready
	sc_signal<sc_uint<2> >		phy_cad_lk_count;	
#endif


	///True while we must stay disconnected for retry
	sc_signal<sc_uint<NUMBER_BITS_REPRESENT_1US_M1> > disconnect_counter;
	///Current state of the internal state machine
	sc_signal<rx_frame_state>	state;

	///Combinational : when a ctl error is detected
	sc_signal<bool> new_detected_ctl_transition_error;

	///Registered value of when ctl error is detected
	/**The register is used to store that a CTL error is detected.  It is not
	reported immediately to prevent a reset to cause an error to be reported*/
	sc_signal<bool> detected_ctl_transition_error;
	
	///If CTL stays low too long, it is a protocol error  
	/**This timer keeps a watch for this error*/
	sc_signal<sc_uint<NUMBER_BITS_REPRESENT_1S> >	ctl_watchdog_timer;

	///SystemC Macro
	SC_HAS_PROCESS(link_frame_rx_l3);

	/** 
	@description Module/class constructor
	@param name The name of the instance of the module
	*/
	link_frame_rx_l3( sc_module_name name);

	void sample_link_width();
	void clocked_process();
	void protocol_error_or();
	void encode_link_width();
	void reorder_cad();
	void reorder_ctl();
	void clocked_and_reset_process();
	void generate_ctl_and_timeout_errors();
	void detect_ctl_transition_error();
	void encode();

#ifdef INTERNAL_SHIFTER_ALIGNMENT
	void frame_cad();
	void frame_ctl();
#else
	void output_reordered_cad_and_ctl();
#endif

};

#endif

