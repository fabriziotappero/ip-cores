//link_frame_tx_l3.cpp
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
#include "link_frame_tx_l3.h"


link_frame_tx_l3::link_frame_tx_l3( sc_module_name name) : sc_module(name) {

	SC_METHOD(state_machine);
	sensitive_pos(clk);
	sensitive_neg(resetx);

	SC_METHOD(generate_consume_data);
	sensitive << phy_consume_lk << consume_if_can_output;

	SC_METHOD(reorder_output);
	sensitive << cad_to_frame << lctl_to_frame << hctl_to_frame
			<< init_cad_value << init_ctl_value 
			<< select_value_1_0 << select_value_3_2 << select_value_7_4
			<< tx_link_width_encoded;

	SC_METHOD(encode_link_width);
	sensitive << csr_tx_link_width_lk;
}


void link_frame_tx_l3::state_machine(){
	//default value
	disable_drivers = false;
	
	//Values that the registers take at reset
	if(!resetx.read()){
		state = TX_FRAME_INACTIVE_ST;
		counter = 0;
		init_cad_value = true;
		init_ctl_value = false;
		consume_if_can_output = false;
		ldtstop_sequence_detected = false;

		select_value_1_0 = LINK_OUTPUT1_0_INIT;
#if CAD_OUT_WIDTH >= 4
		select_value_3_2 = LINK_OUTPUT3_2_INIT;
#endif
#if CAD_OUT_WIDTH == 8
		select_value_7_4 = LINK_OUTPUT7_4_INIT;
#endif
	}
	else{
		/* This was done initially but it is wrong :
		retry_disconnect = cd_initiate_retry_disconnect.read() ||
			tx_retry_disconnect.read() || lk_initiate_retry_disconnect.read();
		
		Only rely on the Flow Control to disconnect the TX side because a disconnect
		nop must be sent.  This way, we're assured that the disconnect NOP is sent
		*/

		//default value
		consume_if_can_output = false;
		select_value_1_0 = LINK_OUTPUT1_0_INIT;
		select_value_7_4 = LINK_OUTPUT7_4_INIT;
		select_value_3_2 = LINK_OUTPUT3_2_INIT;

		//Lower two bit of counter allows to select what to output
		sc_uint<2> selection_counter_value = counter.read().range(1,0);


		switch(state){

		//Part of the init phase
		case TX_FRAME_INIT_ACTIVATE_CTL_ST:

			//Both CAD and CTL are activated
			init_cad_value = true;
			init_ctl_value = true;

			//If ldtstop detected, stop the init sequence.  After this state, the ldtstop will be ignore
			//until the link is fully active
			if(!ldtstopx.read() || csr_end_of_chain.read() || csr_transmitter_off_lk.read()){
				state = TX_FRAME_LDTSTOP_DISCONNECT_ST;
			}
			/*For for RX to have CTL active before going for next step
			  Lasts for a minimum of 16 bit-times(8 bit), 32 for 4-bit and 64 for 2-bit
			  which is equal to 128/CAD_OUT_WIDTH.  After an ldtstop sequence and if
			  the extented_ctl bit in the CSR is active, we must wait 50 us.
			*/
			else if((counter.read() == (128/CAD_OUT_WIDTH) && 
					(!csr_extented_ctl_lk.read() || !ldtstop_sequence_detected.read()) ||
					 counter.read() == NUMBER_CYCLES_50_US)
				&& phy_consume_lk.read()){
				counter = 0;
				state = TX_FRAME_INIT_DISABLE_CTL_CAD_CT_ST;
				init_cad_value = false;
				init_ctl_value = false;
			}
			//Increase the counter if data is read and we're not simply waiting for CTL
			else if(phy_consume_lk.read() && !rx_waiting_for_ctl_tx.read()){
				counter = counter.read() + 1;
				state = TX_FRAME_INIT_ACTIVATE_CTL_ST;
			}
			else{
				counter = counter.read();
				state = TX_FRAME_INIT_ACTIVATE_CTL_ST;
			}
			break;

		//Part of the init phase
		case TX_FRAME_INIT_DISABLE_CTL_CAD_CT_ST:
			//Both CTL and CAD are driven to 0
			init_cad_value = false;
			init_ctl_value = false;
			ldtstop_sequence_detected = false;
			if(phy_consume_lk.read() && 
			/**
				This next #if #elif is to speed up reconnection when 8 bit link is
				detected.  The code could simply by counter.read() == 511 and it would
				be valid.  It would just mean a longer time to reconnect since it can
				be done in 128 cycles in many cases.
			*/
#if CAD_OUT_WIDTH == 8
				 (counter.read() == 511 && tx_link_width_encoded.read() == LINK_2_BIT ||
				  counter.read() == 255 && tx_link_width_encoded.read() == LINK_4_BIT ||
				  counter.read() == 127 && tx_link_width_encoded.read() == LINK_8_BIT)
#elif CAD_OUT_WIDTH == 4
				 (counter.read() == 255 && tx_link_width_encoded.read() == LINK_2_BIT ||
				  counter.read() == 127 && tx_link_width_encoded.read() == LINK_4_BIT)
#else
				  counter.read() == 127)
#endif
			){
				counter = 0;
				state = TX_FRAME_INIT_ACTIVATE_CAD_ST;
				init_cad_value = true;
				init_ctl_value = false;
			}
			else if(phy_consume_lk.read()){
				counter = counter.read() + 1;
				state = TX_FRAME_INIT_DISABLE_CTL_CAD_CT_ST;
			}
			else{
				counter = counter.read();
				state = TX_FRAME_INIT_DISABLE_CTL_CAD_CT_ST;
			}
			break;

		//Part of the init phase
		case TX_FRAME_INIT_ACTIVATE_CAD_ST:
			//Drive CAD to 1 and CTL to 0
			init_cad_value = true;
			init_ctl_value = false;

			/**
				In this case, we need to send a SINGLE dword.  Check the counter and phy_consume_lk
				to know when it is done.
			*/
#if CAD_OUT_WIDTH == 8
			if(phy_consume_lk.read() &&
			( (counter.read() == 3 && tx_link_width_encoded.read() == LINK_2_BIT) ||
			  (counter.read() == 1 && tx_link_width_encoded.read() == LINK_4_BIT) ||
			  (tx_link_width_encoded.read() == LINK_8_BIT) ) )
#elif CAD_OUT_WIDTH == 4
			if(phy_consume_lk.read() &&
			( (counter.read() == 1 && tx_link_width_encoded.read() == LINK_2_BIT) ||
			  (tx_link_width_encoded.read() == LINK_4_bit) ) )
#else
			//On a 2 bit link, a single consumption from the phy
			//represents the full required 16 bit times
			if(phy_consume_lk.read())
#endif
			{
				//reset counter
				counter = 0;
				//go to active state
				state = TX_FRAME_ACTIVE_ST;

				/**
					Depending on the PHYSICAL link width (pre-compiler) and actual
					link width (dynamic), determine what to output.
				*/
#if CAD_OUT_WIDTH == 8
				consume_if_can_output = tx_link_width_encoded.read() == LINK_8_BIT;
				switch(tx_link_width_encoded.read()){
				case LINK_2_BIT:
					select_value_1_0 = LINK_OUTPUT1_0_2BIT_CYCLE1;
					break;
				case LINK_4_BIT:
					select_value_1_0 = LINK_OUTPUT1_0_4BIT_CYCLE1;
					select_value_3_2 = LINK_OUTPUT3_2_4BIT_CYCLE1;
					break;
				//case LINK_8_BIT
				default:
					select_value_1_0 = LINK_OUTPUT1_0_8BIT;
					select_value_3_2 = LINK_OUTPUT3_2_8BIT;
					select_value_7_4 = LINK_OUTPUT7_4_8BIT;
				}
#elif CAD_OUT_WIDTH == 4
				consume_if_can_output = tx_link_width_encoded.read() == LINK_2_BIT;
				switch(tx_link_width_encoded.read()){
				case LINK_2_BIT:
					select_value_1_0 = LINK_OUTPUT1_0_2BIT_CYCLE1;
					break;
				//case LINK_4_BIT:
				default:
					select_value_1_0 = LINK_OUTPUT1_0_4BIT_CYCLE1;
					select_value_3_2 = LINK_OUTPUT3_2_4BIT_CYCLE1;
					break;
				}
#else
				consume_if_can_output = true;
				select_value_1_0 = LINK_OUTPUT1_0_2BIT_CYCLE1;
#endif
			}
			else if(phy_consume_lk.read()){
				counter = counter.read() + 1;
				state = TX_FRAME_INIT_ACTIVATE_CAD_ST;
			}
			else{
				counter = counter.read();
				state = TX_FRAME_INIT_ACTIVATE_CAD_ST;
			}
			break;

		//Normal operation state
		case TX_FRAME_ACTIVE_ST:
			//Default values
			counter = counter.read();
			init_cad_value = false;
			init_ctl_value = false;

			/**
				Check if the link must be stoped.  In the case of the csr_transmitter_off_lk, go immediately
				to the LDSTOP state.  If in a real LDTSTOP, wait for the PHY layer to read the dword
				that is currently being sent, THEN stop.

				csr_end_of_chain is not included in the if because once connected, we must not simply
				disconnect or the other side will see garbage.  If ever we disconnect while
				csr_end_of_chain is active though, then simply never reconnect.
			*/
			if( csr_transmitter_off_lk.read() || ldtstop_disconnect_tx.read() && phy_consume_lk.read()
#if CAD_OUT_WIDTH == 8
				&& ((tx_link_width_encoded.read() == LINK_8_BIT) ||
					(tx_link_width_encoded.read() == LINK_4_BIT && counter.read()[0]) ||
					(tx_link_width_encoded.read() == LINK_2_BIT && counter.read() == 3))
#elif CAD_OUT_WIDTH == 4
				&& ((tx_link_width_encoded.read() == LINK_4_BIT) ||
					(tx_link_width_encoded.read() == LINK_2_BIT && counter.read()[0]))
#endif
				)
			{
				state = TX_FRAME_LDTSTOP_DISCONNECT_ST;
				init_cad_value = true;
				init_ctl_value = false;
			}
#ifdef RETRY_MODE_ENABLED
			/**
				Also check for retry sequence, only if the retry mode is present.  Just like the
				ldtstop sequence, wait for the current dword to be sent before going to the
				disconnect state
			*/
			else if(tx_retry_disconnect.read() && phy_consume_lk.read()
#if CAD_OUT_WIDTH == 8
				&& ((tx_link_width_encoded.read() == LINK_8_BIT) ||
					(tx_link_width_encoded.read() == LINK_4_BIT && counter.read()[0]) ||
					(tx_link_width_encoded.read() == LINK_2_BIT && counter.read() == 3))
#elif CAD_OUT_WIDTH == 4
				&& ((tx_link_width_encoded.read() == LINK_4_BIT) ||
					(tx_link_width_encoded.read() == LINK_2_BIT && counter.read()[0]))
#endif
				)
			{
				state = TX_FRAME_RETRY_DISCONNECT_ST;
			}
#endif
			//Under normal condition, stay in the active state
			else{
				state = TX_FRAME_ACTIVE_ST;
			}

			//Increase counter when PHY consumes data
			if(phy_consume_lk.read()){
				counter = counter.read() + 1;
			}
			else{
				counter = counter.read();
			}

			/**
				This part selects what to output in function of the PHYSICAL link width.  There
				is three precompiler section for the three possible physical widths : 8-bit,
				4-bit and 2-bit.

				Then, it depends on the actual link width, on the current counter value and if
				the PHY layer cnousmes the data
			*/
#if CAD_OUT_WIDTH == 8
			switch(tx_link_width_encoded.read()){
			case LINK_8_BIT:
				//If we can output the data, we want to also get new
				//data from the flowcontrol
				consume_if_can_output = true;
				select_value_1_0 = LINK_OUTPUT1_0_8BIT;
				select_value_3_2 = LINK_OUTPUT3_2_8BIT;
				select_value_7_4 = LINK_OUTPUT7_4_8BIT;
				break;
			case LINK_4_BIT:
				//Unused bits are driven to 0
				select_value_7_4 = LINK_OUTPUT7_4_INIT;

				if(selection_counter_value[0] == phy_consume_lk.read()){
					select_value_1_0 = LINK_OUTPUT1_0_4BIT_CYCLE1;
					select_value_3_2 = LINK_OUTPUT3_2_4BIT_CYCLE1;
				}
				else{
					consume_if_can_output = true;
					select_value_1_0 = LINK_OUTPUT1_0_4BIT_CYCLE2;
					select_value_3_2 = LINK_OUTPUT3_2_4BIT_CYCLE2;
				}
				break;
			case LINK_2_BIT:
			{
				//Unused bits are driven to 0
				select_value_3_2 = LINK_OUTPUT3_2_INIT;
				select_value_7_4 = LINK_OUTPUT7_4_INIT;

				sc_uint<3> bit_link_selector;
				bit_link_selector.range(1,0) = selection_counter_value;
				bit_link_selector[2] = phy_consume_lk.read();
				switch(bit_link_selector){
				//Cases when Consume is false
				case 0:
					select_value_1_0 = LINK_OUTPUT1_0_2BIT_CYCLE1;
					break;
				case 1:
					select_value_1_0 = LINK_OUTPUT1_0_2BIT_CYCLE2;
					break;
				case 2:
					select_value_1_0 = LINK_OUTPUT1_0_2BIT_CYCLE3;
					break;
				case 3:
					select_value_1_0 = LINK_OUTPUT1_0_2BIT_CYCLE4;
					consume_if_can_output = true;
					break;

				//Cases when Consume is true
				case 4:
					select_value_1_0 = LINK_OUTPUT1_0_2BIT_CYCLE2;
					break;
				case 5:
					select_value_1_0 = LINK_OUTPUT1_0_2BIT_CYCLE3;
					break;
				case 6:
					consume_if_can_output = true;
					select_value_1_0 = LINK_OUTPUT1_0_2BIT_CYCLE4;
					break;
				case 7:
					select_value_1_0 = LINK_OUTPUT1_0_2BIT_CYCLE1;
					break;

				}
				break;
			}
			default: // INVALID_LINK_WIDTH:
				select_value_1_0 = LINK_OUTPUT1_0_INIT;
				select_value_3_2 = LINK_OUTPUT3_2_INIT;
				select_value_7_4 = LINK_OUTPUT7_4_INIT;
				break;
			}
#elif CAD_OUT_WIDTH == 4
			switch(tx_link_width_encoded.read()){
			case LINK_4_BIT:
				consume_if_can_output = true;
				select_value_1_0 = LINK_OUTPUT1_0_4BIT_CYCLE1;
				select_value_3_2 = LINK_OUTPUT3_2_4BIT_CYCLE1;
				break;
			case LINK_2_BIT:
				select_value_7_4 = LINK_OUTPUT7_4_INIT;
				if(counter.read()[0] == phy_consume_lk.read()){
					select_value_1_0 = LINK_OUTPUT1_0_2BIT_CYCLE1;
					select_value_3_2 = LINK_OUTPUT3_2_2BIT_CYCLE1;
				}
				else{
					consume_if_can_output = true;
					select_value_1_0 = LINK_OUTPUT1_0_2BIT_CYCLE2;
					select_value_3_2 = LINK_OUTPUT3_2_2BIT_CYCLE2;
				}
				break;
			default: // INVALID_LINK_WIDTH:
				select_value_1_0 = LINK_OUTPUT1_0_INIT;
				select_value_3_2 = LINK_OUTPUT3_2_INIT;
				break;
			}

#else
			switch(tx_link_width_encoded.read()){
			case LINK_2_BIT:
				consume_if_can_output = true;
				select_value_1_0 = LINK_OUTPUT1_0_2BIT_CYCLE1;
				break;
			default: // INVALID_LINK_WIDTH:
				select_value_1_0 = LINK_OUTPUT1_0_INIT;
				break;
			}
#endif

			break;

#ifdef RETRY_MODE_ENABLED
		/**
			In retry mode, we simply maintain warm reset signaling for 1 us and then reconnect
			as normal
		*/
		case TX_FRAME_RETRY_DISCONNECT_ST:
			counter = counter.read() + 1;

			//warm reset signaling
			init_cad_value = true;
			init_ctl_value = false;

			//Go to ldtstopx if it is initiated
			if(ldtstop_disconnect_tx.read() || csr_end_of_chain.read() || csr_transmitter_off_lk.read()){
				state = TX_FRAME_LDTSTOP_DISCONNECT_ST;
			}
			//Otherwise, wait 1us
			else if(counter.read() == NUMBER_CYCLES_1_US){
				state = TX_FRAME_INACTIVE_ST;
			}
			else{
				state = TX_FRAME_RETRY_DISCONNECT_ST;
			}
			break;
#endif
		//Wait here during ldtstop sequence
		case TX_FRAME_LDTSTOP_DISCONNECT_ST:
			//Stay in this state while ldtstop is asserted or the transmitter is off, or
			//csr_end_of_chain
			if(ldtstop_disconnect_tx.read() || 
				csr_end_of_chain.read() ||
				!ldtstopx.read() || csr_transmitter_off_lk.read())
			{
				state = TX_FRAME_LDTSTOP_DISCONNECT_ST;
			}
#ifdef RETRY_MODE_ENABLED
			else if(tx_retry_disconnect.read()){
				state = TX_FRAME_RETRY_DISCONNECT_ST;
			}
#endif
			else{
				state = TX_FRAME_INACTIVE_ST;
			}
			counter = 0;
			init_cad_value = false;
			init_ctl_value = false;

			//Log that there was a ldtstop sequence
			ldtstop_sequence_detected = true;

			//Only disable the drivers if in ldtstopx sequence and allowed to go tristate during
			//that sequence or if csr_transmitter_off_lk has been set in the CSR
			disable_drivers = !ldtstopx.read() && csr_ldtstop_tristate_enable_lk.read() || 
					csr_transmitter_off_lk.read();
			break;

		//case TX_FRAME_INACTIVE_ST:
		default:
			init_cad_value = true;
			init_ctl_value = false;
			
			if(ldtstop_disconnect_tx.read() || csr_end_of_chain.read() || csr_transmitter_off_lk.read()){
				state = TX_FRAME_LDTSTOP_DISCONNECT_ST;
			}
#ifdef RETRY_MODE_ENABLED
			else if(tx_retry_disconnect.read()){
				state = TX_FRAME_RETRY_DISCONNECT_ST;
			}
#endif
			else{
				state = TX_FRAME_INIT_ACTIVATE_CTL_ST;
				init_cad_value = true;
				init_ctl_value = true;
			}
			counter = 0;
		}
	}
}



void link_frame_tx_l3::reorder_output(){
	/**
		First step is to statically reorder bits
		Just wire renaming, no logic involved.  It greatly facilitate
		selection of vectors later on.
	
		Let's say we have an 8 bit width : what will be sent out on the link
		is dword[7..0], then dword[15..8], then dword[23..16], then finally dword[31..24]
		But since this is sent to a serializer, there is 8 outputs.  output0 will contain:
		dword[0],dword[8],dword[16] and dword[24].  This reordering groups those bits together

		The same principle is used for the different link widths and depths
	*/

	sc_bv<32> reordered_cad_2bit;
#if CAD_OUT_WIDTH > 2
	sc_bv<32> reordered_cad_4bit;
#if CAD_OUT_WIDTH > 4
	sc_bv<32> reordered_cad_8bit;

	//Represents the depth
	for(int n = 0; n < 4; n++){
		//Represents the width
		for(int x = 0; x < 2; x++){
			//Represents the cycle
			for(int y = 0; y < 4; y++){
				reordered_cad_2bit[y*8 + 4*x + n] = (sc_bit)cad_to_frame.read()[8 * y + 2*n + x];
			}
		}
	}

	//Represents the depth
	for(int n = 0; n < 4; n++){
		//Represents the width
		for(int x = 0; x < 4; x++){
			//Represents the cycle
			for(int y = 0; y < 2; y++){
				reordered_cad_4bit[y*16 + 4*x+n] = (sc_bit)cad_to_frame.read()[16 * y + 4*n + x];
			}
		}
	}

	for(int n = 0; n < 4; n++){
		for(int x = 0; x < 8;x++){
			reordered_cad_8bit[4*x+n] = (sc_bit)cad_to_frame.read()[8*n+x];
		}
	}

#else
	//Represents the depth
	for(int n = 0; n < 8; n++){
		//Represents the width
		for(int x = 0; x < 2; x++){
			//Represents the cycle
			for(int y = 0; y < 2; y++){
				reordered_cad_2bit[y*16 + 8*x + n] = (sc_bit)cad_to_frame.read()[16 * y + 2*n + x];
			}
		}
	}
	break;
	//Represents the depth
	for(int n = 0; n < 8; n++){
		//Represents the width
		for(int x = 0; x < 4; x++){
			reordered_cad_4bit[8*x + n] = (sc_bit)cad_to_frame.read()[8*n + x];
		}
	}

#endif
#else

	for(int n = 0; n < 16; n++){
		reordered_cad_2bit[n] = (sc_bit)cad_to_frame.read()[2*n];
		reordered_cad_2bit[16+n] = (sc_bit)cad_to_frame.read()[2*n+1];
	}
#endif

	sc_bv<CAD_OUT_DEPTH> init_cad;
	for(int n = 0; n < CAD_OUT_DEPTH; n++){
		init_cad[n] = init_cad_value;
	}

	//Now that we have a vector which is ordered in a way that
	//bit vectors can easily be selected, we use multiplexors
	//to select the appropriate signals, depending on what was selected
	//in the state machine

	//Select the correct output for the two least significant outputs
	switch(select_value_1_0.read()){
	case LINK_OUTPUT1_0_2BIT_CYCLE1:
		lk_cad_phy[0] = reordered_cad_2bit.range(CAD_OUT_DEPTH-1,0);
		lk_cad_phy[1] = reordered_cad_2bit.range(2*CAD_OUT_DEPTH-1,CAD_OUT_DEPTH);
		break;

#if CAD_OUT_WIDTH > 2
	case LINK_OUTPUT1_0_4BIT_CYCLE1:
		lk_cad_phy[0] = reordered_cad_4bit.range(CAD_OUT_DEPTH-1,0);
		lk_cad_phy[1] = reordered_cad_4bit.range(2*CAD_OUT_DEPTH-1,CAD_OUT_DEPTH);
		break;
	case LINK_OUTPUT1_0_2BIT_CYCLE2:
		lk_cad_phy[0] = reordered_cad_2bit.range(3*CAD_OUT_DEPTH-1,2*CAD_OUT_DEPTH);
		lk_cad_phy[1] = reordered_cad_2bit.range(4*CAD_OUT_DEPTH-1,3*CAD_OUT_DEPTH);
		break;
#if CAD_OUT_WIDTH > 4
	case LINK_OUTPUT1_0_8BIT:
		lk_cad_phy[0] = reordered_cad_8bit.range(CAD_OUT_DEPTH-1,0);
		lk_cad_phy[1] = reordered_cad_8bit.range(2*CAD_OUT_DEPTH-1,CAD_OUT_DEPTH);
		break;
	case LINK_OUTPUT1_0_4BIT_CYCLE2:
		lk_cad_phy[0] = reordered_cad_4bit.range(5*CAD_OUT_DEPTH-1,4*CAD_OUT_DEPTH);
		lk_cad_phy[1] = reordered_cad_4bit.range(6*CAD_OUT_DEPTH-1,5*CAD_OUT_DEPTH);
		break;
	case LINK_OUTPUT1_0_2BIT_CYCLE3:
		lk_cad_phy[0] = reordered_cad_2bit.range(5*CAD_OUT_DEPTH-1,4*CAD_OUT_DEPTH);
		lk_cad_phy[1] = reordered_cad_2bit.range(6*CAD_OUT_DEPTH-1,5*CAD_OUT_DEPTH);
		break;
	case LINK_OUTPUT1_0_2BIT_CYCLE4:
		lk_cad_phy[0] = reordered_cad_2bit.range(7*CAD_OUT_DEPTH-1,6*CAD_OUT_DEPTH);
		lk_cad_phy[1] = reordered_cad_2bit.range(8*CAD_OUT_DEPTH-1,7*CAD_OUT_DEPTH);
		break;
#endif
#endif
		
	default: //case LINK_OUTPUT1_0_INIT:
		lk_cad_phy[0] = init_cad;
		lk_cad_phy[1] = init_cad;

	}


#if CAD_OUT_WIDTH > 2
	//Select the correct output for the outpus 3 and 2
	switch(select_value_3_2.read()){
	case LINK_OUTPUT3_2_4BIT_CYCLE1:
		lk_cad_phy[2] = reordered_cad_4bit.range(3*CAD_OUT_DEPTH-1,2*CAD_OUT_DEPTH);
		lk_cad_phy[3] = reordered_cad_4bit.range(4*CAD_OUT_DEPTH-1,3*CAD_OUT_DEPTH);
		break;

#if CAD_OUT_WIDTH > 4
	case LINK_OUTPUT3_2_8BIT:
		lk_cad_phy[2] = reordered_cad_8bit.range(3*CAD_OUT_DEPTH-1,2*CAD_OUT_DEPTH);
		lk_cad_phy[3] = reordered_cad_8bit.range(4*CAD_OUT_DEPTH-1,3*CAD_OUT_DEPTH);
		break;
	case LINK_OUTPUT3_2_4BIT_CYCLE2:
		lk_cad_phy[2] = reordered_cad_4bit.range(7*CAD_OUT_DEPTH-1,6*CAD_OUT_DEPTH);
		lk_cad_phy[3] = reordered_cad_4bit.range(8*CAD_OUT_DEPTH-1,7*CAD_OUT_DEPTH);
		break;
#endif
		
	default: //case LINK_OUTPUT3_2_INIT:
		lk_cad_phy[2] = init_cad;
		lk_cad_phy[3] = init_cad;

	}
#endif


#if CAD_OUT_WIDTH > 4
	//Select the correct output for the outpus 7 through 4
	switch(select_value_7_4.read()){
	case LINK_OUTPUT7_4_8BIT:
		lk_cad_phy[4] = reordered_cad_8bit.range(5*CAD_OUT_DEPTH-1,4*CAD_OUT_DEPTH);
		lk_cad_phy[5] = reordered_cad_8bit.range(6*CAD_OUT_DEPTH-1,5*CAD_OUT_DEPTH);
		lk_cad_phy[6] = reordered_cad_8bit.range(7*CAD_OUT_DEPTH-1,6*CAD_OUT_DEPTH);
		lk_cad_phy[7] = reordered_cad_8bit.range(8*CAD_OUT_DEPTH-1,7*CAD_OUT_DEPTH);
		break;
		
	default: //case LINK_OUTPUT7_4_INIT:
		lk_cad_phy[4] = init_cad;
		lk_cad_phy[5] = init_cad;
		lk_cad_phy[6] = init_cad;
		lk_cad_phy[7] = init_cad;
	}
#endif


	//Now, reorder the CTL
	sc_bv<CAD_OUT_DEPTH> ctl_half_lctl_half_hctl;
	sc_bv<CAD_OUT_DEPTH> ctl_all_lctl;
	sc_bv<CAD_OUT_DEPTH> ctl_all_hctl;

	for(int n = 0; n < CAD_OUT_DEPTH; n++){
		ctl_all_lctl[n] = lctl_to_frame;
		ctl_all_hctl[n] = hctl_to_frame;
	}
	for(int n = 0; n < CAD_OUT_DEPTH/2; n++){
		ctl_half_lctl_half_hctl[n] = lctl_to_frame;
	}
	for(int n = CAD_OUT_DEPTH/2; n < CAD_OUT_DEPTH; n++){
		ctl_half_lctl_half_hctl[n] = hctl_to_frame;
	}

	sc_bv<CAD_OUT_DEPTH> init_ctl;
	for(int n = 0; n < CAD_OUT_DEPTH; n++){
		init_ctl[n] = init_ctl_value;
	}

#if CAD_OUT_WIDTH == 8
	switch(tx_link_width_encoded.read()){
	case LINK_8_BIT:
		switch(select_value_1_0.read()){
		case LINK_OUTPUT1_0_8BIT:
			lk_ctl_phy = ctl_half_lctl_half_hctl;
			break;
		default:
			lk_ctl_phy = init_ctl;
		}
		break;
	case LINK_4_BIT:
		switch(select_value_1_0.read()){
		case LINK_OUTPUT1_0_4BIT_CYCLE1:
			lk_ctl_phy = ctl_all_lctl;
			break;
		case LINK_OUTPUT1_0_4BIT_CYCLE2:
			lk_ctl_phy = ctl_all_hctl;
			break;
		default:
			lk_ctl_phy = init_ctl;
		}
		break;
	case LINK_2_BIT:
		switch(select_value_1_0.read()){
		case LINK_OUTPUT1_0_2BIT_CYCLE1:
			lk_ctl_phy = ctl_all_lctl;
			break;
		case LINK_OUTPUT1_0_2BIT_CYCLE2:
			lk_ctl_phy = ctl_all_lctl;
			break;
		case LINK_OUTPUT1_0_2BIT_CYCLE3:
			lk_ctl_phy = ctl_all_hctl;
			break;
		case LINK_OUTPUT1_0_2BIT_CYCLE4:
			lk_ctl_phy = ctl_all_hctl;
			break;
		default:
			lk_ctl_phy = init_ctl;
		}
		break;
	default:
		lk_ctl_phy = init_ctl;
		break;
	}
#elif CAD_OUT_WIDTH == 4
	switch(tx_link_width_encoded.read()){
	case LINK_4_BIT:
		switch(select_value_1_0.read()){
		case LINK_OUTPUT1_0_4BIT_CYCLE1:
			lk_ctl_phy = ctl_half_lctl_half_hctl;
		default:
			lk_ctl_phy = init_ctl_value;
		}
		break;
	case LINK_2_BIT:
		switch(select_value_1_0.read()){
		case LINK_OUTPUT1_0_2BIT_CYCLE1:
			lk_ctl_phy = ctl_all_lctl;
		case LINK_OUTPUT1_0_2BIT_CYCLE2:
			lk_ctl_phy = ctl_all_hctl;
		default:
			lk_ctl_phy = init_ctl_value;
		}
	default:
		lk_ctl_phy = init_ctl_value;
		break;
	}

#endif
}

void link_frame_tx_l3::generate_consume_data(){
	tx_consume_data = phy_consume_lk.read() && consume_if_can_output.read();
}


/**
	HT link width is encoded on 3 bits, but since we only support
	width of 2,4 and 8 bits, we can re-encode it on two bits
	to simplify code in the module.
*/
void link_frame_tx_l3::encode_link_width(){

	switch((sc_uint<3>)csr_tx_link_width_lk.read()){
	case 0 :
		tx_link_width_encoded = LINK_8_BIT;
		break;
	case 4 : 
		tx_link_width_encoded = LINK_2_BIT;
		break;
	case 5 : 
		tx_link_width_encoded = LINK_4_BIT;
		break;
	default:
		tx_link_width_encoded = INVALID_LINK_WIDTH;
	}
}
