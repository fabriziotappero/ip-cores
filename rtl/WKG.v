//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Whitening key generator of key scheduler                    ////
////  for HIGHT Crypto Core                                       ////
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

module WKG(
	i_op          , 

	i_wf_post_pre ,
	
	i_mk3to0      ,
	i_mk15to12    , 

	o_wk3_7       ,  
	o_wk2_6       ,   
	o_wk1_5       ,  
	o_wk0_4         
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
input       i_op          ; 

input       i_wf_post_pre ;

input[31:0] i_mk3to0      ;
input[31:0] i_mk15to12    ; 

output[7:0] o_wk3_7       ;  
output[7:0] o_wk2_6       ;   
output[7:0] o_wk1_5       ;  
output[7:0] o_wk0_4       ; 


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
wire        w_out_sel;


//=====================================
//
//          MAIN
//
//=====================================
// w_out_sel
assign      w_out_sel = i_op ^ i_wf_post_pre; // 0 if 2 signals have same value
                                              // 1 if 2 signals hava different value

// o_wk3_7
assign      o_wk3_7 = (~w_out_sel) ? i_mk15to12[31:24] : // w_out_sel == 0
                                     i_mk3to0[31:24]   ; // w_out_sel == 1 
// o_wk2_6
assign      o_wk2_6 = (~w_out_sel) ? i_mk15to12[23:16] : // w_out_sel == 0
                                     i_mk3to0[23:16]   ; // w_out_sel == 1 
// o_wk1_5
assign      o_wk1_5 = (~w_out_sel) ? i_mk15to12[15:8]  : // w_out_sel == 0
                                     i_mk3to0[15:8]    ; // w_out_sel == 1  
// o_wk0_4
assign      o_wk0_4 = (~w_out_sel) ? i_mk15to12[7:0]   : // w_out_sel == 0
                                     i_mk3to0[7:0]     ; // w_out_sel == 1  

endmodule








