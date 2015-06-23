//nop_framer_l3.cpp

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

#include "nop_framer_l3.h"

nop_framer_l3::nop_framer_l3(sc_module_name name) : sc_module(name)
{
	SC_METHOD(nop_decision);
		sensitive_pos << clock ;
		sensitive_neg << resetx;

	SC_METHOD(framer);
		sensitive << ro_buffer_cnt_fc << db_buffer_cnt_fc << resetx
			<< generate_disconnect_nop
#ifdef RETRY_MODE_ENABLED
			 << cd_rx_next_pkt_to_ack_fc
#endif
			 ;


}

void nop_framer_l3::nop_decision( void )
{  
	/**
		nop_next_to_send_tmp is to remember if a nop has been requested and has not
		been sent yet.  So it set when ro_nop_req_fc or db_nop_req_fc is
		set, and cleard when fc_nop_sent is set.
	*/
	if(!resetx.read()){
		nop_next_to_send = false;
	}
	else{
		//Clear nop_next_to_send_tmp when the requested nop is sent
		if(fc_nop_sent == true)
			nop_next_to_send = false;
		else if (ro_nop_req_fc ==  true || db_nop_req_fc ==  true)
			nop_next_to_send = true;
		//Or else we stay the same
		else
			nop_next_to_send = nop_next_to_send.read();
	}
}

  /**
  Function framer
  
	Function that concatenate the information contain in the data_buffer and cmd_buffer
	to produce a HT nop packet.
**/                       
void nop_framer_l3::framer( void )
{          
	// temporary variable    
    sc_bv<32> ht_nop_pkt_tmp = 0;
	
	/*
    sc_bv<2> PC;		//bit 0-1 de ro_buffer
    sc_bv<2> PD;		//bit 0-1 de db
    sc_bv<2> R;			//bit 2-3 de ro_buffer	
    sc_bv<2> RD;		//bit 2-3 de db
    sc_bv<2> NPC;		//bit 4-5 de ro_buffe
    sc_bv<2> NPD;		//bit 4-5 de db
	*/
	
	ht_nop_pkt_tmp.range(9,8) = ro_buffer_cnt_fc.read().range(1,0);//bit 0-1 de ro_buffer	
	ht_nop_pkt_tmp.range(11,10) = db_buffer_cnt_fc.read().range(1,0);//bit 0-1 de db_buffer	
	ht_nop_pkt_tmp.range(13,12) = ro_buffer_cnt_fc.read().range(3,2);//bit 2-3 de ro_buffer	
	ht_nop_pkt_tmp.range(15,14) = db_buffer_cnt_fc.read().range(3,2);//bit 2-3 de db_buffer	
	ht_nop_pkt_tmp.range(17,16) = ro_buffer_cnt_fc.read().range(5,4);//bit 4-5 de ro_buffer
	ht_nop_pkt_tmp.range(19,18) = db_buffer_cnt_fc.read().range(5,4);//bit 4-5 de db_buffer
#ifdef RETRY_MODE_ENABLED
	//Only add the ack value if the retry mode is active, otherwise send value 0
	if(csr_retry.read()){
		ht_nop_pkt_tmp.range(31,24) = sc_bv<8>(cd_rx_next_pkt_to_ack_fc.read());
	}
#endif

	if(generate_disconnect_nop.read()){
		ht_nop_pkt = "00000000000000000000000001000000";
	}
	else{
		ht_nop_pkt = ht_nop_pkt_tmp;
	}

	has_nop_buffers_to_send = !(sc_uint<6>(ro_buffer_cnt_fc.read()) == 0 && 
							sc_uint<6>(db_buffer_cnt_fc.read()) == 0);
}


