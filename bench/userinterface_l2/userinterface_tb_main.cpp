//userinterface_tb_main.cpp
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
/**
* @author  Ami Castonguay
*
* @description  High level entity for the simulation of a
*				HyperTransport tunnel interface built for the course
*				ele6305.
*/

#ifndef SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_VC6_MAX_NUMBER_OF_PROCESSES 20
#endif
#include <systemc.h>

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>

#include "../../rtl/systemc/core_synth/ht_type_include.h"
#include "../../rtl/systemc/userinterface_l2/userinterface_l2.h"
#include "userinterface_tb.h"




using namespace std;

// Main function
int sc_main( int argc, char* argv[] )
{
	//sc_clock clk("clk", 20);  // system clk
	sc_signal< bool > clk;

	userinterface_l2 ui("UserInterface");
	userinterface_tb uiTest("UserInterfaceTest");

	sc_signal< bool	>		resetx;

	sc_signal< bool >			csr_direct_route_oppposite_dir[DirectRoute_NumberDirectRouteSpaces];
	sc_signal<sc_bv<32>	>	csr_direct_route_base[DirectRoute_NumberDirectRouteSpaces];
	sc_signal<sc_bv<32>	>	csr_direct_route_limit[DirectRoute_NumberDirectRouteSpaces];
	sc_signal<sc_bv<32> >	csr_direct_route_enable;
	sc_signal< bool >			csr_default_dir;
	sc_signal< bool >			csr_master_host;
	sc_signal< bool >			csr_end_of_chain0;
	sc_signal< bool >			csr_end_of_chain1;
	sc_signal< bool >			csr_bus_master_enable;
	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >	ui_address_db0;
	sc_signal<bool>				ui_consume_db0;
	sc_signal<VirtualChannel>		 ui_vctype_db0;
	sc_signal< sc_bv<32> >			db0_data_ui;
	sc_signal< bool >				ui_erase_db0;
	sc_signal<syn_ControlPacketComplete>	ro0_packet_ui;
	sc_signal<bool> 				ro0_available_ui;
	sc_signal< bool >				ui_consume_ro0;
	sc_signal<sc_bv<64> >		ui_packet_fc0;
	sc_signal<bool>				ui_available_fc0;
	sc_signal<sc_bv<3> >			fc0_user_fifo_ge2_ui;/*!*/
	sc_signal<sc_bv<32> >			ui_data_fc0;
	sc_signal<VirtualChannel> 		fc0_datavc_ui;
	sc_signal< bool >				fc0_consume_data_ui;

	sc_signal< sc_uint<BUFFERS_ADDRESS_WIDTH> >	ui_address_db1;
	sc_signal<bool>				ui_consume_db1;
	sc_signal<VirtualChannel>		 ui_vctype_db1;
	sc_signal< sc_bv<32> >			db1_data_ui;
	sc_signal< bool >				ui_erase_db1;
	sc_signal<syn_ControlPacketComplete>	ro1_packet_ui;
	sc_signal<bool> 				ro1_available_ui;
	sc_signal< bool >				ui_consume_ro1;
	sc_signal<sc_bv<64> >		ui_packet_fc1;
	sc_signal<bool>				ui_available_fc1;
	sc_signal<sc_bv<3> >			fc1_user_fifo_ge2_ui;/*!*/
	sc_signal<sc_bv<32> >			ui_data_fc1;
	sc_signal<VirtualChannel> 		fc1_datavc_ui;
	sc_signal< bool >				fc1_consume_data_ui;

	sc_signal<sc_bv<64> >		ui_packet_usr;
	sc_signal<VirtualChannel>	ui_vc_usr;
	sc_signal< bool >			ui_side_usr;
	sc_signal< bool >			ui_directroute_usr;
	sc_signal< bool >			ui_eop_usr;
	sc_signal< bool >			ui_available_usr;
	sc_signal< bool >			ui_output_64bits_usr;
	sc_signal< bool >			usr_consume_ui;

	sc_signal<sc_bv<64> >		usr_packet_ui;
	sc_signal< bool >			usr_available_ui;
	sc_signal< bool >			usr_side_ui;
	sc_signal<sc_bv<6> >		ui_freevc0_usr;
	sc_signal<sc_bv<6> >		ui_freevc1_usr;	

	sc_signal<bool> ui_sendingPostedDataError_csr;
	sc_signal<bool> ui_sendingTargetAbort_csr;

	sc_signal<bool> ui_receivedResponseDataError_csr;
	sc_signal<bool> ui_receivedPostedDataError_csr;
	sc_signal<bool> ui_receivedTargetAbort_csr;
	sc_signal<bool> ui_receivedMasterAbort_csr;

	sc_signal<bool>				csr_request_databuffer0_access_ui;
	sc_signal<bool>				csr_request_databuffer1_access_ui;
	sc_signal<bool>				ui_databuffer_access_granted_csr;

	sc_signal<bool>				ui_grant_csr_access_db0;
	sc_signal<bool>				ui_grant_csr_access_db1;
	
	/////////////////////////////////////
	// Interface to memory - synchronous
	/////////////////////////////////////

	sc_signal<bool> ui_memory_write0;
	sc_signal<bool> ui_memory_write1;
	sc_signal<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_write_address;
	sc_signal<sc_bv<32> > ui_memory_write_data;

	sc_signal<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_read_address0;
	sc_signal<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_read_address1;
	sc_signal<sc_bv<32> > ui_memory_read_data0;
	sc_signal<sc_bv<32> > ui_memory_read_data1;


	ui.clk(clk);
	uiTest.clk(clk);
	
	//*****************************************
	//Bind ports for UI
	//*****************************************
	
	ui.resetx(resetx);
	
	for(int n = 0; n < DirectRoute_NumberDirectRouteSpaces; n++){
		ui.csr_direct_route_oppposite_dir[n](csr_direct_route_oppposite_dir[n]);
		ui.csr_direct_route_base[n](csr_direct_route_base[n]);
		ui.csr_direct_route_limit[n](csr_direct_route_limit[n]);
	}
	ui.csr_direct_route_enable(csr_direct_route_enable);

	ui.csr_end_of_chain0(csr_end_of_chain0);
	ui.csr_end_of_chain1(csr_end_of_chain1);
	ui.csr_default_dir(csr_default_dir);
	ui.csr_master_host(csr_master_host);
	ui.csr_bus_master_enable(csr_bus_master_enable);
	ui.ui_address_db0(ui_address_db0);
	ui.ui_read_db0(ui_consume_db0);
	ui.ui_vctype_db0(ui_vctype_db0);
	ui.db0_data_ui(db0_data_ui);
	ui.ui_erase_db0(ui_erase_db0);
	ui.ro0_packet_ui(ro0_packet_ui);
	ui.ro0_available_ui(ro0_available_ui);
	ui.ui_ack_ro0(ui_consume_ro0);
	ui.ui_packet_fc0(ui_packet_fc0);
	ui.ui_available_fc0(ui_available_fc0);
	ui.fc0_user_fifo_ge2_ui(fc0_user_fifo_ge2_ui);
	ui.ui_data_fc0(ui_data_fc0);
	ui.fc0_data_vc_ui(fc0_datavc_ui);
	ui.fc0_consume_data_ui(fc0_consume_data_ui);
	ui.ui_address_db1(ui_address_db1);
	ui.ui_read_db1(ui_consume_db1);
	ui.ui_vctype_db1(ui_vctype_db1);
	ui.db1_data_ui(db1_data_ui);
	ui.ui_erase_db1(ui_erase_db0);
	ui.ro1_packet_ui(ro1_packet_ui);
	ui.ro1_available_ui(ro1_available_ui);
	ui.ui_ack_ro1(ui_consume_ro1);
	ui.ui_packet_fc1(ui_packet_fc1);
	ui.ui_available_fc1(ui_available_fc1);
	ui.fc1_user_fifo_ge2_ui(fc1_user_fifo_ge2_ui);
	ui.ui_data_fc1(ui_data_fc1);
	ui.fc1_data_vc_ui(fc1_datavc_ui);
	ui.fc1_consume_data_ui(fc1_consume_data_ui);
	ui.ui_packet_usr(ui_packet_usr);
	ui.ui_vc_usr(ui_vc_usr);
	ui.ui_side_usr(ui_side_usr);
	ui.ui_directroute_usr(ui_directroute_usr);
	ui.ui_eop_usr(ui_eop_usr);
	ui.ui_available_usr(ui_available_usr);
	ui.ui_output_64bits_usr(ui_output_64bits_usr);
	ui.usr_consume_ui(usr_consume_ui);
	ui.usr_packet_ui(usr_packet_ui);
	ui.usr_available_ui(usr_available_ui);
	ui.usr_side_ui(usr_side_ui);
	ui.ui_freevc0_usr(ui_freevc0_usr);
	ui.ui_freevc1_usr(ui_freevc1_usr);

	ui.ui_sendingPostedDataError_csr(ui_sendingPostedDataError_csr);
	ui.ui_sendingTargetAbort_csr(ui_sendingTargetAbort_csr);

	ui.ui_receivedResponseDataError_csr(ui_receivedResponseDataError_csr);
	ui.ui_receivedPostedDataError_csr(ui_receivedPostedDataError_csr);
	ui.ui_receivedTargetAbort_csr(ui_receivedTargetAbort_csr);
	ui.ui_receivedMasterAbort_csr(ui_receivedMasterAbort_csr);

	ui.csr_request_databuffer0_access_ui(csr_request_databuffer0_access_ui);
	ui.csr_request_databuffer1_access_ui(csr_request_databuffer1_access_ui);
	ui.ui_databuffer_access_granted_csr(ui_databuffer_access_granted_csr);
	ui.ui_grant_csr_access_db0(ui_grant_csr_access_db0);
	ui.ui_grant_csr_access_db1(ui_grant_csr_access_db1);
	
	ui.ui_memory_write0(ui_memory_write0);
	ui.ui_memory_write1(ui_memory_write1);
	ui.ui_memory_write_address(ui_memory_write_address);
	ui.ui_memory_write_data(ui_memory_write_data);

	ui.ui_memory_read_address0(ui_memory_read_address0);
	ui.ui_memory_read_address1(ui_memory_read_address1);
	ui.ui_memory_read_data0(ui_memory_read_data0);
	ui.ui_memory_read_data1(ui_memory_read_data1);

	//*****************************************
	//Bind ports for UI Test
	//*****************************************
	uiTest.resetx(resetx);

	for(int n = 0; n < DirectRoute_NumberDirectRouteSpaces; n++){
		uiTest.csr_direct_route_oppposite_dir[n](csr_direct_route_oppposite_dir[n]);
		uiTest.csr_direct_route_base[n](csr_direct_route_base[n]);
		uiTest.csr_direct_route_limit[n](csr_direct_route_limit[n]);
	}
	uiTest.csr_direct_route_enable(csr_direct_route_enable);
	
	uiTest.csr_default_dir(csr_default_dir);
	uiTest.csr_masterhost(csr_master_host);
	uiTest.csr_end_of_chain0(csr_end_of_chain0);
	uiTest.csr_end_of_chain1(csr_end_of_chain1);
	uiTest.csr_bus_master_enable(csr_bus_master_enable);
	uiTest.ui_address_db0(ui_address_db0);
	uiTest.ui_consume_db0(ui_consume_db0);
	uiTest.ui_vctype_db0(ui_vctype_db0);
	uiTest.db0_data_ui(db0_data_ui);
	uiTest.ui_erase_db0(ui_erase_db0);
	uiTest.ro0_packet_ui(ro0_packet_ui);
	uiTest.ro0_available_ui(ro0_available_ui);
	uiTest.ui_consume_ro0(ui_consume_ro0);
	uiTest.ui_packet_fc0(ui_packet_fc0);
	uiTest.ui_available_fc0(ui_available_fc0);
	uiTest.fc0_user_fifo_ge2_ui(fc0_user_fifo_ge2_ui);
	uiTest.ui_data_fc0(ui_data_fc0);
	uiTest.fc0_datavc_ui(fc0_datavc_ui);
	uiTest.fc0_consume_data_ui(fc0_consume_data_ui);
	uiTest.ui_address_db1(ui_address_db1);
	uiTest.ui_consume_db1(ui_consume_db1);
	uiTest.ui_vctype_db1(ui_vctype_db1);
	uiTest.db1_data_ui(db1_data_ui);
	uiTest.ui_erase_db1(ui_erase_db1);
	uiTest.ro1_packet_ui(ro1_packet_ui);
	uiTest.ro1_available_ui(ro1_available_ui);
	uiTest.ui_consume_ro1(ui_consume_ro1);
	uiTest.ui_packet_fc1(ui_packet_fc1);
	uiTest.ui_available_fc1(ui_available_fc1);
	uiTest.fc1_user_fifo_ge2_ui(fc1_user_fifo_ge2_ui);
	uiTest.ui_data_fc1(ui_data_fc1);
	uiTest.fc1_datavc_ui(fc1_datavc_ui);
	uiTest.fc1_consume_data_ui(fc1_consume_data_ui);
	uiTest.ui_packet_usr(ui_packet_usr);
	uiTest.ui_vc_usr(ui_vc_usr);
	uiTest.ui_side_usr(ui_side_usr);
	uiTest.ui_directroute_usr(ui_directroute_usr);
	uiTest.ui_eop_usr(ui_eop_usr);
	uiTest.ui_available_usr(ui_available_usr);
	uiTest.ui_output_64bits_usr(ui_output_64bits_usr);
	uiTest.usr_consume_ui(usr_consume_ui);
	uiTest.usr_packet_ui(usr_packet_ui);
	uiTest.usr_available_ui(usr_available_ui);
	uiTest.usr_side_ui(usr_side_ui);
	uiTest.ui_freevc0_usr(ui_freevc0_usr);
	uiTest.ui_freevc1_usr(ui_freevc1_usr);
	
	uiTest.ui_sendingPostedDataError_csr(ui_sendingPostedDataError_csr);
	uiTest.ui_sendingTargetAbort_csr(ui_sendingTargetAbort_csr);

	uiTest.ui_receivedResponseDataError_csr(ui_receivedResponseDataError_csr);
	uiTest.ui_receivedPostedDataError_csr(ui_receivedPostedDataError_csr);
	uiTest.ui_receivedTargetAbort_csr(ui_receivedTargetAbort_csr);
	uiTest.ui_receivedMasterAbort_csr(ui_receivedMasterAbort_csr);

	uiTest.csr_request_databuffer0_access_ui(csr_request_databuffer0_access_ui);
	uiTest.csr_request_databuffer1_access_ui(csr_request_databuffer1_access_ui);
	uiTest.ui_databuffer_access_granted_csr(ui_databuffer_access_granted_csr);
	uiTest.ui_grant_csr_access_db0(ui_grant_csr_access_db0);
	uiTest.ui_grant_csr_access_db1(ui_grant_csr_access_db1);

	uiTest.ui_memory_write0(ui_memory_write0);
	uiTest.ui_memory_write1(ui_memory_write1);
	uiTest.ui_memory_write_address(ui_memory_write_address);
	uiTest.ui_memory_write_data(ui_memory_write_data);

	uiTest.ui_memory_read_address0(ui_memory_read_address0);
	uiTest.ui_memory_read_address1(ui_memory_read_address1);
	uiTest.ui_memory_read_data0(ui_memory_read_data0);
	uiTest.ui_memory_read_data1(ui_memory_read_data1);

	/**
	cout << "Linking ports... " << endl;
	UserInterfaceTestBindingHelper(ui,uiTest,clk);
	cout << "Done linking ports... " << endl;
	*/
	
	// tracing:
	// trace file creation
	sc_trace_file *tf = sc_create_vcd_trace_file("simplex");
	// External Signals
	sc_trace(tf, clk, "clk");
	sc_trace(tf, resetx, "resetx");
	sc_trace(tf, ui_packet_fc1, "ui_packet_fc1");
	sc_trace(tf, fc0_consume_data_ui, "fc0_consume_data_ui");
	sc_trace(tf, fc1_consume_data_ui, "fc1_consume_data_ui");
	sc_trace(tf, fc0_datavc_ui, "fc0_data_vc_ui");
	sc_trace(tf, fc1_datavc_ui, "fc1_data_vc_ui");
	sc_trace(tf, ui_available_fc0, "ui_available_fc0");
	sc_trace(tf, ui_available_fc1, "ui_available_fc1");
	sc_trace(tf, ui_data_fc0, "ui_data_fc0");
	sc_trace(tf, ui_memory_read_address0, "ui_memory_read_address0");
	sc_trace(tf, ui_memory_read_data0, "ui_memory_read_data0");
	sc_trace(tf, ui.tx_rd0pointer[VC_POSTED], "ui.tx_rd0pointer(POSTED)");
//	sc_trace(tf, ui.tx_increase_rd0pointer[VC_POSTED], "tx_increase_rd0pointer(POSTED)");

	
	sc_trace(tf, ui_memory_write0, "ui_memory_write0");
	sc_trace(tf, ui_memory_write_address, "ui_memory_write_address");
	sc_trace(tf, ui_memory_write_data, "ui_memory_write_data");
		
	sc_trace(tf, usr_available_ui, "usr_available_ui");
	sc_trace(tf, usr_packet_ui, "usr_packet_ui");

	sc_trace(tf, ro0_available_ui, "ro0_available_ui");
	sc_trace(tf, ro1_available_ui, "ro1_available_ui");
	sc_trace(tf, ro0_packet_ui, "ro0_packet_ui");
	sc_trace(tf, ro1_packet_ui, "ro1_packet_ui");
	sc_trace(tf, ui_consume_ro0, "ui_ack_ro0");
	sc_trace(tf, ui_consume_ro1, "ui_ack_ro1");

	sc_trace(tf, ui_available_usr, "ui_available_usr");
	sc_trace(tf, usr_consume_ui, "usr_consume_ui");
	sc_trace(tf, ui_packet_usr, "ui_packet_usr");

	sc_trace(tf, ui_address_db0, "ui_address_db0");
	sc_trace(tf, ui_consume_db0, "ui_read_db0");
	sc_trace(tf, ui_vctype_db0, "ui_vctype_db0");
	sc_trace(tf, db0_data_ui, "db0_data_ui");
	sc_trace(tf, ui_erase_db0, "ui_erase_db0");

	sc_trace(tf, fc0_user_fifo_ge2_ui, "fc0_user_fifo_ge2_ui");
	sc_trace(tf, fc1_user_fifo_ge2_ui, "fc1_user_fifo_ge2_ui");
	sc_trace(tf, ui_freevc0_usr, "ui_freevc0_usr");
	sc_trace(tf, ui_freevc1_usr, "ui_freevc1_usr");

	sc_trace(tf, ui.tx_count0[0], "ui.tx_count0(0)");
	sc_trace(tf, ui.tx_count0[1], "ui.tx_count0(1)");
	sc_trace(tf, ui.tx_count0[2], "ui.tx_count0(2)");
	sc_trace(tf, ui.tx_count1[0], "ui.tx_count1(0)");
	sc_trace(tf, ui.tx_count1[1], "ui.tx_count1(1)");
	sc_trace(tf, ui.tx_count1[2], "ui.tx_count1(2)");
	//------------------------------------------
	// Start simulation
	//------------------------------------------
	//sc_start(400);

	sc_initialize();
	for (int i = 0; i <= 4; i++){
		resetx = 0;
		clk = 1;
		sc_cycle(10);
		clk = 0;
		sc_cycle(10);
	}

	resetx = 1;
	
	for (int i = 0; i <= 100; i++){
		clk = 1;
		sc_cycle(10);
		clk = 0;
		sc_cycle(10);
	}

	sc_close_vcd_trace_file(tf);
	printf("fin de la simulation");
	return 0;
}


