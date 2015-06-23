//fairness_l3.cpp

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

#include "fairness_l3.h"

fairness_l3::fairness_l3(sc_module_name name) : sc_module(name){
	SC_METHOD(clocked_process);
	sensitive_pos(clk);
	sensitive_neg(resetx);
}

void fairness_l3::clocked_process(){
	if(!resetx.read()){
		//Reset to 0 the 3-bit counters
		for(int n = 0; n < 32; n++)
			forward_tracker[n] = 0;

		forward_count = 0;
		window = 1;
		local_priority = false;
		lfsr = 0;
		denominator = 0;
		last_fwd_ack_ro = false;
		last_ro_packet_fwd_unitid = 0;
		last_ro_packet_fwd_chain = false;
	}
	else{
		//Register stuff
		sc_bv<64> pkt = ro_packet_fwd.read().packet;
		last_ro_packet_fwd_chain = isChain(pkt);
		last_fwd_ack_ro = fwd_ack_ro.read();
		last_ro_packet_fwd_unitid = ((sc_uint<5>)(sc_bv<5>)pkt.range(12,8));

		////////////////////////////////////////
		// Check if an increment is in order
		////////////////////////////////////////

		bool count_fwd_packet_sent = last_fwd_ack_ro.read() && !last_ro_packet_fwd_chain.read();

		/////////////////////////////////////////
		// Calculate value of 3-bit counters
		/////////////////////////////////////////

		//Determine if a buffer needs to be incremented
		bool increment[32];
		for(int n = 0; n < 32; n++)
			increment[n] = (count_fwd_packet_sent && last_ro_packet_fwd_unitid.read() == n);

		//Determine if a buffer overflows
		bool overflow_per_tracker[32];
		for(int n = 0; n < 32; n++)
			overflow_per_tracker[n] = forward_tracker[n].read() == 7 && increment[n];

		bool overflow = false;
		for(int n = 0; n < 32; n++)
			overflow = overflow || overflow_per_tracker[n];

		//Set the new value of the counters
		for(int n = 0; n < 32; n++){
			if(overflow) forward_tracker[n] = 0;
			else if(increment[n])forward_tracker[n] = forward_tracker[n].read() + 1;
		}
		
		/////////////////////////////////////////
		// Calculate value of 8-bit counter
		/////////////////////////////////////////

		sc_bv<8> forward_count_p1 = forward_count.read() + 1;

		if(overflow){
			denominator = forward_count_p1;
			forward_count = 0;
		}
		else if(last_fwd_ack_ro.read()){
			forward_count = forward_count_p1;
		}

		/////////////////////////////////////////
		// Calculate value of window
		/////////////////////////////////////////

		//Checks if window is equal to 1 or 0
		bool window_low = window.read().range(5,1) == 0;

		if(last_fwd_ack_ro.read()){
			if(window_low){
				sc_uint<9> windowx8 = (sc_uint<9>)denominator.read() + lfsr.read().range(2,0);
				window = windowx8.range(8,2);
			}
			else{
				window = window.read() - 1;
			}
		}

		////////////////////////////////////////////////////////
		// Calculate value of the linear feedback shift register
		////////////////////////////////////////////////////////

		bool window_cleared = count_fwd_packet_sent && window_low;

		if(window_cleared){
			sc_uint<9> lfsr_tmp;
			lfsr_tmp.range(7,0) = lfsr.read().range(8,1);
			lfsr_tmp[8] = lfsr.read()[0] ^ lfsr.read()[4];
			lfsr = lfsr_tmp;
		}

		/////////////////////////////////////////
		// Calculate value of priority bit
		/////////////////////////////////////////

		if(window_cleared) local_priority = true;
		else if(local_packet_issued.read()) local_priority = false;
	}
}

#ifndef SYSTEMC_SIM
#include "../core_synth/synth_control_packet.cpp"
#endif

