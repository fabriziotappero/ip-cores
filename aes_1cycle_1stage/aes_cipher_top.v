/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Cipher Top Level                                       ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
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
 
//// Modified to achieve 1 cycle functionality 			     ////
//// By Tariq Bashir Ahmad					     //// 	
////  tariq.bashir@gmail.com					     ////
////  http://www.ecs.umass.edu/~tbashir				     ////	



`timescale 1 ns/1 ps

module aes_cipher_top(clk, rst, ld, done, key, text_in, text_out);

input		clk, rst;
input		ld;
output		done;
input	[127:0]	key;
input	[127:0]	text_in;
output	[127:0]	text_out;


reg	[127:0]	text_in_r;
reg	[127:0]	text_out;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

wire	[31:0]	w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18, w19, w20, w21, w22,
               w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33, w34, w35, w36, w37, w38, w39, w40, w41, w42, w43;
					
reg	[127:0]	text_out_temp;

//round 1 wires
reg	[7:0]	sa00, sa01, sa02, sa03;
reg	[7:0]	sa10, sa11, sa12, sa13;
reg	[7:0]	sa20, sa21, sa22, sa23;
reg	[7:0]	sa30, sa31, sa32, sa33;

wire	[7:0]	sa00_next, sa01_next, sa02_next, sa03_next;
wire	[7:0]	sa10_next, sa11_next, sa12_next, sa13_next;
wire	[7:0]	sa20_next, sa21_next, sa22_next, sa23_next;
wire	[7:0]	sa30_next, sa31_next, sa32_next, sa33_next;

wire	[7:0]	sa00_sub, sa01_sub, sa02_sub, sa03_sub;
wire	[7:0]	sa10_sub, sa11_sub, sa12_sub, sa13_sub;
wire  [7:0]	sa20_sub, sa21_sub, sa22_sub, sa23_sub;
wire	[7:0]	sa30_sub, sa31_sub, sa32_sub, sa33_sub;

wire	[7:0]	sa00_sr, sa01_sr, sa02_sr, sa03_sr;
wire	[7:0]	sa10_sr, sa11_sr, sa12_sr, sa13_sr;
wire	[7:0]	sa20_sr, sa21_sr, sa22_sr, sa23_sr;
wire	[7:0]	sa30_sr, sa31_sr, sa32_sr, sa33_sr;

wire	[7:0]	sa00_mc, sa01_mc, sa02_mc, sa03_mc;
wire	[7:0]	sa10_mc, sa11_mc, sa12_mc, sa13_mc;
wire	[7:0]	sa20_mc, sa21_mc, sa22_mc, sa23_mc;
wire	[7:0]	sa30_mc, sa31_mc, sa32_mc, sa33_mc;


//round2 wires
wire	[7:0]	sa00_next_round2, sa01_next_round2, sa02_next_round2, sa03_next_round2;
wire	[7:0]	sa10_next_round2, sa11_next_round2, sa12_next_round2, sa13_next_round2;
wire	[7:0]	sa20_next_round2, sa21_next_round2, sa22_next_round2, sa23_next_round2;
wire	[7:0]	sa30_next_round2, sa31_next_round2, sa32_next_round2, sa33_next_round2;

wire	[7:0]	sa00_sub_round2, sa01_sub_round2, sa02_sub_round2, sa03_sub_round2;
wire	[7:0]	sa10_sub_round2, sa11_sub_round2, sa12_sub_round2, sa13_sub_round2;
wire  [7:0]	sa20_sub_round2, sa21_sub_round2, sa22_sub_round2, sa23_sub_round2;
wire	[7:0]	sa30_sub_round2, sa31_sub_round2, sa32_sub_round2, sa33_sub_round2;

wire	[7:0]	sa00_sr_round2, sa01_sr_round2, sa02_sr_round2, sa03_sr_round2;
wire	[7:0]	sa10_sr_round2, sa11_sr_round2, sa12_sr_round2, sa13_sr_round2;
wire	[7:0]	sa20_sr_round2, sa21_sr_round2, sa22_sr_round2, sa23_sr_round2;
wire	[7:0]	sa30_sr_round2, sa31_sr_round2, sa32_sr_round2, sa33_sr_round2;

wire	[7:0]	sa00_mc_round2, sa01_mc_round2, sa02_mc_round2, sa03_mc_round2;
wire	[7:0]	sa10_mc_round2, sa11_mc_round2, sa12_mc_round2, sa13_mc_round2;
wire	[7:0]	sa20_mc_round2, sa21_mc_round2, sa22_mc_round2, sa23_mc_round2;
wire	[7:0]	sa30_mc_round2, sa31_mc_round2, sa32_mc_round2, sa33_mc_round2;


//round3 wires
wire	[7:0]	sa00_next_round3, sa01_next_round3, sa02_next_round3, sa03_next_round3;
wire	[7:0]	sa10_next_round3, sa11_next_round3, sa12_next_round3, sa13_next_round3;
wire	[7:0]	sa20_next_round3, sa21_next_round3, sa22_next_round3, sa23_next_round3;
wire	[7:0]	sa30_next_round3, sa31_next_round3, sa32_next_round3, sa33_next_round3;

wire	[7:0]	sa00_sub_round3, sa01_sub_round3, sa02_sub_round3, sa03_sub_round3;
wire	[7:0]	sa10_sub_round3, sa11_sub_round3, sa12_sub_round3, sa13_sub_round3;
wire  [7:0]	sa20_sub_round3, sa21_sub_round3, sa22_sub_round3, sa23_sub_round3;
wire	[7:0]	sa30_sub_round3, sa31_sub_round3, sa32_sub_round3, sa33_sub_round3;

wire	[7:0]	sa00_sr_round3, sa01_sr_round3, sa02_sr_round3, sa03_sr_round3;
wire	[7:0]	sa10_sr_round3, sa11_sr_round3, sa12_sr_round3, sa13_sr_round3;
wire	[7:0]	sa20_sr_round3, sa21_sr_round3, sa22_sr_round3, sa23_sr_round3;
wire	[7:0]	sa30_sr_round3, sa31_sr_round3, sa32_sr_round3, sa33_sr_round3;

wire	[7:0]	sa00_mc_round3, sa01_mc_round3, sa02_mc_round3, sa03_mc_round3;
wire	[7:0]	sa10_mc_round3, sa11_mc_round3, sa12_mc_round3, sa13_mc_round3;
wire	[7:0]	sa20_mc_round3, sa21_mc_round3, sa22_mc_round3, sa23_mc_round3;
wire	[7:0]	sa30_mc_round3, sa31_mc_round3, sa32_mc_round3, sa33_mc_round3;



//round4 wires
wire	[7:0]	sa00_next_round4, sa01_next_round4, sa02_next_round4, sa03_next_round4;
wire	[7:0]	sa10_next_round4, sa11_next_round4, sa12_next_round4, sa13_next_round4;
wire	[7:0]	sa20_next_round4, sa21_next_round4, sa22_next_round4, sa23_next_round4;
wire	[7:0]	sa30_next_round4, sa31_next_round4, sa32_next_round4, sa33_next_round4;

wire	[7:0]	sa00_sub_round4, sa01_sub_round4, sa02_sub_round4, sa03_sub_round4;
wire	[7:0]	sa10_sub_round4, sa11_sub_round4, sa12_sub_round4, sa13_sub_round4;
wire  [7:0]	sa20_sub_round4, sa21_sub_round4, sa22_sub_round4, sa23_sub_round4;
wire	[7:0]	sa30_sub_round4, sa31_sub_round4, sa32_sub_round4, sa33_sub_round4;

wire	[7:0]	sa00_sr_round4, sa01_sr_round4, sa02_sr_round4, sa03_sr_round4;
wire	[7:0]	sa10_sr_round4, sa11_sr_round4, sa12_sr_round4, sa13_sr_round4;
wire	[7:0]	sa20_sr_round4, sa21_sr_round4, sa22_sr_round4, sa23_sr_round4;
wire	[7:0]	sa30_sr_round4, sa31_sr_round4, sa32_sr_round4, sa33_sr_round4;

wire	[7:0]	sa00_mc_round4, sa01_mc_round4, sa02_mc_round4, sa03_mc_round4;
wire	[7:0]	sa10_mc_round4, sa11_mc_round4, sa12_mc_round4, sa13_mc_round4;
wire	[7:0]	sa20_mc_round4, sa21_mc_round4, sa22_mc_round4, sa23_mc_round4;
wire	[7:0]	sa30_mc_round4, sa31_mc_round4, sa32_mc_round4, sa33_mc_round4;

//round5 wires
wire	[7:0]	sa00_next_round5, sa01_next_round5, sa02_next_round5, sa03_next_round5;
wire	[7:0]	sa10_next_round5, sa11_next_round5, sa12_next_round5, sa13_next_round5;
wire	[7:0]	sa20_next_round5, sa21_next_round5, sa22_next_round5, sa23_next_round5;
wire	[7:0]	sa30_next_round5, sa31_next_round5, sa32_next_round5, sa33_next_round5;

wire	[7:0]	sa00_sub_round5, sa01_sub_round5, sa02_sub_round5, sa03_sub_round5;
wire	[7:0]	sa10_sub_round5, sa11_sub_round5, sa12_sub_round5, sa13_sub_round5;
wire  [7:0]	sa20_sub_round5, sa21_sub_round5, sa22_sub_round5, sa23_sub_round5;
wire	[7:0]	sa30_sub_round5, sa31_sub_round5, sa32_sub_round5, sa33_sub_round5;

wire	[7:0]	sa00_sr_round5, sa01_sr_round5, sa02_sr_round5, sa03_sr_round5;
wire	[7:0]	sa10_sr_round5, sa11_sr_round5, sa12_sr_round5, sa13_sr_round5;
wire	[7:0]	sa20_sr_round5, sa21_sr_round5, sa22_sr_round5, sa23_sr_round5;
wire	[7:0]	sa30_sr_round5, sa31_sr_round5, sa32_sr_round5, sa33_sr_round5;

wire	[7:0]	sa00_mc_round5, sa01_mc_round5, sa02_mc_round5, sa03_mc_round5;
wire	[7:0]	sa10_mc_round5, sa11_mc_round5, sa12_mc_round5, sa13_mc_round5;
wire	[7:0]	sa20_mc_round5, sa21_mc_round5, sa22_mc_round5, sa23_mc_round5;
wire	[7:0]	sa30_mc_round5, sa31_mc_round5, sa32_mc_round5, sa33_mc_round5;


//round6 wires
wire	[7:0]	sa00_next_round6, sa01_next_round6, sa02_next_round6, sa03_next_round6;
wire	[7:0]	sa10_next_round6, sa11_next_round6, sa12_next_round6, sa13_next_round6;
wire	[7:0]	sa20_next_round6, sa21_next_round6, sa22_next_round6, sa23_next_round6;
wire	[7:0]	sa30_next_round6, sa31_next_round6, sa32_next_round6, sa33_next_round6;

wire	[7:0]	sa00_sub_round6, sa01_sub_round6, sa02_sub_round6, sa03_sub_round6;
wire	[7:0]	sa10_sub_round6, sa11_sub_round6, sa12_sub_round6, sa13_sub_round6;
wire  [7:0]	sa20_sub_round6, sa21_sub_round6, sa22_sub_round6, sa23_sub_round6;
wire	[7:0]	sa30_sub_round6, sa31_sub_round6, sa32_sub_round6, sa33_sub_round6;

wire	[7:0]	sa00_sr_round6, sa01_sr_round6, sa02_sr_round6, sa03_sr_round6;
wire	[7:0]	sa10_sr_round6, sa11_sr_round6, sa12_sr_round6, sa13_sr_round6;
wire	[7:0]	sa20_sr_round6, sa21_sr_round6, sa22_sr_round6, sa23_sr_round6;
wire	[7:0]	sa30_sr_round6, sa31_sr_round6, sa32_sr_round6, sa33_sr_round6;

wire	[7:0]	sa00_mc_round6, sa01_mc_round6, sa02_mc_round6, sa03_mc_round6;
wire	[7:0]	sa10_mc_round6, sa11_mc_round6, sa12_mc_round6, sa13_mc_round6;
wire	[7:0]	sa20_mc_round6, sa21_mc_round6, sa22_mc_round6, sa23_mc_round6;
wire	[7:0]	sa30_mc_round6, sa31_mc_round6, sa32_mc_round6, sa33_mc_round6;


//round7 wires
wire	[7:0]	sa00_next_round7, sa01_next_round7, sa02_next_round7, sa03_next_round7;
wire	[7:0]	sa10_next_round7, sa11_next_round7, sa12_next_round7, sa13_next_round7;
wire	[7:0]	sa20_next_round7, sa21_next_round7, sa22_next_round7, sa23_next_round7;
wire	[7:0]	sa30_next_round7, sa31_next_round7, sa32_next_round7, sa33_next_round7;

wire	[7:0]	sa00_sub_round7, sa01_sub_round7, sa02_sub_round7, sa03_sub_round7;
wire	[7:0]	sa10_sub_round7, sa11_sub_round7, sa12_sub_round7, sa13_sub_round7;
wire  [7:0]	sa20_sub_round7, sa21_sub_round7, sa22_sub_round7, sa23_sub_round7;
wire	[7:0]	sa30_sub_round7, sa31_sub_round7, sa32_sub_round7, sa33_sub_round7;

wire	[7:0]	sa00_sr_round7, sa01_sr_round7, sa02_sr_round7, sa03_sr_round7;
wire	[7:0]	sa10_sr_round7, sa11_sr_round7, sa12_sr_round7, sa13_sr_round7;
wire	[7:0]	sa20_sr_round7, sa21_sr_round7, sa22_sr_round7, sa23_sr_round7;
wire	[7:0]	sa30_sr_round7, sa31_sr_round7, sa32_sr_round7, sa33_sr_round7;

wire	[7:0]	sa00_mc_round7, sa01_mc_round7, sa02_mc_round7, sa03_mc_round7;
wire	[7:0]	sa10_mc_round7, sa11_mc_round7, sa12_mc_round7, sa13_mc_round7;
wire	[7:0]	sa20_mc_round7, sa21_mc_round7, sa22_mc_round7, sa23_mc_round7;
wire	[7:0]	sa30_mc_round7, sa31_mc_round7, sa32_mc_round7, sa33_mc_round7;


//round8 wires
wire	[7:0]	sa00_next_round8, sa01_next_round8, sa02_next_round8, sa03_next_round8;
wire	[7:0]	sa10_next_round8, sa11_next_round8, sa12_next_round8, sa13_next_round8;
wire	[7:0]	sa20_next_round8, sa21_next_round8, sa22_next_round8, sa23_next_round8;
wire	[7:0]	sa30_next_round8, sa31_next_round8, sa32_next_round8, sa33_next_round8;

wire	[7:0]	sa00_sub_round8, sa01_sub_round8, sa02_sub_round8, sa03_sub_round8;
wire	[7:0]	sa10_sub_round8, sa11_sub_round8, sa12_sub_round8, sa13_sub_round8;
wire  [7:0]	sa20_sub_round8, sa21_sub_round8, sa22_sub_round8, sa23_sub_round8;
wire	[7:0]	sa30_sub_round8, sa31_sub_round8, sa32_sub_round8, sa33_sub_round8;

wire	[7:0]	sa00_sr_round8, sa01_sr_round8, sa02_sr_round8, sa03_sr_round8;
wire	[7:0]	sa10_sr_round8, sa11_sr_round8, sa12_sr_round8, sa13_sr_round8;
wire	[7:0]	sa20_sr_round8, sa21_sr_round8, sa22_sr_round8, sa23_sr_round8;
wire	[7:0]	sa30_sr_round8, sa31_sr_round8, sa32_sr_round8, sa33_sr_round8;

wire	[7:0]	sa00_mc_round8, sa01_mc_round8, sa02_mc_round8, sa03_mc_round8;
wire	[7:0]	sa10_mc_round8, sa11_mc_round8, sa12_mc_round8, sa13_mc_round8;
wire	[7:0]	sa20_mc_round8, sa21_mc_round8, sa22_mc_round8, sa23_mc_round8;
wire	[7:0]	sa30_mc_round8, sa31_mc_round8, sa32_mc_round8, sa33_mc_round8;


//round9 wires
wire	[7:0]	sa00_next_round9, sa01_next_round9, sa02_next_round9, sa03_next_round9;
wire	[7:0]	sa10_next_round9, sa11_next_round9, sa12_next_round9, sa13_next_round9;
wire	[7:0]	sa20_next_round9, sa21_next_round9, sa22_next_round9, sa23_next_round9;
wire	[7:0]	sa30_next_round9, sa31_next_round9, sa32_next_round9, sa33_next_round9;

wire	[7:0]	sa00_sub_round9, sa01_sub_round9, sa02_sub_round9, sa03_sub_round9;
wire	[7:0]	sa10_sub_round9, sa11_sub_round9, sa12_sub_round9, sa13_sub_round9;
wire  [7:0]	sa20_sub_round9, sa21_sub_round9, sa22_sub_round9, sa23_sub_round9;
wire	[7:0]	sa30_sub_round9, sa31_sub_round9, sa32_sub_round9, sa33_sub_round9;

wire	[7:0]	sa00_sr_round9, sa01_sr_round9, sa02_sr_round9, sa03_sr_round9;
wire	[7:0]	sa10_sr_round9, sa11_sr_round9, sa12_sr_round9, sa13_sr_round9;
wire	[7:0]	sa20_sr_round9, sa21_sr_round9, sa22_sr_round9, sa23_sr_round9;
wire	[7:0]	sa30_sr_round9, sa31_sr_round9, sa32_sr_round9, sa33_sr_round9;

wire	[7:0]	sa00_mc_round9, sa01_mc_round9, sa02_mc_round9, sa03_mc_round9;
wire	[7:0]	sa10_mc_round9, sa11_mc_round9, sa12_mc_round9, sa13_mc_round9;
wire	[7:0]	sa20_mc_round9, sa21_mc_round9, sa22_mc_round9, sa23_mc_round9;
wire	[7:0]	sa30_mc_round9, sa31_mc_round9, sa32_mc_round9, sa33_mc_round9;


//round10 wires
wire	[7:0]	sa00_next_round10, sa01_next_round10, sa02_next_round10, sa03_next_round10;
wire	[7:0]	sa10_next_round10, sa11_next_round10, sa12_next_round10, sa13_next_round10;
wire	[7:0]	sa20_next_round10, sa21_next_round10, sa22_next_round10, sa23_next_round10;
wire	[7:0]	sa30_next_round10, sa31_next_round10, sa32_next_round10, sa33_next_round10;

wire	[7:0]	sa00_sub_round10, sa01_sub_round10, sa02_sub_round10, sa03_sub_round10;
wire	[7:0]	sa10_sub_round10, sa11_sub_round10, sa12_sub_round10, sa13_sub_round10;
wire  [7:0]	sa20_sub_round10, sa21_sub_round10, sa22_sub_round10, sa23_sub_round10;
wire	[7:0]	sa30_sub_round10, sa31_sub_round10, sa32_sub_round10, sa33_sub_round10;

wire	[7:0]	sa00_sr_round10, sa01_sr_round10, sa02_sr_round10, sa03_sr_round10;
wire	[7:0]	sa10_sr_round10, sa11_sr_round10, sa12_sr_round10, sa13_sr_round10;
wire	[7:0]	sa20_sr_round10, sa21_sr_round10, sa22_sr_round10, sa23_sr_round10;
wire	[7:0]	sa30_sr_round10, sa31_sr_round10, sa32_sr_round10, sa33_sr_round10;



reg		done, ld_r;
reg	[3:0]	dcnt;
reg 		done2;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

always @(posedge clk)
begin
	if(~rst)	begin dcnt <=  4'h0;	 end
	else
	if(ld)	begin	dcnt <=  4'h2;	 end
	else
	if(|dcnt) begin	dcnt <=  dcnt - 4'h1;  end

end

always @(posedge clk) done <=  !(|dcnt[3:1]) & dcnt[0] & !ld;
always @(posedge clk) if(ld) text_in_r <=  text_in;
always @(posedge clk) ld_r <=  ld;



////////////////////////////////////////////////////////////////////
// key expansion


aes_key_expand_128 u0(
	.clk(		clk	),
	.key(		key	),
	.w0(		w0	),
	.w1(		w1	),
	.w2(		w2	),
	.w3(		w3	),
	.w4(		w4	),
	.w5(		w5	),
	.w6(		w6	),
	.w7(		w7	),
	.w8(		w8	),
	.w9(		w9	),
	.w10(		w10	),
	.w11(		w11	),
	.w12(		w12	),
	.w13(		w13	),
	.w14(		w14	),
	.w15(		w15	),
	.w16(		w16	),
	.w17(		w17	),
	.w18(		w18	),
	.w19(		w19	),	
	.w20(		w20	),
	.w21(		w21	),
	.w22(		w22	),
	.w23(		w23	),
	.w24(		w24	),
	.w25(		w25	),
	.w26(		w26	),
	.w27(		w27	),
	.w28(		w28	),
	.w29(		w29	),
	.w30(		w30	),
	.w31(		w31	),
	.w32(		w32	),
	.w33(		w33	),
	.w34(		w34	),
	.w35(		w35	),
	.w36(		w36	),
	.w37(		w37	),
	.w38(		w38	),
	.w39(		w39	),
	.w40(		w40	),
	.w41(		w41	),
	.w42(		w42	),
	.w43(		w43	)
					);

always @(posedge clk) 
begin
   	sa33 <=   text_in_r[007:000] ^ w3[07:00]; //sa33_mc_round2 ^ w3[07:00];
    	sa23 <=   text_in_r[015:008] ^ w3[15:08]; //sa23_mc_round2 ^ w3[15:08];
    	sa13 <=   text_in_r[023:016] ^ w3[23:16]; //sa13_mc_round2 ^ w3[23:16];
    	sa03 <=   text_in_r[031:024] ^ w3[31:24]; //sa03_mc_round2 ^ w3[31:24];
    	sa32 <=   text_in_r[039:032] ^ w2[07:00]; //sa32_mc_round2 ^ w2[07:00];
    	sa22 <=   text_in_r[047:040] ^ w2[15:08]; //sa22_mc_round2 ^ w2[15:08];
    	sa12 <=   text_in_r[055:048] ^ w2[23:16]; //sa12_mc_round2 ^ w2[23:16];
    	sa02 <=   text_in_r[063:056] ^ w2[31:24]; //sa02_mc_round2 ^ w2[31:24];
    	sa31 <=   text_in_r[071:064] ^ w1[07:00]; //sa31_mc_round2 ^ w1[07:00];
    	sa21 <=   text_in_r[079:072] ^ w1[15:08]; //sa21_mc_round2 ^ w1[15:08];
    	sa11 <=   text_in_r[087:080] ^ w1[23:16]; //sa11_mc_round2 ^ w1[23:16];
    	sa01 <=   text_in_r[095:088] ^ w1[31:24]; //sa01_mc_round2 ^ w1[31:24];
    	sa30 <=   text_in_r[103:096] ^ w0[07:00]; //sa30_mc_round2 ^ w0[07:00];
    	sa20 <=   text_in_r[111:104] ^ w0[15:08]; //sa20_mc_round2 ^ w0[15:08];
    	sa10 <=   text_in_r[119:112] ^ w0[23:16]; //sa10_mc_round2 ^ w0[23:16];
    	sa00 <=   text_in_r[127:120] ^ w0[31:24]; //sa00_mc_round2 ^ w0[31:24];
				
end


//sbox lookup
aes_sbox us00(	.a(	sa00	), .d(	sa00_sub	));
aes_sbox us01(	.a(	sa01	), .d(	sa01_sub	));
aes_sbox us02(	.a(	sa02	), .d(	sa02_sub	));
aes_sbox us03(	.a(	sa03	), .d(	sa03_sub	));
aes_sbox us10(	.a(	sa10	), .d(	sa10_sub	));
aes_sbox us11(	.a(	sa11	), .d(	sa11_sub	));
aes_sbox us12(	.a(	sa12	), .d(	sa12_sub	));
aes_sbox us13(	.a(	sa13	), .d(	sa13_sub	));
aes_sbox us20(	.a(	sa20	), .d(	sa20_sub	));
aes_sbox us21(	.a(	sa21	), .d(	sa21_sub	));
aes_sbox us22(	.a(	sa22	), .d(	sa22_sub	));
aes_sbox us23(	.a(	sa23	), .d(	sa23_sub	));
aes_sbox us30(	.a(	sa30	), .d(	sa30_sub	));
aes_sbox us31(	.a(	sa31	), .d(	sa31_sub	));
aes_sbox us32(	.a(	sa32	), .d(	sa32_sub	));
aes_sbox us33(	.a(	sa33	), .d(	sa33_sub	));

//shift rows

assign sa00_sr = sa00_sub;		//
assign sa01_sr = sa01_sub;		//no shift
assign sa02_sr = sa02_sub;		//
assign sa03_sr = sa03_sub;		//

assign sa10_sr = sa11_sub;		//
assign sa11_sr = sa12_sub;		// left shift by 1
assign sa12_sr = sa13_sub;		//
assign sa13_sr = sa10_sub;		//

assign sa20_sr = sa22_sub;		//
assign sa21_sr = sa23_sub;		//	left shift by 2
assign sa22_sr = sa20_sub;		//
assign sa23_sr = sa21_sub;		//

assign sa30_sr = sa33_sub;		//
assign sa31_sr = sa30_sub;		// left shift by 3
assign sa32_sr = sa31_sub;		//
assign sa33_sr = sa32_sub;		//

// mix column operation
assign {sa00_mc, sa10_mc, sa20_mc, sa30_mc}  = mix_col(sa00_sr,sa10_sr,sa20_sr,sa30_sr);
assign {sa01_mc, sa11_mc, sa21_mc, sa31_mc}  = mix_col(sa01_sr,sa11_sr,sa21_sr,sa31_sr);
assign {sa02_mc, sa12_mc, sa22_mc, sa32_mc}  = mix_col(sa02_sr,sa12_sr,sa22_sr,sa32_sr);
assign {sa03_mc, sa13_mc, sa23_mc, sa33_mc}  = mix_col(sa03_sr,sa13_sr,sa23_sr,sa33_sr);

//// add round key
assign sa00_next_round2 = sa00_mc ^ w4[31:24];		
assign sa01_next_round2 = sa01_mc ^ w5[31:24];
assign sa02_next_round2 = sa02_mc ^ w6[31:24];
assign sa03_next_round2 = sa03_mc ^ w7[31:24];
assign sa10_next_round2 = sa10_mc ^ w4[23:16];
assign sa11_next_round2 = sa11_mc ^ w5[23:16];
assign sa12_next_round2 = sa12_mc ^ w6[23:16];
assign sa13_next_round2 = sa13_mc ^ w7[23:16];
assign sa20_next_round2 = sa20_mc ^ w4[15:08];
assign sa21_next_round2 = sa21_mc ^ w5[15:08];
assign sa22_next_round2 = sa22_mc ^ w6[15:08];
assign sa23_next_round2 = sa23_mc ^ w7[15:08];
assign sa30_next_round2 = sa30_mc ^ w4[07:00];
assign sa31_next_round2 = sa31_mc ^ w5[07:00];
assign sa32_next_round2 = sa32_mc ^ w6[07:00];
assign sa33_next_round2 = sa33_mc ^ w7[07:00];



//////////////////////  round 2 //////////////////////////////////

//sbox lookup
aes_sbox us00_round2(	.a(	sa00_next_round2	), .d(	sa00_sub_round2	));
aes_sbox us01_round2(	.a(	sa01_next_round2	), .d(	sa01_sub_round2	));
aes_sbox us02_round2(	.a(	sa02_next_round2	), .d(	sa02_sub_round2	));
aes_sbox us03_round2(	.a(	sa03_next_round2	), .d(	sa03_sub_round2	));
aes_sbox us10_round2(	.a(	sa10_next_round2	), .d(	sa10_sub_round2	));
aes_sbox us11_round2(	.a(	sa11_next_round2	), .d(	sa11_sub_round2	));
aes_sbox us12_round2(	.a(	sa12_next_round2	), .d(	sa12_sub_round2	));
aes_sbox us13_round2(	.a(	sa13_next_round2	), .d(	sa13_sub_round2	));
aes_sbox us20_round2(	.a(	sa20_next_round2	), .d(	sa20_sub_round2	));
aes_sbox us21_round2(	.a(	sa21_next_round2	), .d(	sa21_sub_round2	));
aes_sbox us22_round2(	.a(	sa22_next_round2	), .d(	sa22_sub_round2	));
aes_sbox us23_round2(	.a(	sa23_next_round2	), .d(	sa23_sub_round2	));
aes_sbox us30_round2(	.a(	sa30_next_round2	), .d(	sa30_sub_round2	));
aes_sbox us31_round2(	.a(	sa31_next_round2	), .d(	sa31_sub_round2	));
aes_sbox us32_round2(	.a(	sa32_next_round2	), .d(	sa32_sub_round2	));
aes_sbox us33_round2(	.a(	sa33_next_round2	), .d(	sa33_sub_round2	));

//shift rows

assign sa00_sr_round2 = sa00_sub_round2;		//
assign sa01_sr_round2 = sa01_sub_round2;		//no shift
assign sa02_sr_round2 = sa02_sub_round2;		//
assign sa03_sr_round2 = sa03_sub_round2;		//

assign sa10_sr_round2 = sa11_sub_round2;		//
assign sa11_sr_round2 = sa12_sub_round2;		// left shift by 1
assign sa12_sr_round2 = sa13_sub_round2;		//
assign sa13_sr_round2 = sa10_sub_round2;		//

assign sa20_sr_round2 = sa22_sub_round2;		//
assign sa21_sr_round2 = sa23_sub_round2;		//	left shift by 2
assign sa22_sr_round2 = sa20_sub_round2;		//
assign sa23_sr_round2 = sa21_sub_round2;		//

assign sa30_sr_round2 = sa33_sub_round2;		//
assign sa31_sr_round2 = sa30_sub_round2;		// left shift by 3
assign sa32_sr_round2 = sa31_sub_round2;		//
assign sa33_sr_round2 = sa32_sub_round2;		//

// mix column operation
assign {sa00_mc_round2, sa10_mc_round2, sa20_mc_round2, sa30_mc_round2}  = mix_col(sa00_sr_round2,sa10_sr_round2,sa20_sr_round2,sa30_sr_round2);
assign {sa01_mc_round2, sa11_mc_round2, sa21_mc_round2, sa31_mc_round2}  = mix_col(sa01_sr_round2,sa11_sr_round2,sa21_sr_round2,sa31_sr_round2);
assign {sa02_mc_round2, sa12_mc_round2, sa22_mc_round2, sa32_mc_round2}  = mix_col(sa02_sr_round2,sa12_sr_round2,sa22_sr_round2,sa32_sr_round2);
assign {sa03_mc_round2, sa13_mc_round2, sa23_mc_round2, sa33_mc_round2}  = mix_col(sa03_sr_round2,sa13_sr_round2,sa23_sr_round2,sa33_sr_round2);

//add round key
assign sa33_next_round3 = 		   sa33_mc_round2 ^ w11[07:00];
assign sa23_next_round3 =     	sa23_mc_round2 ^ w11[15:08];
assign sa13_next_round3 =     	sa13_mc_round2 ^ w11[23:16];
assign sa03_next_round3 =     	sa03_mc_round2 ^ w11[31:24];
assign sa32_next_round3 =     	sa32_mc_round2 ^ w10[07:00];
assign sa22_next_round3 =     	sa22_mc_round2 ^ w10[15:08];
assign sa12_next_round3 =     	sa12_mc_round2 ^ w10[23:16];
assign sa02_next_round3 =     	sa02_mc_round2 ^ w10[31:24];
assign sa31_next_round3 =     	sa31_mc_round2 ^ w9[07:00];
assign sa21_next_round3 =     	sa21_mc_round2 ^ w9[15:08];
assign sa11_next_round3 =     	sa11_mc_round2 ^ w9[23:16];
assign sa01_next_round3 =     	sa01_mc_round2 ^ w9[31:24];
assign sa30_next_round3 =     	sa30_mc_round2 ^ w8[07:00];
assign sa20_next_round3 =     	sa20_mc_round2 ^ w8[15:08];
assign sa10_next_round3 =     	sa10_mc_round2 ^ w8[23:16];
assign sa00_next_round3 =     	sa00_mc_round2 ^ w8[31:24];


/////////////////////////round #3 transformations/////////////////////////////


//sbox lookup
aes_sbox us00_round3(	.a(	sa00_next_round3	), .d(	sa00_sub_round3	));
aes_sbox us01_round3(	.a(	sa01_next_round3	), .d(	sa01_sub_round3	));
aes_sbox us02_round3(	.a(	sa02_next_round3	), .d(	sa02_sub_round3	));
aes_sbox us03_round3(	.a(	sa03_next_round3	), .d(	sa03_sub_round3	));
aes_sbox us10_round3(	.a(	sa10_next_round3	), .d(	sa10_sub_round3	));
aes_sbox us11_round3(	.a(	sa11_next_round3	), .d(	sa11_sub_round3	));
aes_sbox us12_round3(	.a(	sa12_next_round3	), .d(	sa12_sub_round3	));
aes_sbox us13_round3(	.a(	sa13_next_round3	), .d(	sa13_sub_round3	));
aes_sbox us20_round3(	.a(	sa20_next_round3	), .d(	sa20_sub_round3	));
aes_sbox us21_round3(	.a(	sa21_next_round3	), .d(	sa21_sub_round3	));
aes_sbox us22_round3(	.a(	sa22_next_round3	), .d(	sa22_sub_round3	));
aes_sbox us23_round3(	.a(	sa23_next_round3	), .d(	sa23_sub_round3	));
aes_sbox us30_round3(	.a(	sa30_next_round3	), .d(	sa30_sub_round3	));
aes_sbox us31_round3(	.a(	sa31_next_round3	), .d(	sa31_sub_round3	));
aes_sbox us32_round3(	.a(	sa32_next_round3	), .d(	sa32_sub_round3	));
aes_sbox us33_round3(	.a(	sa33_next_round3	), .d(	sa33_sub_round3	));

//shift rows

assign sa00_sr_round3 = sa00_sub_round3;		//
assign sa01_sr_round3 = sa01_sub_round3;		//no shift
assign sa02_sr_round3 = sa02_sub_round3;		//
assign sa03_sr_round3 = sa03_sub_round3;		//

assign sa10_sr_round3 = sa11_sub_round3;		//
assign sa11_sr_round3 = sa12_sub_round3;		// left shift by 1
assign sa12_sr_round3 = sa13_sub_round3;		//
assign sa13_sr_round3 = sa10_sub_round3;		//

assign sa20_sr_round3 = sa22_sub_round3;		//
assign sa21_sr_round3 = sa23_sub_round3;		//	left shift by 2
assign sa22_sr_round3 = sa20_sub_round3;		//
assign sa23_sr_round3 = sa21_sub_round3;		//

assign sa30_sr_round3 = sa33_sub_round3;		//
assign sa31_sr_round3 = sa30_sub_round3;		// left shift by 3
assign sa32_sr_round3 = sa31_sub_round3;		//
assign sa33_sr_round3 = sa32_sub_round3;		//

// mix column operation
assign {sa00_mc_round3, sa10_mc_round3, sa20_mc_round3, sa30_mc_round3}  = mix_col(sa00_sr_round3,sa10_sr_round3,sa20_sr_round3,sa30_sr_round3);
assign {sa01_mc_round3, sa11_mc_round3, sa21_mc_round3, sa31_mc_round3}  = mix_col(sa01_sr_round3,sa11_sr_round3,sa21_sr_round3,sa31_sr_round3);
assign {sa02_mc_round3, sa12_mc_round3, sa22_mc_round3, sa32_mc_round3}  = mix_col(sa02_sr_round3,sa12_sr_round3,sa22_sr_round3,sa32_sr_round3);
assign {sa03_mc_round3, sa13_mc_round3, sa23_mc_round3, sa33_mc_round3}  = mix_col(sa03_sr_round3,sa13_sr_round3,sa23_sr_round3,sa33_sr_round3);


//add round key
assign sa33_next_round4 = 		   sa33_mc_round3 ^ w15[07:00];
assign sa23_next_round4 =     	sa23_mc_round3 ^ w15[15:08];
assign sa13_next_round4 =     	sa13_mc_round3 ^ w15[23:16];
assign sa03_next_round4 =     	sa03_mc_round3 ^ w15[31:24];
assign sa32_next_round4 =     	sa32_mc_round3 ^ w14[07:00];
assign sa22_next_round4 =     	sa22_mc_round3 ^ w14[15:08];
assign sa12_next_round4 =     	sa12_mc_round3 ^ w14[23:16];
assign sa02_next_round4 =     	sa02_mc_round3 ^ w14[31:24];
assign sa31_next_round4 =     	sa31_mc_round3 ^ w13[07:00];
assign sa21_next_round4 =     	sa21_mc_round3 ^ w13[15:08];
assign sa11_next_round4 =     	sa11_mc_round3 ^ w13[23:16];
assign sa01_next_round4 =     	sa01_mc_round3 ^ w13[31:24];
assign sa30_next_round4 =     	sa30_mc_round3 ^ w12[07:00];
assign sa20_next_round4 =     	sa20_mc_round3 ^ w12[15:08];
assign sa10_next_round4 =     	sa10_mc_round3 ^ w12[23:16];
assign sa00_next_round4 =     	sa00_mc_round3 ^ w12[31:24];

/////////////////////////round #4 transformations/////////////////////////////


//sbox lookup
aes_sbox us00_round4(	.a(	sa00_next_round4	), .d(	sa00_sub_round4	));
aes_sbox us01_round4(	.a(	sa01_next_round4	), .d(	sa01_sub_round4	));
aes_sbox us02_round4(	.a(	sa02_next_round4	), .d(	sa02_sub_round4	));
aes_sbox us03_round4(	.a(	sa03_next_round4	), .d(	sa03_sub_round4	));
aes_sbox us10_round4(	.a(	sa10_next_round4	), .d(	sa10_sub_round4	));
aes_sbox us11_round4(	.a(	sa11_next_round4	), .d(	sa11_sub_round4	));
aes_sbox us12_round4(	.a(	sa12_next_round4	), .d(	sa12_sub_round4	));
aes_sbox us13_round4(	.a(	sa13_next_round4	), .d(	sa13_sub_round4	));
aes_sbox us20_round4(	.a(	sa20_next_round4	), .d(	sa20_sub_round4	));
aes_sbox us21_round4(	.a(	sa21_next_round4	), .d(	sa21_sub_round4	));
aes_sbox us22_round4(	.a(	sa22_next_round4	), .d(	sa22_sub_round4	));
aes_sbox us23_round4(	.a(	sa23_next_round4	), .d(	sa23_sub_round4	));
aes_sbox us30_round4(	.a(	sa30_next_round4	), .d(	sa30_sub_round4	));
aes_sbox us31_round4(	.a(	sa31_next_round4	), .d(	sa31_sub_round4	));
aes_sbox us32_round4(	.a(	sa32_next_round4	), .d(	sa32_sub_round4	));
aes_sbox us33_round4(	.a(	sa33_next_round4	), .d(	sa33_sub_round4	));

//shift rows

assign sa00_sr_round4 = sa00_sub_round4;		//
assign sa01_sr_round4 = sa01_sub_round4;		//no shift
assign sa02_sr_round4 = sa02_sub_round4;		//
assign sa03_sr_round4 = sa03_sub_round4;		//

assign sa10_sr_round4 = sa11_sub_round4;		//
assign sa11_sr_round4 = sa12_sub_round4;		// left shift by 1
assign sa12_sr_round4 = sa13_sub_round4;		//
assign sa13_sr_round4 = sa10_sub_round4;		//

assign sa20_sr_round4 = sa22_sub_round4;		//
assign sa21_sr_round4 = sa23_sub_round4;		//	left shift by 2
assign sa22_sr_round4 = sa20_sub_round4;		//
assign sa23_sr_round4 = sa21_sub_round4;		//

assign sa30_sr_round4 = sa33_sub_round4;		//
assign sa31_sr_round4 = sa30_sub_round4;		// left shift by 3
assign sa32_sr_round4 = sa31_sub_round4;		//
assign sa33_sr_round4 = sa32_sub_round4;		//

// mix column operation
assign {sa00_mc_round4, sa10_mc_round4, sa20_mc_round4, sa30_mc_round4}  = mix_col(sa00_sr_round4,sa10_sr_round4,sa20_sr_round4,sa30_sr_round4);
assign {sa01_mc_round4, sa11_mc_round4, sa21_mc_round4, sa31_mc_round4}  = mix_col(sa01_sr_round4,sa11_sr_round4,sa21_sr_round4,sa31_sr_round4);
assign {sa02_mc_round4, sa12_mc_round4, sa22_mc_round4, sa32_mc_round4}  = mix_col(sa02_sr_round4,sa12_sr_round4,sa22_sr_round4,sa32_sr_round4);
assign {sa03_mc_round4, sa13_mc_round4, sa23_mc_round4, sa33_mc_round4}  = mix_col(sa03_sr_round4,sa13_sr_round4,sa23_sr_round4,sa33_sr_round4);


//add round key
assign sa33_next_round5 = 		   sa33_mc_round4 ^ w19[07:00];
assign sa23_next_round5 =     	sa23_mc_round4 ^ w19[15:08];
assign sa13_next_round5 =     	sa13_mc_round4 ^ w19[23:16];
assign sa03_next_round5 =     	sa03_mc_round4 ^ w19[31:24];
assign sa32_next_round5 =     	sa32_mc_round4 ^ w18[07:00];
assign sa22_next_round5 =     	sa22_mc_round4 ^ w18[15:08];
assign sa12_next_round5 =     	sa12_mc_round4 ^ w18[23:16];
assign sa02_next_round5 =     	sa02_mc_round4 ^ w18[31:24];
assign sa31_next_round5 =     	sa31_mc_round4 ^ w17[07:00];
assign sa21_next_round5 =     	sa21_mc_round4 ^ w17[15:08];
assign sa11_next_round5 =     	sa11_mc_round4 ^ w17[23:16];
assign sa01_next_round5 =     	sa01_mc_round4 ^ w17[31:24];
assign sa30_next_round5 =     	sa30_mc_round4 ^ w16[07:00];
assign sa20_next_round5 =     	sa20_mc_round4 ^ w16[15:08];
assign sa10_next_round5 =     	sa10_mc_round4 ^ w16[23:16];
assign sa00_next_round5 =     	sa00_mc_round4 ^ w16[31:24];


/////////////////////////round #5 transformations/////////////////////////////


//sbox lookup
aes_sbox us00_round5(	.a(	sa00_next_round5	), .d(	sa00_sub_round5	));
aes_sbox us01_round5(	.a(	sa01_next_round5	), .d(	sa01_sub_round5	));
aes_sbox us02_round5(	.a(	sa02_next_round5	), .d(	sa02_sub_round5	));
aes_sbox us03_round5(	.a(	sa03_next_round5	), .d(	sa03_sub_round5	));
aes_sbox us10_round5(	.a(	sa10_next_round5	), .d(	sa10_sub_round5	));
aes_sbox us11_round5(	.a(	sa11_next_round5	), .d(	sa11_sub_round5	));
aes_sbox us12_round5(	.a(	sa12_next_round5	), .d(	sa12_sub_round5	));
aes_sbox us13_round5(	.a(	sa13_next_round5	), .d(	sa13_sub_round5	));
aes_sbox us20_round5(	.a(	sa20_next_round5	), .d(	sa20_sub_round5	));
aes_sbox us21_round5(	.a(	sa21_next_round5	), .d(	sa21_sub_round5	));
aes_sbox us22_round5(	.a(	sa22_next_round5	), .d(	sa22_sub_round5	));
aes_sbox us23_round5(	.a(	sa23_next_round5	), .d(	sa23_sub_round5	));
aes_sbox us30_round5(	.a(	sa30_next_round5	), .d(	sa30_sub_round5	));
aes_sbox us31_round5(	.a(	sa31_next_round5	), .d(	sa31_sub_round5	));
aes_sbox us32_round5(	.a(	sa32_next_round5	), .d(	sa32_sub_round5	));
aes_sbox us33_round5(	.a(	sa33_next_round5	), .d(	sa33_sub_round5	));

//shift rows

assign sa00_sr_round5 = sa00_sub_round5;		//
assign sa01_sr_round5 = sa01_sub_round5;		//no shift
assign sa02_sr_round5 = sa02_sub_round5;		//
assign sa03_sr_round5 = sa03_sub_round5;		//

assign sa10_sr_round5 = sa11_sub_round5;		//
assign sa11_sr_round5 = sa12_sub_round5;		// left shift by 1
assign sa12_sr_round5 = sa13_sub_round5;		//
assign sa13_sr_round5 = sa10_sub_round5;		//

assign sa20_sr_round5 = sa22_sub_round5;		//
assign sa21_sr_round5 = sa23_sub_round5;		//	left shift by 2
assign sa22_sr_round5 = sa20_sub_round5;		//
assign sa23_sr_round5 = sa21_sub_round5;		//

assign sa30_sr_round5 = sa33_sub_round5;		//
assign sa31_sr_round5 = sa30_sub_round5;		// left shift by 3
assign sa32_sr_round5 = sa31_sub_round5;		//
assign sa33_sr_round5 = sa32_sub_round5;		//

// mix column operation
assign {sa00_mc_round5, sa10_mc_round5, sa20_mc_round5, sa30_mc_round5}  = mix_col(sa00_sr_round5,sa10_sr_round5,sa20_sr_round5,sa30_sr_round5);
assign {sa01_mc_round5, sa11_mc_round5, sa21_mc_round5, sa31_mc_round5}  = mix_col(sa01_sr_round5,sa11_sr_round5,sa21_sr_round5,sa31_sr_round5);
assign {sa02_mc_round5, sa12_mc_round5, sa22_mc_round5, sa32_mc_round5}  = mix_col(sa02_sr_round5,sa12_sr_round5,sa22_sr_round5,sa32_sr_round5);
assign {sa03_mc_round5, sa13_mc_round5, sa23_mc_round5, sa33_mc_round5}  = mix_col(sa03_sr_round5,sa13_sr_round5,sa23_sr_round5,sa33_sr_round5);


//add round key
assign sa33_next_round6 = 		   sa33_mc_round5 ^ w23[07:00];
assign sa23_next_round6 =     	sa23_mc_round5 ^ w23[15:08];
assign sa13_next_round6 =     	sa13_mc_round5 ^ w23[23:16];
assign sa03_next_round6 =     	sa03_mc_round5 ^ w23[31:24];
assign sa32_next_round6 =     	sa32_mc_round5 ^ w22[07:00];
assign sa22_next_round6 =     	sa22_mc_round5 ^ w22[15:08];
assign sa12_next_round6 =     	sa12_mc_round5 ^ w22[23:16];
assign sa02_next_round6 =     	sa02_mc_round5 ^ w22[31:24];
assign sa31_next_round6 =     	sa31_mc_round5 ^ w21[07:00];
assign sa21_next_round6 =     	sa21_mc_round5 ^ w21[15:08];
assign sa11_next_round6 =     	sa11_mc_round5 ^ w21[23:16];
assign sa01_next_round6 =     	sa01_mc_round5 ^ w21[31:24];
assign sa30_next_round6 =     	sa30_mc_round5 ^ w20[07:00];
assign sa20_next_round6 =     	sa20_mc_round5 ^ w20[15:08];
assign sa10_next_round6 =     	sa10_mc_round5 ^ w20[23:16];
assign sa00_next_round6 =     	sa00_mc_round5 ^ w20[31:24];


/////////////////////////round #6 transformations/////////////////////////////


//sbox lookup
aes_sbox us00_round6(	.a(	sa00_next_round6	), .d(	sa00_sub_round6	));
aes_sbox us01_round6(	.a(	sa01_next_round6	), .d(	sa01_sub_round6	));
aes_sbox us02_round6(	.a(	sa02_next_round6	), .d(	sa02_sub_round6	));
aes_sbox us03_round6(	.a(	sa03_next_round6	), .d(	sa03_sub_round6	));
aes_sbox us10_round6(	.a(	sa10_next_round6	), .d(	sa10_sub_round6	));
aes_sbox us11_round6(	.a(	sa11_next_round6	), .d(	sa11_sub_round6	));
aes_sbox us12_round6(	.a(	sa12_next_round6	), .d(	sa12_sub_round6	));
aes_sbox us13_round6(	.a(	sa13_next_round6	), .d(	sa13_sub_round6	));
aes_sbox us20_round6(	.a(	sa20_next_round6	), .d(	sa20_sub_round6	));
aes_sbox us21_round6(	.a(	sa21_next_round6	), .d(	sa21_sub_round6	));
aes_sbox us22_round6(	.a(	sa22_next_round6	), .d(	sa22_sub_round6	));
aes_sbox us23_round6(	.a(	sa23_next_round6	), .d(	sa23_sub_round6	));
aes_sbox us30_round6(	.a(	sa30_next_round6	), .d(	sa30_sub_round6	));
aes_sbox us31_round6(	.a(	sa31_next_round6	), .d(	sa31_sub_round6	));
aes_sbox us32_round6(	.a(	sa32_next_round6	), .d(	sa32_sub_round6	));
aes_sbox us33_round6(	.a(	sa33_next_round6	), .d(	sa33_sub_round6	));

//shift rows

assign sa00_sr_round6 = sa00_sub_round6;		//
assign sa01_sr_round6 = sa01_sub_round6;		//no shift
assign sa02_sr_round6 = sa02_sub_round6;		//
assign sa03_sr_round6 = sa03_sub_round6;		//

assign sa10_sr_round6 = sa11_sub_round6;		//
assign sa11_sr_round6 = sa12_sub_round6;		// left shift by 1
assign sa12_sr_round6 = sa13_sub_round6;		//
assign sa13_sr_round6 = sa10_sub_round6;		//

assign sa20_sr_round6 = sa22_sub_round6;		//
assign sa21_sr_round6 = sa23_sub_round6;		//	left shift by 2
assign sa22_sr_round6 = sa20_sub_round6;		//
assign sa23_sr_round6 = sa21_sub_round6;		//

assign sa30_sr_round6 = sa33_sub_round6;		//
assign sa31_sr_round6 = sa30_sub_round6;		// left shift by 3
assign sa32_sr_round6 = sa31_sub_round6;		//
assign sa33_sr_round6 = sa32_sub_round6;		//

// mix column operation
assign {sa00_mc_round6, sa10_mc_round6, sa20_mc_round6, sa30_mc_round6}  = mix_col(sa00_sr_round6,sa10_sr_round6,sa20_sr_round6,sa30_sr_round6);
assign {sa01_mc_round6, sa11_mc_round6, sa21_mc_round6, sa31_mc_round6}  = mix_col(sa01_sr_round6,sa11_sr_round6,sa21_sr_round6,sa31_sr_round6);
assign {sa02_mc_round6, sa12_mc_round6, sa22_mc_round6, sa32_mc_round6}  = mix_col(sa02_sr_round6,sa12_sr_round6,sa22_sr_round6,sa32_sr_round6);
assign {sa03_mc_round6, sa13_mc_round6, sa23_mc_round6, sa33_mc_round6}  = mix_col(sa03_sr_round6,sa13_sr_round6,sa23_sr_round6,sa33_sr_round6);


//add round key
assign sa33_next_round7 = 		   sa33_mc_round6 ^ w27[07:00];
assign sa23_next_round7 =     	sa23_mc_round6 ^ w27[15:08];
assign sa13_next_round7 =     	sa13_mc_round6 ^ w27[23:16];
assign sa03_next_round7 =     	sa03_mc_round6 ^ w27[31:24];
assign sa32_next_round7 =     	sa32_mc_round6 ^ w26[07:00];
assign sa22_next_round7 =     	sa22_mc_round6 ^ w26[15:08];
assign sa12_next_round7 =     	sa12_mc_round6 ^ w26[23:16];
assign sa02_next_round7 =     	sa02_mc_round6 ^ w26[31:24];
assign sa31_next_round7 =     	sa31_mc_round6 ^ w25[07:00];
assign sa21_next_round7 =     	sa21_mc_round6 ^ w25[15:08];
assign sa11_next_round7 =     	sa11_mc_round6 ^ w25[23:16];
assign sa01_next_round7 =     	sa01_mc_round6 ^ w25[31:24];
assign sa30_next_round7 =     	sa30_mc_round6 ^ w24[07:00];
assign sa20_next_round7 =     	sa20_mc_round6 ^ w24[15:08];
assign sa10_next_round7 =     	sa10_mc_round6 ^ w24[23:16];
assign sa00_next_round7 =     	sa00_mc_round6 ^ w24[31:24];


/////////////////////////round #7 transformations/////////////////////////////


//sbox lookup
aes_sbox us00_round7(	.a(	sa00_next_round7	), .d(	sa00_sub_round7	));
aes_sbox us01_round7(	.a(	sa01_next_round7	), .d(	sa01_sub_round7	));
aes_sbox us02_round7(	.a(	sa02_next_round7	), .d(	sa02_sub_round7	));
aes_sbox us03_round7(	.a(	sa03_next_round7	), .d(	sa03_sub_round7	));
aes_sbox us10_round7(	.a(	sa10_next_round7	), .d(	sa10_sub_round7	));
aes_sbox us11_round7(	.a(	sa11_next_round7	), .d(	sa11_sub_round7	));
aes_sbox us12_round7(	.a(	sa12_next_round7	), .d(	sa12_sub_round7	));
aes_sbox us13_round7(	.a(	sa13_next_round7	), .d(	sa13_sub_round7	));
aes_sbox us20_round7(	.a(	sa20_next_round7	), .d(	sa20_sub_round7	));
aes_sbox us21_round7(	.a(	sa21_next_round7	), .d(	sa21_sub_round7	));
aes_sbox us22_round7(	.a(	sa22_next_round7	), .d(	sa22_sub_round7	));
aes_sbox us23_round7(	.a(	sa23_next_round7	), .d(	sa23_sub_round7	));
aes_sbox us30_round7(	.a(	sa30_next_round7	), .d(	sa30_sub_round7	));
aes_sbox us31_round7(	.a(	sa31_next_round7	), .d(	sa31_sub_round7	));
aes_sbox us32_round7(	.a(	sa32_next_round7	), .d(	sa32_sub_round7	));
aes_sbox us33_round7(	.a(	sa33_next_round7	), .d(	sa33_sub_round7	));

//shift rows

assign sa00_sr_round7 = sa00_sub_round7;		//
assign sa01_sr_round7 = sa01_sub_round7;		//no shift
assign sa02_sr_round7 = sa02_sub_round7;		//
assign sa03_sr_round7 = sa03_sub_round7;		//

assign sa10_sr_round7 = sa11_sub_round7;		//
assign sa11_sr_round7 = sa12_sub_round7;		// left shift by 1
assign sa12_sr_round7 = sa13_sub_round7;		//
assign sa13_sr_round7 = sa10_sub_round7;		//

assign sa20_sr_round7 = sa22_sub_round7;		//
assign sa21_sr_round7 = sa23_sub_round7;		//	left shift by 2
assign sa22_sr_round7 = sa20_sub_round7;		//
assign sa23_sr_round7 = sa21_sub_round7;		//

assign sa30_sr_round7 = sa33_sub_round7;		//
assign sa31_sr_round7 = sa30_sub_round7;		// left shift by 3
assign sa32_sr_round7 = sa31_sub_round7;		//
assign sa33_sr_round7 = sa32_sub_round7;		//

// mix column operation
assign {sa00_mc_round7, sa10_mc_round7, sa20_mc_round7, sa30_mc_round7}  = mix_col(sa00_sr_round7,sa10_sr_round7,sa20_sr_round7,sa30_sr_round7);
assign {sa01_mc_round7, sa11_mc_round7, sa21_mc_round7, sa31_mc_round7}  = mix_col(sa01_sr_round7,sa11_sr_round7,sa21_sr_round7,sa31_sr_round7);
assign {sa02_mc_round7, sa12_mc_round7, sa22_mc_round7, sa32_mc_round7}  = mix_col(sa02_sr_round7,sa12_sr_round7,sa22_sr_round7,sa32_sr_round7);
assign {sa03_mc_round7, sa13_mc_round7, sa23_mc_round7, sa33_mc_round7}  = mix_col(sa03_sr_round7,sa13_sr_round7,sa23_sr_round7,sa33_sr_round7);


//add round key
assign sa33_next_round8 = 		   sa33_mc_round7 ^ w31[07:00];
assign sa23_next_round8 =     	sa23_mc_round7 ^ w31[15:08];
assign sa13_next_round8 =     	sa13_mc_round7 ^ w31[23:16];
assign sa03_next_round8 =     	sa03_mc_round7 ^ w31[31:24];
assign sa32_next_round8 =     	sa32_mc_round7 ^ w30[07:00];
assign sa22_next_round8 =     	sa22_mc_round7 ^ w30[15:08];
assign sa12_next_round8 =     	sa12_mc_round7 ^ w30[23:16];
assign sa02_next_round8 =     	sa02_mc_round7 ^ w30[31:24];
assign sa31_next_round8 =     	sa31_mc_round7 ^ w29[07:00];
assign sa21_next_round8 =     	sa21_mc_round7 ^ w29[15:08];
assign sa11_next_round8 =     	sa11_mc_round7 ^ w29[23:16];
assign sa01_next_round8 =     	sa01_mc_round7 ^ w29[31:24];
assign sa30_next_round8 =     	sa30_mc_round7 ^ w28[07:00];
assign sa20_next_round8 =     	sa20_mc_round7 ^ w28[15:08];
assign sa10_next_round8 =     	sa10_mc_round7 ^ w28[23:16];
assign sa00_next_round8 =     	sa00_mc_round7 ^ w28[31:24];

/////////////////////////round #8 transformations/////////////////////////////

	
//sbox lookup
aes_sbox us00_round8(	.a(	sa00_next_round8	), .d(	sa00_sub_round8	));
aes_sbox us01_round8(	.a(	sa01_next_round8	), .d(	sa01_sub_round8	));
aes_sbox us02_round8(	.a(	sa02_next_round8	), .d(	sa02_sub_round8	));
aes_sbox us03_round8(	.a(	sa03_next_round8	), .d(	sa03_sub_round8	));
aes_sbox us10_round8(	.a(	sa10_next_round8	), .d(	sa10_sub_round8	));
aes_sbox us11_round8(	.a(	sa11_next_round8	), .d(	sa11_sub_round8	));
aes_sbox us12_round8(	.a(	sa12_next_round8	), .d(	sa12_sub_round8	));
aes_sbox us13_round8(	.a(	sa13_next_round8	), .d(	sa13_sub_round8	));
aes_sbox us20_round8(	.a(	sa20_next_round8	), .d(	sa20_sub_round8	));
aes_sbox us21_round8(	.a(	sa21_next_round8	), .d(	sa21_sub_round8	));
aes_sbox us22_round8(	.a(	sa22_next_round8	), .d(	sa22_sub_round8	));
aes_sbox us23_round8(	.a(	sa23_next_round8	), .d(	sa23_sub_round8	));
aes_sbox us30_round8(	.a(	sa30_next_round8	), .d(	sa30_sub_round8	));
aes_sbox us31_round8(	.a(	sa31_next_round8	), .d(	sa31_sub_round8	));
aes_sbox us32_round8(	.a(	sa32_next_round8	), .d(	sa32_sub_round8	));
aes_sbox us33_round8(	.a(	sa33_next_round8	), .d(	sa33_sub_round8	));

//shift rows

assign sa00_sr_round8 = sa00_sub_round8;		//
assign sa01_sr_round8 = sa01_sub_round8;		//no shift
assign sa02_sr_round8 = sa02_sub_round8;		//
assign sa03_sr_round8 = sa03_sub_round8;		//

assign sa10_sr_round8 = sa11_sub_round8;		//
assign sa11_sr_round8 = sa12_sub_round8;		// left shift by 1
assign sa12_sr_round8 = sa13_sub_round8;		//
assign sa13_sr_round8 = sa10_sub_round8;		//

assign sa20_sr_round8 = sa22_sub_round8;		//
assign sa21_sr_round8 = sa23_sub_round8;		//	left shift by 2
assign sa22_sr_round8 = sa20_sub_round8;		//
assign sa23_sr_round8 = sa21_sub_round8;		//

assign sa30_sr_round8 = sa33_sub_round8;		//
assign sa31_sr_round8 = sa30_sub_round8;		// left shift by 3
assign sa32_sr_round8 = sa31_sub_round8;		//
assign sa33_sr_round8 = sa32_sub_round8;		//

// mix column operation
assign {sa00_mc_round8, sa10_mc_round8, sa20_mc_round8, sa30_mc_round8}  = mix_col(sa00_sr_round8,sa10_sr_round8,sa20_sr_round8,sa30_sr_round8);
assign {sa01_mc_round8, sa11_mc_round8, sa21_mc_round8, sa31_mc_round8}  = mix_col(sa01_sr_round8,sa11_sr_round8,sa21_sr_round8,sa31_sr_round8);
assign {sa02_mc_round8, sa12_mc_round8, sa22_mc_round8, sa32_mc_round8}  = mix_col(sa02_sr_round8,sa12_sr_round8,sa22_sr_round8,sa32_sr_round8);
assign {sa03_mc_round8, sa13_mc_round8, sa23_mc_round8, sa33_mc_round8}  = mix_col(sa03_sr_round8,sa13_sr_round8,sa23_sr_round8,sa33_sr_round8);


//add round key
assign sa33_next_round9 = 		   sa33_mc_round8 ^ w35[07:00];
assign sa23_next_round9 =     	sa23_mc_round8 ^ w35[15:08];
assign sa13_next_round9 =     	sa13_mc_round8 ^ w35[23:16];
assign sa03_next_round9 =     	sa03_mc_round8 ^ w35[31:24];
assign sa32_next_round9 =     	sa32_mc_round8 ^ w34[07:00];
assign sa22_next_round9 =     	sa22_mc_round8 ^ w34[15:08];
assign sa12_next_round9 =     	sa12_mc_round8 ^ w34[23:16];
assign sa02_next_round9 =     	sa02_mc_round8 ^ w34[31:24];
assign sa31_next_round9 =     	sa31_mc_round8 ^ w33[07:00];
assign sa21_next_round9 =     	sa21_mc_round8 ^ w33[15:08];
assign sa11_next_round9 =     	sa11_mc_round8 ^ w33[23:16];
assign sa01_next_round9 =     	sa01_mc_round8 ^ w33[31:24];
assign sa30_next_round9 =     	sa30_mc_round8 ^ w32[07:00];
assign sa20_next_round9 =     	sa20_mc_round8 ^ w32[15:08];
assign sa10_next_round9 =     	sa10_mc_round8 ^ w32[23:16];
assign sa00_next_round9 =     	sa00_mc_round8 ^ w32[31:24];



/////////////////////////round #9 transformations/////////////////////////////

	
//sbox lookup
aes_sbox us00_round9(	.a(	sa00_next_round9	), .d(	sa00_sub_round9	));
aes_sbox us01_round9(	.a(	sa01_next_round9	), .d(	sa01_sub_round9	));
aes_sbox us02_round9(	.a(	sa02_next_round9	), .d(	sa02_sub_round9	));
aes_sbox us03_round9(	.a(	sa03_next_round9	), .d(	sa03_sub_round9	));
aes_sbox us10_round9(	.a(	sa10_next_round9	), .d(	sa10_sub_round9	));
aes_sbox us11_round9(	.a(	sa11_next_round9	), .d(	sa11_sub_round9	));
aes_sbox us12_round9(	.a(	sa12_next_round9	), .d(	sa12_sub_round9	));
aes_sbox us13_round9(	.a(	sa13_next_round9	), .d(	sa13_sub_round9	));
aes_sbox us20_round9(	.a(	sa20_next_round9	), .d(	sa20_sub_round9	));
aes_sbox us21_round9(	.a(	sa21_next_round9	), .d(	sa21_sub_round9	));
aes_sbox us22_round9(	.a(	sa22_next_round9	), .d(	sa22_sub_round9	));
aes_sbox us23_round9(	.a(	sa23_next_round9	), .d(	sa23_sub_round9	));
aes_sbox us30_round9(	.a(	sa30_next_round9	), .d(	sa30_sub_round9	));
aes_sbox us31_round9(	.a(	sa31_next_round9	), .d(	sa31_sub_round9	));
aes_sbox us32_round9(	.a(	sa32_next_round9	), .d(	sa32_sub_round9	));
aes_sbox us33_round9(	.a(	sa33_next_round9	), .d(	sa33_sub_round9	));

//shift rows

assign sa00_sr_round9 = sa00_sub_round9;		//
assign sa01_sr_round9 = sa01_sub_round9;		//no shift
assign sa02_sr_round9 = sa02_sub_round9;		//
assign sa03_sr_round9 = sa03_sub_round9;		//

assign sa10_sr_round9 = sa11_sub_round9;		//
assign sa11_sr_round9 = sa12_sub_round9;		// left shift by 1
assign sa12_sr_round9 = sa13_sub_round9;		//
assign sa13_sr_round9 = sa10_sub_round9;		//

assign sa20_sr_round9 = sa22_sub_round9;		//
assign sa21_sr_round9 = sa23_sub_round9;		//	left shift by 2
assign sa22_sr_round9 = sa20_sub_round9;		//
assign sa23_sr_round9 = sa21_sub_round9;		//

assign sa30_sr_round9 = sa33_sub_round9;		//
assign sa31_sr_round9 = sa30_sub_round9;		// left shift by 3
assign sa32_sr_round9 = sa31_sub_round9;		//
assign sa33_sr_round9 = sa32_sub_round9;		//

// mix column operation
assign {sa00_mc_round9, sa10_mc_round9, sa20_mc_round9, sa30_mc_round9}  = mix_col(sa00_sr_round9,sa10_sr_round9,sa20_sr_round9,sa30_sr_round9);
assign {sa01_mc_round9, sa11_mc_round9, sa21_mc_round9, sa31_mc_round9}  = mix_col(sa01_sr_round9,sa11_sr_round9,sa21_sr_round9,sa31_sr_round9);
assign {sa02_mc_round9, sa12_mc_round9, sa22_mc_round9, sa32_mc_round9}  = mix_col(sa02_sr_round9,sa12_sr_round9,sa22_sr_round9,sa32_sr_round9);
assign {sa03_mc_round9, sa13_mc_round9, sa23_mc_round9, sa33_mc_round9}  = mix_col(sa03_sr_round9,sa13_sr_round9,sa23_sr_round9,sa33_sr_round9);


//add round key
assign sa33_next_round10 = 		sa33_mc_round9 ^ w39[07:00];
assign sa23_next_round10 =     	sa23_mc_round9 ^ w39[15:08];
assign sa13_next_round10 =     	sa13_mc_round9 ^ w39[23:16];
assign sa03_next_round10 =     	sa03_mc_round9 ^ w39[31:24];
assign sa32_next_round10 =     	sa32_mc_round9 ^ w38[07:00];
assign sa22_next_round10 =     	sa22_mc_round9 ^ w38[15:08];
assign sa12_next_round10 =     	sa12_mc_round9 ^ w38[23:16];
assign sa02_next_round10 =     	sa02_mc_round9 ^ w38[31:24];
assign sa31_next_round10 =     	sa31_mc_round9 ^ w37[07:00];
assign sa21_next_round10 =     	sa21_mc_round9 ^ w37[15:08];
assign sa11_next_round10 =     	sa11_mc_round9 ^ w37[23:16];
assign sa01_next_round10 =     	sa01_mc_round9 ^ w37[31:24];
assign sa30_next_round10 =     	sa30_mc_round9 ^ w36[07:00];
assign sa20_next_round10 =     	sa20_mc_round9 ^ w36[15:08];
assign sa10_next_round10 =     	sa10_mc_round9 ^ w36[23:16];
assign sa00_next_round10 =     	sa00_mc_round9 ^ w36[31:24];


/////////////////////////round # 10 transformations/////////////////////////////

	
//sbox lookup
aes_sbox us00_round10(	.a(	sa00_next_round10	), .d(	sa00_sub_round10	));
aes_sbox us01_round10(	.a(	sa01_next_round10	), .d(	sa01_sub_round10	));
aes_sbox us02_round10(	.a(	sa02_next_round10	), .d(	sa02_sub_round10	));
aes_sbox us03_round10(	.a(	sa03_next_round10	), .d(	sa03_sub_round10	));
aes_sbox us10_round10(	.a(	sa10_next_round10	), .d(	sa10_sub_round10	));
aes_sbox us11_round10(	.a(	sa11_next_round10	), .d(	sa11_sub_round10	));
aes_sbox us12_round10(	.a(	sa12_next_round10	), .d(	sa12_sub_round10	));
aes_sbox us13_round10(	.a(	sa13_next_round10	), .d(	sa13_sub_round10	));
aes_sbox us20_round10(	.a(	sa20_next_round10	), .d(	sa20_sub_round10	));
aes_sbox us21_round10(	.a(	sa21_next_round10	), .d(	sa21_sub_round10	));
aes_sbox us22_round10(	.a(	sa22_next_round10	), .d(	sa22_sub_round10	));
aes_sbox us23_round10(	.a(	sa23_next_round10	), .d(	sa23_sub_round10	));
aes_sbox us30_round10(	.a(	sa30_next_round10	), .d(	sa30_sub_round10	));
aes_sbox us31_round10(	.a(	sa31_next_round10	), .d(	sa31_sub_round10	));
aes_sbox us32_round10(	.a(	sa32_next_round10	), .d(	sa32_sub_round10	));
aes_sbox us33_round10(	.a(	sa33_next_round10	), .d(	sa33_sub_round10	));

//shift rows

assign sa00_sr_round10 = sa00_sub_round10;		//
assign sa01_sr_round10 = sa01_sub_round10;		//no shift
assign sa02_sr_round10 = sa02_sub_round10;		//
assign sa03_sr_round10 = sa03_sub_round10;		//

assign sa10_sr_round10 = sa11_sub_round10;		//
assign sa11_sr_round10 = sa12_sub_round10;		// left shift by 1
assign sa12_sr_round10 = sa13_sub_round10;		//
assign sa13_sr_round10 = sa10_sub_round10;		//

assign sa20_sr_round10 = sa22_sub_round10;		//
assign sa21_sr_round10 = sa23_sub_round10;		//	left shift by 2
assign sa22_sr_round10 = sa20_sub_round10;		//
assign sa23_sr_round10 = sa21_sub_round10;		//

assign sa30_sr_round10 = sa33_sub_round10;		//
assign sa31_sr_round10 = sa30_sub_round10;		// left shift by 3
assign sa32_sr_round10 = sa31_sub_round10;		//
assign sa33_sr_round10 = sa32_sub_round10;		//


// Final text output


always @(posedge clk)
 begin 
		/*  $strobe($time,": round_key2 is %h\n",{w4,w5,w6,w7});
		  $strobe($time,": roundkeyeven = %h, text_out_even is %h\n",{w4,w5,w6,w7},text_out);*/
		  text_out[127:120] <=  sa00_sr_round10 ^ w40[31:24];	 
		  text_out[095:088] <=  sa01_sr_round10 ^ w41[31:24];	 
		  text_out[063:056] <=  sa02_sr_round10 ^ w42[31:24];	 
		  text_out[031:024] <=  sa03_sr_round10 ^ w43[31:24];	 
		  text_out[119:112] <=  sa10_sr_round10 ^ w40[23:16];	 
		  text_out[087:080] <=  sa11_sr_round10 ^ w41[23:16];	 
		  text_out[055:048] <=  sa12_sr_round10 ^ w42[23:16];	 
		  text_out[023:016] <=  sa13_sr_round10 ^ w43[23:16];	 
		  text_out[111:104] <=  sa20_sr_round10 ^ w40[15:08];	 
		  text_out[079:072] <=  sa21_sr_round10 ^ w41[15:08];	 
		  text_out[047:040] <=  sa22_sr_round10 ^ w42[15:08];	 
		  text_out[015:008] <=  sa23_sr_round10 ^ w43[15:08];	 
		  text_out[103:096] <=  sa30_sr_round10 ^ w40[07:00];	 
		  text_out[071:064] <=  sa31_sr_round10 ^ w41[07:00];	 
		  text_out[039:032] <=  sa32_sr_round10 ^ w42[07:00];	 
		  text_out[007:000] <=  sa33_sr_round10 ^ w43[07:00];
	end


////////////////////////////////////////////////////////////////////
//
// Generic Functions
//

function [31:0] mix_col;
input	[7:0]	s0,s1,s2,s3;
//reg	[7:0]	s0_o,s1_o,s2_o,s3_o;
begin
mix_col[31:24]=xtime(s0)^xtime(s1)^s1^s2^s3;
mix_col[23:16]=s0^xtime(s1)^xtime(s2)^s2^s3;
mix_col[15:08]=s0^s1^xtime(s2)^xtime(s3)^s3;
mix_col[07:00]=xtime(s0)^s0^s1^s2^xtime(s3);
end
endfunction

function [7:0] xtime;
input [7:0] b; xtime={b[6:0],1'b0}^(8'h1b&{8{b[7]}});
endfunction



endmodule



