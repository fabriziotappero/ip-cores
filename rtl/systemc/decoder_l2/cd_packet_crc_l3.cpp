//cd_packet_crc_l3.cpp

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

#include "cd_packet_crc_l3.h"

cd_packet_crc_l3::cd_packet_crc_l3(sc_module_name name) : sc_module(name)
{
	SC_METHOD(clocked_process);
	sensitive_neg << resetx;
	sensitive_pos << clk;

	SC_METHOD(calculate_outputs);
	sensitive << lk_dword_cd << crc1_value << crc2_value;
}

void cd_packet_crc_l3::clocked_process(){
	//At reset, CRC's are set to 0
	if(resetx.read() == false){
		crc1_value = 0xFFFFFFFF;
		crc2_value = 0xFFFFFFFF;
	}
	else{
		//Start by generating the data vector to process
		sc_uint<32> inputDword = sc_uint<32>(lk_dword_cd.read());		
		sc_uint<34> d;

		//Generate first data set
		d.range(15,0) = inputDword.range(15,0) ;
		d[16] = lk_lctl_cd.read();

		//Generate second data set
		d.range(32,17) = inputDword.range(31,16);
		d[33] = lk_hctl_cd.read();

		//Choose which register to use for the treatment
		sc_uint<32> crc;
		sc_uint<32> crc_in;
		if(crc2_if_ctl.read() && lk_lctl_cd.read()) crc_in = crc2_value.read();
		else crc_in = crc1_value.read();

		//Calculate the CRC1
			//calculate crc1
		/*for (int i=0; i<34; ++i) {
			// xor highest bit w/ message: 
			bool tmp = ((sc_bit)crc[31])^((sc_bit)data[i]);
			
			// subtract poly if greater: This has the same effect as the code
			//in the HT spec : might be slower in software, but it's easier to
			//synthesize to hardware.
			//
			//crc = (tmp) ? (crc << 1) ^ poly : ((crc << 1) | tmp);
			//
			//Because the ? operator is equivalent to
			//an if else, it might create a MUX logic.

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
			crc[0] = tmp;
		}*/
		//Created with Xilinx xapp209
		crc[0] = (sc_bit)( d[24] ^ d[33] ^ crc_in[22] ^ d[17] ^ crc_in[7] ^ d[2] ^ crc_in[24] ^ d[4] ^ crc_in[26] ^ crc_in[28] ^ d[8] ^ d[21] ^ crc_in[10] ^ d[23] ^ crc_in[4] ^ crc_in[30] ^ d[1] ^ crc_in[14] ^ crc_in[23] ^ d[27] ^ d[3] ^ crc_in[8] ^ d[5] ^ crc_in[27] ^ d[7] ^ crc_in[29] ^ d[9]);
		crc[1] = (sc_bit)( d[22] ^ crc_in[11] ^ d[24] ^ d[33] ^ crc_in[5] ^ d[0] ^ crc_in[22] ^ d[17] ^ crc_in[31] ^ d[26] ^ crc_in[7] ^ crc_in[15] ^ crc_in[9] ^ crc_in[26] ^ d[6] ^ d[21] ^ crc_in[10] ^ crc_in[4] ^ d[32] ^ d[16] ^ crc_in[14] ^ d[27] ^ crc_in[25] ^ d[5] ^ d[9] ^ d[20]);
		crc[2] = (sc_bit)( crc_in[11] ^ d[31] ^ d[15] ^ d[24] ^ d[33] ^ crc_in[5] ^ crc_in[22] ^ d[17] ^ d[26] ^ crc_in[7] ^ crc_in[15] ^ d[2] ^ crc_in[24] ^ d[19] ^ crc_in[28] ^ crc_in[0] ^ crc_in[4] ^ d[32] ^ crc_in[12] ^ d[16] ^ crc_in[30] ^ d[25] ^ crc_in[14] ^ crc_in[6] ^ d[1] ^ d[27] ^ crc_in[16] ^ d[3] ^ d[7] ^ crc_in[29] ^ d[9] ^ d[20]);
		crc[3] = (sc_bit)( d[31] ^ d[15] ^ d[24] ^ crc_in[5] ^ crc_in[13] ^ d[0] ^ crc_in[31] ^ d[26] ^ crc_in[15] ^ crc_in[7] ^ d[2] ^ d[19] ^ crc_in[17] ^ d[6] ^ d[8] ^ crc_in[0] ^ d[30] ^ d[14] ^ d[23] ^ d[32] ^ crc_in[12] ^ d[16] ^ crc_in[30] ^ d[25] ^ crc_in[6] ^ d[1] ^ crc_in[23] ^ d[18] ^ crc_in[8] ^ crc_in[16] ^ crc_in[25] ^ crc_in[29] ^ crc_in[1]);
		crc[4] = (sc_bit)( d[13] ^ d[22] ^ d[31] ^ d[15] ^ d[33] ^ crc_in[13] ^ d[0] ^ crc_in[22] ^ crc_in[31] ^ d[2] ^ crc_in[9] ^ crc_in[17] ^ d[4] ^ crc_in[28] ^ d[8] ^ crc_in[0] ^ d[21] ^ d[30] ^ crc_in[2] ^ crc_in[10] ^ d[14] ^ crc_in[4] ^ d[25] ^ crc_in[6] ^ crc_in[23] ^ d[18] ^ d[27] ^ crc_in[16] ^ d[3] ^ d[29] ^ crc_in[18] ^ crc_in[27] ^ crc_in[29] ^ d[9] ^ crc_in[1]);
		crc[5] = (sc_bit)( d[13] ^ crc_in[11] ^ crc_in[3] ^ d[33] ^ crc_in[5] ^ crc_in[22] ^ d[26] ^ d[28] ^ crc_in[17] ^ d[4] ^ crc_in[26] ^ crc_in[19] ^ d[12] ^ d[30] ^ crc_in[2] ^ d[14] ^ d[23] ^ crc_in[4] ^ d[32] ^ d[27] ^ crc_in[8] ^ d[29] ^ d[5] ^ crc_in[18] ^ crc_in[27] ^ d[9] ^ d[20] ^ crc_in[1]);
		crc[6] = (sc_bit)( d[13] ^ d[22] ^ d[31] ^ crc_in[3] ^ crc_in[20] ^ crc_in[5] ^ d[26] ^ d[19] ^ d[28] ^ crc_in[9] ^ d[4] ^ crc_in[19] ^ crc_in[28] ^ d[8] ^ crc_in[0] ^ d[12] ^ crc_in[2] ^ d[32] ^ crc_in[12] ^ crc_in[4] ^ d[25] ^ crc_in[6] ^ crc_in[23] ^ d[27] ^ d[3] ^ d[29] ^ crc_in[18] ^ crc_in[27] ^ d[11]);
		crc[7] = (sc_bit)( d[31] ^ crc_in[3] ^ crc_in[20] ^ d[33] ^ crc_in[13] ^ crc_in[5] ^ crc_in[22] ^ d[17] ^ d[26] ^ d[28] ^ d[4] ^ crc_in[26] ^ crc_in[19] ^ d[8] ^ d[10] ^ crc_in[0] ^ d[12] ^ d[30] ^ d[23] ^ crc_in[21] ^ crc_in[30] ^ d[25] ^ crc_in[6] ^ crc_in[14] ^ d[1] ^ crc_in[23] ^ d[18] ^ crc_in[8] ^ d[5] ^ crc_in[27] ^ d[9] ^ d[11] ^ crc_in[1]);
		crc[8] = (sc_bit)( d[22] ^ crc_in[20] ^ d[33] ^ d[0] ^ crc_in[31] ^ d[2] ^ crc_in[15] ^ crc_in[9] ^ crc_in[26] ^ d[10] ^ d[21] ^ d[30] ^ crc_in[2] ^ crc_in[10] ^ d[23] ^ d[32] ^ crc_in[21] ^ d[16] ^ crc_in[30] ^ d[25] ^ d[1] ^ crc_in[6] ^ crc_in[8] ^ d[29] ^ d[5] ^ crc_in[29] ^ d[11] ^ crc_in[1]);
		crc[9] = (sc_bit)( d[22] ^ d[31] ^ crc_in[3] ^ crc_in[11] ^ d[15] ^ d[24] ^ d[0] ^ crc_in[22] ^ crc_in[31] ^ crc_in[7] ^ d[28] ^ crc_in[9] ^ d[4] ^ d[10] ^ crc_in[0] ^ d[21] ^ crc_in[2] ^ crc_in[10] ^ d[32] ^ crc_in[21] ^ crc_in[30] ^ d[1] ^ crc_in[16] ^ d[29] ^ crc_in[27] ^ d[9] ^ d[20]);
		crc[10] = (sc_bit)( d[31] ^ crc_in[11] ^ crc_in[3] ^ d[24] ^ d[33] ^ d[0] ^ crc_in[31] ^ d[17] ^ crc_in[7] ^ d[2] ^ crc_in[24] ^ d[19] ^ d[28] ^ crc_in[17] ^ d[4] ^ crc_in[26] ^ crc_in[0] ^ d[30] ^ d[14] ^ crc_in[12] ^ crc_in[30] ^ crc_in[14] ^ d[1] ^ d[5] ^ crc_in[27] ^ d[7] ^ crc_in[29] ^ d[20] ^ crc_in[1]);
		crc[11] = (sc_bit)( d[13] ^ d[24] ^ d[33] ^ crc_in[13] ^ d[0] ^ crc_in[22] ^ d[17] ^ crc_in[31] ^ crc_in[7] ^ crc_in[15] ^ d[2] ^ crc_in[24] ^ d[19] ^ crc_in[26] ^ d[6] ^ d[8] ^ d[21] ^ d[30] ^ crc_in[2] ^ crc_in[10] ^ d[32] ^ crc_in[12] ^ d[16] ^ crc_in[14] ^ crc_in[23] ^ d[18] ^ crc_in[25] ^ d[29] ^ d[5] ^ crc_in[18] ^ d[7] ^ crc_in[29] ^ d[9] ^ crc_in[1]);
		crc[12] = (sc_bit)( d[31] ^ crc_in[3] ^ crc_in[11] ^ d[15] ^ d[24] ^ d[33] ^ crc_in[13] ^ crc_in[22] ^ crc_in[7] ^ crc_in[15] ^ d[2] ^ d[28] ^ d[6] ^ crc_in[19] ^ crc_in[28] ^ crc_in[0] ^ d[12] ^ d[21] ^ crc_in[2] ^ crc_in[10] ^ crc_in[4] ^ d[32] ^ d[16] ^ d[18] ^ d[27] ^ crc_in[16] ^ d[3] ^ crc_in[25] ^ d[29] ^ crc_in[29] ^ d[9] ^ d[20]);
		crc[13] = (sc_bit)( d[31] ^ crc_in[3] ^ crc_in[11] ^ crc_in[20] ^ d[15] ^ crc_in[5] ^ d[17] ^ d[26] ^ d[2] ^ d[19] ^ d[28] ^ crc_in[17] ^ crc_in[26] ^ d[8] ^ crc_in[0] ^ d[30] ^ d[14] ^ d[23] ^ d[32] ^ crc_in[4] ^ crc_in[12] ^ crc_in[30] ^ crc_in[14] ^ d[1] ^ crc_in[23] ^ d[27] ^ crc_in[8] ^ crc_in[16] ^ d[5] ^ crc_in[29] ^ d[11] ^ d[20] ^ crc_in[1]);
		crc[14] = (sc_bit)( d[13] ^ d[22] ^ d[31] ^ crc_in[5] ^ crc_in[13] ^ d[0] ^ crc_in[31] ^ d[26] ^ crc_in[15] ^ crc_in[24] ^ d[19] ^ crc_in[9] ^ crc_in[17] ^ d[4] ^ d[10] ^ crc_in[0] ^ d[30] ^ crc_in[2] ^ d[14] ^ crc_in[4] ^ crc_in[12] ^ crc_in[21] ^ d[16] ^ crc_in[30] ^ d[25] ^ crc_in[6] ^ d[1] ^ d[18] ^ d[27] ^ d[29] ^ crc_in[18] ^ crc_in[27] ^ d[7] ^ crc_in[1]);
		crc[15] = (sc_bit)( d[13] ^ crc_in[3] ^ d[15] ^ d[24] ^ crc_in[5] ^ d[0] ^ crc_in[13] ^ crc_in[22] ^ d[17] ^ crc_in[31] ^ d[26] ^ crc_in[7] ^ d[28] ^ d[6] ^ crc_in[19] ^ crc_in[28] ^ d[12] ^ d[21] ^ d[30] ^ crc_in[2] ^ crc_in[10] ^ d[25] ^ crc_in[6] ^ crc_in[14] ^ d[18] ^ crc_in[16] ^ d[3] ^ crc_in[25] ^ d[29] ^ crc_in[18] ^ d[9] ^ crc_in[1]);
		crc[16] = (sc_bit)( crc_in[11] ^ crc_in[3] ^ crc_in[20] ^ d[33] ^ crc_in[22] ^ crc_in[15] ^ crc_in[24] ^ d[28] ^ crc_in[17] ^ d[4] ^ crc_in[19] ^ crc_in[28] ^ d[12] ^ d[21] ^ crc_in[2] ^ crc_in[10] ^ d[14] ^ d[16] ^ crc_in[30] ^ d[25] ^ crc_in[6] ^ d[1] ^ d[3] ^ d[29] ^ crc_in[27] ^ d[7] ^ d[9] ^ d[11] ^ d[20]);
		crc[17] = (sc_bit)( d[13] ^ crc_in[3] ^ crc_in[11] ^ crc_in[20] ^ d[15] ^ d[24] ^ d[0] ^ crc_in[31] ^ crc_in[7] ^ d[2] ^ d[19] ^ d[28] ^ d[6] ^ crc_in[28] ^ d[8] ^ d[10] ^ d[32] ^ crc_in[12] ^ crc_in[4] ^ crc_in[21] ^ crc_in[23] ^ d[27] ^ crc_in[16] ^ d[3] ^ crc_in[25] ^ crc_in[18] ^ crc_in[29] ^ d[11] ^ d[20]);
		crc[18] = (sc_bit)( d[31] ^ crc_in[13] ^ crc_in[5] ^ crc_in[22] ^ d[26] ^ d[2] ^ crc_in[24] ^ d[19] ^ crc_in[17] ^ crc_in[26] ^ crc_in[19] ^ d[10] ^ crc_in[0] ^ d[12] ^ d[14] ^ d[23] ^ crc_in[4] ^ crc_in[12] ^ crc_in[21] ^ crc_in[30] ^ d[1] ^ d[18] ^ d[27] ^ crc_in[8] ^ d[5] ^ d[7] ^ crc_in[29] ^ d[9]);
		crc[19] = (sc_bit)( d[13] ^ d[22] ^ crc_in[20] ^ crc_in[5] ^ crc_in[13] ^ d[0] ^ crc_in[22] ^ d[17] ^ crc_in[31] ^ d[26] ^ crc_in[9] ^ d[4] ^ d[6] ^ d[8] ^ d[30] ^ crc_in[30] ^ d[25] ^ crc_in[14] ^ crc_in[6] ^ d[1] ^ crc_in[23] ^ d[18] ^ crc_in[25] ^ crc_in[18] ^ crc_in[27] ^ d[9] ^ d[11] ^ crc_in[1]);
		crc[20] = (sc_bit)( d[24] ^ d[0] ^ d[17] ^ crc_in[31] ^ crc_in[15] ^ crc_in[7] ^ crc_in[24] ^ crc_in[26] ^ crc_in[19] ^ crc_in[28] ^ d[8] ^ d[10] ^ d[12] ^ d[21] ^ crc_in[2] ^ crc_in[10] ^ crc_in[21] ^ d[16] ^ d[25] ^ crc_in[6] ^ crc_in[14] ^ crc_in[23] ^ d[3] ^ d[29] ^ d[5] ^ d[7]);
		crc[21] = (sc_bit)( crc_in[3] ^ crc_in[11] ^ crc_in[20] ^ d[15] ^ d[24] ^ crc_in[22] ^ crc_in[7] ^ crc_in[15] ^ d[2] ^ crc_in[24] ^ d[28] ^ d[4] ^ d[6] ^ d[23] ^ d[16] ^ crc_in[16] ^ crc_in[8] ^ crc_in[25] ^ crc_in[27] ^ d[7] ^ crc_in[29] ^ d[9] ^ d[11] ^ d[20]);
		crc[22] = (sc_bit)( d[22] ^ d[15] ^ d[24] ^ d[33] ^ crc_in[22] ^ d[17] ^ crc_in[7] ^ d[2] ^ crc_in[24] ^ d[19] ^ crc_in[17] ^ crc_in[9] ^ d[4] ^ d[6] ^ d[10] ^ d[21] ^ crc_in[10] ^ d[14] ^ crc_in[12] ^ crc_in[21] ^ crc_in[14] ^ crc_in[16] ^ crc_in[25] ^ crc_in[27] ^ d[7] ^ crc_in[29] ^ d[9]);
		crc[23] = (sc_bit)( d[13] ^ crc_in[11] ^ d[24] ^ d[33] ^ crc_in[13] ^ d[17] ^ crc_in[7] ^ crc_in[15] ^ d[2] ^ crc_in[24] ^ crc_in[17] ^ d[4] ^ d[6] ^ d[14] ^ crc_in[4] ^ d[32] ^ d[16] ^ crc_in[14] ^ d[18] ^ d[27] ^ crc_in[25] ^ crc_in[18] ^ crc_in[27] ^ d[7] ^ crc_in[29] ^ d[20]);
		crc[24] = (sc_bit)( d[13] ^ d[31] ^ d[15] ^ crc_in[5] ^ d[17] ^ d[26] ^ crc_in[15] ^ d[19] ^ crc_in[26] ^ crc_in[19] ^ d[6] ^ crc_in[28] ^ crc_in[0] ^ d[12] ^ d[23] ^ d[32] ^ crc_in[12] ^ d[16] ^ crc_in[30] ^ crc_in[14] ^ d[1] ^ crc_in[8] ^ crc_in[16] ^ d[3] ^ crc_in[25] ^ crc_in[18] ^ d[5]);
		crc[25] = (sc_bit)( d[22] ^ d[31] ^ crc_in[20] ^ d[15] ^ crc_in[13] ^ d[0] ^ crc_in[31] ^ crc_in[15] ^ d[2] ^ crc_in[9] ^ crc_in[17] ^ d[4] ^ crc_in[26] ^ crc_in[19] ^ crc_in[0] ^ d[12] ^ d[30] ^ d[14] ^ d[16] ^ d[25] ^ crc_in[6] ^ d[18] ^ crc_in[16] ^ d[5] ^ crc_in[27] ^ crc_in[29] ^ d[11] ^ crc_in[1]);
		crc[26] = (sc_bit)( d[13] ^ crc_in[20] ^ d[15] ^ d[33] ^ crc_in[22] ^ d[2] ^ crc_in[24] ^ crc_in[17] ^ crc_in[26] ^ d[8] ^ d[10] ^ d[30] ^ crc_in[2] ^ d[14] ^ d[23] ^ crc_in[4] ^ crc_in[21] ^ crc_in[23] ^ d[27] ^ crc_in[8] ^ crc_in[16] ^ d[29] ^ crc_in[18] ^ d[5] ^ d[7] ^ crc_in[29] ^ d[9] ^ d[11] ^ crc_in[1]);
		crc[27] = (sc_bit)( d[13] ^ d[22] ^ crc_in[3] ^ crc_in[5] ^ crc_in[22] ^ d[26] ^ crc_in[24] ^ d[28] ^ crc_in[9] ^ crc_in[17] ^ d[4] ^ crc_in[19] ^ d[6] ^ d[8] ^ d[10] ^ d[12] ^ crc_in[2] ^ d[14] ^ d[32] ^ crc_in[21] ^ crc_in[30] ^ d[1] ^ crc_in[23] ^ crc_in[25] ^ d[29] ^ crc_in[18] ^ crc_in[27] ^ d[7] ^ d[9]);
		crc[28] = (sc_bit)( d[13] ^ d[31] ^ crc_in[3] ^ crc_in[20] ^ d[0] ^ crc_in[22] ^ crc_in[31] ^ crc_in[24] ^ d[28] ^ crc_in[26] ^ crc_in[19] ^ d[6] ^ crc_in[28] ^ d[8] ^ crc_in[0] ^ d[12] ^ d[21] ^ crc_in[10] ^ crc_in[4] ^ d[25] ^ crc_in[6] ^ crc_in[23] ^ d[27] ^ d[3] ^ crc_in[25] ^ crc_in[18] ^ d[5] ^ d[7] ^ d[9] ^ d[11]);
		crc[29] = (sc_bit)( crc_in[11] ^ crc_in[20] ^ d[24] ^ crc_in[5] ^ d[26] ^ crc_in[7] ^ d[2] ^ crc_in[24] ^ d[4] ^ crc_in[26] ^ crc_in[19] ^ d[6] ^ d[8] ^ d[10] ^ d[12] ^ d[30] ^ crc_in[4] ^ crc_in[21] ^ crc_in[23] ^ d[27] ^ crc_in[25] ^ d[5] ^ crc_in[27] ^ d[7] ^ crc_in[29] ^ d[11] ^ d[20] ^ crc_in[1]);
		crc[30] = (sc_bit)( crc_in[20] ^ crc_in[5] ^ crc_in[22] ^ d[26] ^ crc_in[24] ^ d[19] ^ d[4] ^ crc_in[26] ^ d[6] ^ crc_in[28] ^ d[10] ^ crc_in[2] ^ d[23] ^ crc_in[12] ^ crc_in[21] ^ crc_in[30] ^ d[25] ^ crc_in[6] ^ d[1] ^ crc_in[8] ^ d[3] ^ crc_in[25] ^ d[29] ^ d[5] ^ crc_in[27] ^ d[7] ^ d[9] ^ d[11]);
		crc[31] = (sc_bit)( d[22] ^ crc_in[3] ^ d[24] ^ crc_in[13] ^ d[0] ^ crc_in[22] ^ crc_in[31] ^ crc_in[7] ^ d[2] ^ d[28] ^ crc_in[9] ^ d[4] ^ crc_in[26] ^ d[6] ^ crc_in[28] ^ d[8] ^ d[10] ^ crc_in[21] ^ d[25] ^ crc_in[6] ^ crc_in[23] ^ d[18] ^ d[3] ^ crc_in[25] ^ d[5] ^ crc_in[27] ^ crc_in[29] ^ d[9]);
				
		if(crc1_reset.read()){
			crc1_value = 0xFFFFFFFF;
		}
		else if(crc1_enable.read()){
			crc1_value = crc;
		}
		else
			crc1_value = crc1_value;
		
		if(crc2_reset.read()){
			crc2_value = 0xFFFFFFFF;
		}
		else if(crc2_enable.read()){
			crc2_value = crc;
		}
		else
			crc2_value = crc2_value;

	}
}

void cd_packet_crc_l3::calculate_outputs(){
	sc_bv<32> inv_dword;
	for(unsigned n = 0; n < 32; n++){
		inv_dword[n] = !((sc_bit)(lk_dword_cd.read()[n]));
	}

	/**
		To catch a wider range of errors, the per-packet CRC is inversed
		before being sent.  So if what is received is exactly the inverse
		of what we calculated, the result is good.  If it's exactly the
		same, it means the packet is stomped.
	*/
	crc1_good = false;
	crc1_stomped = false;
	crc2_good = false;
	crc2_stomped = false;
	if(sc_bv<32>(crc1_value.read()) == inv_dword) crc1_good = true;
	if(sc_bv<32>(crc1_value.read()) == lk_dword_cd.read()) crc1_stomped = true;

	if(sc_bv<32>(crc2_value.read()) == inv_dword) crc2_good = true;
	if(sc_bv<32>(crc2_value.read()) == lk_dword_cd.read()) crc2_stomped = true;
}
