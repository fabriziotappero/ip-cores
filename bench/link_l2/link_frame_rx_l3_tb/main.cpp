//main.cpp
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
//Main for link_frame_rx_l3 testbench

#ifndef SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_VC6_MAX_NUMBER_OF_PROCESSES 20
#endif
#include <systemc.h>

#include "../../../rtl/systemc/core_synth/synth_datatypes.h"
#include "../../../rtl/systemc/core_synth/constants.h"

#include "../../../rtl/systemc/link_l2/link_frame_rx_l3.h"
#include "link_frame_rx_l3_tb.h"

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>

using namespace std;

int sc_main( int argc, char* argv[] ){


	//The Design Under Test
	link_frame_rx_l3* dut = new link_frame_rx_l3("link_frame_rx_l3");
	//The TestBench
	link_frame_rx_l3_tb* tb = new link_frame_rx_l3_tb("link_frame_rx_l3_tb");


	//Signals used to link the design to the testbench
	sc_clock clk("clk", 1);  // system clk
	sc_signal<sc_bv<CAD_IN_DEPTH> >	phy_ctl_lk;
	sc_signal<sc_bv<CAD_IN_DEPTH> >	phy_cad_lk[CAD_IN_WIDTH];
	sc_signal<bool>					phy_available_lk;
	sc_signal<bool>						lk_disable_receivers_phy;
	sc_signal<sc_bv<32> >				framed_cad;
	sc_signal<bool>						framed_lctl;
	sc_signal<bool >					framed_hctl;
	sc_signal<bool>						framed_data_available;
	sc_signal<bool>						lk_rx_connected;
	sc_signal<bool>					resetx;
	sc_signal<bool>					pwrok;
	sc_signal<bool>					ldtstopx;
	sc_signal<sc_bv<3> >	csr_rx_link_width_lk;
	sc_signal<bool >		csr_end_of_chain;
	sc_signal<bool >		csr_sync;
	sc_signal<bool >		csr_extended_ctl_timeout_lk;
	sc_signal<bool>		lk_update_link_width_csr;
	sc_signal<sc_bv<3> >	lk_sampled_link_width_csr;
	sc_signal<bool>		lk_update_link_failure_property_csr;
	sc_signal<bool>		lk_link_failure_csr;
	sc_signal<bool>			ldtstop_disconnect_rx;

#ifdef RETRY_MODE_ENABLED
	sc_signal<bool>			csr_retry;
	sc_signal<bool>		lk_initiate_retry_disconnect;
	sc_signal<bool>			cd_initiate_retry_disconnect;
#endif
	sc_signal<bool>			lk_protocol_error_csr;
	sc_signal<bool>			rx_waiting_for_ctl_tx;


#ifndef INTERNAL_SHIFTER_ALIGNMENT
	sc_signal<bool > lk_deser_stall_phy;
	sc_signal<sc_uint<LOG2_CAD_IN_DEPTH> > lk_deser_stall_cycles_phy;
#endif

	//Connect the design
	dut->clk(clk);
	dut->phy_ctl_lk(phy_ctl_lk);
	for(int n = 0; n < CAD_IN_WIDTH; n++){
		dut->phy_cad_lk[n](phy_cad_lk[n]);
	}
	dut->phy_available_lk(phy_available_lk);
	dut->lk_disable_receivers_phy(lk_disable_receivers_phy);
	dut->framed_cad(framed_cad);
	dut->framed_lctl(framed_lctl);
	dut->framed_hctl(framed_hctl);
	dut->framed_data_available(framed_data_available);
	dut->lk_rx_connected(lk_rx_connected);
	dut->resetx(resetx);
	dut->pwrok(pwrok);
	dut->ldtstopx(ldtstopx);
	dut->csr_rx_link_width_lk(csr_rx_link_width_lk);
	dut->csr_end_of_chain(csr_end_of_chain);
	dut->csr_sync(csr_sync);
	dut->csr_extended_ctl_timeout_lk(csr_extended_ctl_timeout_lk);
	dut->lk_update_link_width_csr(lk_update_link_width_csr);
	dut->lk_sampled_link_width_csr(lk_sampled_link_width_csr);
	dut->lk_update_link_failure_property_csr(lk_update_link_failure_property_csr);
	dut->lk_link_failure_csr(lk_link_failure_csr);
	dut->ldtstop_disconnect_rx(ldtstop_disconnect_rx);

#ifdef RETRY_MODE_ENABLED
	dut->csr_retry(csr_retry);
	dut->lk_initiate_retry_disconnect(lk_initiate_retry_disconnect);
	dut->cd_initiate_retry_disconnect(cd_initiate_retry_disconnect);
#endif

	dut->lk_protocol_error_csr(lk_protocol_error_csr);
	dut->rx_waiting_for_ctl_tx(rx_waiting_for_ctl_tx);

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	dut->lk_deser_stall_phy(lk_deser_stall_phy);
	dut->lk_deser_stall_cycles_phy(lk_deser_stall_cycles_phy);
#endif

	//Connect the testbench
	//Connect the design
	tb->clk(clk);
	tb->phy_ctl_lk(phy_ctl_lk);
	for(int n = 0; n < CAD_IN_WIDTH; n++){
		tb->phy_cad_lk[n](phy_cad_lk[n]);
	}
	tb->phy_available_lk(phy_available_lk);
	tb->lk_disable_receivers_phy(lk_disable_receivers_phy);
	tb->framed_cad(framed_cad);
	tb->framed_lctl(framed_lctl);
	tb->framed_hctl(framed_hctl);
	tb->framed_data_available(framed_data_available);
	tb->lk_rx_connected(lk_rx_connected);
	tb->resetx(resetx);
	tb->pwrok(pwrok);
	tb->ldtstopx(ldtstopx);
	tb->csr_rx_link_width_lk(csr_rx_link_width_lk);
	tb->csr_end_of_chain(csr_end_of_chain);
	tb->csr_sync(csr_sync);
	tb->csr_extended_ctl_timeout_lk(csr_extended_ctl_timeout_lk);
	tb->lk_update_link_width_csr(lk_update_link_width_csr);
	tb->lk_sampled_link_width_csr(lk_sampled_link_width_csr);
	tb->lk_update_link_failure_property_csr(lk_update_link_failure_property_csr);
	tb->lk_link_failure_csr(lk_link_failure_csr);
	tb->ldtstop_disconnect_rx(ldtstop_disconnect_rx);

#ifdef RETRY_MODE_ENABLED
	tb->csr_retry(csr_retry);
	tb->lk_initiate_retry_disconnect(lk_initiate_retry_disconnect);
	tb->cd_initiate_retry_disconnect(cd_initiate_retry_disconnect);
#endif

 	tb->ctl_transition_error(lk_protocol_error_csr);
	tb->rx_waiting_for_ctl_tx(rx_waiting_for_ctl_tx);

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	tb->lk_deser_stall_phy(lk_deser_stall_phy);
	tb->lk_deser_stall_cycles_phy(lk_deser_stall_cycles_phy);
#endif

	// tracing:
	// trace file creation
	sc_trace_file *tf = sc_create_vcd_trace_file("sim_link_frame_rx_l3");
	// External Signals
	sc_trace(tf, clk, "clk");

	sc_trace(tf, phy_ctl_lk,"phy_ctl_lk");

	for(int n = 0 ; n < CAD_IN_WIDTH; n++){
		std::ostringstream s;
		s << "phy_cad_lk(" << n << ')';
		sc_trace(tf, phy_cad_lk[n],s.str().c_str());
	}

	sc_trace(tf, phy_available_lk,"phy_available_lk");
	sc_trace(tf, lk_disable_receivers_phy,"lk_disable_receivers_phy");

	sc_trace(tf, framed_cad, "framed_cad");
	sc_trace(tf, framed_lctl, "framed_lctl");
	sc_trace(tf, framed_hctl, "framed_hctl");
	sc_trace(tf, framed_data_available, "framed_data_available");
	sc_trace(tf, lk_rx_connected,"lk_rx_connected");
	sc_trace(tf, resetx,"resetx");
	sc_trace(tf, pwrok,"pwrok");
	sc_trace(tf, ldtstopx,"ldtstopx");

	sc_trace(tf, csr_rx_link_width_lk,"csr_rx_link_width_lk");
	sc_trace(tf, csr_end_of_chain,"csr_end_of_chain");
	sc_trace(tf, csr_sync,"csr_sync");
	sc_trace(tf, csr_extended_ctl_timeout_lk,"csr_extended_ctl_timeout_lk");
	sc_trace(tf, lk_update_link_width_csr,"lk_update_link_width_csr");
	sc_trace(tf, lk_sampled_link_width_csr,"lk_sampled_link_width_csr");
	sc_trace(tf, lk_update_link_failure_property_csr,"lk_update_link_failure_property_csr");
	sc_trace(tf, lk_link_failure_csr,"lk_link_failure_csr");
	sc_trace(tf, ldtstop_disconnect_rx,"ldtstop_disconnect_rx");

#ifdef RETRY_MODE_ENABLED
	sc_trace(tf, csr_retry,"csr_retry");
	sc_trace(tf, lk_initiate_retry_disconnect,"lk_initiate_retry_disconnect");
	sc_trace(tf, cd_initiate_retry_disconnect,"cd_initiate_retry_disconnect");
#endif

	sc_trace(tf, lk_protocol_error_csr,"lk_protocol_error_csr");
	sc_trace(tf, rx_waiting_for_ctl_tx,"rx_waiting_for_ctl_tx");

	//sc_trace(tf, dut->debug_state,"debug_state");
	sc_trace(tf, dut->reordered_cad,"reordered_cad");
	sc_trace(tf, dut->reordered_data_ready,"reordered_data_ready");
	//sc_trace(tf, dut->calculated_frame_shift_div2,"calculated_frame_shift_div2");
	//sc_trace(tf, dut->frame_shift_div2,"frame_shift_div2");
	sc_trace(tf, dut->reordered_ctl,"reordered_ctl");
	sc_trace(tf, dut->detected_ctl_transition_error,"detected_ctl_transition_error");

	//------------------------------------------
	// Start simulation
	//------------------------------------------
	std::cout << "Debut de la simulation" << endl;
	sc_start(2248);

	sc_close_vcd_trace_file(tf);
	std::cout << "fin de la simulation" << endl;

	delete dut;
	delete tb;
	return 0;
}