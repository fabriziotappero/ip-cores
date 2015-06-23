/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Twiddle factor ROM for 64-point FFT                        ////
////                                                             ////
////  Authors: Anatoliy Sergienko, Volodya Lepeha                ////
////  Company: Unicore Systems http://unicore.co.ua              ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2006-2010 Unicore Systems LTD                 ////
//// www.unicore.co.ua                                           ////
//// o.uzenkov@unicore.co.ua                                     ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// THIS SOFTWARE IS PROVIDED "AS IS"                           ////
//// AND ANY EXPRESSED OR IMPLIED WARRANTIES,                    ////
//// INCLUDING, BUT NOT LIMITED TO, THE IMPLIED                  ////
//// WARRANTIES OF MERCHANTABILITY, NONINFRINGEMENT              ////
//// AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.        ////
//// IN NO EVENT SHALL THE UNICORE SYSTEMS OR ITS                ////
//// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,            ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL            ////
//// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT         ////
//// OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,               ////
//// DATA, OR PROFITS; OR BUSINESS INTERRUPTION)                 ////
//// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,              ////
//// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT              ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING                 ////
//// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,                 ////
//// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.          ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
// Design_Version       : 1.0
// File name            : WROM64.v
// File Revision        : 
// Last modification    : Sun Sep 30 20:11:56 2007
/////////////////////////////////////////////////////////////////////
// FUNCTION: 1-port synchronous RAM
// FILES:    RAM64.v -single ported synchronous RAM
// PROPERTIES:
//1) Has 64 complex coefficients which form a table 8x8,
//and stay in the needed order, as they are addressed
//by the simple counter 
//2) 16-bit values are stored. When shorter bit width is set
//then rounding	is not used
//3) for FFT and IFFT depending on paramifft	       
/////////////////////////////////////////////////////////////////////

`timescale 1ps / 1ps
`include "FFT64_CONFIG.inc"	 

module WROM64 ( WI ,WR ,ADDR );
	`USFFT64paramnw	
	
	input [5:0] ADDR ;
	wire [5:0] ADDR ;
	
	output [nw-1:0] WI ;
	wire [nw-1:0] WI ;
	output [nw-1:0] WR ;
	wire [nw-1:0] WR ;
	
	parameter signed  [15:0] c0 = 16'h7fff;  
	parameter signed  [15:0] s0 = 16'h0000;   
	parameter signed  [15:0] c1 = 16'h7f62;   
	parameter signed  [15:0] s1 = 16'h0c8c;   
	parameter signed  [15:0] c2 = 16'h7d8a;   
	parameter signed  [15:0] s2 = 16'h18f9 ;   
	parameter signed  [15:0] c3 = 16'h7a7d;   
	parameter signed  [15:0] s3 = 16'h2528;   
	parameter signed  [15:0] c4 = 16'h7642;   
	parameter signed  [15:0] s4 = 16'h30fc;   
	parameter signed  [15:0] c5 = 16'h70e3;   
	parameter signed  [15:0] s5 = 16'h3c57;   
	parameter signed  [15:0] c6 = 16'h6a6e;   
	parameter signed  [15:0] s6 = 16'h471d ;   
	parameter signed  [15:0] c7 = 16'h62f2;   
	parameter signed  [15:0] s7 = 16'h5134;   
	parameter signed  [15:0] c8 = 16'h5a82;   
	
	parameter[31:0] w0= {c0,-s0};   
	parameter[31:0] w1= {c1,-s1};
	parameter[31:0] w2= {c2,-s2};
	parameter[31:0] w3= {c3,-s3};
	parameter[31:0] w4= {c4,-s4};
	parameter[31:0] w5= {c5,-s5};
	parameter[31:0] w6= {c6,-s6};
	parameter[31:0] w7= {c7,-s7};
	parameter[31:0] w8= {c8,-c8};
	parameter[31:0] w9= {s7,-c7};
	parameter[31:0] w10= {s6,-c6};
	parameter[31:0] w12= {s4,-c4};
	parameter[31:0] w14= {s2,-c2};
	parameter[31:0] w15= {s1,-c1};
	parameter[31:0] w16= {s0,-c0};
	parameter[31:0] w18= {-s2, -c2};
	parameter[31:0] w20= {-s4, -c4};
	parameter[31:0] w21= {-s5, -c5};
	parameter[31:0] w24= {-c8, -c8};
	parameter[31:0] w25= {-c7, -s7};
	parameter[31:0] w28= {-c4, -s4};
	parameter[31:0] w30= {-c2, -s2};
	parameter[31:0] w35= {-c3, s3};
	parameter[31:0] w36= {-c4, s4};
	parameter[31:0] w42= {-s6, c6};
	parameter[31:0] w49= {s1, c1};
	
	reg [31:0] wf [0:63] ;	 
	integer	i;
	
	always@(ADDR) begin
			//(w0, w0, w0,  w0,  w0,  w0,  w0,  w0,	 	0..7 // twiddle factors for FFT
			//	w0, w1, w2,  w3,  w4,  w5,  w6,  w7,   	8..15
			//	w0, w2, w4,  w6,  w8,  w10,w12,w14,	16..23
			//	w0, w3, w6,  w9,  w12,w15,w18,w21,	24..31
			//	w0, w4, w8,  w12,w16,w20,w24,w28,	32..47
			//	w0, w5, w10,w15,w20,w25,w30,w35,
			//	w0, w6, w12,w18,w24,w30,w36,w42,
			//	w0, w7, w14,w21,w28,w35,w42,w49);																
			for( i =0; i<8; i=i+1) 	 wf[i] =w0;					
			for( i =8; i<63; i=i+8)  wf[i] =w0;					
			wf[9] =w1 ; wf[10] =w2 ;    wf[11] =w3 ;wf[12] =w4 ;
			wf[13] =w5 ;wf[14] =w6 ;   wf[15] =w7 ;
			wf[17] =w2 ;wf[18] =w4 ;   wf[19] =w6 ;wf[20] =w8 ;
			wf[21] =w10 ;wf[22] =w12 ;wf[23] =w14;
			wf[25] =w3 ;wf[26] =w6 ;   wf[27] =w9 ;wf[28] =w12 ;
			wf[29] =w15 ;wf[30] =w18 ;wf[31] =w21;
			wf[33] =w4 ;wf[34] =w8 ;	wf[35] =w12 ;wf[36] =w16 ;
			wf[37] =w20 ;wf[38] =w24 ;wf[39] =w28;
			wf[41] =w5 ;wf[42] =w10 ;	wf[43] =w15 ;wf[44] =w20 ;
			wf[45] =w25 ;wf[46] =w30 ;wf[47] =w35;
			wf[49] =w6 ;wf[50] =w12 ;	wf[51] =w18 ;wf[52] =w24 ;
			wf[53] =w30 ;wf[54] =w36 ;wf[55] =w42;
			wf[57] =w7 ;wf[58] =w14 ;	wf[59] =w21 ;wf[60] =w28 ;
			wf[61] =w35 ;wf[62] =w42 ;wf[63] =w49;
		end
	
	parameter[31:0] wi0= {c0,s0};   
	parameter[31:0] wi1= {c1,s1};
	parameter[31:0] wi2= {c2,s2};
	parameter[31:0] wi3= {c3,s3};
	parameter[31:0] wi4= {c4,s4};
	parameter[31:0] wi5= {c5,s5};
	parameter[31:0] wi6= {c6,s6};
	parameter[31:0] wi7= {c7,s7};
	parameter[31:0] wi8= {c8,c8};
	parameter[31:0] wi9= {s7,c7};
	parameter[31:0] wi10= {s6,c6};
	parameter[31:0] wi12= {s4,c4};
	parameter[31:0] wi14= {s2,c2};
	parameter[31:0] wi15= {s1,c1};
	parameter[31:0] wi16= {s0,c0};
	parameter[31:0] wi18= {-s2, c2};
	parameter[31:0] wi20= {-s4, c4};
	parameter[31:0] wi21= {-s5, c5};
	parameter[31:0] wi24= {-c8, c8};
	parameter[31:0] wi25= {-c7, s7};
	parameter[31:0] wi28= {-c4, s4};
	parameter[31:0] wi30= {-c2, s2};
	parameter[31:0] wi35= {-c3, -s3};
	parameter[31:0] wi36= {-c4, -s4};
	parameter[31:0] wi42= {-s6, -c6};
	parameter[31:0] wi49= {s1, -c1};		 
	
	reg [31:0] wb [0:63] ;	 
	always@(ADDR) begin
	//initial begin #10;	
			//(w0, w0, w0,  w0,  w0,  w0,  w0,  w0,	 	 // twiddle factors for IFFT
			for( i =0; i<8; i=i+1) 	 wb[i] =wi0;					
			for( i =8; i<63; i=i+8)  wb[i] =wi0;					
			wb[9] =wi1 ; wb[10] =wi2 ;    wb[11] =wi3 ;wb[12] =wi4 ;
			wb[13] =wi5 ;wb[14] =wi6 ;   wb[15] =wi7 ;
			wb[17] =wi2 ;wb[18] =wi4 ;   wb[19] =wi6 ;wb[20] =wi8 ;
			wb[21] =wi10 ;wb[22] =wi12 ;wb[23] =wi14;
			wb[25] =wi3 ;wb[26] =wi6 ;   wb[27] =wi9 ;wb[28] =wi12 ;
			wb[29] =wi15 ;wb[30] =wi18 ;wb[31] =wi21;
			wb[33] =wi4 ;wb[34] =wi8 ;	wb[35] =wi12 ;wb[36] =wi16 ;
			wb[37] =wi20 ;wb[38] =wi24 ;wb[39] =wi28;
			wb[41] =wi5 ;wb[42] =wi10 ;	wb[43] =wi15 ;wb[44] =wi20 ;
			wb[45] =wi25 ;wb[46] =wi30 ;wb[47] =wi35;
			wb[49] =wi6 ;wb[50] =wi12 ;	wb[51] =wi18 ;wb[52] =wi24 ;
			wb[53] =wi30 ;wb[54] =wi36 ;wb[55] =wi42;
			wb[57] =wi7 ;wb[58] =wi14 ;	wb[59] =wi21 ;wb[60] =wi28 ;
			wb[61] =wi35 ;wb[62] =wi42 ;wb[63] =wi49;
		end	  
	
	wire[31:0] reim;		
	
	`ifdef USFFT64paramifft
	assign reim = wb[ADDR];
	`else
	assign reim = wf[ADDR];
	`endif
	
	assign WR =reim[31:32-nw];
	assign WI=reim[15 :16-nw];
	
	
endmodule
