//address_manager_l3.cpp

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

#include "address_manager_l3.h"

address_manager_l3::address_manager_l3(sc_module_name name) : sc_module(name){
	SC_METHOD(clocked_process);
	sensitive_pos(clk);
	sensitive_neg(resetx);

	SC_METHOD(find_first_free_buffers);
	for(int n = 0; n < NB_OF_BUFFERS; n++){
		sensitive << buffer_used[0][n] << buffer_used[1][n] << buffer_used[2][n];
	}

	SC_METHOD(output_write_address);
	sensitive << first_free_one_hot[0]
			  << first_free_one_hot[1]
			  << first_free_one_hot[2]
			  << new_packet_available[0]
			  << new_packet_available[1]
			  << new_packet_available[2];
}

void address_manager_l3::clocked_process(){
	if(!resetx.read()){
		last_lower_rd_addr[0] = 0;
		last_lower_rd_addr[1] = 0;

		//Initialize the internal registers
		for(int x = 0; x < 3; x++){
			for(int y = 0; y < NB_OF_BUFFERS; y++){
				buffer_used[x][y] = false;
			}
		}
	}
	else{
		//Update the internal registers
		last_lower_rd_addr[0]
			= ro_command_packet_rd_addr[0].read().range(LOG2_NB_OF_BUFFERS-1,0);
		last_lower_rd_addr[1] 
			= ro_command_packet_rd_addr[1].read().range(LOG2_NB_OF_BUFFERS-1,0);

		for(int vc = 0; vc < 3; vc++){
			for(int n = 0; n < NB_OF_BUFFERS; n++){
				//By default, keep same value
				buffer_used[vc][n] = buffer_used[vc][n].read() && 
					//If buffer freed, make the value 0.  The last value of the read address must be
					//used because there buffers_cleared is registered
					!(((sc_bit)buffers_cleared[vc].read()[0] && last_lower_rd_addr[0].read() == n) ||
						((sc_bit)buffers_cleared[vc].read()[1] && last_lower_rd_addr[1].read() == n))
						//If new entry, make the value 1
						|| (new_packet_available[vc].read() && (sc_bit)first_free_one_hot[vc].read()[n]);
			}
		}
	}

}

void address_manager_l3::find_first_free_buffers(){
	//////////////////////////////////////////////////////////
	// Use priority encoders to find the position of all
	// first free packets
	//////////////////////////////////////////////////////////

	for(int vc = 0; vc < 3; vc++){
		sc_bv<NB_OF_BUFFERS> first_free_one_hot_tmp = 0;
		for(int n = 0; n < NB_OF_BUFFERS; n++){
			first_free_one_hot_tmp[n] = !buffer_used[vc][n].read();
			for(int i = 0; i < NB_OF_BUFFERS; i++){
				if(i < n)
					first_free_one_hot_tmp[n] = (sc_bit)first_free_one_hot_tmp[n] && buffer_used[vc][i].read();
			}
		}
		first_free_one_hot[vc] = first_free_one_hot_tmp;
	}
}

void address_manager_l3::output_write_address(){
	//////////////////////////////////////////////////////////
	// First build the address from the one-hot encoded vector
	///////////////////////////////////////////////////////////

	sc_uint<LOG2_NB_OF_BUFFERS> first_free_pos[3];
	for(int vc = 0; vc < 3; vc++){
		first_free_pos[vc] = 0;
		for(int n = 0; n < NB_OF_BUFFERS; n++){
			sc_uint<LOG2_NB_OF_BUFFERS> and_vector;
			for(int i = 0; i < LOG2_NB_OF_BUFFERS; i++) and_vector[i] = first_free_one_hot[vc].read()[n];
			first_free_pos[vc] = first_free_pos[vc] | (and_vector & sc_uint<LOG2_NB_OF_BUFFERS>(n));
		}
	}

	//////////////////////////////////////////////////////////
	// Output the correct address depending on the selected vc
	///////////////////////////////////////////////////////////
	sc_uint<LOG2_NB_OF_BUFFERS> pkt_wr_addr_low = 0;
	if(new_packet_available[0].read()) pkt_wr_addr_low = first_free_pos[VC_POSTED];
	if(new_packet_available[1].read()) pkt_wr_addr_low = pkt_wr_addr_low | first_free_pos[VC_NON_POSTED];
	if(new_packet_available[2].read()) pkt_wr_addr_low = pkt_wr_addr_low | first_free_pos[VC_RESPONSE];


	sc_uint<LOG2_NB_OF_BUFFERS+2> pkt_wr_addr;
	pkt_wr_addr.range(LOG2_NB_OF_BUFFERS-1,0) = pkt_wr_addr_low;
	pkt_wr_addr[LOG2_NB_OF_BUFFERS] = new_packet_available[1];
	pkt_wr_addr[LOG2_NB_OF_BUFFERS+1] = new_packet_available[2];
	ro_command_packet_wr_addr = pkt_wr_addr;
	new_packet_addr = pkt_wr_addr.range(LOG2_NB_OF_BUFFERS-1,0);
}
