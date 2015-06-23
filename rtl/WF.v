//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Whitening function of main datapath for HIGHT Crypto Core   ////
////                                                              ////
////  This file is part of the HIGHT Crypto Core project          ////
////  http://github.com/OpenSoCPlus/hight_crypto_core             ////
////  http://www.opencores.org/project,hight                      ////
////                                                              ////
////  Description                                                 ////
////  __description__                                             ////
////                                                              ////
////  Author(s):                                                  ////
////      - JoonSoo Ha, json.ha@gmail.com                         ////
////      - Younjoo Kim, younjookim.kr@gmail.com                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2015 Authors, OpenSoCPlus and OPENCORES.ORG    ////
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

module WF(
	
	i_op        ,  

	i_wf_in     ,  
	
	i_wk        ,   
	
	o_wf_out          
);


//=====================================
//
//          PARAMETERS 
//
//=====================================


//=====================================
//
//          I/O PORTS 
//
//=====================================

input        i_op           ;  

input[63:0]  i_wf_in        ;  
	
input[31:0]  i_wk           ;   

output[63:0] o_wf_out       ;  


//=====================================
//
//          REGISTERS
//
//=====================================


//=====================================
//
//          WIRES
//
//=====================================
// w_wf_out
wire[63:0]  w_wf_out     ;
// w_rf_out(7:0)
wire[7:0]  w_wf_out7     ;  
wire[7:0]  w_wf_out6     ;  
wire[7:0]  w_wf_out5     ;  
wire[7:0]  w_wf_out4     ;  
wire[7:0]  w_wf_out3     ;  
wire[7:0]  w_wf_out2     ;  
wire[7:0]  w_wf_out1     ;  
wire[7:0]  w_wf_out0     ;  

//=====================================
//
//          MAIN
//
//=====================================

assign w_wf_out7 = i_wf_in[63:56];
assign w_wf_out6 = i_wf_in[55:48] ^ i_wk[31:24];
assign w_wf_out5 = i_wf_in[47:40];
assign w_wf_out4 = (i_op == 0) ? (i_wf_in[39:32] + i_wk[23:16]) : 
                                 (i_wf_in[39:32] - i_wk[23:16]) ;
assign w_wf_out3 = i_wf_in[31:24];
assign w_wf_out2 = i_wf_in[23:16] ^ i_wk[15:8];
assign w_wf_out1 = i_wf_in[15:8];
assign w_wf_out0 = (i_op == 0) ? (i_wf_in[7:0] + i_wk[7:0]) : 
                                 (i_wf_in[7:0] - i_wk[7:0]) ; 

assign w_wf_out = {w_wf_out7, w_wf_out6, w_wf_out5, w_wf_out4, w_wf_out3, w_wf_out2, w_wf_out1, w_wf_out0}; 
assign o_wf_out = w_wf_out;

endmodule


