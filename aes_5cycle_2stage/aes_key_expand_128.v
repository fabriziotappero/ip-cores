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


`timescale 1 ns/1 ps

module aes_key_expand_128(clk, kld, key, w0,w1,w2,w3,w4_reg,w5_reg,w6_reg,w7_reg);
input		clk;
input		kld;
input	[127:0]	key;
output reg	[31:0]	w0,w1,w2,w3;
		 reg [31:0]	   w4,w5,w6,w7;

output reg   [31:0]   w4_reg,w5_reg,w6_reg,w7_reg;
wire	[31:0]	tmp_w,tmp_w2;
wire	[31:0]	subword, subword2;
wire	[31:0]	rcon, rcon2;			//round constant



always @(posedge clk)
begin
	w4_reg <=  w4;
	w5_reg <=  w5;
	w6_reg <=  w6;
	w7_reg <=  w7;
/*   $strobe($time,": next round_key is %h\n",{w4_reg,w5_reg,w6_reg,w7_reg}); 
*/end

		
always @*
begin
 
w0 =  kld ? key[127:096] :w4_reg^subword2^{rcon[31:24],24'b0};
w1 =  kld ? key[095:064] :w5_reg^w4_reg^subword2^{rcon[31:24],24'b0};
w2 =  kld ? key[063:032] :w6_reg^w5_reg^w4_reg^subword2^{rcon[31:24],24'b0};
w3 =  kld ? key[031:000] :w7_reg^w6_reg^w5_reg^w4_reg^subword2^{rcon[31:24],24'b0};

w4 =  (1'b0)? key[127:096]^subword^{8'h01,24'b0} : w0^subword^{rcon2[31:24],24'b0};
w5 =  (1'b0)? key[095:064]^key[127:096]^subword^{8'h01,24'b0} :w1^w0^subword^{rcon2[31:24],24'b0};
w6 =  (1'b0)? key[063:032]^key[095:064]^key[127:096]^subword^{8'h01,24'b0} : w2^w1^w0^subword^{rcon2[31:24],24'b0}; 
w7 =  (1'b0)? key[127:096]^key[095:064]^key[063:032]^key[031:000]^subword^{8'h01,24'b0} : w3^w2^w1^w0^subword^{rcon2[31:24],24'b0};

/*$display($time,": rcon is %d, rcon2 is %d\n",rcon[31:24],rcon2[31:24]);*/
/*$display($time,": round_key is %h\n",{w0,w1,w2,w3}); 	
$display($time,": next_round_key is %h\n",{w4,w5,w6,w7});*/
end


/*assign tmp_w =  w3;  //subword
assign tmp_w2 = w7 ;  //subword2
*/
/*
assign subword[31:24]     = aes_sbox(tmp_w[23:16]);
assign subword[23:16]	  = aes_sbox(tmp_w[15:08]);
assign subword[15:08]	  = aes_sbox(tmp_w[07:00]);
assign subword[07:00]     = aes_sbox(tmp_w[31:24]);
*/

aes_sbox inst1(	.a(w3[23:16]), .d(subword[31:24]));
aes_sbox inst2(	.a(w3[15:08]), .d(subword[23:16]));
aes_sbox inst3(	.a(w3[07:00]), .d(subword[15:08]));
aes_sbox inst4(	.a(w3[31:24]), .d(subword[07:00])); 
aes_rcon inst5(.clk(clk), .kld(kld), .out(rcon[31:24]), .out2(rcon2[31:24]));


aes_sbox u4(	.a(w7_reg[23:16]), .d(subword2[31:24]));
aes_sbox u5(	.a(w7_reg[15:08]), .d(subword2[23:16]));
aes_sbox u6(	.a(w7_reg[07:00]), .d(subword2[15:08]));
aes_sbox u7(	.a(w7_reg[31:24]), .d(subword2[07:00])); 



endmodule

