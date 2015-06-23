//flow_control_l3.cpp

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

#include "flow_control_l3.h"

flow_control_l3::flow_control_l3(sc_module_name name) : sc_module(name)
{
	/** Processes of the design.  The sensitivity list is in function
		of what theses processes uses.*/

	SC_METHOD(fc_fsm_state);
		sensitive_pos << clock;
		sensitive_neg << resetx;
		
	SC_METHOD(fc_fsm);
		sensitive  << curr_state << fifo_user_available 
			<< ro_available_fwd << ro_nop_req_fc << db_nop_req_fc  
			<<  has_nop_buffers_to_send
			<< fc_data_vc_ui 
			<< resetx 

			<< fifo_user_packet << fifo_user_available
			<< eh_cmd_data_fc << eh_available_fc
			<< csr_dword_fc << csr_available_fc
			<< ro_packet_fwd << ro_available_fwd

			<< data_cnt << has_data << ldtstopx  << chain_current_state
			<< fwd_next_node_buffer_status_ro
			<< nop_next_to_send << lk_consume_fc 
			<< found_next_state 
			<< found_load_fwd_pkt 
			<< found_load_eh_pkt
			<< found_load_csr_pkt 
			<< found_load_user_fifo_pkt 
			<< found_next_chain_current_state
			<< found_fc_ctr_mux
			<< found_fc_nop_sent
			<< found_generate_disconnect_nop
			<< found_next_data_cnt
			<< found_next_has_data
			<< found_current_sent_type
			<< buffered_fwd_vctype_db
			<< found_fwd_vctype_db
			<< buffered_fwd_address_db
			<< found_fwd_address_db
			<< buffered_fc_data_vc_ui
			<< found_fc_data_vc_ui
			<< found_local_packet_issued
			<< found_next_fairness_vc_reserved[0] << found_next_fairness_vc_reserved[1] << found_next_fairness_vc_reserved[2]

			<< registered_lk_initiate_retry_disconnect
			<< found_hold_user_fifo_pkt
			<< fc_lctl_lk << fc_hctl_lk

#ifdef RETRY_MODE_ENABLED
			<< registered_lk_rx_connected
			<< received_ack
			<< found_new_history_entry_size_m1
			<< found_new_history_entry
			<< new_history_entry_size_m1
			<< retry_disconnect_initiated<< cd_initiate_retry_disconnect
			<< history_playback_done << history_packet 
			<< csr_retry 

			<< foundh_fc_ctr_mux << foundh_fc_nop_sent << foundh_next_state
			<< foundh_next_fc_lctl_lk << foundh_next_fc_hctl_lk << foundh_next_calculate_nop_crc
			<< foundh_next_calculate_crc << foundh_next_data_cnt << foundh_next_has_data
			<< foundh_current_sent_type << foundh_consume_history
#endif
			;

	SC_METHOD(find_next_state);
	sensitive << ro_nop_req_fc << db_nop_req_fc << nop_next_to_send
		<< ldtstopx
		<< csr_dword_fc 
		<< csr_available_fc
		<< fwd_next_node_buffer_status_ro << eh_cmd_data_fc 
		<< fifo_user_packet << eh_available_fc << fifo_user_available
		<< ro_packet_fwd << ro_available_fwd 
		<< local_priority
		<< fairness_vc_reserved[0] << fairness_vc_reserved[1] << fairness_vc_reserved[2]
		<< fc_data_vc_ui
		<< buffered_fwd_vctype_db << buffered_fwd_address_db
#ifdef RETRY_MODE_ENABLED
		<< csr_retry
		<< room_available_in_history 
		<< cd_initiate_retry_disconnect
		<< retry_disconnect_initiated 
#endif
		;
#ifdef RETRY_MODE_ENABLED
	SC_METHOD(find_next_retry_state);
	sensitive << ro_nop_req_fc << db_nop_req_fc << nop_next_to_send
		<< ldtstopx << fwd_next_node_buffer_status_ro << history_packet
		<< history_playback_done << foundh_generate_disconnect_nop;

#endif
}

void flow_control_l3::fc_fsm_state( void )
{  
	
	//Upon the reset signal, go to the RESET_STATE and clear any chain state
	if (resetx == false) {
		curr_state.write(NOP_SENT);
		chain_current_state = NO_CHAIN_STATE;
		
		fc_lctl_lk = true;
		fc_hctl_lk = true;

#ifdef RETRY_MODE_ENABLED
		received_ack = false;
		fc_disconnect_lk = false;
		registered_lk_rx_connected = false;
		registered_lk_initiate_retry_disconnect = false;
		retry_disconnect_initiated = false;

		select_crc_output = false;
		select_nop_crc_output = false;

		//We start with a nop, so calculate CRC
		calculate_nop_crc = true;
		calculate_crc = false;
#endif

		buffered_fc_data_vc_ui = VC_NONE;
		buffered_fwd_address_db = 0;
		buffered_fwd_vctype_db = VC_NONE;

		data_cnt = 0;
		has_data = false;
		
		for(int n = 0; n < 3; n++)
			fairness_vc_reserved[n] = false;

	}
	//Otherwise, store the next value
	else {
		curr_state.write(next_state.read());

#ifdef RETRY_MODE_ENABLED
		fc_disconnect_lk = next_fc_disconnect_lk;
		registered_lk_rx_connected = lk_rx_connected;
		registered_lk_initiate_retry_disconnect = lk_initiate_retry_disconnect;
#endif
		chain_current_state = next_chain_current_state;
		
		fc_lctl_lk = next_fc_lctl_lk;
		fc_hctl_lk = next_fc_hctl_lk;
		
#ifdef RETRY_MODE_ENABLED
		/**It might not be possible to start a retry a retry sequence
		immediately after we receive a signal to initiate it, so store
		that a retry sequence was initiated and clear it later when we
		take it into account*/
		if(clear_retry_disconnect_initiated){
			retry_disconnect_initiated = false;
		}
		else if(cd_initiate_retry_disconnect.read() ||
				registered_lk_initiate_retry_disconnect.read())
			retry_disconnect_initiated = true;
		else
			retry_disconnect_initiated = retry_disconnect_initiated.read();
			
		/**
			When we are in retry mode, we want to wait until we have received
			at least a single ack that represents the last good packet they
			received, so that we know when to replay the history.  received_ack
			keeps track if we have received that first ack
		*/
		if(lk_rx_connected == false)
			received_ack = false;
		else if(nop_received == true)
			received_ack = true;
		else
			received_ack = received_ack.read();

		select_crc_output = next_select_crc_output;
		select_nop_crc_output = next_select_nop_crc_output;

		calculate_nop_crc = next_calculate_nop_crc;
		calculate_crc = next_calculate_crc;

#endif

		buffered_fc_data_vc_ui = fc_data_vc_ui.read();
		buffered_fwd_address_db = fwd_address_db.read();
		buffered_fwd_vctype_db = fwd_vctype_db;

		data_cnt = next_data_cnt;
		has_data = next_has_data;

		for(int n = 0; n < 3; n++)
			fairness_vc_reserved[n] = next_fairness_vc_reserved[n];
	}
}


void flow_control_l3::fc_fsm( void ){
	// test to know if a nop request is present
	bool nop_req;
	if (ro_nop_req_fc ==  true || db_nop_req_fc ==  true || nop_next_to_send == true )
		nop_req = true;
	else
		nop_req  = false;
	
	//far_end buffer status
	sc_bv<6> buffer_status_tmp = fwd_next_node_buffer_status_ro;
	
	//variable who contain the status for response. useful to know quickly if a CSR
	//or EH can be send
	sc_bv<2> far_end_resp_stat = (buffer_status_tmp[0],buffer_status_tmp[1]);
	
	//control  of the multiplexer
	fc_ctr_mux = FC_MUX_FEEDBACK;
	//variable indicating that a nop is currently send
	fc_nop_sent = false;
	// variable indicating the amount of data remaining for a sequence
	next_data_cnt = data_cnt;
	// Indicate a data packet consonmmation to the data buffer
	fwd_read_db = false;	
	//Erase a data packet from the buffers
	fwd_erase_db = false;
	// indicate a data packet consonmmation to the user buffer
	fc_consume_data_ui = false;

	//acknowledges
	fwd_ack_ro = false;
	consume_user_fifo = false;
	fc_ack_eh = false;
	fc_ack_csr = false;

	//Hold the packet so it doesn't change after sending the first dword
	hold_user_fifo = false;

#ifdef RETRY_MODE_ENABLED
	//History
	begin_history_playback = false;
	stop_history_playback = false;
	consume_history = false;
	add_to_history = false;
	new_history_entry = false;
	new_history_entry_size_m1 = 0;

	//Per-packet crc
	clear_crc = false;
	clear_nop_crc = false;

	// ctl signal, in reset it have no meaning
	next_fc_disconnect_lk = false;

	//Some other default outputs
	clear_farend_count = false;

	next_select_crc_output = false;
	next_select_nop_crc_output = false;
	clear_retry_disconnect_initiated = false;
#endif

	//When this is true, the nop framer will produce a disconnect nop
	generate_disconnect_nop = false;

	
	//Default, not sending anything
	current_sent_type = "000000";


	next_chain_current_state = chain_current_state;

	//By default, keep sending the same VC on the output
	fc_data_vc_ui = buffered_fc_data_vc_ui.read();
	fwd_vctype_db = buffered_fwd_vctype_db.read();
	fwd_address_db = buffered_fwd_address_db.read();

	//For the  fairness algorithm
	local_packet_issued = false;
	for(int n = 0; n < 3; n++)
		next_fairness_vc_reserved[n] = fairness_vc_reserved[n];

	next_state = curr_state.read();

	next_fc_lctl_lk = true;
	next_fc_hctl_lk = true;
	next_has_data = has_data.read();

	//By default, don't calculate any CRC
#ifdef RETRY_MODE_ENABLED
	next_calculate_crc = false;
	next_calculate_nop_crc = false;
#endif

	/**
		Select what to do and output in functino of our present state
	*/
	switch (curr_state.read()) {
	//State that sends nop
		
	case FWD_CMD32_SENT:
		{	
#ifdef RETRY_MODE_ENABLED
			add_to_history = lk_consume_fc.read();
#endif
			//If output not consumed, don't modify the output
			if(!lk_consume_fc.read()){
				next_state = FWD_CMD32_SENT;
				next_fc_lctl_lk = true;
				next_fc_hctl_lk = true;
			}
			//If there is data with this packet
			else if (has_data.read()){
				//If a request for nop, interrupt sending the data to send nop
				if (nop_req == true){
					go_NOP_SENT_IN_FWD();
				}
				//Otherwise go send the data
				else{
					go_FWD_DATA_SENT();
				}
			}
#ifdef RETRY_MODE_ENABLED
			//If no data and in retry mode, send the per-packet CRC
			else if(csr_retry.read()){
				go_SEND_CMD_CRC();
			}
#endif
			//No data and no retry mode means packet sent : find next packet to send
			else{
				set_next_state();
			}				 
		}
		break;

	case FWD_CMD64_FIRST_SENT:
		{
#ifdef RETRY_MODE_ENABLED
			add_to_history = lk_consume_fc.read();
#endif

			//If output not consumed, don't modify the output
			if(!lk_consume_fc.read()){
				next_state = FWD_CMD64_FIRST_SENT;
				next_fc_lctl_lk = true;
				next_fc_hctl_lk = true;
			}
			//Go send the second dword
			else{
				next_state = FWD_CMD64_SECOND_SENT;
				fc_ctr_mux = FC_MUX_FWD_MSB; //32 bits lsb FWD_CMD
				next_fc_lctl_lk = true;
				next_fc_hctl_lk = true;
				fwd_ack_ro = true;
#ifdef RETRY_MODE_ENABLED
				next_calculate_crc = true;
				add_to_history = true;
#endif
			}
		}
		break;
	case FWD_CMD64_SECOND_SENT:

#ifdef RETRY_MODE_ENABLED
		add_to_history = lk_consume_fc.read();
#endif

		//If output not consumed, don't modify the output
		if(!lk_consume_fc.read()){
			next_state = FWD_CMD64_SECOND_SENT;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = true;
		}
		//If there is data with this packet
		else if (has_data.read()){
			//If a request for nop, interrupt sending the data to send nop
			if (nop_req == true)
				go_NOP_SENT_IN_FWD();
			//Otherwise go send the data
			else{
				go_FWD_DATA_SENT();
			}
		}
#ifdef RETRY_MODE_ENABLED
		//If no data and in retry mode, send the per-packet CRC
		else if(csr_retry.read()){
			go_SEND_CMD_CRC();
		}
#endif
		//No data and no retry mode means packet sent : find next packet to send
		else {
			set_next_state();
		}
		break;
		
	case FWD_DATA_SENT:
		//cout << "entering FWD_DATA_SENT" <<endl;	
		
#ifdef RETRY_MODE_ENABLED
		add_to_history = lk_consume_fc.read();
#endif

		//If output not consumed, don't modify the output
		if(!lk_consume_fc.read()){
			next_state = FWD_DATA_SENT;
			next_fc_lctl_lk = false;
			next_fc_hctl_lk = false;
		}
		//If there is data left to send
		else if (has_data.read()){
			//If a request for nop, interrupt sending the data to send nop
			if (nop_req == true)
				go_NOP_SENT_IN_FWD();
			//Otherwise keep sending data
			else
				go_FWD_DATA_SENT();
		}
#ifdef RETRY_MODE_ENABLED
		else if(csr_retry.read()){
			go_SEND_DATA_CRC();
		}
#endif
		//No data and no retry mode means packet sent : find next packet to send
		else {
			set_next_state();
		}
		break;
		
	case NOP_SENT_IN_FWD:
		
		//cout << "entering fc_nop_sent_IN_FWD" <<endl;	
		

		if(lk_consume_fc.read()){
#ifdef RETRY_MODE_ENABLED
			//If in retry mode, the nop CRC must be sent
			if(csr_retry.read()){
				go_NOP_CRC_SENT_IN_FWD();
			}
			else
#endif
			{
				//If a nop is requested again, send another
				if (nop_req == true)
					go_NOP_SENT_IN_FWD();
				//Otherwise continue to send data
				else
					go_FWD_DATA_SENT();
			}
		}
		//If output not consumed, don't modify the output
		else{
			next_state = NOP_SENT_IN_FWD;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = true;
		}

		break;
		

	case USER_CMD32_SENT:
		{	
#ifdef RETRY_MODE_ENABLED
			add_to_history = lk_consume_fc.read();
#endif

			//If output not consumed, don't modify the output
			if(!lk_consume_fc.read()){
				next_state = USER_CMD32_SENT;
				next_fc_lctl_lk = true;
				next_fc_hctl_lk = true;
			}
			//If there is data with this packet
			else if (has_data.read()){
				//If a request for nop, interrupt sending the data to send nop
				if (nop_req == true){
					go_NOP_SENT_IN_USER();
				}
				//Otherwise go send the data
				else{
					go_USER_DATA_SENT();
				}
			}
#ifdef RETRY_MODE_ENABLED
			else if(csr_retry.read()){
				go_SEND_CMD_CRC();
			}
#endif
			//No data and no retry mode means packet sent : find next packet to send
			else{
				set_next_state();
			}				 
		}
		break;

	case USER_CMD64_FIRST_SENT:
		{
#ifdef RETRY_MODE_ENABLED
			add_to_history = lk_consume_fc.read();
#endif

			//If output not consumed, don't modify the output
			if(!lk_consume_fc.read()){
				next_state = USER_CMD64_FIRST_SENT;
				next_fc_lctl_lk = true;
				next_fc_hctl_lk = true;
			}
			else{
				next_state = USER_CMD64_SECOND_SENT;
				fc_ctr_mux = FC_MUX_UI_MSB; //32 bits lsb FWD_CMD
				next_fc_lctl_lk = true;
				next_fc_hctl_lk = true;
				consume_user_fifo = true;
#ifdef RETRY_MODE_ENABLED
				next_calculate_crc = true;
				add_to_history = true;
#endif
			}
		}
		break;

	case USER_CMD64_SECOND_SENT:

#ifdef RETRY_MODE_ENABLED
		add_to_history = lk_consume_fc.read();
#endif

		//If output not consumed, don't modify the output
		if(!lk_consume_fc.read()){
			next_state = USER_CMD64_SECOND_SENT;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = true;
		}
		//If there is data with this packet
		else if (has_data.read()){
			//If a request for nop, interrupt sending the data to send nop
			if (nop_req == true)
				go_NOP_SENT_IN_USER();
			//Otherwise go send the data
			else{
				go_USER_DATA_SENT();
			}
		}
#ifdef RETRY_MODE_ENABLED
		else if(csr_retry.read()){
			go_SEND_CMD_CRC();
		}
#endif
		//No data and no retry mode means packet sent : find next packet to send
		else {
			set_next_state();
		}
		break;

	case USER_DATA_SENT:
	
#ifdef RETRY_MODE_ENABLED
		add_to_history = lk_consume_fc.read();
#endif

		//If output not consumed, don't modify the output
		if(!lk_consume_fc.read()){
			next_state = USER_DATA_SENT;
			next_fc_lctl_lk = false;
			next_fc_hctl_lk = false;
		}
		//If there is data left to send
		else if (has_data.read()){
			//If a request for nop, interrupt sending the data to send nop
			if (nop_req == true)
				go_NOP_SENT_IN_USER();
			//Otherwise keep sending data
			else
				go_USER_DATA_SENT();
		}
#ifdef RETRY_MODE_ENABLED
		else if(csr_retry.read()){
			go_SEND_DATA_CRC();
		}
#endif
		//No data and no retry mode means packet sent : find next packet to send
		else {
			set_next_state();
		}

		break;
		
	case NOP_SENT_IN_USER:
		
		if(lk_consume_fc.read()){
#ifdef RETRY_MODE_ENABLED
			//If in retry mode, nop CRC must be sent
			if(csr_retry.read()){
				fc_nop_sent = false;
				next_state = NOP_CRC_SENT_IN_USER;
				next_fc_lctl_lk = true;
				next_fc_hctl_lk = false;
				next_select_nop_crc_output = true;
			}
			else 
#endif
			{
				//If nop is requestion, send another nop
				if (nop_req == true)
					go_NOP_SENT_IN_USER();
				//Otherwise, keep sending data
				else
					go_USER_DATA_SENT();
			}
		}
		//If output not consumed, don't modify the output
		else{
			next_state = NOP_SENT_IN_USER;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = true;
		}

		break;
		
		
	case EH_CMD_SENT:
		{
#ifdef RETRY_MODE_ENABLED
			add_to_history = lk_consume_fc.read();
#endif

			//If output not consumed, don't modify the output
			if(!lk_consume_fc.read()){
				next_state = EH_CMD_SENT;
				next_fc_lctl_lk = true;
				next_fc_hctl_lk = true;
			}
			//If there is data with this packet
			else if (has_data.read()){
				//If a request for nop, interrupt sending the data to send nop
				if (nop_req == true){
					go_NOP_SENT_IN_EH();
				}
				//Otherwise go send the data
				else{
					go_ERROR_DATA_SENT();
				}
			}
#ifdef RETRY_MODE_ENABLED
			else if(csr_retry.read()){
				go_SEND_CMD_CRC();
			}
#endif
			//No data and no retry mode means packet sent : find next packet to send
			else{
				set_next_state();
			}				 
		}
		break;
		
	case CSR_CMD_SENT:
		{

		//cout << "entering CSR_CMD_SENT" <<endl;
#ifdef RETRY_MODE_ENABLED
			add_to_history = lk_consume_fc.read();
#endif

			//If output not consumed, don't modify the output
			if(!lk_consume_fc.read()){
				next_state = CSR_CMD_SENT;
				next_fc_lctl_lk = true;
				next_fc_hctl_lk = true;
			}
			//If there is data with this packet
			else if (has_data.read()){
				//If a request for nop, interrupt sending the data to send nop
				if (nop_req == true){
					go_NOP_SENT_IN_CSR();
				}
				//Otherwise go send the data
				else{
					go_CSR_DATA_SENT();
				}
			}
#ifdef RETRY_MODE_ENABLED
			else if(csr_retry.read()){
				go_SEND_CMD_CRC();
			}
#endif
			//No data and no retry mode means packet sent : find next packet to send
			else{
				set_next_state();
			}				 
		}
		break;
		
		

	case ERROR_DATA_SENT:
	
#ifdef RETRY_MODE_ENABLED
		add_to_history = lk_consume_fc.read();
#endif

		//If output not consumed, don't modify the output
		if(!lk_consume_fc.read()){
			next_state = ERROR_DATA_SENT;
			next_fc_lctl_lk = false;
			next_fc_hctl_lk = false;
		}
		//If there is data left to send
		else if (has_data.read()){
			//If a request for nop, interrupt sending the data to send nop
			if (nop_req == true)
				go_NOP_SENT_IN_EH();
			//Otherwise keep sending data
			else
				go_ERROR_DATA_SENT();
		}
#ifdef RETRY_MODE_ENABLED
		else if(csr_retry.read()){
			go_SEND_DATA_CRC();
		}
#endif
		//No data and no retry mode means packet sent : find next packet to send
		else {
			set_next_state();
		}

		break;
		
	case NOP_SENT_IN_EH:
		
		if(lk_consume_fc.read()){
#ifdef RETRY_MODE_ENABLED
			//If in retry mode, nop CRC must be sent
			if(csr_retry.read()){
				next_select_nop_crc_output = true;
				fc_nop_sent = false;
				next_state = NOP_CRC_SENT_IN_EH;
				next_fc_lctl_lk = true;
				next_fc_hctl_lk = false;
			}
			else
#endif
			{
				//If nop is requestion, send another nop
				if (nop_req == true)
					go_NOP_SENT_IN_EH();
				//Otherwise, keep sending data
				else
					go_ERROR_DATA_SENT();
			}
		}
		//If output not consumed, don't modify the output
		else{
			next_state = NOP_SENT_IN_EH;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = true;
		}
		break;

	case CSR_DATA_SENT:
		
#ifdef RETRY_MODE_ENABLED
		add_to_history = lk_consume_fc.read();
#endif
		//If output not consumed, don't modify the output
		if(!lk_consume_fc.read()){
			next_state = CSR_DATA_SENT;
			next_fc_lctl_lk = false;
			next_fc_hctl_lk = false;
		}
		//If there is data left to send
		else if (has_data.read()){
			//If a request for nop, interrupt sending the data to send nop
			if (nop_req == true)
				go_NOP_SENT_IN_CSR();
			//Otherwise keep sending data
			else
				go_CSR_DATA_SENT();
		}
#ifdef RETRY_MODE_ENABLED
		else if(csr_retry.read()){
			go_SEND_DATA_CRC();
		}
#endif
		//No data and no retry mode means packet sent : find next packet to send
		else {
			set_next_state();
		}

		break;	        	
		
	case NOP_SENT_IN_CSR:
		
		if(lk_consume_fc.read()){
#ifdef RETRY_MODE_ENABLED
			//If in retry mode, nop CRC must be sent
			if(csr_retry.read()){
				next_select_nop_crc_output = true;
				fc_nop_sent = false;
				next_state = NOP_CRC_SENT_IN_CSR;
				next_fc_lctl_lk = true;
				next_fc_hctl_lk = false;
			}
			else
#endif
			{
				//If nop is requestion, send another nop
				if (nop_req == true)
					go_NOP_SENT_IN_CSR();
				//Otherwise, keep sending data
				else
					go_CSR_DATA_SENT();
			}
		}
		//If output not consumed, don't modify the output
		else{
			next_state = NOP_SENT_IN_CSR;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = true;
		}
		break;

	//This outputs nop disconnects.  When ldtstopx is done, then we go back
	//to normal operation.  The link will disconnect on it's own
	case LDTSTOP_DISCONNECT:
		//Disconnect is not activated because the link will start
		//it's deconnect sequence when it reads ldtstopx.  It will
		//take a long delay (minimum 64 dword) before it's deconnected
		//because of the periodic CRC that must be sent
		//
		//fc_disconnect_lk is reserved for RETRY disconnect
		//next_fc_disconnect_lk = true;

#ifdef RETRY_MODE_ENABLED
		//Clear CRC so it's clean when we start over
		clear_crc = true;
		clear_nop_crc = true;
#endif
		//While ldtstopx is maintained, stay in ldstopx state
		if(ldtstopx.read() == false){
			go_LDTSTOP_DISCONNECT();
		}
		//Once done, go back to normal operation by starting with a nop
		else{
			go_NOP_SENT();
		}
		break;

////////////////////////////////////////////
//				MAIN CRC states
///////////////////////////////////////////

#ifdef RETRY_MODE_ENABLED

	case NOP_CRC_SENT_IN_CSR:

		clear_nop_crc = lk_consume_fc.read();

		if(lk_consume_fc.read()){
			go_CSR_DATA_SENT();
		}
		else{
			next_state = NOP_CRC_SENT_IN_CSR;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = false;
			next_select_nop_crc_output = true;
		}
		break;

	case NOP_CRC_SENT_IN_FWD:

		clear_nop_crc = lk_consume_fc.read();

		if(lk_consume_fc.read()){
			go_FWD_DATA_SENT();
		}
		else{
			next_state = NOP_CRC_SENT_IN_FWD;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = false;
			next_select_nop_crc_output = true;
		}

		break;

	case NOP_CRC_SENT_IN_USER:

		clear_nop_crc = lk_consume_fc.read();

		if(lk_consume_fc.read()){
			go_USER_DATA_SENT();
		}
		else{
			next_state = NOP_CRC_SENT_IN_USER;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = false;
			next_select_nop_crc_output = true;
		}
		break;

	case NOP_CRC_SENT_IN_EH:

		clear_nop_crc = lk_consume_fc.read();

		if(lk_consume_fc.read()){
			go_ERROR_DATA_SENT();
		}
		else{
			next_state = NOP_CRC_SENT_IN_EH;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = false;
			next_select_nop_crc_output = true;
		}
		break;
		
	case SEND_DATA_CRC:
		
		//cout << "entering SEND_DATA_CRC" <<endl;	

		if(!lk_consume_fc.read()){
			next_fc_lctl_lk = false;
			next_fc_hctl_lk = true;
			next_state = SEND_DATA_CRC;
			next_select_crc_output = true;
		}
		else{
			clear_crc = true;		
			set_next_state();
		}
		break;

	case SEND_CMD_CRC:
		
		if(!lk_consume_fc.read()){
			next_fc_lctl_lk = true;
			next_fc_hctl_lk =  false;
			next_state = SEND_CMD_CRC;
			next_select_crc_output = true;
		}
		else{
			clear_crc = true;		
			set_next_state();
		}
		break;

	case SEND_NOP_CRC:
		
		if(!lk_consume_fc.read()){
			next_fc_lctl_lk = true;
			next_fc_hctl_lk =  false;
			next_state = SEND_NOP_CRC;
			next_select_nop_crc_output = true;
		}
		else{
			clear_nop_crc = true;		
			set_next_state();
		}
		break;

	case RETRY_SEND_DISCONNECT:

		//If was playing back history, stop it.  If not, this simply does nothing
		stop_history_playback = true;

		if(!lk_consume_fc.read()){
			next_fc_lctl_lk = true;
			next_fc_hctl_lk =  true;
			next_state = RETRY_SEND_DISCONNECT;
			next_fc_disconnect_lk = false;
		}
		else{
			next_fc_lctl_lk = true;
			next_fc_hctl_lk =  false;
			next_state = RETRY_SEND_DISCONNECT_CRC;
			next_select_nop_crc_output = true;
			//When the link detects fc_disconnect_lk, it finishes sending the dword currently
			//on it's output and then starts sending warm reset signaling.  fc_disconnect_lk
			//is activated on the next cycle, when the CRC is outputed to the links.  The CRC
			//will be the last dword sent
			next_fc_disconnect_lk = true;
		}
		break;

	case RETRY_SEND_DISCONNECT_CRC:
	
		if(!lk_consume_fc.read()){
			next_state = RETRY_SEND_DISCONNECT_CRC;
			next_select_nop_crc_output = true;
		}
		else{
			next_state = RETRY_WAIT_FOR_RX_DISCONNECT;
			clear_nop_crc = true;		
		}
		next_fc_lctl_lk = true;
		next_fc_hctl_lk = false;
	
		next_fc_disconnect_lk = true;

	break;

	//The TX side of the link is disconnected, but if we initiated the retry
	//attempt, the RX side might still be receiving stuff.  We wait for the RX
	//side to be disconnected
	case RETRY_WAIT_FOR_RX_DISCONNECT:

		//cout << "Entered RETRY_WAIT_FOR_RX_DISCONNECT" << endl;

		next_fc_lctl_lk = true;
		next_fc_hctl_lk = true;
		clear_crc = true;
		clear_nop_crc = true;
		clear_farend_count = true;
		clear_retry_disconnect_initiated = true;

		if(registered_lk_rx_connected.read()){
			next_state = RETRY_WAIT_FOR_RX_DISCONNECT;
			next_fc_disconnect_lk = true;
		}
		else{
			next_state = RETRY_WAIT_FOR_ACK_AND_BUFFER_COUNT_SENT;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = true;
			fc_ctr_mux = FC_MUX_NOP;
			fc_nop_sent = true;
			next_calculate_nop_crc = true;
			next_fc_disconnect_lk = false;
		}
		break;

	//To know where to start the resend, we wait for a nop with the last
	//acked packet value.  We also have to finish transmitting all our
	//buffer counts
	case RETRY_WAIT_FOR_ACK_AND_BUFFER_COUNT_SENT:
		begin_history_playback = received_ack.read();

		if(!lk_consume_fc.read()){
			next_fc_lctl_lk = true;
			next_fc_hctl_lk =  true;
			next_state = RETRY_WAIT_FOR_ACK_AND_BUFFER_COUNT_SENT;
		}
		else{
			next_state = RETRY_WAIT_FOR_ACK_AND_BUFFER_COUNT_SENT_CRC;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk =  false;
			next_select_nop_crc_output = true;
		}

		break;

	case RETRY_WAIT_FOR_ACK_AND_BUFFER_COUNT_SENT_CRC:
		begin_history_playback = received_ack.read();

		if(!lk_consume_fc.read()){
			next_fc_lctl_lk = true;
			next_fc_hctl_lk =  false;
			next_state = RETRY_WAIT_FOR_ACK_AND_BUFFER_COUNT_SENT_CRC;
			next_select_nop_crc_output = true;
			next_state = RETRY_WAIT_FOR_ACK_AND_BUFFER_COUNT_SENT_CRC;

		}
		else{
			fc_ctr_mux = FC_MUX_NOP;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = true;
			fc_nop_sent = true;
			clear_nop_crc = true;
			next_calculate_nop_crc = true;

			/*Got ack and finished sending buffer count*/
			if(ldtstopx.read() == false || retry_disconnect_initiated.read()){
				go_RETRY_SEND_DISCONNECT();
			}
			//If this case happens, it means there is no history to play back
			if(history_playback_done.read() && history_playback_ready.read())
				next_state = NOP_SENT;
			//All buffers have been confirmed with nops and playback is ready, start playback
			else if(!has_nop_buffers_to_send.read()&& history_playback_ready.read())
				next_state = RETRY_NOP_SENT;
			else
				next_state = RETRY_WAIT_FOR_ACK_AND_BUFFER_COUNT_SENT;
		}
		break;


	case RETRY_CMD32_SENT:
		{
		//cout << "entering USER_CMD_SENT" <<endl;
		
			if(!lk_consume_fc.read()){
				next_state = FWD_CMD32_SENT;
				next_fc_lctl_lk = true;
				next_fc_hctl_lk = true;
			}
			else if (has_data.read()){
				if (nop_req == true){
					go_RETRY_NOP_SENT_IN_DATA();
				}
				else{
					go_RETRY_DATA_SENT();
				}
			}
			else{
				go_RETRY_SEND_CMD_CRC();
			}
		}
		break;

	case RETRY_CMD64_FIRST_SENT:
		if(!lk_consume_fc.read()){
			next_state = RETRY_CMD64_FIRST_SENT;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = true;
		}
		else{
			next_state = RETRY_CMD64_SECOND_SENT;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = true;
			fc_ctr_mux = FC_MUX_HISTORY; //32 bits lsb FWD_CMD
			consume_history = true;
			next_calculate_crc = true;
		}
		break;
	case RETRY_CMD64_SECOND_SENT:
		if(!lk_consume_fc.read()){
			next_state = RETRY_CMD64_SECOND_SENT;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = true;
		}
		else if (has_data.read()){
			if (nop_req == true){
				go_RETRY_NOP_SENT_IN_DATA();
			}
			else{
				go_RETRY_DATA_SENT();
			}
		}
		else{
			go_RETRY_SEND_CMD_CRC();
		}
		break;

	case RETRY_DATA_SENT:
		if(!lk_consume_fc.read()){
			next_state = RETRY_DATA_SENT;
			next_fc_lctl_lk = false;
			next_fc_hctl_lk = false;
		}
		else if (has_data.read()){
			if (nop_req == true){
				go_RETRY_NOP_SENT_IN_DATA();
			}
			else{
				go_RETRY_DATA_SENT();
			}
		}
		else{
			go_RETRY_SEND_CMD_CRC_DATA();
		}
		break;

	case RETRY_SEND_CMD_CRC:
		clear_crc = lk_consume_fc.read();

		if(!lk_consume_fc.read()){
			next_state = RETRY_SEND_CMD_CRC;
			next_fc_lctl_lk = fc_lctl_lk.read();
			next_fc_hctl_lk = fc_hctl_lk.read();
			next_select_crc_output = true;
		}
		else{
			go_next_retry_state();
		}
		break;

	case RETRY_NOP_SENT_IN_DATA:

		if(lk_consume_fc.read()){
			next_state = RETRY_NOP_CRC_SENT_IN_DATA;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = false;
			next_select_nop_crc_output = true;
		}
		else{
			next_state = RETRY_NOP_SENT_IN_DATA;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = true;
		}
		break;

	case RETRY_NOP_CRC_SENT_IN_DATA:
		clear_nop_crc = lk_consume_fc.read();

		if(lk_consume_fc.read()){
			if (nop_req == true)
				go_RETRY_NOP_SENT_IN_DATA();
			else
				go_RETRY_DATA_SENT();
		}
		else{
			next_state = RETRY_NOP_CRC_SENT_IN_DATA;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = false;
			next_select_nop_crc_output = true;
		}
		break;

	case RETRY_NOP_SENT:
		//cout << "Entered RETRY_NOP_SENT state" << endl;
		if(lk_consume_fc.read()){
			next_state = RETRY_NOP_CRC_SENT;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = false;
			next_select_nop_crc_output = true;
		}
		else{
			next_state = RETRY_NOP_SENT;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = true;
		}
		break;
	case RETRY_NOP_CRC_SENT:
		clear_nop_crc = lk_consume_fc.read();

		if(lk_consume_fc.read()){
			go_next_retry_state();
		}
		else{
			next_state = RETRY_NOP_CRC_SENT;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = false;
			next_select_nop_crc_output = true;
		}

		break;
////////////////////////////////////////////
//			End of MAIN CRC states
///////////////////////////////////////////
#endif

	//case TRANSMITTER_OFF_STATE:
	default:
	//case NOP_SENT:
		//cout << "entering fc_nop_sent" <<endl;	
		if(lk_consume_fc.read()){
#ifdef RETRY_MODE_ENABLED
			if(csr_retry.read()){
				next_state = SEND_NOP_CRC;
				next_select_nop_crc_output = true;
				next_fc_lctl_lk = true;
				next_fc_hctl_lk = false;
			}
			else
#endif
				set_next_state();
		}
		else{
			next_state = NOP_SENT;
			next_fc_lctl_lk = true;
			next_fc_hctl_lk = true;
		}
	} // end of switch
} // end of fonction


void flow_control_l3::set_next_state() {

	/**
		Basically, this only outputs what's been calculated in
		find_next_state.  The reason for not calling directly call_next_state
		is that there are a lot of calls for this in the MSA and ususually,
		SystemC synthesis tools unroll functions, so the resulting .vhdl output
		is VERY big!  This way, only this small part get unrolled multiple times,
		resulting in a much smaller and faster to compile file.  find_next_state
		is treated a single parallel process.  We're talking 2K lines versus 15K.
	*/

	next_state = found_next_state;

#ifdef RETRY_MODE_ENABLED
	new_history_entry_size_m1 = found_new_history_entry_size_m1;
	new_history_entry = found_new_history_entry;
	clear_crc = true;
	clear_nop_crc = true;
	next_calculate_crc = found_next_calculate_crc;
	next_calculate_nop_crc = found_next_calculate_nop_crc;
#endif

	fwd_ack_ro = found_load_fwd_pkt;
	fc_ack_eh = found_load_eh_pkt;
	fc_ack_csr = found_load_csr_pkt;
	consume_user_fifo = found_load_user_fifo_pkt;
	hold_user_fifo = found_hold_user_fifo_pkt;
	generate_disconnect_nop = found_generate_disconnect_nop;
	fc_nop_sent = found_fc_nop_sent;
	fwd_vctype_db = found_fwd_vctype_db;
	fwd_address_db = found_fwd_address_db;
	next_data_cnt = found_next_data_cnt;
	next_has_data = found_next_has_data;
	fc_data_vc_ui = found_fc_data_vc_ui;
	current_sent_type = found_current_sent_type;

	local_packet_issued = found_local_packet_issued;
	for(int n = 0; n < 3; n++)
		next_fairness_vc_reserved[n] = found_next_fairness_vc_reserved[n];

	next_chain_current_state = found_next_chain_current_state;

	fc_ctr_mux = found_fc_ctr_mux;
	next_fc_lctl_lk = true;
	next_fc_hctl_lk = true;
}


void flow_control_l3::find_next_state() {
	//Reserving a packet to fairness to make sure not to starve a VC
	bool reserve_fairness = false;
	//If forward has priority but a packet was previously reserved
	bool fairness_override = false;

	//By default don't change the fairness reserved bit
	for(int n = 0; n < 3; n++)
		found_next_fairness_vc_reserved[n] = fairness_vc_reserved[n];

	//Find if we're requesting a nop
	bool nop_req = ro_nop_req_fc.read() || db_nop_req_fc.read() || nop_next_to_send.read();

	bool disconnect = (ldtstopx.read() == false
#ifdef RETRY_MODE_ENABLED
			|| cd_initiate_retry_disconnect.read() || 
			registered_lk_initiate_retry_disconnect.read() ||
			retry_disconnect_initiated.read()		
#endif
			);
	bool send_nop = nop_req || disconnect;

	/**
		First, we look if a packet can be sent - needs to be one available and the necessary
		buffers in the other link must be free
    */
	sc_bv<6> csr_cmd_bits;
	csr_cmd_bits = csr_dword_fc.read().range(5,0);

	//***********************************************
	//Analyse if the packet from the CSR can be sent
	//***********************************************
	//Some packet analysis
	PacketCommand csr_cmd = getPacketCommand(csr_cmd_bits);
	VirtualChannel csr_vc = VC_RESPONSE;
	bool csr_data_associated = hasDataAssociated(csr_cmd);
	sc_uint<5> csr_size_with_data_m1 =
		getDwordPacketSizeWithDatam1(sc_bv<64>(csr_dword_fc.read()),csr_cmd);
	sc_uint<4> csr_data_count = getDataLengthm1(sc_bv<64>(csr_dword_fc.read()));
	//We know csr can only send responses, check if the next buffer has room for
	//a response packet, and data if there is data associated with that response
	//Also check it there IS a packet!  and if in retry mode, if we have enough room
	//in history
	bool csr_can_be_sent = (csr_available_fc == true) &&
			(fwd_next_node_buffer_status_ro.read()[BUF_STATUS_R_CMD] == true) &&
			(fwd_next_node_buffer_status_ro.read()[BUF_STATUS_R_DATA] == true || !csr_data_associated)
#ifdef RETRY_MODE_ENABLED
			&& (room_available_in_history.read() || !csr_retry.read())
#endif
			;

	if(!local_priority.read() && fairness_vc_reserved[csr_vc].read() && csr_can_be_sent)
		fairness_override = true;
	if(csr_available_fc == true && !csr_can_be_sent && 
		local_priority.read() && fairness_vc_reserved[csr_vc].read())
		reserve_fairness = true;

	//*********************************************************
	//Analyse if the packet from the Error handler can be sent
	//*********************************************************
	sc_bv<6> eh_cmd_bits;
	eh_cmd_bits = eh_cmd_data_fc.read().range(5,0);

	PacketCommand eh_cmd = getPacketCommand(eh_cmd_bits);
	VirtualChannel eh_vc = VC_RESPONSE;
	bool eh_data_associated = hasDataAssociated(eh_cmd);
	sc_uint<5> eh_size_with_data_m1 = getDwordPacketSizeWithDatam1(sc_bv<64>(eh_cmd_data_fc.read()),eh_cmd);
	sc_uint<4> eh_data_count = getDataLengthm1(sc_bv<64>(eh_cmd_data_fc.read()));
	//We know csr can only send responses, check if the next buffer has room for
	//a response packet, and data if there is data associated with that response
	//Also check it there IS a packet!  and if in retry mode, if we have enough room
	//in history
	bool eh_can_be_sent = (eh_available_fc == true) &&
			(fwd_next_node_buffer_status_ro.read()[BUF_STATUS_R_CMD] == true) &&
			(fwd_next_node_buffer_status_ro.read()[BUF_STATUS_R_DATA] == true || !eh_data_associated)
#ifdef RETRY_MODE_ENABLED
			 && (room_available_in_history.read() || !csr_retry.read())
#endif
			;

	if(!local_priority.read() && fairness_vc_reserved[eh_vc].read() && eh_can_be_sent)
		fairness_override = true;
	if(eh_available_fc == true && !eh_can_be_sent && 
		local_priority.read() && fairness_vc_reserved[eh_vc].read())
		reserve_fairness = true;


	//*************************************************************
	//Analyse if the packet from the internal user fifo can be sent
	//*************************************************************
	bool user_can_be_sent = fifo_user_available.read() &&
		verify_buffer_status(fifo_user_packet_vc.read(),fifo_user_packet_data_asociated.read())
#ifdef RETRY_MODE_ENABLED
		 && (room_available_in_history.read() || !csr_retry.read())
#endif
	;

#ifdef RETRY_MODE_ENABLED
	sc_uint<5> fifo_user_packet_with_data_m1 = 
		getPacketSizeWithDatam1(fifo_user_packet.read(),fifo_user_packet_command.read());
#endif

	if(!local_priority.read() && fairness_vc_reserved[fifo_user_packet_vc.read()].read() && user_can_be_sent)
		fairness_override = true;

	/** This way to reserve fairness might stop a eh or csr packet from being sent immediately, but it
		will simply be sent a bit later that's all.  And since the eh and csr traffic is rare, it does
		not cause problem.
	*/
	if(fifo_user_available == true && !user_can_be_sent 
		&& local_priority.read() && !fairness_vc_reserved[fifo_user_packet_vc.read()].read())
		reserve_fairness = true;

	/**
		For the fairness algorithm, a packet from csr, user or eh is considered a
		local packet.  We check if a local packet can be sent
	*/
	bool local_req = csr_can_be_sent || eh_can_be_sent || user_can_be_sent;

	/**
		If a fairness slot is reserved, it is for a specific VC, choose this VC
	*/
	VirtualChannel reserve_vc;
	if(eh_available_fc.read() || csr_available_fc.read())reserve_vc = VC_RESPONSE;
	else reserve_vc = fifo_user_packet_vc.read();


	/**
		While we are at it, also check if the forward packet can be sent
	*/
	sc_bv<6> fwd_cmd_bits;
	sc_bv<64> ro_packet_fwd_buf = ro_packet_fwd.read().packet;
	fwd_cmd_bits = ro_packet_fwd_buf.range(5,0);

	PacketCommand fwd_cmd = getPacketCommand(fwd_cmd_bits);
	bool fwd_data_associated = hasDataAssociated(fwd_cmd);
	sc_uint<5> fwd_size_with_data_m1 = getPacketSizeWithDatam1(ro_packet_fwd.read().packet,fwd_cmd);
	sc_uint<4> fwd_data_count = getDataLengthm1(sc_bv<64>(ro_packet_fwd.read().packet));


	/*Also, the error handler shares the line with the fwd, so if the
		error64BitExtension is on, the packet is not for us...*/
	bool fwd_can_be_sent = ro_available_fwd.read() &&
		verify_buffer_status(ro_packet_vc_fwd.read(),fwd_data_associated)  && 
		!ro_packet_fwd.read().error64BitExtension &&
		//If we are currently sending a user chain and the fwd packet is POSTED, we can't send
		!(chain_current_state == USER_CHAIN_STATE && ro_packet_vc_fwd.read() == VC_POSTED) &&
		//Dont send a packet in a VC reserved for local
		!fairness_vc_reserved[ro_packet_vc_fwd.read()].read()
#ifdef RETRY_MODE_ENABLED
		&& (room_available_in_history.read() || !csr_retry.read())
#endif
		;
	bool fwd_chain = isChain(ro_packet_fwd.read().packet);

	/** Nop request always has the absolute priority
	*/

	//default
#ifdef RETRY_MODE_ENABLED
	found_new_history_entry_size_m1 = 0;
	found_new_history_entry = false;
	found_next_calculate_crc = true;
	found_next_calculate_nop_crc = false;
#endif
	found_load_fwd_pkt = false;
	found_next_chain_current_state = chain_current_state;
	found_load_csr_pkt = false;
	found_load_user_fifo_pkt = false;
	found_hold_user_fifo_pkt = false;
	found_load_eh_pkt = false;
	found_generate_disconnect_nop = false;
	found_fc_nop_sent = false;
	found_fwd_vctype_db =  buffered_fwd_vctype_db.read();
	found_fwd_address_db =  buffered_fwd_address_db.read();
	found_next_data_cnt = 0;
	found_next_has_data = false;
	//send early in which VC data might be read
	found_fc_data_vc_ui = fifo_user_packet_vc.read();
	found_fwd_vctype_db = VC_NONE;
	found_local_packet_issued = false;
	found_current_sent_type = 0;


	//******************************
	//Select the next state
	//******************************

	
	/*  If there is a forward packet to be sent and that either there is no
	local packet to send or it the priority of the forward to send.*/
	if (fwd_can_be_sent && !send_nop &&
		//If local has a packet and has priority, we don't send
		(local_priority.read() == false || local_req == false 
		|| reserve_fairness) && !fairness_override )
	{
		
		//Log the chain state
		if(ro_packet_vc_fwd.read() == VC_POSTED){
			if(fwd_chain) found_next_chain_current_state = FWD_CHAIN_STATE;
			else found_next_chain_current_state = NO_CHAIN_STATE;
		}

		//Choose the correct destination state depending 
		//on if the packet is of dword length or not
		if (isDwordPacket(ro_packet_fwd.read().packet,fwd_cmd))  {
			found_next_state = FWD_CMD32_SENT;
			found_load_fwd_pkt = true;
		}
		else{
			found_next_state = FWD_CMD64_FIRST_SENT;
		}
#ifdef RETRY_MODE_ENABLED
		found_new_history_entry_size_m1 = fwd_size_with_data_m1;
		found_new_history_entry = true;
#endif
		found_next_data_cnt = fwd_data_count;
		found_next_has_data = fwd_data_associated;
		found_fwd_vctype_db = ro_packet_vc_fwd.read();
		found_fwd_address_db = ro_packet_fwd.read().data_address;
		found_fc_ctr_mux = FC_MUX_FWD_LSB;
		set_found_sent_type(ro_packet_vc_fwd.read(),fwd_data_associated);

		if(reserve_fairness){
			found_local_packet_issued = true;
			found_next_fairness_vc_reserved[reserve_vc] = true;
		}
	}
	/*  Next in priority is the error handler.  It should not generate too much traffic*/
	else if (eh_can_be_sent && !send_nop && 
			(local_priority.read() || fairness_vc_reserved[VC_RESPONSE].read() || !fwd_can_be_sent))
	{
		found_load_eh_pkt = true;
		found_next_state = EH_CMD_SENT;

#ifdef RETRY_MODE_ENABLED
		found_new_history_entry_size_m1 = eh_size_with_data_m1;
		found_new_history_entry = true;
#endif
		found_next_data_cnt = eh_data_count;
		found_next_has_data = eh_data_associated;
		found_fc_ctr_mux = FC_MUX_EH;

		if(local_priority.read())
			found_local_packet_issued = true;
		else
			found_next_fairness_vc_reserved[VC_RESPONSE] = false;

		//EH ALWAYS and ONLY produces responses
		set_found_sent_type(VC_RESPONSE,eh_data_associated);
	}
	/*  Next in priority is the CSR.  It should not generate too much traffic
		after init*/
	else if(csr_can_be_sent && !send_nop && 
			(local_priority.read() || fairness_vc_reserved[VC_RESPONSE].read() || !fwd_can_be_sent))
	{
		found_load_csr_pkt = true;
		found_next_state = CSR_CMD_SENT; 

#ifdef RETRY_MODE_ENABLED
		found_new_history_entry_size_m1 = csr_size_with_data_m1;
		found_new_history_entry = true;
#endif
		found_next_data_cnt = csr_data_count;
		found_next_has_data = csr_data_associated;
		found_fc_ctr_mux = FC_MUX_CSR;

		if(local_priority.read())
			found_local_packet_issued = true;
		else
			found_next_fairness_vc_reserved[VC_RESPONSE] = false;

		//CSR ALWAYS and ONLY produces responses
		set_found_sent_type(VC_RESPONSE,csr_data_associated);
	}
	/*  Next in priority is the packets from the user*/
	else if(user_can_be_sent && !send_nop &&
		!(chain_current_state == FWD_CHAIN_STATE && fifo_user_packet_vc.read() == VC_POSTED) ){

		bool isChain = fifo_user_packet_isChain.read();
		//Log the chain state
		if(fifo_user_packet_vc.read() == VC_POSTED){
			if(isChain) found_next_chain_current_state = USER_CHAIN_STATE;
			else found_next_chain_current_state = NO_CHAIN_STATE;
		}

		//Choose the correct destination state depending 
		//on if the packet is of dword length or not
		if (fifo_user_packet_dword.read())  {
			found_next_state = USER_CMD32_SENT;
			found_load_user_fifo_pkt = true;
		}
		else{
			found_next_state = USER_CMD64_FIRST_SENT;
			found_hold_user_fifo_pkt = true;
		}
		found_fc_ctr_mux = FC_MUX_UI_LSB;
		
#ifdef RETRY_MODE_ENABLED
		found_new_history_entry_size_m1 = fifo_user_packet_with_data_m1;
		found_new_history_entry = true;
#endif

		if(local_priority.read())
			found_local_packet_issued = !isChain;
		else
			found_next_fairness_vc_reserved[fifo_user_packet_vc.read()] = isChain;

		found_next_data_cnt = fifo_user_packet_data_count_m1.read();
		found_next_has_data = fifo_user_packet_data_asociated.read();
		set_found_sent_type(fifo_user_packet_vc.read(),fifo_user_packet_data_asociated.read());
	}
	else  {
#ifdef RETRY_MODE_ENABLED
		found_next_calculate_crc = false;
		found_next_calculate_nop_crc = true;
#endif
		found_fc_ctr_mux = FC_MUX_NOP;
		found_fc_nop_sent = !disconnect;
		found_generate_disconnect_nop = disconnect;

		//If the link needs to be disconnected
		if(disconnect){
#ifdef RETRY_MODE_ENABLED
			//In retry mode, we initiate a retry sequence
			if(csr_retry.read()){
				found_next_state = RETRY_SEND_DISCONNECT;
			}
			else
#endif
			//Otherwise we just go to standard LDTSTOP disconnect
			{
				found_next_state = LDTSTOP_DISCONNECT;
			}
		}
		//Send nop
		else{
			found_next_state = NOP_SENT;
		}
	}
} 


#ifdef RETRY_MODE_ENABLED

void flow_control_l3::set_foundh_sent_type (VirtualChannel vc , bool data) {
		 
	//comment for Reference, do not uncomment
	//or uncomment and define an enum somewhere
	//enum VirtualChannel {VC_POSTED,VC_NON_POSTED,VC_RESPONSE,VC_NONE};
	//   ResponseData;	//bit 0
	// 	 Response;		//bit 1
	// 	 NonPostData;	//bit 2
	// 	 NonPostCmd;	//bit 3
	// 	 PostData;		//bit 4	
	// 	 PostCmd;		//bit 5
		
	switch (vc) {
		
	case VC_POSTED :
		if (data == true)
			foundh_current_sent_type = "110000";
		else
			foundh_current_sent_type = "100000";
		break;
		
	case VC_NON_POSTED :
		if (data == true)
			foundh_current_sent_type = "001100";
		else
			foundh_current_sent_type = "001000";
		break;
		
	case VC_RESPONSE :
		if (data == true)
			foundh_current_sent_type = "000011";
		else
			foundh_current_sent_type = "000010";
		break;
		
	default :
		foundh_current_sent_type = "000000";
		break;
		
	}
	
}
#endif


void flow_control_l3::set_found_sent_type (VirtualChannel vc , bool data) {
		 
	//comment for Reference, do not uncomment
	//or uncomment and define an enum somewhere
	//enum VirtualChannel {VC_POSTED,VC_NON_POSTED,VC_RESPONSE,VC_NONE};
	//   ResponseData;	//bit 0
	// 	 Response;		//bit 1
	// 	 NonPostData;	//bit 2
	// 	 NonPostCmd;	//bit 3
	// 	 PostData;		//bit 4	
	// 	 PostCmd;		//bit 5
		
	switch (vc) {
		
	case VC_POSTED :
		if (data == true)
			found_current_sent_type = "110000";
		else
			found_current_sent_type = "100000";
		break;
		
	case VC_NON_POSTED :
		if (data == true)
			found_current_sent_type = "001100";
		else
			found_current_sent_type = "001000";
		break;
		
	case VC_RESPONSE :
		if (data == true)
			found_current_sent_type = "000011";
		else
			found_current_sent_type = "000010";
		break;
		
	default :
		found_current_sent_type = "000000";
		break;
		
	}
	
}

bool flow_control_l3::verify_buffer_status (VirtualChannel vc , bool data ){
	
	//comment for Reference, do not uncomment
	//enum VirtualChannel {VC_POSTED,VC_NON_POSTED,VC_RESPONSE,VC_NONE};
	//   ResponseData;	//bit 0
	// 	 Response;		//bit 1
	// 	 NonPostData;	//bit 2
	// 	 NonPostCmd;	//bit 3
	// 	 PostData;		//bit 4	
	// 	 PostCmd;		//bit 5
	
	
	switch (vc) {
		
	case VC_POSTED :
		if (data == true)
			return  (fwd_next_node_buffer_status_ro.read()[BUF_STATUS_P_DATA] == true &&
			fwd_next_node_buffer_status_ro.read()[BUF_STATUS_P_CMD] == true);
		else
			return  (fwd_next_node_buffer_status_ro.read()[BUF_STATUS_P_CMD] == true);
		break;
		
	case VC_NON_POSTED :
		if (data == true)
			return  (fwd_next_node_buffer_status_ro.read()[BUF_STATUS_NP_DATA] == true &&
			fwd_next_node_buffer_status_ro.read()[BUF_STATUS_NP_CMD] == true);
		else
			return  (fwd_next_node_buffer_status_ro.read()[BUF_STATUS_NP_CMD] == true);
		
		break;
		
	case VC_RESPONSE :
		if (data == true)
			return  (fwd_next_node_buffer_status_ro.read()[BUF_STATUS_R_DATA] == true &&
			fwd_next_node_buffer_status_ro.read()[BUF_STATUS_R_CMD] == true);
		else
			return  (fwd_next_node_buffer_status_ro.read()[BUF_STATUS_R_CMD] == true);
		break;
		
	default :
		return false;
		
		
	}
	
}

void flow_control_l3::go_NOP_SENT(){
	fc_ctr_mux = FC_MUX_NOP;
	fc_nop_sent = true;
	next_state = NOP_SENT;
	next_fc_lctl_lk = true;
	next_fc_hctl_lk = true;
#ifdef RETRY_MODE_ENABLED
	next_calculate_nop_crc = true;
#endif
}


void flow_control_l3::go_NOP_SENT_IN_FWD(){
	fc_ctr_mux = FC_MUX_NOP;
	fc_nop_sent = true;
	next_state = NOP_SENT_IN_FWD;
	next_fc_lctl_lk = true;
	next_fc_hctl_lk = true;
#ifdef RETRY_MODE_ENABLED
	next_calculate_nop_crc = true;
#endif
}

void flow_control_l3::go_NOP_SENT_IN_USER(){
	fc_ctr_mux = FC_MUX_NOP;
	fc_nop_sent = true;
	next_state = NOP_SENT_IN_USER;
	next_fc_lctl_lk = true;
	next_fc_hctl_lk = true;
#ifdef RETRY_MODE_ENABLED
	next_calculate_nop_crc = true;
#endif
}

void flow_control_l3::go_NOP_SENT_IN_EH(){
	fc_ctr_mux = FC_MUX_NOP;
	fc_nop_sent = true;
	next_state = NOP_SENT_IN_EH;
	next_fc_lctl_lk = true;
	next_fc_hctl_lk = true;
#ifdef RETRY_MODE_ENABLED
	next_calculate_nop_crc = true;
#endif
}

void flow_control_l3::go_NOP_SENT_IN_CSR(){
	fc_ctr_mux = FC_MUX_NOP;
	fc_nop_sent = true;
	next_state = NOP_SENT_IN_CSR;
	next_fc_lctl_lk = true;
	next_fc_hctl_lk = true;
#ifdef RETRY_MODE_ENABLED
	next_calculate_nop_crc = true;
#endif
}

void flow_control_l3::go_FWD_DATA_SENT(){
	next_fc_lctl_lk = false;
	next_fc_hctl_lk = false;
	fc_ctr_mux = FC_MUX_DB_DATA;
	next_data_cnt = data_cnt.read() - 1;
	next_state = FWD_DATA_SENT;
	next_has_data = data_cnt.read() != 0;
	fwd_erase_db = data_cnt.read() == 0;

	fwd_read_db = true;
#ifdef RETRY_MODE_ENABLED
	next_calculate_crc = true;
#endif
}

void flow_control_l3::go_USER_DATA_SENT(){
	next_fc_lctl_lk = false;
	next_fc_hctl_lk = false;
	fc_ctr_mux = FC_MUX_UI_DATA;
	next_data_cnt = data_cnt.read() - 1;
	next_state = USER_DATA_SENT;
	next_has_data = data_cnt.read() != 0;
	fc_consume_data_ui = true;
#ifdef RETRY_MODE_ENABLED
	next_calculate_crc = true;
#endif
}

void flow_control_l3::go_ERROR_DATA_SENT(){
	next_fc_lctl_lk = false;
	next_fc_hctl_lk = false;
	fc_ctr_mux = FC_MUX_EH;
	next_data_cnt = data_cnt.read() - 1;
	next_state = ERROR_DATA_SENT;
	next_has_data = data_cnt.read() != 0;
	fc_ack_eh = true;
#ifdef RETRY_MODE_ENABLED
	next_calculate_crc = true;
#endif
}

void flow_control_l3::go_CSR_DATA_SENT(){
	next_fc_lctl_lk = false;
	next_fc_hctl_lk = false;
	fc_ctr_mux = FC_MUX_CSR;
	next_data_cnt = data_cnt.read() - 1;
	next_state = CSR_DATA_SENT;
	next_has_data = data_cnt.read() != 0;
	fc_ack_csr = true;
#ifdef RETRY_MODE_ENABLED
	next_calculate_crc = true;
#endif
}

void flow_control_l3::go_LDTSTOP_DISCONNECT(){
	//next_fc_disconnect_lk = false;
	fc_ctr_mux = FC_MUX_NOP; //32 bits NOP
	next_fc_lctl_lk = true;
	next_fc_hctl_lk = true;
	generate_disconnect_nop = true;

	next_state = LDTSTOP_DISCONNECT;
#ifdef RETRY_MODE_ENABLED
	next_calculate_nop_crc = false;
#endif
}


#ifdef RETRY_MODE_ENABLED

void flow_control_l3::go_RETRY_NOP_SENT(){
	fc_ctr_mux = FC_MUX_NOP;
	fc_nop_sent = true;
	next_state = RETRY_NOP_SENT;
	next_fc_lctl_lk = true;
	next_fc_hctl_lk = true;
	next_calculate_nop_crc = true;
}

void flow_control_l3::go_RETRY_NOP_SENT_IN_DATA(){
	fc_ctr_mux = FC_MUX_NOP;
	fc_nop_sent = true;
	next_state = RETRY_NOP_SENT_IN_DATA;
	next_fc_lctl_lk = true;
	next_fc_hctl_lk = true;
	next_calculate_nop_crc = true;
}

void flow_control_l3::go_NOP_CRC_SENT_IN_FWD(){
	next_select_nop_crc_output = true;
	fc_nop_sent = false;
	next_state = NOP_CRC_SENT_IN_FWD;
	next_fc_lctl_lk = true;
	next_fc_hctl_lk = false;
}

void flow_control_l3::go_SEND_CMD_CRC(){
	next_state = SEND_CMD_CRC;
	next_select_crc_output = true;
	next_fc_lctl_lk = true;
	next_fc_hctl_lk = false;
}

void flow_control_l3::go_RETRY_SEND_CMD_CRC(){
	next_state = RETRY_SEND_CMD_CRC;
	next_select_crc_output = true;
	next_fc_lctl_lk = true;
	next_fc_hctl_lk = false;
}

void flow_control_l3::go_RETRY_SEND_CMD_CRC_DATA(){
	next_state = RETRY_SEND_CMD_CRC;
	next_select_crc_output = true;
	next_fc_lctl_lk = false;
	next_fc_hctl_lk = true;
}


void flow_control_l3::go_RETRY_DATA_SENT(){
	next_fc_lctl_lk = false;
	next_fc_hctl_lk = false;
	fc_ctr_mux = FC_MUX_HISTORY;
	next_data_cnt = data_cnt.read() - 1;
	next_state = RETRY_DATA_SENT;
	next_has_data = data_cnt.read() != 0;

	consume_history = true;
	next_calculate_crc = true;
}

void flow_control_l3::go_SEND_DATA_CRC(){
	//fc_ctr_mux = FC_MUX_CRC;
	next_state = SEND_DATA_CRC;
	next_fc_lctl_lk = false;
	next_fc_hctl_lk = true;
	next_select_crc_output = true;
}


void flow_control_l3::go_RETRY_SEND_DISCONNECT(){
	fc_ctr_mux = FC_MUX_NOP; //32 bits NOP
	next_fc_lctl_lk = true;
	next_fc_hctl_lk = true;
	generate_disconnect_nop = true;
	next_calculate_nop_crc = true;

	next_state = RETRY_SEND_DISCONNECT_CRC;
}

void flow_control_l3::go_next_retry_state(){
	fc_ctr_mux = foundh_fc_ctr_mux;
	fc_nop_sent = foundh_fc_nop_sent;
	next_state = foundh_next_state;
	next_fc_lctl_lk = foundh_next_fc_lctl_lk;
	next_fc_hctl_lk = foundh_next_fc_hctl_lk;
	next_calculate_nop_crc = foundh_next_calculate_nop_crc;
	next_calculate_crc = foundh_next_calculate_crc;
	next_data_cnt = foundh_next_data_cnt;
	next_has_data = foundh_next_has_data;
	current_sent_type = foundh_current_sent_type;
	consume_history = foundh_consume_history;
}

void flow_control_l3::find_next_retry_state(){

	//Find if sending a nop has been requested by other modules
	bool nop_req;
	if (ro_nop_req_fc ==  true || db_nop_req_fc ==  true || nop_next_to_send == true )
		nop_req = true;
	else
		nop_req  = false;

	sc_bv<6> history_cmd_bits = history_packet.read().range(5,0);

	PacketCommand history_cmd = getPacketCommand(history_cmd_bits);
	VirtualChannel history_vc = getVirtualChannel(sc_bv<64>(history_packet.read()),history_cmd);
	bool history_data_associated = hasDataAssociated(history_cmd);
	bool enough_buffers = verify_buffer_status(history_vc,history_data_associated);
	bool dword_packet = isDwordPacket((sc_bv<64>)history_packet.read(),history_cmd);

	//Brought before the if/elsif statement to try to accelerate
	//the combinatorial path
	foundh_consume_history = (ldtstopx.read() && !nop_req) && 
		(!history_playback_done.read() && enough_buffers);

	foundh_fc_nop_sent = false;
	foundh_next_fc_lctl_lk = true;
	foundh_next_fc_hctl_lk = true;
	foundh_next_calculate_nop_crc = false;
	foundh_next_calculate_crc = false;
	foundh_next_data_cnt = 0;
	foundh_next_has_data = false;
	foundh_current_sent_type = "000000";
	foundh_generate_disconnect_nop = false;

	if(ldtstopx.read() == false || retry_disconnect_initiated.read()){
		foundh_next_calculate_nop_crc = true;
		foundh_next_state = RETRY_SEND_DISCONNECT;
		foundh_fc_ctr_mux = FC_MUX_NOP;
		foundh_generate_disconnect_nop = true;
		foundh_next_calculate_nop_crc = true;
	}
	else if(!history_playback_done.read() && enough_buffers && !nop_req){
		set_foundh_sent_type(history_vc,history_data_associated);
		foundh_next_data_cnt = getDataLengthm1(sc_bv<64>(history_packet.read()));
		foundh_next_has_data = history_data_associated;
		foundh_fc_ctr_mux = FC_MUX_HISTORY;
		foundh_next_calculate_crc = true;

		//Brought before the if/elsif statement to try to accelerate
		//the combinatorial path
		//foundh_consume_history = dword_packet;

		if (dword_packet){
			foundh_next_state = RETRY_CMD32_SENT;
		}
		else{
			foundh_next_state = RETRY_CMD64_FIRST_SENT;
		}
	}
	else{
		if(!history_playback_done.read())
			foundh_next_state = RETRY_NOP_SENT;
		else
			foundh_next_state = NOP_SENT;

		foundh_fc_ctr_mux = FC_MUX_NOP;
		foundh_fc_nop_sent = true;
		foundh_next_calculate_nop_crc = true;
	}
}

#endif

#ifndef SYSTEMC_SIM

#include "../core_synth/synth_control_packet.cpp"

#endif

