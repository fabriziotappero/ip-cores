//rx_farend_cnt_l3.cpp

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

#include "rx_farend_cnt_l3.h"

rx_farend_cnt_l3::rx_farend_cnt_l3(sc_module_name name) : sc_module(name)
{
	// generate est un thread
	SC_METHOD(compte_buffer);
		sensitive_pos << clock;
		sensitive_neg << resetx;
}


void rx_farend_cnt_l3::compte_buffer( void ) {
	//When reset, reinitialize the buffer count
	if (resetx.read() == false) {
		for (int i=0 ;i < 6 ; i++) {
			buffercount[i] = 0;
		}
		fwd_next_node_buffer_status_ro = "000000";
	} else {
#ifdef RETRY_MODE_ENABLED
		//During a retry sequence, the next node buffer count is reinitialized
		if(clear_farend_count.read() == true){
			for (int i=0 ;i < 6 ; i++) {
				buffercount[i] = 0;
			}
		}
		else
#endif
		{
			//Increase the count when a nop is received
			sc_uint<FAREND_BUFFER_COUNT_SIZE + 1> buffercount_tmp[6] ;
			if ( cd_nop_received_fc == true) {

				//Temporary array of count which is one bit larger than the registry to allow
				//overflow, which can then be saturated

				//increment then buffercount according to the nop received

				//response data
				buffercount_tmp[0] = buffercount[0].read() + (cd_nopinfo_fc.read().range(7,6)).to_uint();
				//response command
				buffercount_tmp[1] = buffercount[1].read() + (cd_nopinfo_fc.read().range(5,4)).to_uint();
				//non-posted data
				buffercount_tmp[2] = buffercount[2].read() +
									 (cd_nopinfo_fc.read().range(11,10)).to_uint();
				//non-posted command
				buffercount_tmp[3] = buffercount[3].read() + (cd_nopinfo_fc.read().range(9,8)).to_uint();
				//posted data
				buffercount_tmp[4] = buffercount[4].read() + (cd_nopinfo_fc.read().range(3,2)).to_uint();
				//posted command
				buffercount_tmp[5] = buffercount[5].read() + (cd_nopinfo_fc.read().range(1,0)).to_uint();
			} else {
				for(int n = 0; n < 6; n++) {
					buffercount_tmp[n] = buffercount[n].read();
				}
			}

			//saturate the integer if the increment caused an overflow
			for (int n = 0 ;n < 6 ; n++) {
				if(buffercount_tmp[n][FAREND_BUFFER_COUNT_SIZE] == true) {
					buffercount_tmp[n] = FAREND_BUFFER_COUNT_MAX_VALUE;
				} else {
					buffercount_tmp[n] = buffercount_tmp[n].range(FAREND_BUFFER_COUNT_SIZE - 1,0);
				}
			}


			//Decrease the count when packet nop is sent
			for (int n = 0 ;n < 6 ; n++) {

				//decrement the buffercount if it is of the type being sent
				if (current_sent_type.read()[n] == true ) {
					buffercount_tmp[n] = buffercount_tmp[n] - 1;
				}
				buffercount[n] = buffercount_tmp[n];

			}

			//Output the result
			sc_bv<6> fwd_next_node_buffer_status_ro_tmp;
			for (int i=0 ;i < 6 ; i++) {
				if (buffercount[i].read() != 0 ) {
					fwd_next_node_buffer_status_ro_tmp[i] = true;
				} else {

					fwd_next_node_buffer_status_ro_tmp[i] = false;
				}
			}
			fwd_next_node_buffer_status_ro = fwd_next_node_buffer_status_ro_tmp;
		}
	}
}

