/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Key Expand Block (for 128 bit keys)                    ////
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

module aes_key_expand_128(clk, key, w0,w1,w2,w3,w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17,
													  w18, w19, w20, w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33,
													  w34, w35, w36, w37, w38, w39, w40, w41, w42, w43);
input		clk;
input	[127:0]	key;
output reg	[31:0]	w0,w1,w2,w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17,
							w18, w19, w20, w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33,
							w34, w35, w36, w37, w38, w39, w40, w41, w42, w43;
wire	[31:0]	subword, subword2,subword3,subword4,subword5, subword6, subword7,subword8,subword9,subword10;
wire	[7:0]	rcon, rcon2,rcon3,rcon4,rcon5, rcon6, rcon7,rcon8,rcon9,rcon10;			



		
always @*
begin
 
w0 =  key[127:096];
w1 =  key[095:064];
w2 =  key[063:032];
w3 =  key[031:000];

w4 =  key[127:096]^subword^{8'h01,24'b0};
w5 =  key[095:064]^key[127:096]^subword^{8'h01,24'b0};
w6 =  key[063:032]^key[095:064]^key[127:096]^subword^{8'h01,24'b0}; 
w7 =  key[127:096]^key[095:064]^key[063:032]^key[031:000]^subword^{8'h01,24'b0};

w8  =  w4^subword2^{rcon2,24'b0};
w9  =  w5^w4^subword2^{rcon2,24'b0};
w10 =  w6^w5^w4^subword2^{rcon2,24'b0}; 
w11 =  w7^w6^w5^w4^subword2^{rcon2,24'b0};


w12  =  w8^subword3^{rcon3,24'b0};
w13  =  w8^w9^subword3^{rcon3,24'b0};
w14  =  w8^w9^w10^subword3^{rcon3,24'b0}; 
w15  =  w8^w9^w10^w11^subword3^{rcon3,24'b0};


w16  =  w12^subword4^{rcon4,24'b0};
w17  =  w12^w13^subword4^{rcon4,24'b0};
w18  =  w12^w13^w14^subword4^{rcon4,24'b0}; 
w19  =  w12^w13^w14^w15^subword4^{rcon4,24'b0};


w20  =  w16^subword5^{rcon5,24'b0};
w21  =  w16^w17^subword5^{rcon5,24'b0};
w22  =  w16^w17^w18^subword5^{rcon5,24'b0}; 
w23  =  w16^w17^w18^w19^subword5^{rcon5,24'b0};


w24  =  w20^subword6^{rcon6,24'b0};
w25  =  w20^w21^subword6^{rcon6,24'b0};
w26  =  w20^w21^w22^subword6^{rcon6,24'b0}; 
w27  =  w20^w21^w22^w23^subword6^{rcon6,24'b0};

w28  =  w24^subword7^{rcon7,24'b0};
w29  =  w24^w25^subword7^{rcon7,24'b0};
w30  =  w24^w25^w26^subword7^{rcon7,24'b0}; 
w31  =  w24^w25^w26^w27^subword7^{rcon7,24'b0};


w32  =  w28^subword8^{rcon8,24'b0};
w33  =  w28^w29^subword8^{rcon8,24'b0};
w34  =  w28^w29^w30^subword8^{rcon8,24'b0}; 
w35  =  w28^w29^w30^w31^subword8^{rcon8,24'b0};

w36  =  w32^subword9^{rcon9,24'b0};
w37  =  w32^w33^subword9^{rcon9,24'b0};
w38  =  w32^w33^w34^subword9^{rcon9,24'b0}; 
w39  =  w32^w33^w34^w35^subword9^{rcon9,24'b0};

w40  =  w36^subword10^{rcon10,24'b0};
w41  =  w36^w37^subword10^{rcon10,24'b0};
w42  =  w36^w37^w38^subword10^{rcon10,24'b0}; 
w43  =  w36^w37^w38^w39^subword10^{rcon10,24'b0};

/*$display($time,": subword5 is %h\n",subword2);
$display($time,": rcon5 is %h\n",rcon5);
$display($time,": key5 is %h, key6 is %h\n",{w16,w17,w18,w19},{w20,w21,w22,w23});*/

end

aes_rcon inst5(.clk(clk),            .out(rcon),   .out2(rcon2),
												 .out3(rcon3), .out4(rcon4),
												 .out5(rcon5), .out6(rcon6),
												 .out7(rcon7), .out8(rcon8),
												 .out9(rcon9), .out10(rcon10));

aes_sbox u0(	.a(w3[23:16]), .d(subword[31:24]));
aes_sbox u1(	.a(w3[15:08]), .d(subword[23:16]));
aes_sbox u2(	.a(w3[07:00]), .d(subword[15:08]));
aes_sbox u3(	.a(w3[31:24]), .d(subword[07:00])); 

aes_sbox u4(	.a(w7[23:16]), .d(subword2[31:24]));
aes_sbox u5(	.a(w7[15:08]), .d(subword2[23:16]));
aes_sbox u6(	.a(w7[07:00]), .d(subword2[15:08]));
aes_sbox u7(	.a(w7[31:24]), .d(subword2[07:00])); 


aes_sbox u8(	.a(w11[23:16]), .d(subword3[31:24]));
aes_sbox u9(	.a(w11[15:08]), .d(subword3[23:16]));
aes_sbox u10(	.a(w11[07:00]), .d(subword3[15:08]));
aes_sbox u11(	.a(w11[31:24]), .d(subword3[07:00])); 


aes_sbox u12(	.a(w15[23:16]), .d(subword4[31:24]));
aes_sbox u13(	.a(w15[15:08]), .d(subword4[23:16]));
aes_sbox u14(	.a(w15[07:00]), .d(subword4[15:08]));
aes_sbox u15(	.a(w15[31:24]), .d(subword4[07:00])); 

aes_sbox u16(	.a(w19[23:16]), .d(subword5[31:24]));
aes_sbox u17(	.a(w19[15:08]), .d(subword5[23:16]));
aes_sbox u18(	.a(w19[07:00]), .d(subword5[15:08]));
aes_sbox u19(	.a(w19[31:24]), .d(subword5[07:00])); 

aes_sbox u20(	.a(w23[23:16]), .d(subword6[31:24]));
aes_sbox u21(	.a(w23[15:08]), .d(subword6[23:16]));
aes_sbox u22(	.a(w23[07:00]), .d(subword6[15:08]));
aes_sbox u23(	.a(w23[31:24]), .d(subword6[07:00])); 

aes_sbox u24(	.a(w27[23:16]), .d(subword7[31:24]));
aes_sbox u25(	.a(w27[15:08]), .d(subword7[23:16]));
aes_sbox u26(	.a(w27[07:00]), .d(subword7[15:08]));
aes_sbox u27(	.a(w27[31:24]), .d(subword7[07:00])); 

aes_sbox u28(	.a(w31[23:16]), .d(subword8[31:24]));
aes_sbox u29(	.a(w31[15:08]), .d(subword8[23:16]));
aes_sbox u30(	.a(w31[07:00]), .d(subword8[15:08]));
aes_sbox u31(	.a(w31[31:24]), .d(subword8[07:00])); 

aes_sbox u32(	.a(w35[23:16]), .d(subword9[31:24]));
aes_sbox u33(	.a(w35[15:08]), .d(subword9[23:16]));
aes_sbox u34(	.a(w35[07:00]), .d(subword9[15:08]));
aes_sbox u35(	.a(w35[31:24]), .d(subword9[07:00])); 

aes_sbox u36(	.a(w39[23:16]), .d(subword10[31:24]));
aes_sbox u37(	.a(w39[15:08]), .d(subword10[23:16]));
aes_sbox u38(	.a(w39[07:00]), .d(subword10[15:08]));
aes_sbox u39(	.a(w39[31:24]), .d(subword10[07:00])); 


endmodule

