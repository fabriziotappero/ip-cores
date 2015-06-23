//main.cpp for history_buffer_l3 testbench
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

#include "../../../rtl/systemc/flow_control_l2/history_buffer_l3.h"
#include "history_buffer_l3_tb.h"

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>

using namespace std;

int sc_main( int argc, char* argv[] ){

	//The Design Under Test
	history_buffer_l3* dut = new history_buffer_l3("history_buffer_l3");
	//The TestBench
	history_buffer_l3_tb* tb = new history_buffer_l3_tb("history_buffer_l3_tb");


	//Signals used to link the design to the testbench
	sc_clock clk("clk", 1);  // system clk
	sc_signal <sc_bv<32> > history_packet;
	sc_signal <bool > history_playback_done;
	sc_signal <bool > begin_history_playback;
	sc_signal <bool > stop_history_playback;
	sc_signal <bool > history_playback_ready;
	sc_signal <bool > consume_history;
	sc_signal <bool > room_available_in_history;
	sc_signal <bool > add_to_history;
	
	sc_signal <bool > new_history_entry;
	sc_signal <sc_uint<5> > new_history_entry_size_m1;
	sc_signal<sc_bv<32> > fc_dword_lk;
	sc_signal<bool>	nop_received;
	sc_signal<sc_uint<8> >	ack_value;
	sc_signal<bool>	resetx;

	sc_signal<bool> history_memory_write;
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_write_address;
	sc_signal<sc_bv<32> > history_memory_write_data;
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_read_address;
	sc_signal<sc_bv<32> > history_memory_output;

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	// DUT connections
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	//Signals used to link the design to the testbench
	dut->clk(clk);
	dut->history_packet(history_packet);
	dut->history_playback_done(history_playback_done);
	dut->begin_history_playback(begin_history_playback);
	dut->stop_history_playback(stop_history_playback);
	dut->history_playback_ready(history_playback_ready);
	dut->consume_history(consume_history);
	dut->room_available_in_history(room_available_in_history);
	dut->add_to_history(add_to_history);
	
	dut->new_history_entry(new_history_entry);
	dut->new_history_entry_size_m1(new_history_entry_size_m1);
	dut->fc_dword_lk(fc_dword_lk);
	dut->nop_received(nop_received);
	dut->ack_value(ack_value);
	dut->resetx(resetx);

	dut->history_memory_write(history_memory_write);
	dut->history_memory_write_address(history_memory_write_address);
	dut->history_memory_write_data(history_memory_write_data);
	dut->history_memory_read_address(history_memory_read_address);
	dut->history_memory_output(history_memory_output);


	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	//  TB connections
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	tb->clk(clk);
	tb->history_packet(history_packet);
	tb->history_playback_done(history_playback_done);
	tb->begin_history_playback(begin_history_playback);
	tb->history_playback_ready(history_playback_ready);
	tb->consume_history(consume_history);
	tb->room_available_in_history(room_available_in_history);
	tb->add_to_history(add_to_history);
	
	tb->new_history_entry(new_history_entry);
	tb->new_history_entry_size_m1(new_history_entry_size_m1);
	tb->fc_dword_lk(fc_dword_lk);
	tb->nop_received(nop_received);
	tb->ack_value(ack_value);
	tb->resetx(resetx);

	tb->history_memory_write(history_memory_write);
	tb->history_memory_write_address(history_memory_write_address);
	tb->history_memory_write_data(history_memory_write_data);
	tb->history_memory_read_address(history_memory_read_address);
	tb->history_memory_output(history_memory_output);

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	//  Trace signals
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	sc_trace_file *tf = sc_create_vcd_trace_file("sim_history_buffer_l3");

	sc_trace(tf,clk,"clk");
	sc_trace(tf,history_packet,"history_packet");
	sc_trace(tf,history_playback_done,"history_playback_done");
	sc_trace(tf,begin_history_playback,"begin_history_playback");
	sc_trace(tf,history_playback_ready,"history_playback_ready");
	
	sc_trace(tf,consume_history,"consume_history");
	sc_trace(tf,room_available_in_history,"room_available_in_history");
	sc_trace(tf,add_to_history,"add_to_history");
	
	sc_trace(tf,new_history_entry,"new_history_entry");
	sc_trace(tf,new_history_entry_size_m1,"new_history_entry_size_m1");
	sc_trace(tf,fc_dword_lk,"fc_dword_lk");
	sc_trace(tf,nop_received,"nop_received");
	sc_trace(tf,ack_value,"ack_value");
	sc_trace(tf,resetx,"resetx");

	sc_trace(tf,history_memory_write,"history_memory_write");
	sc_trace(tf,history_memory_write_address,"history_memory_write_address");
	sc_trace(tf,history_memory_write_data,"history_memory_write_data");
	sc_trace(tf,history_memory_read_address,"history_memory_read_address");
	sc_trace(tf,history_memory_output,"history_memory_output");

	sc_trace(tf,dut->idle_read_pointer,"DUT.idle_read_pointer");
	sc_trace(tf,dut->write_pointer,"DUT.write_pointer");

	//------------------------------------------
	// Start simulation
	//------------------------------------------
	cout << "Start of History Buffer simulation" << endl;
	sc_start(400);


	sc_close_vcd_trace_file(tf);
	cout << "End of simulation" << endl;

	delete dut;
	delete tb;
	return 0;
}

