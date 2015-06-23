//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "decoder_8b10b.v"                                 ////
////                                                              ////
////  This file is part of the :                                  ////
////                                                              ////
//// "1000BASE-X IEEE 802.3-2008 Clause 36 - PCS project"         ////
////                                                              ////
////  http://opencores.org/project,1000base-x                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - D.W.Pegler Cambridge Broadband Networks Ltd           ////
////                                                              ////
////      { peglerd@gmail.com, dwp@cambridgebroadand.com }        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 AUTHORS. All rights reserved.             ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// This module is based on the coding method described in       ////
//// IEEE Std 802.3-2008 Section 36.2.4 which is available from : ////
////                                                              ////
//// http://standards.ieee.org/about/get/802/802.3.html           ////
////                                                              ////
//// and the 8B/10B coding scheme from the 1993 IBM publication   ////
//// "DC-Balanced, Partitioned-Block, 8B/10B Transmission Code"   ////
//// by A.X. Widmer and P.A. Franasze" see doc/01-581v1.pdf       ////
////                                                              ////
//// and US patent #4,486,739 "BYTE ORIENTED DC BALANCED          ////
//// (0,4) 8B/10B PARTITIONED BLOCK TRANSMISSION CODE "; see :    ////
////                                                              ////
//// doc/US4486739.pdf                                            ////
////                                                              ////
//// http://en.wikipedia.org/wiki/8b/10b_encoding                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////


`include "timescale.v"

module decoder_8b10b (
		  
   // --- Resets ---
   input reset,

   // --- Clocks ---
   input RBYTECLK,
		  
   // --- TBI (Ten Bit Interface) input bus
   input [9:0] tbi,

   // --- Control (K)
   output reg K_out,
		  
   // -- Eight bit output bus
   output reg [7:0] ebi,

   // --- 8B/10B RX coding error ---
   output reg coding_err,
		 
   // --- 8B/10B RX disparity ---
   output reg disparity,
   
   // --- 8B/10B RX disparity error ---
   output disparity_err
  
  );
   
`ifdef MODEL_TECH
   // ModelSim debugging only 
   wire [4:0] decoder_8b_X;  wire [2:0] decoder_8b_Y;
   
   assign     decoder_8b_X = ebi[4:0];
   assign     decoder_8b_Y = ebi[7:5];
`endif    
   
   wire   a,b,c,d,e,i,f,g,h,j;  // 10 Bit inputs
 
   assign {a,b,c,d,e,i,f,g,h,j} = tbi[9:0];
   
   // ******************************************************************************
   // Figure 10 - Decoder: 6b - Signals
   // ******************************************************************************
   wire 	AEQB, CEQD, P22, P13, P31;
   
   // ******************************************************************************
   // Figure 11 - Decoder: K - Signals
   // ******************************************************************************
   
   wire 	eeqi, c_d_e_i, cn_dn_en_in;
   
   wire 	P22_a_c_eeqi, P22_an_cn_eeqi;
   
   wire 	P22_b_c_eeqi, P22_bn_cn_eeqi, an_bn_en_in;
   
   wire 	a_b_e_i, P13_d_e_i, P13_in, P13_en, P31_i;

   // ******************************************************************************
   // Figure 12 - Decoder: 5B - Signals   
   // ******************************************************************************
   
   wire 	OR12_1, OR12_2, OR12_3, OR12_4, OR12_5, OR12_6, OR12_7;
   
   wire 	A, B, C, D, E;

   // ******************************************************************************
   // Figure 13 - Decoder: 3B - Signals
   // ******************************************************************************
   
   wire  	K, F, G, H, K28p, KA, KB, KC;
   
   // ******************************************************************************
   // Figure 10 - Decoder: 6b Input Function
   // ******************************************************************************

   assign 	AEQB = (a & b) | (!a & !b) ;
   assign 	CEQD = (c & d) | (!c & !d) ;
   assign 	P22 = (a & b & !c & !d) | (c & d & !a & !b) | ( !AEQB & !CEQD) ;
   assign 	P13 = ( !AEQB & !c & !d) | ( !CEQD & !a & !b) ;
   assign 	P31 = ( !AEQB & c & d) | ( !CEQD & a & b) ;
   
   // ******************************************************************************
   // Figure 11 - Decoder: K 
   // ******************************************************************************
   
   assign 	eeqi = (e == i);
   
   assign 	P22_a_c_eeqi   = P22 & a & c & eeqi;
   assign 	P22_an_cn_eeqi = P22 & !a & !c & eeqi;

   assign 	cn_dn_en_in = (!c & !d & !e & !i);
   assign 	c_d_e_i     = (c & d & e & i);
   
   assign 	KA = c_d_e_i | cn_dn_en_in;
   assign 	KB = P13 & (!e & i & g & h & j);
   assign 	KC = P31 & (e & !i & !g & !h & !j);
   
   assign 	K = KA | KB | KC;

   assign 	P22_b_c_eeqi   = P22 & b & c & eeqi;
   assign 	P22_bn_cn_eeqi = P22 & !b & !c & eeqi;
   assign 	an_bn_en_in    = !a & !b & !e & !i;
   assign 	a_b_e_i        = a & b & e & i;
   assign 	P13_d_e_i      = P13 & d & e & i;
   assign 	P13_in         = P13 & !i;
   assign 	P13_en         = P13 & !e;
   assign 	P31_i          = P31 & i;


   // ******************************************************************************
   // Figure 12 - Decoder: 5B/6B
   // ******************************************************************************

   assign 	OR12_1 = P22_an_cn_eeqi | P13_en;
   assign 	OR12_2 = a_b_e_i | cn_dn_en_in | P31_i;
   assign 	OR12_3 = P31_i | P22_b_c_eeqi | P13_d_e_i;
   assign 	OR12_4 = P22_a_c_eeqi | P13_en;
   assign 	OR12_5 = P13_en | cn_dn_en_in | an_bn_en_in;
   assign 	OR12_6 = P22_an_cn_eeqi | P13_in;
   assign 	OR12_7 = P13_d_e_i | P22_bn_cn_eeqi;
   
   assign 	A = a ^ (OR12_7 | OR12_1 | OR12_2);
   assign 	B = b ^ (OR12_2 | OR12_3 | OR12_4);
   assign 	C = c ^ (OR12_1 | OR12_3 | OR12_5);
   assign 	D = d ^ (OR12_2 | OR12_4 | OR12_7);
   assign 	E = e ^ (OR12_5 | OR12_6 | OR12_7);
   
   // ******************************************************************************
   // Figure 13 - Decoder: 3B/4B
   // ******************************************************************************
   
   // K28 with positive disp into fghi - .1, .2, .5, and .6 specal cases
   assign 	K28p = ! (c | d | e | i) ;
   
   assign 	F = (j & !f & (h | !g | K28p)) | (f & !j & (!h | g | !K28p)) | (K28p & g & h) | (!K28p & !g & !h) ;
   
   assign 	G = (j & !f & (h | !g | !K28p)) | (f & !j & (!h | g |K28p)) | (!K28p & g & h) | (K28p & !g & !h) ;
   
   assign 	H = ((j ^ h) & ! ((!f & g & !h & j & !K28p) | (!f & g & h & !j & K28p) | 
				  (f & !g & !h & j & !K28p) | (f & !g & h & !j & K28p))) | (!f & g & h & j) | (f & !g & !h & !j) ;

   // ******************************************************************************
   // Registered 8B output
   // ******************************************************************************

   always @(posedge RBYTECLK or posedge reset)
     if (reset)
       begin
	  K_out <= 0; ebi[7:0] <= 8'b0; 
       end
     else 
       begin
	  K_out <= K; ebi[7:0] <= { H, G, F, E, D, C, B, A } ;
       end
   
   // ******************************************************************************
   // Disparity 
   // ******************************************************************************

   wire heqj, fghjP13, fghjP31, fghj22;
   
   wire DISPARITY6p, DISPARITY6n, DISPARITY4p, DISPARITY4n;
   
   wire DISPARITY6b, DISPARITY6a2, DISPARITY6a0;
   
   assign 	feqg = (f & g) | (!f & !g); 
   assign 	heqj = (h & j) | (!h & !j);
   
   assign 	fghjP13 = ( !feqg & !h & !j) | ( !heqj & !f & !g) ;
   assign 	fghjP31 = ( (!feqg) & h & j) | ( !heqj & f & g) ;
   assign 	fghj22 = (f & g & !h & !j) | (!f & !g & h & j) | ( !feqg & !heqj) ;
   
   assign 	DISPARITY6p = (P31 & (e | i)) | (P22 & e & i) ;   
   assign 	DISPARITY6n = (P13 & ! (e & i)) | (P22 & !e & !i);
   
   assign 	DISPARITY4p = fghjP31 ;
   assign 	DISPARITY4n = fghjP13 ;
  
   assign 	DISPARITY6a  = P31 | (P22 & disparity); // pos disp if P22 and was pos, or P31.
   assign 	DISPARITY6a2 = P31 & disparity;         // disp is ++ after 4 bts
   assign 	DISPARITY6a0 = P13 & ! disparity;       // -- disp after 4 bts
   
   assign 	DISPARITY6b = (e & i & ! DISPARITY6a0) | (DISPARITY6a & (e | i)) | DISPARITY6a2;
   
   
   // ******************************************************************************
   // Disparity errors
   // ******************************************************************************
   
   wire 	derr1,derr2,derr3,derr4,derr5,derr6,derr7,derr8;
   
   assign derr1 = (disparity & DISPARITY6p) | (DISPARITY6n & !disparity);
   assign derr2 = (disparity & !DISPARITY6n & f & g);
   assign derr3 = (disparity & a & b & c);
   assign derr4 = (disparity & !DISPARITY6n & DISPARITY4p);
   assign derr5 = (!disparity & !DISPARITY6p & !f & !g);
   assign derr6 = (!disparity & !a & !b & !c);
   assign derr7 = (!disparity & !DISPARITY6p & DISPARITY4n);
   assign derr8 = (DISPARITY6p & DISPARITY4p) | (DISPARITY6n & DISPARITY4n);
   
   // ******************************************************************************
   // Register disparity and disparity_err output
   // ******************************************************************************

   reg derr12, derr34, derr56, derr78;

   always @(posedge RBYTECLK or posedge reset)
     if (reset)
       begin
          disparity <= 1'b0;
          derr12 <= 1;
          derr34 <= 1;
          derr56 <= 1;
          derr78 <= 1;
       end
     else
       begin
	  disparity <= fghjP31 | (DISPARITY6b & fghj22) ;

          derr12 <= derr1 | derr2;
          derr34 <= derr3 | derr4;
          derr56 <= derr5 | derr6;
          derr78 <= derr7 | derr8;
       end

   assign disparity_err = derr12|derr34|derr56|derr78;

   // ******************************************************************************
   // Coding errors as defined in patent - page 447
   // ******************************************************************************

   wire cerr1, cerr2, cerr3, cerr4, cerr5, cerr6, cerr7, cerr8, cerr9;
   
   assign cerr1 = (a &  b &  c &  d) | (!a & !b & !c & !d);
   assign cerr2 = (P13 & !e & !i);
   assign cerr3 = (P31 & e & i);
   assign cerr4 = (f & g & h & j) | (!f & !g & !h & !j);
   assign cerr5 = (e & i & f & g & h) | (!e & !i & !f & !g & !h);
   assign cerr6 = (e & !i & g & h & j) | (!e & i & !g & !h & !j);
   assign cerr7 = (((e & i & !g & !h & !j) | (!e & !i & g & h & j)) & !((c & d & e) | (!c & !d & !e)));
   assign cerr8 = (!P31 & e & !i & !g & !h & !j);
   assign cerr9 = (!P13 & !e & i & g & h & j);

   reg 	  cerr;
   
   always @(posedge RBYTECLK or posedge reset)
     if (reset)
       cerr <= 0;
     else
       cerr <= cerr1|cerr2|cerr3|cerr4|cerr5|cerr6|cerr7|cerr8|cerr9;
   
   // ******************************************************************************
   // Disparity coding errors curtosy of http://asics.chuckbenz.com/decode.v
   // ******************************************************************************
   
   wire   zerr1, zerr2, zerr3;
   
   assign zerr1 = (DISPARITY6p & DISPARITY4p) | (DISPARITY6n & DISPARITY4n);
   assign zerr2 = (f & g & !h & !j & DISPARITY6p);
   assign zerr3 = (!f & !g & h & j & DISPARITY6n);

   reg 	  zerr;
   
   always @(posedge RBYTECLK or posedge reset)
     if (reset)
       zerr <= 0;
     else
       zerr <= zerr1|zerr2|zerr3;
   
   // ******************************************************************************
   // Extra coding errors - again from http://asics.chuckbenz.com/decode.v
   // ******************************************************************************
   
   wire   xerr1, xerr2, xerr3, xerr4;

   reg 	  xerr;
   
   assign xerr1 = (a & b & c & !e & !i & ((!f & !g) | fghjP13));
   assign xerr2 =(!a & !b & !c & e & i & ((f & g) | fghjP31));
   assign xerr3 = (c & d & e & i & !f & !g & !h);
   assign xerr4 = (!c & !d & !e & !i & f & g & h);

   always @(posedge RBYTECLK or posedge reset)
     if (reset)
       xerr <= 0;
     else
       xerr <= xerr1|xerr2|xerr3|xerr4;
   
   // ******************************************************************************
   // Registered Coding error output
   // ******************************************************************************
   
   always @(posedge RBYTECLK or posedge reset)
     if (reset) 
       coding_err <= 1'b1;
     else   
       coding_err <= cerr | zerr | xerr;
   
endmodule
