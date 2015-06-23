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

#include "../../../rtl/systemc/link_l2/link_l2.h"
#include "../../../rtl/systemc/link_l2/link_frame_rx_l3.h"
#include "link_l2_tb.h"

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>

using namespace std;

int sc_main( int argc, char* argv[] ){


	//The Design Under Test
	link_l2* dut = new link_l2("link_l2");
	//The TestBench
	link_l2_tb* tb = new link_l2_tb("link_l2_tb");


	//Signals used to link the design to the testbench
	sc_clock clk("clk", 1);  // system clk
	sc_signal<bool>			resetx;
	sc_signal<bool>			pwrok;
	sc_signal<bool>			ldtstopx;

	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy_ctl_lk;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy_cad_lk[CAD_IN_WIDTH];
	sc_signal<bool>						phy_available_lk;

	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk_ctl_phy;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk_cad_phy[CAD_OUT_WIDTH];
	sc_signal<bool>						phy_consume_lk;

	sc_signal<bool>					lk_disable_drivers_phy;
	sc_signal<bool>					lk_disable_receivers_phy;

	sc_signal<bool>					lk_ldtstop_disconnected;

	/**
		Data to be sent to the next link
		This data comes from the flow control
		@{
	*/
	///Dword to send
	sc_signal<sc_bv<32> > 	fc_dword_lk;
	///The LCTL value associated with the dword to send
	sc_signal<bool>			fc_lctl_lk;
	///The HCTL value associated with the dword to send
	sc_signal<bool>			fc_hctl_lk;
	///To consume the data from the flow control
	sc_signal<bool>		lk_consume_fc;
	///@}


	//*******************************
	//	Signals from link
	//*******************************
	
	///Bit vector output for command decoder 
	sc_signal< sc_bv<32> > 		lk_dword_cd;
	///Control bit
	sc_signal< bool > 			lk_hctl_cd;
	///Control bit
	sc_signal< bool > 			lk_lctl_cd;
	///FIFO is ready to be read from
	sc_signal< bool > 			lk_available_cd;

	/**
	Link widths
	
	000 8 bits 
	100 2 bits 
	101 4 bits 
	111  Link physically not connected 
	@{
	*/
	///The link width for the RX side
	sc_signal<sc_bv<3> >	csr_rx_link_width_lk;
	///The link width for the TX side
	sc_signal<sc_bv<3> >	csr_tx_link_width_lk;
	///@}

	//If the chain is being synched
	sc_signal<bool>			csr_sync;

	///If this link should be inactive because it is the end of chain
	sc_signal<bool>			csr_end_of_chain;

	///To update the link width registered in the CSR with the new value
	sc_signal<bool>		lk_update_link_width_csr;
	///The link width that is being sampled
	sc_signal<sc_bv<3> >	lk_sampled_link_width_csr;
	///A protocol error has been detected
	sc_signal<bool>		lk_protocol_error_csr;


	///Force CRC errors to be generated
	sc_signal<bool>			csr_crc_force_error_lk;
	///To turn off the transmitter
	sc_signal<bool>			csr_transmitter_off_lk;
	///Hold CTL longer in the ini sequemce
	sc_signal<bool>			csr_extented_ctl_lk;
	///The timeout for CTL being low too long is extended
	sc_signal<bool>			csr_extended_ctl_timeout_lk;
	///If we are enabled to tristated the drivers when in ldtstop
	sc_signal<bool>			csr_ldtstop_tristate_enable_lk;
	
	///CRC error detected on link
	sc_signal<bool>		lk_crc_error_csr;
	///Update the link failure flag in CSR with the lk_link_failure_csr signal
	sc_signal<bool>		lk_update_link_failure_property_csr;

#ifdef RETRY_MODE_ENABLED
	///Start a retry sequence
	sc_signal<bool>		lk_initiate_retry_disconnect;
	///Command decoder commands a retry disconnect
	sc_signal<bool>			cd_initiate_retry_disconnect;

	///The flow control asks us to disconnect the link
	sc_signal<bool>			fc_disconnect_lk;
	///If we are in the retry mode
	sc_signal<bool >		csr_retry;
#endif
	///RX link is connected (identical to lk_initialization_complete_csr)
	sc_signal<bool>		lk_rx_connected;
	///This signal should only be evaluated at lk_update_link_failure_property_csr
	sc_signal<bool>		lk_link_failure_csr;

	//A sync error has been detected
	// - Not used anymore, sync only detected through standard decode logic
	//sc_signal<bool>		lk_sync_detected_csr;

	///Command decoder commands a ltdstop disconnect
	sc_signal<bool>			cd_initiate_nonretry_disconnect_lk;

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	sc_signal<bool > lk_deser_stall_phy;
	///Number of bit times to stall deserializing incoming data when lk_deser_stall_phy is asserted
	sc_signal<sc_uint<LOG2_CAD_IN_DEPTH> > lk_deser_stall_cycles_phy;
#endif

	//Connect the design
	dut->clk(clk);
	dut->resetx(resetx);
	dut->pwrok(pwrok);
	dut->ldtstopx(ldtstopx);
	dut->phy_ctl_lk(phy_ctl_lk);
	for(int n = 0; n < CAD_IN_WIDTH; n++)
		dut->phy_cad_lk[n](phy_cad_lk[n]);
	dut->phy_available_lk(phy_available_lk);
	dut->lk_ctl_phy(lk_ctl_phy);
	for(int n = 0; n < CAD_OUT_WIDTH; n++)
		dut->lk_cad_phy[n](lk_cad_phy[n]);
	dut->phy_consume_lk(phy_consume_lk);
	dut->lk_disable_drivers_phy(lk_disable_drivers_phy);
	dut->lk_disable_receivers_phy(lk_disable_receivers_phy);
	dut->lk_ldtstop_disconnected(lk_ldtstop_disconnected);
	dut->fc_dword_lk(fc_dword_lk);
	dut->fc_lctl_lk(fc_lctl_lk);
	dut->fc_hctl_lk(fc_hctl_lk);
	dut->lk_consume_fc(lk_consume_fc);
	dut->lk_dword_cd(lk_dword_cd);
	dut->lk_hctl_cd(lk_hctl_cd);
	dut->lk_lctl_cd(lk_lctl_cd);
	dut->lk_available_cd(lk_available_cd);
	dut->csr_rx_link_width_lk(csr_rx_link_width_lk);
	dut->csr_tx_link_width_lk(csr_tx_link_width_lk);
	dut->csr_sync(csr_sync);
	dut->csr_end_of_chain(csr_end_of_chain);
	dut->lk_update_link_width_csr(lk_update_link_width_csr);
	dut->lk_sampled_link_width_csr(lk_sampled_link_width_csr);
	dut->lk_protocol_error_csr(lk_protocol_error_csr);
	dut->csr_crc_force_error_lk(csr_crc_force_error_lk);
	dut->csr_transmitter_off_lk(csr_transmitter_off_lk);
	dut->csr_extented_ctl_lk(csr_extented_ctl_lk);
	dut->csr_extended_ctl_timeout_lk(csr_extended_ctl_timeout_lk);
	dut->csr_ldtstop_tristate_enable_lk(csr_ldtstop_tristate_enable_lk);
	dut->lk_crc_error_csr(lk_crc_error_csr);
	dut->lk_update_link_failure_property_csr(lk_update_link_failure_property_csr);

#ifdef RETRY_MODE_ENABLED
	dut->lk_initiate_retry_disconnect(lk_initiate_retry_disconnect);
	dut->cd_initiate_retry_disconnect(cd_initiate_retry_disconnect);
	dut->fc_disconnect_lk(fc_disconnect_lk);
	dut->csr_retry(csr_retry);
#endif
	dut->lk_rx_connected(lk_rx_connected);
	dut->lk_link_failure_csr(lk_link_failure_csr);
	dut->cd_initiate_nonretry_disconnect_lk(cd_initiate_nonretry_disconnect_lk);

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	dut->lk_deser_stall_phy(lk_deser_stall_phy);
	dut->lk_deser_stall_cycles_phy(lk_deser_stall_cycles_phy);
#endif
	//Connect the testbench
	tb->clk(clk);
	tb->resetx(resetx);
	tb->pwrok(pwrok);
	tb->ldtstopx(ldtstopx);
	tb->phy_ctl_lk(phy_ctl_lk);
	for(int n = 0; n < CAD_IN_WIDTH; n++)
		tb->phy_cad_lk[n](phy_cad_lk[n]);
	tb->phy_available_lk(phy_available_lk);
	tb->lk_ctl_phy(lk_ctl_phy);
	for(int n = 0; n < CAD_OUT_WIDTH; n++)
		tb->lk_cad_phy[n](lk_cad_phy[n]);
	tb->phy_consume_lk(phy_consume_lk);
	tb->lk_disable_drivers_phy(lk_disable_drivers_phy);
	tb->lk_disable_receivers_phy(lk_disable_receivers_phy);
	tb->fc_dword_lk(fc_dword_lk);
	tb->fc_lctl_lk(fc_lctl_lk);
	tb->fc_hctl_lk(fc_hctl_lk);
	tb->lk_consume_fc(lk_consume_fc);
	tb->lk_dword_cd(lk_dword_cd);
	tb->lk_hctl_cd(lk_hctl_cd);
	tb->lk_lctl_cd(lk_lctl_cd);
	tb->lk_available_cd(lk_available_cd);
	tb->csr_rx_link_width_lk(csr_rx_link_width_lk);
	tb->csr_tx_link_width_lk(csr_tx_link_width_lk);
	tb->csr_sync(csr_sync);
	tb->csr_end_of_chain(csr_end_of_chain);
	tb->lk_update_link_width_csr(lk_update_link_width_csr);
	tb->lk_sampled_link_width_csr(lk_sampled_link_width_csr);
	tb->lk_protocol_error_csr(lk_protocol_error_csr);
	tb->csr_crc_force_error_lk(csr_crc_force_error_lk);
	tb->csr_transmitter_off_lk(csr_transmitter_off_lk);
	tb->csr_extented_ctl_lk(csr_extented_ctl_lk);
	tb->csr_extended_ctl_timeout_lk(csr_extended_ctl_timeout_lk);
	tb->csr_ldtstop_tristate_enable_lk(csr_ldtstop_tristate_enable_lk);
	tb->lk_crc_error_csr(lk_crc_error_csr);
	tb->lk_update_link_failure_property_csr(lk_update_link_failure_property_csr);

#ifdef RETRY_MODE_ENABLED
	tb->lk_initiate_retry_disconnect(lk_initiate_retry_disconnect);
	tb->cd_initiate_retry_disconnect(cd_initiate_retry_disconnect);
	tb->fc_disconnect_lk(fc_disconnect_lk);
	tb->csr_retry(csr_retry);
#endif
	tb->lk_rx_connected(lk_rx_connected);
	tb->lk_link_failure_csr(lk_link_failure_csr);
	tb->cd_initiate_nonretry_disconnect_lk(cd_initiate_nonretry_disconnect_lk);

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	tb->lk_deser_stall_phy(lk_deser_stall_phy);
	tb->lk_deser_stall_cycles_phy(lk_deser_stall_cycles_phy);
#endif
	// tracing:
	// trace file creation
	sc_trace_file *tf = sc_create_vcd_trace_file("sim_link_l2");
	// External Signals
	sc_trace(tf, clk, "clk");
	sc_trace(tf,resetx,"resetx");
	sc_trace(tf,pwrok,"pwrok");
	sc_trace(tf,ldtstopx,"ldtstopx");
	sc_trace(tf,phy_ctl_lk,"phy_ctl_lk");
	for(int n = 0 ; n < CAD_IN_WIDTH; n++){
		std::ostringstream s;
		s << "phy_cad_lk(" << n << ')';
		sc_trace(tf, phy_cad_lk[n],s.str().c_str());
	}
	sc_trace(tf,phy_available_lk,"phy_available_lk");
	sc_trace(tf,lk_ctl_phy,"lk_ctl_phy");
	for(int n = 0 ; n < CAD_OUT_WIDTH; n++){
		std::ostringstream s;
		s << "lk_cad_phy(" << n << ')';
		sc_trace(tf,lk_cad_phy[n],s.str().c_str());
	}
	sc_trace(tf,phy_consume_lk,"phy_consume_lk");
	sc_trace(tf,lk_disable_drivers_phy,"lk_disable_drivers_phy");
	sc_trace(tf,lk_disable_receivers_phy,"lk_disable_receivers_phy");
	sc_trace(tf,fc_dword_lk,"fc_dword_lk");
	sc_trace(tf,fc_lctl_lk,"fc_lctl_lk");
	sc_trace(tf,fc_hctl_lk,"fc_hctl_lk");
	sc_trace(tf,lk_consume_fc,"lk_consume_fc");
	sc_trace(tf,lk_dword_cd,"lk_dword_cd");
	sc_trace(tf,lk_hctl_cd,"lk_hctl_cd");
	sc_trace(tf,lk_lctl_cd,"lk_lctl_cd");
	sc_trace(tf,lk_available_cd,"lk_available_cd");
	sc_trace(tf,csr_rx_link_width_lk,"csr_rx_link_width_lk");
	sc_trace(tf,csr_tx_link_width_lk,"csr_tx_link_width_lk");
	sc_trace(tf,csr_sync,"csr_sync");
	sc_trace(tf,csr_end_of_chain,"csr_end_of_chain");
	sc_trace(tf,lk_update_link_width_csr,"lk_update_link_width_csr");
	sc_trace(tf,lk_sampled_link_width_csr,"lk_sampled_link_width_csr");
	sc_trace(tf,lk_protocol_error_csr,"lk_protocol_error_csr");
	sc_trace(tf,csr_crc_force_error_lk,"csr_crc_force_error_lk");
	sc_trace(tf,csr_transmitter_off_lk,"csr_transmitter_off_lk");
	sc_trace(tf,csr_extented_ctl_lk,"csr_extented_ctl_lk");
	sc_trace(tf,csr_extended_ctl_timeout_lk,"csr_extended_ctl_timeout_lk");
	sc_trace(tf,csr_ldtstop_tristate_enable_lk,"csr_ldtstop_tristate_enable_lk");
	sc_trace(tf,lk_crc_error_csr,"lk_crc_error_csr");
	sc_trace(tf,lk_update_link_failure_property_csr,"lk_update_link_failure_property_csr");

#ifdef RETRY_MODE_ENABLED
	sc_trace(tf,lk_initiate_retry_disconnect,"lk_initiate_retry_disconnect");
	sc_trace(tf,cd_initiate_retry_disconnect,"cd_initiate_retry_disconnect");
	sc_trace(tf,fc_disconnect_lk,"fc_disconnect_lk");
	sc_trace(tf,csr_retry,"csr_retry");
#endif
	sc_trace(tf,lk_rx_connected,"lk_rx_connected");
	sc_trace(tf,lk_link_failure_csr,"lk_link_failure_csr");
	sc_trace(tf,cd_initiate_nonretry_disconnect_lk,"cd_initiate_nonretry_disconnect_lk");



	//------------------------------------------
	// Start simulation
	//------------------------------------------
	cout << "Debut de la simulation" << endl;
	sc_start(4500);


	sc_close_vcd_trace_file(tf);
	cout << "fin de la simulation" << endl;

	delete dut;
	delete tb;
	return 0;
}