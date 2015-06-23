//flow_control_l2.cpp

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
 *   Jean-Francois Belanger
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

#include "flow_control_l2.h"
#include "flow_control_l3.h"
#include "nop_framer_l3.h"
#include "multiplexer_l3.h"
#include "rx_farend_cnt_l3.h"
#include "user_fifo_l3.h"
#include "fairness_l3.h"

#ifdef RETRY_MODE_ENABLED
#include "history_buffer_l3.h"
#include "fc_packet_crc_l3.h"
#endif
/**  *************************************************************
This file contain the linking of all submodule of flow_control
*************************************************************
**/

flow_control_l2::flow_control_l2(sc_module_name name) : sc_module(name)
{

#ifdef RETRY_MODE_ENABLED
	SC_METHOD(send_clear_single_error_and_stomp);
	sensitive << clear_crc << clear_nop_crc;
#endif
	
	the_flow_control = new flow_control_l3("the_flow_control_l3");
	
	//	Linking of the flow control state-machine sub module
	
	
	//************ THE FLOW CONTROL ******************
	
	//Signals to internal FIFO
	the_flow_control->fifo_user_available(fifo_user_available);  				//fifo have a packet to send
	the_flow_control->fifo_user_packet(fifo_user_packet); 
 	the_flow_control->fifo_user_packet_vc(fifo_user_packet_vc);
	the_flow_control->fifo_user_packet_dword(fifo_user_packet_dword);
	the_flow_control->fifo_user_packet_data_asociated(fifo_user_packet_data_asociated);
#ifdef RETRY_MODE_ENABLED
	the_flow_control->fifo_user_packet_command(fifo_user_packet_command);
#endif
	the_flow_control->fifo_user_packet_data_count_m1(fifo_user_packet_data_count_m1);
	the_flow_control->fifo_user_packet_isChain(fifo_user_packet_isChain);
	the_flow_control->consume_user_fifo(consume_user_fifo);   		//acknowledge signal 	
	the_flow_control->hold_user_fifo(hold_user_fifo);   		//acknowledge signal 	
	
	//Signals to error handler
	the_flow_control->fc_ack_eh(fc_ack_eh);
	the_flow_control->eh_cmd_data_fc(eh_cmd_data_fc);
	the_flow_control->eh_available_fc(eh_available_fc);
	
	
	//Signals to CSR
	the_flow_control->fc_ack_csr(fc_ack_csr);
	the_flow_control->csr_dword_fc(csr_dword_fc);
	the_flow_control->csr_available_fc(csr_available_fc);

	
	
	//Signals to Reordering
	the_flow_control->ro_available_fwd(ro_available_fwd);		//RO have a packet to send
	the_flow_control->ro_nop_req_fc(ro_nop_req_fc);
	the_flow_control->ro_packet_fwd(ro_packet_fwd);
	the_flow_control->ro_packet_vc_fwd(ro_packet_vc_fwd);
	the_flow_control->fwd_ack_ro(fwd_ack_ro);  		//acknowledge signal
	
	
	//Signals to User Interface
	the_flow_control->fc_data_vc_ui(fc_data_vc_ui);		//dant state Local_cmd_sent
	the_flow_control->fc_consume_data_ui(fc_consume_data_ui);				//data consumme
	
	
	//Signals from databuffer from this side   
	the_flow_control->db_nop_req_fc(db_nop_req_fc);
	
	
	//Signals from databuffer from other side   
	the_flow_control->fwd_address_db(fwd_address_db);
	the_flow_control->fwd_vctype_db(fwd_vctype_db);
	the_flow_control->fwd_read_db(fwd_read_db);
	the_flow_control->fwd_erase_db(fwd_erase_db);
	
	//Signals from nop_framer
	the_flow_control->nop_next_to_send(nop_next_to_send);
	the_flow_control->generate_disconnect_nop(generate_disconnect_nop);
	the_flow_control->has_nop_buffers_to_send(has_nop_buffers_to_send);
	
	
	//Signals to rx_farend_cnt
	the_flow_control->current_sent_type(current_sent_type);
	the_flow_control->fwd_next_node_buffer_status_ro(fwd_next_node_buffer_status_ro);
#ifdef RETRY_MODE_ENABLED
	the_flow_control->clear_farend_count(clear_farend_count);
#endif
	
	//Signal for output selection (Multiplexer)
	the_flow_control->fc_ctr_mux(fc_ctr_mux);  
	
	//Signals to link
	the_flow_control->fc_lctl_lk(fc_lctl_lk);    	
	the_flow_control->fc_hctl_lk(fc_hctl_lk);    	
	the_flow_control->lk_consume_fc(lk_consume_fc);    
#ifdef RETRY_MODE_ENABLED
	the_flow_control->lk_rx_connected(lk_rx_connected);
	the_flow_control->fc_disconnect_lk(fc_disconnect_lk);
	the_flow_control->lk_initiate_retry_disconnect(lk_initiate_retry_disconnect);
	//Signals to command decoder
	the_flow_control->cd_initiate_retry_disconnect(cd_initiate_retry_disconnect);
	the_flow_control->csr_retry(csr_retry);
#endif	
	
	//Signals to fairness
	the_flow_control->local_priority(local_priority);
	the_flow_control->local_packet_issued(local_packet_issued);

	
	//Misc signals
	the_flow_control->clock(clk);
	the_flow_control->resetx(resetx);
	the_flow_control->ldtstopx(ldtstopx);
	the_flow_control->fc_nop_sent(fc_nop_sent);
	the_flow_control->nop_received(cd_nop_received_fc);
	

		
		
#ifdef RETRY_MODE_ENABLED
	//History signals
	the_flow_control->history_packet(history_packet);
	
	the_flow_control->history_playback_done(history_playback_done);
	the_flow_control->begin_history_playback(begin_history_playback);
	the_flow_control->stop_history_playback(stop_history_playback);
	the_flow_control->consume_history(consume_history);
	
	the_flow_control->room_available_in_history(room_available_in_history);
	
	the_flow_control->add_to_history(add_to_history);
	the_flow_control->new_history_entry(new_history_entry);
	the_flow_control->new_history_entry_size_m1(new_history_entry_size_m1);
	the_flow_control->history_playback_ready(history_playback_ready);
	
	//Signals to CRC unit
	the_flow_control->calculate_crc(calculate_crc);
	the_flow_control->clear_crc(clear_crc);
	the_flow_control->calculate_nop_crc(calculate_nop_crc);
	the_flow_control->clear_nop_crc(clear_nop_crc);
	
	the_flow_control->select_crc_output(select_crc_output);
	the_flow_control->select_nop_crc_output(select_nop_crc_output);
#endif	
	
	
	
	
	//*********************************
	//Linking of the nop_framer module
	//*********************************
	
	the_nop_framer = new nop_framer_l3("the_nop_framer");

	the_nop_framer->db_buffer_cnt_fc(db_buffer_cnt_fc);
	the_nop_framer->ro_buffer_cnt_fc(ro_buffer_cnt_fc);
	the_nop_framer->ro_nop_req_fc(ro_nop_req_fc);
	the_nop_framer->db_nop_req_fc(db_nop_req_fc);
	the_nop_framer->generate_disconnect_nop(generate_disconnect_nop);
	the_nop_framer->has_nop_buffers_to_send(has_nop_buffers_to_send);
	the_nop_framer->ht_nop_pkt(ht_nop_pkt);
	the_nop_framer->fc_nop_sent(fc_nop_sent);
#ifdef RETRY_MODE_ENABLED
	the_nop_framer->cd_rx_next_pkt_to_ack_fc(cd_rx_next_pkt_to_ack_fc);
	the_nop_framer->csr_retry(csr_retry);
#endif	
	the_nop_framer->resetx(resetx);
	the_nop_framer->clock(clk);
	the_nop_framer->nop_next_to_send(nop_next_to_send);
	
	//Linking of the multiplexer module
	
	the_multiplexer = new multiplexer_l3("the_multiplexer");
	the_multiplexer->fc_ctr_mux(fc_ctr_mux);
	the_multiplexer->resetx(resetx);
	the_multiplexer->clk(clk);
	the_multiplexer->fc_dword_lk(fc_dword_lk);
	the_multiplexer->ht_nop_pkt(ht_nop_pkt);  						//0
	the_multiplexer->fwd_packet(ro_packet_fwd);			//1-2
	the_multiplexer->db_data_fwd(db_data_fwd);  						//3
	the_multiplexer->eh_cmd_data_fc(eh_cmd_data_fc);  			//4
	the_multiplexer->csr_dword_fc(csr_dword_fc);  			//5
	the_multiplexer->user_packet(fifo_user_packet);			 //6-7
	the_multiplexer->ui_data_fc(ui_data_fc);
#ifdef RETRY_MODE_ENABLED
	the_multiplexer->history_packet(history_packet);
	the_multiplexer->crc_output(crc_output);
	the_multiplexer->nop_crc_output(nop_crc_output);
	the_multiplexer->select_crc_output(select_crc_output);
	the_multiplexer->select_nop_crc_output(select_nop_crc_output);
	the_multiplexer->registered_output(mux_registered_output);
#endif
	
	/** 
	Linking of the rx_farend_cnd module
	This module is used to trace the amount of buffer that are free
	in the command and data buffer of a far end HT interface.
	
	**/	
	
	the_rx_farend_cnt = new rx_farend_cnt_l3("the_rx_farend_cnt");

	the_rx_farend_cnt->cd_nopinfo_fc(cd_nopinfo_fc);
	the_rx_farend_cnt->cd_nop_received_fc(cd_nop_received_fc);
	the_rx_farend_cnt->resetx(resetx);
	the_rx_farend_cnt->clock(clk);
	the_rx_farend_cnt->fwd_next_node_buffer_status_ro(fwd_next_node_buffer_status_ro);
	the_rx_farend_cnt->current_sent_type(current_sent_type);
#ifdef RETRY_MODE_ENABLED
	the_rx_farend_cnt->clear_farend_count(clear_farend_count);
#endif	
	
	/** 
	Linking of the user_fifo module
	
	**/
	the_user_fifo = new user_fifo_l3("the_user_fifo");
	
	
	the_user_fifo->fc_user_fifo_ge2_ui(fc_user_fifo_ge2_ui);
	the_user_fifo->ui_available_fc(ui_available_fc);
	the_user_fifo->ui_packet_fc(ui_packet_fc);
	the_user_fifo->clock(clk);
	the_user_fifo->resetx(resetx);
	the_user_fifo->fifo_user_packet(fifo_user_packet);
 	the_user_fifo->fifo_user_packet_vc(fifo_user_packet_vc);
	the_user_fifo->fifo_user_packet_dword(fifo_user_packet_dword);
	the_user_fifo->fifo_user_packet_data_asociated(fifo_user_packet_data_asociated);
#ifdef RETRY_MODE_ENABLED
	the_user_fifo->fifo_user_packet_command(fifo_user_packet_command);
#endif
	the_user_fifo->fifo_user_packet_data_count_m1(fifo_user_packet_data_count_m1);
	the_user_fifo->fifo_user_packet_isChain(fifo_user_packet_isChain);

	the_user_fifo->fwd_next_node_buffer_status_ro(fwd_next_node_buffer_status_ro);
	the_user_fifo->fifo_user_available(fifo_user_available);
	the_user_fifo->consume_user_fifo(consume_user_fifo);
	the_user_fifo->hold_user_fifo(hold_user_fifo);

	/**
	Linking of the fairness algorithm module
	*/

	the_fairness = new fairness_l3("the_fairness_l3");
	the_fairness->clk(clk);
	the_fairness->resetx(resetx);
	the_fairness->ro_available_fwd(ro_available_fwd);
	the_fairness->ro_packet_fwd(ro_packet_fwd);
	the_fairness->fwd_ack_ro(fwd_ack_ro);
	the_fairness->local_priority(local_priority);
	the_fairness->local_packet_issued(local_packet_issued);
	

#ifdef RETRY_MODE_ENABLED
	/** Link to the CRC unit */
	the_fc_packet_crc = new fc_packet_crc_l3("the_fc_packet_crc");

	the_fc_packet_crc->clk(clk);
	the_fc_packet_crc->resetx(resetx);
	
	the_fc_packet_crc->data_in(mux_registered_output);
	the_fc_packet_crc->fc_hctl_lk(fc_hctl_lk);
	the_fc_packet_crc->fc_lctl_lk(fc_lctl_lk);
	
	the_fc_packet_crc->calculate_crc(calculate_crc);
	the_fc_packet_crc->clear_crc(clear_crc);
	the_fc_packet_crc->calculate_nop_crc(calculate_nop_crc);
	the_fc_packet_crc->clear_nop_crc(clear_nop_crc);
	the_fc_packet_crc->crc_output(crc_output);
	the_fc_packet_crc->nop_crc_output(nop_crc_output);
	the_fc_packet_crc->csr_force_single_stomp_fc(csr_force_single_stomp_fc);
	the_fc_packet_crc->csr_force_single_error_fc(csr_force_single_error_fc);


	/** Link to the history buffer */
	the_history_buffer = new history_buffer_l3("the_history_buffer");

	the_history_buffer->ack_value(cd_nop_ack_value_fc);
	the_history_buffer->add_to_history(add_to_history);
	the_history_buffer->begin_history_playback(begin_history_playback);
	the_history_buffer->stop_history_playback(stop_history_playback);
	the_history_buffer->clk(clk);
	the_history_buffer->consume_history(consume_history);
	the_history_buffer->mux_registered_output(mux_registered_output);
	the_history_buffer->history_packet(history_packet);
	the_history_buffer->history_playback_done(history_playback_done);
	the_history_buffer->new_history_entry(new_history_entry);
	the_history_buffer->new_history_entry_size_m1(new_history_entry_size_m1);
	the_history_buffer->nop_received(cd_nop_received_fc);
	the_history_buffer->resetx(resetx);
	the_history_buffer->room_available_in_history(room_available_in_history);
	the_history_buffer->history_memory_write(history_memory_write);
	the_history_buffer->history_memory_write_address(history_memory_write_address);
	the_history_buffer->history_memory_write_data(history_memory_write_data);
	the_history_buffer->history_memory_read_address(history_memory_read_address);
	the_history_buffer->history_memory_output(history_memory_output);
	the_history_buffer->history_playback_ready(history_playback_ready);
#endif	
}

#ifdef RETRY_MODE_ENABLED
void flow_control_l2::send_clear_single_error_and_stomp(){
	fc_clear_single_error_csr = clear_crc.read() || clear_nop_crc.read();
	fc_clear_single_stomp_csr =	clear_crc.read();
}
#endif	


#ifdef SYSTEMC_SIM
flow_control_l2::~flow_control_l2(){
		delete the_flow_control; 
		delete the_nop_framer;
		delete the_multiplexer;
		delete the_rx_farend_cnt;
		delete the_user_fifo; 
#ifdef RETRY_MODE_ENABLED
		delete the_fc_packet_crc;
		delete the_history_buffer;
#endif	
	}
#endif
