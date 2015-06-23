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
		
module cb_huff(clk, rst, enable,
Cb11, Cb12, Cb13, Cb14, Cb15, Cb16, Cb17, Cb18, Cb21, Cb22, Cb23, Cb24, Cb25, Cb26, Cb27, Cb28,
Cb31, Cb32, Cb33, Cb34, Cb35, Cb36, Cb37, Cb38, Cb41, Cb42, Cb43, Cb44, Cb45, Cb46, Cb47, Cb48,
Cb51, Cb52, Cb53, Cb54, Cb55, Cb56, Cb57, Cb58, Cb61, Cb62, Cb63, Cb64, Cb65, Cb66, Cb67, Cb68,
Cb71, Cb72, Cb73, Cb74, Cb75, Cb76, Cb77, Cb78, Cb81, Cb82, Cb83, Cb84, Cb85, Cb86, Cb87, Cb88,
JPEG_bitstream, data_ready, output_reg_count, end_of_block_empty);
input		clk;
input		rst;
input		enable;
input  [10:0]  Cb11, Cb12, Cb13, Cb14, Cb15, Cb16, Cb17, Cb18, Cb21, Cb22, Cb23, Cb24;
input  [10:0]  Cb25, Cb26, Cb27, Cb28, Cb31, Cb32, Cb33, Cb34, Cb35, Cb36, Cb37, Cb38;
input  [10:0]  Cb41, Cb42, Cb43, Cb44, Cb45, Cb46, Cb47, Cb48, Cb51, Cb52, Cb53, Cb54;
input  [10:0]  Cb55, Cb56, Cb57, Cb58, Cb61, Cb62, Cb63, Cb64, Cb65, Cb66, Cb67, Cb68;
input  [10:0]  Cb71, Cb72, Cb73, Cb74, Cb75, Cb76, Cb77, Cb78, Cb81, Cb82, Cb83, Cb84;
input  [10:0]  Cb85, Cb86, Cb87, Cb88;
output	[31:0]	JPEG_bitstream;
output	data_ready;
output		[4:0] output_reg_count;
output	end_of_block_empty;


reg		[7:0] block_counter;
reg		[11:0]  Cb11_amp, Cb11_1_pos, Cb11_1_neg, Cb11_diff;
reg		[11:0]  Cb11_previous, Cb11_1;
reg		[10:0]  Cb12_amp, Cb12_pos, Cb12_neg;
reg		[10:0]  Cb21_pos, Cb21_neg, Cb31_pos, Cb31_neg, Cb22_pos, Cb22_neg;
reg		[10:0]  Cb13_pos, Cb13_neg, Cb14_pos, Cb14_neg, Cb15_pos, Cb15_neg;
reg		[10:0]  Cb16_pos, Cb16_neg, Cb17_pos, Cb17_neg, Cb18_pos, Cb18_neg;
reg		[10:0]  Cb23_pos, Cb23_neg, Cb24_pos, Cb24_neg, Cb25_pos, Cb25_neg;
reg		[10:0]  Cb26_pos, Cb26_neg, Cb27_pos, Cb27_neg, Cb28_pos, Cb28_neg;
reg		[10:0]  Cb32_pos, Cb32_neg;
reg		[10:0]  Cb33_pos, Cb33_neg, Cb34_pos, Cb34_neg, Cb35_pos, Cb35_neg;
reg		[10:0]  Cb36_pos, Cb36_neg, Cb37_pos, Cb37_neg, Cb38_pos, Cb38_neg;
reg		[10:0]  Cb41_pos, Cb41_neg, Cb42_pos, Cb42_neg;
reg		[10:0]  Cb43_pos, Cb43_neg, Cb44_pos, Cb44_neg, Cb45_pos, Cb45_neg;
reg		[10:0]  Cb46_pos, Cb46_neg, Cb47_pos, Cb47_neg, Cb48_pos, Cb48_neg;
reg		[10:0]  Cb51_pos, Cb51_neg, Cb52_pos, Cb52_neg;
reg		[10:0]  Cb53_pos, Cb53_neg, Cb54_pos, Cb54_neg, Cb55_pos, Cb55_neg;
reg		[10:0]  Cb56_pos, Cb56_neg, Cb57_pos, Cb57_neg, Cb58_pos, Cb58_neg;
reg		[10:0]  Cb61_pos, Cb61_neg, Cb62_pos, Cb62_neg;
reg		[10:0]  Cb63_pos, Cb63_neg, Cb64_pos, Cb64_neg, Cb65_pos, Cb65_neg;
reg		[10:0]  Cb66_pos, Cb66_neg, Cb67_pos, Cb67_neg, Cb68_pos, Cb68_neg;
reg		[10:0]  Cb71_pos, Cb71_neg, Cb72_pos, Cb72_neg;
reg		[10:0]  Cb73_pos, Cb73_neg, Cb74_pos, Cb74_neg, Cb75_pos, Cb75_neg;
reg		[10:0]  Cb76_pos, Cb76_neg, Cb77_pos, Cb77_neg, Cb78_pos, Cb78_neg;
reg		[10:0]  Cb81_pos, Cb81_neg, Cb82_pos, Cb82_neg;
reg		[10:0]  Cb83_pos, Cb83_neg, Cb84_pos, Cb84_neg, Cb85_pos, Cb85_neg;
reg		[10:0]  Cb86_pos, Cb86_neg, Cb87_pos, Cb87_neg, Cb88_pos, Cb88_neg;
reg		[3:0]	Cb11_bits_pos, Cb11_bits_neg, Cb11_bits, Cb11_bits_1;
reg		[3:0]	Cb12_bits_pos, Cb12_bits_neg, Cb12_bits, Cb12_bits_1; 
reg		[3:0]	Cb12_bits_2, Cb12_bits_3;
reg		Cb11_msb, Cb12_msb, Cb12_msb_1, data_ready;
reg		enable_1, enable_2, enable_3, enable_4, enable_5, enable_6;
reg		enable_7, enable_8, enable_9, enable_10, enable_11, enable_12;
reg		enable_13, enable_module, enable_latch_7, enable_latch_8;
reg		Cb12_et_zero, rollover, rollover_1, rollover_2, rollover_3;
reg		rollover_4, rollover_5, rollover_6, rollover_7;
reg		Cb21_et_zero, Cb21_msb, Cb31_et_zero, Cb31_msb;
reg		Cb22_et_zero, Cb22_msb, Cb13_et_zero, Cb13_msb;
reg		Cb14_et_zero, Cb14_msb, Cb15_et_zero, Cb15_msb;
reg		Cb16_et_zero, Cb16_msb, Cb17_et_zero, Cb17_msb;
reg		Cb18_et_zero, Cb18_msb;
reg		Cb23_et_zero, Cb23_msb, Cb24_et_zero, Cb24_msb;
reg		Cb25_et_zero, Cb25_msb, Cb26_et_zero, Cb26_msb;
reg		Cb27_et_zero, Cb27_msb, Cb28_et_zero, Cb28_msb;
reg		Cb32_et_zero, Cb32_msb, Cb33_et_zero, Cb33_msb;
reg		Cb34_et_zero, Cb34_msb, Cb35_et_zero, Cb35_msb;
reg		Cb36_et_zero, Cb36_msb, Cb37_et_zero, Cb37_msb;
reg		Cb38_et_zero, Cb38_msb;
reg		Cb41_et_zero, Cb41_msb, Cb42_et_zero, Cb42_msb;
reg		Cb43_et_zero, Cb43_msb, Cb44_et_zero, Cb44_msb;
reg		Cb45_et_zero, Cb45_msb, Cb46_et_zero, Cb46_msb;
reg		Cb47_et_zero, Cb47_msb, Cb48_et_zero, Cb48_msb;
reg		Cb51_et_zero, Cb51_msb, Cb52_et_zero, Cb52_msb;
reg		Cb53_et_zero, Cb53_msb, Cb54_et_zero, Cb54_msb;
reg		Cb55_et_zero, Cb55_msb, Cb56_et_zero, Cb56_msb;
reg		Cb57_et_zero, Cb57_msb, Cb58_et_zero, Cb58_msb;
reg		Cb61_et_zero, Cb61_msb, Cb62_et_zero, Cb62_msb;
reg		Cb63_et_zero, Cb63_msb, Cb64_et_zero, Cb64_msb;
reg		Cb65_et_zero, Cb65_msb, Cb66_et_zero, Cb66_msb;
reg		Cb67_et_zero, Cb67_msb, Cb68_et_zero, Cb68_msb;
reg		Cb71_et_zero, Cb71_msb, Cb72_et_zero, Cb72_msb;
reg		Cb73_et_zero, Cb73_msb, Cb74_et_zero, Cb74_msb;
reg		Cb75_et_zero, Cb75_msb, Cb76_et_zero, Cb76_msb;
reg		Cb77_et_zero, Cb77_msb, Cb78_et_zero, Cb78_msb;
reg		Cb81_et_zero, Cb81_msb, Cb82_et_zero, Cb82_msb;
reg		Cb83_et_zero, Cb83_msb, Cb84_et_zero, Cb84_msb;
reg		Cb85_et_zero, Cb85_msb, Cb86_et_zero, Cb86_msb;
reg		Cb87_et_zero, Cb87_msb, Cb88_et_zero, Cb88_msb;
reg 	Cb12_et_zero_1, Cb12_et_zero_2, Cb12_et_zero_3, Cb12_et_zero_4, Cb12_et_zero_5;
reg		[10:0] Cb_DC [11:0];
reg 	[3:0] Cb_DC_code_length [11:0];
reg		[15:0] Cb_AC [161:0];
reg 	[4:0] Cb_AC_code_length [161:0];
reg 	[7:0] Cb_AC_run_code [250:0];
reg		[10:0] Cb11_Huff, Cb11_Huff_1, Cb11_Huff_2;
reg		[15:0] Cb12_Huff, Cb12_Huff_1, Cb12_Huff_2;
reg		[3:0] Cb11_Huff_count, Cb11_Huff_shift, Cb11_Huff_shift_1, Cb11_amp_shift, Cb12_amp_shift;
reg		[3:0] Cb12_Huff_shift, Cb12_Huff_shift_1, zero_run_length, zrl_1, zrl_2, zrl_3;
reg		[4:0] Cb12_Huff_count, Cb12_Huff_count_1;
reg		[4:0] output_reg_count, Cb11_output_count, old_orc_1, old_orc_2;
reg		[4:0] old_orc_3, old_orc_4, old_orc_5, old_orc_6, Cb12_oc_1;
reg		[4:0] orc_3, orc_4, orc_5, orc_6, orc_7, orc_8;
reg		[4:0] Cb12_output_count;
reg 	[4:0] Cb12_edge, Cb12_edge_1, Cb12_edge_2, Cb12_edge_3, Cb12_edge_4;
reg		[31:0]	JPEG_bitstream, JPEG_bs, JPEG_bs_1, JPEG_bs_2, JPEG_bs_3, JPEG_bs_4, JPEG_bs_5;
reg		[31:0]	JPEG_Cb12_bs, JPEG_Cb12_bs_1, JPEG_Cb12_bs_2, JPEG_Cb12_bs_3, JPEG_Cb12_bs_4;
reg		[31:0]	JPEG_ro_bs, JPEG_ro_bs_1, JPEG_ro_bs_2, JPEG_ro_bs_3, JPEG_ro_bs_4;
reg		[21:0]	Cb11_JPEG_LSBs_3;
reg		[10:0]	Cb11_JPEG_LSBs, Cb11_JPEG_LSBs_1, Cb11_JPEG_LSBs_2;
reg		[9:0]	Cb12_JPEG_LSBs, Cb12_JPEG_LSBs_1, Cb12_JPEG_LSBs_2, Cb12_JPEG_LSBs_3;
reg		[25:0]	Cb11_JPEG_bits, Cb11_JPEG_bits_1, Cb12_JPEG_bits, Cb12_JPEG_LSBs_4;	  
reg		[7:0]	Cb12_code_entry;
reg		third_8_all_0s, fourth_8_all_0s, fifth_8_all_0s, sixth_8_all_0s, seventh_8_all_0s;
reg		eighth_8_all_0s, end_of_block, end_of_block_output, code_15_0, zrl_et_15;
reg		end_of_block_empty;

wire	[7:0]	code_index = { zrl_2, Cb12_bits };



always @(posedge clk)
begin
	if (rst) begin
		third_8_all_0s <= 0; fourth_8_all_0s <= 0;
		fifth_8_all_0s <= 0; sixth_8_all_0s <= 0; seventh_8_all_0s <= 0;
		eighth_8_all_0s <= 0;
		end
	else if (enable_1) begin
		third_8_all_0s <= Cb25_et_zero & Cb34_et_zero & Cb43_et_zero & Cb52_et_zero
					  & Cb61_et_zero & Cb71_et_zero & Cb62_et_zero & Cb53_et_zero;
		fourth_8_all_0s <= Cb44_et_zero & Cb35_et_zero & Cb26_et_zero & Cb17_et_zero
					  & Cb18_et_zero & Cb27_et_zero & Cb36_et_zero & Cb45_et_zero;
		fifth_8_all_0s <= Cb54_et_zero & Cb63_et_zero & Cb72_et_zero & Cb81_et_zero
					  & Cb82_et_zero & Cb73_et_zero & Cb64_et_zero & Cb55_et_zero;
		sixth_8_all_0s <= Cb46_et_zero & Cb37_et_zero & Cb28_et_zero & Cb38_et_zero
					  & Cb47_et_zero & Cb56_et_zero & Cb65_et_zero & Cb74_et_zero;
		seventh_8_all_0s <= Cb83_et_zero & Cb84_et_zero & Cb75_et_zero & Cb66_et_zero
					  & Cb57_et_zero & Cb48_et_zero & Cb58_et_zero & Cb67_et_zero;
		eighth_8_all_0s <= Cb76_et_zero & Cb85_et_zero & Cb86_et_zero & Cb77_et_zero
					  & Cb68_et_zero & Cb78_et_zero & Cb87_et_zero & Cb88_et_zero;						  			  
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
		output_reg_count <= output_reg_count + Cb11_output_count;
		end	
	else if (enable_latch_7) begin
		output_reg_count <= output_reg_count + Cb12_oc_1;
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
		JPEG_ro_bs_4 <= (Cb12_edge_4 <= 1) ? JPEG_ro_bs_3 << 1 : JPEG_ro_bs_3;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		JPEG_bs_3 <= 0; old_orc_6 <= 0; JPEG_ro_bs_3 <= 0;
		Cb12_edge_4 <= 0; 
		end
	else if (enable_module) begin 
		JPEG_bs_3 <= (old_orc_5 >= 2) ? JPEG_bs_2 >> 2 : JPEG_bs_2;
		old_orc_6 <= (old_orc_5 >= 2) ? old_orc_5 - 2 : old_orc_5;
		JPEG_ro_bs_3 <= (Cb12_edge_3 <= 2) ? JPEG_ro_bs_2 << 2 : JPEG_ro_bs_2;
		Cb12_edge_4 <= (Cb12_edge_3 <= 2) ? Cb12_edge_3 : Cb12_edge_3 - 2;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		JPEG_bs_2 <= 0; old_orc_5 <= 0; JPEG_ro_bs_2 <= 0;
		Cb12_edge_3 <= 0; 
		end
	else if (enable_module) begin 
		JPEG_bs_2 <= (old_orc_4 >= 4) ? JPEG_bs_1 >> 4 : JPEG_bs_1;
		old_orc_5 <= (old_orc_4 >= 4) ? old_orc_4 - 4 : old_orc_4;
		JPEG_ro_bs_2 <= (Cb12_edge_2 <= 4) ? JPEG_ro_bs_1 << 4 : JPEG_ro_bs_1;
		Cb12_edge_3 <= (Cb12_edge_2 <= 4) ? Cb12_edge_2 : Cb12_edge_2 - 4;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		JPEG_bs_1 <= 0; old_orc_4 <= 0; JPEG_ro_bs_1 <= 0; 
		Cb12_edge_2 <= 0; 
		end
	else if (enable_module) begin 
		JPEG_bs_1 <= (old_orc_3 >= 8) ? JPEG_bs >> 8 : JPEG_bs;
		old_orc_4 <= (old_orc_3 >= 8) ? old_orc_3 - 8 : old_orc_3;
		JPEG_ro_bs_1 <= (Cb12_edge_1 <= 8) ? JPEG_ro_bs << 8 : JPEG_ro_bs;
		Cb12_edge_2 <= (Cb12_edge_1 <= 8) ? Cb12_edge_1 : Cb12_edge_1 - 8;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		JPEG_bs <= 0; old_orc_3 <= 0; JPEG_ro_bs <= 0;
		Cb12_edge_1 <= 0; Cb11_JPEG_bits_1 <= 0;
		end
	else if (enable_module) begin 
		JPEG_bs <= (old_orc_2 >= 16) ? Cb11_JPEG_bits >> 10 : Cb11_JPEG_bits << 6;
		old_orc_3 <= (old_orc_2 >= 16) ? old_orc_2 - 16 : old_orc_2;
		JPEG_ro_bs <= (Cb12_edge <= 16) ? Cb11_JPEG_bits_1 << 16 : Cb11_JPEG_bits_1;
		Cb12_edge_1 <= (Cb12_edge <= 16) ? Cb12_edge : Cb12_edge - 16;
		Cb11_JPEG_bits_1 <= Cb11_JPEG_bits;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		Cb12_JPEG_bits <= 0; Cb12_edge <= 0;
		end
	else if (enable_module) begin 
		Cb12_JPEG_bits[25] <= (Cb12_Huff_shift_1 >= 16) ? Cb12_JPEG_LSBs_4[25] : Cb12_Huff_2[15];
		Cb12_JPEG_bits[24] <= (Cb12_Huff_shift_1 >= 15) ? Cb12_JPEG_LSBs_4[24] : Cb12_Huff_2[14];
		Cb12_JPEG_bits[23] <= (Cb12_Huff_shift_1 >= 14) ? Cb12_JPEG_LSBs_4[23] : Cb12_Huff_2[13];
		Cb12_JPEG_bits[22] <= (Cb12_Huff_shift_1 >= 13) ? Cb12_JPEG_LSBs_4[22] : Cb12_Huff_2[12];
		Cb12_JPEG_bits[21] <= (Cb12_Huff_shift_1 >= 12) ? Cb12_JPEG_LSBs_4[21] : Cb12_Huff_2[11];
		Cb12_JPEG_bits[20] <= (Cb12_Huff_shift_1 >= 11) ? Cb12_JPEG_LSBs_4[20] : Cb12_Huff_2[10];
		Cb12_JPEG_bits[19] <= (Cb12_Huff_shift_1 >= 10) ? Cb12_JPEG_LSBs_4[19] : Cb12_Huff_2[9];
		Cb12_JPEG_bits[18] <= (Cb12_Huff_shift_1 >= 9) ? Cb12_JPEG_LSBs_4[18] : Cb12_Huff_2[8];
		Cb12_JPEG_bits[17] <= (Cb12_Huff_shift_1 >= 8) ? Cb12_JPEG_LSBs_4[17] : Cb12_Huff_2[7];
		Cb12_JPEG_bits[16] <= (Cb12_Huff_shift_1 >= 7) ? Cb12_JPEG_LSBs_4[16] : Cb12_Huff_2[6];
		Cb12_JPEG_bits[15] <= (Cb12_Huff_shift_1 >= 6) ? Cb12_JPEG_LSBs_4[15] : Cb12_Huff_2[5];
		Cb12_JPEG_bits[14] <= (Cb12_Huff_shift_1 >= 5) ? Cb12_JPEG_LSBs_4[14] : Cb12_Huff_2[4];
		Cb12_JPEG_bits[13] <= (Cb12_Huff_shift_1 >= 4) ? Cb12_JPEG_LSBs_4[13] : Cb12_Huff_2[3];
		Cb12_JPEG_bits[12] <= (Cb12_Huff_shift_1 >= 3) ? Cb12_JPEG_LSBs_4[12] : Cb12_Huff_2[2];
		Cb12_JPEG_bits[11] <= (Cb12_Huff_shift_1 >= 2) ? Cb12_JPEG_LSBs_4[11] : Cb12_Huff_2[1];
		Cb12_JPEG_bits[10] <= (Cb12_Huff_shift_1 >= 1) ? Cb12_JPEG_LSBs_4[10] : Cb12_Huff_2[0];
		Cb12_JPEG_bits[9:0] <= Cb12_JPEG_LSBs_4[9:0];
		Cb12_edge <= old_orc_2 + 26; // 26 is the size of Cb11_JPEG_bits
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		Cb11_JPEG_bits <= 0; 
		end
	else if (enable_7) begin 
		Cb11_JPEG_bits[25] <= (Cb11_Huff_shift_1 >= 11) ? Cb11_JPEG_LSBs_3[21] : Cb11_Huff_2[10];
		Cb11_JPEG_bits[24] <= (Cb11_Huff_shift_1 >= 10) ? Cb11_JPEG_LSBs_3[20] : Cb11_Huff_2[9];
		Cb11_JPEG_bits[23] <= (Cb11_Huff_shift_1 >= 9) ? Cb11_JPEG_LSBs_3[19] : Cb11_Huff_2[8];
		Cb11_JPEG_bits[22] <= (Cb11_Huff_shift_1 >= 8) ? Cb11_JPEG_LSBs_3[18] : Cb11_Huff_2[7];
		Cb11_JPEG_bits[21] <= (Cb11_Huff_shift_1 >= 7) ? Cb11_JPEG_LSBs_3[17] : Cb11_Huff_2[6];
		Cb11_JPEG_bits[20] <= (Cb11_Huff_shift_1 >= 6) ? Cb11_JPEG_LSBs_3[16] : Cb11_Huff_2[5];
		Cb11_JPEG_bits[19] <= (Cb11_Huff_shift_1 >= 5) ? Cb11_JPEG_LSBs_3[15] : Cb11_Huff_2[4];
		Cb11_JPEG_bits[18] <= (Cb11_Huff_shift_1 >= 4) ? Cb11_JPEG_LSBs_3[14] : Cb11_Huff_2[3];
		Cb11_JPEG_bits[17] <= (Cb11_Huff_shift_1 >= 3) ? Cb11_JPEG_LSBs_3[13] : Cb11_Huff_2[2];
		Cb11_JPEG_bits[16] <= (Cb11_Huff_shift_1 >= 2) ? Cb11_JPEG_LSBs_3[12] : Cb11_Huff_2[1];
		Cb11_JPEG_bits[15] <= (Cb11_Huff_shift_1 >= 1) ? Cb11_JPEG_LSBs_3[11] : Cb11_Huff_2[0];
		Cb11_JPEG_bits[14:4] <= Cb11_JPEG_LSBs_3[10:0];
		end
	else if (enable_latch_8) begin
		Cb11_JPEG_bits <= Cb12_JPEG_bits;
		end
end	


always @(posedge clk)
begin
	if (rst) begin
		Cb12_oc_1 <= 0; Cb12_JPEG_LSBs_4 <= 0;
		Cb12_Huff_2 <= 0; Cb12_Huff_shift_1 <= 0;
		end
	else if (enable_module) begin 
		Cb12_oc_1 <= (Cb12_et_zero_5 & !code_15_0 & block_counter != 67) ? 0 : 
			Cb12_bits_3 + Cb12_Huff_count_1;
		Cb12_JPEG_LSBs_4 <= Cb12_JPEG_LSBs_3 << Cb12_Huff_shift;
		Cb12_Huff_2 <= Cb12_Huff_1;
		Cb12_Huff_shift_1 <= Cb12_Huff_shift;
		end
end

always @(posedge clk)
begin
	if (rst) begin
		Cb11_JPEG_LSBs_3 <= 0; Cb11_Huff_2 <= 0; 
		Cb11_Huff_shift_1 <= 0; 
		end
	else if (enable_6) begin 
		Cb11_JPEG_LSBs_3 <= Cb11_JPEG_LSBs_2 << Cb11_Huff_shift;
		Cb11_Huff_2 <= Cb11_Huff_1;
		Cb11_Huff_shift_1 <= Cb11_Huff_shift;
		end
end	


always @(posedge clk)
begin
	if (rst) begin
		Cb12_Huff_shift <= 0;
		Cb12_Huff_1 <= 0; Cb12_JPEG_LSBs_3 <= 0; Cb12_bits_3 <= 0;
		Cb12_Huff_count_1 <= 0; Cb12_et_zero_5 <= 0; code_15_0 <= 0;
		end
	else if (enable_module) begin 
		Cb12_Huff_shift <= 16 - Cb12_Huff_count;
		Cb12_Huff_1 <= Cb12_Huff;
		Cb12_JPEG_LSBs_3 <= Cb12_JPEG_LSBs_2;
		Cb12_bits_3 <= Cb12_bits_2;
		Cb12_Huff_count_1 <= Cb12_Huff_count;
		Cb12_et_zero_5 <= Cb12_et_zero_4;
		code_15_0 <= zrl_et_15 & !end_of_block;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		Cb11_output_count <= 0; Cb11_JPEG_LSBs_2 <= 0; Cb11_Huff_shift <= 0;
		Cb11_Huff_1 <= 0;
		end
	else if (enable_5) begin 
		Cb11_output_count <= Cb11_bits_1 + Cb11_Huff_count;
		Cb11_JPEG_LSBs_2 <= Cb11_JPEG_LSBs_1 << Cb11_amp_shift;
		Cb11_Huff_shift <= 11 - Cb11_Huff_count;
		Cb11_Huff_1 <= Cb11_Huff;
		end
end	


always @(posedge clk)
begin
	if (rst) begin
		Cb12_JPEG_LSBs_2 <= 0;
		Cb12_Huff <= 0; Cb12_Huff_count <= 0; Cb12_bits_2 <= 0;
		Cb12_et_zero_4 <= 0; zrl_et_15 <= 0; zrl_3 <= 0;
		end
	else if (enable_module) begin
		Cb12_JPEG_LSBs_2 <= Cb12_JPEG_LSBs_1 << Cb12_amp_shift;
		Cb12_Huff <= Cb_AC[Cb12_code_entry];
		Cb12_Huff_count <= Cb_AC_code_length[Cb12_code_entry];
		Cb12_bits_2 <= Cb12_bits_1;
		Cb12_et_zero_4 <= Cb12_et_zero_3;
		zrl_et_15 <= zrl_3 == 15;
		zrl_3 <= zrl_2;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		Cb11_Huff <= 0; Cb11_Huff_count <= 0; Cb11_amp_shift <= 0;
		Cb11_JPEG_LSBs_1 <= 0; Cb11_bits_1 <= 0; 
		end
	else if (enable_4) begin
		Cb11_Huff[10:0] <= Cb_DC[Cb11_bits];
		Cb11_Huff_count <= Cb_DC_code_length[Cb11_bits];
		Cb11_amp_shift <= 11 - Cb11_bits;
		Cb11_JPEG_LSBs_1 <= Cb11_JPEG_LSBs;
		Cb11_bits_1 <= Cb11_bits;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		Cb12_code_entry <= 0; Cb12_JPEG_LSBs_1 <= 0; Cb12_amp_shift <= 0; 
		Cb12_bits_1 <= 0; Cb12_et_zero_3 <= 0; zrl_2 <= 0;
		end
	else if (enable_module) begin
		Cb12_code_entry <= Cb_AC_run_code[code_index];
		Cb12_JPEG_LSBs_1 <= Cb12_JPEG_LSBs;
		Cb12_amp_shift <= 10 - Cb12_bits;
		Cb12_bits_1 <= Cb12_bits;
		Cb12_et_zero_3 <= Cb12_et_zero_2;
		zrl_2 <= zrl_1;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		Cb11_bits <= 0; Cb11_JPEG_LSBs <= 0; 
		end
	else if (enable_3) begin
		Cb11_bits <= Cb11_msb ? Cb11_bits_neg : Cb11_bits_pos;
		Cb11_JPEG_LSBs <= Cb11_amp[10:0]; // The top bit of Cb11_amp is the sign bit
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		Cb12_bits <= 0; Cb12_JPEG_LSBs <= 0; zrl_1 <= 0;
		Cb12_et_zero_2 <= 0;
		end
	else if (enable_module) begin 
		Cb12_bits <= Cb12_msb_1 ? Cb12_bits_neg : Cb12_bits_pos;
		Cb12_JPEG_LSBs <= Cb12_amp[9:0]; // The top bit of Cb12_amp is the sign bit
		zrl_1 <= block_counter == 62 & Cb12_et_zero ? 0 : zero_run_length;
		Cb12_et_zero_2 <= Cb12_et_zero_1;
		end
end	

// Cb11_amp is the amplitude that will be represented in bits in the 
// JPEG code, following the run length code
always @(posedge clk)
begin
	if (rst) begin
		Cb11_amp <= 0;
		end
	else if (enable_2) begin 
		Cb11_amp <= Cb11_msb ? Cb11_1_neg : Cb11_1_pos;
		end
end	


always @(posedge clk)
begin
	if (rst) 
		zero_run_length <= 0; 
	else if (enable)
		zero_run_length <= 0; 
	else if (enable_module) 
		zero_run_length <= Cb12_et_zero ? zero_run_length + 1: 0;
end	 

always @(posedge clk)
begin
	if (rst) begin
		Cb12_amp <= 0;  
		Cb12_et_zero_1 <= 0; Cb12_msb_1 <= 0;
		end
	else if (enable_module) begin
		Cb12_amp <= Cb12_msb ? Cb12_neg : Cb12_pos;
		Cb12_et_zero_1 <= Cb12_et_zero;
		Cb12_msb_1 <= Cb12_msb;
		end
end	 

always @(posedge clk)
begin
	if (rst) begin
		Cb11_1_pos <= 0; Cb11_1_neg <= 0; Cb11_msb <= 0;
		Cb11_previous <= 0; 
		end
	else if (enable_1) begin
		Cb11_1_pos <= Cb11_diff;
		Cb11_1_neg <= Cb11_diff - 1;
		Cb11_msb <= Cb11_diff[11];
		Cb11_previous <= Cb11_1;
		end
end	 

always @(posedge clk)
begin
	if (rst) begin 
		Cb12_pos <= 0; Cb12_neg <= 0; Cb12_msb <= 0; Cb12_et_zero <= 0; 
		Cb13_pos <= 0; Cb13_neg <= 0; Cb13_msb <= 0; Cb13_et_zero <= 0;
		Cb14_pos <= 0; Cb14_neg <= 0; Cb14_msb <= 0; Cb14_et_zero <= 0; 
		Cb15_pos <= 0; Cb15_neg <= 0; Cb15_msb <= 0; Cb15_et_zero <= 0;
		Cb16_pos <= 0; Cb16_neg <= 0; Cb16_msb <= 0; Cb16_et_zero <= 0; 
		Cb17_pos <= 0; Cb17_neg <= 0; Cb17_msb <= 0; Cb17_et_zero <= 0;
		Cb18_pos <= 0; Cb18_neg <= 0; Cb18_msb <= 0; Cb18_et_zero <= 0; 
		Cb21_pos <= 0; Cb21_neg <= 0; Cb21_msb <= 0; Cb21_et_zero <= 0;
		Cb22_pos <= 0; Cb22_neg <= 0; Cb22_msb <= 0; Cb22_et_zero <= 0; 
		Cb23_pos <= 0; Cb23_neg <= 0; Cb23_msb <= 0; Cb23_et_zero <= 0;
		Cb24_pos <= 0; Cb24_neg <= 0; Cb24_msb <= 0; Cb24_et_zero <= 0; 
		Cb25_pos <= 0; Cb25_neg <= 0; Cb25_msb <= 0; Cb25_et_zero <= 0;
		Cb26_pos <= 0; Cb26_neg <= 0; Cb26_msb <= 0; Cb26_et_zero <= 0; 
		Cb27_pos <= 0; Cb27_neg <= 0; Cb27_msb <= 0; Cb27_et_zero <= 0;
		Cb28_pos <= 0; Cb28_neg <= 0; Cb28_msb <= 0; Cb28_et_zero <= 0; 
		Cb31_pos <= 0; Cb31_neg <= 0; Cb31_msb <= 0; Cb31_et_zero <= 0;  
		Cb32_pos <= 0; Cb32_neg <= 0; Cb32_msb <= 0; Cb32_et_zero <= 0; 
		Cb33_pos <= 0; Cb33_neg <= 0; Cb33_msb <= 0; Cb33_et_zero <= 0;
		Cb34_pos <= 0; Cb34_neg <= 0; Cb34_msb <= 0; Cb34_et_zero <= 0; 
		Cb35_pos <= 0; Cb35_neg <= 0; Cb35_msb <= 0; Cb35_et_zero <= 0;
		Cb36_pos <= 0; Cb36_neg <= 0; Cb36_msb <= 0; Cb36_et_zero <= 0; 
		Cb37_pos <= 0; Cb37_neg <= 0; Cb37_msb <= 0; Cb37_et_zero <= 0;
		Cb38_pos <= 0; Cb38_neg <= 0; Cb38_msb <= 0; Cb38_et_zero <= 0;
		Cb41_pos <= 0; Cb41_neg <= 0; Cb41_msb <= 0; Cb41_et_zero <= 0;  
		Cb42_pos <= 0; Cb42_neg <= 0; Cb42_msb <= 0; Cb42_et_zero <= 0; 
		Cb43_pos <= 0; Cb43_neg <= 0; Cb43_msb <= 0; Cb43_et_zero <= 0;
		Cb44_pos <= 0; Cb44_neg <= 0; Cb44_msb <= 0; Cb44_et_zero <= 0; 
		Cb45_pos <= 0; Cb45_neg <= 0; Cb45_msb <= 0; Cb45_et_zero <= 0;
		Cb46_pos <= 0; Cb46_neg <= 0; Cb46_msb <= 0; Cb46_et_zero <= 0; 
		Cb47_pos <= 0; Cb47_neg <= 0; Cb47_msb <= 0; Cb47_et_zero <= 0;
		Cb48_pos <= 0; Cb48_neg <= 0; Cb48_msb <= 0; Cb48_et_zero <= 0;
		Cb51_pos <= 0; Cb51_neg <= 0; Cb51_msb <= 0; Cb51_et_zero <= 0;  
		Cb52_pos <= 0; Cb52_neg <= 0; Cb52_msb <= 0; Cb52_et_zero <= 0; 
		Cb53_pos <= 0; Cb53_neg <= 0; Cb53_msb <= 0; Cb53_et_zero <= 0;
		Cb54_pos <= 0; Cb54_neg <= 0; Cb54_msb <= 0; Cb54_et_zero <= 0; 
		Cb55_pos <= 0; Cb55_neg <= 0; Cb55_msb <= 0; Cb55_et_zero <= 0;
		Cb56_pos <= 0; Cb56_neg <= 0; Cb56_msb <= 0; Cb56_et_zero <= 0; 
		Cb57_pos <= 0; Cb57_neg <= 0; Cb57_msb <= 0; Cb57_et_zero <= 0;
		Cb58_pos <= 0; Cb58_neg <= 0; Cb58_msb <= 0; Cb58_et_zero <= 0;
		Cb61_pos <= 0; Cb61_neg <= 0; Cb61_msb <= 0; Cb61_et_zero <= 0;  
		Cb62_pos <= 0; Cb62_neg <= 0; Cb62_msb <= 0; Cb62_et_zero <= 0; 
		Cb63_pos <= 0; Cb63_neg <= 0; Cb63_msb <= 0; Cb63_et_zero <= 0;
		Cb64_pos <= 0; Cb64_neg <= 0; Cb64_msb <= 0; Cb64_et_zero <= 0; 
		Cb65_pos <= 0; Cb65_neg <= 0; Cb65_msb <= 0; Cb65_et_zero <= 0;
		Cb66_pos <= 0; Cb66_neg <= 0; Cb66_msb <= 0; Cb66_et_zero <= 0; 
		Cb67_pos <= 0; Cb67_neg <= 0; Cb67_msb <= 0; Cb67_et_zero <= 0;
		Cb68_pos <= 0; Cb68_neg <= 0; Cb68_msb <= 0; Cb68_et_zero <= 0;
		Cb71_pos <= 0; Cb71_neg <= 0; Cb71_msb <= 0; Cb71_et_zero <= 0;  
		Cb72_pos <= 0; Cb72_neg <= 0; Cb72_msb <= 0; Cb72_et_zero <= 0; 
		Cb73_pos <= 0; Cb73_neg <= 0; Cb73_msb <= 0; Cb73_et_zero <= 0;
		Cb74_pos <= 0; Cb74_neg <= 0; Cb74_msb <= 0; Cb74_et_zero <= 0; 
		Cb75_pos <= 0; Cb75_neg <= 0; Cb75_msb <= 0; Cb75_et_zero <= 0;
		Cb76_pos <= 0; Cb76_neg <= 0; Cb76_msb <= 0; Cb76_et_zero <= 0; 
		Cb77_pos <= 0; Cb77_neg <= 0; Cb77_msb <= 0; Cb77_et_zero <= 0;
		Cb78_pos <= 0; Cb78_neg <= 0; Cb78_msb <= 0; Cb78_et_zero <= 0;
		Cb81_pos <= 0; Cb81_neg <= 0; Cb81_msb <= 0; Cb81_et_zero <= 0;  
		Cb82_pos <= 0; Cb82_neg <= 0; Cb82_msb <= 0; Cb82_et_zero <= 0; 
		Cb83_pos <= 0; Cb83_neg <= 0; Cb83_msb <= 0; Cb83_et_zero <= 0;
		Cb84_pos <= 0; Cb84_neg <= 0; Cb84_msb <= 0; Cb84_et_zero <= 0; 
		Cb85_pos <= 0; Cb85_neg <= 0; Cb85_msb <= 0; Cb85_et_zero <= 0;
		Cb86_pos <= 0; Cb86_neg <= 0; Cb86_msb <= 0; Cb86_et_zero <= 0; 
		Cb87_pos <= 0; Cb87_neg <= 0; Cb87_msb <= 0; Cb87_et_zero <= 0;
		Cb88_pos <= 0; Cb88_neg <= 0; Cb88_msb <= 0; Cb88_et_zero <= 0; 
		end
	else if (enable) begin 
		Cb12_pos <= Cb12;	   
		Cb12_neg <= Cb12 - 1;
		Cb12_msb <= Cb12[10];
		Cb12_et_zero <= !(|Cb12);
		Cb13_pos <= Cb13;	   
		Cb13_neg <= Cb13 - 1;
		Cb13_msb <= Cb13[10];
		Cb13_et_zero <= !(|Cb13);
		Cb14_pos <= Cb14;	   
		Cb14_neg <= Cb14 - 1;
		Cb14_msb <= Cb14[10];
		Cb14_et_zero <= !(|Cb14);
		Cb15_pos <= Cb15;	   
		Cb15_neg <= Cb15 - 1;
		Cb15_msb <= Cb15[10];
		Cb15_et_zero <= !(|Cb15);
		Cb16_pos <= Cb16;	   
		Cb16_neg <= Cb16 - 1;
		Cb16_msb <= Cb16[10];
		Cb16_et_zero <= !(|Cb16);
		Cb17_pos <= Cb17;	   
		Cb17_neg <= Cb17 - 1;
		Cb17_msb <= Cb17[10];
		Cb17_et_zero <= !(|Cb17);
		Cb18_pos <= Cb18;	   
		Cb18_neg <= Cb18 - 1;
		Cb18_msb <= Cb18[10];
		Cb18_et_zero <= !(|Cb18);
		Cb21_pos <= Cb21;	   
		Cb21_neg <= Cb21 - 1;
		Cb21_msb <= Cb21[10];
		Cb21_et_zero <= !(|Cb21);
		Cb22_pos <= Cb22;	   
		Cb22_neg <= Cb22 - 1;
		Cb22_msb <= Cb22[10];
		Cb22_et_zero <= !(|Cb22);
		Cb23_pos <= Cb23;	   
		Cb23_neg <= Cb23 - 1;
		Cb23_msb <= Cb23[10];
		Cb23_et_zero <= !(|Cb23);
		Cb24_pos <= Cb24;	   
		Cb24_neg <= Cb24 - 1;
		Cb24_msb <= Cb24[10];
		Cb24_et_zero <= !(|Cb24);
		Cb25_pos <= Cb25;	   
		Cb25_neg <= Cb25 - 1;
		Cb25_msb <= Cb25[10];
		Cb25_et_zero <= !(|Cb25);
		Cb26_pos <= Cb26;	   
		Cb26_neg <= Cb26 - 1;
		Cb26_msb <= Cb26[10];
		Cb26_et_zero <= !(|Cb26);
		Cb27_pos <= Cb27;	   
		Cb27_neg <= Cb27 - 1;
		Cb27_msb <= Cb27[10];
		Cb27_et_zero <= !(|Cb27);
		Cb28_pos <= Cb28;	   
		Cb28_neg <= Cb28 - 1;
		Cb28_msb <= Cb28[10];
		Cb28_et_zero <= !(|Cb28);
		Cb31_pos <= Cb31;	   
		Cb31_neg <= Cb31 - 1;
		Cb31_msb <= Cb31[10];
		Cb31_et_zero <= !(|Cb31);
		Cb32_pos <= Cb32;	   
		Cb32_neg <= Cb32 - 1;
		Cb32_msb <= Cb32[10];
		Cb32_et_zero <= !(|Cb32);
		Cb33_pos <= Cb33;	   
		Cb33_neg <= Cb33 - 1;
		Cb33_msb <= Cb33[10];
		Cb33_et_zero <= !(|Cb33);
		Cb34_pos <= Cb34;	   
		Cb34_neg <= Cb34 - 1;
		Cb34_msb <= Cb34[10];
		Cb34_et_zero <= !(|Cb34);
		Cb35_pos <= Cb35;	   
		Cb35_neg <= Cb35 - 1;
		Cb35_msb <= Cb35[10];
		Cb35_et_zero <= !(|Cb35);
		Cb36_pos <= Cb36;	   
		Cb36_neg <= Cb36 - 1;
		Cb36_msb <= Cb36[10];
		Cb36_et_zero <= !(|Cb36);
		Cb37_pos <= Cb37;	   
		Cb37_neg <= Cb37 - 1;
		Cb37_msb <= Cb37[10];
		Cb37_et_zero <= !(|Cb37);
		Cb38_pos <= Cb38;	   
		Cb38_neg <= Cb38 - 1;
		Cb38_msb <= Cb38[10];
		Cb38_et_zero <= !(|Cb38);
		Cb41_pos <= Cb41;	   
		Cb41_neg <= Cb41 - 1;
		Cb41_msb <= Cb41[10];
		Cb41_et_zero <= !(|Cb41);
		Cb42_pos <= Cb42;	   
		Cb42_neg <= Cb42 - 1;
		Cb42_msb <= Cb42[10];
		Cb42_et_zero <= !(|Cb42);
		Cb43_pos <= Cb43;	   
		Cb43_neg <= Cb43 - 1;
		Cb43_msb <= Cb43[10];
		Cb43_et_zero <= !(|Cb43);
		Cb44_pos <= Cb44;	   
		Cb44_neg <= Cb44 - 1;
		Cb44_msb <= Cb44[10];
		Cb44_et_zero <= !(|Cb44);
		Cb45_pos <= Cb45;	   
		Cb45_neg <= Cb45 - 1;
		Cb45_msb <= Cb45[10];
		Cb45_et_zero <= !(|Cb45);
		Cb46_pos <= Cb46;	   
		Cb46_neg <= Cb46 - 1;
		Cb46_msb <= Cb46[10];
		Cb46_et_zero <= !(|Cb46);
		Cb47_pos <= Cb47;	   
		Cb47_neg <= Cb47 - 1;
		Cb47_msb <= Cb47[10];
		Cb47_et_zero <= !(|Cb47);
		Cb48_pos <= Cb48;	   
		Cb48_neg <= Cb48 - 1;
		Cb48_msb <= Cb48[10];
		Cb48_et_zero <= !(|Cb48);
		Cb51_pos <= Cb51;	   
		Cb51_neg <= Cb51 - 1;
		Cb51_msb <= Cb51[10];
		Cb51_et_zero <= !(|Cb51);
		Cb52_pos <= Cb52;	   
		Cb52_neg <= Cb52 - 1;
		Cb52_msb <= Cb52[10];
		Cb52_et_zero <= !(|Cb52);
		Cb53_pos <= Cb53;	   
		Cb53_neg <= Cb53 - 1;
		Cb53_msb <= Cb53[10];
		Cb53_et_zero <= !(|Cb53);
		Cb54_pos <= Cb54;	   
		Cb54_neg <= Cb54 - 1;
		Cb54_msb <= Cb54[10];
		Cb54_et_zero <= !(|Cb54);
		Cb55_pos <= Cb55;	   
		Cb55_neg <= Cb55 - 1;
		Cb55_msb <= Cb55[10];
		Cb55_et_zero <= !(|Cb55);
		Cb56_pos <= Cb56;	   
		Cb56_neg <= Cb56 - 1;
		Cb56_msb <= Cb56[10];
		Cb56_et_zero <= !(|Cb56);
		Cb57_pos <= Cb57;	   
		Cb57_neg <= Cb57 - 1;
		Cb57_msb <= Cb57[10];
		Cb57_et_zero <= !(|Cb57);
		Cb58_pos <= Cb58;	   
		Cb58_neg <= Cb58 - 1;
		Cb58_msb <= Cb58[10];
		Cb58_et_zero <= !(|Cb58);
		Cb61_pos <= Cb61;	   
		Cb61_neg <= Cb61 - 1;
		Cb61_msb <= Cb61[10];
		Cb61_et_zero <= !(|Cb61);
		Cb62_pos <= Cb62;	   
		Cb62_neg <= Cb62 - 1;
		Cb62_msb <= Cb62[10];
		Cb62_et_zero <= !(|Cb62);
		Cb63_pos <= Cb63;	   
		Cb63_neg <= Cb63 - 1;
		Cb63_msb <= Cb63[10];
		Cb63_et_zero <= !(|Cb63);
		Cb64_pos <= Cb64;	   
		Cb64_neg <= Cb64 - 1;
		Cb64_msb <= Cb64[10];
		Cb64_et_zero <= !(|Cb64);
		Cb65_pos <= Cb65;	   
		Cb65_neg <= Cb65 - 1;
		Cb65_msb <= Cb65[10];
		Cb65_et_zero <= !(|Cb65);
		Cb66_pos <= Cb66;	   
		Cb66_neg <= Cb66 - 1;
		Cb66_msb <= Cb66[10];
		Cb66_et_zero <= !(|Cb66);
		Cb67_pos <= Cb67;	   
		Cb67_neg <= Cb67 - 1;
		Cb67_msb <= Cb67[10];
		Cb67_et_zero <= !(|Cb67);
		Cb68_pos <= Cb68;	   
		Cb68_neg <= Cb68 - 1;
		Cb68_msb <= Cb68[10];
		Cb68_et_zero <= !(|Cb68);
		Cb71_pos <= Cb71;	   
		Cb71_neg <= Cb71 - 1;
		Cb71_msb <= Cb71[10];
		Cb71_et_zero <= !(|Cb71);
		Cb72_pos <= Cb72;	   
		Cb72_neg <= Cb72 - 1;
		Cb72_msb <= Cb72[10];
		Cb72_et_zero <= !(|Cb72);
		Cb73_pos <= Cb73;	   
		Cb73_neg <= Cb73 - 1;
		Cb73_msb <= Cb73[10];
		Cb73_et_zero <= !(|Cb73);
		Cb74_pos <= Cb74;	   
		Cb74_neg <= Cb74 - 1;
		Cb74_msb <= Cb74[10];
		Cb74_et_zero <= !(|Cb74);
		Cb75_pos <= Cb75;	   
		Cb75_neg <= Cb75 - 1;
		Cb75_msb <= Cb75[10];
		Cb75_et_zero <= !(|Cb75);
		Cb76_pos <= Cb76;	   
		Cb76_neg <= Cb76 - 1;
		Cb76_msb <= Cb76[10];
		Cb76_et_zero <= !(|Cb76);
		Cb77_pos <= Cb77;	   
		Cb77_neg <= Cb77 - 1;
		Cb77_msb <= Cb77[10];
		Cb77_et_zero <= !(|Cb77);
		Cb78_pos <= Cb78;	   
		Cb78_neg <= Cb78 - 1;
		Cb78_msb <= Cb78[10];
		Cb78_et_zero <= !(|Cb78);
		Cb81_pos <= Cb81;	   
		Cb81_neg <= Cb81 - 1;
		Cb81_msb <= Cb81[10];
		Cb81_et_zero <= !(|Cb81);
		Cb82_pos <= Cb82;	   
		Cb82_neg <= Cb82 - 1;
		Cb82_msb <= Cb82[10];
		Cb82_et_zero <= !(|Cb82);
		Cb83_pos <= Cb83;	   
		Cb83_neg <= Cb83 - 1;
		Cb83_msb <= Cb83[10];
		Cb83_et_zero <= !(|Cb83);
		Cb84_pos <= Cb84;	   
		Cb84_neg <= Cb84 - 1;
		Cb84_msb <= Cb84[10];
		Cb84_et_zero <= !(|Cb84);
		Cb85_pos <= Cb85;	   
		Cb85_neg <= Cb85 - 1;
		Cb85_msb <= Cb85[10];
		Cb85_et_zero <= !(|Cb85);
		Cb86_pos <= Cb86;	   
		Cb86_neg <= Cb86 - 1;
		Cb86_msb <= Cb86[10];
		Cb86_et_zero <= !(|Cb86);
		Cb87_pos <= Cb87;	   
		Cb87_neg <= Cb87 - 1;
		Cb87_msb <= Cb87[10];
		Cb87_et_zero <= !(|Cb87);
		Cb88_pos <= Cb88;	   
		Cb88_neg <= Cb88 - 1;
		Cb88_msb <= Cb88[10];
		Cb88_et_zero <= !(|Cb88);
		end
	else if (enable_module) begin 
		Cb12_pos <= Cb21_pos;	   
		Cb12_neg <= Cb21_neg;
		Cb12_msb <= Cb21_msb;
		Cb12_et_zero <= Cb21_et_zero;
		Cb21_pos <= Cb31_pos;	   
		Cb21_neg <= Cb31_neg;
		Cb21_msb <= Cb31_msb;
		Cb21_et_zero <= Cb31_et_zero;
		Cb31_pos <= Cb22_pos;	   
		Cb31_neg <= Cb22_neg;
		Cb31_msb <= Cb22_msb;
		Cb31_et_zero <= Cb22_et_zero;
		Cb22_pos <= Cb13_pos;	   
		Cb22_neg <= Cb13_neg;
		Cb22_msb <= Cb13_msb;
		Cb22_et_zero <= Cb13_et_zero;
		Cb13_pos <= Cb14_pos;	   
		Cb13_neg <= Cb14_neg;
		Cb13_msb <= Cb14_msb;
		Cb13_et_zero <= Cb14_et_zero;
		Cb14_pos <= Cb23_pos;	   
		Cb14_neg <= Cb23_neg;
		Cb14_msb <= Cb23_msb;
		Cb14_et_zero <= Cb23_et_zero;
		Cb23_pos <= Cb32_pos;	   
		Cb23_neg <= Cb32_neg;
		Cb23_msb <= Cb32_msb;
		Cb23_et_zero <= Cb32_et_zero;
		Cb32_pos <= Cb41_pos;	   
		Cb32_neg <= Cb41_neg;
		Cb32_msb <= Cb41_msb;
		Cb32_et_zero <= Cb41_et_zero;
		Cb41_pos <= Cb51_pos;	   
		Cb41_neg <= Cb51_neg;
		Cb41_msb <= Cb51_msb;
		Cb41_et_zero <= Cb51_et_zero;
		Cb51_pos <= Cb42_pos;	   
		Cb51_neg <= Cb42_neg;
		Cb51_msb <= Cb42_msb;
		Cb51_et_zero <= Cb42_et_zero;
		Cb42_pos <= Cb33_pos;	   
		Cb42_neg <= Cb33_neg;
		Cb42_msb <= Cb33_msb;
		Cb42_et_zero <= Cb33_et_zero;
		Cb33_pos <= Cb24_pos;	   
		Cb33_neg <= Cb24_neg;
		Cb33_msb <= Cb24_msb;
		Cb33_et_zero <= Cb24_et_zero;
		Cb24_pos <= Cb15_pos;	   
		Cb24_neg <= Cb15_neg;
		Cb24_msb <= Cb15_msb;
		Cb24_et_zero <= Cb15_et_zero;
		Cb15_pos <= Cb16_pos;	   
		Cb15_neg <= Cb16_neg;
		Cb15_msb <= Cb16_msb;
		Cb15_et_zero <= Cb16_et_zero;
		Cb16_pos <= Cb25_pos;	   
		Cb16_neg <= Cb25_neg;
		Cb16_msb <= Cb25_msb;
		Cb16_et_zero <= Cb25_et_zero;
		Cb25_pos <= Cb34_pos;	   
		Cb25_neg <= Cb34_neg;
		Cb25_msb <= Cb34_msb;
		Cb25_et_zero <= Cb34_et_zero;
		Cb34_pos <= Cb43_pos;	   
		Cb34_neg <= Cb43_neg;
		Cb34_msb <= Cb43_msb;
		Cb34_et_zero <= Cb43_et_zero;
		Cb43_pos <= Cb52_pos;	   
		Cb43_neg <= Cb52_neg;
		Cb43_msb <= Cb52_msb;
		Cb43_et_zero <= Cb52_et_zero;
		Cb52_pos <= Cb61_pos;	   
		Cb52_neg <= Cb61_neg;
		Cb52_msb <= Cb61_msb;
		Cb52_et_zero <= Cb61_et_zero;
		Cb61_pos <= Cb71_pos;	   
		Cb61_neg <= Cb71_neg;
		Cb61_msb <= Cb71_msb;
		Cb61_et_zero <= Cb71_et_zero;
		Cb71_pos <= Cb62_pos;	   
		Cb71_neg <= Cb62_neg;
		Cb71_msb <= Cb62_msb;
		Cb71_et_zero <= Cb62_et_zero;
		Cb62_pos <= Cb53_pos;	   
		Cb62_neg <= Cb53_neg;
		Cb62_msb <= Cb53_msb;
		Cb62_et_zero <= Cb53_et_zero;
		Cb53_pos <= Cb44_pos;	   
		Cb53_neg <= Cb44_neg;
		Cb53_msb <= Cb44_msb;
		Cb53_et_zero <= Cb44_et_zero;
		Cb44_pos <= Cb35_pos;	   
		Cb44_neg <= Cb35_neg;
		Cb44_msb <= Cb35_msb;
		Cb44_et_zero <= Cb35_et_zero;
		Cb35_pos <= Cb26_pos;	   
		Cb35_neg <= Cb26_neg;
		Cb35_msb <= Cb26_msb;
		Cb35_et_zero <= Cb26_et_zero;
		Cb26_pos <= Cb17_pos;	   
		Cb26_neg <= Cb17_neg;
		Cb26_msb <= Cb17_msb;
		Cb26_et_zero <= Cb17_et_zero;
		Cb17_pos <= Cb18_pos;	   
		Cb17_neg <= Cb18_neg;
		Cb17_msb <= Cb18_msb;
		Cb17_et_zero <= Cb18_et_zero;
		Cb18_pos <= Cb27_pos;	   
		Cb18_neg <= Cb27_neg;
		Cb18_msb <= Cb27_msb;
		Cb18_et_zero <= Cb27_et_zero;
		Cb27_pos <= Cb36_pos;	   
		Cb27_neg <= Cb36_neg;
		Cb27_msb <= Cb36_msb;
		Cb27_et_zero <= Cb36_et_zero;
		Cb36_pos <= Cb45_pos;	   
		Cb36_neg <= Cb45_neg;
		Cb36_msb <= Cb45_msb;
		Cb36_et_zero <= Cb45_et_zero;
		Cb45_pos <= Cb54_pos;	   
		Cb45_neg <= Cb54_neg;
		Cb45_msb <= Cb54_msb;
		Cb45_et_zero <= Cb54_et_zero;
		Cb54_pos <= Cb63_pos;	   
		Cb54_neg <= Cb63_neg;
		Cb54_msb <= Cb63_msb;
		Cb54_et_zero <= Cb63_et_zero;
		Cb63_pos <= Cb72_pos;	   
		Cb63_neg <= Cb72_neg;
		Cb63_msb <= Cb72_msb;
		Cb63_et_zero <= Cb72_et_zero;
		Cb72_pos <= Cb81_pos;	   
		Cb72_neg <= Cb81_neg;
		Cb72_msb <= Cb81_msb;
		Cb72_et_zero <= Cb81_et_zero;
		Cb81_pos <= Cb82_pos;	   
		Cb81_neg <= Cb82_neg;
		Cb81_msb <= Cb82_msb;
		Cb81_et_zero <= Cb82_et_zero;
		Cb82_pos <= Cb73_pos;	   
		Cb82_neg <= Cb73_neg;
		Cb82_msb <= Cb73_msb;
		Cb82_et_zero <= Cb73_et_zero;
		Cb73_pos <= Cb64_pos;	   
		Cb73_neg <= Cb64_neg;
		Cb73_msb <= Cb64_msb;
		Cb73_et_zero <= Cb64_et_zero;
		Cb64_pos <= Cb55_pos;	   
		Cb64_neg <= Cb55_neg;
		Cb64_msb <= Cb55_msb;
		Cb64_et_zero <= Cb55_et_zero;
		Cb55_pos <= Cb46_pos;	   
		Cb55_neg <= Cb46_neg;
		Cb55_msb <= Cb46_msb;
		Cb55_et_zero <= Cb46_et_zero;
		Cb46_pos <= Cb37_pos;	   
		Cb46_neg <= Cb37_neg;
		Cb46_msb <= Cb37_msb;
		Cb46_et_zero <= Cb37_et_zero;
		Cb37_pos <= Cb28_pos;	   
		Cb37_neg <= Cb28_neg;
		Cb37_msb <= Cb28_msb;
		Cb37_et_zero <= Cb28_et_zero;
		Cb28_pos <= Cb38_pos;	   
		Cb28_neg <= Cb38_neg;
		Cb28_msb <= Cb38_msb;
		Cb28_et_zero <= Cb38_et_zero;
		Cb38_pos <= Cb47_pos;	   
		Cb38_neg <= Cb47_neg;
		Cb38_msb <= Cb47_msb;
		Cb38_et_zero <= Cb47_et_zero;
		Cb47_pos <= Cb56_pos;	   
		Cb47_neg <= Cb56_neg;
		Cb47_msb <= Cb56_msb;
		Cb47_et_zero <= Cb56_et_zero;
		Cb56_pos <= Cb65_pos;	   
		Cb56_neg <= Cb65_neg;
		Cb56_msb <= Cb65_msb;
		Cb56_et_zero <= Cb65_et_zero;
		Cb65_pos <= Cb74_pos;	   
		Cb65_neg <= Cb74_neg;
		Cb65_msb <= Cb74_msb;
		Cb65_et_zero <= Cb74_et_zero;
		Cb74_pos <= Cb83_pos;	   
		Cb74_neg <= Cb83_neg;
		Cb74_msb <= Cb83_msb;
		Cb74_et_zero <= Cb83_et_zero;
		Cb83_pos <= Cb84_pos;	   
		Cb83_neg <= Cb84_neg;
		Cb83_msb <= Cb84_msb;
		Cb83_et_zero <= Cb84_et_zero;
		Cb84_pos <= Cb75_pos;	   
		Cb84_neg <= Cb75_neg;
		Cb84_msb <= Cb75_msb;
		Cb84_et_zero <= Cb75_et_zero;
		Cb75_pos <= Cb66_pos;	   
		Cb75_neg <= Cb66_neg;
		Cb75_msb <= Cb66_msb;
		Cb75_et_zero <= Cb66_et_zero;
		Cb66_pos <= Cb57_pos;	   
		Cb66_neg <= Cb57_neg;
		Cb66_msb <= Cb57_msb;
		Cb66_et_zero <= Cb57_et_zero;
		Cb57_pos <= Cb48_pos;	   
		Cb57_neg <= Cb48_neg;
		Cb57_msb <= Cb48_msb;
		Cb57_et_zero <= Cb48_et_zero;
		Cb48_pos <= Cb58_pos;	   
		Cb48_neg <= Cb58_neg;
		Cb48_msb <= Cb58_msb;
		Cb48_et_zero <= Cb58_et_zero;
		Cb58_pos <= Cb67_pos;	   
		Cb58_neg <= Cb67_neg;
		Cb58_msb <= Cb67_msb;
		Cb58_et_zero <= Cb67_et_zero;
		Cb67_pos <= Cb76_pos;	   
		Cb67_neg <= Cb76_neg;
		Cb67_msb <= Cb76_msb;
		Cb67_et_zero <= Cb76_et_zero;
		Cb76_pos <= Cb85_pos;	   
		Cb76_neg <= Cb85_neg;
		Cb76_msb <= Cb85_msb;
		Cb76_et_zero <= Cb85_et_zero;
		Cb85_pos <= Cb86_pos;	   
		Cb85_neg <= Cb86_neg;
		Cb85_msb <= Cb86_msb;
		Cb85_et_zero <= Cb86_et_zero;
		Cb86_pos <= Cb77_pos;	   
		Cb86_neg <= Cb77_neg;
		Cb86_msb <= Cb77_msb;
		Cb86_et_zero <= Cb77_et_zero;
		Cb77_pos <= Cb68_pos;	   
		Cb77_neg <= Cb68_neg;
		Cb77_msb <= Cb68_msb;
		Cb77_et_zero <= Cb68_et_zero;
		Cb68_pos <= Cb78_pos;	   
		Cb68_neg <= Cb78_neg;
		Cb68_msb <= Cb78_msb;
		Cb68_et_zero <= Cb78_et_zero;
		Cb78_pos <= Cb87_pos;	   
		Cb78_neg <= Cb87_neg;
		Cb78_msb <= Cb87_msb;
		Cb78_et_zero <= Cb87_et_zero;
		Cb87_pos <= Cb88_pos;	   
		Cb87_neg <= Cb88_neg;
		Cb87_msb <= Cb88_msb;
		Cb87_et_zero <= Cb88_et_zero;
		Cb88_pos <= 0;	   
		Cb88_neg <= 0;
		Cb88_msb <= 0;
		Cb88_et_zero <= 1;
		end
end	 

always @(posedge clk)
begin
	if (rst) begin 
		Cb11_diff <= 0; Cb11_1 <= 0; 
		end
	else if (enable) begin // Need to sign extend Cb11 to 12 bits
		Cb11_diff <= {Cb11[10], Cb11} - Cb11_previous;
		Cb11_1 <= Cb11[10] ? { 1'b1, Cb11 } : { 1'b0, Cb11 };
		end
end	 

always @(posedge clk)
begin
	if (rst) 
		Cb11_bits_pos <= 0;
	else if (Cb11_1_pos[10] == 1) 
		Cb11_bits_pos <= 11;	
	else if (Cb11_1_pos[9] == 1) 
		Cb11_bits_pos <= 10;
	else if (Cb11_1_pos[8] == 1) 
		Cb11_bits_pos <= 9;
	else if (Cb11_1_pos[7] == 1) 
		Cb11_bits_pos <= 8;
	else if (Cb11_1_pos[6] == 1) 
		Cb11_bits_pos <= 7;
	else if (Cb11_1_pos[5] == 1) 
		Cb11_bits_pos <= 6;
	else if (Cb11_1_pos[4] == 1) 
		Cb11_bits_pos <= 5;
	else if (Cb11_1_pos[3] == 1) 
		Cb11_bits_pos <= 4;
	else if (Cb11_1_pos[2] == 1) 
		Cb11_bits_pos <= 3;
	else if (Cb11_1_pos[1] == 1) 
		Cb11_bits_pos <= 2;
	else if (Cb11_1_pos[0] == 1) 
		Cb11_bits_pos <= 1;
	else 
	 	Cb11_bits_pos <= 0;
end

always @(posedge clk)
begin
	if (rst) 
		Cb11_bits_neg <= 0;
	else if (Cb11_1_neg[10] == 0) 
		Cb11_bits_neg <= 11;	
	else if (Cb11_1_neg[9] == 0) 
		Cb11_bits_neg <= 10;  
	else if (Cb11_1_neg[8] == 0) 
		Cb11_bits_neg <= 9;   
	else if (Cb11_1_neg[7] == 0) 
		Cb11_bits_neg <= 8;   
	else if (Cb11_1_neg[6] == 0) 
		Cb11_bits_neg <= 7;   
	else if (Cb11_1_neg[5] == 0) 
		Cb11_bits_neg <= 6;   
	else if (Cb11_1_neg[4] == 0) 
		Cb11_bits_neg <= 5;   
	else if (Cb11_1_neg[3] == 0) 
		Cb11_bits_neg <= 4;   
	else if (Cb11_1_neg[2] == 0) 
		Cb11_bits_neg <= 3;   
	else if (Cb11_1_neg[1] == 0) 
		Cb11_bits_neg <= 2;   
	else if (Cb11_1_neg[0] == 0) 
		Cb11_bits_neg <= 1;
	else 
	 	Cb11_bits_neg <= 0;
end


always @(posedge clk)
begin
	if (rst) 
		Cb12_bits_pos <= 0;
	else if (Cb12_pos[9] == 1) 
		Cb12_bits_pos <= 10;
	else if (Cb12_pos[8] == 1) 
		Cb12_bits_pos <= 9;
	else if (Cb12_pos[7] == 1) 
		Cb12_bits_pos <= 8;
	else if (Cb12_pos[6] == 1) 
		Cb12_bits_pos <= 7;
	else if (Cb12_pos[5] == 1) 
		Cb12_bits_pos <= 6;
	else if (Cb12_pos[4] == 1) 
		Cb12_bits_pos <= 5;
	else if (Cb12_pos[3] == 1) 
		Cb12_bits_pos <= 4;
	else if (Cb12_pos[2] == 1) 
		Cb12_bits_pos <= 3;
	else if (Cb12_pos[1] == 1) 
		Cb12_bits_pos <= 2;
	else if (Cb12_pos[0] == 1) 
		Cb12_bits_pos <= 1;
	else 
	 	Cb12_bits_pos <= 0;
end

always @(posedge clk)
begin
	if (rst) 
		Cb12_bits_neg <= 0;
	else if (Cb12_neg[9] == 0) 
		Cb12_bits_neg <= 10;  
	else if (Cb12_neg[8] == 0) 
		Cb12_bits_neg <= 9;   
	else if (Cb12_neg[7] == 0) 
		Cb12_bits_neg <= 8;   
	else if (Cb12_neg[6] == 0) 
		Cb12_bits_neg <= 7;   
	else if (Cb12_neg[5] == 0) 
		Cb12_bits_neg <= 6;   
	else if (Cb12_neg[4] == 0) 
		Cb12_bits_neg <= 5;   
	else if (Cb12_neg[3] == 0) 
		Cb12_bits_neg <= 4;   
	else if (Cb12_neg[2] == 0) 
		Cb12_bits_neg <= 3;   
	else if (Cb12_neg[1] == 0) 
		Cb12_bits_neg <= 2;   
	else if (Cb12_neg[0] == 0) 
		Cb12_bits_neg <= 1;
	else 
	 	Cb12_bits_neg <= 0;
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

/* These Cb DC and AC code lengths, run lengths, and bit codes
were created from the Huffman table entries in the JPEG file header.
For different Huffman tables for different images, these values
below will need to be changed.  I created a matlab file to automatically
create these entries from the already encoded JPEG image. This matlab program
won't be any help if you're starting from scratch with a .tif or other
raw image file format.  The values below come from a Huffman table, they
do not actually create the Huffman table based on the probabilities of
each code created from the image data.  Cbou will need another program to
create the optimal Huffman table, or you can go with a generic Huffman table,
which will have slightly less than the best compression.*/

always @(posedge clk)
begin
Cb_DC_code_length[0] <= 2;
Cb_DC_code_length[1] <= 2;
Cb_DC_code_length[2] <= 2;
Cb_DC_code_length[3] <= 3;
Cb_DC_code_length[4] <= 4;
Cb_DC_code_length[5] <= 5;
Cb_DC_code_length[6] <= 6;
Cb_DC_code_length[7] <= 7;
Cb_DC_code_length[8] <= 8;
Cb_DC_code_length[9] <= 9;
Cb_DC_code_length[10] <= 10;
Cb_DC_code_length[11] <= 11;
Cb_DC[0] <= 11'b00000000000;
Cb_DC[1] <= 11'b01000000000;
Cb_DC[2] <= 11'b10000000000;
Cb_DC[3] <= 11'b11000000000;
Cb_DC[4] <= 11'b11100000000;
Cb_DC[5] <= 11'b11110000000;
Cb_DC[6] <= 11'b11111000000;
Cb_DC[7] <= 11'b11111100000;
Cb_DC[8] <= 11'b11111110000;
Cb_DC[9] <= 11'b11111111000;
Cb_DC[10] <= 11'b11111111100;
Cb_DC[11] <= 11'b11111111110;
Cb_AC_code_length[0] <= 2;
Cb_AC_code_length[1] <= 2;
Cb_AC_code_length[2] <= 3;
Cb_AC_code_length[3] <= 4;
Cb_AC_code_length[4] <= 4;
Cb_AC_code_length[5] <= 4;
Cb_AC_code_length[6] <= 5;
Cb_AC_code_length[7] <= 5;
Cb_AC_code_length[8] <= 5;
Cb_AC_code_length[9] <= 6;
Cb_AC_code_length[10] <= 6;
Cb_AC_code_length[11] <= 7;
Cb_AC_code_length[12] <= 7;
Cb_AC_code_length[13] <= 7;
Cb_AC_code_length[14] <= 7;
Cb_AC_code_length[15] <= 8;
Cb_AC_code_length[16] <= 8;
Cb_AC_code_length[17] <= 8;
Cb_AC_code_length[18] <= 9;
Cb_AC_code_length[19] <= 9;
Cb_AC_code_length[20] <= 9;
Cb_AC_code_length[21] <= 9;
Cb_AC_code_length[22] <= 9;
Cb_AC_code_length[23] <= 10;
Cb_AC_code_length[24] <= 10;
Cb_AC_code_length[25] <= 10;
Cb_AC_code_length[26] <= 10;
Cb_AC_code_length[27] <= 10;
Cb_AC_code_length[28] <= 11;
Cb_AC_code_length[29] <= 11;
Cb_AC_code_length[30] <= 11;
Cb_AC_code_length[31] <= 11;
Cb_AC_code_length[32] <= 12;
Cb_AC_code_length[33] <= 12;
Cb_AC_code_length[34] <= 12;
Cb_AC_code_length[35] <= 12;
Cb_AC_code_length[36] <= 15;
Cb_AC_code_length[37] <= 16;
Cb_AC_code_length[38] <= 16;
Cb_AC_code_length[39] <= 16;
Cb_AC_code_length[40] <= 16;
Cb_AC_code_length[41] <= 16;
Cb_AC_code_length[42] <= 16;
Cb_AC_code_length[43] <= 16;
Cb_AC_code_length[44] <= 16;
Cb_AC_code_length[45] <= 16;
Cb_AC_code_length[46] <= 16;
Cb_AC_code_length[47] <= 16;
Cb_AC_code_length[48] <= 16;
Cb_AC_code_length[49] <= 16;
Cb_AC_code_length[50] <= 16;
Cb_AC_code_length[51] <= 16;
Cb_AC_code_length[52] <= 16;
Cb_AC_code_length[53] <= 16;
Cb_AC_code_length[54] <= 16;
Cb_AC_code_length[55] <= 16;
Cb_AC_code_length[56] <= 16;
Cb_AC_code_length[57] <= 16;
Cb_AC_code_length[58] <= 16;
Cb_AC_code_length[59] <= 16;
Cb_AC_code_length[60] <= 16;
Cb_AC_code_length[61] <= 16;
Cb_AC_code_length[62] <= 16;
Cb_AC_code_length[63] <= 16;
Cb_AC_code_length[64] <= 16;
Cb_AC_code_length[65] <= 16;
Cb_AC_code_length[66] <= 16;
Cb_AC_code_length[67] <= 16;
Cb_AC_code_length[68] <= 16;
Cb_AC_code_length[69] <= 16;
Cb_AC_code_length[70] <= 16;
Cb_AC_code_length[71] <= 16;
Cb_AC_code_length[72] <= 16;
Cb_AC_code_length[73] <= 16;
Cb_AC_code_length[74] <= 16;
Cb_AC_code_length[75] <= 16;
Cb_AC_code_length[76] <= 16;
Cb_AC_code_length[77] <= 16;
Cb_AC_code_length[78] <= 16;
Cb_AC_code_length[79] <= 16;
Cb_AC_code_length[80] <= 16;
Cb_AC_code_length[81] <= 16;
Cb_AC_code_length[82] <= 16;
Cb_AC_code_length[83] <= 16;
Cb_AC_code_length[84] <= 16;
Cb_AC_code_length[85] <= 16;
Cb_AC_code_length[86] <= 16;
Cb_AC_code_length[87] <= 16;
Cb_AC_code_length[88] <= 16;
Cb_AC_code_length[89] <= 16;
Cb_AC_code_length[90] <= 16;
Cb_AC_code_length[91] <= 16;
Cb_AC_code_length[92] <= 16;
Cb_AC_code_length[93] <= 16;
Cb_AC_code_length[94] <= 16;
Cb_AC_code_length[95] <= 16;
Cb_AC_code_length[96] <= 16;
Cb_AC_code_length[97] <= 16;
Cb_AC_code_length[98] <= 16;
Cb_AC_code_length[99] <= 16;
Cb_AC_code_length[100] <= 16;
Cb_AC_code_length[101] <= 16;
Cb_AC_code_length[102] <= 16;
Cb_AC_code_length[103] <= 16;
Cb_AC_code_length[104] <= 16;
Cb_AC_code_length[105] <= 16;
Cb_AC_code_length[106] <= 16;
Cb_AC_code_length[107] <= 16;
Cb_AC_code_length[108] <= 16;
Cb_AC_code_length[109] <= 16;
Cb_AC_code_length[110] <= 16;
Cb_AC_code_length[111] <= 16;
Cb_AC_code_length[112] <= 16;
Cb_AC_code_length[113] <= 16;
Cb_AC_code_length[114] <= 16;
Cb_AC_code_length[115] <= 16;
Cb_AC_code_length[116] <= 16;
Cb_AC_code_length[117] <= 16;
Cb_AC_code_length[118] <= 16;
Cb_AC_code_length[119] <= 16;
Cb_AC_code_length[120] <= 16;
Cb_AC_code_length[121] <= 16;
Cb_AC_code_length[122] <= 16;
Cb_AC_code_length[123] <= 16;
Cb_AC_code_length[124] <= 16;
Cb_AC_code_length[125] <= 16;
Cb_AC_code_length[126] <= 16;
Cb_AC_code_length[127] <= 16;
Cb_AC_code_length[128] <= 16;
Cb_AC_code_length[129] <= 16;
Cb_AC_code_length[130] <= 16;
Cb_AC_code_length[131] <= 16;
Cb_AC_code_length[132] <= 16;
Cb_AC_code_length[133] <= 16;
Cb_AC_code_length[134] <= 16;
Cb_AC_code_length[135] <= 16;
Cb_AC_code_length[136] <= 16;
Cb_AC_code_length[137] <= 16;
Cb_AC_code_length[138] <= 16;
Cb_AC_code_length[139] <= 16;
Cb_AC_code_length[140] <= 16;
Cb_AC_code_length[141] <= 16;
Cb_AC_code_length[142] <= 16;
Cb_AC_code_length[143] <= 16;
Cb_AC_code_length[144] <= 16;
Cb_AC_code_length[145] <= 16;
Cb_AC_code_length[146] <= 16;
Cb_AC_code_length[147] <= 16;
Cb_AC_code_length[148] <= 16;
Cb_AC_code_length[149] <= 16;
Cb_AC_code_length[150] <= 16;
Cb_AC_code_length[151] <= 16;
Cb_AC_code_length[152] <= 16;
Cb_AC_code_length[153] <= 16;
Cb_AC_code_length[154] <= 16;
Cb_AC_code_length[155] <= 16;
Cb_AC_code_length[156] <= 16;
Cb_AC_code_length[157] <= 16;
Cb_AC_code_length[158] <= 16;
Cb_AC_code_length[159] <= 16;
Cb_AC_code_length[160] <= 16;
Cb_AC_code_length[161] <= 16;
Cb_AC[0] <= 16'b0000000000000000;
Cb_AC[1] <= 16'b0100000000000000;
Cb_AC[2] <= 16'b1000000000000000;
Cb_AC[3] <= 16'b1010000000000000;
Cb_AC[4] <= 16'b1011000000000000;
Cb_AC[5] <= 16'b1100000000000000;
Cb_AC[6] <= 16'b1101000000000000;
Cb_AC[7] <= 16'b1101100000000000;
Cb_AC[8] <= 16'b1110000000000000;
Cb_AC[9] <= 16'b1110100000000000;
Cb_AC[10] <= 16'b1110110000000000;
Cb_AC[11] <= 16'b1111000000000000;
Cb_AC[12] <= 16'b1111001000000000;
Cb_AC[13] <= 16'b1111010000000000;
Cb_AC[14] <= 16'b1111011000000000;
Cb_AC[15] <= 16'b1111100000000000;
Cb_AC[16] <= 16'b1111100100000000;
Cb_AC[17] <= 16'b1111101000000000;
Cb_AC[18] <= 16'b1111101100000000;
Cb_AC[19] <= 16'b1111101110000000;
Cb_AC[20] <= 16'b1111110000000000;
Cb_AC[21] <= 16'b1111110010000000;
Cb_AC[22] <= 16'b1111110100000000;
Cb_AC[23] <= 16'b1111110110000000;
Cb_AC[24] <= 16'b1111110111000000;
Cb_AC[25] <= 16'b1111111000000000;
Cb_AC[26] <= 16'b1111111001000000;
Cb_AC[27] <= 16'b1111111010000000;
Cb_AC[28] <= 16'b1111111011000000;
Cb_AC[29] <= 16'b1111111011100000;
Cb_AC[30] <= 16'b1111111100000000;
Cb_AC[31] <= 16'b1111111100100000;
Cb_AC[32] <= 16'b1111111101000000;
Cb_AC[33] <= 16'b1111111101010000;
Cb_AC[34] <= 16'b1111111101100000;
Cb_AC[35] <= 16'b1111111101110000;
Cb_AC[36] <= 16'b1111111110000000;
Cb_AC[37] <= 16'b1111111110000010;
Cb_AC[38] <= 16'b1111111110000011;
Cb_AC[39] <= 16'b1111111110000100;
Cb_AC[40] <= 16'b1111111110000101;
Cb_AC[41] <= 16'b1111111110000110;
Cb_AC[42] <= 16'b1111111110000111;
Cb_AC[43] <= 16'b1111111110001000;
Cb_AC[44] <= 16'b1111111110001001;
Cb_AC[45] <= 16'b1111111110001010;
Cb_AC[46] <= 16'b1111111110001011;
Cb_AC[47] <= 16'b1111111110001100;
Cb_AC[48] <= 16'b1111111110001101;
Cb_AC[49] <= 16'b1111111110001110;
Cb_AC[50] <= 16'b1111111110001111;
Cb_AC[51] <= 16'b1111111110010000;
Cb_AC[52] <= 16'b1111111110010001;
Cb_AC[53] <= 16'b1111111110010010;
Cb_AC[54] <= 16'b1111111110010011;
Cb_AC[55] <= 16'b1111111110010100;
Cb_AC[56] <= 16'b1111111110010101;
Cb_AC[57] <= 16'b1111111110010110;
Cb_AC[58] <= 16'b1111111110010111;
Cb_AC[59] <= 16'b1111111110011000;
Cb_AC[60] <= 16'b1111111110011001;
Cb_AC[61] <= 16'b1111111110011010;
Cb_AC[62] <= 16'b1111111110011011;
Cb_AC[63] <= 16'b1111111110011100;
Cb_AC[64] <= 16'b1111111110011101;
Cb_AC[65] <= 16'b1111111110011110;
Cb_AC[66] <= 16'b1111111110011111;
Cb_AC[67] <= 16'b1111111110100000;
Cb_AC[68] <= 16'b1111111110100001;
Cb_AC[69] <= 16'b1111111110100010;
Cb_AC[70] <= 16'b1111111110100011;
Cb_AC[71] <= 16'b1111111110100100;
Cb_AC[72] <= 16'b1111111110100101;
Cb_AC[73] <= 16'b1111111110100110;
Cb_AC[74] <= 16'b1111111110100111;
Cb_AC[75] <= 16'b1111111110101000;
Cb_AC[76] <= 16'b1111111110101001;
Cb_AC[77] <= 16'b1111111110101010;
Cb_AC[78] <= 16'b1111111110101011;
Cb_AC[79] <= 16'b1111111110101100;
Cb_AC[80] <= 16'b1111111110101101;
Cb_AC[81] <= 16'b1111111110101110;
Cb_AC[82] <= 16'b1111111110101111;
Cb_AC[83] <= 16'b1111111110110000;
Cb_AC[84] <= 16'b1111111110110001;
Cb_AC[85] <= 16'b1111111110110010;
Cb_AC[86] <= 16'b1111111110110011;
Cb_AC[87] <= 16'b1111111110110100;
Cb_AC[88] <= 16'b1111111110110101;
Cb_AC[89] <= 16'b1111111110110110;
Cb_AC[90] <= 16'b1111111110110111;
Cb_AC[91] <= 16'b1111111110111000;
Cb_AC[92] <= 16'b1111111110111001;
Cb_AC[93] <= 16'b1111111110111010;
Cb_AC[94] <= 16'b1111111110111011;
Cb_AC[95] <= 16'b1111111110111100;
Cb_AC[96] <= 16'b1111111110111101;
Cb_AC[97] <= 16'b1111111110111110;
Cb_AC[98] <= 16'b1111111110111111;
Cb_AC[99] <= 16'b1111111111000000;
Cb_AC[100] <= 16'b1111111111000001;
Cb_AC[101] <= 16'b1111111111000010;
Cb_AC[102] <= 16'b1111111111000011;
Cb_AC[103] <= 16'b1111111111000100;
Cb_AC[104] <= 16'b1111111111000101;
Cb_AC[105] <= 16'b1111111111000110;
Cb_AC[106] <= 16'b1111111111000111;
Cb_AC[107] <= 16'b1111111111001000;
Cb_AC[108] <= 16'b1111111111001001;
Cb_AC[109] <= 16'b1111111111001010;
Cb_AC[110] <= 16'b1111111111001011;
Cb_AC[111] <= 16'b1111111111001100;
Cb_AC[112] <= 16'b1111111111001101;
Cb_AC[113] <= 16'b1111111111001110;
Cb_AC[114] <= 16'b1111111111001111;
Cb_AC[115] <= 16'b1111111111010000;
Cb_AC[116] <= 16'b1111111111010001;
Cb_AC[117] <= 16'b1111111111010010;
Cb_AC[118] <= 16'b1111111111010011;
Cb_AC[119] <= 16'b1111111111010100;
Cb_AC[120] <= 16'b1111111111010101;
Cb_AC[121] <= 16'b1111111111010110;
Cb_AC[122] <= 16'b1111111111010111;
Cb_AC[123] <= 16'b1111111111011000;
Cb_AC[124] <= 16'b1111111111011001;
Cb_AC[125] <= 16'b1111111111011010;
Cb_AC[126] <= 16'b1111111111011011;
Cb_AC[127] <= 16'b1111111111011100;
Cb_AC[128] <= 16'b1111111111011101;
Cb_AC[129] <= 16'b1111111111011110;
Cb_AC[130] <= 16'b1111111111011111;
Cb_AC[131] <= 16'b1111111111100000;
Cb_AC[132] <= 16'b1111111111100001;
Cb_AC[133] <= 16'b1111111111100010;
Cb_AC[134] <= 16'b1111111111100011;
Cb_AC[135] <= 16'b1111111111100100;
Cb_AC[136] <= 16'b1111111111100101;
Cb_AC[137] <= 16'b1111111111100110;
Cb_AC[138] <= 16'b1111111111100111;
Cb_AC[139] <= 16'b1111111111101000;
Cb_AC[140] <= 16'b1111111111101001;
Cb_AC[141] <= 16'b1111111111101010;
Cb_AC[142] <= 16'b1111111111101011;
Cb_AC[143] <= 16'b1111111111101100;
Cb_AC[144] <= 16'b1111111111101101;
Cb_AC[145] <= 16'b1111111111101110;
Cb_AC[146] <= 16'b1111111111101111;
Cb_AC[147] <= 16'b1111111111110000;
Cb_AC[148] <= 16'b1111111111110001;
Cb_AC[149] <= 16'b1111111111110010;
Cb_AC[150] <= 16'b1111111111110011;
Cb_AC[151] <= 16'b1111111111110100;
Cb_AC[152] <= 16'b1111111111110101;
Cb_AC[153] <= 16'b1111111111110110;
Cb_AC[154] <= 16'b1111111111110111;
Cb_AC[155] <= 16'b1111111111111000;
Cb_AC[156] <= 16'b1111111111111001;
Cb_AC[157] <= 16'b1111111111111010;
Cb_AC[158] <= 16'b1111111111111011;
Cb_AC[159] <= 16'b1111111111111100;
Cb_AC[160] <= 16'b1111111111111101;
Cb_AC[161] <= 16'b1111111111111110;
Cb_AC_run_code[1] <= 0;
Cb_AC_run_code[2] <= 1;
Cb_AC_run_code[3] <= 2;
Cb_AC_run_code[0] <= 3;
Cb_AC_run_code[4] <= 4;
Cb_AC_run_code[17] <= 5;
Cb_AC_run_code[5] <= 6;
Cb_AC_run_code[18] <= 7;
Cb_AC_run_code[33] <= 8;
Cb_AC_run_code[49] <= 9;
Cb_AC_run_code[65] <= 10;
Cb_AC_run_code[6] <= 11;
Cb_AC_run_code[19] <= 12;
Cb_AC_run_code[81] <= 13;
Cb_AC_run_code[97] <= 14;
Cb_AC_run_code[7] <= 15;
Cb_AC_run_code[34] <= 16;
Cb_AC_run_code[113] <= 17;
Cb_AC_run_code[20] <= 18;
Cb_AC_run_code[50] <= 19;
Cb_AC_run_code[129] <= 20;
Cb_AC_run_code[145] <= 21;
Cb_AC_run_code[161] <= 22;
Cb_AC_run_code[8] <= 23;
Cb_AC_run_code[35] <= 24;
Cb_AC_run_code[66] <= 25;
Cb_AC_run_code[177] <= 26;
Cb_AC_run_code[193] <= 27;
Cb_AC_run_code[21] <= 28;
Cb_AC_run_code[82] <= 29;
Cb_AC_run_code[209] <= 30;
Cb_AC_run_code[240] <= 31;
Cb_AC_run_code[36] <= 32;
Cb_AC_run_code[51] <= 33;
Cb_AC_run_code[98] <= 34;
Cb_AC_run_code[114] <= 35;
Cb_AC_run_code[130] <= 36;
Cb_AC_run_code[9] <= 37;
Cb_AC_run_code[10] <= 38;
Cb_AC_run_code[22] <= 39;
Cb_AC_run_code[23] <= 40;
Cb_AC_run_code[24] <= 41;
Cb_AC_run_code[25] <= 42;
Cb_AC_run_code[26] <= 43;
Cb_AC_run_code[37] <= 44;
Cb_AC_run_code[38] <= 45;
Cb_AC_run_code[39] <= 46;
Cb_AC_run_code[40] <= 47;
Cb_AC_run_code[41] <= 48;
Cb_AC_run_code[42] <= 49;
Cb_AC_run_code[52] <= 50;
Cb_AC_run_code[53] <= 51;
Cb_AC_run_code[54] <= 52;
Cb_AC_run_code[55] <= 53;
Cb_AC_run_code[56] <= 54;
Cb_AC_run_code[57] <= 55;
Cb_AC_run_code[58] <= 56;
Cb_AC_run_code[67] <= 57;
Cb_AC_run_code[68] <= 58;
Cb_AC_run_code[69] <= 59;
Cb_AC_run_code[70] <= 60;
Cb_AC_run_code[71] <= 61;
Cb_AC_run_code[72] <= 62;
Cb_AC_run_code[73] <= 63;
Cb_AC_run_code[74] <= 64;
Cb_AC_run_code[83] <= 65;
Cb_AC_run_code[84] <= 66;
Cb_AC_run_code[85] <= 67;
Cb_AC_run_code[86] <= 68;
Cb_AC_run_code[87] <= 69;
Cb_AC_run_code[88] <= 70;
Cb_AC_run_code[89] <= 71;
Cb_AC_run_code[90] <= 72;
Cb_AC_run_code[99] <= 73;
Cb_AC_run_code[100] <= 74;
Cb_AC_run_code[101] <= 75;
Cb_AC_run_code[102] <= 76;
Cb_AC_run_code[103] <= 77;
Cb_AC_run_code[104] <= 78;
Cb_AC_run_code[105] <= 79;
Cb_AC_run_code[106] <= 80;
Cb_AC_run_code[115] <= 81;
Cb_AC_run_code[116] <= 82;
Cb_AC_run_code[117] <= 83;
Cb_AC_run_code[118] <= 84;
Cb_AC_run_code[119] <= 85;
Cb_AC_run_code[120] <= 86;
Cb_AC_run_code[121] <= 87;
Cb_AC_run_code[122] <= 88;
Cb_AC_run_code[131] <= 89;
Cb_AC_run_code[132] <= 90;
Cb_AC_run_code[133] <= 91;
Cb_AC_run_code[134] <= 92;
Cb_AC_run_code[135] <= 93;
Cb_AC_run_code[136] <= 94;
Cb_AC_run_code[137] <= 95;
Cb_AC_run_code[138] <= 96;
Cb_AC_run_code[146] <= 97;
Cb_AC_run_code[147] <= 98;
Cb_AC_run_code[148] <= 99;
Cb_AC_run_code[149] <= 100;
Cb_AC_run_code[150] <= 101;
Cb_AC_run_code[151] <= 102;
Cb_AC_run_code[152] <= 103;
Cb_AC_run_code[153] <= 104;
Cb_AC_run_code[154] <= 105;
Cb_AC_run_code[162] <= 106;
Cb_AC_run_code[163] <= 107;
Cb_AC_run_code[164] <= 108;
Cb_AC_run_code[165] <= 109;
Cb_AC_run_code[166] <= 110;
Cb_AC_run_code[167] <= 111;
Cb_AC_run_code[168] <= 112;
Cb_AC_run_code[169] <= 113;
Cb_AC_run_code[170] <= 114;
Cb_AC_run_code[178] <= 115;
Cb_AC_run_code[179] <= 116;
Cb_AC_run_code[180] <= 117;
Cb_AC_run_code[181] <= 118;
Cb_AC_run_code[182] <= 119;
Cb_AC_run_code[183] <= 120;
Cb_AC_run_code[184] <= 121;
Cb_AC_run_code[185] <= 122;
Cb_AC_run_code[186] <= 123;
Cb_AC_run_code[194] <= 124;
Cb_AC_run_code[195] <= 125;
Cb_AC_run_code[196] <= 126;
Cb_AC_run_code[197] <= 127;
Cb_AC_run_code[198] <= 128;
Cb_AC_run_code[199] <= 129;
Cb_AC_run_code[200] <= 130;
Cb_AC_run_code[201] <= 131;
Cb_AC_run_code[202] <= 132;
Cb_AC_run_code[210] <= 133;
Cb_AC_run_code[211] <= 134;
Cb_AC_run_code[212] <= 135;
Cb_AC_run_code[213] <= 136;
Cb_AC_run_code[214] <= 137;
Cb_AC_run_code[215] <= 138;
Cb_AC_run_code[216] <= 139;
Cb_AC_run_code[217] <= 140;
Cb_AC_run_code[218] <= 141;
Cb_AC_run_code[225] <= 142;
Cb_AC_run_code[226] <= 143;
Cb_AC_run_code[227] <= 144;
Cb_AC_run_code[228] <= 145;
Cb_AC_run_code[229] <= 146;
Cb_AC_run_code[230] <= 147;
Cb_AC_run_code[231] <= 148;
Cb_AC_run_code[232] <= 149;
Cb_AC_run_code[233] <= 150;
Cb_AC_run_code[234] <= 151;
Cb_AC_run_code[241] <= 152;
Cb_AC_run_code[242] <= 153;
Cb_AC_run_code[243] <= 154;
Cb_AC_run_code[244] <= 155;
Cb_AC_run_code[245] <= 156;
Cb_AC_run_code[246] <= 157;
Cb_AC_run_code[247] <= 158;
Cb_AC_run_code[248] <= 159;
Cb_AC_run_code[249] <= 160;
Cb_AC_run_code[250] <= 161;
	Cb_AC_run_code[16] <= 0;
	Cb_AC_run_code[32] <= 0;
	Cb_AC_run_code[48] <= 0;
	Cb_AC_run_code[64] <= 0;
	Cb_AC_run_code[80] <= 0;
	Cb_AC_run_code[96] <= 0;
	Cb_AC_run_code[112] <= 0;
	Cb_AC_run_code[128] <= 0;
	Cb_AC_run_code[144] <= 0;
	Cb_AC_run_code[160] <= 0;
	Cb_AC_run_code[176] <= 0;
	Cb_AC_run_code[192] <= 0;
	Cb_AC_run_code[208] <= 0;
	Cb_AC_run_code[224] <= 0;
	
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