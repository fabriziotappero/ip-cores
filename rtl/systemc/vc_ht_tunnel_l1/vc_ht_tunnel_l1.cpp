//vc_ht_tynnel_l1.cpp

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

#include "vc_ht_tunnel_l1.h"


vc_ht_tunnel_l1::vc_ht_tunnel_l1(sc_module_name name) : sc_module(name){

	//**************************************
	// CSR Linkage
	//**************************************

	the_csr_l2 = new csr_l2("the_csr_l2");

	the_csr_l2->clk(clk);

	the_csr_l2->resetx(resetx);
	the_csr_l2->pwrok(pwrok);
	the_csr_l2->ldtstopx(registered_ldtstopx);

	the_csr_l2->csr_read_addr_usr(csr_read_addr_usr);
	the_csr_l2->usr_read_data_csr(usr_read_data_csr);
	the_csr_l2->csr_write_usr(csr_write_usr);
	the_csr_l2->csr_write_addr_usr(csr_write_addr_usr);
	the_csr_l2->csr_write_data_usr(csr_write_data_usr);
	the_csr_l2->csr_write_mask_usr(csr_write_mask_usr);

	the_csr_l2->csr_sync(csr_sync);

	the_csr_l2->ro0_available_csr(ro0_available_csr);
	the_csr_l2->ro0_packet_csr(ro0_packet_csr);
	the_csr_l2->csr_ack_ro0(csr_ack_ro0);

	the_csr_l2->ro1_available_csr(ro1_available_csr);
	the_csr_l2->ro1_packet_csr(ro1_packet_csr);
	the_csr_l2->csr_ack_ro1(csr_ack_ro1);

	the_csr_l2->csr_read_db0(csr_read_db0);
	the_csr_l2->csr_read_db1(csr_read_db1);

	the_csr_l2->csr_address_db0(csr_address_db0);
	the_csr_l2->csr_address_db1(csr_address_db1);

	the_csr_l2->csr_vctype_db0(csr_vctype_db0);
	the_csr_l2->csr_vctype_db1(csr_vctype_db1);

	the_csr_l2->db0_data_csr(db0_data_accepted);
	the_csr_l2->db1_data_csr(db1_data_accepted);

	the_csr_l2->csr_erase_db0(csr_erase_db0);
	the_csr_l2->csr_erase_db1(csr_erase_db1);

	the_csr_l2->csr_available_fc0(csr_available_fc0);
	the_csr_l2->csr_dword_fc0(csr_dword_fc0);
	the_csr_l2->fc0_ack_csr(fc0_ack_csr);

	the_csr_l2->csr_available_fc1(csr_available_fc1);
	the_csr_l2->csr_dword_fc1(csr_dword_fc1);
	the_csr_l2->fc1_ack_csr(fc1_ack_csr);

	the_csr_l2->ui_sendingPostedDataError_csr(ui_sendingPostedDataError_csr);
	the_csr_l2->ui_sendingTargetAbort_csr(ui_sendingTargetAbort_csr);
	the_csr_l2->ui_receivedResponseDataError_csr(ui_receivedResponseDataError_csr);
	the_csr_l2->ui_receivedPostedDataError_csr(ui_receivedPostedDataError_csr);
	the_csr_l2->ui_receivedTargetAbort_csr(ui_receivedTargetAbort_csr);
	the_csr_l2->ui_receivedMasterAbort_csr(ui_receivedMasterAbort_csr);

	the_csr_l2->usr_receivedResponseError_csr(usr_receivedResponseError_csr);

	the_csr_l2->db0_overflow_csr(db0_overflow_csr);
	the_csr_l2->ro0_overflow_csr(ro0_overflow_csr);
	the_csr_l2->db1_overflow_csr(db1_overflow_csr);
	the_csr_l2->ro1_overflow_csr(ro1_overflow_csr);

	the_csr_l2->eh0_ack_ro0(eh0_ack_ro0);
	the_csr_l2->eh1_ack_ro1(eh1_ack_ro1);

	the_csr_l2->lk0_initialization_complete_csr(lk0_rx_connected);
	the_csr_l2->lk0_crc_error_csr(lk0_crc_error_csr);
#ifdef RETRY_MODE_ENABLED
	the_csr_l2->lk0_initiate_retry_disconnect(lk0_initiate_retry_disconnect);
#endif
//	the_csr_l2->lk0_sync_detected_csr(lk0_sync_detected_csr);
	the_csr_l2->lk0_protocol_error_csr(lk0_protocol_error_csr);


	the_csr_l2->lk1_initialization_complete_csr(lk1_rx_connected);
	the_csr_l2->lk1_crc_error_csr(lk1_crc_error_csr);
#ifdef RETRY_MODE_ENABLED
	the_csr_l2->lk1_initiate_retry_disconnect(lk1_initiate_retry_disconnect);
#endif
	//the_csr_l2->lk1_sync_detected_csr(lk1_sync_detected_csr);
	the_csr_l2->lk1_protocol_error_csr(lk1_protocol_error_csr);

	the_csr_l2->cd0_protocol_error_csr(cd0_protocol_error_csr);

	the_csr_l2->cd0_sync_detected_csr(cd0_sync_detected_csr);
	the_csr_l2->cd1_protocol_error_csr(cd1_protocol_error_csr);
#ifdef RETRY_MODE_ENABLED
	the_csr_l2->cd0_initiate_retry_disconnect(cd0_initiate_retry_disconnect);
	the_csr_l2->cd0_received_stomped_csr(cd0_received_stomped_csr);
	the_csr_l2->cd1_initiate_retry_disconnect(cd1_initiate_retry_disconnect);
	the_csr_l2->cd1_received_stomped_csr(cd1_received_stomped_csr);
#endif
	the_csr_l2->cd1_sync_detected_csr(cd1_sync_detected_csr);


	the_csr_l2->lk0_update_link_failure_property_csr(lk0_update_link_failure_property_csr);
	the_csr_l2->lk0_update_link_width_csr(lk0_update_link_width_csr);
	the_csr_l2->lk0_sampled_link_width_csr(lk0_sampled_link_width_csr);
	the_csr_l2->lk0_link_failure_csr(lk0_link_failure_csr);

#ifdef RETRY_MODE_ENABLED
	the_csr_l2->fc0_clear_single_error_csr(fc0_clear_single_error_csr);
	the_csr_l2->fc0_clear_single_stomp_csr(fc0_clear_single_stomp_csr);
#endif


	the_csr_l2->lk1_update_link_failure_property_csr(lk1_update_link_failure_property_csr);
	the_csr_l2->lk1_update_link_width_csr(lk1_update_link_width_csr);
	the_csr_l2->lk1_sampled_link_width_csr(lk1_sampled_link_width_csr);
	the_csr_l2->lk1_link_failure_csr(lk1_link_failure_csr);

#ifdef RETRY_MODE_ENABLED
	the_csr_l2->fc1_clear_single_error_csr(fc1_clear_single_error_csr);
	the_csr_l2->fc1_clear_single_stomp_csr(fc1_clear_single_stomp_csr);
#endif

	the_csr_l2->csr_io_space_enable(csr_io_space_enable);
	the_csr_l2->csr_memory_space_enable(csr_memory_space_enable);
	the_csr_l2->csr_bus_master_enable(csr_bus_master_enable);
	the_csr_l2->csr_master_host(csr_master_host);

	for(int n = 0; n < NbRegsBars; n++){
		the_csr_l2->csr_bar[n](csr_bar[n]);
	}

	the_csr_l2->csr_unit_id(csr_unit_id);
	the_csr_l2->csr_default_dir(csr_default_dir);
	the_csr_l2->csr_drop_uninit_link(csr_drop_uninit_link);
	the_csr_l2->csr_crc_force_error_lk0(csr_crc_force_error_lk0);
	the_csr_l2->csr_end_of_chain0(csr_end_of_chain0);
	the_csr_l2->csr_transmitter_off_lk0(csr_transmitter_off_lk0);
	the_csr_l2->csr_ldtstop_tristate_enable_lk0(csr_ldtstop_tristate_enable_lk0);
	the_csr_l2->csr_extented_ctl_lk0(csr_extented_ctl_lk0);
	the_csr_l2->csr_rx_link_width_lk0(csr_rx_link_width_lk0);
	the_csr_l2->csr_tx_link_width_lk0(csr_tx_link_width_lk0);
	the_csr_l2->csr_crc_force_error_lk1(csr_crc_force_error_lk1);
	the_csr_l2->csr_end_of_chain1(csr_end_of_chain1);
	the_csr_l2->csr_transmitter_off_lk1(csr_transmitter_off_lk1);
	the_csr_l2->csr_ldtstop_tristate_enable_lk1(csr_ldtstop_tristate_enable_lk1);
	the_csr_l2->csr_extented_ctl_lk1(csr_extented_ctl_lk1);
	the_csr_l2->csr_rx_link_width_lk1(csr_rx_link_width_lk1);
	the_csr_l2->csr_tx_link_width_lk1(csr_tx_link_width_lk1);
	the_csr_l2->csr_extended_ctl_timeout_lk0(csr_extended_ctl_timeout_lk0);
#ifdef ENABLE_REORDERING
	the_csr_l2->csr_unitid_reorder_disable(csr_unitid_reorder_disable);
#endif
	the_csr_l2->csr_extended_ctl_timeout_lk1(csr_extended_ctl_timeout_lk1);
#ifdef RETRY_MODE_ENABLED
	the_csr_l2->csr_retry0(csr_retry0);
	the_csr_l2->csr_force_single_error_fc0(csr_force_single_error_fc0);
	the_csr_l2->csr_force_single_stomp_fc0(csr_force_single_stomp_fc0);
	the_csr_l2->csr_retry1(csr_retry1);
	the_csr_l2->csr_force_single_error_fc1(csr_force_single_error_fc1);
	the_csr_l2->csr_force_single_stomp_fc1(csr_force_single_stomp_fc1);
#endif
	the_csr_l2->csr_clumping_configuration(csr_clumping_configuration);

#ifdef ENABLE_DIRECTROUTE
	the_csr_l2->csr_direct_route_enable(csr_direct_route_enable);
	for(int n = 0; n < DirectRoute_NumberDirectRouteSpaces; n++){
		the_csr_l2->csr_direct_route_oppposite_dir[n](csr_direct_route_oppposite_dir[n]);
		the_csr_l2->csr_direct_route_base[n](csr_direct_route_base[n]);
		the_csr_l2->csr_direct_route_limit[n](csr_direct_route_limit[n]);
	}
#endif

	the_csr_l2->csr_initcomplete0(csr_initcomplete0);
	the_csr_l2->csr_initcomplete1(csr_initcomplete1);

	the_csr_l2->csr_link_frequency0(csr_link_frequency0);
	the_csr_l2->csr_link_frequency1(csr_link_frequency1);

	the_csr_l2->csr_request_databuffer0_access_ui(csr_request_databuffer0_access_ui);
	the_csr_l2->csr_request_databuffer1_access_ui(csr_request_databuffer1_access_ui);
	the_csr_l2->ui_databuffer_access_granted_csr(ui_databuffer_access_granted_csr);

	
	//******************************
	// Flow control 0 linkage
	//******************************
	the_flow_control0_l2 = new flow_control_l2("the_flow_control0_l2");

	the_flow_control0_l2->clk(clk);
	the_flow_control0_l2->resetx(resetx);
	the_flow_control0_l2->ldtstopx(registered_ldtstopx);

	the_flow_control0_l2->ui_packet_fc(ui_packet_fc0);
	the_flow_control0_l2->ui_available_fc(ui_available_fc0);
	the_flow_control0_l2->fc_user_fifo_ge2_ui(fc0_user_fifo_ge2_ui);
	
	the_flow_control0_l2->fc_data_vc_ui(fc0_data_vc_ui);
	the_flow_control0_l2->ui_data_fc(ui_data_fc0);
	the_flow_control0_l2->fc_consume_data_ui(fc0_consume_data_ui);
    
	the_flow_control0_l2->ro_available_fwd(ro1_available_fwd0);
	the_flow_control0_l2->ro_packet_fwd(ro1_packet_fwd0);
	the_flow_control0_l2->ro_packet_vc_fwd(ro1_packet_vc_fwd0);
	the_flow_control0_l2->fwd_ack_ro(fwd0_ack_ro1);

	the_flow_control0_l2->fc_dword_lk(fc0_dword_lk0);
	the_flow_control0_l2->fc_lctl_lk(fc0_lctl_lk0);
	the_flow_control0_l2->fc_hctl_lk(fc0_hctl_lk0);
	the_flow_control0_l2->lk_consume_fc(lk0_consume_fc0);
#ifdef RETRY_MODE_ENABLED
	the_flow_control0_l2->fc_disconnect_lk(fc0_disconnect_lk0);
	the_flow_control0_l2->lk_rx_connected(lk0_rx_connected);
#endif
    		
	the_flow_control0_l2->fwd_address_db(fwd0_address_db1);
	the_flow_control0_l2->fwd_vctype_db(fwd0_vctype_db1);
	the_flow_control0_l2->fwd_read_db(fwd0_read_db1);
	the_flow_control0_l2->fwd_erase_db(fwd0_erase_db1);
	the_flow_control0_l2->db_data_fwd(db1_data_fwd0);
	
	the_flow_control0_l2->ro_buffer_cnt_fc(ro0_buffer_cnt_fc0);
	the_flow_control0_l2->db_buffer_cnt_fc(db0_buffer_cnt_fc0);
    
	the_flow_control0_l2->fc_ack_eh(fc0_ack_eh0);
	the_flow_control0_l2->eh_cmd_data_fc(eh0_cmd_data_fc0);
	the_flow_control0_l2->eh_available_fc(eh0_available_fc0);
    
	the_flow_control0_l2->fc_ack_csr(fc0_ack_csr);
	the_flow_control0_l2->csr_available_fc(csr_available_fc0);
	the_flow_control0_l2->csr_dword_fc(csr_dword_fc0);

#ifdef RETRY_MODE_ENABLED
	the_flow_control0_l2->csr_force_single_error_fc(csr_force_single_error_fc0);
	the_flow_control0_l2->csr_retry(csr_retry0);
	the_flow_control0_l2->csr_force_single_stomp_fc(csr_force_single_stomp_fc0);

	the_flow_control0_l2->fc_clear_single_error_csr(fc0_clear_single_error_csr);
	the_flow_control0_l2->fc_clear_single_stomp_csr(fc0_clear_single_stomp_csr);
	
	the_flow_control0_l2->cd_initiate_retry_disconnect(cd0_initiate_retry_disconnect);
	the_flow_control0_l2->cd_rx_next_pkt_to_ack_fc(cd0_rx_next_pkt_to_ack_fc0);
#endif

	the_flow_control0_l2->db_nop_req_fc(db0_nop_req_fc0);
	the_flow_control0_l2->ro_nop_req_fc(ro0_nop_req_fc0);
	the_flow_control0_l2->fc_nop_sent(fc0_nop_sent);
	
	the_flow_control0_l2->cd_nopinfo_fc(cd0_nopinfo_fc0);
	the_flow_control0_l2->cd_nop_received_fc(cd0_nop_received_fc0);
#ifdef RETRY_MODE_ENABLED
	the_flow_control0_l2->cd_nop_ack_value_fc(cd0_nop_ack_value_fc0);
#endif

	the_flow_control0_l2->fwd_next_node_buffer_status_ro(fwd0_next_node_buffer_status_ro1);
#ifdef RETRY_MODE_ENABLED
	the_flow_control0_l2->lk_initiate_retry_disconnect(lk0_initiate_retry_disconnect);
	
	the_flow_control0_l2->history_memory_write(history_memory_write0);
	the_flow_control0_l2->history_memory_write_address(history_memory_write_address0);
	the_flow_control0_l2->history_memory_write_data(history_memory_write_data0);
	the_flow_control0_l2->history_memory_read_address(history_memory_read_address0);
	the_flow_control0_l2->history_memory_output(history_memory_output0);
#endif
	
	//******************************
	// Flow control 1 linkage
	//******************************
	the_flow_control1_l2 = new flow_control_l2("the_flow_control1_l2");

	the_flow_control1_l2->clk(clk);
	the_flow_control1_l2->resetx(resetx);
	the_flow_control1_l2->ldtstopx(registered_ldtstopx);

	the_flow_control1_l2->ui_packet_fc(ui_packet_fc1);
	the_flow_control1_l2->ui_available_fc(ui_available_fc1);
	the_flow_control1_l2->fc_user_fifo_ge2_ui(fc1_user_fifo_ge2_ui);
	
	the_flow_control1_l2->fc_data_vc_ui(fc1_data_vc_ui);
	the_flow_control1_l2->ui_data_fc(ui_data_fc1);
	the_flow_control1_l2->fc_consume_data_ui(fc1_consume_data_ui);
    
	the_flow_control1_l2->ro_available_fwd(ro0_available_fwd1);
	the_flow_control1_l2->ro_packet_fwd(ro0_packet_fwd1);
	the_flow_control1_l2->ro_packet_vc_fwd(ro0_packet_vc_fwd1);
	the_flow_control1_l2->fwd_ack_ro(fwd1_ack_ro0);

	the_flow_control1_l2->fc_dword_lk(fc1_dword_lk1);
	the_flow_control1_l2->fc_lctl_lk(fc1_lctl_lk1);
	the_flow_control1_l2->fc_hctl_lk(fc1_hctl_lk1);
	the_flow_control1_l2->lk_consume_fc(lk1_consume_fc1);
#ifdef RETRY_MODE_ENABLED
	the_flow_control1_l2->fc_disconnect_lk(fc1_disconnect_lk1);
	the_flow_control1_l2->lk_rx_connected(lk1_rx_connected);
#endif
    		
	the_flow_control1_l2->fwd_address_db(fwd1_address_db0);
	the_flow_control1_l2->fwd_vctype_db(fwd1_vctype_db0);
	the_flow_control1_l2->fwd_read_db(fwd1_read_db0);
	the_flow_control1_l2->fwd_erase_db(fwd1_erase_db0);
	the_flow_control1_l2->db_data_fwd(db0_data_fwd1);
	
	the_flow_control1_l2->ro_buffer_cnt_fc(ro1_buffer_cnt_fc1);
	the_flow_control1_l2->db_buffer_cnt_fc(db1_buffer_cnt_fc1);
    
	the_flow_control1_l2->fc_ack_eh(fc1_ack_eh1);
	the_flow_control1_l2->eh_cmd_data_fc(eh1_cmd_data_fc1);
	the_flow_control1_l2->eh_available_fc(eh1_available_fc1);
    
	the_flow_control1_l2->fc_ack_csr(fc1_ack_csr);
	the_flow_control1_l2->csr_available_fc(csr_available_fc1);
	the_flow_control1_l2->csr_dword_fc(csr_dword_fc1);
	
#ifdef RETRY_MODE_ENABLED
	the_flow_control1_l2->csr_force_single_error_fc(csr_force_single_error_fc1);
	the_flow_control1_l2->csr_force_single_stomp_fc(csr_force_single_stomp_fc1);
	the_flow_control1_l2->csr_retry(csr_retry1);
	
	the_flow_control1_l2->fc_clear_single_error_csr(fc1_clear_single_error_csr);
	the_flow_control1_l2->fc_clear_single_stomp_csr(fc1_clear_single_stomp_csr);

	the_flow_control1_l2->cd_initiate_retry_disconnect(cd1_initiate_retry_disconnect);
	the_flow_control1_l2->cd_rx_next_pkt_to_ack_fc(cd1_rx_next_pkt_to_ack_fc1);
#endif

	the_flow_control1_l2->db_nop_req_fc(db1_nop_req_fc1);
	the_flow_control1_l2->ro_nop_req_fc(ro1_nop_req_fc1);
	the_flow_control1_l2->fc_nop_sent(fc1_nop_sent);
	
	the_flow_control1_l2->cd_nopinfo_fc(cd1_nopinfo_fc1);
	the_flow_control1_l2->cd_nop_received_fc(cd1_nop_received_fc1);

	the_flow_control1_l2->fwd_next_node_buffer_status_ro(fwd1_next_node_buffer_status_ro0);
#ifdef RETRY_MODE_ENABLED
	the_flow_control1_l2->cd_nop_ack_value_fc(cd1_nop_ack_value_fc1);
	the_flow_control1_l2->lk_initiate_retry_disconnect(lk1_initiate_retry_disconnect);
	
	the_flow_control1_l2->history_memory_write(history_memory_write1);
	the_flow_control1_l2->history_memory_write_address(history_memory_write_address1);
	the_flow_control1_l2->history_memory_write_data(history_memory_write_data1);
	the_flow_control1_l2->history_memory_read_address(history_memory_read_address1);
	the_flow_control1_l2->history_memory_output(history_memory_output1);
#endif

	//******************************
	// Decoder 0 linkage
	//******************************
	the_decoder0_l2 = new decoder_l2("the_decoder0_l2");

	the_decoder0_l2->clk(clk);
	the_decoder0_l2->resetx(resetx);
#ifdef RETRY_MODE_ENABLED
	the_decoder0_l2->csr_retry(csr_retry0);
#endif

	the_decoder0_l2->cd_packet_ro(cd0_packet_ro0);
	the_decoder0_l2->cd_available_ro(cd0_available_ro0);
	the_decoder0_l2->cd_data_pending_ro(cd0_data_pending_ro0);
	the_decoder0_l2->cd_data_pending_addr_ro(cd0_data_pending_addr_ro0);

	the_decoder0_l2->db_address_cd(db0_address_cd0);
	the_decoder0_l2->cd_getaddr_db(cd0_getaddr_db0);
	the_decoder0_l2->cd_datalen_db(cd0_datalen_db0);
	the_decoder0_l2->cd_vctype_db(cd0_vctype_db0);
	the_decoder0_l2->cd_data_db(cd0_data_db0);
	the_decoder0_l2->cd_write_db(cd0_write_db0);
#ifdef RETRY_MODE_ENABLED
	the_decoder0_l2->cd_drop_db(cd0_drop_db0);
#endif

	the_decoder0_l2->cd_protocol_error_csr(cd0_protocol_error_csr);
	the_decoder0_l2->cd_sync_detected_csr(cd0_sync_detected_csr);
	
	the_decoder0_l2->lk_dword_cd(lk0_dword_cd0);
	the_decoder0_l2->lk_hctl_cd(lk0_hctl_cd0);
	the_decoder0_l2->lk_lctl_cd(lk0_lctl_cd0);
	the_decoder0_l2->lk_available_cd(lk0_available_cd0);

	the_decoder0_l2->cd_nopinfo_fc(cd0_nopinfo_fc0);
	the_decoder0_l2->cd_nop_received_fc(cd0_nop_received_fc0);
	the_decoder0_l2->cd_initiate_nonretry_disconnect_lk(cd0_initiate_nonretry_disconnect_lk0);
#ifdef RETRY_MODE_ENABLED
	the_decoder0_l2->cd_rx_next_pkt_to_ack_fc(cd0_rx_next_pkt_to_ack_fc0);
	the_decoder0_l2->cd_nop_ack_value_fc(cd0_nop_ack_value_fc0);

	the_decoder0_l2->cd_initiate_retry_disconnect(cd0_initiate_retry_disconnect);
	the_decoder0_l2->cd_received_stomped_csr(cd0_received_stomped_csr);
	the_decoder0_l2->cd_received_non_flow_stomped_ro(cd0_received_non_flow_stomped_ro0);
	the_decoder0_l2->lk_initiate_retry_disconnect(lk0_initiate_retry_disconnect);
#endif


	//******************************
	// Decoder 1 linkage
	//******************************
	the_decoder1_l2 = new decoder_l2("the_decoder1_l2");

	the_decoder1_l2->clk(clk);
	the_decoder1_l2->resetx(resetx);
#ifdef RETRY_MODE_ENABLED
	the_decoder1_l2->csr_retry(csr_retry1);
#endif

	the_decoder1_l2->cd_packet_ro(cd1_packet_ro1);
	the_decoder1_l2->cd_available_ro(cd1_available_ro1);
	the_decoder1_l2->cd_data_pending_ro(cd1_data_pending_ro1);
	the_decoder1_l2->cd_data_pending_addr_ro(cd1_data_pending_addr_ro1);

	the_decoder1_l2->db_address_cd(db1_address_cd1);
	the_decoder1_l2->cd_getaddr_db(cd1_getaddr_db1);
	the_decoder1_l2->cd_datalen_db(cd1_datalen_db1);
	the_decoder1_l2->cd_vctype_db(cd1_vctype_db1);
	the_decoder1_l2->cd_data_db(cd1_data_db1);
	the_decoder1_l2->cd_write_db(cd1_write_db1);
#ifdef RETRY_MODE_ENABLED
	the_decoder1_l2->cd_drop_db(cd1_drop_db1);
#endif

	the_decoder1_l2->cd_protocol_error_csr(cd1_protocol_error_csr);
	the_decoder1_l2->cd_sync_detected_csr(cd1_sync_detected_csr);
	
	the_decoder1_l2->lk_dword_cd(lk1_dword_cd1);
	the_decoder1_l2->lk_hctl_cd(lk1_hctl_cd1);
	the_decoder1_l2->lk_lctl_cd(lk1_lctl_cd1);
	the_decoder1_l2->lk_available_cd(lk1_available_cd1);

	the_decoder1_l2->cd_nopinfo_fc(cd1_nopinfo_fc1);
	the_decoder1_l2->cd_nop_received_fc(cd1_nop_received_fc1);
	the_decoder1_l2->cd_initiate_nonretry_disconnect_lk(cd1_initiate_nonretry_disconnect_lk1);
#ifdef RETRY_MODE_ENABLED
	the_decoder1_l2->cd_rx_next_pkt_to_ack_fc(cd1_rx_next_pkt_to_ack_fc1);
	the_decoder1_l2->cd_nop_ack_value_fc(cd1_nop_ack_value_fc1);

	the_decoder1_l2->cd_initiate_retry_disconnect(cd1_initiate_retry_disconnect);
	the_decoder1_l2->cd_received_stomped_csr(cd1_received_stomped_csr);
	the_decoder1_l2->cd_received_non_flow_stomped_ro(cd1_received_non_flow_stomped_ro1);
	the_decoder1_l2->lk_initiate_retry_disconnect(lk1_initiate_retry_disconnect);
#endif

	//**********************************
	//Data buffer 0 linkage
	//**********************************
	the_databuffer0_l2 = new databuffer_l2("the_databuffer0_l2");

	the_databuffer0_l2->resetx(resetx);
	the_databuffer0_l2->ldtstopx(registered_ldtstopx);
	the_databuffer0_l2->clk(clk);
	
	the_databuffer0_l2->cd_data_db(cd0_data_db0);
	the_databuffer0_l2->cd_datalen_db(cd0_datalen_db0);
	the_databuffer0_l2->cd_vctype_db(cd0_vctype_db0);
	the_databuffer0_l2->cd_write_db(cd0_write_db0);
	the_databuffer0_l2->cd_getaddr_db(cd0_getaddr_db0);
#ifdef RETRY_MODE_ENABLED
	the_databuffer0_l2->cd_drop_db(cd0_drop_db0);
	the_databuffer0_l2->lk_initiate_retry_disconnect(lk0_initiate_retry_disconnect);
	the_databuffer0_l2->cd_initiate_retry_disconnect(cd0_initiate_retry_disconnect);
	the_databuffer0_l2->csr_retry(csr_retry0);
#endif
	the_databuffer0_l2->db_address_cd(db0_address_cd0);

	the_databuffer0_l2->eh_address_db(eh0_address_db0);
	the_databuffer0_l2->eh_vctype_db(eh0_vctype_db0);
	the_databuffer0_l2->eh_erase_db(eh0_erase_db0);

	the_databuffer0_l2->csr_address_db(csr_address_db0);
	the_databuffer0_l2->csr_read_db(csr_read_db0);
	the_databuffer0_l2->csr_vctype_db(csr_vctype_db0);
	the_databuffer0_l2->db_data_accepted(db0_data_accepted);
	the_databuffer0_l2->csr_erase_db(csr_erase_db0);
	the_databuffer0_l2->ui_erase_db(ui_erase_db0);

	the_databuffer0_l2->ui_address_db(ui_address_db0);
	the_databuffer0_l2->ui_read_db(ui_read_db0);
	the_databuffer0_l2->ui_vctype_db(ui_vctype_db0);

	the_databuffer0_l2->fwd_address_db(fwd1_address_db0);
	the_databuffer0_l2->fwd_read_db(fwd1_read_db0);
	the_databuffer0_l2->fwd_vctype_db(fwd1_vctype_db0);
	the_databuffer0_l2->db_data_fwd(db0_data_fwd1);
	the_databuffer0_l2->fwd_erase_db(fwd1_erase_db0);

	the_databuffer0_l2->fc_nop_sent(fc0_nop_sent);
	the_databuffer0_l2->db_buffer_cnt_fc(db0_buffer_cnt_fc0);
	the_databuffer0_l2->db_nop_req_fc(db0_nop_req_fc0);

	the_databuffer0_l2->db_overflow_csr(db0_overflow_csr);

	the_databuffer0_l2->memory_write(memory_write0);
	the_databuffer0_l2->memory_write_address_vc(memory_write_address_vc0);
	the_databuffer0_l2->memory_write_address_buffer(memory_write_address_buffer0);
	the_databuffer0_l2->memory_write_address_pos(memory_write_address_pos0);
	the_databuffer0_l2->memory_write_data(memory_write_data0);
	
	for(int n = 0; n < 2; n++){
		the_databuffer0_l2->memory_read_address_vc[n](memory_read_address_vc0[n]);
		the_databuffer0_l2->memory_read_address_buffer[n](memory_read_address_buffer0[n]);
		the_databuffer0_l2->memory_read_address_pos[n](memory_read_address_pos0[n]);

		the_databuffer0_l2->memory_output[n](memory_output0[n]);
	}

	the_databuffer0_l2->ui_grant_csr_access_db(ui_grant_csr_access_db0);
	
	//**********************************
	//Data buffer 1 linkage
	//**********************************
	the_databuffer1_l2 = new databuffer_l2("the_databuffer1_l2");

	the_databuffer1_l2->resetx(resetx);
	the_databuffer1_l2->ldtstopx(registered_ldtstopx);
	the_databuffer1_l2->clk(clk);

	the_databuffer1_l2->cd_data_db(cd1_data_db1);
	the_databuffer1_l2->cd_datalen_db(cd1_datalen_db1);
	the_databuffer1_l2->cd_vctype_db(cd1_vctype_db1);
	the_databuffer1_l2->cd_write_db(cd1_write_db1);
	the_databuffer1_l2->cd_getaddr_db(cd1_getaddr_db1);
#ifdef RETRY_MODE_ENABLED
	the_databuffer1_l2->cd_drop_db(cd1_drop_db1);
	the_databuffer1_l2->lk_initiate_retry_disconnect(lk1_initiate_retry_disconnect);
	the_databuffer1_l2->cd_initiate_retry_disconnect(cd1_initiate_retry_disconnect);
	the_databuffer1_l2->csr_retry(csr_retry1);
#endif
	the_databuffer1_l2->db_address_cd(db1_address_cd1);

	the_databuffer1_l2->eh_address_db(eh1_address_db1);
	the_databuffer1_l2->eh_vctype_db(eh1_vctype_db1);
	the_databuffer1_l2->eh_erase_db(eh1_erase_db1);

	the_databuffer1_l2->csr_address_db(csr_address_db1);
	the_databuffer1_l2->csr_read_db(csr_read_db1);
	the_databuffer1_l2->csr_vctype_db(csr_vctype_db1);
	the_databuffer1_l2->db_data_accepted(db1_data_accepted);
	the_databuffer1_l2->csr_erase_db(csr_erase_db1);
	the_databuffer1_l2->ui_erase_db(ui_erase_db1);

	the_databuffer1_l2->ui_address_db(ui_address_db1);
	the_databuffer1_l2->ui_read_db(ui_read_db1);
	the_databuffer1_l2->ui_vctype_db(ui_vctype_db1);

	the_databuffer1_l2->fwd_address_db(fwd0_address_db1);
	the_databuffer1_l2->fwd_read_db(fwd0_read_db1);
	the_databuffer1_l2->fwd_vctype_db(fwd0_vctype_db1);
	the_databuffer1_l2->db_data_fwd(db1_data_fwd0);
	the_databuffer1_l2->fwd_erase_db(fwd0_erase_db1);

	the_databuffer1_l2->fc_nop_sent(fc1_nop_sent);
	the_databuffer1_l2->db_buffer_cnt_fc(db1_buffer_cnt_fc1);
	the_databuffer1_l2->db_nop_req_fc(db1_nop_req_fc1);

	the_databuffer1_l2->db_overflow_csr(db1_overflow_csr);

	the_databuffer1_l2->memory_write(memory_write1);
	the_databuffer1_l2->memory_write_address_vc(memory_write_address_vc1);
	the_databuffer1_l2->memory_write_address_buffer(memory_write_address_buffer1);
	the_databuffer1_l2->memory_write_address_pos(memory_write_address_pos1);
	the_databuffer1_l2->memory_write_data(memory_write_data1);
	
	for(int n = 0; n < 2; n++){
		the_databuffer1_l2->memory_read_address_vc[n](memory_read_address_vc1[n]);
		the_databuffer1_l2->memory_read_address_buffer[n](memory_read_address_buffer1[n]);
		the_databuffer1_l2->memory_read_address_pos[n](memory_read_address_pos1[n]);

		the_databuffer1_l2->memory_output[n](memory_output1[n]);
	}

	the_databuffer1_l2->ui_grant_csr_access_db(ui_grant_csr_access_db1);

	//**********************************
	//Reordering 0 linkage
	//**********************************

	the_reordering0_l2 = new reordering_l2("the_reordering0_l2");

	the_reordering0_l2->clk(clk);
	the_reordering0_l2->resetx(resetx);

	the_reordering0_l2->ro_packet_csr(ro0_packet_csr);

	the_reordering0_l2->ro_packet_ui(ro0_packet_ui);
	the_reordering0_l2->ro_packet_fwd(ro0_packet_fwd1);
	the_reordering0_l2->ro_packet_vc_fwd(ro0_packet_vc_fwd1);

	the_reordering0_l2->ro_available_csr(ro0_available_csr);
	the_reordering0_l2->ro_available_ui(ro0_available_ui);
	the_reordering0_l2->ro_available_fwd(ro0_available_fwd1);

	the_reordering0_l2->csr_ack_ro(csr_ack_ro0);
	the_reordering0_l2->ui_ack_ro(ui_ack_ro0);
	the_reordering0_l2->fwd_ack_ro(fwd1_ack_ro0);
	the_reordering0_l2->eh_ack_ro(eh0_ack_ro0);

	the_reordering0_l2->cd_packet_ro(cd0_packet_ro0);
	the_reordering0_l2->cd_available_ro(cd0_available_ro0);
	the_reordering0_l2->cd_data_pending_ro(cd0_data_pending_ro0);
	the_reordering0_l2->cd_data_pending_addr_ro(cd0_data_pending_addr_ro0);

	the_reordering0_l2->csr_unit_id(csr_unit_id);

	for(int n = 0; n < NbRegsBars; n++){
		the_reordering0_l2->csr_bar[n](csr_bar[n]);
	}

	the_reordering0_l2->csr_memory_space_enable(csr_memory_space_enable);
	the_reordering0_l2->csr_io_space_enable(csr_io_space_enable);
	//for(int n = 0; n < DirectRoute_NumberDirectRouteSpaces; n++){
	//	the_reordering0_l2->csr_direct_route_base[n](csr_direct_route_base[n]);
	//	the_reordering0_l2->csr_direct_route_limit[n](csr_direct_route_limit[n]);
	//}
#ifdef ENABLE_DIRECTROUTE
	the_reordering0_l2->csr_direct_route_enable(csr_direct_route_enable);
#endif
#ifdef ENABLE_REORDERING
	the_reordering0_l2->csr_unitid_reorder_disable(csr_unitid_reorder_disable);
#endif
	the_reordering0_l2->csr_sync(csr_sync);
	
	the_reordering0_l2->fc_nop_sent(fc0_nop_sent);
	the_reordering0_l2->fwd_next_node_buffer_status_ro(fwd1_next_node_buffer_status_ro0);
	
	the_reordering0_l2->ro_buffer_cnt_fc(ro0_buffer_cnt_fc0);
	the_reordering0_l2->ro_nop_req_fc(ro0_nop_req_fc0);
	the_reordering0_l2->ro_overflow_csr(ro0_overflow_csr);

#ifdef ENABLE_REORDERING
	for(int n = 0; n < 32; n++){
#else
	for(int n = 0; n < 4; n++){
#endif
		the_reordering0_l2->clumped_unit_id[n](clumped_unit_id[n]);
	}

#ifdef RETRY_MODE_ENABLED
	the_reordering0_l2->lk_rx_connected(lk0_rx_connected);
	the_reordering0_l2->csr_retry(csr_retry0);
	the_reordering0_l2->cd_received_non_flow_stomped_ro(cd0_received_non_flow_stomped_ro0);
#endif
	///////////////////////////////////////
	// Interface to command memory 0
	///////////////////////////////////////
	the_reordering0_l2->ro_command_packet_wr_data(ro0_command_packet_wr_data);
	the_reordering0_l2->ro_command_packet_write(ro0_command_packet_write);
	the_reordering0_l2->ro_command_packet_wr_addr(ro0_command_packet_wr_addr);
	the_reordering0_l2->ro_command_packet_rd_addr[0](ro0_command_packet_rd_addr[0]);
	the_reordering0_l2->ro_command_packet_rd_addr[1](ro0_command_packet_rd_addr[1]);
	the_reordering0_l2->command_packet_rd_data_ro[0](command_packet_rd_data_ro0[0]);
	the_reordering0_l2->command_packet_rd_data_ro[1](command_packet_rd_data_ro0[1]);

	//**********************************
	//Reordering 1 linkage
	//**********************************

	the_reordering1_l2 = new reordering_l2("the_reordering1_l2");

	the_reordering1_l2->clk(clk);
	the_reordering1_l2->resetx(resetx);

	the_reordering1_l2->ro_packet_csr(ro1_packet_csr);

	the_reordering1_l2->ro_packet_ui(ro1_packet_ui);
	the_reordering1_l2->ro_packet_fwd(ro1_packet_fwd0);
	the_reordering1_l2->ro_packet_vc_fwd(ro1_packet_vc_fwd0);

	the_reordering1_l2->ro_available_csr(ro1_available_csr);
	the_reordering1_l2->ro_available_ui(ro1_available_ui);
	the_reordering1_l2->ro_available_fwd(ro1_available_fwd0);

	the_reordering1_l2->csr_ack_ro(csr_ack_ro1);
	the_reordering1_l2->ui_ack_ro(ui_ack_ro1);
	the_reordering1_l2->fwd_ack_ro(fwd0_ack_ro1);
	the_reordering1_l2->eh_ack_ro(eh1_ack_ro1);

	the_reordering1_l2->cd_packet_ro(cd1_packet_ro1);
	the_reordering1_l2->cd_available_ro(cd1_available_ro1);
	the_reordering1_l2->cd_data_pending_ro(cd1_data_pending_ro1);
	the_reordering1_l2->cd_data_pending_addr_ro(cd1_data_pending_addr_ro1);

	the_reordering1_l2->csr_unit_id(csr_unit_id);

	for(int n = 0; n < NbRegsBars; n++){
		the_reordering1_l2->csr_bar[n](csr_bar[n]);
	}

	the_reordering1_l2->csr_memory_space_enable(csr_memory_space_enable);
	the_reordering1_l2->csr_io_space_enable(csr_io_space_enable);
	//for(int n = 0; n < DirectRoute_NumberDirectRouteSpaces; n++){
	//	the_reordering1_l2->csr_direct_route_base[n](csr_direct_route_base[n]);
	//	the_reordering1_l2->csr_direct_route_limit[n](csr_direct_route_limit[n]);
	//}
#ifdef ENABLE_DIRECTROUTE
	the_reordering1_l2->csr_direct_route_enable(csr_direct_route_enable);
#endif
#ifdef ENABLE_REORDERING
	the_reordering1_l2->csr_unitid_reorder_disable(csr_unitid_reorder_disable);
#endif
	the_reordering1_l2->csr_sync(csr_sync);
	
	the_reordering1_l2->fc_nop_sent(fc1_nop_sent);
	the_reordering1_l2->fwd_next_node_buffer_status_ro(fwd0_next_node_buffer_status_ro1);
	
	the_reordering1_l2->ro_buffer_cnt_fc(ro1_buffer_cnt_fc1);
	the_reordering1_l2->ro_nop_req_fc(ro1_nop_req_fc1);
	the_reordering1_l2->ro_overflow_csr(ro1_overflow_csr);

#ifdef ENABLE_REORDERING
	for(int n = 0; n < 32; n++){
#else
	for(int n = 0; n < 4; n++){
#endif
		the_reordering1_l2->clumped_unit_id[n](clumped_unit_id[n]);
	}

#ifdef RETRY_MODE_ENABLED
	the_reordering1_l2->lk_rx_connected(lk1_rx_connected);
	the_reordering1_l2->csr_retry(csr_retry1);
	the_reordering1_l2->cd_received_non_flow_stomped_ro(cd1_received_non_flow_stomped_ro1);
#endif

	///////////////////////////////////////
	// Interface to command memory 1
	///////////////////////////////////////
	the_reordering1_l2->ro_command_packet_wr_data(ro1_command_packet_wr_data);
	the_reordering1_l2->ro_command_packet_write(ro1_command_packet_write);
	the_reordering1_l2->ro_command_packet_wr_addr(ro1_command_packet_wr_addr);
	the_reordering1_l2->ro_command_packet_rd_addr[0](ro1_command_packet_rd_addr[0]);
	the_reordering1_l2->ro_command_packet_rd_addr[1](ro1_command_packet_rd_addr[1]);
	the_reordering1_l2->command_packet_rd_data_ro[0](command_packet_rd_data_ro1[0]);
	the_reordering1_l2->command_packet_rd_data_ro[1](command_packet_rd_data_ro1[1]);

	//************************************
	//User interface linkage
	//************************************

	the_userinterface_l2 = new userinterface_l2("the_userinterface_l2");

	the_userinterface_l2->clk(clk);
	the_userinterface_l2->resetx(resetx);

#ifdef ENABLE_DIRECTROUTE
	for(int n = 0; n < DirectRoute_NumberDirectRouteSpaces;n++){
		the_userinterface_l2->csr_direct_route_oppposite_dir[n](csr_direct_route_oppposite_dir[n]);
		the_userinterface_l2->csr_direct_route_base[n](csr_direct_route_base[n]);
		the_userinterface_l2->csr_direct_route_limit[n](csr_direct_route_limit[n]);
	}
	the_userinterface_l2->csr_direct_route_enable(csr_direct_route_enable);
#endif

	the_userinterface_l2->csr_default_dir(csr_default_dir);
	the_userinterface_l2->csr_master_host(csr_master_host);
	the_userinterface_l2->csr_end_of_chain0(csr_end_of_chain0);
	the_userinterface_l2->csr_end_of_chain1(csr_end_of_chain1);
	the_userinterface_l2->csr_bus_master_enable(csr_bus_master_enable);

	the_userinterface_l2->ui_address_db0(ui_address_db0);
	the_userinterface_l2->ui_read_db0(ui_read_db0);
	the_userinterface_l2->ui_vctype_db0(ui_vctype_db0);
	the_userinterface_l2->db0_data_ui(db0_data_accepted);
	the_userinterface_l2->ui_erase_db0(ui_erase_db0);

	the_userinterface_l2->ro0_packet_ui(ro0_packet_ui);
	the_userinterface_l2->ro0_available_ui(ro0_available_ui);
	the_userinterface_l2->ui_ack_ro0(ui_ack_ro0);

	the_userinterface_l2->ui_packet_fc0(ui_packet_fc0);
	the_userinterface_l2->ui_available_fc0(ui_available_fc0);
	the_userinterface_l2->fc0_user_fifo_ge2_ui(fc0_user_fifo_ge2_ui);

	the_userinterface_l2->ui_data_fc0(ui_data_fc0);
	the_userinterface_l2->fc0_data_vc_ui(fc0_data_vc_ui);
	the_userinterface_l2->fc0_consume_data_ui(fc0_consume_data_ui);

	the_userinterface_l2->ui_address_db1(ui_address_db1);
	the_userinterface_l2->ui_read_db1(ui_read_db1);
	the_userinterface_l2->ui_vctype_db1(ui_vctype_db1);
	the_userinterface_l2->db1_data_ui(db1_data_accepted);
	the_userinterface_l2->ui_erase_db1(ui_erase_db1);

	the_userinterface_l2->ro1_packet_ui(ro1_packet_ui);
	the_userinterface_l2->ro1_available_ui(ro1_available_ui);
	the_userinterface_l2->ui_ack_ro1(ui_ack_ro1);

	the_userinterface_l2->ui_packet_fc1(ui_packet_fc1);
	the_userinterface_l2->ui_available_fc1(ui_available_fc1);
	the_userinterface_l2->fc1_user_fifo_ge2_ui(fc1_user_fifo_ge2_ui);
	the_userinterface_l2->ui_data_fc1(ui_data_fc1);
	the_userinterface_l2->fc1_data_vc_ui(fc1_data_vc_ui);
	the_userinterface_l2->fc1_consume_data_ui(fc1_consume_data_ui);

	the_userinterface_l2->ui_packet_usr(ui_packet_usr);
	the_userinterface_l2->ui_vc_usr(ui_vc_usr);
	the_userinterface_l2->ui_side_usr(ui_side_usr);
	the_userinterface_l2->ui_eop_usr(ui_eop_usr);
	the_userinterface_l2->ui_available_usr(ui_available_usr);
	the_userinterface_l2->ui_output_64bits_usr(ui_output_64bits_usr);
	the_userinterface_l2->usr_consume_ui(usr_consume_ui);

	the_userinterface_l2->usr_packet_ui(usr_packet_ui);
	the_userinterface_l2->usr_available_ui(usr_available_ui);
	the_userinterface_l2->usr_side_ui(usr_side_ui);
#ifdef ENABLE_DIRECTROUTE
	the_userinterface_l2->ui_directroute_usr(ui_directroute_usr);
#endif
	//the_userinterface_l2->ui_invalid_usr(ui_invalid_usr);
	the_userinterface_l2->ui_freevc0_usr(ui_freevc0_usr);
	the_userinterface_l2->ui_freevc1_usr(ui_freevc1_usr);
	the_userinterface_l2->ui_sendingPostedDataError_csr(ui_sendingPostedDataError_csr);
	the_userinterface_l2->ui_sendingTargetAbort_csr(ui_sendingTargetAbort_csr);

	the_userinterface_l2->ui_receivedResponseDataError_csr(ui_receivedResponseDataError_csr);
	the_userinterface_l2->ui_receivedPostedDataError_csr(ui_receivedPostedDataError_csr);
	the_userinterface_l2->ui_receivedTargetAbort_csr(ui_receivedTargetAbort_csr);
	the_userinterface_l2->ui_receivedMasterAbort_csr(ui_receivedMasterAbort_csr);

	the_userinterface_l2->ui_memory_write0(ui_memory_write0);
	the_userinterface_l2->ui_memory_write1(ui_memory_write1);
	the_userinterface_l2->ui_memory_write_address(ui_memory_write_address);
	the_userinterface_l2->ui_memory_write_data(ui_memory_write_data);

	the_userinterface_l2->ui_memory_read_address0(ui_memory_read_address0);
	the_userinterface_l2->ui_memory_read_address1(ui_memory_read_address1);
	the_userinterface_l2->ui_memory_read_data0(ui_memory_read_data0);
	the_userinterface_l2->ui_memory_read_data1(ui_memory_read_data1);

	the_userinterface_l2->csr_request_databuffer0_access_ui(csr_request_databuffer0_access_ui);
	the_userinterface_l2->csr_request_databuffer1_access_ui(csr_request_databuffer1_access_ui);
	the_userinterface_l2->ui_databuffer_access_granted_csr(ui_databuffer_access_granted_csr);
	the_userinterface_l2->ui_grant_csr_access_db0(ui_grant_csr_access_db0);
	the_userinterface_l2->ui_grant_csr_access_db1(ui_grant_csr_access_db1);
	
	//************************************
	//Error handler 0 linkage
	//************************************

	the_errorhandler0_l2 = new errorhandler_l2("the_errorhandler0_l2");

	the_errorhandler0_l2->resetx(resetx);
	the_errorhandler0_l2->clk(clk);
	the_errorhandler0_l2->csr_unit_id(csr_unit_id);

	the_errorhandler0_l2->ro_packet_fwd(ro0_packet_fwd1);
	the_errorhandler0_l2->ro_available_fwd(ro0_available_fwd1);
	the_errorhandler0_l2->eh_ack_ro(eh0_ack_ro0);

	the_errorhandler0_l2->fc_ack_eh(fc0_ack_eh0);
	the_errorhandler0_l2->eh_cmd_data_fc(eh0_cmd_data_fc0);
	the_errorhandler0_l2->eh_available_fc(eh0_available_fc0);

	the_errorhandler0_l2->eh_address_db(eh0_address_db0);
	the_errorhandler0_l2->eh_erase_db(eh0_erase_db0);
	the_errorhandler0_l2->eh_vctype_db(eh0_vctype_db0);

	the_errorhandler0_l2->csr_end_of_chain(csr_end_of_chain0);
	the_errorhandler0_l2->csr_initcomplete(csr_initcomplete0);
	the_errorhandler0_l2->csr_drop_uninit_link(csr_drop_uninit_link);


	//************************************
	//Error handler 1 linkage
	//************************************

	the_errorhandler1_l2 = new errorhandler_l2("the_errorhandler1_l2");

	the_errorhandler1_l2->resetx(resetx);
	the_errorhandler1_l2->clk(clk);
	the_errorhandler1_l2->csr_unit_id(csr_unit_id);

	the_errorhandler1_l2->ro_packet_fwd(ro1_packet_fwd0);
	the_errorhandler1_l2->ro_available_fwd(ro1_available_fwd0);
	the_errorhandler1_l2->eh_ack_ro(eh1_ack_ro1);

	the_errorhandler1_l2->fc_ack_eh(fc1_ack_eh1);
	the_errorhandler1_l2->eh_cmd_data_fc(eh1_cmd_data_fc1);
	the_errorhandler1_l2->eh_available_fc(eh1_available_fc1);

	the_errorhandler1_l2->eh_address_db(eh1_address_db1);
	the_errorhandler1_l2->eh_erase_db(eh1_erase_db1);
	the_errorhandler1_l2->eh_vctype_db(eh1_vctype_db1);

	the_errorhandler1_l2->csr_end_of_chain(csr_end_of_chain1);
	the_errorhandler1_l2->csr_initcomplete(csr_initcomplete1);
	the_errorhandler1_l2->csr_drop_uninit_link(csr_drop_uninit_link);

	//**************************************
	// Link 0 linkage
	//**************************************

	the_link0_l2 = new link_l2("the_link0_l2");

	the_link0_l2->clk(clk);

	//the_link0_l2->receive_clk(receive_clk0);
	the_link0_l2->phy_available_lk(phy0_available_lk0);
	the_link0_l2->phy_ctl_lk(phy0_ctl_lk0);
	for(int n = 0; n < CAD_IN_WIDTH; n++){
		the_link0_l2->phy_cad_lk[n](phy0_cad_lk0[n]);
	}

	//the_link0_l2->transmit_clk(transmit_clk0);
	the_link0_l2->phy_consume_lk(phy0_consume_lk0);
	the_link0_l2->lk_ctl_phy(lk0_ctl_phy0);
	for(int n = 0; n < CAD_OUT_WIDTH; n++){
		the_link0_l2->lk_cad_phy[n](lk0_cad_phy0[n]);
	}
#ifndef INTERNAL_SHIFTER_ALIGNMENT
	the_link0_l2->lk_deser_stall_phy(lk0_deser_stall_phy0);
	the_link0_l2->lk_deser_stall_cycles_phy(lk0_deser_stall_cycles_phy0);
#endif
	the_link0_l2->ldtstopx(registered_ldtstopx);
	the_link0_l2->resetx(resetx);
	the_link0_l2->pwrok(pwrok);


	the_link0_l2->lk_dword_cd(lk0_dword_cd0);
	the_link0_l2->lk_lctl_cd(lk0_lctl_cd0);
	the_link0_l2->lk_hctl_cd(lk0_hctl_cd0);
	the_link0_l2->lk_available_cd(lk0_available_cd0);

	the_link0_l2->fc_dword_lk(fc0_dword_lk0);
	the_link0_l2->fc_lctl_lk(fc0_lctl_lk0);
	the_link0_l2->fc_hctl_lk(fc0_hctl_lk0);
	the_link0_l2->lk_consume_fc(lk0_consume_fc0);


	the_link0_l2->csr_rx_link_width_lk(csr_rx_link_width_lk0);
	the_link0_l2->csr_tx_link_width_lk(csr_tx_link_width_lk0);

#ifdef RETRY_MODE_ENABLED
	the_link0_l2->csr_retry(csr_retry0);
#endif
	the_link0_l2->csr_sync(csr_sync);
	the_link0_l2->csr_end_of_chain(csr_end_of_chain0);

	the_link0_l2->lk_update_link_width_csr(lk0_update_link_width_csr);
	the_link0_l2->lk_sampled_link_width_csr(lk0_sampled_link_width_csr);

	the_link0_l2->lk_protocol_error_csr(lk0_protocol_error_csr);

#ifdef RETRY_MODE_ENABLED
	the_link0_l2->fc_disconnect_lk(fc0_disconnect_lk0);
#endif

	the_link0_l2->csr_crc_force_error_lk(csr_crc_force_error_lk0);
	the_link0_l2->csr_transmitter_off_lk(csr_transmitter_off_lk0);
	the_link0_l2->csr_extented_ctl_lk(csr_extented_ctl_lk0);
	the_link0_l2->csr_extended_ctl_timeout_lk(csr_extended_ctl_timeout_lk0);
	the_link0_l2->csr_ldtstop_tristate_enable_lk(csr_ldtstop_tristate_enable_lk0);

	the_link0_l2->lk_crc_error_csr(lk0_crc_error_csr);
	the_link0_l2->lk_update_link_failure_property_csr(lk0_update_link_failure_property_csr);
#ifdef RETRY_MODE_ENABLED
	the_link0_l2->lk_initiate_retry_disconnect(lk0_initiate_retry_disconnect);
#endif

	the_link0_l2->lk_rx_connected(lk0_rx_connected);
	the_link0_l2->lk_link_failure_csr(lk0_link_failure_csr);

	//the_link0_l2->lk_sync_detected_csr(lk0_sync_detected_csr);

#ifdef RETRY_MODE_ENABLED
	the_link0_l2->cd_initiate_retry_disconnect(cd0_initiate_retry_disconnect);
#endif
	the_link0_l2->cd_initiate_nonretry_disconnect_lk(cd0_initiate_nonretry_disconnect_lk0);

	the_link0_l2->lk_disable_drivers_phy(lk0_disable_drivers_phy0);
	the_link0_l2->lk_disable_receivers_phy(lk0_disable_receivers_phy0);

	the_link0_l2->lk_ldtstop_disconnected(lk0_ldtstop_disconnected);
	
	//**************************************
	// Link 1 linkage
	//**************************************

	the_link1_l2 = new link_l2("the_link1_l2");

	the_link1_l2->clk(clk);

	//the_link0_l2->receive_clk(receive_clk0);
	the_link1_l2->phy_available_lk(phy1_available_lk1);
	the_link1_l2->phy_ctl_lk(phy1_ctl_lk1);
	for(int n = 0; n < CAD_IN_WIDTH; n++){
		the_link1_l2->phy_cad_lk[n](phy1_cad_lk1[n]);
	}

	//the_link0_l2->transmit_clk(transmit_clk0);
	the_link1_l2->phy_consume_lk(phy1_consume_lk1);
	the_link1_l2->lk_ctl_phy(lk1_ctl_phy1);
	for(int n = 0; n < CAD_OUT_WIDTH; n++){
		the_link1_l2->lk_cad_phy[n](lk1_cad_phy1[n]);
	}
#ifndef INTERNAL_SHIFTER_ALIGNMENT
	the_link1_l2->lk_deser_stall_phy(lk1_deser_stall_phy1);
	the_link1_l2->lk_deser_stall_cycles_phy(lk1_deser_stall_cycles_phy1);
#endif

	the_link1_l2->ldtstopx(registered_ldtstopx);
	the_link1_l2->resetx(resetx);
	the_link1_l2->pwrok(pwrok);


	the_link1_l2->lk_dword_cd(lk1_dword_cd1);
	the_link1_l2->lk_lctl_cd(lk1_lctl_cd1);
	the_link1_l2->lk_hctl_cd(lk1_hctl_cd1);
	the_link1_l2->lk_available_cd(lk1_available_cd1);

	the_link1_l2->fc_dword_lk(fc1_dword_lk1);
	the_link1_l2->fc_lctl_lk(fc1_lctl_lk1);
	the_link1_l2->fc_hctl_lk(fc1_hctl_lk1);
	the_link1_l2->lk_consume_fc(lk1_consume_fc1);


	the_link1_l2->csr_rx_link_width_lk(csr_rx_link_width_lk1);
	the_link1_l2->csr_tx_link_width_lk(csr_tx_link_width_lk1);

#ifdef RETRY_MODE_ENABLED
	the_link1_l2->csr_retry(csr_retry1);
#endif
	the_link1_l2->csr_sync(csr_sync);
	the_link1_l2->csr_end_of_chain(csr_end_of_chain1);

	the_link1_l2->lk_update_link_width_csr(lk1_update_link_width_csr);
	the_link1_l2->lk_sampled_link_width_csr(lk1_sampled_link_width_csr);

	the_link1_l2->lk_protocol_error_csr(lk1_protocol_error_csr);

#ifdef RETRY_MODE_ENABLED
	the_link1_l2->fc_disconnect_lk(fc1_disconnect_lk1);
#endif

	the_link1_l2->csr_crc_force_error_lk(csr_crc_force_error_lk1);
	the_link1_l2->csr_transmitter_off_lk(csr_transmitter_off_lk1);
	the_link1_l2->csr_extented_ctl_lk(csr_extented_ctl_lk1);
	the_link1_l2->csr_extended_ctl_timeout_lk(csr_extended_ctl_timeout_lk1);
	the_link1_l2->csr_ldtstop_tristate_enable_lk(csr_ldtstop_tristate_enable_lk1);

	the_link1_l2->lk_crc_error_csr(lk1_crc_error_csr);
	the_link1_l2->lk_update_link_failure_property_csr(lk1_update_link_failure_property_csr);
#ifdef RETRY_MODE_ENABLED
	the_link1_l2->lk_initiate_retry_disconnect(lk1_initiate_retry_disconnect);
#endif

	the_link1_l2->lk_rx_connected(lk1_rx_connected);
	the_link1_l2->lk_link_failure_csr(lk1_link_failure_csr);

	//the_link1_l2->lk_sync_detected_csr(lk1_sync_detected_csr);

#ifdef RETRY_MODE_ENABLED
	the_link1_l2->cd_initiate_retry_disconnect(cd1_initiate_retry_disconnect);
#endif
	the_link1_l2->cd_initiate_nonretry_disconnect_lk(cd1_initiate_nonretry_disconnect_lk1);

	the_link1_l2->lk_disable_drivers_phy(lk1_disable_drivers_phy1);
	the_link1_l2->lk_disable_receivers_phy(lk1_disable_receivers_phy1);
	the_link1_l2->lk_ldtstop_disconnected(lk1_ldtstop_disconnected);

	//**************************************
	// Misc logic linkage
	//**************************************

	the_misc_logic_l2 = new misc_logic_l2("the_misc_logic_l2");

	the_misc_logic_l2->clk(clk);
	the_misc_logic_l2->resetx(resetx);
	the_misc_logic_l2->pwrok(pwrok);
	the_misc_logic_l2->ldtstopx(ldtstopx);
	the_misc_logic_l2->lk0_ldtstop_disconnected(lk0_ldtstop_disconnected);
	the_misc_logic_l2->lk1_ldtstop_disconnected(lk1_ldtstop_disconnected);
	the_misc_logic_l2->csr_link_frequency0(csr_link_frequency0);
	the_misc_logic_l2->csr_link_frequency1(csr_link_frequency1);
	the_misc_logic_l2->link_frequency0_phy(link_frequency0_phy);
	the_misc_logic_l2->link_frequency1_phy(link_frequency1_phy);
	the_misc_logic_l2->csr_clumping_configuration(csr_clumping_configuration);
	the_misc_logic_l2->registered_ldtstopx(registered_ldtstopx);

#ifdef ENABLE_REORDERING
	for(int n = 0; n < 32; n++){
#else
	for(int n = 0; n < 4; n++){
#endif
		the_misc_logic_l2->clumped_unit_id[n](clumped_unit_id[n]);
	}
}

#ifdef SYSTEMC_SIM
vc_ht_tunnel_l1::~vc_ht_tunnel_l1(){
	delete the_decoder0_l2;
	delete the_databuffer0_l2;
	delete the_flow_control0_l2;
	delete the_link0_l2;
	delete the_errorhandler0_l2;	
	delete the_reordering0_l2;

	delete the_decoder1_l2;
	delete the_databuffer1_l2;
	delete the_flow_control1_l2;
	delete the_link1_l2;
	delete the_errorhandler1_l2;	
	delete the_reordering1_l2;

	//Shared
	delete the_csr_l2;
	delete the_userinterface_l2;
	delete the_misc_logic_l2;
}
#endif


