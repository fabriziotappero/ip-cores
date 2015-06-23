//main.cpp for user_fifo_l3 testbench
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

#include "../../../rtl/systemc/core_synth/synth_datatypes.h"
#include "../../../rtl/systemc/core_synth/constants.h"

#include "../../../rtl/systemc/flow_control_l2/user_fifo_l3.h"
#include "user_fifo_l3_tb.h"

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>

using namespace std;

int sc_main( int argc, char* argv[] ){

	//The Design Under Test
	user_fifo_l3* dut = new user_fifo_l3("user_fifo_l3");
	//The TestBench
	user_fifo_l3_tb* tb = new user_fifo_l3_tb("user_fifo_l3_tb");


	//Signals used to link the design to the testbench
	sc_clock clk("clk", 1);  // system clk
	sc_signal <bool> resetx;
	sc_signal<sc_bv<3> >	fc_user_fifo_ge2_ui;
	sc_signal<bool>			ui_available_fc;
	sc_signal<sc_bv<64> >		ui_packet_fc;
    
    sc_signal<sc_bv<64> > fifo_user_packet;
	sc_signal<bool> fifo_user_available;
 	sc_signal<VirtualChannel> fifo_user_packet_vc;
	sc_signal<bool> fifo_user_packet_dword;
	sc_signal<bool> fifo_user_packet_data_asociated;
#ifdef RETRY_MODE_ENABLED
    ///The command of fifo_user_packet
	sc_signal<PacketCommand > fifo_user_packet_command;
#endif
	sc_signal<sc_uint<4> > fifo_user_packet_data_count_m1;
	sc_signal<bool> fifo_user_packet_isChain;
    sc_signal<sc_bv<6> > fwd_next_node_buffer_status_ro;
	sc_signal<bool>		consume_user_fifo;
	sc_signal<bool> hold_user_fifo;

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	//  USER FIFO DUT connections
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	//Signals used to link the design to the testbench
	dut->clock(clk);
	dut->resetx(resetx);
	dut->fc_user_fifo_ge2_ui(fc_user_fifo_ge2_ui);
	dut->ui_available_fc(ui_available_fc);
	dut->ui_packet_fc(ui_packet_fc);
    
    dut->fifo_user_packet(fifo_user_packet);
	dut->fifo_user_available(fifo_user_available);
 	dut->fifo_user_packet_vc(fifo_user_packet_vc);
	dut->fifo_user_packet_dword(fifo_user_packet_dword);
	dut->fifo_user_packet_data_asociated(fifo_user_packet_data_asociated);
	dut->fifo_user_packet_command(fifo_user_packet_command);
	dut->fifo_user_packet_data_count_m1(fifo_user_packet_data_count_m1);
	dut->fifo_user_packet_isChain(fifo_user_packet_isChain);
    dut->fwd_next_node_buffer_status_ro(fwd_next_node_buffer_status_ro);
    dut->consume_user_fifo(consume_user_fifo);
    dut->hold_user_fifo(hold_user_fifo);



	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	//  USER FIFO TB connections
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	tb->clk(clk);
	tb->resetx(resetx);
	tb->fc_user_fifo_ge2_ui(fc_user_fifo_ge2_ui);
	tb->ui_available_fc(ui_available_fc);
	tb->ui_packet_fc(ui_packet_fc);
    
    tb->fifo_user_packet(fifo_user_packet);
	tb->fifo_user_available(fifo_user_available);
 	tb->fifo_user_packet_vc(fifo_user_packet_vc);
	tb->fifo_user_packet_dword(fifo_user_packet_dword);
	tb->fifo_user_packet_data_asociated(fifo_user_packet_data_asociated);
	tb->fifo_user_packet_data_count_m1(fifo_user_packet_data_count_m1);
	tb->fifo_user_packet_isChain(fifo_user_packet_isChain);
    tb->fwd_next_node_buffer_status_ro(fwd_next_node_buffer_status_ro);
    tb->consume_user_fifo(consume_user_fifo);
    tb->hold_user_fifo(hold_user_fifo);

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	//  Trace signals
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	sc_trace_file *tf = sc_create_vcd_trace_file("sim_user_fifo_l3");

	sc_trace(tf,clk,"clk");
	sc_trace(tf,resetx,"resetx");
	sc_trace(tf,fc_user_fifo_ge2_ui,"fc_user_fifo_ge2_ui");
	sc_trace(tf,ui_available_fc,"ui_available_fc");
	sc_trace(tf,ui_packet_fc,"ui_packet_fc");
    
    sc_trace(tf,fifo_user_packet,"fifo_user_packet");
	sc_trace(tf,fifo_user_available,"fifo_user_available");
 	sc_trace(tf,fifo_user_packet_vc,"fifo_user_packet_vc");
	sc_trace(tf,fifo_user_packet_dword,"fifo_user_packet_dword");
	sc_trace(tf,fifo_user_packet_data_asociated,"fifo_user_packet_data_asociated");
	sc_trace(tf,fifo_user_packet_data_count_m1,"fifo_user_packet_data_count_m1");
	sc_trace(tf,fifo_user_packet_isChain,"fifo_user_packet_isChain");
    sc_trace(tf,fwd_next_node_buffer_status_ro,"fwd_next_node_buffer_status_ro");

    sc_trace(tf,dut->write_pointer_posted,"write_pointer_posted");
    sc_trace(tf,dut->write_pointer_nposted,"write_pointer_nposted");
    sc_trace(tf,dut->write_pointer_response,"write_pointer_response");

    sc_trace(tf,dut->read_pointer_posted,"read_pointer_posted");
    sc_trace(tf,dut->read_pointer_nposted,"read_pointer_nposted");
    sc_trace(tf,dut->read_pointer_response,"read_pointer_response");

    sc_trace(tf,dut->buffer_count_posted,"buffer_count_posted");
    sc_trace(tf,dut->buffer_count_nposted,"buffer_count_nposted");
    sc_trace(tf,dut->buffer_count_response,"buffer_count_response");

	sc_trace(tf,dut->posted_pointer_when_response_received[0],"posted_pointer_when_response_received(0)");
	sc_trace(tf,dut->posted_pointer_when_response_received[1],"posted_pointer_when_response_received(1)");
	sc_trace(tf,dut->posted_pointer_when_response_received[2],"posted_pointer_when_response_received(2)");
	sc_trace(tf,dut->posted_pointer_when_response_received[3],"posted_pointer_when_response_received(3)");
	sc_trace(tf,dut->response_after_posted[0],"response_after_posted(0)");
	sc_trace(tf,dut->response_after_posted[1],"response_after_posted(1)");
	sc_trace(tf,dut->response_after_posted[2],"response_after_posted(2)");
	sc_trace(tf,dut->response_after_posted[3],"response_after_posted(3)");

    sc_trace(tf,consume_user_fifo,"consume_user_fifo");

	//------------------------------------------
	// Start simulation
	//------------------------------------------
	cout << "Start of simulation" << endl;
	sc_start(200);


	sc_close_vcd_trace_file(tf);
	cout << "End of simulation" << endl;

	cout << "Fifo depth : " << USER_FIFO_DEPTH << endl;
	if(tb->error) cout << "Test FAILED!" << endl;
	else cout << "Test SUCCESSFUL!" << endl;

	delete dut;
	delete tb;
	return 0;
}

