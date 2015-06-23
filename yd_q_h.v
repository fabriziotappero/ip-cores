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

/* This module combines the dct, quantizer, and huffman modules. */

`timescale 1ns / 100ps

module yd_q_h(clk, rst, enable, data_in,
JPEG_bitstream, 
  data_ready, y_orc, end_of_block_output,
   end_of_block_empty);
input		clk;
input		rst;
input		enable;
input	[7:0]	data_in;
output  [31:0]  JPEG_bitstream;
output		data_ready;
output [4:0] y_orc;
output	end_of_block_output;
output	end_of_block_empty;


wire	dct_enable, quantizer_enable;
wire [10:0] Z11_final, Z12_final, Z13_final, Z14_final;
wire [10:0] Z15_final, Z16_final, Z17_final, Z18_final;
wire [10:0] Z21_final, Z22_final, Z23_final, Z24_final;
wire [10:0] Z25_final, Z26_final, Z27_final, Z28_final;
wire [10:0] Z31_final, Z32_final, Z33_final, Z34_final;
wire [10:0] Z35_final, Z36_final, Z37_final, Z38_final;
wire [10:0] Z41_final, Z42_final, Z43_final, Z44_final;
wire [10:0] Z45_final, Z46_final, Z47_final, Z48_final;
wire [10:0] Z51_final, Z52_final, Z53_final, Z54_final;
wire [10:0] Z55_final, Z56_final, Z57_final, Z58_final;
wire [10:0] Z61_final, Z62_final, Z63_final, Z64_final;
wire [10:0] Z65_final, Z66_final, Z67_final, Z68_final;
wire [10:0] Z71_final, Z72_final, Z73_final, Z74_final;
wire [10:0] Z75_final, Z76_final, Z77_final, Z78_final;
wire [10:0] Z81_final, Z82_final, Z83_final, Z84_final;
wire [10:0] Z85_final, Z86_final, Z87_final, Z88_final;
wire [10:0] Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18; 	
wire [10:0] Q21, Q22, Q23, Q24, Q25, Q26, Q27, Q28; 
wire [10:0] Q31, Q32, Q33, Q34, Q35, Q36, Q37, Q38; 
wire [10:0] Q41, Q42, Q43, Q44, Q45, Q46, Q47, Q48; 
wire [10:0] Q51, Q52, Q53, Q54, Q55, Q56, Q57, Q58; 
wire [10:0] Q61, Q62, Q63, Q64, Q65, Q66, Q67, Q68; 
wire [10:0] Q71, Q72, Q73, Q74, Q75, Q76, Q77, Q78; 
wire [10:0] Q81, Q82, Q83, Q84, Q85, Q86, Q87, Q88; 

	y_dct u1(
	.clk(clk),.rst(rst), .enable(enable), .data_in(data_in), 
	.Z11_final(Z11_final), .Z12_final(Z12_final), 
	.Z13_final(Z13_final), .Z14_final(Z14_final), .Z15_final(Z15_final), .Z16_final(Z16_final), 
	.Z17_final(Z17_final), .Z18_final(Z18_final), .Z21_final(Z21_final), .Z22_final(Z22_final), 
	.Z23_final(Z23_final), .Z24_final(Z24_final), .Z25_final(Z25_final), .Z26_final(Z26_final), 
	.Z27_final(Z27_final), .Z28_final(Z28_final), .Z31_final(Z31_final), .Z32_final(Z32_final), 
	.Z33_final(Z33_final), .Z34_final(Z34_final), .Z35_final(Z35_final), .Z36_final(Z36_final), 
	.Z37_final(Z37_final), .Z38_final(Z38_final), .Z41_final(Z41_final), .Z42_final(Z42_final), 
	.Z43_final(Z43_final), .Z44_final(Z44_final), .Z45_final(Z45_final), .Z46_final(Z46_final), 
	.Z47_final(Z47_final), .Z48_final(Z48_final), .Z51_final(Z51_final), .Z52_final(Z52_final), 
	.Z53_final(Z53_final), .Z54_final(Z54_final), .Z55_final(Z55_final), .Z56_final(Z56_final), 
	.Z57_final(Z57_final), .Z58_final(Z58_final), .Z61_final(Z61_final), .Z62_final(Z62_final), 
	.Z63_final(Z63_final), .Z64_final(Z64_final), .Z65_final(Z65_final), .Z66_final(Z66_final), 
	.Z67_final(Z67_final), .Z68_final(Z68_final), .Z71_final(Z71_final), .Z72_final(Z72_final), 
	.Z73_final(Z73_final), .Z74_final(Z74_final), .Z75_final(Z75_final), .Z76_final(Z76_final), 
	.Z77_final(Z77_final), .Z78_final(Z78_final), .Z81_final(Z81_final), .Z82_final(Z82_final), 
	.Z83_final(Z83_final), .Z84_final(Z84_final), .Z85_final(Z85_final), .Z86_final(Z86_final), 
	.Z87_final(Z87_final), .Z88_final(Z88_final), .output_enable(dct_enable)); 
	
	y_quantizer u2(
	.clk(clk),.rst(rst),.enable(dct_enable),
	.Z11(Z11_final), .Z12(Z12_final), .Z13(Z13_final), .Z14(Z14_final), 
	.Z15(Z15_final), .Z16(Z16_final), .Z17(Z17_final), .Z18(Z18_final), 
	.Z21(Z21_final), .Z22(Z22_final), .Z23(Z23_final), .Z24(Z24_final), 
	.Z25(Z25_final), .Z26(Z26_final), .Z27(Z27_final), .Z28(Z28_final),
	.Z31(Z31_final), .Z32(Z32_final), .Z33(Z33_final), .Z34(Z34_final), 
	.Z35(Z35_final), .Z36(Z36_final), .Z37(Z37_final), .Z38(Z38_final), 
	.Z41(Z41_final), .Z42(Z42_final), .Z43(Z43_final), .Z44(Z44_final), 
	.Z45(Z45_final), .Z46(Z46_final), .Z47(Z47_final), .Z48(Z48_final),
	.Z51(Z51_final), .Z52(Z52_final), .Z53(Z53_final), .Z54(Z54_final), 
	.Z55(Z55_final), .Z56(Z56_final), .Z57(Z57_final), .Z58(Z58_final), 
	.Z61(Z61_final), .Z62(Z62_final), .Z63(Z63_final), .Z64(Z64_final), 
	.Z65(Z65_final), .Z66(Z66_final), .Z67(Z67_final), .Z68(Z68_final),
	.Z71(Z71_final), .Z72(Z72_final), .Z73(Z73_final), .Z74(Z74_final), 
	.Z75(Z75_final), .Z76(Z76_final), .Z77(Z77_final), .Z78(Z78_final), 
	.Z81(Z81_final), .Z82(Z82_final), .Z83(Z83_final), .Z84(Z84_final), 
	.Z85(Z85_final), .Z86(Z86_final), .Z87(Z87_final), .Z88(Z88_final),
	.Q11(Q11), .Q12(Q12), .Q13(Q13), .Q14(Q14), .Q15(Q15), .Q16(Q16), .Q17(Q17), .Q18(Q18), 
	.Q21(Q21), .Q22(Q22), .Q23(Q23), .Q24(Q24), .Q25(Q25), .Q26(Q26), .Q27(Q27), .Q28(Q28),
	.Q31(Q31), .Q32(Q32), .Q33(Q33), .Q34(Q34), .Q35(Q35), .Q36(Q36), .Q37(Q37), .Q38(Q38), 
	.Q41(Q41), .Q42(Q42), .Q43(Q43), .Q44(Q44), .Q45(Q45), .Q46(Q46), .Q47(Q47), .Q48(Q48),
	.Q51(Q51), .Q52(Q52), .Q53(Q53), .Q54(Q54), .Q55(Q55), .Q56(Q56), .Q57(Q57), .Q58(Q58), 
	.Q61(Q61), .Q62(Q62), .Q63(Q63), .Q64(Q64), .Q65(Q65), .Q66(Q66), .Q67(Q67), .Q68(Q68),
	.Q71(Q71), .Q72(Q72), .Q73(Q73), .Q74(Q74), .Q75(Q75), .Q76(Q76), .Q77(Q77), .Q78(Q78), 
	.Q81(Q81), .Q82(Q82), .Q83(Q83), .Q84(Q84), .Q85(Q85), .Q86(Q86), .Q87(Q87), .Q88(Q88),
	.out_enable(quantizer_enable));

	y_huff u3(.clk(clk), .rst(rst), .enable(quantizer_enable), 
	.Y11(Q11), .Y12(Q21), .Y13(Q31), .Y14(Q41), .Y15(Q51), .Y16(Q61), .Y17(Q71), .Y18(Q81), 
	.Y21(Q12), .Y22(Q22), .Y23(Q32), .Y24(Q42), .Y25(Q52), .Y26(Q62), .Y27(Q72), .Y28(Q82),
	.Y31(Q13), .Y32(Q23), .Y33(Q33), .Y34(Q43), .Y35(Q53), .Y36(Q63), .Y37(Q73), .Y38(Q83), 
	.Y41(Q14), .Y42(Q24), .Y43(Q34), .Y44(Q44), .Y45(Q54), .Y46(Q64), .Y47(Q74), .Y48(Q84),
	.Y51(Q15), .Y52(Q25), .Y53(Q35), .Y54(Q45), .Y55(Q55), .Y56(Q65), .Y57(Q75), .Y58(Q85), 
	.Y61(Q16), .Y62(Q26), .Y63(Q36), .Y64(Q46), .Y65(Q56), .Y66(Q66), .Y67(Q76), .Y68(Q86),
	.Y71(Q17), .Y72(Q27), .Y73(Q37), .Y74(Q47), .Y75(Q57), .Y76(Q67), .Y77(Q77), .Y78(Q87), 
	.Y81(Q18), .Y82(Q28), .Y83(Q38), .Y84(Q48), .Y85(Q58), .Y86(Q68), .Y87(Q78), .Y88(Q88),
	.JPEG_bitstream(JPEG_bitstream), .data_ready(data_ready), .output_reg_count(y_orc),
	.end_of_block_output(end_of_block_output),
	 .end_of_block_empty(end_of_block_empty));	

	endmodule
