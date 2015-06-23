//main.cpp for reordering_l2 testbench
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

#include "../../rtl/systemc/core_synth/synth_datatypes.h"
#include "../../rtl/systemc/core_synth/constants.h"

#include "../../rtl/systemc/reordering_l2/reordering_l2.h"
#include "../../rtl/systemc/reordering_l2/posted_vc_l3.h"
#include "../../rtl/systemc/reordering_l2/response_vc_l3.h"
#include "../../rtl/systemc/reordering_l2/nposted_vc_l3.h"
#include "../../rtl/systemc/reordering_l2/nophandler_l3.h"
#include "../../rtl/systemc/reordering_l2/final_reordering_l3.h"
#include "../../rtl/systemc/reordering_l2/address_manager_l3.h"

#include "reordering_l2_tb.h"

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>

using namespace std;

int sc_main( int argc, char* argv[] ){

	//The Design Under Test
	reordering_l2* dut = new reordering_l2("reordering_l2");
	//The TestBench
	reordering_l2_tb* tb = new reordering_l2_tb("reordering_l2_tb");


	//Signals used to link the design to the testbench
	sc_clock clk("clk", 1);  // system clk
	sc_signal<bool> resetx;
	sc_signal<syn_ControlPacketComplete> ro_packet_csr;
	sc_signal<syn_ControlPacketComplete> ro_packet_ui;
	sc_signal<syn_ControlPacketComplete> ro_packet_fwd;
	sc_signal<VirtualChannel> ro_packet_vc_fwd;

	sc_signal<bool> ro_available_csr;
	sc_signal<bool> ro_available_ui;
	sc_signal<bool> ro_available_fwd;

	sc_signal<bool> csr_ack_ro;
	sc_signal<bool> ui_ack_ro;	
	sc_signal<bool> fwd_ack_ro;

	sc_signal<bool> eh_ack_ro;
	sc_signal<bool> fc_nop_sent;
	sc_signal<syn_ControlPacketComplete> cd_packet_ro;
	sc_signal<bool> cd_available_ro;
	sc_signal<bool>						cd_data_pending_ro;
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> >	cd_data_pending_addr_ro;
	sc_signal<sc_bv<5> > csr_unit_id;
	sc_signal<sc_bv<40> >	csr_bar[NbRegsBars];
	sc_signal<bool>			csr_memory_space_enable;
	sc_signal<bool>			csr_io_space_enable;
	sc_signal<sc_bv<32> > csr_direct_route_enable;
	sc_signal<sc_bv<5> > clumped_unit_id[32];
	sc_signal<bool>	csr_sync;

#ifdef ENABLE_REORDERING
	sc_signal<bool> csr_unitid_reorder_disable;
#endif
	sc_signal<sc_bv <6> > fwd_next_node_buffer_status_ro;
	
	sc_signal<sc_bv <6> > ro_buffer_cnt_fc;
	sc_signal<bool> ro_nop_req_fc;

	sc_signal<bool> ro_overflow_csr;

#ifdef RETRY_MODE_ENABLED
	sc_signal< bool >								lk_rx_connected;
	sc_signal< bool >								csr_retry;
	sc_signal<bool>		cd_received_non_flow_stomped_ro;
#endif

	sc_signal<sc_bv<CMD_BUFFER_MEM_WIDTH> > ro_command_packet_wr_data;
	sc_signal<bool > ro_command_packet_write;
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro_command_packet_wr_addr;
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro_command_packet_rd_addr[2];
	sc_signal<sc_bv<CMD_BUFFER_MEM_WIDTH> > command_packet_rd_data_ro[2];

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	// DUT connections
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	//Signals used to link the design to the testbench
	dut->clk(clk);
	dut->resetx(resetx);
	dut->ro_packet_csr(ro_packet_csr);
	dut->ro_packet_ui(ro_packet_ui);
	dut->ro_packet_fwd(ro_packet_fwd);
	dut->ro_packet_vc_fwd(ro_packet_vc_fwd);
	dut->ro_available_csr(ro_available_csr);
	dut->ro_available_ui(ro_available_ui);
	dut->ro_available_fwd(ro_available_fwd);

	dut->csr_ack_ro(csr_ack_ro);
	dut->ui_ack_ro(ui_ack_ro);
	dut->fwd_ack_ro(fwd_ack_ro);

	dut->eh_ack_ro(eh_ack_ro);
	dut->fc_nop_sent(fc_nop_sent);
	dut->cd_packet_ro(cd_packet_ro);
	dut->cd_available_ro(cd_available_ro);
	dut->cd_data_pending_ro(cd_data_pending_ro);
	dut->cd_data_pending_addr_ro(cd_data_pending_addr_ro);
	dut->csr_unit_id(csr_unit_id);
	for(int n = 0; n < NbRegsBars; n++)
		dut->csr_bar[n](csr_bar[n]);
	dut->csr_memory_space_enable(csr_memory_space_enable);
	dut->csr_io_space_enable(csr_io_space_enable);
	dut->csr_direct_route_enable(csr_direct_route_enable);
	dut->csr_sync(csr_sync);

	for(int n = 0; n < 32; n++)
		dut->clumped_unit_id[n](clumped_unit_id[n]);

#ifdef ENABLE_REORDERING
	dut->csr_unitid_reorder_disable(csr_unitid_reorder_disable);
#endif
	dut->fwd_next_node_buffer_status_ro(fwd_next_node_buffer_status_ro);
	
	dut->ro_buffer_cnt_fc(ro_buffer_cnt_fc);
	dut->ro_nop_req_fc(ro_nop_req_fc);

	dut->ro_overflow_csr(ro_overflow_csr);

#ifdef RETRY_MODE_ENABLED
	dut->lk_rx_connected(lk_rx_connected);
	dut->csr_retry(csr_retry);
	dut->cd_received_non_flow_stomped_ro(cd_received_non_flow_stomped_ro);
#endif

	dut->ro_command_packet_wr_data(ro_command_packet_wr_data);
	dut->ro_command_packet_write(ro_command_packet_write);
	dut->ro_command_packet_wr_addr(ro_command_packet_wr_addr);
	dut->ro_command_packet_rd_addr[0](ro_command_packet_rd_addr[0]);
	dut->ro_command_packet_rd_addr[1](ro_command_packet_rd_addr[1]);
	dut->command_packet_rd_data_ro[0](command_packet_rd_data_ro[0]);
	dut->command_packet_rd_data_ro[1](command_packet_rd_data_ro[1]);

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	//  TB connections
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	tb->clk(clk);
	tb->resetx(resetx);
	tb->ro_packet_csr(ro_packet_csr);
	tb->ro_packet_ui(ro_packet_ui);
	tb->ro_packet_fwd(ro_packet_fwd);

	tb->ro_available_csr(ro_available_csr);
	tb->ro_available_ui(ro_available_ui);
	tb->ro_available_fwd(ro_available_fwd);

	tb->csr_ack_ro(csr_ack_ro);
	tb->ui_ack_ro(ui_ack_ro);
	tb->fwd_ack_ro(fwd_ack_ro);

	tb->eh_ack_ro(eh_ack_ro);
	tb->fc_nop_sent(fc_nop_sent);
	tb->cd_packet_ro(cd_packet_ro);
	tb->cd_available_ro(cd_available_ro);
	tb->cd_data_pending_ro(cd_data_pending_ro);
	tb->cd_data_pending_addr_ro(cd_data_pending_addr_ro);
	tb->csr_unit_id(csr_unit_id);
	for(int n = 0; n < NbRegsBars; n++)
		tb->csr_bar[n](csr_bar[n]);
	tb->csr_memory_space_enable(csr_memory_space_enable);
	tb->csr_io_space_enable(csr_io_space_enable);
	tb->csr_direct_route_enable(csr_direct_route_enable);
	tb->csr_sync(csr_sync);

	for(int n = 0; n < 32; n++)
		tb->clumped_unit_id[n](clumped_unit_id[n]);

#ifdef ENABLE_REORDERING
	tb->csr_unitid_reorder_disable(csr_unitid_reorder_disable);
#endif
	tb->fwd_next_node_buffer_status_ro(fwd_next_node_buffer_status_ro);
	
	tb->ro_buffer_cnt_fc(ro_buffer_cnt_fc);
	tb->ro_nop_req_fc(ro_nop_req_fc);

	tb->ro_overflow_csr(ro_overflow_csr);

#ifdef RETRY_MODE_ENABLED
	tb->lk_rx_connected(lk_rx_connected);
	tb->csr_retry(csr_retry);
#endif

	tb->ro_command_packet_wr_data(ro_command_packet_wr_data);
	tb->ro_command_packet_write(ro_command_packet_write);
	tb->ro_command_packet_wr_addr(ro_command_packet_wr_addr);
	tb->ro_command_packet_rd_addr[0](ro_command_packet_rd_addr[0]);
	tb->ro_command_packet_rd_addr[1](ro_command_packet_rd_addr[1]);
	tb->command_packet_rd_data_ro[0](command_packet_rd_data_ro[0]);
	tb->command_packet_rd_data_ro[1](command_packet_rd_data_ro[1]);

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////
	//  Trace signals
	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	sc_trace_file *tf = sc_create_vcd_trace_file("sim_reordering_l2");

	sc_trace(tf,clk,"clk");
	sc_trace(tf,resetx,"resetx");
	sc_trace(tf,ro_packet_csr,"ro_packet_csr");
	sc_trace(tf,ro_packet_ui,"ro_packet_ui");
	sc_trace(tf,ro_packet_fwd,"ro_packet_fwd");

	sc_trace(tf,ro_available_csr,"ro_available_csr");
	sc_trace(tf,ro_available_ui,"ro_available_ui");
	sc_trace(tf,ro_available_fwd,"ro_available_fwd");

	sc_trace(tf,csr_ack_ro,"csr_ack_ro");
	sc_trace(tf,ui_ack_ro,"ui_ack_ro");
	sc_trace(tf,fwd_ack_ro,"fwd_ack_ro");

	sc_trace(tf,eh_ack_ro,"eh_ack_ro");
	sc_trace(tf,fc_nop_sent,"fc_nop_sent");
	sc_trace(tf,cd_packet_ro,"cd_packet_ro");
	sc_trace(tf,cd_available_ro,"cd_available_ro");
	sc_trace(tf,cd_data_pending_ro,"cd_data_pending_ro");
	sc_trace(tf,cd_data_pending_addr_ro,"cd_data_pending_addr_ro");
	sc_trace(tf,csr_unit_id,"csr_unit_id");
	for(int n = 0; n < NbRegsBars; n++){
		ostringstream o;
		o << "csr_bar(" << n << ")";
		sc_trace(tf,csr_bar[n],o.str().c_str());
	}
	sc_trace(tf,csr_memory_space_enable,"csr_memory_space_enable");
	sc_trace(tf,csr_io_space_enable,"csr_io_space_enable");
	sc_trace(tf,csr_direct_route_enable,"csr_direct_route_enable");
	//sc_trace(tf,csr_clumping_configuration,"csr_clumping_configuration");

#ifdef ENABLE_REORDERING
	sc_trace(tf,csr_unitid_reorder_disable,"csr_unitid_reorder_disable");
#endif
	sc_trace(tf,fwd_next_node_buffer_status_ro,"fwd_next_node_buffer_status_ro");
	
	sc_trace(tf,ro_buffer_cnt_fc,"ro_buffer_cnt_fc");
	sc_trace(tf,ro_nop_req_fc,"ro_nop_req_fc");

	sc_trace(tf,ro_overflow_csr,"ro_overflow_csr");

#ifdef RETRY_MODE_ENABLED
	sc_trace(tf,lk_rx_connected,"lk_rx_connected");
	sc_trace(tf,csr_retry,"csr_retry");
#endif

	/*
	sc_trace(tf,dut->vc_npc_out_packet[0],"vc_npc_out_packet(0)");
	sc_trace(tf,dut->vc_npc_out_packet[1],"vc_npc_out_packet(1)");
	sc_trace(tf,dut->vc_npc_packet_available[0],"vc_npc_packet_available(0)");
	sc_trace(tf,dut->vc_npc_packet_available[1],"vc_npc_packet_available(1)");
	sc_trace(tf,dut->vc_npc_acknowledge[0],"vc_npc_acknowledge(0)");
	sc_trace(tf,dut->vc_npc_acknowledge[1],"vc_npc_acknowledge(1)");
	*/
	
	sc_trace(tf,dut->vc_rc_module->compare_with_higher,"AAA.compare_with_higher");

	sc_trace(tf,dut->addressManagerModule->first_free_one_hot[0],"ADDR_MANAGER.first_free_one_hot[0]");
	sc_trace(tf,dut->addressManagerModule->first_free_one_hot[1],"ADDR_MANAGER.first_free_one_hot[1]");
	sc_trace(tf,dut->addressManagerModule->first_free_one_hot[2],"ADDR_MANAGER.first_free_one_hot[2]");

	sc_trace(tf,dut->addressManagerModule->buffer_used[2][0],"ADDR_MANAGER.buffer_used[2][0]");
	sc_trace(tf,dut->addressManagerModule->buffer_used[2][1],"ADDR_MANAGER.buffer_used[2][1]");
	sc_trace(tf,dut->addressManagerModule->buffer_used[2][2],"ADDR_MANAGER.buffer_used[2][2]");
	sc_trace(tf,dut->addressManagerModule->buffer_used[2][3],"ADDR_MANAGER.buffer_used[2][3]");

	sc_trace(tf,dut->addressManagerModule->use_address,"ADDR_MANAGER.use_address");
	sc_trace(tf,dut->addressManagerModule->new_packet_available[0],"ADDR_MANAGER.new_packet_available[0]");
	sc_trace(tf,dut->addressManagerModule->new_packet_available[1],"ADDR_MANAGER.new_packet_available[1]");
	sc_trace(tf,dut->addressManagerModule->new_packet_available[2],"ADDR_MANAGER.new_packet_available[2]");

	sc_trace(tf,dut->addressManagerModule->ro_command_packet_rd_addr[0],"ADDR_MANAGER.ro_command_packet_rd_addr[0]");
	sc_trace(tf,dut->addressManagerModule->ro_command_packet_rd_addr[1],"ADDR_MANAGER.ro_command_packet_rd_addr[1]");
	sc_trace(tf,dut->addressManagerModule->buffers_cleared[0],"ADDR_MANAGER.buffers_cleared[0]");

	sc_trace(tf,dut->vc_rc_module->in_packet_destination[0],"RESPONSE.in_packet_destination[0]");
	sc_trace(tf,dut->vc_rc_module->in_packet_destination[1],"RESPONSE.in_packet_destination[1]");
	sc_trace(tf,dut->vc_rc_module->in_packet_addr,"RESPONSE.in_packet_addr");

	sc_trace(tf,dut->vc_rc_module->packet_available[0],"RESPONSE.available[0]");
	sc_trace(tf,dut->vc_rc_module->packet_available[1],"RESPONSE.available[1]");
	sc_trace(tf,dut->vc_rc_module->out_packet_addr[0],"RESPONSE.out_packet_addr[0]");
	sc_trace(tf,dut->vc_rc_module->out_packet_addr[1],"RESPONSE.out_packet_addr[1]");

	/*sc_trace(tf,dut->vc_rc_module->out_packet_seqid[0],"RESPONSE.out_packet_seqid[0]");
	sc_trace(tf,dut->vc_rc_module->out_packet_seqid[1],"RESPONSE.out_packet_seqid[1]");
	sc_trace(tf,dut->vc_rc_module->in_packet_seqid,"RESPONSE.in_packet_seqid");*/

	sc_trace(tf,dut->ro_command_packet_rd_addr[0],"AAA.ro_command_packet_rd_addr[0]");
	sc_trace(tf,dut->ro_command_packet_rd_addr[1],"AAA.ro_command_packet_rd_addr[1]");
	sc_trace(tf,dut->ro_command_packet_wr_addr,"AAA.ro_command_packet_wr_addr");
	sc_trace(tf,dut->ro_command_packet_wr_data,"AAA.ro_command_packet_wr_data");
	sc_trace(tf,dut->ro_command_packet_write,"AAA.ro_command_packet_write");
	sc_trace(tf,dut->command_packet_rd_data_ro[0],"AAA.command_packet_rd_data_ro[0]");
	sc_trace(tf,dut->command_packet_rd_data_ro[1],"AAA.command_packet_rd_data_ro[1]");
	sc_trace(tf,dut->finalReorderingModule->response_requested[0],"AAA.response_requested[0]");
	sc_trace(tf,dut->finalReorderingModule->response_requested[1],"AAA.response_requested[1]");

	sc_trace(tf,dut->vc_rc_module->packet_addr_register[0],"packet_addr_register[0]");
	sc_trace(tf,dut->vc_rc_module->destination_registers[0],"destination_registers[0]");
	sc_trace(tf,dut->vc_rc_module->packet_passpw_register[0],"packet_passpw_register[0]");

	sc_trace(tf,dut->vc_rc_module->packet_addr_register[1],"packet_addr_register[1]");
	sc_trace(tf,dut->vc_rc_module->destination_registers[1],"destination_registers[1]");
	sc_trace(tf,dut->vc_rc_module->packet_passpw_register[1],"packet_passpw_register[1]");

	sc_trace(tf,dut->vc_rc_module->packet_addr_register[2],"packet_addr_register[2]");
	sc_trace(tf,dut->vc_rc_module->destination_registers[2],"destination_registers[2]");
	sc_trace(tf,dut->vc_rc_module->packet_passpw_register[2],"packet_passpw_register[2]");

	sc_trace(tf,dut->vc_rc_module->packet_addr_register[3],"packet_addr_register[3]");
	sc_trace(tf,dut->vc_rc_module->destination_registers[3],"destination_registers[3]");
	sc_trace(tf,dut->vc_rc_module->packet_passpw_register[3],"packet_passpw_register[3]");

	sc_trace(tf,dut->vc_rc_module->packet_addr_register[4],"packet_addr_register[4]");
	sc_trace(tf,dut->vc_rc_module->destination_registers[4],"destination_registers[4]");
	sc_trace(tf,dut->vc_rc_module->packet_passpw_register[4],"packet_passpw_register[4]");

	sc_trace(tf,dut->vc_rc_module->packet_addr_register[5],"packet_addr_register[5]");
	sc_trace(tf,dut->vc_rc_module->destination_registers[5],"destination_registers[5]");
	sc_trace(tf,dut->vc_rc_module->packet_passpw_register[5],"packet_passpw_register[5]");

	sc_trace(tf,dut->vc_rc_module->packet_addr_register[6],"packet_addr_register[6]");
	sc_trace(tf,dut->vc_rc_module->destination_registers[6],"destination_registers[6]");
	sc_trace(tf,dut->vc_rc_module->packet_passpw_register[6],"packet_passpw_register[6]");
	
	sc_trace(tf,dut->vc_npc_module->out_packet_addr[0],"BBB.out_packet_addr[0]");
	sc_trace(tf,dut->vc_npc_module->out_packet_addr[1],"BBB.out_packet_addr[1]");
	sc_trace(tf,dut->vc_npc_module->out_packet_seqid[0],"BBB.out_packet_seqid[0]");
	sc_trace(tf,dut->vc_npc_module->out_packet_seqid[1],"BBB.out_packet_seqid[1]");
	sc_trace(tf,dut->vc_npc_module->packet_available[0],"BBB.packet_available[0]");
	sc_trace(tf,dut->vc_npc_module->packet_available[1],"BBB.packet_available[1]");
	sc_trace(tf,dut->vc_npc_module->acknowledge[0],"BBB.acknowledge[0]");
	sc_trace(tf,dut->vc_npc_module->acknowledge[1],"BBB.acknowledge[1]");

	sc_trace(tf,dut->finalReorderingModule->response_packet_buffer_accepted[0].read().packet,"final_packet_accepted0");
	sc_trace(tf,dut->finalReorderingModule->response_packet_buffer_accepted[1].read().packet,"final_packet_accepted1");
	sc_trace(tf,dut->finalReorderingModule->response_packet_buffer_rejected[0].read().packet,"final_packet_rejected0");
	sc_trace(tf,dut->finalReorderingModule->response_packet_buffer_rejected_loaded[0],"final_packet_rejected_l0");
	sc_trace(tf,dut->finalReorderingModule->response_packet_buffer_rejected[1].read().packet,"final_packet_rejected1");
	sc_trace(tf,dut->finalReorderingModule->response_packet_buffer_rejected_loaded[1],"final_packet_rejected_l1");

	sc_trace(tf,dut->finalReorderingModule->response_packet_buffer_accepted_loaded[0],"final_packet_accepted_rc_l0");
	sc_trace(tf,dut->finalReorderingModule->response_packet_buffer_accepted_loaded[1],"final_packet_accepted_rc_l1");
	sc_trace(tf,dut->finalReorderingModule->posted_packet_buffer_accepted_loaded[0],"final_packet_accepted_pc_l0");
	sc_trace(tf,dut->finalReorderingModule->posted_packet_buffer_accepted_loaded[1],"final_packet_accepted_pc_l1");
	sc_trace(tf,dut->finalReorderingModule->nposted_packet_buffer_accepted_loaded[0],"final_packet_accepted_npc_l0");
	sc_trace(tf,dut->finalReorderingModule->nposted_packet_buffer_accepted_loaded[1],"final_packet_accepted_npc_l1");


	sc_trace(tf,dut->finalReorderingModule->fetched_packet_available[0],"fetched_packet_available[0]");
	sc_trace(tf,dut->finalReorderingModule->fetched_packet_available[1],"fetched_packet_available[1]");
	sc_trace(tf,dut->finalReorderingModule->fetched_packet[0],"fetched_packet[0]");
	sc_trace(tf,dut->finalReorderingModule->fetched_packet[1],"fetched_packet[1]");
	sc_trace(tf,dut->finalReorderingModule->fetched_packet_vc[0],"fetched_packet_vc[0]");
	sc_trace(tf,dut->finalReorderingModule->fetched_packet_vc[1],"fetched_packet_vc[1]");

	//To notify that packets have been received, one signal per VC
	sc_trace(tf,dut->nopHandlerModule->received_packet[0],"received_packet[0]");
	sc_trace(tf,dut->nopHandlerModule->received_packet[1],"received_packet[1]");
	sc_trace(tf,dut->nopHandlerModule->received_packet[2],"received_packet[2]");
	//To notify that packets have been sent and the buffer is free, one signal per VC
	sc_trace(tf,dut->nopHandlerModule->buffers_cleared[0],"buffers_cleared[0]");
	sc_trace(tf,dut->nopHandlerModule->buffers_cleared[1],"buffers_cleared[1]");
	sc_trace(tf,dut->nopHandlerModule->buffers_cleared[2],"buffers_cleared[2]");

	//Count of the number of buffers that are advertised as being free to the next node
	sc_trace(tf,dut->nopHandlerModule->bufferCount[0],"bufferCount[0]");
	sc_trace(tf,dut->nopHandlerModule->bufferCount[1],"bufferCount[1]");
	sc_trace(tf,dut->nopHandlerModule->bufferCount[2],"bufferCount[2]");

	//The number of free buffers
	sc_trace(tf,dut->nopHandlerModule->freeBuffers[0],"freeBuffers[0]");
	sc_trace(tf,dut->nopHandlerModule->freeBuffers[1],"freeBuffers[1]");
	sc_trace(tf,dut->nopHandlerModule->freeBuffers[2],"freeBuffers[2]");

	//An internal register that keeps track of the previous value of ro_buffer_cnt_fc
	//sc_trace(tf,dut->nopHandlerModule->bufferFreedNop,"bufferFreedNop");


	//------------------------------------------
	// Start simulation
	//------------------------------------------
	cout << "Start of History Buffer simulation" << endl;
	sc_start(450);


	sc_close_vcd_trace_file(tf);
	cout << "End of simulation" << endl;

	delete dut;
	delete tb;
	return 0;
}

