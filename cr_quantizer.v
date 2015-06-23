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

/* This module comes after the dct module.  The 64 matrix entries calculated after
performing the 2D DCT are inputs to this quantization module.  This module quantizes
the entire 8x8 block of Cr values.  The outputs from this module
are the quantized Cr values for one 8x8 block. */

`timescale 1ns / 100ps

module cr_quantizer(clk, rst, enable,
Z11, Z12, Z13, Z14, Z15, Z16, Z17, Z18, Z21, Z22, Z23, Z24, Z25, Z26, Z27, Z28,
Z31, Z32, Z33, Z34, Z35, Z36, Z37, Z38, Z41, Z42, Z43, Z44, Z45, Z46, Z47, Z48,
Z51, Z52, Z53, Z54, Z55, Z56, Z57, Z58, Z61, Z62, Z63, Z64, Z65, Z66, Z67, Z68,
Z71, Z72, Z73, Z74, Z75, Z76, Z77, Z78, Z81, Z82, Z83, Z84, Z85, Z86, Z87, Z88,
Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18, Q21, Q22, Q23, Q24, Q25, Q26, Q27, Q28,
Q31, Q32, Q33, Q34, Q35, Q36, Q37, Q38, Q41, Q42, Q43, Q44, Q45, Q46, Q47, Q48,
Q51, Q52, Q53, Q54, Q55, Q56, Q57, Q58, Q61, Q62, Q63, Q64, Q65, Q66, Q67, Q68,
Q71, Q72, Q73, Q74, Q75, Q76, Q77, Q78, Q81, Q82, Q83, Q84, Q85, Q86, Q87, Q88,
out_enable);
input		clk;
input		rst;
input		enable;
input  [10:0]  Z11, Z12, Z13, Z14, Z15, Z16, Z17, Z18, Z21, Z22, Z23, Z24;
input  [10:0]  Z25, Z26, Z27, Z28, Z31, Z32, Z33, Z34, Z35, Z36, Z37, Z38;
input  [10:0]  Z41, Z42, Z43, Z44, Z45, Z46, Z47, Z48, Z51, Z52, Z53, Z54;
input  [10:0]  Z55, Z56, Z57, Z58, Z61, Z62, Z63, Z64, Z65, Z66, Z67, Z68;
input  [10:0]  Z71, Z72, Z73, Z74, Z75, Z76, Z77, Z78, Z81, Z82, Z83, Z84;
input  [10:0]  Z85, Z86, Z87, Z88;
output  [10:0]  Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18, Q21, Q22, Q23, Q24;
output  [10:0]  Q25, Q26, Q27, Q28, Q31, Q32, Q33, Q34, Q35, Q36, Q37, Q38;
output  [10:0]  Q41, Q42, Q43, Q44, Q45, Q46, Q47, Q48, Q51, Q52, Q53, Q54;
output  [10:0]  Q55, Q56, Q57, Q58, Q61, Q62, Q63, Q64, Q65, Q66, Q67, Q68;
output  [10:0]  Q71, Q72, Q73, Q74, Q75, Q76, Q77, Q78, Q81, Q82, Q83, Q84;
output  [10:0]  Q85, Q86, Q87, Q88;
output		out_enable;

/* Below are the quantization values, these can be changed for different 
quantization levels */

parameter Q1_1	= 1;
parameter Q1_2	= 1;
parameter Q1_3	= 1;
parameter Q1_4	= 1;
parameter Q1_5	= 1;
parameter Q1_6	= 1;
parameter Q1_7	= 1;
parameter Q1_8	= 1;
parameter Q2_1	= 1;
parameter Q2_2	= 1;
parameter Q2_3	= 1;
parameter Q2_4	= 1;
parameter Q2_5	= 1;
parameter Q2_6	= 1;
parameter Q2_7	= 1;
parameter Q2_8	= 1;
parameter Q3_1	= 1;
parameter Q3_2	= 1;
parameter Q3_3	= 1;
parameter Q3_4	= 1;
parameter Q3_5	= 1;
parameter Q3_6	= 1;
parameter Q3_7	= 1;
parameter Q3_8	= 1;
parameter Q4_1	= 1;
parameter Q4_2	= 1;
parameter Q4_3	= 1;
parameter Q4_4	= 1;
parameter Q4_5	= 1;
parameter Q4_6	= 1;
parameter Q4_7	= 1;
parameter Q4_8	= 1;
parameter Q5_1	= 1;
parameter Q5_2	= 1;
parameter Q5_3	= 1;
parameter Q5_4	= 1;
parameter Q5_5	= 1;
parameter Q5_6	= 1;
parameter Q5_7	= 1;
parameter Q5_8	= 1;
parameter Q6_1	= 1;
parameter Q6_2	= 1;
parameter Q6_3	= 1;
parameter Q6_4	= 1;
parameter Q6_5	= 1;
parameter Q6_6	= 1;
parameter Q6_7	= 1;
parameter Q6_8	= 1;
parameter Q7_1	= 1;
parameter Q7_2	= 1;
parameter Q7_3	= 1;
parameter Q7_4	= 1;
parameter Q7_5	= 1;
parameter Q7_6	= 1;
parameter Q7_7	= 1;
parameter Q7_8	= 1;
parameter Q8_1	= 1;
parameter Q8_2	= 1;
parameter Q8_3	= 1;
parameter Q8_4	= 1;
parameter Q8_5	= 1;
parameter Q8_6	= 1;
parameter Q8_7	= 1;
parameter Q8_8	= 1;
// End of Quantization Values

/* The following parameters hold the values of 4096 divided by the corresponding 
individual quantization values.  These values are needed to get around
actually dividing the Y, Cb, and Cr values by the quantization values.
Instead, you can multiply by the values below, and then divide by 4096
to get the same result.  And 4096 = 2^12, so instead of dividing, you can
just shift the bottom 12 bits out.  This is a lossy process, as 4096/Q divided
by 4096 doesn't always equal the same value as if you were just dividing by Q.  But
the quantization process is also lossy, so the additional loss of precision is
negligible.  To decrease the loss, you could use a larger number than 4096 to 
get around the actual use of division.  Like take 8192/Q and then divide by 8192.*/

parameter QQ1_1	= 4096/Q1_1;
parameter QQ1_2	= 4096/Q1_2;
parameter QQ1_3	= 4096/Q1_3;
parameter QQ1_4	= 4096/Q1_4;
parameter QQ1_5	= 4096/Q1_5;
parameter QQ1_6	= 4096/Q1_6;
parameter QQ1_7	= 4096/Q1_7;
parameter QQ1_8	= 4096/Q1_8;
parameter QQ2_1	= 4096/Q2_1;
parameter QQ2_2	= 4096/Q2_2;
parameter QQ2_3	= 4096/Q2_3;
parameter QQ2_4	= 4096/Q2_4;
parameter QQ2_5	= 4096/Q2_5;
parameter QQ2_6	= 4096/Q2_6;
parameter QQ2_7	= 4096/Q2_7;
parameter QQ2_8	= 4096/Q2_8;
parameter QQ3_1	= 4096/Q3_1;
parameter QQ3_2	= 4096/Q3_2;
parameter QQ3_3	= 4096/Q3_3;
parameter QQ3_4	= 4096/Q3_4;
parameter QQ3_5	= 4096/Q3_5;
parameter QQ3_6	= 4096/Q3_6;
parameter QQ3_7	= 4096/Q3_7;
parameter QQ3_8	= 4096/Q3_8;
parameter QQ4_1	= 4096/Q4_1;
parameter QQ4_2	= 4096/Q4_2;
parameter QQ4_3	= 4096/Q4_3;
parameter QQ4_4	= 4096/Q4_4;
parameter QQ4_5	= 4096/Q4_5;
parameter QQ4_6	= 4096/Q4_6;
parameter QQ4_7	= 4096/Q4_7;
parameter QQ4_8	= 4096/Q4_8;
parameter QQ5_1	= 4096/Q5_1;
parameter QQ5_2	= 4096/Q5_2;
parameter QQ5_3	= 4096/Q5_3;
parameter QQ5_4	= 4096/Q5_4;
parameter QQ5_5	= 4096/Q5_5;
parameter QQ5_6	= 4096/Q5_6;
parameter QQ5_7	= 4096/Q5_7;
parameter QQ5_8	= 4096/Q5_8;
parameter QQ6_1	= 4096/Q6_1;
parameter QQ6_2	= 4096/Q6_2;
parameter QQ6_3	= 4096/Q6_3;
parameter QQ6_4	= 4096/Q6_4;
parameter QQ6_5	= 4096/Q6_5;
parameter QQ6_6	= 4096/Q6_6;
parameter QQ6_7	= 4096/Q6_7;
parameter QQ6_8	= 4096/Q6_8;
parameter QQ7_1	= 4096/Q7_1;
parameter QQ7_2	= 4096/Q7_2;
parameter QQ7_3	= 4096/Q7_3;
parameter QQ7_4	= 4096/Q7_4;
parameter QQ7_5	= 4096/Q7_5;
parameter QQ7_6	= 4096/Q7_6;
parameter QQ7_7	= 4096/Q7_7;
parameter QQ7_8	= 4096/Q7_8;
parameter QQ8_1	= 4096/Q8_1;
parameter QQ8_2	= 4096/Q8_2;
parameter QQ8_3	= 4096/Q8_3;
parameter QQ8_4	= 4096/Q8_4;
parameter QQ8_5	= 4096/Q8_5;
parameter QQ8_6	= 4096/Q8_6;
parameter QQ8_7	= 4096/Q8_7;
parameter QQ8_8	= 4096/Q8_8;

wire [12:0] QM1_1 = QQ1_1;
wire [12:0] QM1_2 = QQ1_2;
wire [12:0] QM1_3 = QQ1_3;
wire [12:0] QM1_4 = QQ1_4;
wire [12:0] QM1_5 = QQ1_5;
wire [12:0] QM1_6 = QQ1_6;
wire [12:0] QM1_7 = QQ1_7;
wire [12:0] QM1_8 = QQ1_8;
wire [12:0] QM2_1 = QQ2_1;
wire [12:0] QM2_2 = QQ2_2;
wire [12:0] QM2_3 = QQ2_3;
wire [12:0] QM2_4 = QQ2_4;
wire [12:0] QM2_5 = QQ2_5;
wire [12:0] QM2_6 = QQ2_6;
wire [12:0] QM2_7 = QQ2_7;
wire [12:0] QM2_8 = QQ2_8;
wire [12:0] QM3_1 = QQ3_1;
wire [12:0] QM3_2 = QQ3_2;
wire [12:0] QM3_3 = QQ3_3;
wire [12:0] QM3_4 = QQ3_4;
wire [12:0] QM3_5 = QQ3_5;
wire [12:0] QM3_6 = QQ3_6;
wire [12:0] QM3_7 = QQ3_7;
wire [12:0] QM3_8 = QQ3_8;
wire [12:0] QM4_1 = QQ4_1;
wire [12:0] QM4_2 = QQ4_2;
wire [12:0] QM4_3 = QQ4_3;
wire [12:0] QM4_4 = QQ4_4;
wire [12:0] QM4_5 = QQ4_5;
wire [12:0] QM4_6 = QQ4_6;
wire [12:0] QM4_7 = QQ4_7;
wire [12:0] QM4_8 = QQ4_8;
wire [12:0] QM5_1 = QQ5_1;
wire [12:0] QM5_2 = QQ5_2;
wire [12:0] QM5_3 = QQ5_3;
wire [12:0] QM5_4 = QQ5_4;
wire [12:0] QM5_5 = QQ5_5;
wire [12:0] QM5_6 = QQ5_6;
wire [12:0] QM5_7 = QQ5_7;
wire [12:0] QM5_8 = QQ5_8;
wire [12:0] QM6_1 = QQ6_1;
wire [12:0] QM6_2 = QQ6_2;
wire [12:0] QM6_3 = QQ6_3;
wire [12:0] QM6_4 = QQ6_4;
wire [12:0] QM6_5 = QQ6_5;
wire [12:0] QM6_6 = QQ6_6;
wire [12:0] QM6_7 = QQ6_7;
wire [12:0] QM6_8 = QQ6_8;
wire [12:0] QM7_1 = QQ7_1;
wire [12:0] QM7_2 = QQ7_2;
wire [12:0] QM7_3 = QQ7_3;
wire [12:0] QM7_4 = QQ7_4;
wire [12:0] QM7_5 = QQ7_5;
wire [12:0] QM7_6 = QQ7_6;
wire [12:0] QM7_7 = QQ7_7;
wire [12:0] QM7_8 = QQ7_8;
wire [12:0] QM8_1 = QQ8_1;
wire [12:0] QM8_2 = QQ8_2;
wire [12:0] QM8_3 = QQ8_3;
wire [12:0] QM8_4 = QQ8_4;
wire [12:0] QM8_5 = QQ8_5;
wire [12:0] QM8_6 = QQ8_6;
wire [12:0] QM8_7 = QQ8_7;
wire [12:0] QM8_8 = QQ8_8;
reg [22:0] Z11_temp, Z12_temp, Z13_temp, Z14_temp, Z15_temp, Z16_temp, Z17_temp, Z18_temp;
reg [22:0] Z21_temp, Z22_temp, Z23_temp, Z24_temp, Z25_temp, Z26_temp, Z27_temp, Z28_temp;
reg [22:0] Z31_temp, Z32_temp, Z33_temp, Z34_temp, Z35_temp, Z36_temp, Z37_temp, Z38_temp;
reg [22:0] Z41_temp, Z42_temp, Z43_temp, Z44_temp, Z45_temp, Z46_temp, Z47_temp, Z48_temp;
reg [22:0] Z51_temp, Z52_temp, Z53_temp, Z54_temp, Z55_temp, Z56_temp, Z57_temp, Z58_temp;
reg [22:0] Z61_temp, Z62_temp, Z63_temp, Z64_temp, Z65_temp, Z66_temp, Z67_temp, Z68_temp;
reg [22:0] Z71_temp, Z72_temp, Z73_temp, Z74_temp, Z75_temp, Z76_temp, Z77_temp, Z78_temp;
reg [22:0] Z81_temp, Z82_temp, Z83_temp, Z84_temp, Z85_temp, Z86_temp, Z87_temp, Z88_temp;
reg [22:0] Z11_temp_1, Z12_temp_1, Z13_temp_1, Z14_temp_1, Z15_temp_1, Z16_temp_1, Z17_temp_1, Z18_temp_1;
reg [22:0] Z21_temp_1, Z22_temp_1, Z23_temp_1, Z24_temp_1, Z25_temp_1, Z26_temp_1, Z27_temp_1, Z28_temp_1;
reg [22:0] Z31_temp_1, Z32_temp_1, Z33_temp_1, Z34_temp_1, Z35_temp_1, Z36_temp_1, Z37_temp_1, Z38_temp_1;
reg [22:0] Z41_temp_1, Z42_temp_1, Z43_temp_1, Z44_temp_1, Z45_temp_1, Z46_temp_1, Z47_temp_1, Z48_temp_1;
reg [22:0] Z51_temp_1, Z52_temp_1, Z53_temp_1, Z54_temp_1, Z55_temp_1, Z56_temp_1, Z57_temp_1, Z58_temp_1;
reg [22:0] Z61_temp_1, Z62_temp_1, Z63_temp_1, Z64_temp_1, Z65_temp_1, Z66_temp_1, Z67_temp_1, Z68_temp_1;
reg [22:0] Z71_temp_1, Z72_temp_1, Z73_temp_1, Z74_temp_1, Z75_temp_1, Z76_temp_1, Z77_temp_1, Z78_temp_1;
reg [22:0] Z81_temp_1, Z82_temp_1, Z83_temp_1, Z84_temp_1, Z85_temp_1, Z86_temp_1, Z87_temp_1, Z88_temp_1;
reg [10:0] Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18; 	
reg [10:0] Q21, Q22, Q23, Q24, Q25, Q26, Q27, Q28; 
reg [10:0] Q31, Q32, Q33, Q34, Q35, Q36, Q37, Q38; 
reg [10:0] Q41, Q42, Q43, Q44, Q45, Q46, Q47, Q48; 
reg [10:0] Q51, Q52, Q53, Q54, Q55, Q56, Q57, Q58; 
reg [10:0] Q61, Q62, Q63, Q64, Q65, Q66, Q67, Q68; 
reg [10:0] Q71, Q72, Q73, Q74, Q75, Q76, Q77, Q78; 
reg [10:0] Q81, Q82, Q83, Q84, Q85, Q86, Q87, Q88; 
reg out_enable, enable_1, enable_2, enable_3;
integer Z11_int, Z12_int, Z13_int, Z14_int, Z15_int, Z16_int, Z17_int, Z18_int;
integer Z21_int, Z22_int, Z23_int, Z24_int, Z25_int, Z26_int, Z27_int, Z28_int;
integer Z31_int, Z32_int, Z33_int, Z34_int, Z35_int, Z36_int, Z37_int, Z38_int;
integer Z41_int, Z42_int, Z43_int, Z44_int, Z45_int, Z46_int, Z47_int, Z48_int;
integer Z51_int, Z52_int, Z53_int, Z54_int, Z55_int, Z56_int, Z57_int, Z58_int;
integer Z61_int, Z62_int, Z63_int, Z64_int, Z65_int, Z66_int, Z67_int, Z68_int;
integer Z71_int, Z72_int, Z73_int, Z74_int, Z75_int, Z76_int, Z77_int, Z78_int;
integer Z81_int, Z82_int, Z83_int, Z84_int, Z85_int, Z86_int, Z87_int, Z88_int;

always @(posedge clk)
begin
	if (rst) begin
		Z11_int <= 0; Z12_int <= 0; Z13_int <= 0; Z14_int <= 0;
		Z15_int <= 0; Z16_int <= 0; Z17_int <= 0; Z18_int <= 0; 
		Z21_int <= 0; Z22_int <= 0; Z23_int <= 0; Z24_int <= 0;
		Z25_int <= 0; Z26_int <= 0; Z27_int <= 0; Z28_int <= 0;
		Z31_int <= 0; Z32_int <= 0; Z33_int <= 0; Z34_int <= 0;
		Z35_int <= 0; Z36_int <= 0; Z37_int <= 0; Z38_int <= 0;
		Z41_int <= 0; Z42_int <= 0; Z43_int <= 0; Z44_int <= 0;
		Z45_int <= 0; Z46_int <= 0; Z47_int <= 0; Z48_int <= 0;
		Z51_int <= 0; Z52_int <= 0; Z53_int <= 0; Z54_int <= 0;
		Z55_int <= 0; Z56_int <= 0; Z57_int <= 0; Z58_int <= 0;
		Z61_int <= 0; Z62_int <= 0; Z63_int <= 0; Z64_int <= 0;
		Z65_int <= 0; Z66_int <= 0; Z67_int <= 0; Z68_int <= 0;
		Z71_int <= 0; Z72_int <= 0; Z73_int <= 0; Z74_int <= 0;
		Z75_int <= 0; Z76_int <= 0; Z77_int <= 0; Z78_int <= 0;
		Z81_int <= 0; Z82_int <= 0; Z83_int <= 0; Z84_int <= 0;
		Z85_int <= 0; Z86_int <= 0; Z87_int <= 0; Z88_int <= 0;
		end
	else if (enable) begin
		Z11_int[10:0] <= Z11; Z12_int[10:0] <= Z12; Z13_int[10:0] <= Z13; Z14_int[10:0] <= Z14;
		Z15_int[10:0] <= Z15; Z16_int[10:0] <= Z16; Z17_int[10:0] <= Z17; Z18_int[10:0] <= Z18;
		Z21_int[10:0] <= Z21; Z22_int[10:0] <= Z22; Z23_int[10:0] <= Z23; Z24_int[10:0] <= Z24;
		Z25_int[10:0] <= Z25; Z26_int[10:0] <= Z26; Z27_int[10:0] <= Z27; Z28_int[10:0] <= Z28;
		Z31_int[10:0] <= Z31; Z32_int[10:0] <= Z32; Z33_int[10:0] <= Z33; Z34_int[10:0] <= Z34;
		Z35_int[10:0] <= Z35; Z36_int[10:0] <= Z36; Z37_int[10:0] <= Z37; Z38_int[10:0] <= Z38;
		Z41_int[10:0] <= Z41; Z42_int[10:0] <= Z42; Z43_int[10:0] <= Z43; Z44_int[10:0] <= Z44;
		Z45_int[10:0] <= Z45; Z46_int[10:0] <= Z46; Z47_int[10:0] <= Z47; Z48_int[10:0] <= Z48;
		Z51_int[10:0] <= Z51; Z52_int[10:0] <= Z52; Z53_int[10:0] <= Z53; Z54_int[10:0] <= Z54;
		Z55_int[10:0] <= Z55; Z56_int[10:0] <= Z56; Z57_int[10:0] <= Z57; Z58_int[10:0] <= Z58;
		Z61_int[10:0] <= Z61; Z62_int[10:0] <= Z62; Z63_int[10:0] <= Z63; Z64_int[10:0] <= Z64;
		Z65_int[10:0] <= Z65; Z66_int[10:0] <= Z66; Z67_int[10:0] <= Z67; Z68_int[10:0] <= Z68;
		Z71_int[10:0] <= Z71; Z72_int[10:0] <= Z72; Z73_int[10:0] <= Z73; Z74_int[10:0] <= Z74;
		Z75_int[10:0] <= Z75; Z76_int[10:0] <= Z76; Z77_int[10:0] <= Z77; Z78_int[10:0] <= Z78;
		Z81_int[10:0] <= Z81; Z82_int[10:0] <= Z82; Z83_int[10:0] <= Z83; Z84_int[10:0] <= Z84;
		Z85_int[10:0] <= Z85; Z86_int[10:0] <= Z86; Z87_int[10:0] <= Z87; Z88_int[10:0] <= Z88;
		// sign extend to make Z11_int a twos complement representation of Z11
		Z11_int[31:11] <= Z11[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z12_int[31:11] <= Z12[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z13_int[31:11] <= Z13[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z14_int[31:11] <= Z14[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z15_int[31:11] <= Z15[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z16_int[31:11] <= Z16[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z17_int[31:11] <= Z17[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z18_int[31:11] <= Z18[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z21_int[31:11] <= Z21[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z22_int[31:11] <= Z22[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z23_int[31:11] <= Z23[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z24_int[31:11] <= Z24[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z25_int[31:11] <= Z25[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z26_int[31:11] <= Z26[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z27_int[31:11] <= Z27[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z28_int[31:11] <= Z28[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z31_int[31:11] <= Z31[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z32_int[31:11] <= Z32[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z33_int[31:11] <= Z33[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z34_int[31:11] <= Z34[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z35_int[31:11] <= Z35[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z36_int[31:11] <= Z36[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z37_int[31:11] <= Z37[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z38_int[31:11] <= Z38[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z41_int[31:11] <= Z41[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z42_int[31:11] <= Z42[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z43_int[31:11] <= Z43[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z44_int[31:11] <= Z44[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z45_int[31:11] <= Z45[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z46_int[31:11] <= Z46[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z47_int[31:11] <= Z47[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z48_int[31:11] <= Z48[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z51_int[31:11] <= Z51[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z52_int[31:11] <= Z52[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z53_int[31:11] <= Z53[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z54_int[31:11] <= Z54[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z55_int[31:11] <= Z55[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z56_int[31:11] <= Z56[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z57_int[31:11] <= Z57[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z58_int[31:11] <= Z58[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z61_int[31:11] <= Z61[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z62_int[31:11] <= Z62[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z63_int[31:11] <= Z63[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z64_int[31:11] <= Z64[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z65_int[31:11] <= Z65[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z66_int[31:11] <= Z66[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z67_int[31:11] <= Z67[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z68_int[31:11] <= Z68[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z71_int[31:11] <= Z71[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z72_int[31:11] <= Z72[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z73_int[31:11] <= Z73[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z74_int[31:11] <= Z74[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z75_int[31:11] <= Z75[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z76_int[31:11] <= Z76[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z77_int[31:11] <= Z77[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z78_int[31:11] <= Z78[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z81_int[31:11] <= Z81[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z82_int[31:11] <= Z82[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z83_int[31:11] <= Z83[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z84_int[31:11] <= Z84[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z85_int[31:11] <= Z85[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z86_int[31:11] <= Z86[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z87_int[31:11] <= Z87[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Z88_int[31:11] <= Z88[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;	 
		end
end	   

always @(posedge clk)
begin
	if (rst) begin
		Z11_temp <= 0; Z12_temp <= 0; Z13_temp <= 0; Z14_temp <= 0;
		Z12_temp <= 0; Z16_temp <= 0; Z17_temp <= 0; Z18_temp <= 0;
		Z21_temp <= 0; Z22_temp <= 0; Z23_temp <= 0; Z24_temp <= 0;
		Z22_temp <= 0; Z26_temp <= 0; Z27_temp <= 0; Z28_temp <= 0;
		Z31_temp <= 0; Z32_temp <= 0; Z33_temp <= 0; Z34_temp <= 0;
		Z32_temp <= 0; Z36_temp <= 0; Z37_temp <= 0; Z38_temp <= 0;
		Z41_temp <= 0; Z42_temp <= 0; Z43_temp <= 0; Z44_temp <= 0;
		Z42_temp <= 0; Z46_temp <= 0; Z47_temp <= 0; Z48_temp <= 0;
		Z51_temp <= 0; Z52_temp <= 0; Z53_temp <= 0; Z54_temp <= 0;
		Z52_temp <= 0; Z56_temp <= 0; Z57_temp <= 0; Z58_temp <= 0;
		Z61_temp <= 0; Z62_temp <= 0; Z63_temp <= 0; Z64_temp <= 0;
		Z62_temp <= 0; Z66_temp <= 0; Z67_temp <= 0; Z68_temp <= 0;
		Z71_temp <= 0; Z72_temp <= 0; Z73_temp <= 0; Z74_temp <= 0;
		Z72_temp <= 0; Z76_temp <= 0; Z77_temp <= 0; Z78_temp <= 0;
		Z81_temp <= 0; Z82_temp <= 0; Z83_temp <= 0; Z84_temp <= 0;
		Z82_temp <= 0; Z86_temp <= 0; Z87_temp <= 0; Z88_temp <= 0;
		end
	else if (enable_1) begin
		Z11_temp <= Z11_int * QM1_1; Z12_temp <= Z12_int * QM1_2;
		Z13_temp <= Z13_int * QM1_3; Z14_temp <= Z14_int * QM1_4;
		Z15_temp <= Z15_int * QM1_5; Z16_temp <= Z16_int * QM1_6;
		Z17_temp <= Z17_int * QM1_7; Z18_temp <= Z18_int * QM1_8;
		Z21_temp <= Z21_int * QM2_1; Z22_temp <= Z22_int * QM2_2;
		Z23_temp <= Z23_int * QM2_3; Z24_temp <= Z24_int * QM2_4;
		Z25_temp <= Z25_int * QM2_5; Z26_temp <= Z26_int * QM2_6;
		Z27_temp <= Z27_int * QM2_7; Z28_temp <= Z28_int * QM2_8;
		Z31_temp <= Z31_int * QM3_1; Z32_temp <= Z32_int * QM3_2;
		Z33_temp <= Z33_int * QM3_3; Z34_temp <= Z34_int * QM3_4;
		Z35_temp <= Z35_int * QM3_5; Z36_temp <= Z36_int * QM3_6;
		Z37_temp <= Z37_int * QM3_7; Z38_temp <= Z38_int * QM3_8;
		Z41_temp <= Z41_int * QM4_1; Z42_temp <= Z42_int * QM4_2;
		Z43_temp <= Z43_int * QM4_3; Z44_temp <= Z44_int * QM4_4;
		Z45_temp <= Z45_int * QM4_5; Z46_temp <= Z46_int * QM4_6;
		Z47_temp <= Z47_int * QM4_7; Z48_temp <= Z48_int * QM4_8;
		Z51_temp <= Z51_int * QM5_1; Z52_temp <= Z52_int * QM5_2;
		Z53_temp <= Z53_int * QM5_3; Z54_temp <= Z54_int * QM5_4;
		Z55_temp <= Z55_int * QM5_5; Z56_temp <= Z56_int * QM5_6;
		Z57_temp <= Z57_int * QM5_7; Z58_temp <= Z58_int * QM5_8;
		Z61_temp <= Z61_int * QM6_1; Z62_temp <= Z62_int * QM6_2;
		Z63_temp <= Z63_int * QM6_3; Z64_temp <= Z64_int * QM6_4;
		Z65_temp <= Z65_int * QM6_5; Z66_temp <= Z66_int * QM6_6;
		Z67_temp <= Z67_int * QM6_7; Z68_temp <= Z68_int * QM6_8;
		Z71_temp <= Z71_int * QM7_1; Z72_temp <= Z72_int * QM7_2;
		Z73_temp <= Z73_int * QM7_3; Z74_temp <= Z74_int * QM7_4;
		Z75_temp <= Z75_int * QM7_5; Z76_temp <= Z76_int * QM7_6;
		Z77_temp <= Z77_int * QM7_7; Z78_temp <= Z78_int * QM7_8;
		Z81_temp <= Z81_int * QM8_1; Z82_temp <= Z82_int * QM8_2;
		Z83_temp <= Z83_int * QM8_3; Z84_temp <= Z84_int * QM8_4;
		Z85_temp <= Z85_int * QM8_5; Z86_temp <= Z86_int * QM8_6;
		Z87_temp <= Z87_int * QM8_7; Z88_temp <= Z88_int * QM8_8;
		end
end	 


always @(posedge clk)
begin
	if (rst) begin
		Z11_temp_1 <= 0; Z12_temp_1 <= 0; Z13_temp_1 <= 0; Z14_temp_1 <= 0;
		Z12_temp_1 <= 0; Z16_temp_1 <= 0; Z17_temp_1 <= 0; Z18_temp_1 <= 0;
		Z21_temp_1 <= 0; Z22_temp_1 <= 0; Z23_temp_1 <= 0; Z24_temp_1 <= 0;
		Z22_temp_1 <= 0; Z26_temp_1 <= 0; Z27_temp_1 <= 0; Z28_temp_1 <= 0;
		Z31_temp_1 <= 0; Z32_temp_1 <= 0; Z33_temp_1 <= 0; Z34_temp_1 <= 0;
		Z32_temp_1 <= 0; Z36_temp_1 <= 0; Z37_temp_1 <= 0; Z38_temp_1 <= 0;
		Z41_temp_1 <= 0; Z42_temp_1 <= 0; Z43_temp_1 <= 0; Z44_temp_1 <= 0;
		Z42_temp_1 <= 0; Z46_temp_1 <= 0; Z47_temp_1 <= 0; Z48_temp_1 <= 0;
		Z51_temp_1 <= 0; Z52_temp_1 <= 0; Z53_temp_1 <= 0; Z54_temp_1 <= 0;
		Z52_temp_1 <= 0; Z56_temp_1 <= 0; Z57_temp_1 <= 0; Z58_temp_1 <= 0;
		Z61_temp_1 <= 0; Z62_temp_1 <= 0; Z63_temp_1 <= 0; Z64_temp_1 <= 0;
		Z62_temp_1 <= 0; Z66_temp_1 <= 0; Z67_temp_1 <= 0; Z68_temp_1 <= 0;
		Z71_temp_1 <= 0; Z72_temp_1 <= 0; Z73_temp_1 <= 0; Z74_temp_1 <= 0;
		Z72_temp_1 <= 0; Z76_temp_1 <= 0; Z77_temp_1 <= 0; Z78_temp_1 <= 0;
		Z81_temp_1 <= 0; Z82_temp_1 <= 0; Z83_temp_1 <= 0; Z84_temp_1 <= 0;
		Z82_temp_1 <= 0; Z86_temp_1 <= 0; Z87_temp_1 <= 0; Z88_temp_1 <= 0;
		end
	else if (enable_2) begin
		Z11_temp_1 <= Z11_temp; Z12_temp_1 <= Z12_temp;
		Z13_temp_1 <= Z13_temp; Z14_temp_1 <= Z14_temp;
		Z15_temp_1 <= Z15_temp; Z16_temp_1 <= Z16_temp;
		Z17_temp_1 <= Z17_temp; Z18_temp_1 <= Z18_temp;
		Z21_temp_1 <= Z21_temp; Z22_temp_1 <= Z22_temp;
		Z23_temp_1 <= Z23_temp; Z24_temp_1 <= Z24_temp;
		Z25_temp_1 <= Z25_temp; Z26_temp_1 <= Z26_temp;
		Z27_temp_1 <= Z27_temp; Z28_temp_1 <= Z28_temp;
		Z31_temp_1 <= Z31_temp; Z32_temp_1 <= Z32_temp;
		Z33_temp_1 <= Z33_temp; Z34_temp_1 <= Z34_temp;
		Z35_temp_1 <= Z35_temp; Z36_temp_1 <= Z36_temp;
		Z37_temp_1 <= Z37_temp; Z38_temp_1 <= Z38_temp;
		Z41_temp_1 <= Z41_temp; Z42_temp_1 <= Z42_temp;
		Z43_temp_1 <= Z43_temp; Z44_temp_1 <= Z44_temp;
		Z45_temp_1 <= Z45_temp; Z46_temp_1 <= Z46_temp;
		Z47_temp_1 <= Z47_temp; Z48_temp_1 <= Z48_temp;
		Z51_temp_1 <= Z51_temp; Z52_temp_1 <= Z52_temp;
		Z53_temp_1 <= Z53_temp; Z54_temp_1 <= Z54_temp;
		Z55_temp_1 <= Z55_temp; Z56_temp_1 <= Z56_temp;
		Z57_temp_1 <= Z57_temp; Z58_temp_1 <= Z58_temp;
		Z61_temp_1 <= Z61_temp; Z62_temp_1 <= Z62_temp;
		Z63_temp_1 <= Z63_temp; Z64_temp_1 <= Z64_temp;
		Z65_temp_1 <= Z65_temp; Z66_temp_1 <= Z66_temp;
		Z67_temp_1 <= Z67_temp; Z68_temp_1 <= Z68_temp;
		Z71_temp_1 <= Z71_temp; Z72_temp_1 <= Z72_temp;
		Z73_temp_1 <= Z73_temp; Z74_temp_1 <= Z74_temp;
		Z75_temp_1 <= Z75_temp; Z76_temp_1 <= Z76_temp;
		Z77_temp_1 <= Z77_temp; Z78_temp_1 <= Z78_temp;
		Z81_temp_1 <= Z81_temp; Z82_temp_1 <= Z82_temp;
		Z83_temp_1 <= Z83_temp; Z84_temp_1 <= Z84_temp;
		Z85_temp_1 <= Z85_temp; Z86_temp_1 <= Z86_temp;
		Z87_temp_1 <= Z87_temp; Z88_temp_1 <= Z88_temp;
		end
end	 

always @(posedge clk)
begin
	if (rst) begin
		Q11 <= 0; Q12 <= 0; Q13 <= 0; Q14 <= 0; Q15 <= 0; Q16 <= 0; Q17 <= 0; Q18 <= 0;
		Q21 <= 0; Q22 <= 0; Q23 <= 0; Q24 <= 0; Q25 <= 0; Q26 <= 0; Q27 <= 0; Q28 <= 0;
		Q31 <= 0; Q32 <= 0; Q33 <= 0; Q34 <= 0; Q35 <= 0; Q36 <= 0; Q37 <= 0; Q38 <= 0;
		Q41 <= 0; Q42 <= 0; Q43 <= 0; Q44 <= 0; Q45 <= 0; Q46 <= 0; Q47 <= 0; Q48 <= 0;
		Q51 <= 0; Q52 <= 0; Q53 <= 0; Q54 <= 0; Q55 <= 0; Q56 <= 0; Q57 <= 0; Q58 <= 0;
		Q61 <= 0; Q62 <= 0; Q63 <= 0; Q64 <= 0; Q65 <= 0; Q66 <= 0; Q67 <= 0; Q68 <= 0;
		Q71 <= 0; Q72 <= 0; Q73 <= 0; Q74 <= 0; Q75 <= 0; Q76 <= 0; Q77 <= 0; Q78 <= 0;
		Q81 <= 0; Q82 <= 0; Q83 <= 0; Q84 <= 0; Q85 <= 0; Q86 <= 0; Q87 <= 0; Q88 <= 0;
		end
	else if (enable_3) begin
		// rounding Q11 based on the bit in the 11th place of Z11_temp	
		Q11 <= Z11_temp_1[11] ? Z11_temp_1[22:12] + 1 : Z11_temp_1[22:12]; 
		Q12 <= Z12_temp_1[11] ? Z12_temp_1[22:12] + 1 : Z12_temp_1[22:12];
		Q13 <= Z13_temp_1[11] ? Z13_temp_1[22:12] + 1 : Z13_temp_1[22:12];
		Q14 <= Z14_temp_1[11] ? Z14_temp_1[22:12] + 1 : Z14_temp_1[22:12];
		Q15 <= Z15_temp_1[11] ? Z15_temp_1[22:12] + 1 : Z15_temp_1[22:12];
		Q16 <= Z16_temp_1[11] ? Z16_temp_1[22:12] + 1 : Z16_temp_1[22:12];
		Q17 <= Z17_temp_1[11] ? Z17_temp_1[22:12] + 1 : Z17_temp_1[22:12];
		Q18 <= Z18_temp_1[11] ? Z18_temp_1[22:12] + 1 : Z18_temp_1[22:12]; 
		Q21 <= Z21_temp_1[11] ? Z21_temp_1[22:12] + 1 : Z21_temp_1[22:12];
		Q22 <= Z22_temp_1[11] ? Z22_temp_1[22:12] + 1 : Z22_temp_1[22:12];
		Q23 <= Z23_temp_1[11] ? Z23_temp_1[22:12] + 1 : Z23_temp_1[22:12];
		Q24 <= Z24_temp_1[11] ? Z24_temp_1[22:12] + 1 : Z24_temp_1[22:12];
		Q25 <= Z25_temp_1[11] ? Z25_temp_1[22:12] + 1 : Z25_temp_1[22:12];
		Q26 <= Z26_temp_1[11] ? Z26_temp_1[22:12] + 1 : Z26_temp_1[22:12];
		Q27 <= Z27_temp_1[11] ? Z27_temp_1[22:12] + 1 : Z27_temp_1[22:12];
		Q28 <= Z28_temp_1[11] ? Z28_temp_1[22:12] + 1 : Z28_temp_1[22:12];
		Q31 <= Z31_temp_1[11] ? Z31_temp_1[22:12] + 1 : Z31_temp_1[22:12];
		Q32 <= Z32_temp_1[11] ? Z32_temp_1[22:12] + 1 : Z32_temp_1[22:12];
		Q33 <= Z33_temp_1[11] ? Z33_temp_1[22:12] + 1 : Z33_temp_1[22:12];
		Q34 <= Z34_temp_1[11] ? Z34_temp_1[22:12] + 1 : Z34_temp_1[22:12];
		Q35 <= Z35_temp_1[11] ? Z35_temp_1[22:12] + 1 : Z35_temp_1[22:12];
		Q36 <= Z36_temp_1[11] ? Z36_temp_1[22:12] + 1 : Z36_temp_1[22:12];
		Q37 <= Z37_temp_1[11] ? Z37_temp_1[22:12] + 1 : Z37_temp_1[22:12];
		Q38 <= Z38_temp_1[11] ? Z38_temp_1[22:12] + 1 : Z38_temp_1[22:12];
		Q41 <= Z41_temp_1[11] ? Z41_temp_1[22:12] + 1 : Z41_temp_1[22:12];
		Q42 <= Z42_temp_1[11] ? Z42_temp_1[22:12] + 1 : Z42_temp_1[22:12];
		Q43 <= Z43_temp_1[11] ? Z43_temp_1[22:12] + 1 : Z43_temp_1[22:12];
		Q44 <= Z44_temp_1[11] ? Z44_temp_1[22:12] + 1 : Z44_temp_1[22:12];
		Q45 <= Z45_temp_1[11] ? Z45_temp_1[22:12] + 1 : Z45_temp_1[22:12];
		Q46 <= Z46_temp_1[11] ? Z46_temp_1[22:12] + 1 : Z46_temp_1[22:12];
		Q47 <= Z47_temp_1[11] ? Z47_temp_1[22:12] + 1 : Z47_temp_1[22:12];
		Q48 <= Z48_temp_1[11] ? Z48_temp_1[22:12] + 1 : Z48_temp_1[22:12];
		Q51 <= Z51_temp_1[11] ? Z51_temp_1[22:12] + 1 : Z51_temp_1[22:12];
		Q52 <= Z52_temp_1[11] ? Z52_temp_1[22:12] + 1 : Z52_temp_1[22:12];
		Q53 <= Z53_temp_1[11] ? Z53_temp_1[22:12] + 1 : Z53_temp_1[22:12];
		Q54 <= Z54_temp_1[11] ? Z54_temp_1[22:12] + 1 : Z54_temp_1[22:12];
		Q55 <= Z55_temp_1[11] ? Z55_temp_1[22:12] + 1 : Z55_temp_1[22:12];
		Q56 <= Z56_temp_1[11] ? Z56_temp_1[22:12] + 1 : Z56_temp_1[22:12];
		Q57 <= Z57_temp_1[11] ? Z57_temp_1[22:12] + 1 : Z57_temp_1[22:12];
		Q58 <= Z58_temp_1[11] ? Z58_temp_1[22:12] + 1 : Z58_temp_1[22:12];
		Q61 <= Z61_temp_1[11] ? Z61_temp_1[22:12] + 1 : Z61_temp_1[22:12];
		Q62 <= Z62_temp_1[11] ? Z62_temp_1[22:12] + 1 : Z62_temp_1[22:12];
		Q63 <= Z63_temp_1[11] ? Z63_temp_1[22:12] + 1 : Z63_temp_1[22:12];
		Q64 <= Z64_temp_1[11] ? Z64_temp_1[22:12] + 1 : Z64_temp_1[22:12];
		Q65 <= Z65_temp_1[11] ? Z65_temp_1[22:12] + 1 : Z65_temp_1[22:12];
		Q66 <= Z66_temp_1[11] ? Z66_temp_1[22:12] + 1 : Z66_temp_1[22:12];
		Q67 <= Z67_temp_1[11] ? Z67_temp_1[22:12] + 1 : Z67_temp_1[22:12];
		Q68 <= Z68_temp_1[11] ? Z68_temp_1[22:12] + 1 : Z68_temp_1[22:12];
		Q71 <= Z71_temp_1[11] ? Z71_temp_1[22:12] + 1 : Z71_temp_1[22:12];
		Q72 <= Z72_temp_1[11] ? Z72_temp_1[22:12] + 1 : Z72_temp_1[22:12];
		Q73 <= Z73_temp_1[11] ? Z73_temp_1[22:12] + 1 : Z73_temp_1[22:12];
		Q74 <= Z74_temp_1[11] ? Z74_temp_1[22:12] + 1 : Z74_temp_1[22:12];
		Q75 <= Z75_temp_1[11] ? Z75_temp_1[22:12] + 1 : Z75_temp_1[22:12];
		Q76 <= Z76_temp_1[11] ? Z76_temp_1[22:12] + 1 : Z76_temp_1[22:12];
		Q77 <= Z77_temp_1[11] ? Z77_temp_1[22:12] + 1 : Z77_temp_1[22:12];
		Q78 <= Z78_temp_1[11] ? Z78_temp_1[22:12] + 1 : Z78_temp_1[22:12];
		Q81 <= Z81_temp_1[11] ? Z81_temp_1[22:12] + 1 : Z81_temp_1[22:12];
		Q82 <= Z82_temp_1[11] ? Z82_temp_1[22:12] + 1 : Z82_temp_1[22:12];
		Q83 <= Z83_temp_1[11] ? Z83_temp_1[22:12] + 1 : Z83_temp_1[22:12];
		Q84 <= Z84_temp_1[11] ? Z84_temp_1[22:12] + 1 : Z84_temp_1[22:12];
		Q85 <= Z85_temp_1[11] ? Z85_temp_1[22:12] + 1 : Z85_temp_1[22:12];
		Q86 <= Z86_temp_1[11] ? Z86_temp_1[22:12] + 1 : Z86_temp_1[22:12];
		Q87 <= Z87_temp_1[11] ? Z87_temp_1[22:12] + 1 : Z87_temp_1[22:12];
		Q88 <= Z88_temp_1[11] ? Z88_temp_1[22:12] + 1 : Z88_temp_1[22:12];
		end
end	 


/* enable_1 is delayed one clock cycle from enable, and it's used to 
enable the logic that needs to execute on the clock cycle after enable goes high 
enable_2 is delayed two clock cycles, and out_enable signals the next module
that its input data is ready*/

always @(posedge clk)
begin
	if (rst) begin
		enable_1 <= 0; enable_2 <= 0; enable_3 <= 0;
		out_enable <= 0;
		end
	else begin
		enable_1 <= enable; enable_2 <= enable_1;
		enable_3 <= enable_2;
		out_enable <= enable_3;
		end
end	 

endmodule
