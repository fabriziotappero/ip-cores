/////////////////////////////////////////////////////////////////////
////                                                             ////
////  JPEG Encoder Core - Verilog                                ////
////                                                             ////
////  Author: David Lundgren                                     ////
////          davidklun@gmail.com                                ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2009 David Lundgren                           ////
////                  davidklun@gmail.com                        ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

/* This module is the Huffman encoder.  It takes in the quantized outputs
from the quantizer, and creates the Huffman codes from these value.  The 
output from this module is the jpeg code of the actual pixel data.  The jpeg
file headers will need to be generated separately.  The Huffman codes are constant, 
and they can be changed by changing the parameters in this module. */

`timescale 1ns / 100ps
		
module cr_huff(clk, rst, enable,
Cr11, Cr12, Cr13, Cr14, Cr15, Cr16, Cr17, Cr18, Cr21, Cr22, Cr23, Cr24, Cr25, Cr26, Cr27, Cr28,
Cr31, Cr32, Cr33, Cr34, Cr35, Cr36, Cr37, Cr38, Cr41, Cr42, Cr43, Cr44, Cr45, Cr46, Cr47, Cr48,
Cr51, Cr52, Cr53, Cr54, Cr55, Cr56, Cr57, Cr58, Cr61, Cr62, Cr63, Cr64, Cr65, Cr66, Cr67, Cr68,
Cr71, Cr72, Cr73, Cr74, Cr75, Cr76, Cr77, Cr78, Cr81, Cr82, Cr83, Cr84, Cr85, Cr86, Cr87, Cr88,
JPEG_bitstream, data_ready, output_reg_count, end_of_block_empty);
input		clk;
input		rst;
input		enable;
input  [10:0]  Cr11, Cr12, Cr13, Cr14, Cr15, Cr16, Cr17, Cr18, Cr21, Cr22, Cr23, Cr24;
input  [10:0]  Cr25, Cr26, Cr27, Cr28, Cr31, Cr32, Cr33, Cr34, Cr35, Cr36, Cr37, Cr38;
input  [10:0]  Cr41, Cr42, Cr43, Cr44, Cr45, Cr46, Cr47, Cr48, Cr51, Cr52, Cr53, Cr54;
input  [10:0]  Cr55, Cr56, Cr57, Cr58, Cr61, Cr62, Cr63, Cr64, Cr65, Cr66, Cr67, Cr68;
input  [10:0]  Cr71, Cr72, Cr73, Cr74, Cr75, Cr76, Cr77, Cr78, Cr81, Cr82, Cr83, Cr84;
input  [10:0]  Cr85, Cr86, Cr87, Cr88;
output	[31:0]	JPEG_bitstream;
output	data_ready;
output	output_reg_count;
output	end_of_block_empty;
		

reg		[7:0] block_counter;
reg		[11:0]  Cr11_amp, Cr11_1_pos, Cr11_1_neg, Cr11_diff;
reg		[11:0]  Cr11_previous, Cr11_1;
reg		[10:0]  Cr12_amp, Cr12_pos, Cr12_neg;
reg		[10:0]  Cr21_pos, Cr21_neg, Cr31_pos, Cr31_neg, Cr22_pos, Cr22_neg;
reg		[10:0]  Cr13_pos, Cr13_neg, Cr14_pos, Cr14_neg, Cr15_pos, Cr15_neg;
reg		[10:0]  Cr16_pos, Cr16_neg, Cr17_pos, Cr17_neg, Cr18_pos, Cr18_neg;
reg		[10:0]  Cr23_pos, Cr23_neg, Cr24_pos, Cr24_neg, Cr25_pos, Cr25_neg;
reg		[10:0]  Cr26_pos, Cr26_neg, Cr27_pos, Cr27_neg, Cr28_pos, Cr28_neg;
reg		[10:0]  Cr32_pos, Cr32_neg;
reg		[10:0]  Cr33_pos, Cr33_neg, Cr34_pos, Cr34_neg, Cr35_pos, Cr35_neg;
reg		[10:0]  Cr36_pos, Cr36_neg, Cr37_pos, Cr37_neg, Cr38_pos, Cr38_neg;
reg		[10:0]  Cr41_pos, Cr41_neg, Cr42_pos, Cr42_neg;
reg		[10:0]  Cr43_pos, Cr43_neg, Cr44_pos, Cr44_neg, Cr45_pos, Cr45_neg;
reg		[10:0]  Cr46_pos, Cr46_neg, Cr47_pos, Cr47_neg, Cr48_pos, Cr48_neg;
reg		[10:0]  Cr51_pos, Cr51_neg, Cr52_pos, Cr52_neg;
reg		[10:0]  Cr53_pos, Cr53_neg, Cr54_pos, Cr54_neg, Cr55_pos, Cr55_neg;
reg		[10:0]  Cr56_pos, Cr56_neg, Cr57_pos, Cr57_neg, Cr58_pos, Cr58_neg;
reg		[10:0]  Cr61_pos, Cr61_neg, Cr62_pos, Cr62_neg;
reg		[10:0]  Cr63_pos, Cr63_neg, Cr64_pos, Cr64_neg, Cr65_pos, Cr65_neg;
reg		[10:0]  Cr66_pos, Cr66_neg, Cr67_pos, Cr67_neg, Cr68_pos, Cr68_neg;
reg		[10:0]  Cr71_pos, Cr71_neg, Cr72_pos, Cr72_neg;
reg		[10:0]  Cr73_pos, Cr73_neg, Cr74_pos, Cr74_neg, Cr75_pos, Cr75_neg;
reg		[10:0]  Cr76_pos, Cr76_neg, Cr77_pos, Cr77_neg, Cr78_pos, Cr78_neg;
reg		[10:0]  Cr81_pos, Cr81_neg, Cr82_pos, Cr82_neg;
reg		[10:0]  Cr83_pos, Cr83_neg, Cr84_pos, Cr84_neg, Cr85_pos, Cr85_neg;
reg		[10:0]  Cr86_pos, Cr86_neg, Cr87_pos, Cr87_neg, Cr88_pos, Cr88_neg;
reg		[3:0]	Cr11_bits_pos, Cr11_bits_neg, Cr11_bits, Cr11_bits_1;
reg		[3:0]	Cr12_bits_pos, Cr12_bits_neg, Cr12_bits, Cr12_bits_1; 
reg		[3:0]	Cr12_bits_2, Cr12_bits_3;
reg		Cr11_msb, Cr12_msb, Cr12_msb_1, data_ready;
reg		enable_1, enable_2, enable_3, enable_4, enable_5, enable_6;
reg		enable_7, enable_8, enable_9, enable_10, enable_11, enable_12;
reg		enable_13, enable_module, enable_latch_7, enable_latch_8;
reg		Cr12_et_zero, rollover, rollover_1, rollover_2, rollover_3;
reg		rollover_4, rollover_5, rollover_6, rollover_7;
reg		Cr21_et_zero, Cr21_msb, Cr31_et_zero, Cr31_msb;
reg		Cr22_et_zero, Cr22_msb, Cr13_et_zero, Cr13_msb;
reg		Cr14_et_zero, Cr14_msb, Cr15_et_zero, Cr15_msb;
reg		Cr16_et_zero, Cr16_msb, Cr17_et_zero, Cr17_msb;
reg		Cr18_et_zero, Cr18_msb;
reg		Cr23_et_zero, Cr23_msb, Cr24_et_zero, Cr24_msb;
reg		Cr25_et_zero, Cr25_msb, Cr26_et_zero, Cr26_msb;
reg		Cr27_et_zero, Cr27_msb, Cr28_et_zero, Cr28_msb;
reg		Cr32_et_zero, Cr32_msb, Cr33_et_zero, Cr33_msb;
reg		Cr34_et_zero, Cr34_msb, Cr35_et_zero, Cr35_msb;
reg		Cr36_et_zero, Cr36_msb, Cr37_et_zero, Cr37_msb;
reg		Cr38_et_zero, Cr38_msb;
reg		Cr41_et_zero, Cr41_msb, Cr42_et_zero, Cr42_msb;
reg		Cr43_et_zero, Cr43_msb, Cr44_et_zero, Cr44_msb;
reg		Cr45_et_zero, Cr45_msb, Cr46_et_zero, Cr46_msb;
reg		Cr47_et_zero, Cr47_msb, Cr48_et_zero, Cr48_msb;
reg		Cr51_et_zero, Cr51_msb, Cr52_et_zero, Cr52_msb;
reg		Cr53_et_zero, Cr53_msb, Cr54_et_zero, Cr54_msb;
reg		Cr55_et_zero, Cr55_msb, Cr56_et_zero, Cr56_msb;
reg		Cr57_et_zero, Cr57_msb, Cr58_et_zero, Cr58_msb;
reg		Cr61_et_zero, Cr61_msb, Cr62_et_zero, Cr62_msb;
reg		Cr63_et_zero, Cr63_msb, Cr64_et_zero, Cr64_msb;
reg		Cr65_et_zero, Cr65_msb, Cr66_et_zero, Cr66_msb;
reg		Cr67_et_zero, Cr67_msb, Cr68_et_zero, Cr68_msb;
reg		Cr71_et_zero, Cr71_msb, Cr72_et_zero, Cr72_msb;
reg		Cr73_et_zero, Cr73_msb, Cr74_et_zero, Cr74_msb;
reg		Cr75_et_zero, Cr75_msb, Cr76_et_zero, Cr76_msb;
reg		Cr77_et_zero, Cr77_msb, Cr78_et_zero, Cr78_msb;
reg		Cr81_et_zero, Cr81_msb, Cr82_et_zero, Cr82_msb;
reg		Cr83_et_zero, Cr83_msb, Cr84_et_zero, Cr84_msb;
reg		Cr85_et_zero, Cr85_msb, Cr86_et_zero, Cr86_msb;
reg		Cr87_et_zero, Cr87_msb, Cr88_et_zero, Cr88_msb;
reg 	Cr12_et_zero_1, Cr12_et_zero_2, Cr12_et_zero_3, Cr12_et_zero_4, Cr12_et_zero_5;
reg		[10:0] Cr_DC [11:0];
reg 	[3:0] Cr_DC_code_length [11:0];
reg		[15:0] Cr_AC [161:0];
reg 	[4:0] Cr_AC_code_length [161:0];
reg 	[7:0] Cr_AC_run_code [250:0];
reg		[10:0] Cr11_Huff, Cr11_Huff_1, Cr11_Huff_2;
reg		[15:0] Cr12_Huff, Cr12_Huff_1, Cr12_Huff_2;
reg		[3:0] Cr11_Huff_count, Cr11_Huff_shift, Cr11_Huff_shift_1, Cr11_amp_shift, Cr12_amp_shift;
reg		[3:0] Cr12_Huff_shift, Cr12_Huff_shift_1, zero_run_length, zrl_1, zrl_2, zrl_3;
reg		[4:0] Cr12_Huff_count, Cr12_Huff_count_1;
reg		[4:0] output_reg_count, Cr11_output_count, old_orc_1, old_orc_2;
reg		[4:0] old_orc_3, old_orc_4, old_orc_5, old_orc_6, Cr12_oc_1;
reg		[4:0] orc_3, orc_4, orc_5, orc_6, orc_7, orc_8;
reg		[4:0] Cr12_output_count;
reg 	[4:0] Cr12_edge, Cr12_edge_1, Cr12_edge_2, Cr12_edge_3, Cr12_edge_4;
reg		[31:0]	JPEG_bitstream, JPEG_bs, JPEG_bs_1, JPEG_bs_2, JPEG_bs_3, JPEG_bs_4, JPEG_bs_5;
reg		[31:0]	JPEG_Cr12_bs, JPEG_Cr12_bs_1, JPEG_Cr12_bs_2, JPEG_Cr12_bs_3, JPEG_Cr12_bs_4;
reg		[31:0]	JPEG_ro_bs, JPEG_ro_bs_1, JPEG_ro_bs_2, JPEG_ro_bs_3, JPEG_ro_bs_4;
reg		[21:0]	Cr11_JPEG_LSBs_3;
reg		[10:0]	Cr11_JPEG_LSBs, Cr11_JPEG_LSBs_1, Cr11_JPEG_LSBs_2;
reg		[9:0]	Cr12_JPEG_LSBs, Cr12_JPEG_LSBs_1, Cr12_JPEG_LSBs_2, Cr12_JPEG_LSBs_3;
reg		[25:0]	Cr11_JPEG_bits, Cr11_JPEG_bits_1, Cr12_JPEG_bits, Cr12_JPEG_LSBs_4;	  
reg		[7:0]	Cr12_code_entry;
reg		third_8_all_0s, fourth_8_all_0s, fifth_8_all_0s, sixth_8_all_0s, seventh_8_all_0s;
reg		eighth_8_all_0s, end_of_block, code_15_0, zrl_et_15, end_of_block_output;
reg		end_of_block_empty;

wire	[7:0]	code_index = { zrl_2, Cr12_bits };



always @(posedge clk)
begin
	if (rst) begin
		third_8_all_0s <= 0; fourth_8_all_0s <= 0;
		fifth_8_all_0s <= 0; sixth_8_all_0s <= 0; seventh_8_all_0s <= 0;
		eighth_8_all_0s <= 0;
		end
	else if (enable_1) begin
		third_8_all_0s <= Cr25_et_zero & Cr34_et_zero & Cr43_et_zero & Cr52_et_zero
					  & Cr61_et_zero & Cr71_et_zero & Cr62_et_zero & Cr53_et_zero;
		fourth_8_all_0s <= Cr44_et_zero & Cr35_et_zero & Cr26_et_zero & Cr17_et_zero
					  & Cr18_et_zero & Cr27_et_zero & Cr36_et_zero & Cr45_et_zero;
		fifth_8_all_0s <= Cr54_et_zero & Cr63_et_zero & Cr72_et_zero & Cr81_et_zero
					  & Cr82_et_zero & Cr73_et_zero & Cr64_et_zero & Cr55_et_zero;
		sixth_8_all_0s <= Cr46_et_zero & Cr37_et_zero & Cr28_et_zero & Cr38_et_zero
					  & Cr47_et_zero & Cr56_et_zero & Cr65_et_zero & Cr74_et_zero;
		seventh_8_all_0s <= Cr83_et_zero & Cr84_et_zero & Cr75_et_zero & Cr66_et_zero
					  & Cr57_et_zero & Cr48_et_zero & Cr58_et_zero & Cr67_et_zero;
		eighth_8_all_0s <= Cr76_et_zero & Cr85_et_zero & Cr86_et_zero & Cr77_et_zero
					  & Cr68_et_zero & Cr78_et_zero & Cr87_et_zero & Cr88_et_zero;						  			  
		end
end	 


/* end_of_block checks to see if there are any nonzero elements left in the block
If there aren't any nonzero elements left, then the last bits in the JPEG stream
will be the end of block code.  The purpose of this register is to determine if the
zero run length code 15-0 should be used or not.  It should be used if there are 15 or more
zeros in a row, followed by a nonzero value.  If there are only zeros left in the block,
then end_of_block will be 1.  If there are any nonzero values left in the block, end_of_block 
will be 0. */

always @(posedge clk)
begin
	if (rst) 
		end_of_block <= 0;
	else if (enable)
		end_of_block <= 0;
	else if (enable_module & block_counter < 32)
		end_of_block <= third_8_all_0s & fourth_8_all_0s & fifth_8_all_0s
					& sixth_8_all_0s & seventh_8_all_0s & eighth_8_all_0s;
	else if (enable_module & block_counter < 48)
		end_of_block <= fifth_8_all_0s & sixth_8_all_0s & seventh_8_all_0s 
					& eighth_8_all_0s;
	else if (enable_module & block_counter <= 64)
		end_of_block <= seventh_8_all_0s & eighth_8_all_0s;
	else if (enable_module & block_counter > 64)
		end_of_block <= 1;
end	 

always @(posedge clk)
begin
	if (rst) begin
		block_counter <= 0;
		end
	else if (enable) begin
		block_counter <= 0;
		end	
	else if (enable_module) begin
		block_counter <= block_counter + 1;
		end
end	 

always @(posedge clk)
begin
	if (rst) begin
		output_reg_count <= 0;
		end
	else if (end_of_block_output) begin
		output_reg_count <= 0;
		end
	else if (enable_6) begin
		output_reg_count <= output_reg_count + Cr11_output_count;
		end	
	else if (enable_latch_7) begin
		output_reg_count <= output_reg_count + Cr12_oc_1;
		end
end	 

always @(posedge clk)
begin
	if (rst) begin
		old_orc_1 <= 0;
		end
	else if (end_of_block_output) begin
		old_orc_1 <= 0;
		end
	else if (enable_module) begin
		old_orc_1 <= output_reg_count;
		end
end

always @(posedge clk)
begin
	if (rst) begin
		rollover <= 0; rollover_1 <= 0; rollover_2 <= 0;
		rollover_3 <= 0; rollover_4 <= 0; rollover_5 <= 0;
		rollover_6 <= 0; rollover_7 <= 0;
		old_orc_2 <= 0; 
		orc_3 <= 0; orc_4 <= 0; orc_5 <= 0; orc_6 <= 0; 
		orc_7 <= 0; orc_8 <= 0; data_ready <= 0;
		end_of_block_output <= 0; end_of_block_empty <= 0;
		end
	else if (enable_module) begin
		rollover <= (old_orc_1 > output_reg_count); 
		rollover_1 <= rollover;
		rollover_2 <= rollover_1;
		rollover_3 <= rollover_2;
		rollover_4 <= rollover_3;
		rollover_5 <= rollover_4;
		rollover_6 <= rollover_5;
		rollover_7 <= rollover_6;
		old_orc_2 <= old_orc_1;
		orc_3 <= old_orc_2;
		orc_4 <= orc_3; orc_5 <= orc_4;
		orc_6 <= orc_5; orc_7 <= orc_6;
		orc_8 <= orc_7;
		data_ready <= rollover_6 | block_counter == 77;
		end_of_block_output <= block_counter == 77;
		end_of_block_empty <= rollover_7 & block_counter == 77 & output_reg_count == 0;
		end
end	 


	
always @(posedge clk)
begin
	if (rst) begin
		JPEG_bs_5 <= 0; 
		end
	else if (enable_module) begin 
		JPEG_bs_5[31] <= (rollover_6 & orc_7 > 0) ? JPEG_ro_bs_4[31] : JPEG_bs_4[31];
		JPEG_bs_5[30] <= (rollover_6 & orc_7 > 1) ? JPEG_ro_bs_4[30] : JPEG_bs_4[30];
		JPEG_bs_5[29] <= (rollover_6 & orc_7 > 2) ? JPEG_ro_bs_4[29] : JPEG_bs_4[29];
		JPEG_bs_5[28] <= (rollover_6 & orc_7 > 3) ? JPEG_ro_bs_4[28] : JPEG_bs_4[28];
		JPEG_bs_5[27] <= (rollover_6 & orc_7 > 4) ? JPEG_ro_bs_4[27] : JPEG_bs_4[27];
		JPEG_bs_5[26] <= (rollover_6 & orc_7 > 5) ? JPEG_ro_bs_4[26] : JPEG_bs_4[26];
		JPEG_bs_5[25] <= (rollover_6 & orc_7 > 6) ? JPEG_ro_bs_4[25] : JPEG_bs_4[25];
		JPEG_bs_5[24] <= (rollover_6 & orc_7 > 7) ? JPEG_ro_bs_4[24] : JPEG_bs_4[24];
		JPEG_bs_5[23] <= (rollover_6 & orc_7 > 8) ? JPEG_ro_bs_4[23] : JPEG_bs_4[23];
		JPEG_bs_5[22] <= (rollover_6 & orc_7 > 9) ? JPEG_ro_bs_4[22] : JPEG_bs_4[22];
		JPEG_bs_5[21] <= (rollover_6 & orc_7 > 10) ? JPEG_ro_bs_4[21] : JPEG_bs_4[21];
		JPEG_bs_5[20] <= (rollover_6 & orc_7 > 11) ? JPEG_ro_bs_4[20] : JPEG_bs_4[20];
		JPEG_bs_5[19] <= (rollover_6 & orc_7 > 12) ? JPEG_ro_bs_4[19] : JPEG_bs_4[19];
		JPEG_bs_5[18] <= (rollover_6 & orc_7 > 13) ? JPEG_ro_bs_4[18] : JPEG_bs_4[18];
		JPEG_bs_5[17] <= (rollover_6 & orc_7 > 14) ? JPEG_ro_bs_4[17] : JPEG_bs_4[17];
		JPEG_bs_5[16] <= (rollover_6 & orc_7 > 15) ? JPEG_ro_bs_4[16] : JPEG_bs_4[16];
		JPEG_bs_5[15] <= (rollover_6 & orc_7 > 16) ? JPEG_ro_bs_4[15] : JPEG_bs_4[15];
		JPEG_bs_5[14] <= (rollover_6 & orc_7 > 17) ? JPEG_ro_bs_4[14] : JPEG_bs_4[14];
		JPEG_bs_5[13] <= (rollover_6 & orc_7 > 18) ? JPEG_ro_bs_4[13] : JPEG_bs_4[13];
		JPEG_bs_5[12] <= (rollover_6 & orc_7 > 19) ? JPEG_ro_bs_4[12] : JPEG_bs_4[12];
		JPEG_bs_5[11] <= (rollover_6 & orc_7 > 20) ? JPEG_ro_bs_4[11] : JPEG_bs_4[11];
		JPEG_bs_5[10] <= (rollover_6 & orc_7 > 21) ? JPEG_ro_bs_4[10] : JPEG_bs_4[10];
		JPEG_bs_5[9] <= (rollover_6 & orc_7 > 22) ? JPEG_ro_bs_4[9] : JPEG_bs_4[9];
		JPEG_bs_5[8] <= (rollover_6 & orc_7 > 23) ? JPEG_ro_bs_4[8] : JPEG_bs_4[8];
		JPEG_bs_5[7] <= (rollover_6 & orc_7 > 24) ? JPEG_ro_bs_4[7] : JPEG_bs_4[7];
		JPEG_bs_5[6] <= (rollover_6 & orc_7 > 25) ? JPEG_ro_bs_4[6] : JPEG_bs_4[6];
		JPEG_bs_5[5] <= (rollover_6 & orc_7 > 26) ? JPEG_ro_bs_4[5] : JPEG_bs_4[5];
		JPEG_bs_5[4] <= (rollover_6 & orc_7 > 27) ? JPEG_ro_bs_4[4] : JPEG_bs_4[4];
		JPEG_bs_5[3] <= (rollover_6 & orc_7 > 28) ? JPEG_ro_bs_4[3] : JPEG_bs_4[3];
		JPEG_bs_5[2] <= (rollover_6 & orc_7 > 29) ? JPEG_ro_bs_4[2] : JPEG_bs_4[2];
		JPEG_bs_5[1] <= (rollover_6 & orc_7 > 30) ? JPEG_ro_bs_4[1] : JPEG_bs_4[1];
		JPEG_bs_5[0] <= JPEG_bs_4[0];
		end
end	
	
always @(posedge clk)
begin
	if (rst) begin
		JPEG_bs_4 <= 0; JPEG_ro_bs_4 <= 0;
		end
	else if (enable_module) begin 
		JPEG_bs_4 <= (old_orc_6 == 1) ? JPEG_bs_3 >> 1 : JPEG_bs_3;
		JPEG_ro_bs_4 <= (Cr12_edge_4 <= 1) ? JPEG_ro_bs_3 << 1 : JPEG_ro_bs_3;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		JPEG_bs_3 <= 0; old_orc_6 <= 0; JPEG_ro_bs_3 <= 0;
		Cr12_edge_4 <= 0; 
		end
	else if (enable_module) begin 
		JPEG_bs_3 <= (old_orc_5 >= 2) ? JPEG_bs_2 >> 2 : JPEG_bs_2;
		old_orc_6 <= (old_orc_5 >= 2) ? old_orc_5 - 2 : old_orc_5;
		JPEG_ro_bs_3 <= (Cr12_edge_3 <= 2) ? JPEG_ro_bs_2 << 2 : JPEG_ro_bs_2;
		Cr12_edge_4 <= (Cr12_edge_3 <= 2) ? Cr12_edge_3 : Cr12_edge_3 - 2;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		JPEG_bs_2 <= 0; old_orc_5 <= 0; JPEG_ro_bs_2 <= 0;
		Cr12_edge_3 <= 0; 
		end
	else if (enable_module) begin 
		JPEG_bs_2 <= (old_orc_4 >= 4) ? JPEG_bs_1 >> 4 : JPEG_bs_1;
		old_orc_5 <= (old_orc_4 >= 4) ? old_orc_4 - 4 : old_orc_4;
		JPEG_ro_bs_2 <= (Cr12_edge_2 <= 4) ? JPEG_ro_bs_1 << 4 : JPEG_ro_bs_1;
		Cr12_edge_3 <= (Cr12_edge_2 <= 4) ? Cr12_edge_2 : Cr12_edge_2 - 4;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		JPEG_bs_1 <= 0; old_orc_4 <= 0; JPEG_ro_bs_1 <= 0; 
		Cr12_edge_2 <= 0; 
		end
	else if (enable_module) begin 
		JPEG_bs_1 <= (old_orc_3 >= 8) ? JPEG_bs >> 8 : JPEG_bs;
		old_orc_4 <= (old_orc_3 >= 8) ? old_orc_3 - 8 : old_orc_3;
		JPEG_ro_bs_1 <= (Cr12_edge_1 <= 8) ? JPEG_ro_bs << 8 : JPEG_ro_bs;
		Cr12_edge_2 <= (Cr12_edge_1 <= 8) ? Cr12_edge_1 : Cr12_edge_1 - 8;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		JPEG_bs <= 0; old_orc_3 <= 0; JPEG_ro_bs <= 0;
		Cr12_edge_1 <= 0; Cr11_JPEG_bits_1 <= 0;
		end
	else if (enable_module) begin 
		JPEG_bs <= (old_orc_2 >= 16) ? Cr11_JPEG_bits >> 10 : Cr11_JPEG_bits << 6;
		old_orc_3 <= (old_orc_2 >= 16) ? old_orc_2 - 16 : old_orc_2;
		JPEG_ro_bs <= (Cr12_edge <= 16) ? Cr11_JPEG_bits_1 << 16 : Cr11_JPEG_bits_1;
		Cr12_edge_1 <= (Cr12_edge <= 16) ? Cr12_edge : Cr12_edge - 16;
		Cr11_JPEG_bits_1 <= Cr11_JPEG_bits;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		Cr12_JPEG_bits <= 0; Cr12_edge <= 0;
		end
	else if (enable_module) begin 
		Cr12_JPEG_bits[25] <= (Cr12_Huff_shift_1 >= 16) ? Cr12_JPEG_LSBs_4[25] : Cr12_Huff_2[15];
		Cr12_JPEG_bits[24] <= (Cr12_Huff_shift_1 >= 15) ? Cr12_JPEG_LSBs_4[24] : Cr12_Huff_2[14];
		Cr12_JPEG_bits[23] <= (Cr12_Huff_shift_1 >= 14) ? Cr12_JPEG_LSBs_4[23] : Cr12_Huff_2[13];
		Cr12_JPEG_bits[22] <= (Cr12_Huff_shift_1 >= 13) ? Cr12_JPEG_LSBs_4[22] : Cr12_Huff_2[12];
		Cr12_JPEG_bits[21] <= (Cr12_Huff_shift_1 >= 12) ? Cr12_JPEG_LSBs_4[21] : Cr12_Huff_2[11];
		Cr12_JPEG_bits[20] <= (Cr12_Huff_shift_1 >= 11) ? Cr12_JPEG_LSBs_4[20] : Cr12_Huff_2[10];
		Cr12_JPEG_bits[19] <= (Cr12_Huff_shift_1 >= 10) ? Cr12_JPEG_LSBs_4[19] : Cr12_Huff_2[9];
		Cr12_JPEG_bits[18] <= (Cr12_Huff_shift_1 >= 9) ? Cr12_JPEG_LSBs_4[18] : Cr12_Huff_2[8];
		Cr12_JPEG_bits[17] <= (Cr12_Huff_shift_1 >= 8) ? Cr12_JPEG_LSBs_4[17] : Cr12_Huff_2[7];
		Cr12_JPEG_bits[16] <= (Cr12_Huff_shift_1 >= 7) ? Cr12_JPEG_LSBs_4[16] : Cr12_Huff_2[6];
		Cr12_JPEG_bits[15] <= (Cr12_Huff_shift_1 >= 6) ? Cr12_JPEG_LSBs_4[15] : Cr12_Huff_2[5];
		Cr12_JPEG_bits[14] <= (Cr12_Huff_shift_1 >= 5) ? Cr12_JPEG_LSBs_4[14] : Cr12_Huff_2[4];
		Cr12_JPEG_bits[13] <= (Cr12_Huff_shift_1 >= 4) ? Cr12_JPEG_LSBs_4[13] : Cr12_Huff_2[3];
		Cr12_JPEG_bits[12] <= (Cr12_Huff_shift_1 >= 3) ? Cr12_JPEG_LSBs_4[12] : Cr12_Huff_2[2];
		Cr12_JPEG_bits[11] <= (Cr12_Huff_shift_1 >= 2) ? Cr12_JPEG_LSBs_4[11] : Cr12_Huff_2[1];
		Cr12_JPEG_bits[10] <= (Cr12_Huff_shift_1 >= 1) ? Cr12_JPEG_LSBs_4[10] : Cr12_Huff_2[0];
		Cr12_JPEG_bits[9:0] <= Cr12_JPEG_LSBs_4[9:0];
		Cr12_edge <= old_orc_2 + 26; // 26 is the size of Cr11_JPEG_bits
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		Cr11_JPEG_bits <= 0; 
		end
	else if (enable_7) begin 
		Cr11_JPEG_bits[25] <= (Cr11_Huff_shift_1 >= 11) ? Cr11_JPEG_LSBs_3[21] : Cr11_Huff_2[10];
		Cr11_JPEG_bits[24] <= (Cr11_Huff_shift_1 >= 10) ? Cr11_JPEG_LSBs_3[20] : Cr11_Huff_2[9];
		Cr11_JPEG_bits[23] <= (Cr11_Huff_shift_1 >= 9) ? Cr11_JPEG_LSBs_3[19] : Cr11_Huff_2[8];
		Cr11_JPEG_bits[22] <= (Cr11_Huff_shift_1 >= 8) ? Cr11_JPEG_LSBs_3[18] : Cr11_Huff_2[7];
		Cr11_JPEG_bits[21] <= (Cr11_Huff_shift_1 >= 7) ? Cr11_JPEG_LSBs_3[17] : Cr11_Huff_2[6];
		Cr11_JPEG_bits[20] <= (Cr11_Huff_shift_1 >= 6) ? Cr11_JPEG_LSBs_3[16] : Cr11_Huff_2[5];
		Cr11_JPEG_bits[19] <= (Cr11_Huff_shift_1 >= 5) ? Cr11_JPEG_LSBs_3[15] : Cr11_Huff_2[4];
		Cr11_JPEG_bits[18] <= (Cr11_Huff_shift_1 >= 4) ? Cr11_JPEG_LSBs_3[14] : Cr11_Huff_2[3];
		Cr11_JPEG_bits[17] <= (Cr11_Huff_shift_1 >= 3) ? Cr11_JPEG_LSBs_3[13] : Cr11_Huff_2[2];
		Cr11_JPEG_bits[16] <= (Cr11_Huff_shift_1 >= 2) ? Cr11_JPEG_LSBs_3[12] : Cr11_Huff_2[1];
		Cr11_JPEG_bits[15] <= (Cr11_Huff_shift_1 >= 1) ? Cr11_JPEG_LSBs_3[11] : Cr11_Huff_2[0];
		Cr11_JPEG_bits[14:4] <= Cr11_JPEG_LSBs_3[10:0];
		end
	else if (enable_latch_8) begin
		Cr11_JPEG_bits <= Cr12_JPEG_bits;
		end
end	


always @(posedge clk)
begin
	if (rst) begin
		Cr12_oc_1 <= 0; Cr12_JPEG_LSBs_4 <= 0;
		Cr12_Huff_2 <= 0; Cr12_Huff_shift_1 <= 0;
		end
	else if (enable_module) begin 
		Cr12_oc_1 <= (Cr12_et_zero_5 & !code_15_0 & block_counter != 67) ? 0 : 
			Cr12_bits_3 + Cr12_Huff_count_1;
		Cr12_JPEG_LSBs_4 <= Cr12_JPEG_LSBs_3 << Cr12_Huff_shift;
		Cr12_Huff_2 <= Cr12_Huff_1;
		Cr12_Huff_shift_1 <= Cr12_Huff_shift;
		end
end

always @(posedge clk)
begin
	if (rst) begin
		Cr11_JPEG_LSBs_3 <= 0; Cr11_Huff_2 <= 0; 
		Cr11_Huff_shift_1 <= 0; 
		end
	else if (enable_6) begin 
		Cr11_JPEG_LSBs_3 <= Cr11_JPEG_LSBs_2 << Cr11_Huff_shift;
		Cr11_Huff_2 <= Cr11_Huff_1;
		Cr11_Huff_shift_1 <= Cr11_Huff_shift;
		end
end	


always @(posedge clk)
begin
	if (rst) begin
		Cr12_Huff_shift <= 0;
		Cr12_Huff_1 <= 0; Cr12_JPEG_LSBs_3 <= 0; Cr12_bits_3 <= 0;
		Cr12_Huff_count_1 <= 0; Cr12_et_zero_5 <= 0; code_15_0 <= 0;
		end
	else if (enable_module) begin 
		Cr12_Huff_shift <= 16 - Cr12_Huff_count;
		Cr12_Huff_1 <= Cr12_Huff;
		Cr12_JPEG_LSBs_3 <= Cr12_JPEG_LSBs_2;
		Cr12_bits_3 <= Cr12_bits_2;
		Cr12_Huff_count_1 <= Cr12_Huff_count;
		Cr12_et_zero_5 <= Cr12_et_zero_4;
		code_15_0 <= zrl_et_15 & !end_of_block;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		Cr11_output_count <= 0; Cr11_JPEG_LSBs_2 <= 0; Cr11_Huff_shift <= 0;
		Cr11_Huff_1 <= 0;
		end
	else if (enable_5) begin 
		Cr11_output_count <= Cr11_bits_1 + Cr11_Huff_count;
		Cr11_JPEG_LSBs_2 <= Cr11_JPEG_LSBs_1 << Cr11_amp_shift;
		Cr11_Huff_shift <= 11 - Cr11_Huff_count;
		Cr11_Huff_1 <= Cr11_Huff;
		end
end	


always @(posedge clk)
begin
	if (rst) begin
		Cr12_JPEG_LSBs_2 <= 0;
		Cr12_Huff <= 0; Cr12_Huff_count <= 0; Cr12_bits_2 <= 0;
		Cr12_et_zero_4 <= 0; zrl_et_15 <= 0; zrl_3 <= 0;
		end
	else if (enable_module) begin
		Cr12_JPEG_LSBs_2 <= Cr12_JPEG_LSBs_1 << Cr12_amp_shift;
		Cr12_Huff <= Cr_AC[Cr12_code_entry];
		Cr12_Huff_count <= Cr_AC_code_length[Cr12_code_entry];
		Cr12_bits_2 <= Cr12_bits_1;
		Cr12_et_zero_4 <= Cr12_et_zero_3;
		zrl_et_15 <= zrl_3 == 15;
		zrl_3 <= zrl_2;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		Cr11_Huff <= 0; Cr11_Huff_count <= 0; Cr11_amp_shift <= 0;
		Cr11_JPEG_LSBs_1 <= 0; Cr11_bits_1 <= 0; 
		end
	else if (enable_4) begin
		Cr11_Huff[10:0] <= Cr_DC[Cr11_bits];
		Cr11_Huff_count <= Cr_DC_code_length[Cr11_bits];
		Cr11_amp_shift <= 11 - Cr11_bits;
		Cr11_JPEG_LSBs_1 <= Cr11_JPEG_LSBs;
		Cr11_bits_1 <= Cr11_bits;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		Cr12_code_entry <= 0; Cr12_JPEG_LSBs_1 <= 0; Cr12_amp_shift <= 0; 
		Cr12_bits_1 <= 0; Cr12_et_zero_3 <= 0; zrl_2 <= 0;
		end
	else if (enable_module) begin
		Cr12_code_entry <= Cr_AC_run_code[code_index];
		Cr12_JPEG_LSBs_1 <= Cr12_JPEG_LSBs;
		Cr12_amp_shift <= 10 - Cr12_bits;
		Cr12_bits_1 <= Cr12_bits;
		Cr12_et_zero_3 <= Cr12_et_zero_2;
		zrl_2 <= zrl_1;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		Cr11_bits <= 0; Cr11_JPEG_LSBs <= 0; 
		end
	else if (enable_3) begin
		Cr11_bits <= Cr11_msb ? Cr11_bits_neg : Cr11_bits_pos;
		Cr11_JPEG_LSBs <= Cr11_amp[10:0]; // The top bit of Cr11_amp is the sign bit
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		Cr12_bits <= 0; Cr12_JPEG_LSBs <= 0; zrl_1 <= 0;
		Cr12_et_zero_2 <= 0;
		end
	else if (enable_module) begin 
		Cr12_bits <= Cr12_msb_1 ? Cr12_bits_neg : Cr12_bits_pos;
		Cr12_JPEG_LSBs <= Cr12_amp[9:0]; // The top bit of Cr12_amp is the sign bit
		zrl_1 <= block_counter == 62 & Cr12_et_zero ? 0 : zero_run_length;
		Cr12_et_zero_2 <= Cr12_et_zero_1;
		end
end	

// Cr11_amp is the amplitude that will be represented in bits in the 
// JPEG code, following the run length code
always @(posedge clk)
begin
	if (rst) begin
		Cr11_amp <= 0;
		end
	else if (enable_2) begin 
		Cr11_amp <= Cr11_msb ? Cr11_1_neg : Cr11_1_pos;
		end
end	


always @(posedge clk)
begin
	if (rst) 
		zero_run_length <= 0; 
	else if (enable)
		zero_run_length <= 0; 
	else if (enable_module) 
		zero_run_length <= Cr12_et_zero ? zero_run_length + 1: 0;
end	 

always @(posedge clk)
begin
	if (rst) begin
		Cr12_amp <= 0;  
		Cr12_et_zero_1 <= 0; Cr12_msb_1 <= 0;
		end
	else if (enable_module) begin
		Cr12_amp <= Cr12_msb ? Cr12_neg : Cr12_pos;
		Cr12_et_zero_1 <= Cr12_et_zero;
		Cr12_msb_1 <= Cr12_msb;
		end
end	 

always @(posedge clk)
begin
	if (rst) begin
		Cr11_1_pos <= 0; Cr11_1_neg <= 0; Cr11_msb <= 0;
		Cr11_previous <= 0; 
		end
	else if (enable_1) begin
		Cr11_1_pos <= Cr11_diff;
		Cr11_1_neg <= Cr11_diff - 1;
		Cr11_msb <= Cr11_diff[11];
		Cr11_previous <= Cr11_1;
		end
end	 

always @(posedge clk)
begin
	if (rst) begin 
		Cr12_pos <= 0; Cr12_neg <= 0; Cr12_msb <= 0; Cr12_et_zero <= 0; 
		Cr13_pos <= 0; Cr13_neg <= 0; Cr13_msb <= 0; Cr13_et_zero <= 0;
		Cr14_pos <= 0; Cr14_neg <= 0; Cr14_msb <= 0; Cr14_et_zero <= 0; 
		Cr15_pos <= 0; Cr15_neg <= 0; Cr15_msb <= 0; Cr15_et_zero <= 0;
		Cr16_pos <= 0; Cr16_neg <= 0; Cr16_msb <= 0; Cr16_et_zero <= 0; 
		Cr17_pos <= 0; Cr17_neg <= 0; Cr17_msb <= 0; Cr17_et_zero <= 0;
		Cr18_pos <= 0; Cr18_neg <= 0; Cr18_msb <= 0; Cr18_et_zero <= 0; 
		Cr21_pos <= 0; Cr21_neg <= 0; Cr21_msb <= 0; Cr21_et_zero <= 0;
		Cr22_pos <= 0; Cr22_neg <= 0; Cr22_msb <= 0; Cr22_et_zero <= 0; 
		Cr23_pos <= 0; Cr23_neg <= 0; Cr23_msb <= 0; Cr23_et_zero <= 0;
		Cr24_pos <= 0; Cr24_neg <= 0; Cr24_msb <= 0; Cr24_et_zero <= 0; 
		Cr25_pos <= 0; Cr25_neg <= 0; Cr25_msb <= 0; Cr25_et_zero <= 0;
		Cr26_pos <= 0; Cr26_neg <= 0; Cr26_msb <= 0; Cr26_et_zero <= 0; 
		Cr27_pos <= 0; Cr27_neg <= 0; Cr27_msb <= 0; Cr27_et_zero <= 0;
		Cr28_pos <= 0; Cr28_neg <= 0; Cr28_msb <= 0; Cr28_et_zero <= 0; 
		Cr31_pos <= 0; Cr31_neg <= 0; Cr31_msb <= 0; Cr31_et_zero <= 0;  
		Cr32_pos <= 0; Cr32_neg <= 0; Cr32_msb <= 0; Cr32_et_zero <= 0; 
		Cr33_pos <= 0; Cr33_neg <= 0; Cr33_msb <= 0; Cr33_et_zero <= 0;
		Cr34_pos <= 0; Cr34_neg <= 0; Cr34_msb <= 0; Cr34_et_zero <= 0; 
		Cr35_pos <= 0; Cr35_neg <= 0; Cr35_msb <= 0; Cr35_et_zero <= 0;
		Cr36_pos <= 0; Cr36_neg <= 0; Cr36_msb <= 0; Cr36_et_zero <= 0; 
		Cr37_pos <= 0; Cr37_neg <= 0; Cr37_msb <= 0; Cr37_et_zero <= 0;
		Cr38_pos <= 0; Cr38_neg <= 0; Cr38_msb <= 0; Cr38_et_zero <= 0;
		Cr41_pos <= 0; Cr41_neg <= 0; Cr41_msb <= 0; Cr41_et_zero <= 0;  
		Cr42_pos <= 0; Cr42_neg <= 0; Cr42_msb <= 0; Cr42_et_zero <= 0; 
		Cr43_pos <= 0; Cr43_neg <= 0; Cr43_msb <= 0; Cr43_et_zero <= 0;
		Cr44_pos <= 0; Cr44_neg <= 0; Cr44_msb <= 0; Cr44_et_zero <= 0; 
		Cr45_pos <= 0; Cr45_neg <= 0; Cr45_msb <= 0; Cr45_et_zero <= 0;
		Cr46_pos <= 0; Cr46_neg <= 0; Cr46_msb <= 0; Cr46_et_zero <= 0; 
		Cr47_pos <= 0; Cr47_neg <= 0; Cr47_msb <= 0; Cr47_et_zero <= 0;
		Cr48_pos <= 0; Cr48_neg <= 0; Cr48_msb <= 0; Cr48_et_zero <= 0;
		Cr51_pos <= 0; Cr51_neg <= 0; Cr51_msb <= 0; Cr51_et_zero <= 0;  
		Cr52_pos <= 0; Cr52_neg <= 0; Cr52_msb <= 0; Cr52_et_zero <= 0; 
		Cr53_pos <= 0; Cr53_neg <= 0; Cr53_msb <= 0; Cr53_et_zero <= 0;
		Cr54_pos <= 0; Cr54_neg <= 0; Cr54_msb <= 0; Cr54_et_zero <= 0; 
		Cr55_pos <= 0; Cr55_neg <= 0; Cr55_msb <= 0; Cr55_et_zero <= 0;
		Cr56_pos <= 0; Cr56_neg <= 0; Cr56_msb <= 0; Cr56_et_zero <= 0; 
		Cr57_pos <= 0; Cr57_neg <= 0; Cr57_msb <= 0; Cr57_et_zero <= 0;
		Cr58_pos <= 0; Cr58_neg <= 0; Cr58_msb <= 0; Cr58_et_zero <= 0;
		Cr61_pos <= 0; Cr61_neg <= 0; Cr61_msb <= 0; Cr61_et_zero <= 0;  
		Cr62_pos <= 0; Cr62_neg <= 0; Cr62_msb <= 0; Cr62_et_zero <= 0; 
		Cr63_pos <= 0; Cr63_neg <= 0; Cr63_msb <= 0; Cr63_et_zero <= 0;
		Cr64_pos <= 0; Cr64_neg <= 0; Cr64_msb <= 0; Cr64_et_zero <= 0; 
		Cr65_pos <= 0; Cr65_neg <= 0; Cr65_msb <= 0; Cr65_et_zero <= 0;
		Cr66_pos <= 0; Cr66_neg <= 0; Cr66_msb <= 0; Cr66_et_zero <= 0; 
		Cr67_pos <= 0; Cr67_neg <= 0; Cr67_msb <= 0; Cr67_et_zero <= 0;
		Cr68_pos <= 0; Cr68_neg <= 0; Cr68_msb <= 0; Cr68_et_zero <= 0;
		Cr71_pos <= 0; Cr71_neg <= 0; Cr71_msb <= 0; Cr71_et_zero <= 0;  
		Cr72_pos <= 0; Cr72_neg <= 0; Cr72_msb <= 0; Cr72_et_zero <= 0; 
		Cr73_pos <= 0; Cr73_neg <= 0; Cr73_msb <= 0; Cr73_et_zero <= 0;
		Cr74_pos <= 0; Cr74_neg <= 0; Cr74_msb <= 0; Cr74_et_zero <= 0; 
		Cr75_pos <= 0; Cr75_neg <= 0; Cr75_msb <= 0; Cr75_et_zero <= 0;
		Cr76_pos <= 0; Cr76_neg <= 0; Cr76_msb <= 0; Cr76_et_zero <= 0; 
		Cr77_pos <= 0; Cr77_neg <= 0; Cr77_msb <= 0; Cr77_et_zero <= 0;
		Cr78_pos <= 0; Cr78_neg <= 0; Cr78_msb <= 0; Cr78_et_zero <= 0;
		Cr81_pos <= 0; Cr81_neg <= 0; Cr81_msb <= 0; Cr81_et_zero <= 0;  
		Cr82_pos <= 0; Cr82_neg <= 0; Cr82_msb <= 0; Cr82_et_zero <= 0; 
		Cr83_pos <= 0; Cr83_neg <= 0; Cr83_msb <= 0; Cr83_et_zero <= 0;
		Cr84_pos <= 0; Cr84_neg <= 0; Cr84_msb <= 0; Cr84_et_zero <= 0; 
		Cr85_pos <= 0; Cr85_neg <= 0; Cr85_msb <= 0; Cr85_et_zero <= 0;
		Cr86_pos <= 0; Cr86_neg <= 0; Cr86_msb <= 0; Cr86_et_zero <= 0; 
		Cr87_pos <= 0; Cr87_neg <= 0; Cr87_msb <= 0; Cr87_et_zero <= 0;
		Cr88_pos <= 0; Cr88_neg <= 0; Cr88_msb <= 0; Cr88_et_zero <= 0; 
		end
	else if (enable) begin 
		Cr12_pos <= Cr12;	   
		Cr12_neg <= Cr12 - 1;
		Cr12_msb <= Cr12[10];
		Cr12_et_zero <= !(|Cr12);
		Cr13_pos <= Cr13;	   
		Cr13_neg <= Cr13 - 1;
		Cr13_msb <= Cr13[10];
		Cr13_et_zero <= !(|Cr13);
		Cr14_pos <= Cr14;	   
		Cr14_neg <= Cr14 - 1;
		Cr14_msb <= Cr14[10];
		Cr14_et_zero <= !(|Cr14);
		Cr15_pos <= Cr15;	   
		Cr15_neg <= Cr15 - 1;
		Cr15_msb <= Cr15[10];
		Cr15_et_zero <= !(|Cr15);
		Cr16_pos <= Cr16;	   
		Cr16_neg <= Cr16 - 1;
		Cr16_msb <= Cr16[10];
		Cr16_et_zero <= !(|Cr16);
		Cr17_pos <= Cr17;	   
		Cr17_neg <= Cr17 - 1;
		Cr17_msb <= Cr17[10];
		Cr17_et_zero <= !(|Cr17);
		Cr18_pos <= Cr18;	   
		Cr18_neg <= Cr18 - 1;
		Cr18_msb <= Cr18[10];
		Cr18_et_zero <= !(|Cr18);
		Cr21_pos <= Cr21;	   
		Cr21_neg <= Cr21 - 1;
		Cr21_msb <= Cr21[10];
		Cr21_et_zero <= !(|Cr21);
		Cr22_pos <= Cr22;	   
		Cr22_neg <= Cr22 - 1;
		Cr22_msb <= Cr22[10];
		Cr22_et_zero <= !(|Cr22);
		Cr23_pos <= Cr23;	   
		Cr23_neg <= Cr23 - 1;
		Cr23_msb <= Cr23[10];
		Cr23_et_zero <= !(|Cr23);
		Cr24_pos <= Cr24;	   
		Cr24_neg <= Cr24 - 1;
		Cr24_msb <= Cr24[10];
		Cr24_et_zero <= !(|Cr24);
		Cr25_pos <= Cr25;	   
		Cr25_neg <= Cr25 - 1;
		Cr25_msb <= Cr25[10];
		Cr25_et_zero <= !(|Cr25);
		Cr26_pos <= Cr26;	   
		Cr26_neg <= Cr26 - 1;
		Cr26_msb <= Cr26[10];
		Cr26_et_zero <= !(|Cr26);
		Cr27_pos <= Cr27;	   
		Cr27_neg <= Cr27 - 1;
		Cr27_msb <= Cr27[10];
		Cr27_et_zero <= !(|Cr27);
		Cr28_pos <= Cr28;	   
		Cr28_neg <= Cr28 - 1;
		Cr28_msb <= Cr28[10];
		Cr28_et_zero <= !(|Cr28);
		Cr31_pos <= Cr31;	   
		Cr31_neg <= Cr31 - 1;
		Cr31_msb <= Cr31[10];
		Cr31_et_zero <= !(|Cr31);
		Cr32_pos <= Cr32;	   
		Cr32_neg <= Cr32 - 1;
		Cr32_msb <= Cr32[10];
		Cr32_et_zero <= !(|Cr32);
		Cr33_pos <= Cr33;	   
		Cr33_neg <= Cr33 - 1;
		Cr33_msb <= Cr33[10];
		Cr33_et_zero <= !(|Cr33);
		Cr34_pos <= Cr34;	   
		Cr34_neg <= Cr34 - 1;
		Cr34_msb <= Cr34[10];
		Cr34_et_zero <= !(|Cr34);
		Cr35_pos <= Cr35;	   
		Cr35_neg <= Cr35 - 1;
		Cr35_msb <= Cr35[10];
		Cr35_et_zero <= !(|Cr35);
		Cr36_pos <= Cr36;	   
		Cr36_neg <= Cr36 - 1;
		Cr36_msb <= Cr36[10];
		Cr36_et_zero <= !(|Cr36);
		Cr37_pos <= Cr37;	   
		Cr37_neg <= Cr37 - 1;
		Cr37_msb <= Cr37[10];
		Cr37_et_zero <= !(|Cr37);
		Cr38_pos <= Cr38;	   
		Cr38_neg <= Cr38 - 1;
		Cr38_msb <= Cr38[10];
		Cr38_et_zero <= !(|Cr38);
		Cr41_pos <= Cr41;	   
		Cr41_neg <= Cr41 - 1;
		Cr41_msb <= Cr41[10];
		Cr41_et_zero <= !(|Cr41);
		Cr42_pos <= Cr42;	   
		Cr42_neg <= Cr42 - 1;
		Cr42_msb <= Cr42[10];
		Cr42_et_zero <= !(|Cr42);
		Cr43_pos <= Cr43;	   
		Cr43_neg <= Cr43 - 1;
		Cr43_msb <= Cr43[10];
		Cr43_et_zero <= !(|Cr43);
		Cr44_pos <= Cr44;	   
		Cr44_neg <= Cr44 - 1;
		Cr44_msb <= Cr44[10];
		Cr44_et_zero <= !(|Cr44);
		Cr45_pos <= Cr45;	   
		Cr45_neg <= Cr45 - 1;
		Cr45_msb <= Cr45[10];
		Cr45_et_zero <= !(|Cr45);
		Cr46_pos <= Cr46;	   
		Cr46_neg <= Cr46 - 1;
		Cr46_msb <= Cr46[10];
		Cr46_et_zero <= !(|Cr46);
		Cr47_pos <= Cr47;	   
		Cr47_neg <= Cr47 - 1;
		Cr47_msb <= Cr47[10];
		Cr47_et_zero <= !(|Cr47);
		Cr48_pos <= Cr48;	   
		Cr48_neg <= Cr48 - 1;
		Cr48_msb <= Cr48[10];
		Cr48_et_zero <= !(|Cr48);
		Cr51_pos <= Cr51;	   
		Cr51_neg <= Cr51 - 1;
		Cr51_msb <= Cr51[10];
		Cr51_et_zero <= !(|Cr51);
		Cr52_pos <= Cr52;	   
		Cr52_neg <= Cr52 - 1;
		Cr52_msb <= Cr52[10];
		Cr52_et_zero <= !(|Cr52);
		Cr53_pos <= Cr53;	   
		Cr53_neg <= Cr53 - 1;
		Cr53_msb <= Cr53[10];
		Cr53_et_zero <= !(|Cr53);
		Cr54_pos <= Cr54;	   
		Cr54_neg <= Cr54 - 1;
		Cr54_msb <= Cr54[10];
		Cr54_et_zero <= !(|Cr54);
		Cr55_pos <= Cr55;	   
		Cr55_neg <= Cr55 - 1;
		Cr55_msb <= Cr55[10];
		Cr55_et_zero <= !(|Cr55);
		Cr56_pos <= Cr56;	   
		Cr56_neg <= Cr56 - 1;
		Cr56_msb <= Cr56[10];
		Cr56_et_zero <= !(|Cr56);
		Cr57_pos <= Cr57;	   
		Cr57_neg <= Cr57 - 1;
		Cr57_msb <= Cr57[10];
		Cr57_et_zero <= !(|Cr57);
		Cr58_pos <= Cr58;	   
		Cr58_neg <= Cr58 - 1;
		Cr58_msb <= Cr58[10];
		Cr58_et_zero <= !(|Cr58);
		Cr61_pos <= Cr61;	   
		Cr61_neg <= Cr61 - 1;
		Cr61_msb <= Cr61[10];
		Cr61_et_zero <= !(|Cr61);
		Cr62_pos <= Cr62;	   
		Cr62_neg <= Cr62 - 1;
		Cr62_msb <= Cr62[10];
		Cr62_et_zero <= !(|Cr62);
		Cr63_pos <= Cr63;	   
		Cr63_neg <= Cr63 - 1;
		Cr63_msb <= Cr63[10];
		Cr63_et_zero <= !(|Cr63);
		Cr64_pos <= Cr64;	   
		Cr64_neg <= Cr64 - 1;
		Cr64_msb <= Cr64[10];
		Cr64_et_zero <= !(|Cr64);
		Cr65_pos <= Cr65;	   
		Cr65_neg <= Cr65 - 1;
		Cr65_msb <= Cr65[10];
		Cr65_et_zero <= !(|Cr65);
		Cr66_pos <= Cr66;	   
		Cr66_neg <= Cr66 - 1;
		Cr66_msb <= Cr66[10];
		Cr66_et_zero <= !(|Cr66);
		Cr67_pos <= Cr67;	   
		Cr67_neg <= Cr67 - 1;
		Cr67_msb <= Cr67[10];
		Cr67_et_zero <= !(|Cr67);
		Cr68_pos <= Cr68;	   
		Cr68_neg <= Cr68 - 1;
		Cr68_msb <= Cr68[10];
		Cr68_et_zero <= !(|Cr68);
		Cr71_pos <= Cr71;	   
		Cr71_neg <= Cr71 - 1;
		Cr71_msb <= Cr71[10];
		Cr71_et_zero <= !(|Cr71);
		Cr72_pos <= Cr72;	   
		Cr72_neg <= Cr72 - 1;
		Cr72_msb <= Cr72[10];
		Cr72_et_zero <= !(|Cr72);
		Cr73_pos <= Cr73;	   
		Cr73_neg <= Cr73 - 1;
		Cr73_msb <= Cr73[10];
		Cr73_et_zero <= !(|Cr73);
		Cr74_pos <= Cr74;	   
		Cr74_neg <= Cr74 - 1;
		Cr74_msb <= Cr74[10];
		Cr74_et_zero <= !(|Cr74);
		Cr75_pos <= Cr75;	   
		Cr75_neg <= Cr75 - 1;
		Cr75_msb <= Cr75[10];
		Cr75_et_zero <= !(|Cr75);
		Cr76_pos <= Cr76;	   
		Cr76_neg <= Cr76 - 1;
		Cr76_msb <= Cr76[10];
		Cr76_et_zero <= !(|Cr76);
		Cr77_pos <= Cr77;	   
		Cr77_neg <= Cr77 - 1;
		Cr77_msb <= Cr77[10];
		Cr77_et_zero <= !(|Cr77);
		Cr78_pos <= Cr78;	   
		Cr78_neg <= Cr78 - 1;
		Cr78_msb <= Cr78[10];
		Cr78_et_zero <= !(|Cr78);
		Cr81_pos <= Cr81;	   
		Cr81_neg <= Cr81 - 1;
		Cr81_msb <= Cr81[10];
		Cr81_et_zero <= !(|Cr81);
		Cr82_pos <= Cr82;	   
		Cr82_neg <= Cr82 - 1;
		Cr82_msb <= Cr82[10];
		Cr82_et_zero <= !(|Cr82);
		Cr83_pos <= Cr83;	   
		Cr83_neg <= Cr83 - 1;
		Cr83_msb <= Cr83[10];
		Cr83_et_zero <= !(|Cr83);
		Cr84_pos <= Cr84;	   
		Cr84_neg <= Cr84 - 1;
		Cr84_msb <= Cr84[10];
		Cr84_et_zero <= !(|Cr84);
		Cr85_pos <= Cr85;	   
		Cr85_neg <= Cr85 - 1;
		Cr85_msb <= Cr85[10];
		Cr85_et_zero <= !(|Cr85);
		Cr86_pos <= Cr86;	   
		Cr86_neg <= Cr86 - 1;
		Cr86_msb <= Cr86[10];
		Cr86_et_zero <= !(|Cr86);
		Cr87_pos <= Cr87;	   
		Cr87_neg <= Cr87 - 1;
		Cr87_msb <= Cr87[10];
		Cr87_et_zero <= !(|Cr87);
		Cr88_pos <= Cr88;	   
		Cr88_neg <= Cr88 - 1;
		Cr88_msb <= Cr88[10];
		Cr88_et_zero <= !(|Cr88);
		end
	else if (enable_module) begin 
		Cr12_pos <= Cr21_pos;	   
		Cr12_neg <= Cr21_neg;
		Cr12_msb <= Cr21_msb;
		Cr12_et_zero <= Cr21_et_zero;
		Cr21_pos <= Cr31_pos;	   
		Cr21_neg <= Cr31_neg;
		Cr21_msb <= Cr31_msb;
		Cr21_et_zero <= Cr31_et_zero;
		Cr31_pos <= Cr22_pos;	   
		Cr31_neg <= Cr22_neg;
		Cr31_msb <= Cr22_msb;
		Cr31_et_zero <= Cr22_et_zero;
		Cr22_pos <= Cr13_pos;	   
		Cr22_neg <= Cr13_neg;
		Cr22_msb <= Cr13_msb;
		Cr22_et_zero <= Cr13_et_zero;
		Cr13_pos <= Cr14_pos;	   
		Cr13_neg <= Cr14_neg;
		Cr13_msb <= Cr14_msb;
		Cr13_et_zero <= Cr14_et_zero;
		Cr14_pos <= Cr23_pos;	   
		Cr14_neg <= Cr23_neg;
		Cr14_msb <= Cr23_msb;
		Cr14_et_zero <= Cr23_et_zero;
		Cr23_pos <= Cr32_pos;	   
		Cr23_neg <= Cr32_neg;
		Cr23_msb <= Cr32_msb;
		Cr23_et_zero <= Cr32_et_zero;
		Cr32_pos <= Cr41_pos;	   
		Cr32_neg <= Cr41_neg;
		Cr32_msb <= Cr41_msb;
		Cr32_et_zero <= Cr41_et_zero;
		Cr41_pos <= Cr51_pos;	   
		Cr41_neg <= Cr51_neg;
		Cr41_msb <= Cr51_msb;
		Cr41_et_zero <= Cr51_et_zero;
		Cr51_pos <= Cr42_pos;	   
		Cr51_neg <= Cr42_neg;
		Cr51_msb <= Cr42_msb;
		Cr51_et_zero <= Cr42_et_zero;
		Cr42_pos <= Cr33_pos;	   
		Cr42_neg <= Cr33_neg;
		Cr42_msb <= Cr33_msb;
		Cr42_et_zero <= Cr33_et_zero;
		Cr33_pos <= Cr24_pos;	   
		Cr33_neg <= Cr24_neg;
		Cr33_msb <= Cr24_msb;
		Cr33_et_zero <= Cr24_et_zero;
		Cr24_pos <= Cr15_pos;	   
		Cr24_neg <= Cr15_neg;
		Cr24_msb <= Cr15_msb;
		Cr24_et_zero <= Cr15_et_zero;
		Cr15_pos <= Cr16_pos;	   
		Cr15_neg <= Cr16_neg;
		Cr15_msb <= Cr16_msb;
		Cr15_et_zero <= Cr16_et_zero;
		Cr16_pos <= Cr25_pos;	   
		Cr16_neg <= Cr25_neg;
		Cr16_msb <= Cr25_msb;
		Cr16_et_zero <= Cr25_et_zero;
		Cr25_pos <= Cr34_pos;	   
		Cr25_neg <= Cr34_neg;
		Cr25_msb <= Cr34_msb;
		Cr25_et_zero <= Cr34_et_zero;
		Cr34_pos <= Cr43_pos;	   
		Cr34_neg <= Cr43_neg;
		Cr34_msb <= Cr43_msb;
		Cr34_et_zero <= Cr43_et_zero;
		Cr43_pos <= Cr52_pos;	   
		Cr43_neg <= Cr52_neg;
		Cr43_msb <= Cr52_msb;
		Cr43_et_zero <= Cr52_et_zero;
		Cr52_pos <= Cr61_pos;	   
		Cr52_neg <= Cr61_neg;
		Cr52_msb <= Cr61_msb;
		Cr52_et_zero <= Cr61_et_zero;
		Cr61_pos <= Cr71_pos;	   
		Cr61_neg <= Cr71_neg;
		Cr61_msb <= Cr71_msb;
		Cr61_et_zero <= Cr71_et_zero;
		Cr71_pos <= Cr62_pos;	   
		Cr71_neg <= Cr62_neg;
		Cr71_msb <= Cr62_msb;
		Cr71_et_zero <= Cr62_et_zero;
		Cr62_pos <= Cr53_pos;	   
		Cr62_neg <= Cr53_neg;
		Cr62_msb <= Cr53_msb;
		Cr62_et_zero <= Cr53_et_zero;
		Cr53_pos <= Cr44_pos;	   
		Cr53_neg <= Cr44_neg;
		Cr53_msb <= Cr44_msb;
		Cr53_et_zero <= Cr44_et_zero;
		Cr44_pos <= Cr35_pos;	   
		Cr44_neg <= Cr35_neg;
		Cr44_msb <= Cr35_msb;
		Cr44_et_zero <= Cr35_et_zero;
		Cr35_pos <= Cr26_pos;	   
		Cr35_neg <= Cr26_neg;
		Cr35_msb <= Cr26_msb;
		Cr35_et_zero <= Cr26_et_zero;
		Cr26_pos <= Cr17_pos;	   
		Cr26_neg <= Cr17_neg;
		Cr26_msb <= Cr17_msb;
		Cr26_et_zero <= Cr17_et_zero;
		Cr17_pos <= Cr18_pos;	   
		Cr17_neg <= Cr18_neg;
		Cr17_msb <= Cr18_msb;
		Cr17_et_zero <= Cr18_et_zero;
		Cr18_pos <= Cr27_pos;	   
		Cr18_neg <= Cr27_neg;
		Cr18_msb <= Cr27_msb;
		Cr18_et_zero <= Cr27_et_zero;
		Cr27_pos <= Cr36_pos;	   
		Cr27_neg <= Cr36_neg;
		Cr27_msb <= Cr36_msb;
		Cr27_et_zero <= Cr36_et_zero;
		Cr36_pos <= Cr45_pos;	   
		Cr36_neg <= Cr45_neg;
		Cr36_msb <= Cr45_msb;
		Cr36_et_zero <= Cr45_et_zero;
		Cr45_pos <= Cr54_pos;	   
		Cr45_neg <= Cr54_neg;
		Cr45_msb <= Cr54_msb;
		Cr45_et_zero <= Cr54_et_zero;
		Cr54_pos <= Cr63_pos;	   
		Cr54_neg <= Cr63_neg;
		Cr54_msb <= Cr63_msb;
		Cr54_et_zero <= Cr63_et_zero;
		Cr63_pos <= Cr72_pos;	   
		Cr63_neg <= Cr72_neg;
		Cr63_msb <= Cr72_msb;
		Cr63_et_zero <= Cr72_et_zero;
		Cr72_pos <= Cr81_pos;	   
		Cr72_neg <= Cr81_neg;
		Cr72_msb <= Cr81_msb;
		Cr72_et_zero <= Cr81_et_zero;
		Cr81_pos <= Cr82_pos;	   
		Cr81_neg <= Cr82_neg;
		Cr81_msb <= Cr82_msb;
		Cr81_et_zero <= Cr82_et_zero;
		Cr82_pos <= Cr73_pos;	   
		Cr82_neg <= Cr73_neg;
		Cr82_msb <= Cr73_msb;
		Cr82_et_zero <= Cr73_et_zero;
		Cr73_pos <= Cr64_pos;	   
		Cr73_neg <= Cr64_neg;
		Cr73_msb <= Cr64_msb;
		Cr73_et_zero <= Cr64_et_zero;
		Cr64_pos <= Cr55_pos;	   
		Cr64_neg <= Cr55_neg;
		Cr64_msb <= Cr55_msb;
		Cr64_et_zero <= Cr55_et_zero;
		Cr55_pos <= Cr46_pos;	   
		Cr55_neg <= Cr46_neg;
		Cr55_msb <= Cr46_msb;
		Cr55_et_zero <= Cr46_et_zero;
		Cr46_pos <= Cr37_pos;	   
		Cr46_neg <= Cr37_neg;
		Cr46_msb <= Cr37_msb;
		Cr46_et_zero <= Cr37_et_zero;
		Cr37_pos <= Cr28_pos;	   
		Cr37_neg <= Cr28_neg;
		Cr37_msb <= Cr28_msb;
		Cr37_et_zero <= Cr28_et_zero;
		Cr28_pos <= Cr38_pos;	   
		Cr28_neg <= Cr38_neg;
		Cr28_msb <= Cr38_msb;
		Cr28_et_zero <= Cr38_et_zero;
		Cr38_pos <= Cr47_pos;	   
		Cr38_neg <= Cr47_neg;
		Cr38_msb <= Cr47_msb;
		Cr38_et_zero <= Cr47_et_zero;
		Cr47_pos <= Cr56_pos;	   
		Cr47_neg <= Cr56_neg;
		Cr47_msb <= Cr56_msb;
		Cr47_et_zero <= Cr56_et_zero;
		Cr56_pos <= Cr65_pos;	   
		Cr56_neg <= Cr65_neg;
		Cr56_msb <= Cr65_msb;
		Cr56_et_zero <= Cr65_et_zero;
		Cr65_pos <= Cr74_pos;	   
		Cr65_neg <= Cr74_neg;
		Cr65_msb <= Cr74_msb;
		Cr65_et_zero <= Cr74_et_zero;
		Cr74_pos <= Cr83_pos;	   
		Cr74_neg <= Cr83_neg;
		Cr74_msb <= Cr83_msb;
		Cr74_et_zero <= Cr83_et_zero;
		Cr83_pos <= Cr84_pos;	   
		Cr83_neg <= Cr84_neg;
		Cr83_msb <= Cr84_msb;
		Cr83_et_zero <= Cr84_et_zero;
		Cr84_pos <= Cr75_pos;	   
		Cr84_neg <= Cr75_neg;
		Cr84_msb <= Cr75_msb;
		Cr84_et_zero <= Cr75_et_zero;
		Cr75_pos <= Cr66_pos;	   
		Cr75_neg <= Cr66_neg;
		Cr75_msb <= Cr66_msb;
		Cr75_et_zero <= Cr66_et_zero;
		Cr66_pos <= Cr57_pos;	   
		Cr66_neg <= Cr57_neg;
		Cr66_msb <= Cr57_msb;
		Cr66_et_zero <= Cr57_et_zero;
		Cr57_pos <= Cr48_pos;	   
		Cr57_neg <= Cr48_neg;
		Cr57_msb <= Cr48_msb;
		Cr57_et_zero <= Cr48_et_zero;
		Cr48_pos <= Cr58_pos;	   
		Cr48_neg <= Cr58_neg;
		Cr48_msb <= Cr58_msb;
		Cr48_et_zero <= Cr58_et_zero;
		Cr58_pos <= Cr67_pos;	   
		Cr58_neg <= Cr67_neg;
		Cr58_msb <= Cr67_msb;
		Cr58_et_zero <= Cr67_et_zero;
		Cr67_pos <= Cr76_pos;	   
		Cr67_neg <= Cr76_neg;
		Cr67_msb <= Cr76_msb;
		Cr67_et_zero <= Cr76_et_zero;
		Cr76_pos <= Cr85_pos;	   
		Cr76_neg <= Cr85_neg;
		Cr76_msb <= Cr85_msb;
		Cr76_et_zero <= Cr85_et_zero;
		Cr85_pos <= Cr86_pos;	   
		Cr85_neg <= Cr86_neg;
		Cr85_msb <= Cr86_msb;
		Cr85_et_zero <= Cr86_et_zero;
		Cr86_pos <= Cr77_pos;	   
		Cr86_neg <= Cr77_neg;
		Cr86_msb <= Cr77_msb;
		Cr86_et_zero <= Cr77_et_zero;
		Cr77_pos <= Cr68_pos;	   
		Cr77_neg <= Cr68_neg;
		Cr77_msb <= Cr68_msb;
		Cr77_et_zero <= Cr68_et_zero;
		Cr68_pos <= Cr78_pos;	   
		Cr68_neg <= Cr78_neg;
		Cr68_msb <= Cr78_msb;
		Cr68_et_zero <= Cr78_et_zero;
		Cr78_pos <= Cr87_pos;	   
		Cr78_neg <= Cr87_neg;
		Cr78_msb <= Cr87_msb;
		Cr78_et_zero <= Cr87_et_zero;
		Cr87_pos <= Cr88_pos;	   
		Cr87_neg <= Cr88_neg;
		Cr87_msb <= Cr88_msb;
		Cr87_et_zero <= Cr88_et_zero;
		Cr88_pos <= 0;	   
		Cr88_neg <= 0;
		Cr88_msb <= 0;
		Cr88_et_zero <= 1;
		end
end	 

always @(posedge clk)
begin
	if (rst) begin 
		Cr11_diff <= 0; Cr11_1 <= 0; 
		end
	else if (enable) begin // Need to sign extend Cr11 to 12 bits
		Cr11_diff <= {Cr11[10], Cr11} - Cr11_previous;
		Cr11_1 <= Cr11[10] ? { 1'b1, Cr11 } : { 1'b0, Cr11 };
		end
end	 

always @(posedge clk)
begin
	if (rst) 
		Cr11_bits_pos <= 0;
	else if (Cr11_1_pos[10] == 1) 
		Cr11_bits_pos <= 11;	
	else if (Cr11_1_pos[9] == 1) 
		Cr11_bits_pos <= 10;
	else if (Cr11_1_pos[8] == 1) 
		Cr11_bits_pos <= 9;
	else if (Cr11_1_pos[7] == 1) 
		Cr11_bits_pos <= 8;
	else if (Cr11_1_pos[6] == 1) 
		Cr11_bits_pos <= 7;
	else if (Cr11_1_pos[5] == 1) 
		Cr11_bits_pos <= 6;
	else if (Cr11_1_pos[4] == 1) 
		Cr11_bits_pos <= 5;
	else if (Cr11_1_pos[3] == 1) 
		Cr11_bits_pos <= 4;
	else if (Cr11_1_pos[2] == 1) 
		Cr11_bits_pos <= 3;
	else if (Cr11_1_pos[1] == 1) 
		Cr11_bits_pos <= 2;
	else if (Cr11_1_pos[0] == 1) 
		Cr11_bits_pos <= 1;
	else 
	 	Cr11_bits_pos <= 0;
end

always @(posedge clk)
begin
	if (rst) 
		Cr11_bits_neg <= 0;
	else if (Cr11_1_neg[10] == 0) 
		Cr11_bits_neg <= 11;	
	else if (Cr11_1_neg[9] == 0) 
		Cr11_bits_neg <= 10;  
	else if (Cr11_1_neg[8] == 0) 
		Cr11_bits_neg <= 9;   
	else if (Cr11_1_neg[7] == 0) 
		Cr11_bits_neg <= 8;   
	else if (Cr11_1_neg[6] == 0) 
		Cr11_bits_neg <= 7;   
	else if (Cr11_1_neg[5] == 0) 
		Cr11_bits_neg <= 6;   
	else if (Cr11_1_neg[4] == 0) 
		Cr11_bits_neg <= 5;   
	else if (Cr11_1_neg[3] == 0) 
		Cr11_bits_neg <= 4;   
	else if (Cr11_1_neg[2] == 0) 
		Cr11_bits_neg <= 3;   
	else if (Cr11_1_neg[1] == 0) 
		Cr11_bits_neg <= 2;   
	else if (Cr11_1_neg[0] == 0) 
		Cr11_bits_neg <= 1;
	else 
	 	Cr11_bits_neg <= 0;
end


always @(posedge clk)
begin
	if (rst) 
		Cr12_bits_pos <= 0;
	else if (Cr12_pos[9] == 1) 
		Cr12_bits_pos <= 10;
	else if (Cr12_pos[8] == 1) 
		Cr12_bits_pos <= 9;
	else if (Cr12_pos[7] == 1) 
		Cr12_bits_pos <= 8;
	else if (Cr12_pos[6] == 1) 
		Cr12_bits_pos <= 7;
	else if (Cr12_pos[5] == 1) 
		Cr12_bits_pos <= 6;
	else if (Cr12_pos[4] == 1) 
		Cr12_bits_pos <= 5;
	else if (Cr12_pos[3] == 1) 
		Cr12_bits_pos <= 4;
	else if (Cr12_pos[2] == 1) 
		Cr12_bits_pos <= 3;
	else if (Cr12_pos[1] == 1) 
		Cr12_bits_pos <= 2;
	else if (Cr12_pos[0] == 1) 
		Cr12_bits_pos <= 1;
	else 
	 	Cr12_bits_pos <= 0;
end

always @(posedge clk)
begin
	if (rst) 
		Cr12_bits_neg <= 0;
	else if (Cr12_neg[9] == 0) 
		Cr12_bits_neg <= 10;  
	else if (Cr12_neg[8] == 0) 
		Cr12_bits_neg <= 9;   
	else if (Cr12_neg[7] == 0) 
		Cr12_bits_neg <= 8;   
	else if (Cr12_neg[6] == 0) 
		Cr12_bits_neg <= 7;   
	else if (Cr12_neg[5] == 0) 
		Cr12_bits_neg <= 6;   
	else if (Cr12_neg[4] == 0) 
		Cr12_bits_neg <= 5;   
	else if (Cr12_neg[3] == 0) 
		Cr12_bits_neg <= 4;   
	else if (Cr12_neg[2] == 0) 
		Cr12_bits_neg <= 3;   
	else if (Cr12_neg[1] == 0) 
		Cr12_bits_neg <= 2;   
	else if (Cr12_neg[0] == 0) 
		Cr12_bits_neg <= 1;
	else 
	 	Cr12_bits_neg <= 0;
end

always @(posedge clk)
begin
	if (rst) begin
		enable_module <= 0; 
		end
	else if (enable) begin
		enable_module <= 1; 
		end
end	 

always @(posedge clk)
begin
	if (rst) begin
		enable_latch_7 <= 0; 
		end
	else if (block_counter == 68)  begin
		enable_latch_7 <= 0; 
		end
	else if (enable_6) begin
		enable_latch_7 <= 1; 
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		enable_latch_8 <= 0; 
		end
	else if (enable_7) begin
		enable_latch_8 <= 1; 
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		enable_1 <= 0; enable_2 <= 0; enable_3 <= 0;
		enable_4 <= 0; enable_5 <= 0; enable_6 <= 0;
		enable_7 <= 0; enable_8 <= 0; enable_9 <= 0;
		enable_10 <= 0; enable_11 <= 0; enable_12 <= 0;
		enable_13 <= 0;
		end
	else begin
		enable_1 <= enable; enable_2 <= enable_1; enable_3 <= enable_2;
		enable_4 <= enable_3; enable_5 <= enable_4; enable_6 <= enable_5;
		enable_7 <= enable_6; enable_8 <= enable_7; enable_9 <= enable_8;
		enable_10 <= enable_9; enable_11 <= enable_10; enable_12 <= enable_11;
		enable_13 <= enable_12;
		end
end	 

/* These Cr DC and AC code lengths, run lengths, and bit codes
were created from the Huffman table entries in the JPEG file header.
For different Huffman tables for different images, these values
below will need to be changed.  I created a matlab file to automatically
create these entries from the already encoded JPEG image. This matlab program
won't be any help if you're starting from scratch with a .tif or other
raw image file format.  The values below come from a Huffman table, they
do not actually create the Huffman table based on the probabilities of
each code created from the image data.  Crou will need another program to
create the optimal Huffman table, or you can go with a generic Huffman table,
which will have slightly less than the best compression.*/


always @(posedge clk)
begin
Cr_DC_code_length[0] <= 2;
Cr_DC_code_length[1] <= 2;
Cr_DC_code_length[2] <= 2;
Cr_DC_code_length[3] <= 3;
Cr_DC_code_length[4] <= 4;
Cr_DC_code_length[5] <= 5;
Cr_DC_code_length[6] <= 6;
Cr_DC_code_length[7] <= 7;
Cr_DC_code_length[8] <= 8;
Cr_DC_code_length[9] <= 9;
Cr_DC_code_length[10] <= 10;
Cr_DC_code_length[11] <= 11;
Cr_DC[0] <= 11'b00000000000;
Cr_DC[1] <= 11'b01000000000;
Cr_DC[2] <= 11'b10000000000;
Cr_DC[3] <= 11'b11000000000;
Cr_DC[4] <= 11'b11100000000;
Cr_DC[5] <= 11'b11110000000;
Cr_DC[6] <= 11'b11111000000;
Cr_DC[7] <= 11'b11111100000;
Cr_DC[8] <= 11'b11111110000;
Cr_DC[9] <= 11'b11111111000;
Cr_DC[10] <= 11'b11111111100;
Cr_DC[11] <= 11'b11111111110;
Cr_AC_code_length[0] <= 2;
Cr_AC_code_length[1] <= 2;
Cr_AC_code_length[2] <= 3;
Cr_AC_code_length[3] <= 4;
Cr_AC_code_length[4] <= 4;
Cr_AC_code_length[5] <= 4;
Cr_AC_code_length[6] <= 5;
Cr_AC_code_length[7] <= 5;
Cr_AC_code_length[8] <= 5;
Cr_AC_code_length[9] <= 6;
Cr_AC_code_length[10] <= 6;
Cr_AC_code_length[11] <= 7;
Cr_AC_code_length[12] <= 7;
Cr_AC_code_length[13] <= 7;
Cr_AC_code_length[14] <= 7;
Cr_AC_code_length[15] <= 8;
Cr_AC_code_length[16] <= 8;
Cr_AC_code_length[17] <= 8;
Cr_AC_code_length[18] <= 9;
Cr_AC_code_length[19] <= 9;
Cr_AC_code_length[20] <= 9;
Cr_AC_code_length[21] <= 9;
Cr_AC_code_length[22] <= 9;
Cr_AC_code_length[23] <= 10;
Cr_AC_code_length[24] <= 10;
Cr_AC_code_length[25] <= 10;
Cr_AC_code_length[26] <= 10;
Cr_AC_code_length[27] <= 10;
Cr_AC_code_length[28] <= 11;
Cr_AC_code_length[29] <= 11;
Cr_AC_code_length[30] <= 11;
Cr_AC_code_length[31] <= 11;
Cr_AC_code_length[32] <= 12;
Cr_AC_code_length[33] <= 12;
Cr_AC_code_length[34] <= 12;
Cr_AC_code_length[35] <= 12;
Cr_AC_code_length[36] <= 15;
Cr_AC_code_length[37] <= 16;
Cr_AC_code_length[38] <= 16;
Cr_AC_code_length[39] <= 16;
Cr_AC_code_length[40] <= 16;
Cr_AC_code_length[41] <= 16;
Cr_AC_code_length[42] <= 16;
Cr_AC_code_length[43] <= 16;
Cr_AC_code_length[44] <= 16;
Cr_AC_code_length[45] <= 16;
Cr_AC_code_length[46] <= 16;
Cr_AC_code_length[47] <= 16;
Cr_AC_code_length[48] <= 16;
Cr_AC_code_length[49] <= 16;
Cr_AC_code_length[50] <= 16;
Cr_AC_code_length[51] <= 16;
Cr_AC_code_length[52] <= 16;
Cr_AC_code_length[53] <= 16;
Cr_AC_code_length[54] <= 16;
Cr_AC_code_length[55] <= 16;
Cr_AC_code_length[56] <= 16;
Cr_AC_code_length[57] <= 16;
Cr_AC_code_length[58] <= 16;
Cr_AC_code_length[59] <= 16;
Cr_AC_code_length[60] <= 16;
Cr_AC_code_length[61] <= 16;
Cr_AC_code_length[62] <= 16;
Cr_AC_code_length[63] <= 16;
Cr_AC_code_length[64] <= 16;
Cr_AC_code_length[65] <= 16;
Cr_AC_code_length[66] <= 16;
Cr_AC_code_length[67] <= 16;
Cr_AC_code_length[68] <= 16;
Cr_AC_code_length[69] <= 16;
Cr_AC_code_length[70] <= 16;
Cr_AC_code_length[71] <= 16;
Cr_AC_code_length[72] <= 16;
Cr_AC_code_length[73] <= 16;
Cr_AC_code_length[74] <= 16;
Cr_AC_code_length[75] <= 16;
Cr_AC_code_length[76] <= 16;
Cr_AC_code_length[77] <= 16;
Cr_AC_code_length[78] <= 16;
Cr_AC_code_length[79] <= 16;
Cr_AC_code_length[80] <= 16;
Cr_AC_code_length[81] <= 16;
Cr_AC_code_length[82] <= 16;
Cr_AC_code_length[83] <= 16;
Cr_AC_code_length[84] <= 16;
Cr_AC_code_length[85] <= 16;
Cr_AC_code_length[86] <= 16;
Cr_AC_code_length[87] <= 16;
Cr_AC_code_length[88] <= 16;
Cr_AC_code_length[89] <= 16;
Cr_AC_code_length[90] <= 16;
Cr_AC_code_length[91] <= 16;
Cr_AC_code_length[92] <= 16;
Cr_AC_code_length[93] <= 16;
Cr_AC_code_length[94] <= 16;
Cr_AC_code_length[95] <= 16;
Cr_AC_code_length[96] <= 16;
Cr_AC_code_length[97] <= 16;
Cr_AC_code_length[98] <= 16;
Cr_AC_code_length[99] <= 16;
Cr_AC_code_length[100] <= 16;
Cr_AC_code_length[101] <= 16;
Cr_AC_code_length[102] <= 16;
Cr_AC_code_length[103] <= 16;
Cr_AC_code_length[104] <= 16;
Cr_AC_code_length[105] <= 16;
Cr_AC_code_length[106] <= 16;
Cr_AC_code_length[107] <= 16;
Cr_AC_code_length[108] <= 16;
Cr_AC_code_length[109] <= 16;
Cr_AC_code_length[110] <= 16;
Cr_AC_code_length[111] <= 16;
Cr_AC_code_length[112] <= 16;
Cr_AC_code_length[113] <= 16;
Cr_AC_code_length[114] <= 16;
Cr_AC_code_length[115] <= 16;
Cr_AC_code_length[116] <= 16;
Cr_AC_code_length[117] <= 16;
Cr_AC_code_length[118] <= 16;
Cr_AC_code_length[119] <= 16;
Cr_AC_code_length[120] <= 16;
Cr_AC_code_length[121] <= 16;
Cr_AC_code_length[122] <= 16;
Cr_AC_code_length[123] <= 16;
Cr_AC_code_length[124] <= 16;
Cr_AC_code_length[125] <= 16;
Cr_AC_code_length[126] <= 16;
Cr_AC_code_length[127] <= 16;
Cr_AC_code_length[128] <= 16;
Cr_AC_code_length[129] <= 16;
Cr_AC_code_length[130] <= 16;
Cr_AC_code_length[131] <= 16;
Cr_AC_code_length[132] <= 16;
Cr_AC_code_length[133] <= 16;
Cr_AC_code_length[134] <= 16;
Cr_AC_code_length[135] <= 16;
Cr_AC_code_length[136] <= 16;
Cr_AC_code_length[137] <= 16;
Cr_AC_code_length[138] <= 16;
Cr_AC_code_length[139] <= 16;
Cr_AC_code_length[140] <= 16;
Cr_AC_code_length[141] <= 16;
Cr_AC_code_length[142] <= 16;
Cr_AC_code_length[143] <= 16;
Cr_AC_code_length[144] <= 16;
Cr_AC_code_length[145] <= 16;
Cr_AC_code_length[146] <= 16;
Cr_AC_code_length[147] <= 16;
Cr_AC_code_length[148] <= 16;
Cr_AC_code_length[149] <= 16;
Cr_AC_code_length[150] <= 16;
Cr_AC_code_length[151] <= 16;
Cr_AC_code_length[152] <= 16;
Cr_AC_code_length[153] <= 16;
Cr_AC_code_length[154] <= 16;
Cr_AC_code_length[155] <= 16;
Cr_AC_code_length[156] <= 16;
Cr_AC_code_length[157] <= 16;
Cr_AC_code_length[158] <= 16;
Cr_AC_code_length[159] <= 16;
Cr_AC_code_length[160] <= 16;
Cr_AC_code_length[161] <= 16;
Cr_AC[0] <= 16'b0000000000000000;
Cr_AC[1] <= 16'b0100000000000000;
Cr_AC[2] <= 16'b1000000000000000;
Cr_AC[3] <= 16'b1010000000000000;
Cr_AC[4] <= 16'b1011000000000000;
Cr_AC[5] <= 16'b1100000000000000;
Cr_AC[6] <= 16'b1101000000000000;
Cr_AC[7] <= 16'b1101100000000000;
Cr_AC[8] <= 16'b1110000000000000;
Cr_AC[9] <= 16'b1110100000000000;
Cr_AC[10] <= 16'b1110110000000000;
Cr_AC[11] <= 16'b1111000000000000;
Cr_AC[12] <= 16'b1111001000000000;
Cr_AC[13] <= 16'b1111010000000000;
Cr_AC[14] <= 16'b1111011000000000;
Cr_AC[15] <= 16'b1111100000000000;
Cr_AC[16] <= 16'b1111100100000000;
Cr_AC[17] <= 16'b1111101000000000;
Cr_AC[18] <= 16'b1111101100000000;
Cr_AC[19] <= 16'b1111101110000000;
Cr_AC[20] <= 16'b1111110000000000;
Cr_AC[21] <= 16'b1111110010000000;
Cr_AC[22] <= 16'b1111110100000000;
Cr_AC[23] <= 16'b1111110110000000;
Cr_AC[24] <= 16'b1111110111000000;
Cr_AC[25] <= 16'b1111111000000000;
Cr_AC[26] <= 16'b1111111001000000;
Cr_AC[27] <= 16'b1111111010000000;
Cr_AC[28] <= 16'b1111111011000000;
Cr_AC[29] <= 16'b1111111011100000;
Cr_AC[30] <= 16'b1111111100000000;
Cr_AC[31] <= 16'b1111111100100000;
Cr_AC[32] <= 16'b1111111101000000;
Cr_AC[33] <= 16'b1111111101010000;
Cr_AC[34] <= 16'b1111111101100000;
Cr_AC[35] <= 16'b1111111101110000;
Cr_AC[36] <= 16'b1111111110000000;
Cr_AC[37] <= 16'b1111111110000010;
Cr_AC[38] <= 16'b1111111110000011;
Cr_AC[39] <= 16'b1111111110000100;
Cr_AC[40] <= 16'b1111111110000101;
Cr_AC[41] <= 16'b1111111110000110;
Cr_AC[42] <= 16'b1111111110000111;
Cr_AC[43] <= 16'b1111111110001000;
Cr_AC[44] <= 16'b1111111110001001;
Cr_AC[45] <= 16'b1111111110001010;
Cr_AC[46] <= 16'b1111111110001011;
Cr_AC[47] <= 16'b1111111110001100;
Cr_AC[48] <= 16'b1111111110001101;
Cr_AC[49] <= 16'b1111111110001110;
Cr_AC[50] <= 16'b1111111110001111;
Cr_AC[51] <= 16'b1111111110010000;
Cr_AC[52] <= 16'b1111111110010001;
Cr_AC[53] <= 16'b1111111110010010;
Cr_AC[54] <= 16'b1111111110010011;
Cr_AC[55] <= 16'b1111111110010100;
Cr_AC[56] <= 16'b1111111110010101;
Cr_AC[57] <= 16'b1111111110010110;
Cr_AC[58] <= 16'b1111111110010111;
Cr_AC[59] <= 16'b1111111110011000;
Cr_AC[60] <= 16'b1111111110011001;
Cr_AC[61] <= 16'b1111111110011010;
Cr_AC[62] <= 16'b1111111110011011;
Cr_AC[63] <= 16'b1111111110011100;
Cr_AC[64] <= 16'b1111111110011101;
Cr_AC[65] <= 16'b1111111110011110;
Cr_AC[66] <= 16'b1111111110011111;
Cr_AC[67] <= 16'b1111111110100000;
Cr_AC[68] <= 16'b1111111110100001;
Cr_AC[69] <= 16'b1111111110100010;
Cr_AC[70] <= 16'b1111111110100011;
Cr_AC[71] <= 16'b1111111110100100;
Cr_AC[72] <= 16'b1111111110100101;
Cr_AC[73] <= 16'b1111111110100110;
Cr_AC[74] <= 16'b1111111110100111;
Cr_AC[75] <= 16'b1111111110101000;
Cr_AC[76] <= 16'b1111111110101001;
Cr_AC[77] <= 16'b1111111110101010;
Cr_AC[78] <= 16'b1111111110101011;
Cr_AC[79] <= 16'b1111111110101100;
Cr_AC[80] <= 16'b1111111110101101;
Cr_AC[81] <= 16'b1111111110101110;
Cr_AC[82] <= 16'b1111111110101111;
Cr_AC[83] <= 16'b1111111110110000;
Cr_AC[84] <= 16'b1111111110110001;
Cr_AC[85] <= 16'b1111111110110010;
Cr_AC[86] <= 16'b1111111110110011;
Cr_AC[87] <= 16'b1111111110110100;
Cr_AC[88] <= 16'b1111111110110101;
Cr_AC[89] <= 16'b1111111110110110;
Cr_AC[90] <= 16'b1111111110110111;
Cr_AC[91] <= 16'b1111111110111000;
Cr_AC[92] <= 16'b1111111110111001;
Cr_AC[93] <= 16'b1111111110111010;
Cr_AC[94] <= 16'b1111111110111011;
Cr_AC[95] <= 16'b1111111110111100;
Cr_AC[96] <= 16'b1111111110111101;
Cr_AC[97] <= 16'b1111111110111110;
Cr_AC[98] <= 16'b1111111110111111;
Cr_AC[99] <= 16'b1111111111000000;
Cr_AC[100] <= 16'b1111111111000001;
Cr_AC[101] <= 16'b1111111111000010;
Cr_AC[102] <= 16'b1111111111000011;
Cr_AC[103] <= 16'b1111111111000100;
Cr_AC[104] <= 16'b1111111111000101;
Cr_AC[105] <= 16'b1111111111000110;
Cr_AC[106] <= 16'b1111111111000111;
Cr_AC[107] <= 16'b1111111111001000;
Cr_AC[108] <= 16'b1111111111001001;
Cr_AC[109] <= 16'b1111111111001010;
Cr_AC[110] <= 16'b1111111111001011;
Cr_AC[111] <= 16'b1111111111001100;
Cr_AC[112] <= 16'b1111111111001101;
Cr_AC[113] <= 16'b1111111111001110;
Cr_AC[114] <= 16'b1111111111001111;
Cr_AC[115] <= 16'b1111111111010000;
Cr_AC[116] <= 16'b1111111111010001;
Cr_AC[117] <= 16'b1111111111010010;
Cr_AC[118] <= 16'b1111111111010011;
Cr_AC[119] <= 16'b1111111111010100;
Cr_AC[120] <= 16'b1111111111010101;
Cr_AC[121] <= 16'b1111111111010110;
Cr_AC[122] <= 16'b1111111111010111;
Cr_AC[123] <= 16'b1111111111011000;
Cr_AC[124] <= 16'b1111111111011001;
Cr_AC[125] <= 16'b1111111111011010;
Cr_AC[126] <= 16'b1111111111011011;
Cr_AC[127] <= 16'b1111111111011100;
Cr_AC[128] <= 16'b1111111111011101;
Cr_AC[129] <= 16'b1111111111011110;
Cr_AC[130] <= 16'b1111111111011111;
Cr_AC[131] <= 16'b1111111111100000;
Cr_AC[132] <= 16'b1111111111100001;
Cr_AC[133] <= 16'b1111111111100010;
Cr_AC[134] <= 16'b1111111111100011;
Cr_AC[135] <= 16'b1111111111100100;
Cr_AC[136] <= 16'b1111111111100101;
Cr_AC[137] <= 16'b1111111111100110;
Cr_AC[138] <= 16'b1111111111100111;
Cr_AC[139] <= 16'b1111111111101000;
Cr_AC[140] <= 16'b1111111111101001;
Cr_AC[141] <= 16'b1111111111101010;
Cr_AC[142] <= 16'b1111111111101011;
Cr_AC[143] <= 16'b1111111111101100;
Cr_AC[144] <= 16'b1111111111101101;
Cr_AC[145] <= 16'b1111111111101110;
Cr_AC[146] <= 16'b1111111111101111;
Cr_AC[147] <= 16'b1111111111110000;
Cr_AC[148] <= 16'b1111111111110001;
Cr_AC[149] <= 16'b1111111111110010;
Cr_AC[150] <= 16'b1111111111110011;
Cr_AC[151] <= 16'b1111111111110100;
Cr_AC[152] <= 16'b1111111111110101;
Cr_AC[153] <= 16'b1111111111110110;
Cr_AC[154] <= 16'b1111111111110111;
Cr_AC[155] <= 16'b1111111111111000;
Cr_AC[156] <= 16'b1111111111111001;
Cr_AC[157] <= 16'b1111111111111010;
Cr_AC[158] <= 16'b1111111111111011;
Cr_AC[159] <= 16'b1111111111111100;
Cr_AC[160] <= 16'b1111111111111101;
Cr_AC[161] <= 16'b1111111111111110;
Cr_AC_run_code[1] <= 0;
Cr_AC_run_code[2] <= 1;
Cr_AC_run_code[3] <= 2;
Cr_AC_run_code[0] <= 3;
Cr_AC_run_code[4] <= 4;
Cr_AC_run_code[17] <= 5;
Cr_AC_run_code[5] <= 6;
Cr_AC_run_code[18] <= 7;
Cr_AC_run_code[33] <= 8;
Cr_AC_run_code[49] <= 9;
Cr_AC_run_code[65] <= 10;
Cr_AC_run_code[6] <= 11;
Cr_AC_run_code[19] <= 12;
Cr_AC_run_code[81] <= 13;
Cr_AC_run_code[97] <= 14;
Cr_AC_run_code[7] <= 15;
Cr_AC_run_code[34] <= 16;
Cr_AC_run_code[113] <= 17;
Cr_AC_run_code[20] <= 18;
Cr_AC_run_code[50] <= 19;
Cr_AC_run_code[129] <= 20;
Cr_AC_run_code[145] <= 21;
Cr_AC_run_code[161] <= 22;
Cr_AC_run_code[8] <= 23;
Cr_AC_run_code[35] <= 24;
Cr_AC_run_code[66] <= 25;
Cr_AC_run_code[177] <= 26;
Cr_AC_run_code[193] <= 27;
Cr_AC_run_code[21] <= 28;
Cr_AC_run_code[82] <= 29;
Cr_AC_run_code[209] <= 30;
Cr_AC_run_code[240] <= 31;
Cr_AC_run_code[36] <= 32;
Cr_AC_run_code[51] <= 33;
Cr_AC_run_code[98] <= 34;
Cr_AC_run_code[114] <= 35;
Cr_AC_run_code[130] <= 36;
Cr_AC_run_code[9] <= 37;
Cr_AC_run_code[10] <= 38;
Cr_AC_run_code[22] <= 39;
Cr_AC_run_code[23] <= 40;
Cr_AC_run_code[24] <= 41;
Cr_AC_run_code[25] <= 42;
Cr_AC_run_code[26] <= 43;
Cr_AC_run_code[37] <= 44;
Cr_AC_run_code[38] <= 45;
Cr_AC_run_code[39] <= 46;
Cr_AC_run_code[40] <= 47;
Cr_AC_run_code[41] <= 48;
Cr_AC_run_code[42] <= 49;
Cr_AC_run_code[52] <= 50;
Cr_AC_run_code[53] <= 51;
Cr_AC_run_code[54] <= 52;
Cr_AC_run_code[55] <= 53;
Cr_AC_run_code[56] <= 54;
Cr_AC_run_code[57] <= 55;
Cr_AC_run_code[58] <= 56;
Cr_AC_run_code[67] <= 57;
Cr_AC_run_code[68] <= 58;
Cr_AC_run_code[69] <= 59;
Cr_AC_run_code[70] <= 60;
Cr_AC_run_code[71] <= 61;
Cr_AC_run_code[72] <= 62;
Cr_AC_run_code[73] <= 63;
Cr_AC_run_code[74] <= 64;
Cr_AC_run_code[83] <= 65;
Cr_AC_run_code[84] <= 66;
Cr_AC_run_code[85] <= 67;
Cr_AC_run_code[86] <= 68;
Cr_AC_run_code[87] <= 69;
Cr_AC_run_code[88] <= 70;
Cr_AC_run_code[89] <= 71;
Cr_AC_run_code[90] <= 72;
Cr_AC_run_code[99] <= 73;
Cr_AC_run_code[100] <= 74;
Cr_AC_run_code[101] <= 75;
Cr_AC_run_code[102] <= 76;
Cr_AC_run_code[103] <= 77;
Cr_AC_run_code[104] <= 78;
Cr_AC_run_code[105] <= 79;
Cr_AC_run_code[106] <= 80;
Cr_AC_run_code[115] <= 81;
Cr_AC_run_code[116] <= 82;
Cr_AC_run_code[117] <= 83;
Cr_AC_run_code[118] <= 84;
Cr_AC_run_code[119] <= 85;
Cr_AC_run_code[120] <= 86;
Cr_AC_run_code[121] <= 87;
Cr_AC_run_code[122] <= 88;
Cr_AC_run_code[131] <= 89;
Cr_AC_run_code[132] <= 90;
Cr_AC_run_code[133] <= 91;
Cr_AC_run_code[134] <= 92;
Cr_AC_run_code[135] <= 93;
Cr_AC_run_code[136] <= 94;
Cr_AC_run_code[137] <= 95;
Cr_AC_run_code[138] <= 96;
Cr_AC_run_code[146] <= 97;
Cr_AC_run_code[147] <= 98;
Cr_AC_run_code[148] <= 99;
Cr_AC_run_code[149] <= 100;
Cr_AC_run_code[150] <= 101;
Cr_AC_run_code[151] <= 102;
Cr_AC_run_code[152] <= 103;
Cr_AC_run_code[153] <= 104;
Cr_AC_run_code[154] <= 105;
Cr_AC_run_code[162] <= 106;
Cr_AC_run_code[163] <= 107;
Cr_AC_run_code[164] <= 108;
Cr_AC_run_code[165] <= 109;
Cr_AC_run_code[166] <= 110;
Cr_AC_run_code[167] <= 111;
Cr_AC_run_code[168] <= 112;
Cr_AC_run_code[169] <= 113;
Cr_AC_run_code[170] <= 114;
Cr_AC_run_code[178] <= 115;
Cr_AC_run_code[179] <= 116;
Cr_AC_run_code[180] <= 117;
Cr_AC_run_code[181] <= 118;
Cr_AC_run_code[182] <= 119;
Cr_AC_run_code[183] <= 120;
Cr_AC_run_code[184] <= 121;
Cr_AC_run_code[185] <= 122;
Cr_AC_run_code[186] <= 123;
Cr_AC_run_code[194] <= 124;
Cr_AC_run_code[195] <= 125;
Cr_AC_run_code[196] <= 126;
Cr_AC_run_code[197] <= 127;
Cr_AC_run_code[198] <= 128;
Cr_AC_run_code[199] <= 129;
Cr_AC_run_code[200] <= 130;
Cr_AC_run_code[201] <= 131;
Cr_AC_run_code[202] <= 132;
Cr_AC_run_code[210] <= 133;
Cr_AC_run_code[211] <= 134;
Cr_AC_run_code[212] <= 135;
Cr_AC_run_code[213] <= 136;
Cr_AC_run_code[214] <= 137;
Cr_AC_run_code[215] <= 138;
Cr_AC_run_code[216] <= 139;
Cr_AC_run_code[217] <= 140;
Cr_AC_run_code[218] <= 141;
Cr_AC_run_code[225] <= 142;
Cr_AC_run_code[226] <= 143;
Cr_AC_run_code[227] <= 144;
Cr_AC_run_code[228] <= 145;
Cr_AC_run_code[229] <= 146;
Cr_AC_run_code[230] <= 147;
Cr_AC_run_code[231] <= 148;
Cr_AC_run_code[232] <= 149;
Cr_AC_run_code[233] <= 150;
Cr_AC_run_code[234] <= 151;
Cr_AC_run_code[241] <= 152;
Cr_AC_run_code[242] <= 153;
Cr_AC_run_code[243] <= 154;
Cr_AC_run_code[244] <= 155;
Cr_AC_run_code[245] <= 156;
Cr_AC_run_code[246] <= 157;
Cr_AC_run_code[247] <= 158;
Cr_AC_run_code[248] <= 159;
Cr_AC_run_code[249] <= 160;
Cr_AC_run_code[250] <= 161;
	Cr_AC_run_code[16] <= 0;
	Cr_AC_run_code[32] <= 0;
	Cr_AC_run_code[48] <= 0;
	Cr_AC_run_code[64] <= 0;
	Cr_AC_run_code[80] <= 0;
	Cr_AC_run_code[96] <= 0;
	Cr_AC_run_code[112] <= 0;
	Cr_AC_run_code[128] <= 0;
	Cr_AC_run_code[144] <= 0;
	Cr_AC_run_code[160] <= 0;
	Cr_AC_run_code[176] <= 0;
	Cr_AC_run_code[192] <= 0;
	Cr_AC_run_code[208] <= 0;
	Cr_AC_run_code[224] <= 0;
end	




always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[31] <= 0;
	else if (enable_module && rollover_7) 
		JPEG_bitstream[31] <= JPEG_bs_5[31];
	else if (enable_module && orc_8 == 0) 
		JPEG_bitstream[31] <= JPEG_bs_5[31];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[30] <= 0;
	else if (enable_module && rollover_7) 
		JPEG_bitstream[30] <= JPEG_bs_5[30];
	else if (enable_module && orc_8 <= 1) 
		JPEG_bitstream[30] <= JPEG_bs_5[30];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[29] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[29] <= JPEG_bs_5[29];
	else if (enable_module && orc_8 <= 2) 
		JPEG_bitstream[29] <= JPEG_bs_5[29];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[28] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[28] <= JPEG_bs_5[28];
	else if (enable_module && orc_8 <= 3) 
		JPEG_bitstream[28] <= JPEG_bs_5[28];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[27] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[27] <= JPEG_bs_5[27];
	else if (enable_module && orc_8 <= 4) 
		JPEG_bitstream[27] <= JPEG_bs_5[27];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[26] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[26] <= JPEG_bs_5[26];
	else if (enable_module && orc_8 <= 5) 
		JPEG_bitstream[26] <= JPEG_bs_5[26];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[25] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[25] <= JPEG_bs_5[25];
	else if (enable_module && orc_8 <= 6) 
		JPEG_bitstream[25] <= JPEG_bs_5[25];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[24] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[24] <= JPEG_bs_5[24];
	else if (enable_module && orc_8 <= 7) 
		JPEG_bitstream[24] <= JPEG_bs_5[24];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[23] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[23] <= JPEG_bs_5[23];
	else if (enable_module && orc_8 <= 8) 
		JPEG_bitstream[23] <= JPEG_bs_5[23];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[22] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[22] <= JPEG_bs_5[22];
	else if (enable_module && orc_8 <= 9) 
		JPEG_bitstream[22] <= JPEG_bs_5[22];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[21] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[21] <= JPEG_bs_5[21];
	else if (enable_module && orc_8 <= 10) 
		JPEG_bitstream[21] <= JPEG_bs_5[21];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[20] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[20] <= JPEG_bs_5[20];
	else if (enable_module && orc_8 <= 11) 
		JPEG_bitstream[20] <= JPEG_bs_5[20];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[19] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[19] <= JPEG_bs_5[19];
	else if (enable_module && orc_8 <= 12) 
		JPEG_bitstream[19] <= JPEG_bs_5[19];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[18] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[18] <= JPEG_bs_5[18];
	else if (enable_module && orc_8 <= 13) 
		JPEG_bitstream[18] <= JPEG_bs_5[18];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[17] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[17] <= JPEG_bs_5[17];
	else if (enable_module && orc_8 <= 14) 
		JPEG_bitstream[17] <= JPEG_bs_5[17];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[16] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[16] <= JPEG_bs_5[16];
	else if (enable_module && orc_8 <= 15) 
		JPEG_bitstream[16] <= JPEG_bs_5[16];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[15] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[15] <= JPEG_bs_5[15];
	else if (enable_module && orc_8 <= 16) 
		JPEG_bitstream[15] <= JPEG_bs_5[15];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[14] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[14] <= JPEG_bs_5[14];
	else if (enable_module && orc_8 <= 17) 
		JPEG_bitstream[14] <= JPEG_bs_5[14];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[13] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[13] <= JPEG_bs_5[13];
	else if (enable_module && orc_8 <= 18) 
		JPEG_bitstream[13] <= JPEG_bs_5[13];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[12] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[12] <= JPEG_bs_5[12];
	else if (enable_module && orc_8 <= 19) 
		JPEG_bitstream[12] <= JPEG_bs_5[12];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[11] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[11] <= JPEG_bs_5[11];
	else if (enable_module && orc_8 <= 20) 
		JPEG_bitstream[11] <= JPEG_bs_5[11];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[10] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[10] <= JPEG_bs_5[10];
	else if (enable_module && orc_8 <= 21) 
		JPEG_bitstream[10] <= JPEG_bs_5[10];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[9] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[9] <= JPEG_bs_5[9];
	else if (enable_module && orc_8 <= 22) 
		JPEG_bitstream[9] <= JPEG_bs_5[9];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[8] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[8] <= JPEG_bs_5[8];
	else if (enable_module && orc_8 <= 23) 
		JPEG_bitstream[8] <= JPEG_bs_5[8];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[7] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[7] <= JPEG_bs_5[7];
	else if (enable_module && orc_8 <= 24) 
		JPEG_bitstream[7] <= JPEG_bs_5[7];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[6] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[6] <= JPEG_bs_5[6];
	else if (enable_module && orc_8 <= 25) 
		JPEG_bitstream[6] <= JPEG_bs_5[6];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[5] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[5] <= JPEG_bs_5[5];
	else if (enable_module && orc_8 <= 26) 
		JPEG_bitstream[5] <= JPEG_bs_5[5];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[4] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[4] <= JPEG_bs_5[4];
	else if (enable_module && orc_8 <= 27) 
		JPEG_bitstream[4] <= JPEG_bs_5[4];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[3] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[3] <= JPEG_bs_5[3];
	else if (enable_module && orc_8 <= 28) 
		JPEG_bitstream[3] <= JPEG_bs_5[3];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[2] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[2] <= JPEG_bs_5[2];
	else if (enable_module && orc_8 <= 29) 
		JPEG_bitstream[2] <= JPEG_bs_5[2];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[1] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[1] <= JPEG_bs_5[1];
	else if (enable_module && orc_8 <= 30) 
		JPEG_bitstream[1] <= JPEG_bs_5[1];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[0] <= 0;
	else if (enable_module && rollover_7)
		JPEG_bitstream[0] <= JPEG_bs_5[0];
	else if (enable_module && orc_8 <= 31) 
		JPEG_bitstream[0] <= JPEG_bs_5[0];
end
endmodule