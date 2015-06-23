//reordering_l2.cpp

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
 *   Laurent Aubray
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

#include "reordering_l2.h"

#include "entrance_reordering_l3.h"
#include "final_reordering_l3.h"
#include "posted_vc_l3.h"
#include "nposted_vc_l3.h"
#include "response_vc_l3.h"
#include "nophandler_l3.h"
#include "address_manager_l3.h"
#include "fetch_packet_l3.h"

/// Main constructor
reordering_l2::reordering_l2(sc_module_name name): sc_module(name)
{

	SC_METHOD(doOrFwdEhAck);
	sensitive << fwd_ack_ro << eh_ack_ro;
	
	SC_METHOD(or_overflows);
	sensitive << vc_overflow[0] << vc_overflow[1] << vc_overflow[2];

	SC_METHOD(wire_through);
	sensitive << cd_available_ro << ro_packet_accepted;

	/***********************************************
		vcBuffersLinking
	***********************************************/

  
	/////////////////////////////////////////
	//POSTED Buffer
	/////////////////////////////////////////
	vc_pc_module = new posted_vc_l3("VC_PC");

	vc_pc_module->clk(clk);
	vc_pc_module->resetx(resetx);
	vc_pc_module->buffers_cleared(buffers_cleared[VC_POSTED]);

	for(int n = 0; n < 2; n++){
		vc_pc_module->out_packet_addr[n](posted_packet_addr[n]);
#ifdef ENABLE_REORDERING
		vc_pc_module->out_packet_passpw[n](posted_packet_passpw[n]);
		vc_pc_module->out_packet_seqid[n](posted_packet_seqid[n]);
		vc_pc_module->out_packet_chain[n](posted_packet_chain[n]);
		vc_pc_module->out_packet_nposted_refid[n](posted_packet_nposted_refid[n]);
		vc_pc_module->out_packet_response_refid[n](posted_packet_response_refid[n]);
#endif
		vc_pc_module->packet_available[n](posted_available[n]);
		vc_pc_module->acknowledge[n](ack_posted[n]);
		
		vc_pc_module->in_packet_destination[n](destination_pc[n]);
	}
	

	vc_pc_module->in_packet_addr(new_packet_addr);
#ifdef ENABLE_REORDERING
	vc_pc_module->in_packet_chain(new_packet_chain);
	vc_pc_module->in_packet_passpw(new_packet_passpw);
	vc_pc_module->in_packet_seqid(new_packet_seqid);

	vc_pc_module->in_packet_clumped_unitid(new_packet_clumped_unitid);
	vc_pc_module->unitid_reorder_disable(csr_unitid_reorder_disable);
	vc_pc_module->nposted_refid_rejected(nposted_refid_rejected);
	vc_pc_module->response_refid_rejected(response_refid_rejected);
	vc_pc_module->nposted_refid_accepted(nposted_refid_accepted);
	vc_pc_module->response_refid_accepted(response_refid_accepted);
#endif

	vc_pc_module->vc_overflow(vc_overflow[VC_POSTED]);

	/////////////////////////////////////////
	//NON POSTED Buffer
	/////////////////////////////////////////
	vc_npc_module = new nposted_vc_l3("VC_NPC");

	vc_npc_module->clk(clk);
	vc_npc_module->resetx(resetx);

	vc_npc_module->buffers_cleared(buffers_cleared[VC_NON_POSTED]);

	for(int n = 0; n < 2; n++){
		vc_npc_module->out_packet_addr[n](nposted_packet_addr[n]);
#ifdef ENABLE_REORDERING
		vc_npc_module->out_packet_passpw[n](nposted_packet_passpw[n]);
		vc_npc_module->out_packet_seqid[n](nposted_packet_seqid[n]);
#endif
		vc_npc_module->packet_available[n](nposted_available[n]);
		vc_npc_module->acknowledge[n](ack_nposted[n]);

		vc_npc_module->in_packet_destination[n](destination_npc[n]);
	}


	vc_npc_module->in_packet_addr(new_packet_addr);
#ifdef ENABLE_REORDERING
	vc_npc_module->in_packet_passpw(new_packet_passpw);
	vc_npc_module->in_packet_seqid(new_packet_seqid);

	vc_npc_module->in_packet_clumped_unitid(new_packet_clumped_unitid);
	vc_npc_module->unitid_reorder_disable(csr_unitid_reorder_disable);
#endif

	vc_npc_module->vc_overflow(vc_overflow[VC_NON_POSTED]);

	/////////////////////////////////////////
	//RESPONSE Buffer
	/////////////////////////////////////////
	vc_rc_module = new response_vc_l3("VC_RC");

	vc_rc_module->clk(clk);
	vc_rc_module->resetx(resetx);

	vc_rc_module->buffers_cleared(buffers_cleared[VC_RESPONSE]);

	for(int n = 0; n < 2; n++){
		vc_rc_module->out_packet_addr[n](response_packet_addr[n]);
#ifdef ENABLE_REORDERING
		vc_rc_module->out_packet_passpw[n](response_packet_passpw[n]);
#endif
		vc_rc_module->packet_available[n](response_available[n]);
		vc_rc_module->acknowledge[n](ack_response[n]);

		vc_rc_module->in_packet_destination[n](destination_rc[n]);

	}

	vc_rc_module->in_packet_addr(new_packet_addr);
#ifdef ENABLE_REORDERING
	vc_rc_module->in_packet_passpw(new_packet_passpw);
	vc_rc_module->unitid_reorder_disable(csr_unitid_reorder_disable);
#endif

	vc_rc_module->vc_overflow(vc_overflow[VC_RESPONSE]);


	/*****************************************
		entranceReorderingLinking
	*****************************************/

	entranceReorderingModule = new entrance_reordering_l3("The_Entrance_Reordering");

	entranceReorderingModule->clk(clk);
	entranceReorderingModule->resetx(resetx);

	entranceReorderingModule->in_packet(cd_packet_ro);
	entranceReorderingModule->packet_available(cd_available_ro);
	entranceReorderingModule->unit_id(csr_unit_id);
#ifdef ENABLE_DIRECTROUTE
	entranceReorderingModule->csr_direct_route_enable(csr_direct_route_enable);
#endif
	entranceReorderingModule->csr_memory_space_enable(csr_memory_space_enable);
	entranceReorderingModule->csr_io_space_enable(csr_io_space_enable);

#ifdef ENABLE_REORDERING
	entranceReorderingModule->new_packet_passPW(new_packet_passpw);
	entranceReorderingModule->new_packet_chain(new_packet_chain);
	entranceReorderingModule->new_packet_seqid(new_packet_seqid);
	entranceReorderingModule->nposted_refid_rejected(nposted_refid_rejected);
	entranceReorderingModule->response_refid_rejected(response_refid_rejected);
	entranceReorderingModule->nposted_refid_accepted(nposted_refid_accepted);
	entranceReorderingModule->response_refid_accepted(response_refid_accepted);
#endif

	entranceReorderingModule->ro_command_packet_wr_data(ro_command_packet_wr_data);

	for(int n = 0; n < NbRegsBars; n++){
		entranceReorderingModule->csr_bar[n](csr_bar[n]);
	}

	for(int n = 0; n < 2; n++){
		entranceReorderingModule->destination_pc[n](destination_pc[n]);
		entranceReorderingModule->destination_npc[n](destination_npc[n]);
		entranceReorderingModule->destination_rc[n](destination_rc[n]);
	}

	for(int n = 0; n < 3; n++){
		entranceReorderingModule->new_packet_available[n](new_packet_available[n]);
	}

#ifdef ENABLE_REORDERING


	entranceReorderingModule->new_packet_clumped_unitid(new_packet_clumped_unitid);
	for(int n = 0; n < 32; n++){
		entranceReorderingModule->clumped_unit_id[n](clumped_unit_id[n]);
	}
#else
	for(int n = 0; n < 4; n++){
		entranceReorderingModule->clumped_unit_id[n](clumped_unit_id[n]);
	}
#endif

#ifdef RETRY_MODE_ENABLED
	entranceReorderingModule->input_packet_vc(input_packet_vc);
#endif
	
	/***************************************
		finalReorderingLinking
	***************************************/
	
	finalReorderingModule = new final_reordering_l3("final_reordering");

	finalReorderingModule->clk(clk);
	finalReorderingModule->resetx(resetx);

	for(int destination = 0; destination <2 ; destination++){
		finalReorderingModule->posted_requested[destination](posted_requested[destination]);
		finalReorderingModule->nposted_requested[destination](nposted_requested[destination]);
		finalReorderingModule->response_requested[destination](response_requested[destination]);

		finalReorderingModule->fetched_packet[destination](fetched_packet[destination]);
		finalReorderingModule->fetched_packet_available[destination](fetched_packet_available[destination]);
		finalReorderingModule->fetched_packet_vc[destination](fetched_packet_vc[destination]);

		finalReorderingModule->fetched_packet_nposted_refid[destination](fetched_packet_nposted_refid[destination]);
		finalReorderingModule->fetched_packet_response_refid[destination](fetched_packet_response_refid[destination]);
	}

	finalReorderingModule->out_packet_accepted(ro_packet_accepted);
	finalReorderingModule->out_packet_fwd(ro_packet_fwd);
	finalReorderingModule->out_packet_vc_fwd(ro_packet_vc_fwd);


	
	finalReorderingModule->out_packet_available_csr(ro_available_csr);
	finalReorderingModule->out_packet_available_ui(ro_available_ui);
	finalReorderingModule->out_packet_available_fwd(ro_available_fwd);

	finalReorderingModule->ack[FWD_DEST](orFwdEhAck);
	finalReorderingModule->ack[CSR_DEST](csr_ack_ro);
	finalReorderingModule->ack[UI_DEST](ui_ack_ro);

	finalReorderingModule->cd_data_pending_ro(cd_data_pending_ro);
	finalReorderingModule->cd_data_pending_addr_ro(cd_data_pending_addr_ro);

	finalReorderingModule->csr_sync(csr_sync);
	finalReorderingModule->fwd_next_node_buffer_status_ro(fwd_next_node_buffer_status_ro);

	/**************************************
		nopHandlerLinking
	**************************************/

	nopHandlerModule = new nophandler_l3("The_Nop_Handler");

	nopHandlerModule->clk(clk);
	nopHandlerModule->resetx(resetx);
	nopHandlerModule->fc_nop_sent(fc_nop_sent);

	for(int n = 0; n < 3; n++){
		nopHandlerModule->received_packet[n](new_packet_available[n]);
		nopHandlerModule->buffers_cleared[n](buffers_cleared[n]);
	}

	nopHandlerModule->ro_nop_req_fc(ro_nop_req_fc);
	nopHandlerModule->ro_buffer_cnt_fc(ro_buffer_cnt_fc);

#ifdef RETRY_MODE_ENABLED
	nopHandlerModule->lk_rx_connected(lk_rx_connected);
	nopHandlerModule->csr_retry(csr_retry);
	nopHandlerModule->cd_received_non_flow_stomped_ro(cd_received_non_flow_stomped_ro);
	nopHandlerModule->input_packet_vc(input_packet_vc);
#endif

	/**************************************
		Address Manager Linking
	**************************************/

	addressManagerModule = new address_manager_l3("CMD_Address_Manager");
	addressManagerModule->clk(clk);
	addressManagerModule->resetx(resetx);
	addressManagerModule->use_address(cd_available_ro);
	for(int n = 0; n < 3; n++){
		addressManagerModule->new_packet_available[n](new_packet_available[n]);
		addressManagerModule->buffers_cleared[n](buffers_cleared[n]);
	}
	addressManagerModule->ro_command_packet_wr_addr(ro_command_packet_wr_addr);
	addressManagerModule->new_packet_addr(new_packet_addr);

	addressManagerModule->ro_command_packet_rd_addr[0](ro_command_packet_rd_addr[0]);
	addressManagerModule->ro_command_packet_rd_addr[1](ro_command_packet_rd_addr[1]);

	/**************************************
		Fetch Packet Module Linking
	**************************************/
	fetchPacketModule = new fetch_packet_l3("CMD_fetch_packet");

	fetchPacketModule->clk(clk);
	fetchPacketModule->resetx(resetx);

	for(int destination = 0; destination < 2; destination++){
		//Packet from posted buffers
		fetchPacketModule->posted_packet_addr[destination](posted_packet_addr[destination]);
#ifdef ENABLE_REORDERING
		fetchPacketModule->posted_packet_passpw[destination](posted_packet_passpw[destination]);
		fetchPacketModule->posted_packet_seqid[destination](posted_packet_seqid[destination]);
		fetchPacketModule->posted_packet_chain[destination](posted_packet_chain[destination]);
		fetchPacketModule->posted_packet_nposted_refid[destination](posted_packet_nposted_refid[destination]);
		fetchPacketModule->posted_packet_response_refid[destination](posted_packet_response_refid[destination]);
#endif
		fetchPacketModule->posted_available[destination](posted_available[destination]);

		//Packet from nposted buffers
		fetchPacketModule->nposted_packet_addr[destination](nposted_packet_addr[destination]);
#ifdef ENABLE_REORDERING
		fetchPacketModule->nposted_packet_passpw[destination](nposted_packet_passpw[destination]);
		fetchPacketModule->nposted_packet_seqid[destination](nposted_packet_seqid[destination]);
#endif
		fetchPacketModule->nposted_available[destination](nposted_available[destination]);

		//Packet from response buffers
		fetchPacketModule->response_packet_addr[destination](response_packet_addr[destination]);
#ifdef ENABLE_REORDERING
		fetchPacketModule->response_packet_passpw[destination](response_packet_passpw[destination]);
#endif
		fetchPacketModule->response_available[destination](response_available[destination]);

		//Data from memory
		fetchPacketModule->command_packet_rd_data_ro[destination](command_packet_rd_data_ro[destination]);

		//Packet types requested
		fetchPacketModule->posted_requested[destination](posted_requested[destination]);
		fetchPacketModule->nposted_requested[destination](nposted_requested[destination]);
		fetchPacketModule->response_requested[destination](response_requested[destination]);

		fetchPacketModule->ack_posted[destination](ack_posted[destination]);
		fetchPacketModule->ack_nposted[destination](ack_nposted[destination]);
		fetchPacketModule->ack_response[destination](ack_response[destination]);

		//Actual retrieved packet
		fetchPacketModule->fetched_packet[destination](fetched_packet[destination]);
		fetchPacketModule->fetched_packet_available[destination](fetched_packet_available[destination]);
		fetchPacketModule->fetched_packet_vc[destination](fetched_packet_vc[destination]);

		fetchPacketModule->fetched_packet_nposted_refid[destination](fetched_packet_nposted_refid[destination]);
		fetchPacketModule->fetched_packet_response_refid[destination](fetched_packet_response_refid[destination]);
	
	}

	//Address to retrieve data from memory
	fetchPacketModule->ro_command_packet_rd_addr[0](ro_command_packet_rd_addr[0]);
	fetchPacketModule->ro_command_packet_rd_addr[1](ro_command_packet_rd_addr[1]);
}


void reordering_l2::doOrFwdEhAck(){
	orFwdEhAck = fwd_ack_ro.read() || eh_ack_ro.read();
}

void reordering_l2::or_overflows(){
	ro_overflow_csr = vc_overflow[0].read() || vc_overflow[1].read() || vc_overflow[2].read();
}

void reordering_l2::wire_through(){
	ro_command_packet_write = cd_available_ro;
	ro_packet_ui = ro_packet_accepted;
	ro_packet_csr = ro_packet_accepted;
}

#ifdef SYSTEMC_SIM
reordering_l2::~reordering_l2(){
	delete vc_pc_module;
	delete vc_npc_module;
	delete vc_rc_module;
	delete entranceReorderingModule;
	delete finalReorderingModule;
	delete nopHandlerModule;
}
#endif

