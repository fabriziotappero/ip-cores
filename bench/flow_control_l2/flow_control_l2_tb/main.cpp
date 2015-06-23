//main.cpp for flow_control_l2 testbench
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

#include "../../../rtl/systemc/flow_control_l2/flow_control_l2.h"
#include "../../../rtl/systemc/flow_control_l2/user_fifo_l3.h"
#include "../../../rtl/systemc/flow_control_l2/fc_packet_crc_l3.h"
#include "../../../rtl/systemc/flow_control_l2/multiplexer_l3.h"
#include "../../../rtl/systemc/flow_control_l2/history_buffer_l3.h"
#include "../../../rtl/systemc/flow_control_l2/nop_framer_l3.h"
#include "flow_control_l2_tb.h"

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>

using namespace std;

int sc_main( int argc, char* argv[] ){

	//The Design Under Test
	flow_control_l2* dut = new flow_control_l2("flow_control_l2");
	//The TestBench
	flow_control_l2_tb* tb = new flow_control_l2_tb("flow_control_l2_tb");


	//Signals used to link the design to the testbench
	sc_clock clk("clk", 1);  // system clk
	sc_signal<bool> resetx;
	sc_signal<bool> ldtstopx;
    sc_signal <sc_bv<64> >			ui_packet_fc;
	sc_signal <bool>				ui_available_fc;
	sc_signal <sc_bv<3> >			fc_user_fifo_ge2_ui;
	sc_signal <VirtualChannel>		fc_data_vc_ui;
	sc_signal <sc_bv<32> >			ui_data_fc; 
	sc_signal <bool>				fc_consume_data_ui;
    sc_signal <bool> ro_available_fwd;
    sc_signal <syn_ControlPacketComplete > ro_packet_fwd;
	sc_signal<VirtualChannel> ro_packet_vc_fwd;
    sc_signal <bool> fwd_ack_ro;
    sc_signal <sc_bv<32> > fc_dword_lk;
    sc_signal <bool> fc_lctl_lk;
    sc_signal <bool> fc_hctl_lk;
    sc_signal  <bool> lk_consume_fc;
#ifdef RETRY_MODE_ENABLED
    sc_signal <bool> fc_disconnect_lk;
	sc_signal  <bool> lk_rx_connected;
	sc_signal  <bool> lk_initiate_retry_disconnect;
	sc_signal <bool> csr_retry;
	sc_signal <bool>	cd_initiate_retry_disconnect;
#endif
    		
    sc_signal <sc_uint<BUFFERS_ADDRESS_WIDTH> > fwd_address_db;
    sc_signal <VirtualChannel>  fwd_vctype_db;
    sc_signal <bool> fwd_read_db;
    sc_signal <bool> fwd_erase_db;
    sc_signal <sc_bv<32> > db_data_fwd;
    sc_signal <sc_bv<6> > ro_buffer_cnt_fc;
    sc_signal <sc_bv<6> > db_buffer_cnt_fc;
    
	sc_signal <bool> fc_ack_eh;
	sc_signal <sc_bv<32> > eh_cmd_data_fc;
	sc_signal <bool> eh_available_fc;
    
	sc_signal <bool> fc_ack_csr;	
	sc_signal <bool> csr_available_fc;
	sc_signal <sc_bv<32> > csr_dword_fc;
	sc_signal <bool> csr_transmitteroff;
	
	sc_signal<bool>			csr_force_single_stomp_fc;
	sc_signal<bool>			csr_force_single_error_fc;
	sc_signal<bool>		fc_clear_single_error_csr;
	sc_signal<bool>		fc_clear_single_stomp_csr;

		
	sc_signal <bool> db_nop_req_fc;
	sc_signal <bool> ro_nop_req_fc;
	sc_signal <bool> fc_nop_sent;
	
	sc_signal<sc_bv<12> > cd_nopinfo_fc;
    sc_signal<bool> cd_nop_received_fc;
	sc_signal <sc_bv<6> > fwd_next_node_buffer_status_ro;

#ifdef RETRY_MODE_ENABLED
	sc_signal<sc_uint<8> > cd_nop_ack_value_fc;
	sc_signal<sc_uint<8> > cd_rx_next_pkt_to_ack_fc;

	sc_signal<bool> history_memory_write;
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_write_address;
	sc_signal<sc_bv<32> > history_memory_write_data;
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_read_address;
	sc_signal<sc_bv<32> > history_memory_output;
#endif

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	// DUT connections
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	//Signals used to link the design to the testbench
	dut->clk(clk);
	dut->resetx(resetx);
	dut->ldtstopx(ldtstopx);
    dut->ui_packet_fc(ui_packet_fc);
	dut->ui_available_fc(ui_available_fc);
	dut->fc_user_fifo_ge2_ui(fc_user_fifo_ge2_ui);
	dut->fc_data_vc_ui(fc_data_vc_ui);
	dut->ui_data_fc(ui_data_fc);
	dut->fc_consume_data_ui(fc_consume_data_ui);
    dut->ro_available_fwd(ro_available_fwd);
    dut->ro_packet_fwd(ro_packet_fwd);
    dut->ro_packet_vc_fwd(ro_packet_vc_fwd);
    dut->fwd_ack_ro(fwd_ack_ro);
    dut->fc_dword_lk(fc_dword_lk);
    dut->fc_lctl_lk(fc_lctl_lk);
    dut->fc_hctl_lk(fc_hctl_lk);
    dut->lk_consume_fc(lk_consume_fc);
#ifdef RETRY_MODE_ENABLED
    dut->fc_disconnect_lk(fc_disconnect_lk);
	dut->lk_rx_connected(lk_rx_connected);
	dut->lk_initiate_retry_disconnect(lk_initiate_retry_disconnect);
	dut->csr_retry(csr_retry);
	dut->cd_initiate_retry_disconnect(cd_initiate_retry_disconnect);
#endif
    		
    dut->fwd_address_db(fwd_address_db);
    dut->fwd_vctype_db(fwd_vctype_db);
    dut->fwd_read_db(fwd_read_db);
	dut->fwd_erase_db(fwd_erase_db);
    dut->db_data_fwd(db_data_fwd);
    dut->ro_buffer_cnt_fc(ro_buffer_cnt_fc);
    dut->db_buffer_cnt_fc(db_buffer_cnt_fc);
    
	dut->fc_ack_eh(fc_ack_eh);
	dut->eh_cmd_data_fc(eh_cmd_data_fc);
	dut->eh_available_fc(eh_available_fc);
    
	dut->fc_ack_csr(fc_ack_csr);
	dut->csr_available_fc(csr_available_fc);
	dut->csr_dword_fc(csr_dword_fc);
	//dut->csr_transmitteroff(csr_transmitteroff);
	
	dut->csr_force_single_stomp_fc(csr_force_single_stomp_fc);
	dut->csr_force_single_error_fc(csr_force_single_error_fc);
	dut->fc_clear_single_error_csr(fc_clear_single_error_csr);
	dut->fc_clear_single_stomp_csr(fc_clear_single_stomp_csr);

		
	dut->db_nop_req_fc(db_nop_req_fc);
	dut->ro_nop_req_fc(ro_nop_req_fc);
	dut->fc_nop_sent(fc_nop_sent);
	
	dut->cd_nopinfo_fc(cd_nopinfo_fc);
    dut->cd_nop_received_fc(cd_nop_received_fc);
	dut->fwd_next_node_buffer_status_ro(fwd_next_node_buffer_status_ro);

#ifdef RETRY_MODE_ENABLED
	dut->cd_nop_ack_value_fc(cd_nop_ack_value_fc);
	dut->cd_rx_next_pkt_to_ack_fc(cd_rx_next_pkt_to_ack_fc);

	dut->history_memory_write(history_memory_write);
	dut->history_memory_write_address(history_memory_write_address);
	dut->history_memory_write_data(history_memory_write_data);
	dut->history_memory_read_address(history_memory_read_address);
	dut->history_memory_output(history_memory_output);
#endif


	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	//  TB connections
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	tb->clk(clk);
	tb->resetx(resetx);
	tb->ldtstopx(ldtstopx);
    tb->ui_packet_fc(ui_packet_fc);
	tb->ui_available_fc(ui_available_fc);
	tb->fc_user_fifo_ge2_ui(fc_user_fifo_ge2_ui);
	tb->fc_data_vc_ui(fc_data_vc_ui);
	tb->ui_data_fc(ui_data_fc);
	tb->fc_consume_data_ui(fc_consume_data_ui);
    tb->ro_available_fwd(ro_available_fwd);
    tb->ro_packet_fwd(ro_packet_fwd);
    tb->ro_packet_vc_fwd(ro_packet_vc_fwd);
    tb->fwd_ack_ro(fwd_ack_ro);
    tb->fc_dword_lk(fc_dword_lk);
    tb->fc_lctl_lk(fc_lctl_lk);
    tb->fc_hctl_lk(fc_hctl_lk);
    tb->lk_consume_fc(lk_consume_fc);
#ifdef RETRY_MODE_ENABLED
    tb->fc_disconnect_lk(fc_disconnect_lk);
	tb->lk_rx_connected(lk_rx_connected);
	tb->lk_initiate_retry_disconnect(lk_initiate_retry_disconnect);
	tb->csr_retry(csr_retry);
	tb->cd_initiate_retry_disconnect(cd_initiate_retry_disconnect);
#endif
    		
    tb->fwd_address_db(fwd_address_db);
    tb->fwd_vctype_db(fwd_vctype_db);
    tb->fwd_read_db(fwd_read_db);
    tb->db_data_fwd(db_data_fwd);
    tb->ro_buffer_cnt_fc(ro_buffer_cnt_fc);
    tb->db_buffer_cnt_fc(db_buffer_cnt_fc);
    
	tb->fc_ack_eh(fc_ack_eh);
	tb->eh_cmd_data_fc(eh_cmd_data_fc);
	tb->eh_available_fc(eh_available_fc);
    
	tb->fc_ack_csr(fc_ack_csr);
	tb->csr_available_fc(csr_available_fc);
	tb->csr_dword_fc(csr_dword_fc);
	tb->csr_transmitteroff(csr_transmitteroff);
	
	tb->csr_force_single_stomp_fc(csr_force_single_stomp_fc);
	tb->csr_force_single_error_fc(csr_force_single_error_fc);
	tb->fc_clear_single_error_csr(fc_clear_single_error_csr);
	tb->fc_clear_single_stomp_csr(fc_clear_single_stomp_csr);

		
	tb->db_nop_req_fc(db_nop_req_fc);
	tb->ro_nop_req_fc(ro_nop_req_fc);
	tb->fc_nop_sent(fc_nop_sent);
	
	tb->cd_nopinfo_fc(cd_nopinfo_fc);
    tb->cd_nop_received_fc(cd_nop_received_fc);
	tb->fwd_next_node_buffer_status_ro(fwd_next_node_buffer_status_ro);

#ifdef RETRY_MODE_ENABLED
	tb->cd_nop_ack_value_fc(cd_nop_ack_value_fc);
	tb->cd_rx_next_pkt_to_ack_fc(cd_rx_next_pkt_to_ack_fc);

	tb->history_memory_write(history_memory_write);
	tb->history_memory_write_address(history_memory_write_address);
	tb->history_memory_write_data(history_memory_write_data);
	tb->history_memory_read_address(history_memory_read_address);
	tb->history_memory_output(history_memory_output);
#endif

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	//  Trace signals
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	sc_trace_file *tf = sc_create_vcd_trace_file("sim_flow_control_l2");

	sc_trace(tf,clk,"clk");
	sc_trace(tf,resetx,"resetx");
	sc_trace(tf,ldtstopx,"ldtstopx");
    sc_trace(tf,ui_packet_fc,"ui_packet_fc");
	sc_trace(tf,ui_available_fc,"ui_available_fc");
	sc_trace(tf,fc_user_fifo_ge2_ui,"fc_user_fifo_ge2_ui");
	sc_trace(tf,fc_data_vc_ui,"fc_data_vc_ui");
	sc_trace(tf,ui_data_fc,"ui_data_fc");
	sc_trace(tf,fc_consume_data_ui,"fc_consume_data_ui");
    sc_trace(tf,ro_available_fwd,"ro_available_fwd");
    sc_trace(tf,ro_packet_fwd,"ro_packet_fwd");
    sc_trace(tf,fwd_ack_ro,"fwd_ack_ro");
    sc_trace(tf,fc_dword_lk,"fc_dword_lk");
    sc_trace(tf,fc_lctl_lk,"fc_lctl_lk");
    sc_trace(tf,fc_hctl_lk,"fc_hctl_lk");
    sc_trace(tf,lk_consume_fc,"lk_consume_fc");
#ifdef RETRY_MODE_ENABLED
    sc_trace(tf,fc_disconnect_lk,"fc_disconnect_lk");
	sc_trace(tf,lk_rx_connected,"lk_rx_connected");
	sc_trace(tf,lk_initiate_retry_disconnect,"lk_initiate_retry_disconnect");
	sc_trace(tf,csr_retry,"csr_retry");
	sc_trace(tf,cd_initiate_retry_disconnect,"cd_initiate_retry_disconnect");
#endif
    		
    sc_trace(tf,fwd_address_db,"fwd_address_db");
    sc_trace(tf,fwd_vctype_db,"fwd_vctype_db");
    sc_trace(tf,fwd_read_db,"fwd_read_db");
    sc_trace(tf,db_data_fwd,"db_data_fwd");
    sc_trace(tf,ro_buffer_cnt_fc,"ro_buffer_cnt_fc");
    sc_trace(tf,db_buffer_cnt_fc,"db_buffer_cnt_fc");
    
	sc_trace(tf,fc_ack_eh,"fc_ack_eh");
	sc_trace(tf,eh_cmd_data_fc,"eh_cmd_data_fc");
	sc_trace(tf,eh_available_fc,"eh_available_fc");
    
	sc_trace(tf,fc_ack_csr,"fc_ack_csr");
	sc_trace(tf,csr_available_fc,"csr_available_fc");
	sc_trace(tf,csr_dword_fc,"csr_dword_fc");
	sc_trace(tf,csr_transmitteroff,"csr_transmitteroff");
	
	sc_trace(tf,csr_force_single_stomp_fc,"csr_force_single_stomp_fc");
	sc_trace(tf,csr_force_single_error_fc,"csr_force_single_error_fc");
	sc_trace(tf,fc_clear_single_error_csr,"fc_clear_single_error_csr");
	sc_trace(tf,fc_clear_single_stomp_csr,"fc_clear_single_stomp_csr");

		
	sc_trace(tf,db_nop_req_fc,"db_nop_req_fc");
	sc_trace(tf,ro_nop_req_fc,"ro_nop_req_fc");
	sc_trace(tf,fc_nop_sent,"fc_nop_sent");
	
	sc_trace(tf,cd_nopinfo_fc,"cd_nopinfo_fc");
    sc_trace(tf,cd_nop_received_fc,"cd_nop_received_fc");
	sc_trace(tf,fwd_next_node_buffer_status_ro,"fwd_next_node_buffer_status_ro");

#ifdef RETRY_MODE_ENABLED
	sc_trace(tf,cd_nop_ack_value_fc,"cd_nop_ack_value_fc");
	sc_trace(tf,cd_rx_next_pkt_to_ack_fc,"cd_rx_next_pkt_to_ack_fc");

	sc_trace(tf,history_memory_write,"history_memory_write");
	sc_trace(tf,history_memory_write_address,"history_memory_write_address");
	sc_trace(tf,history_memory_write_data,"history_memory_write_data");
	sc_trace(tf,history_memory_read_address,"history_memory_read_address");
	sc_trace(tf,history_memory_output,"history_memory_output");
#endif


/*	sc_trace(tf,dut->the_user_fifo->packet_buffer_nposted[0],"FIFO.packet_buffer_nposted(0)");
	sc_trace(tf,dut->the_user_fifo->packet_buffer_nposted[1],"FIFO.packet_buffer_nposted(1)");
	sc_trace(tf,dut->the_user_fifo->packet_buffer_nposted[2],"FIFO.packet_buffer_nposted(2)");
	sc_trace(tf,dut->the_user_fifo->write_pointer_nposted,"FIFO.write_pointer_nposted");
	sc_trace(tf,dut->the_user_fifo->read_pointer_nposted,"FIFO.read_pointer_nposted");
	sc_trace(tf,dut->the_user_fifo->buffer_count_nposted,"FIFO.buffer_count_nposted");
	sc_trace(tf,dut->the_user_fifo->fifo_user_packet,"FIFO.fifo_user_packet");
	sc_trace(tf,dut->the_user_fifo->fifo_user_available,"FIFO.fifo_user_available");
	sc_trace(tf,dut->the_user_fifo->consume_user_fifo,"FIFO.consume_user_fifo");*/

	sc_trace(tf,dut->the_fc_packet_crc->data_in,"CRC.data_in");
	sc_trace(tf,dut->the_fc_packet_crc->fc_hctl_lk,"CRC.fc_hctl_lk");
	sc_trace(tf,dut->the_fc_packet_crc->fc_lctl_lk,"CRC.fc_lctl_lk");

	sc_trace(tf,dut->the_fc_packet_crc->calculate_crc,"CRC.calculate_crc");
	sc_trace(tf,dut->the_fc_packet_crc->clear_crc,"CRC.clear_crc");
	sc_trace(tf,dut->the_fc_packet_crc->calculate_nop_crc,"CRC.calculate_nop_crc");
	sc_trace(tf,dut->the_fc_packet_crc->clear_nop_crc,"CRC.clear_nop_crc");
	sc_trace(tf,dut->the_fc_packet_crc->crc_output,"CRC.crc_output");
	sc_trace(tf,dut->the_fc_packet_crc->nop_crc_output,"CRC.nop_crc_output");
	sc_trace(tf,dut->the_fc_packet_crc->csr_force_single_stomp_fc,"CRC.csr_force_single_stomp_fc");
	sc_trace(tf,dut->the_fc_packet_crc->csr_force_single_error_fc,"CRC.csr_force_single_error_fc");

	sc_trace(tf,dut->the_multiplexer->select_crc_output,"CRC_MUX.select_crc_output");
	sc_trace(tf,dut->the_multiplexer->select_nop_crc_output,"CRC_MUX.select_nop_crc_output");

	sc_trace(tf,dut->the_history_buffer->history_packet,"HISTORY.history_packet");
	sc_trace(tf,dut->the_history_buffer->history_playback_done,"HISTORY.history_playback_done");
	sc_trace(tf,dut->the_history_buffer->begin_history_playback,"HISTORY.begin_history_playback");
	sc_trace(tf,dut->the_history_buffer->history_playback_ready,"HISTORY.history_playback_ready");
	sc_trace(tf,dut->the_history_buffer->consume_history,"HISTORY.consume_history");
	sc_trace(tf,dut->the_history_buffer->room_available_in_history,"HISTORY.room_available_in_history");
	sc_trace(tf,dut->the_history_buffer->add_to_history,"HISTORY.add_to_history");
	sc_trace(tf,dut->the_history_buffer->new_history_entry,"HISTORY.new_history_entry");
	sc_trace(tf,dut->the_history_buffer->new_history_entry_size_m1,"HISTORY.new_history_entry_size_m1");
	sc_trace(tf,dut->the_history_buffer->fc_dword_lk,"HISTORY.fc_dword_lk");
	sc_trace(tf,dut->the_history_buffer->nop_received,"HISTORY.nop_received");
	sc_trace(tf,dut->the_history_buffer->ack_value,"HISTORY.ack_value");
	sc_trace(tf,dut->the_history_buffer->TxNextPktToAck,"HISTORY.TxNextPktToAck");

	sc_trace(tf,dut->the_history_buffer->idle_read_pointer,"HISTORY_INTERN.idle_read_pointer");
	sc_trace(tf,dut->the_history_buffer->write_pointer,"HISTORY_INTERN.write_pointer");

	sc_trace(tf,dut->the_nop_framer->ht_nop_pkt,"NOP.ht_nop_pkt");

	//------------------------------------------
	// Start simulation
	//------------------------------------------
	cout << "Start of Flow Control simulation" << endl;
	sc_start(300);


	sc_close_vcd_trace_file(tf);
	cout << "End of simulation" << endl;

	if(tb->error)
		cout << "Test FAILED!" << endl;
	else
		cout << "Test SUCCESSFUL!" << endl;

	delete dut;
	delete tb;
	return 0;
}

