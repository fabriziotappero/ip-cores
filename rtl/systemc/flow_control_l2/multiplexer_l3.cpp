//multiplexer_l3.cpp

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

#include "multiplexer_l3.h"

multiplexer_l3::multiplexer_l3(sc_module_name name) : sc_module(name)
{
	SC_METHOD(mux);
	sensitive_pos << clk;
	sensitive_neg << resetx;

	SC_METHOD(output);
	sensitive << registered_output 
#ifdef RETRY_MODE_ENABLED
		<< crc_output << nop_crc_output <<
		select_crc_output << select_nop_crc_output
#endif
		;
}

void multiplexer_l3::mux( void )
{  
	if (resetx == false) {
		registered_output = 0;
	}
	else {	//fin du non-reset
		

#ifdef SYSTEMC_SIM
		//GCC comlains if it's not an int that is used for the switch
		//But for synthesis, I don't want to change it to an int because
		//by default an int has a 32 bit width, which is not what I
		//want for a MUX selector!
		switch ((int)fc_ctr_mux.read()) { //synopsys infer_mux
#else
		switch (fc_ctr_mux.read()) { //synopsys infer_mux
#endif		
		case FC_MUX_FWD_LSB: 		//fowrard CMD is sent (LSB)
			{
			sc_bv<64> packet = fwd_packet.read().packet;
			registered_output = packet.range(31,0);
			}
			break;
			
		case FC_MUX_FWD_MSB :		// Forward CMD is sent (MSB)
			{
			sc_bv<64> packet = fwd_packet.read().packet;
			registered_output = packet.range(63,32);
			}
			break;
			
		case FC_MUX_DB_DATA: 		// Forward data is sent
			registered_output = db_data_fwd;
			break;
			
			
		case FC_MUX_EH :		//Error handler packet is sent (data or CMD)
			registered_output = eh_cmd_data_fc;
			break;
			
		case FC_MUX_CSR: 		//Csr packet is sent (data or CMD
			registered_output = csr_dword_fc;
			break;
			
		case FC_MUX_UI_LSB :		//user CMD is sent (LSB)
			registered_output = user_packet.read().range(31,0);
			break;
			
		case FC_MUX_UI_MSB: 		//user CMD is sent (MSB)
			registered_output = user_packet.read().range(63,32);	
			break;
			
		case FC_MUX_UI_DATA: 		//User data is sent
			registered_output = ui_data_fc;
			break;

		case FC_MUX_NOP :		//nop_sent
			
			registered_output = ht_nop_pkt;
			
			break;
			
#ifdef RETRY_MODE_ENABLED
		case FC_MUX_HISTORY:
			registered_output = history_packet;
			break;
#endif
		default :		//Data not read, keep the same data : FC_MUX_FEEDBACK
			registered_output = registered_output.read();
			
		}
		
	}//fin du non-reset
} // fin de fonction

void multiplexer_l3::output(){
#ifdef RETRY_MODE_ENABLED
	sc_uint<2> selector;
	selector[1] = select_crc_output;
	selector[0] = select_nop_crc_output;

	switch(selector){
	case 2:
		fc_dword_lk = crc_output.read();
		break;
	case 1:
		fc_dword_lk = nop_crc_output.read();
		break;
	default:
		fc_dword_lk = registered_output;
	}
#else
	fc_dword_lk = registered_output;
#endif

}





