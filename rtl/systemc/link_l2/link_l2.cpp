//link_l2.cpp
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

#include "link_l2.h"
#include "link_frame_rx_l3.h"
#include "link_frame_tx_l3.h"

link_l2::link_l2( sc_module_name name) : sc_module(name) {
	////////////////////////////////////////
	// Process declaration
	////////////////////////////////////////

	SC_METHOD(rx_crc_state_machine);
	sensitive_pos(clk);
	sensitive_neg(resetx);
	
	SC_METHOD(tx_crc_state_machine);
	sensitive_pos(clk);
	sensitive_neg(resetx);

	SC_METHOD(evaluate_rx_crc_process);
	sensitive_pos(clk);
	sensitive_neg(resetx);

	SC_METHOD(evaluate_tx_crc_process);
	sensitive_pos(clk);
	sensitive_neg(resetx);

	SC_METHOD(output_ldtstop_disconnected);
	sensitive << ldtstop_disconnect_tx;
	
	SC_METHOD(select_output);
	sensitive << transmit_select << tx_last_crc << 
				fc_dword_lk << fc_lctl_lk << fc_hctl_lk <<
				tx_consume_data;

	SC_METHOD(output_framed_data);
	sensitive(framed_data_ready);
	sensitive(framed_data_available);

	////////////////////////////////////////
	// RX Framer linking
	////////////////////////////////////////

	frame_rx = new link_frame_rx_l3("link_frame_rx_l3");
	frame_rx->clk(clk);
	frame_rx->phy_ctl_lk(phy_ctl_lk);

	for(int n = 0; n < CAD_IN_WIDTH; n++){
		frame_rx->phy_cad_lk[n](phy_cad_lk[n]);
	}
	frame_rx->lk_disable_receivers_phy(lk_disable_receivers_phy);
	frame_rx->phy_available_lk(phy_available_lk);

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	frame_rx->lk_deser_stall_phy(lk_deser_stall_phy);
	frame_rx->lk_deser_stall_cycles_phy(lk_deser_stall_cycles_phy);
#endif
	
	frame_rx->framed_cad(lk_dword_cd);
	frame_rx->framed_lctl(lk_lctl_cd);
	frame_rx->framed_hctl(lk_hctl_cd);
	frame_rx->framed_data_available(framed_data_available);

	frame_rx->resetx(resetx);
	frame_rx->pwrok(pwrok);
	frame_rx->ldtstopx(ldtstopx);

	frame_rx->csr_rx_link_width_lk(csr_rx_link_width_lk);
	frame_rx->csr_end_of_chain(csr_end_of_chain);
	frame_rx->csr_sync(csr_sync);
	frame_rx->csr_extended_ctl_timeout_lk(csr_extended_ctl_timeout_lk);

	frame_rx->lk_update_link_width_csr(lk_update_link_width_csr);
	frame_rx->lk_sampled_link_width_csr(lk_sampled_link_width_csr);

	
	frame_rx->lk_update_link_failure_property_csr(lk_update_link_failure_property_csr);
	frame_rx->lk_link_failure_csr(lk_link_failure_csr);

	frame_rx->ldtstop_disconnect_rx(ldtstop_disconnect_rx);

	frame_rx->lk_protocol_error_csr(lk_protocol_error_csr);

	frame_rx->rx_waiting_for_ctl_tx(rx_waiting_for_ctl_tx);

	frame_rx->lk_rx_connected(lk_rx_connected);

#ifdef RETRY_MODE_ENABLED
	frame_rx->csr_retry(csr_retry);
	frame_rx->cd_initiate_retry_disconnect(cd_initiate_retry_disconnect);
	frame_rx->lk_initiate_retry_disconnect(lk_initiate_retry_disconnect);
#endif

	////////////////////////////////////////
	// TX Framer linking
	////////////////////////////////////////

	frame_tx = new link_frame_tx_l3("link_frame_tx_l3");
	frame_tx->clk(clk);

	frame_tx->lk_ctl_phy(lk_ctl_phy);


	for(int n = 0; n < CAD_OUT_WIDTH; n++){
		frame_tx->lk_cad_phy[n](lk_cad_phy[n]);
	}
	frame_tx->phy_consume_lk(phy_consume_lk);

	frame_tx->disable_drivers(lk_disable_drivers_phy);
	
	frame_tx->cad_to_frame(cad_to_frame);
	frame_tx->lctl_to_frame(lctl_to_frame);
	frame_tx->hctl_to_frame(hctl_to_frame);
	frame_tx->tx_consume_data(tx_consume_data);

	frame_tx->resetx(resetx);
	frame_tx->ldtstopx(ldtstopx);

	frame_tx->csr_tx_link_width_lk(csr_tx_link_width_lk);
	frame_tx->csr_end_of_chain(csr_end_of_chain);
	frame_tx->csr_transmitter_off_lk(csr_transmitter_off_lk);
	frame_tx->csr_extented_ctl_lk(csr_extented_ctl_lk);
	frame_tx->csr_ldtstop_tristate_enable_lk(csr_ldtstop_tristate_enable_lk);

#ifdef RETRY_MODE_ENABLED
	frame_tx->tx_retry_disconnect(tx_retry_disconnect);
#endif

	frame_tx->ldtstop_disconnect_tx(ldtstop_disconnect_tx);
	frame_tx->rx_waiting_for_ctl_tx(rx_waiting_for_ctl_tx);
}

void link_l2::rx_crc_state_machine(){
	//initial value at reset
	if(!resetx.read()){
		rx_state = RX_FIRST_CRC_WINDOW_ST;
		rx_crc_count = 0;
		new_rx_crc_window = false;
		ldtstop_disconnect_rx = false;
		framed_data_ready = true;
	}
	//action to take at clock edge
	else{
		//default values
		framed_data_ready = true;
		new_rx_crc_window = false;
		ldtstop_disconnect_rx = false;

		//RX state machine
		switch(rx_state.read()){

		case RX_CRC_WINDOW_BEGIN_ST:
			//incremet rx count when data available only
			if(framed_data_available.read())
				rx_crc_count = rx_crc_count.read()+1;

			//After 16 dword, it is time to received CRC
			if(rx_crc_count.read() == 15 && framed_data_available.read()){
				//Do not send CRC to the decoder
				framed_data_ready = false;

				//If starting a ldtstop sequence, we need to go to a second
				//set of state so that we disconnect after the next CRC
				//window is done
				if(cd_initiate_nonretry_disconnect_lk.read()){
					rx_state = RX_RECEIVE_CRC_LDTSTOP_ST;
				}
				else{
					rx_state = RX_RECEIVE_CRC_ST;
				}
			}
			else if(cd_initiate_nonretry_disconnect_lk.read()){
				//When we receive a disconnect NOP, it gets decoded immediately
				//, that's why if the rx_crc count
				//is 0, it means we were in the current window
				rx_state = RX_CRC_WINDOW_BEGIN_LDTSTOP_ST;
			}
			break;
		case RX_RECEIVE_CRC_ST:
			rx_crc_count = rx_crc_count.read();//Don't modify the CRC count
			//Don't send the CRC received to the decoder by default unless framed data available
			framed_data_ready = false;

			if(framed_data_available.read()){
				framed_data_ready = true;
				if(cd_initiate_nonretry_disconnect_lk.read()){
					rx_state = RX_CRC_WINDOW_END_LDTSTOP_ST;
				}
				else{
					rx_state = RX_CRC_WINDOW_END_ST;
				}
			}
			else if(cd_initiate_nonretry_disconnect_lk.read()){
				rx_state = RX_RECEIVE_CRC_LDTSTOP_ST;
			}
			break;

		case RX_CRC_WINDOW_END_ST:
			if(framed_data_available.read())
				rx_crc_count = rx_crc_count.read()+1;

			if(rx_crc_count.read() == 127 && framed_data_available.read()){
				new_rx_crc_window = true;
				if(cd_initiate_nonretry_disconnect_lk.read()){
					rx_state = RX_CRC_WINDOW_LAST_LDTSTOP_ST;
				}
				else{
					rx_state = RX_CRC_WINDOW_BEGIN_ST;
				}
			}
			else if(cd_initiate_nonretry_disconnect_lk.read()){
				rx_state = RX_CRC_WINDOW_END_LDTSTOP_ST;
			}
			break;

		/**
			The previous group of states it for normal operation (also includes
			the last default state : RX_FIRST_CRC_WINDOW_ST)

			The next group of states is for when a LDTSTOP sequence is initiated.
			When LDTSTOP is initiated, the current CRC window must be finished,
			the last CRC sent and then disconnect.
		*/

		case RX_FIRST_CRC_WINDOW_LDTSTOP_ST:
			if(framed_data_available.read())
				rx_crc_count = rx_crc_count.read()+1;

			if(rx_crc_count.read() == 127 && framed_data_available.read()){
				new_rx_crc_window = true;
				rx_state = RX_RECEIVE_LAST_CRC_LDTSTOP_ST;
			}
			break;

		case RX_CRC_WINDOW_BEGIN_LDTSTOP_ST:
			if(framed_data_available.read())
				rx_crc_count = rx_crc_count.read()+1;

			if(rx_crc_count.read() == 15 && framed_data_available.read()){
				framed_data_ready = false;
				rx_state = RX_RECEIVE_CRC_LDTSTOP_ST;
			}
			break;

		case RX_RECEIVE_CRC_LDTSTOP_ST:
			if(framed_data_available.read()){
				rx_state = RX_CRC_WINDOW_END_LDTSTOP_ST;
				framed_data_ready = true;
			}
			else{
				framed_data_ready = false;
			}
			break;

		case RX_CRC_WINDOW_END_LDTSTOP_ST:
			if(framed_data_available.read())
				rx_crc_count = rx_crc_count.read()+1;

			if(rx_crc_count.read() == 127 && framed_data_available.read()){
				new_rx_crc_window = true;
				rx_state = RX_CRC_WINDOW_LAST_LDTSTOP_ST;
			}
			break;
		case RX_CRC_WINDOW_LAST_LDTSTOP_ST:
			if(framed_data_available.read())
				rx_crc_count = rx_crc_count.read()+1;

			if(rx_crc_count.read() == 15 && framed_data_available.read()){
				rx_state = RX_RECEIVE_LAST_CRC_LDTSTOP_ST;
				framed_data_ready = false;
			}
			break;
		case RX_RECEIVE_LAST_CRC_LDTSTOP_ST:
			framed_data_ready = false;
			rx_crc_count = rx_crc_count.read();

			if(framed_data_available.read()){
				rx_state = RX_DISCONNECTED;
			}
			break;

		//Link is disconnected
		case RX_DISCONNECTED:
			framed_data_ready = false;//Don't send any data to decoder
			rx_crc_count = 0;//Keep CRC count at 0
			//Make sure the CRC register is ready to start a new windows
			//by resetting it
			new_rx_crc_window = true;

			ldtstop_disconnect_rx = true;
			if(!ldtstopx.read() || csr_end_of_chain.read() || csr_sync.read()){
				rx_state = RX_DISCONNECTED;
			}
			else{
				rx_state = RX_FIRST_CRC_WINDOW_ST;
			}
			break;
		default: //case RX_FIRST_CRC_WINDOW_ST:
			if(framed_data_available.read())
				rx_crc_count = rx_crc_count.read()+1;

			if(rx_crc_count.read() == 127 && framed_data_available.read()){
				new_rx_crc_window = true;
				if(cd_initiate_nonretry_disconnect_lk.read()){
					rx_state = RX_CRC_WINDOW_LAST_LDTSTOP_ST;
				}
				else{
					rx_state = RX_CRC_WINDOW_BEGIN_ST;
				}
			}
			else if(cd_initiate_nonretry_disconnect_lk.read()){
				rx_state = RX_FIRST_CRC_WINDOW_LDTSTOP_ST;
			}
			break;
		}

		/**
			If sync of csr_end_of_chain, go to disconnected state (ignore input)
			
			Also disconnect if the connect sequence is not complete 
			(!lk_rx_connected.read()) when ldtstop sequence is initiated.  In retry mode,
			ldtstop sequence might start in the middle of a retry reconnect sequence.  This
			code will make RX abort reconnect, which might not be the case for the TX : it
			will finish the connect, the flow_control_l2 will make it send a discon nop and
			then it will redisconnect
		*/
		if(csr_sync.read() || csr_end_of_chain.read() ||
			(!lk_rx_connected.read() && !ldtstopx.read()))
		{
			framed_data_ready = false;
			rx_state = RX_DISCONNECTED;		
		}
#ifdef RETRY_MODE_ENABLED
		/*
		In the case of a retry sequence, the RX framer will disconnect so just go directly
		to the first CRC window to wait for it to complete the reconnect sequence

		Note: the command decoder is NOT allowed to activate cd_initiate_nonretry_disconnect_lk.
		If a ldtstop sequence is started, it's cd_initiate_retry_disconnect_lk that will
		be activated
		*/
		else if(lk_initiate_retry_disconnect.read() || cd_initiate_retry_disconnect.read()){
			rx_state = RX_FIRST_CRC_WINDOW_ST;	
			rx_crc_count = 0;
		}
#endif
	}
}


void link_l2::evaluate_rx_crc_process(){
	//Init values during reset
	if(!resetx.read()){
		rx_crc = 0xFFFFFFFF;
		rx_last_crc = 0;

		lk_crc_error_csr = false;
		crc_error = false;
		crc_error_delay = 0;
	}

	//Action to take during clock event
	else{
		//By default, no error is detected
		lk_crc_error_csr = false;
		bool crc_error_detected = false;		

		//Check if we are in a state to check the received CRC
		bool crc_comparison_state = 
			rx_state.read() == RX_RECEIVE_CRC_ST ||
			rx_state.read() == RX_RECEIVE_CRC_LDTSTOP_ST ||
			rx_state.read() == RX_RECEIVE_LAST_CRC_LDTSTOP_ST;


		//If starting a new CRC, calculate from 0, otherwise take the old CRC
		sc_uint<32>  crc_in;
		sc_uint<32>  crc;
		if(new_rx_crc_window.read())
			crc_in = 0xFFFFFFFF;
		else
			crc_in = rx_crc.read();


		//Setup the data to send in the CRC :
		////HCTL,data[31,24],HCTL,data[23,16],LCTL,data[15,8],LCTL,data[7,0]
		//See chapter 10 of HT spec
		sc_bv<36> d;
		d.range(7,0) = lk_dword_cd.read().range(7,0);
		d[8] = lk_lctl_cd.read();
		d.range(16,9) = lk_dword_cd.read().range(15,8);
		d[17] = lk_lctl_cd.read();
		d.range(25,18) = lk_dword_cd.read().range(23,16);
		d[26] = lk_hctl_cd.read();
		d.range(34,27) = lk_dword_cd.read().range(31,24);
		d[35] = lk_hctl_cd.read();

		/*//Calculate the CRC
		for (int i=0; i<36; ++i) { 
			bool tmp = crc[31];  // store highest bit 
			
			// subtract poly if greater: 
			crc[31] = crc[30];
			crc[30] = crc[29];
			crc[29] = crc[28];
			crc[28] = crc[27];
			crc[27] = crc[26];
			crc[26] = crc[25]^tmp;
			crc[25] = crc[24];
			crc[24] = crc[23];
			crc[23] = crc[22]^tmp;
			crc[22] = crc[21]^tmp;
			crc[21] = crc[20];
			crc[20] = crc[19];
			crc[19] = crc[18];
			crc[18] = crc[17];
			crc[17] = crc[16];
			crc[16] = crc[15]^tmp;
			crc[15] = crc[14];
			crc[14] = crc[13];
			crc[13] = crc[12];
			crc[12] = crc[11]^tmp;
			crc[11] = crc[10]^tmp;
			crc[10] = crc[9]^tmp;
			crc[9] = crc[8];
			crc[8] = crc[7]^tmp;
			crc[7] = crc[6]^tmp;
			crc[6] = crc[5];
			crc[5] = crc[4]^tmp;
			crc[4] = crc[3]^tmp;
			crc[3] = crc[2];
			crc[2] = crc[1]^tmp;
			crc[1] = crc[0]^tmp; 
			crc[0] = ((sc_bit)crc_data[i]) ^ tmp;
		}*/
		//Obtained with a slightly modified Xilinx Xapp209
		crc[0] = (sc_bit)(crc_in[2] ^ crc_in[20] ^ crc_in[12] ^ crc_in[21] ^ crc_in[5] ^ crc_in[30] ^ crc_in[22] ^ crc_in[6] ^ d[35] ^ crc_in[24] ^ crc_in[8] ^ d[3] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28]);
		crc[1] = (sc_bit)(crc_in[2] ^ crc_in[3] ^ crc_in[20] ^ crc_in[12] ^ crc_in[5] ^ crc_in[13] ^ crc_in[30] ^ crc_in[31] ^ d[34] ^ crc_in[23] ^ crc_in[7] ^ d[2] ^ crc_in[24] ^ crc_in[8] ^ d[3] ^ crc_in[9] ^ crc_in[29]);
		crc[2] = (sc_bit)(crc_in[3] ^ crc_in[20] ^ crc_in[5] ^ crc_in[13] ^ d[33] ^ crc_in[22] ^ crc_in[31] ^ d[2] ^ crc_in[9] ^ crc_in[26] ^ crc_in[28] ^ crc_in[2] ^ crc_in[10] ^ crc_in[4] ^ crc_in[12] ^ d[1] ^ crc_in[14] ^ d[3] ^ crc_in[27]);
		crc[3] = (sc_bit)(crc_in[3] ^ crc_in[11] ^ crc_in[13] ^ crc_in[5] ^ d[0] ^ d[2] ^ crc_in[15] ^ crc_in[28] ^ crc_in[10] ^ crc_in[4] ^ d[32] ^ crc_in[21] ^ crc_in[6] ^ d[1] ^ crc_in[14] ^ crc_in[23] ^ crc_in[27] ^ crc_in[29]);
		crc[4] = (sc_bit)(crc_in[11] ^ d[31] ^ crc_in[20] ^ d[0] ^ crc_in[7] ^ crc_in[15] ^ crc_in[26] ^ crc_in[0] ^ crc_in[2] ^ crc_in[4] ^ crc_in[21] ^ d[1] ^ crc_in[14] ^ d[3] ^ crc_in[8] ^ crc_in[16] ^ crc_in[25] ^ crc_in[27] ^ crc_in[29]);
		crc[5] = (sc_bit)(crc_in[3] ^ crc_in[20] ^ d[0] ^ d[2] ^ crc_in[15] ^ crc_in[24] ^ crc_in[9] ^ crc_in[17] ^ crc_in[0] ^ crc_in[2] ^ d[30] ^ crc_in[6] ^ d[3] ^ crc_in[16] ^ crc_in[25] ^ crc_in[1]);
		crc[6] = (sc_bit)(crc_in[3] ^ d[2] ^ crc_in[7] ^ crc_in[17] ^ crc_in[26] ^ crc_in[0] ^ crc_in[2] ^ crc_in[10] ^ crc_in[4] ^ crc_in[21] ^ d[1] ^ crc_in[16] ^ crc_in[25] ^ d[29] ^ crc_in[18] ^ crc_in[1]);
		crc[7] = (sc_bit)(crc_in[11] ^ crc_in[3] ^ crc_in[20] ^ d[0] ^ crc_in[24] ^ d[28] ^ crc_in[17] ^ crc_in[19] ^ crc_in[28] ^ crc_in[4] ^ crc_in[12] ^ crc_in[21] ^ crc_in[30] ^ crc_in[6] ^ d[1] ^ d[3] ^ crc_in[25] ^ crc_in[18] ^ crc_in[1]);
		crc[8] = (sc_bit)(d[0] ^ crc_in[13] ^ crc_in[31] ^ crc_in[7] ^ d[2] ^ crc_in[24] ^ crc_in[19] ^ crc_in[28] ^ crc_in[0] ^ crc_in[4] ^ crc_in[30] ^ crc_in[6] ^ d[27] ^ d[3] ^ crc_in[8] ^ crc_in[18] ^ crc_in[27] ^ crc_in[29]);
		crc[9] = (sc_bit)(crc_in[20] ^ crc_in[5] ^ crc_in[31] ^ d[26] ^ d[2] ^ crc_in[7] ^ crc_in[9] ^ crc_in[19] ^ crc_in[28] ^ crc_in[0] ^ crc_in[30] ^ d[1] ^ crc_in[14] ^ crc_in[8] ^ crc_in[25] ^ crc_in[29] ^ crc_in[1]);
		crc[10] = (sc_bit)(d[0] ^ crc_in[5] ^ crc_in[22] ^ crc_in[31] ^ crc_in[15] ^ crc_in[24] ^ crc_in[9] ^ crc_in[28] ^ crc_in[10] ^ crc_in[12] ^ d[25] ^ d[1] ^ d[3] ^ crc_in[25] ^ crc_in[27] ^ crc_in[29] ^ crc_in[1]);
		crc[11] = (sc_bit)(crc_in[11] ^ crc_in[20] ^ d[24] ^ d[0] ^ crc_in[5] ^ crc_in[13] ^ crc_in[22] ^ d[2] ^ crc_in[24] ^ crc_in[0] ^ crc_in[10] ^ crc_in[12] ^ crc_in[21] ^ crc_in[23] ^ d[3] ^ crc_in[8] ^ crc_in[16] ^ crc_in[27] ^ crc_in[29]);
		crc[12] = (sc_bit)(crc_in[11] ^ crc_in[20] ^ crc_in[5] ^ crc_in[13] ^ d[2] ^ crc_in[9] ^ crc_in[17] ^ crc_in[26] ^ crc_in[0] ^ crc_in[2] ^ d[23] ^ d[1] ^ crc_in[14] ^ crc_in[23] ^ d[3] ^ crc_in[8] ^ crc_in[27] ^ crc_in[1]);
		crc[13] = (sc_bit)(d[22] ^ crc_in[3] ^ d[0] ^ d[2] ^ crc_in[15] ^ crc_in[24] ^ crc_in[9] ^ crc_in[28] ^ crc_in[2] ^ crc_in[10] ^ crc_in[12] ^ crc_in[21] ^ crc_in[6] ^ d[1] ^ crc_in[14] ^ crc_in[18] ^ crc_in[27] ^ crc_in[1]);
		crc[14] = (sc_bit)(crc_in[3] ^ crc_in[11] ^ d[0] ^ crc_in[13] ^ crc_in[22] ^ crc_in[7] ^ crc_in[15] ^ crc_in[19] ^ crc_in[28] ^ crc_in[0] ^ d[21] ^ crc_in[2] ^ crc_in[10] ^ crc_in[4] ^ d[1] ^ crc_in[16] ^ crc_in[25] ^ crc_in[29]);
		crc[15] = (sc_bit)(crc_in[3] ^ crc_in[11] ^ crc_in[20] ^ crc_in[5] ^ d[0] ^ crc_in[17] ^ crc_in[26] ^ crc_in[0] ^ crc_in[4] ^ crc_in[12] ^ crc_in[30] ^ crc_in[14] ^ crc_in[23] ^ crc_in[8] ^ crc_in[16] ^ crc_in[29] ^ d[20] ^ crc_in[1]);
		crc[16] = (sc_bit)(crc_in[20] ^ crc_in[13] ^ crc_in[22] ^ crc_in[31] ^ crc_in[15] ^ d[19] ^ crc_in[9] ^ crc_in[17] ^ crc_in[26] ^ crc_in[28] ^ crc_in[0] ^ crc_in[4] ^ d[3] ^ crc_in[8] ^ crc_in[25] ^ crc_in[18] ^ crc_in[1]);
		crc[17] = (sc_bit)(crc_in[5] ^ d[2] ^ crc_in[9] ^ crc_in[26] ^ crc_in[19] ^ crc_in[2] ^ crc_in[10] ^ crc_in[21] ^ crc_in[14] ^ crc_in[23] ^ d[18] ^ crc_in[16] ^ crc_in[18] ^ crc_in[27] ^ crc_in[29] ^ crc_in[1]);
		crc[18] = (sc_bit)(crc_in[11] ^ crc_in[3] ^ crc_in[20] ^ crc_in[22] ^ d[17] ^ crc_in[15] ^ crc_in[24] ^ crc_in[17] ^ crc_in[19] ^ crc_in[28] ^ crc_in[2] ^ crc_in[10] ^ crc_in[30] ^ d[1] ^ crc_in[6] ^ crc_in[27]);
		crc[19] = (sc_bit)(crc_in[3] ^ crc_in[11] ^ crc_in[20] ^ d[0] ^ crc_in[31] ^ crc_in[7] ^ crc_in[28] ^ crc_in[12] ^ crc_in[4] ^ crc_in[21] ^ d[16] ^ crc_in[23] ^ crc_in[16] ^ crc_in[25] ^ crc_in[18] ^ crc_in[29]);
		crc[20] = (sc_bit)(d[15] ^ crc_in[13] ^ crc_in[5] ^ crc_in[22] ^ crc_in[24] ^ crc_in[17] ^ crc_in[26] ^ crc_in[19] ^ crc_in[0] ^ crc_in[4] ^ crc_in[12] ^ crc_in[21] ^ crc_in[30] ^ crc_in[8] ^ crc_in[29]);
		crc[21] = (sc_bit)(crc_in[20] ^ crc_in[5] ^ crc_in[13] ^ crc_in[22] ^ crc_in[31] ^ crc_in[9] ^ d[14] ^ crc_in[30] ^ crc_in[14] ^ crc_in[6] ^ crc_in[23] ^ crc_in[25] ^ crc_in[18] ^ crc_in[27] ^ crc_in[1]);
		crc[22] = (sc_bit)(d[13] ^ crc_in[20] ^ crc_in[5] ^ crc_in[22] ^ crc_in[31] ^ crc_in[15] ^ crc_in[7] ^ crc_in[19] ^ crc_in[10] ^ crc_in[12] ^ crc_in[30] ^ crc_in[14] ^ crc_in[23] ^ d[3] ^ crc_in[8] ^ crc_in[25] ^ crc_in[27]);
		crc[23] = (sc_bit)(crc_in[11] ^ crc_in[5] ^ crc_in[13] ^ crc_in[22] ^ crc_in[31] ^ d[2] ^ crc_in[15] ^ crc_in[9] ^ d[12] ^ crc_in[2] ^ crc_in[12] ^ crc_in[30] ^ crc_in[23] ^ d[3] ^ crc_in[16] ^ crc_in[25] ^ crc_in[27]);
		crc[24] = (sc_bit)(crc_in[3] ^ crc_in[13] ^ crc_in[31] ^ d[2] ^ crc_in[24] ^ crc_in[17] ^ crc_in[26] ^ crc_in[28] ^ crc_in[10] ^ crc_in[12] ^ crc_in[6] ^ d[1] ^ crc_in[14] ^ crc_in[23] ^ crc_in[16] ^ d[11]);
		crc[25] = (sc_bit)(crc_in[11] ^ d[0] ^ crc_in[13] ^ crc_in[7] ^ crc_in[15] ^ crc_in[24] ^ crc_in[17] ^ d[10] ^ crc_in[4] ^ d[1] ^ crc_in[14] ^ crc_in[25] ^ crc_in[18] ^ crc_in[27] ^ crc_in[29]);
		crc[26] = (sc_bit)(crc_in[20] ^ d[0] ^ crc_in[22] ^ crc_in[15] ^ crc_in[24] ^ crc_in[19] ^ crc_in[0] ^ crc_in[2] ^ crc_in[21] ^ crc_in[6] ^ crc_in[14] ^ d[3] ^ crc_in[16] ^ crc_in[18] ^ crc_in[27] ^ d[9]);
		crc[27] = (sc_bit)(crc_in[3] ^ crc_in[20] ^ crc_in[22] ^ d[2] ^ crc_in[7] ^ crc_in[15] ^ crc_in[17] ^ crc_in[19] ^ crc_in[28] ^ d[8] ^ crc_in[0] ^ crc_in[21] ^ crc_in[23] ^ crc_in[16] ^ crc_in[25] ^ crc_in[1]);
		crc[28] = (sc_bit)(crc_in[20] ^ crc_in[22] ^ crc_in[24] ^ crc_in[17] ^ crc_in[26] ^ crc_in[2] ^ crc_in[4] ^ crc_in[21] ^ d[1] ^ crc_in[23] ^ crc_in[8] ^ crc_in[16] ^ crc_in[18] ^ d[7] ^ crc_in[29] ^ crc_in[1]);
		crc[29] = (sc_bit)(crc_in[3] ^ crc_in[5] ^ d[0] ^ crc_in[22] ^ crc_in[24] ^ crc_in[9] ^ crc_in[17] ^ crc_in[19] ^ d[6] ^ crc_in[2] ^ crc_in[21] ^ crc_in[30] ^ crc_in[23] ^ crc_in[25] ^ crc_in[18] ^ crc_in[27]);
		crc[30] = (sc_bit)(crc_in[3] ^ crc_in[20] ^ crc_in[22] ^ crc_in[31] ^ crc_in[24] ^ crc_in[26] ^ crc_in[19] ^ crc_in[28] ^ crc_in[0] ^ crc_in[10] ^ crc_in[4] ^ crc_in[6] ^ crc_in[23] ^ crc_in[25] ^ crc_in[18] ^ d[5]);
		crc[31] = (sc_bit)(crc_in[11] ^ crc_in[20] ^ crc_in[5] ^ crc_in[7] ^ crc_in[24] ^ d[4] ^ crc_in[26] ^ crc_in[19] ^ crc_in[4] ^ crc_in[21] ^ crc_in[23] ^ crc_in[25] ^ crc_in[27] ^ crc_in[29] ^ crc_in[1]);

		//CRC is sent inverted on the link
		sc_uint<32> inverted_lk_dword_cd = ~(sc_uint<32>(lk_dword_cd.read()));

		//If in comparison state, check if received CRC is correct
		if(framed_data_available.read() && crc_comparison_state){
			crc_error_detected = rx_last_crc.read() != inverted_lk_dword_cd;
		}

		if(framed_data_available.read() && !crc_comparison_state){
			rx_crc = crc;
		}
		else if(new_rx_crc_window.read()){
			rx_crc = 0xFFFFFFFF;
		}

		//When starting a new windows, store the last value since the CRC of 
		//window is sent with a delay
		if(new_rx_crc_window.read()){
			rx_last_crc = rx_crc;
		}

		//Only log error after 15 cycles to exlude sync and reset errors
		if(crc_error_delay.read() == 15){
			lk_crc_error_csr = true;
		}

		//Don't log errors in sync, end of chain, of retry mode.  Reset crc_error
		//if crc_error_delay reached 15 and the error is logged
		if(csr_sync.read() || csr_end_of_chain.read() || crc_error_delay.read() == 15
#ifdef RETRY_MODE_ENABLED
			|| csr_retry.read()
#endif
			){
			crc_error = false;
		}
		else if(crc_error_detected){
			crc_error = true;
		}
		
		//Increment CRC error while the error is detected
		if(crc_error.read() && !csr_sync.read()){
			crc_error_delay = crc_error_delay.read() + 1;
		}
		else{
			crc_error_delay = 0;
		}

	}

}


void link_l2::tx_crc_state_machine(){
	//Value registers take at reset
	if(!resetx.read()){
		tx_state = TX_FIRST_CRC_WINDOW_ST;
		tx_crc_count = 0;
		new_tx_crc_window = false;
		ldtstop_disconnect_tx = false;
		transmit_select = TX_SELECT_DATA;
	}
	else{
		//Default values
		new_tx_crc_window = false;
		ldtstop_disconnect_tx = false;
		if(tx_consume_data.read())
			transmit_select = TX_SELECT_DATA;
		//else stay the same

		/**
			Note on ldtstop sequence.

			Ldtstop sequence normally started when the CD detects a discon nop
			and activates cd_initiate_nonretry_disconnect_lk.  
			
			In the retry mode, it is possible that a retry sequence is started 
			while reconnecting the link, in which case the RX might not complete connection
			that a discon nop might never be received.  In that case, the flow_control
			should still activate fc_disconnect_lk to activate the disconnect, which
			should not cause any problem.

			This *should* not happen in non retry mode, but we check for it anyway
			just to make sure.  If ldtstop is asserted while RX is not connected,
			start an ldtstop sequence just like if the CD had decoded it.
		*/
		bool initiate_ldtstop_sequence = cd_initiate_nonretry_disconnect_lk.read() ||
			!ldtstopx.read() && !lk_rx_connected.read();

		switch(tx_state.read()){
		case TX_CRC_WINDOW_BEGIN_ST:
			//Increment the tx CRC count when a dword is sent
			if(tx_consume_data.read())
				tx_crc_count = tx_crc_count.read()+1;

			//When the window is finished
			if(tx_crc_count.read() == 15 && tx_consume_data.read()){
				if(initiate_ldtstop_sequence)
					tx_state = TX_SEND_CRC_LDTSTOP_ST;
				else
					tx_state = TX_SEND_CRC_ST;
				transmit_select = TX_SELECT_CRC;
			}
			else if(initiate_ldtstop_sequence){
				tx_state = TX_CRC_WINDOW_BEGIN_LDTSTOP_ST;
			}
			break;
		case TX_SEND_CRC_ST:
			tx_crc_count = tx_crc_count.read();

			if(tx_consume_data.read()){
				if(initiate_ldtstop_sequence)
					tx_state = TX_CRC_WINDOW_END_LDTSTOP_ST;
				else
					tx_state = TX_CRC_WINDOW_END_ST;
			}
			else if(initiate_ldtstop_sequence){
				tx_state = TX_SEND_CRC_LDTSTOP_ST;
			}

			if(!tx_consume_data.read())
				transmit_select = TX_SELECT_CRC;

			break;
		case TX_CRC_WINDOW_END_ST:
			if(tx_consume_data.read())
				tx_crc_count = tx_crc_count.read()+1;

			if(tx_crc_count.read() == 127 && tx_consume_data.read()){
				new_tx_crc_window = true;
				if(initiate_ldtstop_sequence)
					tx_state = TX_CRC_WINDOW_BEGIN_LDTSTOP_ST;
				else
					tx_state = TX_CRC_WINDOW_BEGIN_ST;
			}
			else if(initiate_ldtstop_sequence){
				tx_state = TX_FIRST_CRC_WINDOW_LDTSTOP_ST;
			}
			break;


		case TX_FIRST_CRC_WINDOW_LDTSTOP_ST:
			if(tx_consume_data.read())
				tx_crc_count = tx_crc_count.read()+1;

			if(tx_crc_count.read() == 127 && tx_consume_data.read()){
				new_tx_crc_window = true;
				tx_state = TX_CRC_WINDOW_LAST_LDTSTOP_ST;
			}
			break;
		case TX_CRC_WINDOW_BEGIN_LDTSTOP_ST:
			if(tx_consume_data.read())
				tx_crc_count = tx_crc_count.read()+1;

			if(tx_crc_count.read() == 15 && tx_consume_data.read()){
				tx_state = TX_SEND_CRC_LDTSTOP_ST;
				transmit_select = TX_SELECT_CRC;
			}
			break;
		case TX_SEND_CRC_LDTSTOP_ST:
			tx_crc_count = rx_crc_count.read();

			if(tx_consume_data.read()){
				tx_state = TX_CRC_WINDOW_END_LDTSTOP_ST;
			}

			if(!tx_consume_data.read())
				transmit_select = TX_SELECT_CRC;

			break;
		case TX_CRC_WINDOW_END_LDTSTOP_ST:
			if(tx_consume_data.read())
				tx_crc_count = tx_crc_count.read()+1;

			if(tx_crc_count.read() == 127 && tx_consume_data.read()){
				new_tx_crc_window = true;
				tx_state = TX_CRC_WINDOW_LAST_LDTSTOP_ST;
			}
			break;
		case TX_CRC_WINDOW_LAST_LDTSTOP_ST:
			if(tx_consume_data.read())
				tx_crc_count = tx_crc_count.read()+1;

			if(tx_crc_count.read() == 15 && tx_consume_data.read()){
				tx_state = TX_SEND_LAST_CRC_LDTSTOP_ST;
				transmit_select = TX_SELECT_CRC;
			}
			break;
		case TX_SEND_LAST_CRC_LDTSTOP_ST:
			tx_crc_count = 0;

			if(tx_consume_data.read()){
				tx_state = TX_LDTSTOP_M64;
				transmit_select = TX_SELECT_DISCON;
			}
			else
				transmit_select = TX_SELECT_CRC;

			break;

		case TX_LDTSTOP_M64:
			transmit_select = TX_SELECT_DISCON;

			if(tx_consume_data.read())
				tx_crc_count = tx_crc_count.read()+1;

			if(tx_crc_count.read() == 63 && tx_consume_data.read()){
				tx_state = TX_LDTSTOP;
			}
			break;

		case TX_LDTSTOP:
			tx_crc_count = 0;
			new_tx_crc_window = true;
			//Must wait for RX to disconnect
			ldtstop_disconnect_tx = ldtstop_disconnect_rx;
			if(!ldtstopx.read()){
				tx_state = TX_LDTSTOP;
				transmit_select = TX_SELECT_DISCON;
			}
			else{
				tx_state = TX_FIRST_CRC_WINDOW_ST;
				transmit_select = TX_SELECT_DATA;
			}
			break;

		case TX_SYNC_ST:
			tx_crc_count = 0;
			tx_state = TX_SYNC_ST;
			transmit_select = TX_SELECT_SYNC;
			break;

		default: //case TX_FIRST_CRC_WINDOW_ST:
			if(tx_consume_data.read())
				tx_crc_count = tx_crc_count.read()+1;

			if(tx_crc_count.read() == 127 && tx_consume_data.read()){
				new_tx_crc_window = true;
				if(initiate_ldtstop_sequence)
					tx_state = TX_CRC_WINDOW_BEGIN_LDTSTOP_ST;
				else
					tx_state = TX_CRC_WINDOW_BEGIN_ST;
			}
			else if(initiate_ldtstop_sequence)
			{
				tx_state = TX_FIRST_CRC_WINDOW_LDTSTOP_ST;
			}
			break;
		}

		if(csr_sync.read()){
			tx_state = TX_SYNC_ST;
			transmit_select = TX_SELECT_SYNC;
		}
#ifdef RETRY_MODE_ENABLED
		//When the flow_control assert retry disconnect, just wait for the tx_framer to reconnect
		else if(fc_disconnect_lk.read()){
			tx_state = TX_FIRST_CRC_WINDOW_ST;
			tx_crc_count = 0;
			new_tx_crc_window = true;
		}
#endif
	}
}

void link_l2::evaluate_tx_crc_process(){
	if(!resetx.read()){
		tx_crc = 0xFFFFFFFF;
		tx_last_crc = 0;
	}
	else{
		//If we are in a state where we have to evaluate CRC when consuming data
		bool evaluate_tx_crc = lk_consume_fc.read();
		
		sc_bv<32> mod_cad_data;

		//Change the data when forcing bad CRC
		if(csr_crc_force_error_lk.read())
			mod_cad_data = 0x55555555;
		else
			mod_cad_data = 0;

		sc_bv<32> cad_to_crc = cad_to_frame.read() ^ mod_cad_data;

		sc_bv<36> d;
		d.range(7,0) = cad_to_crc.range(7,0);
		d[8] = lctl_to_frame.read();
		d.range(16,9) = cad_to_crc.range(15,8);
		d[17] = lctl_to_frame.read();
		d.range(25,18) = cad_to_crc.range(23,16);
		d[26] = hctl_to_frame.read();
		d.range(34,27) = cad_to_crc.range(31,24);
		d[35] = hctl_to_frame.read();

		sc_uint<32> crc_in;
		sc_uint<32> crc;
		if(new_tx_crc_window)
			crc_in = 0xFFFFFFFF;
		else
			crc_in = tx_crc.read();
			

		/*for (unsigned i=0; i<36; ++i) { 
			bool tmp = crc[31];  // store highest bit 

			// subtract poly if greater:
			crc[31] = crc[30];
			crc[30] = crc[29];
			crc[29] = crc[28];
			crc[28] = crc[27];
			crc[27] = crc[26];
			crc[26] = crc[25]^tmp;
			crc[25] = crc[24];
			crc[24] = crc[23];
			crc[23] = crc[22]^tmp;
			crc[22] = crc[21]^tmp;
			crc[21] = crc[20];
			crc[20] = crc[19];
			crc[19] = crc[18];
			crc[18] = crc[17];
			crc[17] = crc[16];
			crc[16] = crc[15]^tmp;
			crc[15] = crc[14];
			crc[14] = crc[13];
			crc[13] = crc[12];
			crc[12] = crc[11]^tmp;
			crc[11] = crc[10]^tmp;
			crc[10] = crc[9]^tmp;
			crc[9] = crc[8];
			crc[8] = crc[7]^tmp;
			crc[7] = crc[6]^tmp;
			crc[6] = crc[5];
			crc[5] = crc[4]^tmp;
			crc[4] = crc[3]^tmp;
			crc[3] = crc[2];
			crc[2] = crc[1]^tmp;
			crc[1] = crc[0]^tmp; 
			crc[0] = ((sc_bit)crc_data[i]) ^ tmp;
		}*/
		//Obtained with a slightly modified Xilinx Xapp209
		crc[0] = (sc_bit)(crc_in[2] ^ crc_in[20] ^ crc_in[12] ^ crc_in[21] ^ crc_in[5] ^ crc_in[30] ^ crc_in[22] ^ crc_in[6] ^ d[35] ^ crc_in[24] ^ crc_in[8] ^ d[3] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28]);
		crc[1] = (sc_bit)(crc_in[2] ^ crc_in[3] ^ crc_in[20] ^ crc_in[12] ^ crc_in[5] ^ crc_in[13] ^ crc_in[30] ^ crc_in[31] ^ d[34] ^ crc_in[23] ^ crc_in[7] ^ d[2] ^ crc_in[24] ^ crc_in[8] ^ d[3] ^ crc_in[9] ^ crc_in[29]);
		crc[2] = (sc_bit)(crc_in[3] ^ crc_in[20] ^ crc_in[5] ^ crc_in[13] ^ d[33] ^ crc_in[22] ^ crc_in[31] ^ d[2] ^ crc_in[9] ^ crc_in[26] ^ crc_in[28] ^ crc_in[2] ^ crc_in[10] ^ crc_in[4] ^ crc_in[12] ^ d[1] ^ crc_in[14] ^ d[3] ^ crc_in[27]);
		crc[3] = (sc_bit)(crc_in[3] ^ crc_in[11] ^ crc_in[13] ^ crc_in[5] ^ d[0] ^ d[2] ^ crc_in[15] ^ crc_in[28] ^ crc_in[10] ^ crc_in[4] ^ d[32] ^ crc_in[21] ^ crc_in[6] ^ d[1] ^ crc_in[14] ^ crc_in[23] ^ crc_in[27] ^ crc_in[29]);
		crc[4] = (sc_bit)(crc_in[11] ^ d[31] ^ crc_in[20] ^ d[0] ^ crc_in[7] ^ crc_in[15] ^ crc_in[26] ^ crc_in[0] ^ crc_in[2] ^ crc_in[4] ^ crc_in[21] ^ d[1] ^ crc_in[14] ^ d[3] ^ crc_in[8] ^ crc_in[16] ^ crc_in[25] ^ crc_in[27] ^ crc_in[29]);
		crc[5] = (sc_bit)(crc_in[3] ^ crc_in[20] ^ d[0] ^ d[2] ^ crc_in[15] ^ crc_in[24] ^ crc_in[9] ^ crc_in[17] ^ crc_in[0] ^ crc_in[2] ^ d[30] ^ crc_in[6] ^ d[3] ^ crc_in[16] ^ crc_in[25] ^ crc_in[1]);
		crc[6] = (sc_bit)(crc_in[3] ^ d[2] ^ crc_in[7] ^ crc_in[17] ^ crc_in[26] ^ crc_in[0] ^ crc_in[2] ^ crc_in[10] ^ crc_in[4] ^ crc_in[21] ^ d[1] ^ crc_in[16] ^ crc_in[25] ^ d[29] ^ crc_in[18] ^ crc_in[1]);
		crc[7] = (sc_bit)(crc_in[11] ^ crc_in[3] ^ crc_in[20] ^ d[0] ^ crc_in[24] ^ d[28] ^ crc_in[17] ^ crc_in[19] ^ crc_in[28] ^ crc_in[4] ^ crc_in[12] ^ crc_in[21] ^ crc_in[30] ^ crc_in[6] ^ d[1] ^ d[3] ^ crc_in[25] ^ crc_in[18] ^ crc_in[1]);
		crc[8] = (sc_bit)(d[0] ^ crc_in[13] ^ crc_in[31] ^ crc_in[7] ^ d[2] ^ crc_in[24] ^ crc_in[19] ^ crc_in[28] ^ crc_in[0] ^ crc_in[4] ^ crc_in[30] ^ crc_in[6] ^ d[27] ^ d[3] ^ crc_in[8] ^ crc_in[18] ^ crc_in[27] ^ crc_in[29]);
		crc[9] = (sc_bit)(crc_in[20] ^ crc_in[5] ^ crc_in[31] ^ d[26] ^ d[2] ^ crc_in[7] ^ crc_in[9] ^ crc_in[19] ^ crc_in[28] ^ crc_in[0] ^ crc_in[30] ^ d[1] ^ crc_in[14] ^ crc_in[8] ^ crc_in[25] ^ crc_in[29] ^ crc_in[1]);
		crc[10] = (sc_bit)(d[0] ^ crc_in[5] ^ crc_in[22] ^ crc_in[31] ^ crc_in[15] ^ crc_in[24] ^ crc_in[9] ^ crc_in[28] ^ crc_in[10] ^ crc_in[12] ^ d[25] ^ d[1] ^ d[3] ^ crc_in[25] ^ crc_in[27] ^ crc_in[29] ^ crc_in[1]);
		crc[11] = (sc_bit)(crc_in[11] ^ crc_in[20] ^ d[24] ^ d[0] ^ crc_in[5] ^ crc_in[13] ^ crc_in[22] ^ d[2] ^ crc_in[24] ^ crc_in[0] ^ crc_in[10] ^ crc_in[12] ^ crc_in[21] ^ crc_in[23] ^ d[3] ^ crc_in[8] ^ crc_in[16] ^ crc_in[27] ^ crc_in[29]);
		crc[12] = (sc_bit)(crc_in[11] ^ crc_in[20] ^ crc_in[5] ^ crc_in[13] ^ d[2] ^ crc_in[9] ^ crc_in[17] ^ crc_in[26] ^ crc_in[0] ^ crc_in[2] ^ d[23] ^ d[1] ^ crc_in[14] ^ crc_in[23] ^ d[3] ^ crc_in[8] ^ crc_in[27] ^ crc_in[1]);
		crc[13] = (sc_bit)(d[22] ^ crc_in[3] ^ d[0] ^ d[2] ^ crc_in[15] ^ crc_in[24] ^ crc_in[9] ^ crc_in[28] ^ crc_in[2] ^ crc_in[10] ^ crc_in[12] ^ crc_in[21] ^ crc_in[6] ^ d[1] ^ crc_in[14] ^ crc_in[18] ^ crc_in[27] ^ crc_in[1]);
		crc[14] = (sc_bit)(crc_in[3] ^ crc_in[11] ^ d[0] ^ crc_in[13] ^ crc_in[22] ^ crc_in[7] ^ crc_in[15] ^ crc_in[19] ^ crc_in[28] ^ crc_in[0] ^ d[21] ^ crc_in[2] ^ crc_in[10] ^ crc_in[4] ^ d[1] ^ crc_in[16] ^ crc_in[25] ^ crc_in[29]);
		crc[15] = (sc_bit)(crc_in[3] ^ crc_in[11] ^ crc_in[20] ^ crc_in[5] ^ d[0] ^ crc_in[17] ^ crc_in[26] ^ crc_in[0] ^ crc_in[4] ^ crc_in[12] ^ crc_in[30] ^ crc_in[14] ^ crc_in[23] ^ crc_in[8] ^ crc_in[16] ^ crc_in[29] ^ d[20] ^ crc_in[1]);
		crc[16] = (sc_bit)(crc_in[20] ^ crc_in[13] ^ crc_in[22] ^ crc_in[31] ^ crc_in[15] ^ d[19] ^ crc_in[9] ^ crc_in[17] ^ crc_in[26] ^ crc_in[28] ^ crc_in[0] ^ crc_in[4] ^ d[3] ^ crc_in[8] ^ crc_in[25] ^ crc_in[18] ^ crc_in[1]);
		crc[17] = (sc_bit)(crc_in[5] ^ d[2] ^ crc_in[9] ^ crc_in[26] ^ crc_in[19] ^ crc_in[2] ^ crc_in[10] ^ crc_in[21] ^ crc_in[14] ^ crc_in[23] ^ d[18] ^ crc_in[16] ^ crc_in[18] ^ crc_in[27] ^ crc_in[29] ^ crc_in[1]);
		crc[18] = (sc_bit)(crc_in[11] ^ crc_in[3] ^ crc_in[20] ^ crc_in[22] ^ d[17] ^ crc_in[15] ^ crc_in[24] ^ crc_in[17] ^ crc_in[19] ^ crc_in[28] ^ crc_in[2] ^ crc_in[10] ^ crc_in[30] ^ d[1] ^ crc_in[6] ^ crc_in[27]);
		crc[19] = (sc_bit)(crc_in[3] ^ crc_in[11] ^ crc_in[20] ^ d[0] ^ crc_in[31] ^ crc_in[7] ^ crc_in[28] ^ crc_in[12] ^ crc_in[4] ^ crc_in[21] ^ d[16] ^ crc_in[23] ^ crc_in[16] ^ crc_in[25] ^ crc_in[18] ^ crc_in[29]);
		crc[20] = (sc_bit)(d[15] ^ crc_in[13] ^ crc_in[5] ^ crc_in[22] ^ crc_in[24] ^ crc_in[17] ^ crc_in[26] ^ crc_in[19] ^ crc_in[0] ^ crc_in[4] ^ crc_in[12] ^ crc_in[21] ^ crc_in[30] ^ crc_in[8] ^ crc_in[29]);
		crc[21] = (sc_bit)(crc_in[20] ^ crc_in[5] ^ crc_in[13] ^ crc_in[22] ^ crc_in[31] ^ crc_in[9] ^ d[14] ^ crc_in[30] ^ crc_in[14] ^ crc_in[6] ^ crc_in[23] ^ crc_in[25] ^ crc_in[18] ^ crc_in[27] ^ crc_in[1]);
		crc[22] = (sc_bit)(d[13] ^ crc_in[20] ^ crc_in[5] ^ crc_in[22] ^ crc_in[31] ^ crc_in[15] ^ crc_in[7] ^ crc_in[19] ^ crc_in[10] ^ crc_in[12] ^ crc_in[30] ^ crc_in[14] ^ crc_in[23] ^ d[3] ^ crc_in[8] ^ crc_in[25] ^ crc_in[27]);
		crc[23] = (sc_bit)(crc_in[11] ^ crc_in[5] ^ crc_in[13] ^ crc_in[22] ^ crc_in[31] ^ d[2] ^ crc_in[15] ^ crc_in[9] ^ d[12] ^ crc_in[2] ^ crc_in[12] ^ crc_in[30] ^ crc_in[23] ^ d[3] ^ crc_in[16] ^ crc_in[25] ^ crc_in[27]);
		crc[24] = (sc_bit)(crc_in[3] ^ crc_in[13] ^ crc_in[31] ^ d[2] ^ crc_in[24] ^ crc_in[17] ^ crc_in[26] ^ crc_in[28] ^ crc_in[10] ^ crc_in[12] ^ crc_in[6] ^ d[1] ^ crc_in[14] ^ crc_in[23] ^ crc_in[16] ^ d[11]);
		crc[25] = (sc_bit)(crc_in[11] ^ d[0] ^ crc_in[13] ^ crc_in[7] ^ crc_in[15] ^ crc_in[24] ^ crc_in[17] ^ d[10] ^ crc_in[4] ^ d[1] ^ crc_in[14] ^ crc_in[25] ^ crc_in[18] ^ crc_in[27] ^ crc_in[29]);
		crc[26] = (sc_bit)(crc_in[20] ^ d[0] ^ crc_in[22] ^ crc_in[15] ^ crc_in[24] ^ crc_in[19] ^ crc_in[0] ^ crc_in[2] ^ crc_in[21] ^ crc_in[6] ^ crc_in[14] ^ d[3] ^ crc_in[16] ^ crc_in[18] ^ crc_in[27] ^ d[9]);
		crc[27] = (sc_bit)(crc_in[3] ^ crc_in[20] ^ crc_in[22] ^ d[2] ^ crc_in[7] ^ crc_in[15] ^ crc_in[17] ^ crc_in[19] ^ crc_in[28] ^ d[8] ^ crc_in[0] ^ crc_in[21] ^ crc_in[23] ^ crc_in[16] ^ crc_in[25] ^ crc_in[1]);
		crc[28] = (sc_bit)(crc_in[20] ^ crc_in[22] ^ crc_in[24] ^ crc_in[17] ^ crc_in[26] ^ crc_in[2] ^ crc_in[4] ^ crc_in[21] ^ d[1] ^ crc_in[23] ^ crc_in[8] ^ crc_in[16] ^ crc_in[18] ^ d[7] ^ crc_in[29] ^ crc_in[1]);
		crc[29] = (sc_bit)(crc_in[3] ^ crc_in[5] ^ d[0] ^ crc_in[22] ^ crc_in[24] ^ crc_in[9] ^ crc_in[17] ^ crc_in[19] ^ d[6] ^ crc_in[2] ^ crc_in[21] ^ crc_in[30] ^ crc_in[23] ^ crc_in[25] ^ crc_in[18] ^ crc_in[27]);
		crc[30] = (sc_bit)(crc_in[3] ^ crc_in[20] ^ crc_in[22] ^ crc_in[31] ^ crc_in[24] ^ crc_in[26] ^ crc_in[19] ^ crc_in[28] ^ crc_in[0] ^ crc_in[10] ^ crc_in[4] ^ crc_in[6] ^ crc_in[23] ^ crc_in[25] ^ crc_in[18] ^ d[5]);
		crc[31] = (sc_bit)(crc_in[11] ^ crc_in[20] ^ crc_in[5] ^ crc_in[7] ^ crc_in[24] ^ d[4] ^ crc_in[26] ^ crc_in[19] ^ crc_in[4] ^ crc_in[21] ^ crc_in[23] ^ crc_in[25] ^ crc_in[27] ^ crc_in[29] ^ crc_in[1]);
			
		if(evaluate_tx_crc)
			tx_crc = crc; 
		else if(new_tx_crc_window)
			tx_crc = 0xFFFFFFFF;

		if(new_tx_crc_window)
			tx_last_crc = tx_crc;		
	}
}

void link_l2::select_output(){

	sc_uint<32> discon_nop = 0x0000020;
	sc_uint<32> sync_pkt = 0xFFFFFFFF;

	switch(transmit_select.read()){
	case TX_SELECT_CRC:
		cad_to_frame = ~tx_last_crc.read();
		lctl_to_frame = true;
		hctl_to_frame = true;
		lk_consume_fc = false;
#ifdef RETRY_MODE_ENABLED
		tx_retry_disconnect = false;
#endif
		break;
	case TX_SELECT_DISCON:
		cad_to_frame = discon_nop;
		lctl_to_frame = true;
		hctl_to_frame = true;
		lk_consume_fc = false;
#ifdef RETRY_MODE_ENABLED
		tx_retry_disconnect = false;
#endif
		break;
	case TX_SELECT_SYNC:
		cad_to_frame = sync_pkt;
		lctl_to_frame = true;
		hctl_to_frame = true;
		lk_consume_fc = false;
#ifdef RETRY_MODE_ENABLED
		tx_retry_disconnect = false;
#endif
		break;
	default: //case TX_SELECT_DATA:
		cad_to_frame = fc_dword_lk.read();
		lctl_to_frame = fc_lctl_lk.read();
		hctl_to_frame = fc_hctl_lk.read();
		lk_consume_fc = tx_consume_data.read();
#ifdef RETRY_MODE_ENABLED
		tx_retry_disconnect = fc_disconnect_lk;
#endif
	}
}

void link_l2::output_framed_data(){
	lk_available_cd = framed_data_available.read() && framed_data_ready.read();
}

void link_l2::output_ldtstop_disconnected(){
	lk_ldtstop_disconnected = ldtstop_disconnect_tx;
}

