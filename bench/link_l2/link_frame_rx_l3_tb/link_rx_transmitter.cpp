//link_rx_transmitter.cpp
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

#include "link_rx_transmitter.h"

using namespace std;

link_rx_transmitter::link_rx_transmitter(sc_module_name name) : sc_module(name){

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	SC_METHOD(realign);
	sensitive_pos(clk);
#endif

	//By default, link width is at the maximum width
	bit_width = CAD_IN_WIDTH;
	//Introduce no offset
	transmission_offset = 0;

	last_sent_dword = 0;
	last_sent_lctl = false;
	last_sent_hctl = false;
}

void link_rx_transmitter::send_init_sequence(int offset1, int offset2){


	//Wait a couple cycles (delay not specified)
	for(int n = 0; n < 5; n++)
		wait();

	transmission_offset = offset1;
	sc_bv<32> low_dword = sc_uint<32>(0);
	sc_bv<32> high_dword = ~low_dword;

	//Set some stuff so that send_dword_link starts correctly
	last_sent_dword = high_dword;
	last_sent_lctl = false;
	last_sent_hctl = false;

	for(int n = 0; n < 5; n++){
		send_dword_link(high_dword,true,true,false);
	}
	
	//Insert dead time
	wait();

	//Change the offset just for kicks
	transmission_offset = offset2;

	for(int n = 0; n < 130; n++){
		send_dword_link(low_dword,false,false,false);

		//Insert dead times
		if(n%20 == 0) wait();
	}
	//Insert dead time
	wait();
	
	send_dword_link(high_dword,false,false,false);

	//Insert dead time
	wait();
	cout << "RX connection complete" << endl;

}



void link_rx_transmitter::send_dword_link(const sc_bv<32> & dword, 
										  bool lctl, bool hctl,
										  bool ctl_error){

	///Data is available for the tunnel until the dword is sent
	phy_available_lk = true;
	
	//CAD and CTL signals have a depth (the deserialization factor).
	//Start by filling the lowest part : pos 0 of the depth
	int pos_in_depth = 0;

	sc_bv<CAD_IN_DEPTH>	phy_ctl_lk_buf;
	sc_bv<CAD_IN_DEPTH>	phy_cad_lk_buf[CAD_IN_WIDTH];

	//Start by sending unsent offset of last dword
	for(int n = 0; n < transmission_offset; n++){
		//Offset in the last dword
		int base_offset = 32-(transmission_offset-n)*bit_width;

		//Send bits int the cad vectors
		for(int x = 0; x < bit_width; x++){
			phy_cad_lk_buf[x][pos_in_depth] = (sc_bit)last_sent_dword[base_offset + x];
		}

		if(ctl_error){
			//pos_in_depth%2 will make the CTL change every cycle, which is more
			//than at every half (unless 16 bit width, which is not supported)
			phy_ctl_lk_buf[pos_in_depth] = (bool)(pos_in_depth%2);
		}
		else{
			if(base_offset >=16)
				phy_ctl_lk_buf[pos_in_depth] = last_sent_hctl;
			else
				phy_ctl_lk_buf[pos_in_depth] = last_sent_lctl;
		}

		//If the depth is filled
		/**
			This can happen if we have an 8 bit link (depth 4) and are connected
			to a 2 bit link that takes 16 bit time to send data.  In that case, 16
			bit times will fill the depth if the transmission_offset is 4 or higher.
		*/
		pos_in_depth++;
		if(pos_in_depth == CAD_IN_DEPTH){
			pos_in_depth = 0;
			phy_ctl_lk = phy_ctl_lk_buf;
			for(int n = 0; n < CAD_IN_WIDTH; n++) phy_cad_lk[n] = phy_cad_lk_buf[n];
			//Wait to transmit, then continue with next CAD and CTL values
			wait();
		}
	}	

	//Now send new data
	int max_iterations = 32/bit_width - transmission_offset;
	for(int n = 0; n < max_iterations; n++){
		//Send bits int the cad vectors
		for(int x = 0; x < bit_width; x++){
			phy_cad_lk_buf[x][pos_in_depth] = (sc_bit)dword[n *bit_width + x];
		}

		if(ctl_error){
			phy_ctl_lk_buf[pos_in_depth] = (bool)(pos_in_depth%2);
		}
		else{
			if(n * bit_width >=16)
				phy_ctl_lk_buf[pos_in_depth] = hctl;
			else
				phy_ctl_lk_buf[pos_in_depth] = lctl;
		}

		//If the depth is filled
		/**
			This can happen if we have an 8 bit link (depth 4) and are connected
			to a 2 bit link that takes 16 bit time to send data.  In that case, 16
			bit times will fill the depth if the transmission_offset is 4 or higher.
		*/
		pos_in_depth++;
		if(pos_in_depth == CAD_IN_DEPTH){
			pos_in_depth = 0;
			phy_ctl_lk = phy_ctl_lk_buf;
			for(int n = 0; n < CAD_IN_WIDTH; n++) phy_cad_lk[n] = phy_cad_lk_buf[n];
			//Wait to transmit, then continue with next CAD and CTL values
			wait();
		}
	}


	last_sent_lctl = lctl;
	last_sent_hctl = hctl;
	last_sent_dword = dword;
	phy_available_lk = false;
}

void link_rx_transmitter::send_initial_value(int nb_cyles){
	sc_bv<CAD_IN_DEPTH> zero_value = sc_uint<CAD_IN_DEPTH>(0);
	sc_bv<CAD_IN_DEPTH> reset_value = ~zero_value;

	//Send reset value at input
	phy_ctl_lk = zero_value;

	for(int n = 0; n < CAD_IN_WIDTH && n < bit_width; n++)
		phy_cad_lk[n] = reset_value;

	//Keep reset asserted for some cyles (1ms in reality)
	for(int n = 0; n < nb_cyles; n++){
		wait();
	}
	phy_available_lk = true;

}

#ifndef INTERNAL_SHIFTER_ALIGNMENT
void link_rx_transmitter::realign(){
	if(lk_deser_stall_phy.read()){
		//cout << "Correcting transmission offset: current=" << transmission_offset << " stall=" << (int)lk_deser_stall_cycles_phy.read();
		transmission_offset = (transmission_offset + lk_deser_stall_cycles_phy.read()) % CAD_IN_DEPTH;
		//cout << " new_offset=" << transmission_offset << endl;
	}
}
#endif

