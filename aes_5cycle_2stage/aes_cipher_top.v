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
 
//// Modified to achieve 5 cycles - stage  functionality 	     ////
//// By Tariq Bashir Ahmad					     				 //// 	
////  tariq.bashir@gmail.com					     			 ////
////  http://www.ecs.umass.edu/~tbashir				    		 ////



`timescale 1 ns/1 ps

module aes_cipher_top(clk, rst, ld, done, key, text_in, text_out);

input		clk, rst;
input		ld;
output		done;
input	[127:0]	key;
input	[127:0]	text_in;
output	[127:0]	text_out;


////////////////////////////////////////////////////////////////////
//
// Local Wires
//

wire	[31:0]	w0, w1, w2, w3, w4, w5, w6, w7;
/*wire	[127:0]	key_odd,key_even;
*/
reg	[127:0]	text_in_r;
reg	[127:0]	text_out;

reg	[127:0]	text_out_temp;

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
	if(ld)	begin	dcnt <=  4'h6;	 end
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
	.kld(		ld_r	),
	.key(		key	),
	.w0(		w0	),
	.w1(		w1	),
	.w2(		w2	),
	.w3(		w3	),
	.w4_reg(		w4	),
	.w5_reg(		w5	),
	.w6_reg(		w6	),
	.w7_reg(		w7	)
							);
/*assign key_odd  = {w0,w1,w2,w3};
assign key_even = {w4,w5,w6,w7};
*/

/*assign {w0,w1,w2,w3} = 128'h0;

assign {w4,w5,w6,w7} = 128'h62636363626363636263636362636363;
*/							
// Initial Permutation (AddRoundKey)
//
/*
always @(posedge clk)
begin
  w0 <= w0_net;
  w1 <= w1_net;
  w2 <= w2_net;
  w3 <= w3_net;
  w4 <= w4_net;
  w5 <= w5_net;
  w6 <= w6_net;
  w7 <= w7_net;
end
*/
always @(posedge clk) 
begin
   	sa33 <=  ld_r ? text_in_r[007:000] ^ w3[07:00] : sa33_mc_round2 ^ w3[07:00];
    	sa23 <=  ld_r ? text_in_r[015:008] ^ w3[15:08] : sa23_mc_round2 ^ w3[15:08];
    	sa13 <=  ld_r ? text_in_r[023:016] ^ w3[23:16] : sa13_mc_round2 ^ w3[23:16];
    	sa03 <=  ld_r ? text_in_r[031:024] ^ w3[31:24] : sa03_mc_round2 ^ w3[31:24];
    	sa32 <=  ld_r ? text_in_r[039:032] ^ w2[07:00] : sa32_mc_round2 ^ w2[07:00];
    	sa22 <=  ld_r ? text_in_r[047:040] ^ w2[15:08] : sa22_mc_round2 ^ w2[15:08];
    	sa12 <=  ld_r ? text_in_r[055:048] ^ w2[23:16] : sa12_mc_round2 ^ w2[23:16];
    	sa02 <=  ld_r ? text_in_r[063:056] ^ w2[31:24] : sa02_mc_round2 ^ w2[31:24];
    	sa31 <=  ld_r ? text_in_r[071:064] ^ w1[07:00] : sa31_mc_round2 ^ w1[07:00];
    	sa21 <=  ld_r ? text_in_r[079:072] ^ w1[15:08] : sa21_mc_round2 ^ w1[15:08];
    	sa11 <=  ld_r ? text_in_r[087:080] ^ w1[23:16] : sa11_mc_round2 ^ w1[23:16];
    	sa01 <=  ld_r ? text_in_r[095:088] ^ w1[31:24] : sa01_mc_round2 ^ w1[31:24];
    	sa30 <=  ld_r ? text_in_r[103:096] ^ w0[07:00] : sa30_mc_round2 ^ w0[07:00];
    	sa20 <=  ld_r ? text_in_r[111:104] ^ w0[15:08] : sa20_mc_round2 ^ w0[15:08];
    	sa10 <=  ld_r ? text_in_r[119:112] ^ w0[23:16] : sa10_mc_round2 ^ w0[23:16];
    	sa00 <=  ld_r ? text_in_r[127:120] ^ w0[31:24] : sa00_mc_round2 ^ w0[31:24];
		
		/*$strobe($time,": roundkeyodd = %h\n",{w0,w1,w2,w3});
		$strobe($time,": state is %h\n",{sa00, sa01, sa02, sa03,
													 sa10, sa11, sa12, sa13,
													 sa20, sa21, sa22, sa23,
													 sa30, sa31, sa32, sa33});*/
		
end

////////////////////////////////////////////////////////////////////
//
// Modules instantiation
//

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

////////////////////////////////////////////////////////////////////
//
// Round Permutations
//

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


always @(posedge clk)
begin 
	  
	 /* $strobe($time,": roundkeyodd = %h, text_out_odd is %h\n",{w0,w1,w2,w3},text_out_temp);
	  $strobe($time,": roundkeyeven is %h\n",{w4,w5,w6,w7}); 	*/
	  text_out_temp[127:120] <=  sa00_sr ^ w4[31:24];	 
	  text_out_temp[095:088] <=  sa01_sr ^ w5[31:24];	 
          text_out_temp[063:056] <=  sa02_sr ^ w6[31:24];	 
	  text_out_temp[031:024] <=  sa03_sr ^ w7[31:24];	 
	  text_out_temp[119:112] <=  sa10_sr ^ w4[23:16];	 
	  text_out_temp[087:080] <=  sa11_sr ^ w5[23:16];	 
	  text_out_temp[055:048] <=  sa12_sr ^ w6[23:16];	 
	  text_out_temp[023:016] <=  sa13_sr ^ w7[23:16];	 
	  text_out_temp[111:104] <=  sa20_sr ^ w4[15:08];	 
	  text_out_temp[079:072] <=  sa21_sr ^ w5[15:08];	 
	  text_out_temp[047:040] <=  sa22_sr ^ w6[15:08];	 
	  text_out_temp[015:008] <=  sa23_sr ^ w7[15:08];	 
	  text_out_temp[103:096] <=  sa30_sr ^ w4[07:00];	 
	  text_out_temp[071:064] <=  sa31_sr ^ w5[07:00];	 
	  text_out_temp[039:032] <=  sa32_sr ^ w6[07:00];	 
	  text_out_temp[007:000] <=  sa33_sr ^ w7[07:00];    
end




//////////////////////  round i + 1 //////////////////////////////////
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


// Round Permutations
//

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

////////////////////////////////////////////////////////////////////
//
// Final text output
//


always @(posedge clk)
 begin 
		/*  $strobe($time,": round_key2 is %h\n",{w4,w5,w6,w7});
		  $strobe($time,": roundkeyeven = %h, text_out_even is %h\n",{w4,w5,w6,w7},text_out);*/
		  text_out[127:120] <=  sa00_sr_round2 ^ w0[31:24];	 
		  text_out[095:088] <=  sa01_sr_round2 ^ w1[31:24];	 
		  text_out[063:056] <=  sa02_sr_round2 ^ w2[31:24];	 
		  text_out[031:024] <=  sa03_sr_round2 ^ w3[31:24];	 
		  text_out[119:112] <=  sa10_sr_round2 ^ w0[23:16];	 
		  text_out[087:080] <=  sa11_sr_round2 ^ w1[23:16];	 
		  text_out[055:048] <=  sa12_sr_round2 ^ w2[23:16];	 
		  text_out[023:016] <=  sa13_sr_round2 ^ w3[23:16];	 
		  text_out[111:104] <=  sa20_sr_round2 ^ w0[15:08];	 
		  text_out[079:072] <=  sa21_sr_round2 ^ w1[15:08];	 
		  text_out[047:040] <=  sa22_sr_round2 ^ w2[15:08];	 
		  text_out[015:008] <=  sa23_sr_round2 ^ w3[15:08];	 
		  text_out[103:096] <=  sa30_sr_round2 ^ w0[07:00];	 
		  text_out[071:064] <=  sa31_sr_round2 ^ w1[07:00];	 
		  text_out[039:032] <=  sa32_sr_round2 ^ w2[07:00];	 
		  text_out[007:000] <=  sa33_sr_round2 ^ w3[07:00];
	end


/* -----\/----- EXCLUDED -----\/-----
always @(posedge clk)
	begin
/-*	$strobe($time,": text_out_temp is %h\n",text_out_temp);


*-/	/-*
	$strobe($time,": subbytes is %h\n",{sa00_sub, sa01_sub, sa02_sub, sa03_sub,
													 sa10_sub, sa11_sub, sa12_sub, sa13_sub,
													 sa20_sub, sa21_sub, sa22_sub, sa23_sub,
													 sa30_sub, sa31_sub, sa32_sub, sa33_sub});
													 
	$strobe($time,": shiftrows is %h\n",{sa00_sr, sa01_sr, sa02_sr, sa03_sr,
													  sa10_sr, sa11_sr, sa12_sr, sa13_sr,
													  sa20_sr, sa21_sr, sa22_sr, sa23_sr,
													  sa30_sr, sa31_sr, sa32_sr, sa33_sr});
													  
	$strobe($time,": mixcolumn is %h\n",{sa00_mc, sa01_mc, sa02_mc, sa03_mc,
													  sa10_mc, sa11_mc, sa12_mc, sa13_mc,
													  sa20_mc, sa21_mc, sa22_mc, sa23_mc,
													  sa30_mc, sa31_mc, sa32_mc, sa33_mc});
	
	$strobe($time,": sa_next_into_even is %h\n",{sa00_next_round2, sa01_next_round2, sa02_next_round2, sa03_next_round2,
																 sa10_next_round2, sa11_next_round2, sa12_next_round2, sa13_next_round2,
																 sa20_next_round2, sa21_next_round2, sa22_next_round2, sa23_next_round2,
																 sa30_next_round2, sa31_next_round2, sa32_next_round2, sa33_next_round2});
																 
	$strobe($time,": subbytes_e is %h\n",{sa00_sub_round2, sa01_sub_round2, sa02_sub_round2, sa03_sub_round2,
													 sa10_sub_round2, sa11_sub_round2, sa12_sub_round2, sa13_sub_round2,
													 sa20_sub_round2, sa21_sub_round2, sa22_sub_round2, sa23_sub_round2,
													 sa30_sub_round2, sa31_sub_round2, sa32_sub_round2, sa33_sub_round2});
													 
	$strobe($time,": shiftrows_e is %h\n",{sa00_sr_round2, sa01_sr_round2, sa02_sr_round2, sa03_sr_round2,
													  sa10_sr_round2, sa11_sr_round2, sa12_sr_round2, sa13_sr_round2,
													  sa20_sr_round2, sa21_sr_round2, sa22_sr_round2, sa23_sr_round2,
													  sa30_sr_round2, sa31_sr_round2, sa32_sr_round2, sa33_sr_round2});
													  
	$strobe($time,": mixcolumn_e is %h\n",{sa00_mc_round2, sa01_mc_round2, sa02_mc_round2, sa03_mc_round2,
													  sa10_mc_round2, sa11_mc_round2, sa12_mc_round2, sa13_mc_round2,
													  sa20_mc_round2, sa21_mc_round2, sa22_mc_round2, sa23_mc_round2,
													  sa30_mc_round2, sa31_mc_round2, sa32_mc_round2, sa33_mc_round2});																
	*-/															 
	end
	
	
/-*
always @(posedge clk)
       begin
				if(done)
						begin
							text_out_64 <= text_out[127:64];
//							done2 <= 1;
						end
				else if(~done)
							text_out_64 <= text_out[63:0];
		end
	*-/	 
		 
/-*
always @(posedge clk)
			 begin
				if(done2)
					begin
						text_out_64 <= text_out[63:0];
					end	
		 end
*-/		 
 -----/\----- EXCLUDED -----/\----- */
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



