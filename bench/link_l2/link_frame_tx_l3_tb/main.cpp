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

#include "../../../rtl/systemc/link_l2/link_frame_tx_l3.h"
#include "link_frame_tx_l3_tb.h"

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>

using namespace std;

int sc_main( int argc, char* argv[] ){


	//The Design Under Test
	link_frame_tx_l3* dut = new link_frame_tx_l3("link_frame_tx_l3");
	//The TestBench
	link_frame_tx_l3_tb* tb = new link_frame_tx_l3_tb("link_frame_tx_l3_tb");


	//Signals used to link the design to the testbench
	sc_clock clk("clk", 1);  // system clk

	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk_ctl_phy;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >		lk_cad_phy[CAD_OUT_WIDTH];
	sc_signal<bool>							phy_consume_lk;
	sc_signal<bool >	disable_drivers;	
	sc_signal<sc_bv<32> >	cad_to_frame;
	sc_signal<bool>	lctl_to_frame;
	sc_signal<bool >	hctl_to_frame;
	sc_signal<bool>		tx_consume_data;

	sc_signal<bool>			resetx;
	sc_signal<bool>			pwrok;
	sc_signal<bool>			ldtstopx;

	sc_signal<sc_bv<3> >	csr_tx_link_width_lk;
	sc_signal<bool >		csr_end_of_chain;
	sc_signal<bool> csr_transmitter_off_lk;
	sc_signal<bool> csr_ldtstop_tristate_enable_lk;

	sc_signal<bool>			ldtstop_disconnect_tx;
	sc_signal<bool>			rx_waiting_for_ctl_tx;
#ifdef RETRY_MODE_ENABLED
	sc_signal<bool>			fc_disconnect_lk;
#endif
	sc_signal<bool>			csr_extented_ctl_lk;

	//Connect the design
	dut->clk(clk);
	dut->lk_ctl_phy(lk_ctl_phy);
	for(int n = 0; n < CAD_OUT_WIDTH; n++)
		dut->lk_cad_phy[n](lk_cad_phy[n]);
	dut->phy_consume_lk(phy_consume_lk);
	dut->disable_drivers(disable_drivers);
	dut->cad_to_frame(cad_to_frame);
	dut->lctl_to_frame(lctl_to_frame);
	dut->hctl_to_frame(hctl_to_frame);
	dut->tx_consume_data(tx_consume_data);

	dut->resetx(resetx);
	dut->ldtstopx(ldtstopx);

	dut->csr_tx_link_width_lk(csr_tx_link_width_lk);
	dut->csr_end_of_chain(csr_end_of_chain);
	dut->csr_transmitter_off_lk(csr_transmitter_off_lk);
	dut->csr_ldtstop_tristate_enable_lk(csr_ldtstop_tristate_enable_lk);

	dut->ldtstop_disconnect_tx(ldtstop_disconnect_tx);
	dut->rx_waiting_for_ctl_tx(rx_waiting_for_ctl_tx);
#ifdef RETRY_MODE_ENABLED
	dut->tx_retry_disconnect(fc_disconnect_lk);
#endif
	dut->csr_extented_ctl_lk(csr_extented_ctl_lk);
	
	//Connect the testbench
	tb->clk(clk);
	tb->lk_ctl_phy(lk_ctl_phy);
	for(int n = 0; n < CAD_OUT_WIDTH; n++)
		tb->lk_cad_phy[n](lk_cad_phy[n]);
	tb->phy_consume_lk(phy_consume_lk);
	tb->disable_drivers(disable_drivers);	
	tb->cad_to_frame(cad_to_frame);
	tb->lctl_to_frame(lctl_to_frame);
	tb->hctl_to_frame(hctl_to_frame);
	tb->tx_consume_data(tx_consume_data);

	tb->resetx(resetx);
	tb->pwrok(pwrok);
	tb->ldtstopx(ldtstopx);

	tb->csr_tx_link_width_lk(csr_tx_link_width_lk);
	tb->csr_end_of_chain(csr_end_of_chain);
	tb->ldtstop_disconnect_tx(ldtstop_disconnect_tx);
	tb->rx_waiting_for_ctl_tx(rx_waiting_for_ctl_tx);
#ifdef RETRY_MODE_ENABLED
	tb->fc_disconnect_lk(fc_disconnect_lk);
#endif

	// tracing:
	// trace file creation
	sc_trace_file *tf = sc_create_vcd_trace_file("sim_link_frame_tx_l3");
	// External Signals
	sc_trace(tf, clk, "clk");

	sc_trace(tf,lk_ctl_phy,"lk_ctl_phy");
	for(int n = 0; n < CAD_OUT_WIDTH; n++){
		ostringstream s;
		s << "lk_cad_phy(" << n << ")";
		sc_trace(tf,lk_cad_phy[n], s.str().c_str());
	}
	sc_trace(tf,phy_consume_lk,"phy_consume_lk");
	sc_trace(tf,disable_drivers,"disable_drivers");
	sc_trace(tf,cad_to_frame,"cad_to_frame");
	sc_trace(tf,lctl_to_frame,"lctl_to_frame");
	sc_trace(tf,hctl_to_frame,"hctl_to_frame");
	sc_trace(tf,tx_consume_data,"tx_consume_data");

	sc_trace(tf,resetx,"resetx");
	sc_trace(tf,pwrok,"pwrok");
	sc_trace(tf,ldtstopx,"ldtstopx");

	sc_trace(tf,csr_tx_link_width_lk,"csr_tx_link_width_lk");
	sc_trace(tf,csr_end_of_chain,"csr_end_of_chain");
	sc_trace(tf,ldtstop_disconnect_tx,"ldtstop_disconnect_tx");
	sc_trace(tf,rx_waiting_for_ctl_tx,"rx_waiting_for_ctl_tx");
#ifdef RETRY_MODE_ENABLED
	sc_trace(tf,fc_disconnect_lk,"fc_disconnect_lk");
#endif


	//------------------------------------------
	// Start simulation
	//------------------------------------------
	cout << "Debut de la simulation" << endl;
	sc_start(14000/CAD_OUT_DEPTH);


	sc_close_vcd_trace_file(tf);
	cout << "fin de la simulation" << endl;

	delete dut;
	delete tb;
	return 0;
}