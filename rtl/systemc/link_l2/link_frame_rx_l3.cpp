//link_frame_rx_l3.cpp

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
#include "link_frame_rx_l3.h"


///Constructor of module
link_frame_rx_l3::link_frame_rx_l3( sc_module_name name) : sc_module(name) {

	SC_METHOD(sample_link_width);
	sensitive_neg(pwrok);
	sensitive_pos(clk);

	SC_METHOD(clocked_process);
	sensitive_pos(clk);

	SC_METHOD(clocked_and_reset_process);
	sensitive_pos(clk);
	sensitive_neg(resetx);

	SC_METHOD(generate_ctl_and_timeout_errors);
	sensitive_pos(clk);
	sensitive_neg(resetx);

	SC_METHOD(encode);
	sensitive(reordered_cad);

	SC_METHOD(detect_ctl_transition_error);
	sensitive << state << reordered_data_ready << reordered_ctl 
#ifdef INTERNAL_SHIFTER_ALIGNMENT
		<< delayed_reordered_ctl << frame_shift_div_width
#endif
		;

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	SC_METHOD(output_reordered_cad_and_ctl);
	sensitive << reordered_cad << reordered_ctl;
#endif


}



/**
	Immediately following cold reset (when resetx becomes
	true and pwrok was false during the reset), the cad
	signals are sampled to determine link width.  At that
	time, both signals 
	lk_update_link_failure_property_csr  and
	lk_update_link_width_csr  are activated to update the
	value in the CSR.

	This is a clocked process, but using the signal
	pwrok as a reset instead of the usual resetx.  This is done
	because the link only has to be sampled after a cold reset 
	(after pwrok being low).		
*/
void link_frame_rx_l3::sample_link_width(){

	if(!pwrok.read()){
		ready_to_sample_link_width = false;
		ready_to_sample_link_width2 = false;
		link_width_sampled = false;
		lk_sampled_link_width_csr = "000";
		lk_link_failure_csr = false;
		lk_update_link_failure_property_csr = false;
		lk_update_link_width_csr = false;
	}
	else{
		//Sychronisation because resetx is asynchronous
		ready_to_sample_link_width = resetx;
		ready_to_sample_link_width2 = ready_to_sample_link_width;

		lk_update_link_failure_property_csr = false;
		lk_update_link_width_csr = false;

		//When reset is done, sample link width
		if(ready_to_sample_link_width2.read() && !link_width_sampled.read()){
			link_width_sampled = true;
			lk_update_link_failure_property_csr = true;
			lk_update_link_width_csr = true;

			//If cad[0] is false at reset, it means that no link is connected
			//We have a link failure
			if( phy_cad_lk[0].read()[0] == false){
				lk_link_failure_csr = true;
			}
			else{
				lk_link_failure_csr = false;
			}

			/*
			Link widths
				
			 000 8 bits 
			 100 2 bits 
			 101 4 bits 
			 111  Link physically not connected 
			*/
					
					//2 bits width
			if((sc_bit)phy_cad_lk[0].read()[0] && (sc_bit)phy_cad_lk[1].read()[0] 
#if CAD_IN_WIDTH > 2
				&& !(sc_bit)phy_cad_lk[2].read()[0] && !(sc_bit)phy_cad_lk[3].read()[0] 
#endif
#if CAD_IN_WIDTH > 4
				&& !(sc_bit)phy_cad_lk[4].read()[0] && !(sc_bit)phy_cad_lk[5].read()[0] 
				&& !(sc_bit)phy_cad_lk[6].read()[0] && !(sc_bit)phy_cad_lk[7].read()[0] 
#endif
				){
				lk_sampled_link_width_csr = "100";
			}
#if CAD_IN_WIDTH > 2
			//4 bits width
			else if((sc_bit)phy_cad_lk[0].read()[0] && (sc_bit)phy_cad_lk[1].read()[0] 
				&& (sc_bit)phy_cad_lk[2].read()[0] && (sc_bit)phy_cad_lk[3].read()[0] 
#if CAD_IN_WIDTH > 4
				&& !(sc_bit)phy_cad_lk[4].read()[0] && !(sc_bit)phy_cad_lk[5].read()[0] 
				&& !(sc_bit)phy_cad_lk[6].read()[0] && !(sc_bit)phy_cad_lk[7].read()[0] 
#endif
				){
				lk_sampled_link_width_csr = "101";
			}
#endif
#if CAD_IN_WIDTH > 4
			//8 bits width
			else if((sc_bit)phy_cad_lk[0].read()[0] && (sc_bit)phy_cad_lk[1].read()[0] 
				&& (sc_bit)phy_cad_lk[2].read()[0] && (sc_bit)phy_cad_lk[3].read()[0] 
				&& (sc_bit)phy_cad_lk[4].read()[0] && (sc_bit)phy_cad_lk[5].read()[0] 
				&& (sc_bit)phy_cad_lk[6].read()[0] && (sc_bit)phy_cad_lk[7].read()[0] ){
				lk_sampled_link_width_csr = "000";
			}
#endif
			//invalid bits width
			else{
				lk_sampled_link_width_csr = "111";
			}
		}
	}

}


/**
	Process for registered outputs without reset
*/
void link_frame_rx_l3::clocked_process(){
	encode_link_width();
#ifdef INTERNAL_SHIFTER_ALIGNMENT
	frame_cad();
	frame_ctl();
#endif
}

/**
	HT link width is encoded on 3 bits, but since we only support
	width of 2,4 and 8 bits, we can re-encode it on two bits
	to simplify code in the module.
*/
void link_frame_rx_l3::encode_link_width(){

	switch((sc_uint<3>)csr_rx_link_width_lk.read()){
	case 0 :
		rx_link_width_encoded = LINK_8_BIT;
		break;
	case 4 : 
		rx_link_width_encoded = LINK_2_BIT;
		break;
	case 5 : 
		rx_link_width_encoded = LINK_4_BIT;
		break;
	default:
		rx_link_width_encoded = INVALID_LINK_WIDTH;
	}
}

/**
	This arranges bits received from the physical layer back into
	order.  This needs to be done because when the phy receives
	bits, all he does it use a shift register for each lane.  Lets
	take a 4 lane example with the order of bits received

	Lane 0: ... 8  4 0
	Lane 1: ... 9  5 1
	Lane 2: ... 10 6 2
	Lane 3: ... 11 7 3

	What is received by this module is every Lane vectors.  Whe want to
	reorder the bits into a single ordered vector
*/
void link_frame_rx_l3::reorder_cad(){

	//Work on a temporary variable because we can't easily modify
	//bits of a sc_signal.  The modifications will only be accepted
	//what is read is new data from the link (see end of function)
	sc_bv<32> reordered_cad_tmp;

	//The reordering algorithm strongly depends on the physical link
	//width that changes the depths (number of bits received from
	//every lane.
#if CAD_IN_WIDTH == 2
	//Reorder bits 31 through 0.
	for(int n = 0; n < 16; n ++ ){
		reordered_cad_tmp[2*n] = (sc_bit)phy_cad_lk[0].read()[n];
		reordered_cad_tmp[2*n + 1] = (sc_bit)phy_cad_lk[1].read()[n];
	}
#elif CAD_IN_WIDTH == 4
	switch(rx_link_width_encoded.read()){
	case 2_BIT_LINK :
		//Reorder bits 31 through 16.
		for(int n = 0; n < 8; n ++ ){
			reordered_cad_tmp[2*n + 16] = (sc_bit)phy_cad_lk[0].read()[n];
			reordered_cad_tmp[2*n + 17] = (sc_bit)phy_cad_lk[1].read()[n];
		}

		//Reorder bits 15 through 0 : shift the last registered bits
		reordered_cad_tmp.range(15,0) = reordered_cad.read().range(31,16);
		break;

	default:
		//Reorder bits 31 through 0.
		for(int n = 0; n < 8; n ++ ){
			for(int y = 0; y < 4; y ++ ){
				reordered_cad_tmp[4*n + y] = (sc_bit)phy_cad_lk[y].read()[n];
			}
		}
		break;
	}


#else
	//CAD_IN_WIDTH == 8

	switch(rx_link_width_encoded.read()){
	case LINK_2_BIT :
		//Reorder bits 31 through 24.
		for(int n = 0; n < 4; n ++ ){
			reordered_cad_tmp[2*n + 24] = (sc_bit)phy_cad_lk[0].read()[n];
			reordered_cad_tmp[2*n + 25] = (sc_bit)phy_cad_lk[1].read()[n];
		}

		//Reorder bits 23 through 0. : shift the last registered bits
		reordered_cad_tmp.range(23,0) = reordered_cad.read().range(31,8);
		break;

	case LINK_4_BIT :
		//Reorder bits 31 through 16.
		for(int n = 0; n < 4; n ++ ){
			for(int y = 0; y < 4; y ++ ){
				reordered_cad_tmp[4*n + y + 16] = (sc_bit)phy_cad_lk[y].read()[n];
			}
		}

		//Reorder bits 15 through 0. : shift the last registered bits
		reordered_cad_tmp.range(15,0) = reordered_cad.read().range(31,16);
		break;
	default :
		for(int n = 0; n < 4; n ++ ){
			for(int y = 0; y < 8; y ++ ){
				reordered_cad_tmp[8*n + y] = (sc_bit)phy_cad_lk[y].read()[n];
			}
		}
	}
#endif

	//Store the new value if it was calculated from new data
	if(phy_available_lk.read())
		reordered_cad = reordered_cad_tmp;
}

/**
	This is similar to the cad reordering in the way that we want
	an easy to analyze ordered vector of the ctl signal received
	from the physical layer.  
	
	It is slightly different though because CTL is only one 
	lane : there is no real reordering to do.  What is also different
	is that the number of CTL transitions may vary :
		an 8-bit link will have 4 CTL bits per dword
		a  2-bit link will have 16 CTL bits per dword

	To simplify the post treatment of CTL, the received result
	is always stored in a 16 bits vector in this way

	8-bit link :
		... CTL2 CTL1 CTL1 CTL1 CTL1 CTL0 CTL0 CTL0 CTL0
	2-bit link
		... CTL8 CTL7 CTL6 CTL5 CTL4 CTL3 CTL2 CTL1 CTL0

	So once the CTL is reordering, the framing does not need
	to consider the link width and only deals with a constant
	16 bits vector.
*/
void link_frame_rx_l3::reorder_ctl(){
	sc_bv<16> reordered_ctl_tmp;

#if CAD_IN_WIDTH == 2
	reordered_ctl_tmp = phy_ctl_lk;
#elif CAD_IN_WIDTH == 4
	switch(rx_link_width_encoded.read()){
	case 2_BIT_LINK :
		reordered_ctl_tmp.range(15,8) = phy_ctl_lk.read().range(7,0);
		reordered_ctl_tmp.range(7,0) = reordered_ctl.read().range(15,8);
		break;

	default:
		for(int n = 0; n < 8; n++){
			reordered_ctl_tmp[2*n] = (sc_bit)phy_ctl_lk.read()[n];
			reordered_ctl_tmp[2*n + 1] = (sc_bit)phy_ctl_lk.read()[n];
		}
		break;
	}

#else
	//CAD_IN_WIDTH == 8
	switch(rx_link_width_encoded.read()){
	case LINK_2_BIT :
		reordered_ctl_tmp.range(15,12) = phy_ctl_lk.read().range(3,0);
		reordered_ctl_tmp.range(11,0) = reordered_ctl.read().range(15,4);
		break;

	case LINK_4_BIT :
		for(int n = 0; n < 4; n++){
			reordered_ctl_tmp[2*n + 8] = (sc_bit)phy_ctl_lk.read()[n];
			reordered_ctl_tmp[2*n + 9] = (sc_bit)phy_ctl_lk.read()[n];
		}
		reordered_ctl_tmp.range(7,0) = reordered_ctl.read().range(15,8);
		break;
	default :
		for(int n = 0; n < 4; n++){
			reordered_ctl_tmp[4*n] = (sc_bit)phy_ctl_lk.read()[n];
			reordered_ctl_tmp[4*n + 1] = (sc_bit)phy_ctl_lk.read()[n];
			reordered_ctl_tmp[4*n + 2] = (sc_bit)phy_ctl_lk.read()[n];
			reordered_ctl_tmp[4*n + 3] = (sc_bit)phy_ctl_lk.read()[n];
		}
	}
#endif

	//Store the new value if it was calculated from new data
	if(phy_available_lk.read())
		reordered_ctl = reordered_ctl_tmp;
}


/**
	Regroups all registers that require a asynchronous reset
	Contains the state machine
*/
void link_frame_rx_l3::clocked_and_reset_process(){
	if(!resetx.read()){
		disconnect_counter = 0;
		state = RX_FRAME_INACTIVE_ST;
		rx_waiting_for_ctl_tx = true;
		reordered_data_ready = false;

		lk_rx_connected = false;

		lk_disable_receivers_phy = false;
		framed_data_available = false;

#ifdef INTERNAL_SHIFTER_ALIGNMENT
		frame_shift_div_width = 0;
		delayed_reordered_cad = "11111111111111111111111111111111";
		delayed_reordered_ctl = 0;
#else
		lk_deser_stall_phy = false;
		lk_deser_stall_cycles_phy = 0;
#endif
		delayed_calculated_frame_shift_div_width = 0;
		reordered_ctl = 0;
		reordered_cad = "11111111111111111111111111111111";


#if CAD_IN_WIDTH > 2
		phy_cad_lk_count = 0;	
#endif

	}
	else{

#ifdef RETRY_MODE_ENABLED
		bool retry_disconnect = cd_initiate_retry_disconnect.read() ||
			lk_initiate_retry_disconnect.read();
#endif
		//Reorder the bits
		reorder_cad();
		reorder_ctl();

		//By default we are not connected
		lk_rx_connected = false;


#ifdef INTERNAL_SHIFTER_ALIGNMENT
		//Register reordered_cad & reordered_ctl
		if(reordered_data_ready.read()){
			delayed_reordered_cad = reordered_cad;
			delayed_reordered_ctl = reordered_ctl;
		}
#else
		delayed_calculated_frame_shift_div_width = calculated_frame_shift_div_width;

		//By default, do not stall phy
		lk_deser_stall_phy = false;
		lk_deser_stall_cycles_phy = delayed_calculated_frame_shift_div_width.read();
#endif
		bool reordered_data_ready_tmp;

		/** The count of how many receptions are made is only needed for links
		with more than two bits because of the depth : An 8-bit link has a depth
		of 4, a 2-bit link has a depth of 16.  So every cycle with a 2-bit link, 
		we received a full dword (2x16), so we don't need to count how much data
		is received before a dword is received.

		In the case of an 8-bit link that's only running at a 2-bit width, only
		8 bits are received per cycle (2x4) so it will take 4 cycles to receive
		a full dword.
		*/
#if CAD_IN_WIDTH > 2
		if(RX_FRAME_INACTIVE_ST)
			phy_cad_lk_count = 0;
		if(phy_available_lk.read())
			phy_cad_lk_count = phy_cad_lk_count.read() + 1;
#endif

#if CAD_IN_WIDTH == 8
		switch(rx_link_width_encoded.read()){
		case LINK_8_BIT:
			reordered_data_ready_tmp = phy_available_lk.read();
			break;

		case LINK_4_BIT:
			reordered_data_ready_tmp = phy_cad_lk_count.read()[0] == false && phy_available_lk.read();
			break;

		case LINK_2_BIT:
			reordered_data_ready_tmp = phy_cad_lk_count.read() == 2 && phy_available_lk.read();
			break;

		default:
			reordered_data_ready_tmp = false;

		}
#elif CAD_IN_WIDTH == 4
		switch(rx_link_width_encoded.read()){
		case LINK_4_BIT:
			reordered_data_ready_tmp = phy_available_lk.read();
			break;

		case LINK_2_BIT:
			reordered_data_ready_tmp = phy_cad_lk_count.read()[0] == false && phy_available_lk.read();
			break;

		default:
			reordered_data_ready_tmp = false;

		}
#else
		switch(rx_link_width_encoded.read()){
		case LINK_2_BIT:
			reordered_data_ready_tmp = phy_available_lk.read();
			break;

		default:
			reordered_data_ready_tmp = false;

		}
#endif
		reordered_data_ready = reordered_data_ready_tmp;

		disconnect_counter = 1;

		rx_waiting_for_ctl_tx = false;
		lk_disable_receivers_phy = false;
		framed_data_available = false;

		/**
			State machine to detect the init sequence
		*/
		switch(state){

		case RX_FRAME_ACTIVE_ST:
			lk_rx_connected = true;

			if(ldtstop_disconnect_rx.read() || csr_end_of_chain.read()){
				state = RX_FRAME_LDTSTOP_DISCONNECT_ST;
			}			
#ifdef RETRY_MODE_ENABLED
			else if(retry_disconnect){
				state = RX_FRAME_RETRY_DISCONNECT_ST;
			}
#endif


#ifdef INTERNAL_SHIFTER_ALIGNMENT
			//With internal shifter alignment, there is a register after alignment,
			//so we send framed_data_available one cycle after reordered data is ready
			if(	reordered_data_ready.read() && 
#else
			//Without internal shifter, there is not a register after alignment (there is no
			//alignment), so the data ready signal can be sent right away
			if(	reordered_data_ready_tmp && //reordered_data_ready_tmp means data ready NEXT cycle!
#endif
#ifdef RETRY_MODE_ENABLED
				!retry_disconnect && !new_detected_ctl_transition_error.read() &&
#endif
			!ldtstop_disconnect_rx.read()){
				framed_data_available = true;
			}
			break;

		case RX_FRAME_WAIT_FRAME_ST:
			if(ldtstop_disconnect_rx.read() || csr_end_of_chain.read()){
				state = RX_FRAME_LDTSTOP_DISCONNECT_ST;
			}			
#ifdef INTERNAL_SHIFTER_ALIGNMENT
			else if(reordered_data_ready.read() && (sc_bit)(reordered_cad.read()[0])){
#else
			else if(reordered_data_ready_tmp && (sc_bit)(reordered_cad.read()[0])){
				framed_data_available = true;
#endif
				state = RX_FRAME_ACTIVE_ST;
			}
			break;

#ifdef RETRY_MODE_ENABLED
		case RX_FRAME_RETRY_DISCONNECT_ST:
			disconnect_counter = disconnect_counter.read() + 1;
			if(ldtstop_disconnect_rx.read() || csr_end_of_chain.read()){
				state = RX_FRAME_LDTSTOP_DISCONNECT_ST;
			}			
			else if(disconnect_counter.read() == 0){
				state = RX_FRAME_INACTIVE_ST;				
			};

			break;
#endif
		case RX_FRAME_LDTSTOP_DISCONNECT_ST:
			lk_disable_receivers_phy = true;

			if(ldtstopx.read()){
				disconnect_counter = disconnect_counter.read() + 1;
			}

			if(disconnect_counter.read() == 0){
				state = RX_FRAME_INACTIVE_ST;				
			};

			break;
		default: // RX_FRAME_INACTIVE_ST:

			//Warn TX side that CTL is not active
			rx_waiting_for_ctl_tx = !phy_ctl_lk[0];

			if(ldtstop_disconnect_rx.read() || csr_end_of_chain.read()){
				state = RX_FRAME_LDTSTOP_DISCONNECT_ST;
			}
			/**
				Originally, the end of inactive state was checked with bit
				!(sc_bit)reordered_cad.read()[31], but this can be problematic
				after cold reset if the link width is smaller than 8 bits since
				the width update takes multiple cycles to propagate to the
				cad reordering logic.  What can happen is that the reordering logic
				at the beginning will reorder all inputs as if it was 8-bit width
				event if it is 2-bit width for example, reordering the 0's at inputs
				7..2.  Those 0's could be mistaken for 0's sent by the next node.
				
				To go around this problem, bit 0 is used instead, but with a
				delayed "calculated_frame_shift_div_width" instead.

				If bit 31 = 0 and bit 0 = 0, it means the shift is 0 and since last
				frame contained all 1's, delayed_calculated_frame_shift_div_width will still have
				the correct value of 0.
			*/
			else if(!(sc_bit)reordered_cad.read()[0]){
				state = RX_FRAME_WAIT_FRAME_ST;
#ifdef INTERNAL_SHIFTER_ALIGNMENT
				frame_shift_div_width = delayed_calculated_frame_shift_div_width.read();
#else
				//Always has this value (set in top of process)
				//lk_deser_stall_cycles_phy = delayed_calculated_frame_shift_div_width.read();
				lk_deser_stall_phy = delayed_calculated_frame_shift_div_width.read() != 0;
#endif
			}
		}

		if(csr_sync.read()){
			state = RX_FRAME_INACTIVE_ST;
		}
	}
}

/**
	During the link initialization, the data allignement must be determined.  This function
	encodes the stored cad data to determine the shift necessary to properly align the data.
	Of course, this is combinatory, so it always outputs something, but it is only valid
	at a precise moment during the initialization sequence, at which time the value
	is stored.
*/
void link_frame_rx_l3::encode(){

	sc_bv<LOG2_CAD_IN_DEPTH> encoded_reordered_cad;
	
	//When we received the first int cad sequence, it's going to be all zeroes
	//in the higher bits and all ones in the bottom.  We want to encode the position
	//of this change so we start with some edge detection
	sc_bv<32/CAD_IN_WIDTH> edge_x;
	for(int n = 1; n < 32/CAD_IN_WIDTH; n++){
		edge_x[n] = !(!(sc_bit)reordered_cad.read()[32-CAD_IN_WIDTH*n] && (sc_bit)reordered_cad.read()[30-CAD_IN_WIDTH]);
	}

	//Only one edge is detected (if we are indeed in the init sequence), encode it
	//The larger the link is, the smaller the depth is (to have a constant 32 bits input).  The alignment
	//can only be related to the depth of the input : an 8 bits input has depth of 4 (4x8), so the alignment
	//offset can be 0, 8, 16 or 24.  The alignment offset can be represented on 2 bits (0,1,2 or 3).
	//A link with a smaller width (higher depth) needs more bits to represent the offset.
#if CAD_IN_WIDTH == 2
	encoded_reordered_cad[3] = 
		!((((sc_bit)edge_x[15] && (sc_bit)edge_x[14] )
		&& ((sc_bit)edge_x[13] && (sc_bit)edge_x[12]))
				&&
		(((sc_bit)edge_x[11] && (sc_bit)edge_x[10]) && 
		((sc_bit)edge_x[9] && (sc_bit)edge_x[8])));

	encoded_reordered_cad[2] = 
		!((((sc_bit)edge_x[15] && (sc_bit)edge_x[14]) && 
		((sc_bit)edge_x[13] && 	(sc_bit)edge_x[12])) && 
		(((sc_bit)edge_x[7] && (sc_bit)edge_x[6]) &&
		((sc_bit)edge_x[5] && (sc_bit)edge_x[4])));

	encoded_reordered_cad[1] = 
		!((((sc_bit)edge_x[15] && (sc_bit)edge_x[14]) && 
		((sc_bit)edge_x[11] && (sc_bit)edge_x[10])) && 
		(((sc_bit)edge_x[7] && (sc_bit)edge_x[6]) &&
		((sc_bit)edge_x[3] && (sc_bit)edge_x[2])));

	encoded_reordered_cad[0] = 
		!((((sc_bit)edge_x[15] && (sc_bit)edge_x[13]) && 
		((sc_bit)edge_x[11] && (sc_bit)edge_x[9])) &&
		(((sc_bit)edge_x[7] && (sc_bit)edge_x[5]) &&
		((sc_bit)edge_x[3] && (sc_bit)edge_x[1])));
#elif CAD_IN_WIDTH == 4
	encoded_reordered_cad[2] = 
		!(((sc_bit)edge_x[7] && (sc_bit)edge_x[6]) &&
		((sc_bit)edge_x[5] && (sc_bit)edge_x[4]));

	encoded_reordered_cad[1] = 
		!(((sc_bit)edge_x[7] && (sc_bit)edge_x[6]) &&
		((sc_bit)edge_x[3] && (sc_bit)edge_x[2]));

	encoded_reordered_cad[0] = 
		!(((sc_bit)edge_x[7] && (sc_bit)edge_x[5]) &&
		((sc_bit)edge_x[3] && (sc_bit)edge_x[1]));
#else
	encoded_reordered_cad[1] = 
		!((sc_bit)edge_x[3] && (sc_bit)edge_x[2]);

	encoded_reordered_cad[0] = 
		!((sc_bit)edge_x[3] && (sc_bit)edge_x[1]);
#endif

	calculated_frame_shift_div_width = encoded_reordered_cad;
}

#ifndef INTERNAL_SHIFTER_ALIGNMENT
void link_frame_rx_l3::output_reordered_cad_and_ctl(){
	framed_cad = reordered_cad;
	framed_lctl = (sc_bit)reordered_ctl.read()[0];
	framed_hctl = (sc_bit)reordered_ctl.read()[8];
}
#else

/**
	Once bits are reordered, they are in a correct sequence of order. BUT,
	there is no guarantee that the beginning of the reordered vector is
	the actual beginning of a transmitted dword : there might be an
	offset.

	That offset is calculated during the init sequence and the amount
	of shift that needs to be done to correct that offset is stored
	in the frame_shift_div_width register.

	In other words, this is simply a shifter to correctly frame the
	received data, also using the previous received data.
*/
void link_frame_rx_l3::frame_cad(){
	//Here, there are multiple shifters : one for every bit of the input
	//It saves on resources compared to using one big shifter

	sc_bv<32> framed_cad_tmp;

	for(int n = 0; n < CAD_IN_WIDTH;n++){

		sc_bv<64/CAD_IN_WIDTH> shift_cad;

		for(int i = 0; i < 32/CAD_IN_WIDTH; i++){
			shift_cad[ i + 32/CAD_IN_WIDTH] = (sc_bit)reordered_cad.read()[CAD_IN_WIDTH*i+n];
		}
		for(int i = 0; i < 32/CAD_IN_WIDTH; i++){
			shift_cad[ i ] = (sc_bit)delayed_reordered_cad.read()[CAD_IN_WIDTH*i+n];
		}

		sc_bv<64/CAD_IN_WIDTH> shifted_cad = shift_cad << frame_shift_div_width.read();

		for(int i = 0; i < 32/CAD_IN_WIDTH; i++){
			framed_cad_tmp[CAD_IN_WIDTH*i+n] = (sc_bit)shifted_cad[i+32/CAD_IN_WIDTH];
		}
	}

	framed_cad = framed_cad_tmp;
}

/**
	Same principle as the frame_cad function, except since we are only
	interested in two CTL values (LCTL and HCTL), there is no need to
	shift the bits.  We simplyread the correct bit.
*/
void link_frame_rx_l3::frame_ctl(){
	sc_bv<32> shift_ctl_bits;
	shift_ctl_bits.range(31,16) = reordered_ctl.read();
	shift_ctl_bits.range(15,0) = delayed_reordered_ctl.read();

	framed_lctl = (sc_bit)shift_ctl_bits[16-frame_shift_div_width.read()];
	framed_hctl = (sc_bit)shift_ctl_bits[24-frame_shift_div_width.read()];
}


#endif

/**
	This process handles various errors of the CTL bit.  CTL transition
	errors are detected by another process, but this process will
	log the error after the correct amount of time.  If in retry
	mode, it will even initiate the retry sequence when an error\
	is detected.

	Also, if CTL stays low for too long, an error is also logged.
*/
void link_frame_rx_l3::generate_ctl_and_timeout_errors(){

	if(!resetx.read()){
		detected_ctl_transition_error = false;
		lk_protocol_error_csr = false;
		ctl_watchdog_timer = 0;
#ifdef RETRY_MODE_ENABLED
		lk_initiate_retry_disconnect = false;
#endif
	}
	else{
		lk_protocol_error_csr = false;

		bool active_ctl = 
		((((sc_bit)reordered_ctl.read()[0] || (sc_bit)reordered_ctl.read()[1]) || 
		((sc_bit)reordered_ctl.read()[2] || (sc_bit)reordered_ctl.read()[3])) ||
		(((sc_bit)reordered_ctl.read()[4] || (sc_bit)reordered_ctl.read()[5]) || 
		((sc_bit)reordered_ctl.read()[6] || (sc_bit)reordered_ctl.read()[7]))) ||
		((((sc_bit)reordered_ctl.read()[8] || (sc_bit)reordered_ctl.read()[9]) || 
		((sc_bit)reordered_ctl.read()[10] || (sc_bit)reordered_ctl.read()[11])) ||
		(((sc_bit)reordered_ctl.read()[12] || (sc_bit)reordered_ctl.read()[13]) || 
		((sc_bit)reordered_ctl.read()[14] || (sc_bit)reordered_ctl.read()[15])));

		
		if(! (state == RX_FRAME_ACTIVE_ST || state == RX_FRAME_WAIT_FRAME_ST)){
			detected_ctl_transition_error = false;
#ifdef RETRY_MODE_ENABLED
			lk_initiate_retry_disconnect = false;
#endif
		}
		else if(reordered_data_ready.read()){
			detected_ctl_transition_error = new_detected_ctl_transition_error.read() || 
				detected_ctl_transition_error.read();

			//Only activate the transition error when we receive another CTL
			//so that a reset sequence is not loged as an error
			bool ctl_transition_error_tmp = detected_ctl_transition_error.read() && active_ctl;
			lk_protocol_error_csr = ctl_transition_error_tmp;

#ifdef RETRY_MODE_ENABLED
			lk_initiate_retry_disconnect = csr_retry.read() && ctl_transition_error_tmp;
#endif
		}

		/**
			This is a watchdog timer that checks if the link has not received a positive
			CTL value for more than a certain amount of time, which would mean that
			some kind of error has occured.
		*/
		if(! (state == RX_FRAME_ACTIVE_ST || state == RX_FRAME_WAIT_FRAME_ST) || active_ctl){
			ctl_watchdog_timer = 0;
		}
		else{
			ctl_watchdog_timer = ctl_watchdog_timer.read() + 1;
		}

		if( !csr_extended_ctl_timeout_lk.read() && 
			(ctl_watchdog_timer.read() == NUMBER_CYCLES_1_MS) ||
			csr_extended_ctl_timeout_lk.read() && 
			(ctl_watchdog_timer.read() == NUMBER_CYCLES_1_S) )
		{
			lk_protocol_error_csr = true;
		}
	}
}

/**
	This process detects transitions errors of the CTL bit.  The CTL
	bit is normally only allowed to make a transition half way
	through the transmission of a dword : for LCTL and HCTL.  If
	a transition is detected at another moment, it means that
	an error has occured.
*/
void link_frame_rx_l3::detect_ctl_transition_error(){
	if(reordered_data_ready.read() &&
		(state == RX_FRAME_ACTIVE_ST || state == RX_FRAME_WAIT_FRAME_ST)){

#ifdef INTERNAL_SHIFTER_ALIGNMENT
		sc_bv<32> shift_ctl_bits;
		shift_ctl_bits.range(31,16) = reordered_ctl.read();
		shift_ctl_bits.range(15,0) = delayed_reordered_ctl.read();

		sc_bv<16> shifted_ctl_bits;
		for(int n = 0; n < 16; n++){
			shifted_ctl_bits[n] = shift_ctl_bits[16+n-frame_shift_div_width.read()*CAD_IN_WIDTH/2];
		}
#else
		sc_bv<16> shifted_ctl_bits = reordered_ctl.read();
#endif

		//First, detect transition errors : if not all values of LCTL or HCTL
		//are the same, it's an error
		new_detected_ctl_transition_error = !(
			(((((sc_bit)shifted_ctl_bits[0] && (sc_bit)shifted_ctl_bits[1]) && 
			  ((sc_bit)shifted_ctl_bits[2] && (sc_bit)shifted_ctl_bits[3])) && 
			  (((sc_bit)shifted_ctl_bits[4] && (sc_bit)shifted_ctl_bits[5]) && 
			  ((sc_bit)shifted_ctl_bits[6] && (sc_bit)shifted_ctl_bits[7])) ) 
			||
			(((!(sc_bit)shifted_ctl_bits[0] && !(sc_bit)shifted_ctl_bits[1]) && 
			(!(sc_bit)shifted_ctl_bits[2] && !(sc_bit)shifted_ctl_bits[3])) && 
			((!(sc_bit)shifted_ctl_bits[4] && !(sc_bit)shifted_ctl_bits[5]) && 
			(!(sc_bit)shifted_ctl_bits[6] && !(sc_bit)shifted_ctl_bits[7])) ))
					&&
			(((((sc_bit)shifted_ctl_bits[8] && (sc_bit)shifted_ctl_bits[9]) && 
			((sc_bit)shifted_ctl_bits[10] && (sc_bit)shifted_ctl_bits[11])) && 
			(((sc_bit)shifted_ctl_bits[12] && (sc_bit)shifted_ctl_bits[13]) && 
			((sc_bit)shifted_ctl_bits[14] && (sc_bit)shifted_ctl_bits[15]))) 
			||
			(((!(sc_bit)shifted_ctl_bits[8] && !(sc_bit)shifted_ctl_bits[9]) && 
			(!(sc_bit)shifted_ctl_bits[10] && !(sc_bit)shifted_ctl_bits[11])) && 
			(((!(sc_bit)shifted_ctl_bits[12] && !(sc_bit)shifted_ctl_bits[13]) && 
			(!(sc_bit)shifted_ctl_bits[14] && !(sc_bit)shifted_ctl_bits[15]))))));
	}
	else
		new_detected_ctl_transition_error = false;

}

