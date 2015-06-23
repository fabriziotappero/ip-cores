//fc_packet_crc_l3.cpp

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

#include "fc_packet_crc_l3.h"

fc_packet_crc_l3::fc_packet_crc_l3(sc_module_name name) : sc_module(name)
{
	SC_METHOD(clocked_process);
	sensitive_neg << resetx;
	sensitive_pos << clk;
}

void fc_packet_crc_l3::clocked_process(){
	//At reset, CRC's are set to 0
	if(resetx.read() == false){
		crc_value = 0xFFFFFFFF;
		nop_crc_value = 0xFFFFFFFF;
		crc_output = 0;
		nop_crc_output = 0;
	}
	else{
		//Bu default, the crc values stay the same
		sc_uint<32> new_crc_value = crc_value.read();
		sc_uint<32> new_nop_crc_value = nop_crc_value.read();

		/**
			Before synthesis, this was working with native C ints.  Since on most
			platforms, an int is 32 bits and that we have to treat 34 bits of data
			(the dword + LCTL + HCTL), the data calculation were seperated in two
			passes of 17 bits.
			
			Now that uint are being used, it might be possible to do it in a single
			pass.  But the resulting logic and result is exactly the same.
		*/
		sc_uint<32> inputDword = sc_uint<32>(data_in.read());
		//Generate first data set
		sc_uint<34> d;
		d.range(15,0) = inputDword.range(15,0);
		d[16] = fc_lctl_lk.read();
		
		//Generate second data set
		d.range(32,17) = inputDword.range(31,16);
		d[33] = fc_hctl_lk.read();

		//Choose which register to use for the treatment
		sc_uint<32> crc;
		sc_uint<32> crc_in;
		if(calculate_crc.read()) crc_in = crc_value.read();
		else crc_in = nop_crc_value.read();

		//Calculate the CRC
		/*for (int i=0; i<34; ++i) {
			// xor highest bit w/ message:
			//bool tmp = ((crc >> 31) & 1)^((data1 >> i) & 1);
			bool tmp = crc[31]^data[i];
			
			// subtract poly if greater: 
			//
			//	This next code is equivalent to :
			//		crc = (tmp) ? (crc << 1) ^ poly : ((crc << 1)|tmp);
			//	but is nicer for the synthesis tool

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
		
		if(clear_crc.read()){
			new_crc_value = 0xFFFFFFFF;
		}
		else if(calculate_crc.read()){
			new_crc_value = crc;
		}
		
		if(clear_nop_crc.read()){
			new_nop_crc_value = 0xFFFFFFFF;
		}
		else if(calculate_nop_crc.read()){
			new_nop_crc_value = crc;
		}
		//Assign the new CRC value
		crc_value = new_crc_value;
		nop_crc_value = new_nop_crc_value;

		//Error mask for when forcing errors.  Bits that are '1' will be inversed
		sc_bv<32> error_mask_bv = "10101010101010101010101010101010";
		sc_uint<32> error_mask = error_mask_bv;

		//Output the result with the error mask if requested
		if(csr_force_single_error_fc.read()){
			crc_output = new_crc_value ^ error_mask;
			nop_crc_output = new_nop_crc_value ^ error_mask;
		}
		//Output the CRC value directly.  It is supposed to be inversed, so 
		//a non-inversed CRC represents a stomped packet
		else if(csr_force_single_stomp_fc.read()){
			crc_output = new_crc_value;
			nop_crc_output = ~new_nop_crc_value;
		}
		//Output the inverse of the calculated CRC value (normal behaviour)
		else{
			crc_output = ~new_crc_value;
			nop_crc_output = ~new_nop_crc_value;
		}
	}
}

