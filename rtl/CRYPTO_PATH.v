//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Main datapath for HIGHT Crypto Core                         ////
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

module CRYPTO_PATH(
	rstn             ,   
	clk              ,  

	i_op             ,   

	i_wrsk           , 

	i_text_in        ,  
	
	i_xf_sel         ,   
	i_rf_final       ,  

	o_text_out          
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
input        rstn           ; 
input        clk            ;  

input        i_op           ;  

input[31:0]  i_wrsk         ;  

input[63:0]  i_text_in      ;  
	
input[2:0]   i_xf_sel       ;   
input        i_rf_final     ;  

output[63:0] o_text_out     ;  


//=====================================
//
//          REGISTERS
//
//=====================================
// xf register
reg[63:0]   r_xf         ;


//=====================================
//
//          WIRES
//
//=====================================
// wf_in mux
wire[63:0]  w_wf_in_mux  ;
// w_wf_out
wire[63:0]  w_wf_out     ;
// w_rf_out
wire[63:0]  w_rf_out     ;  
// xf mux
wire[63:0]  w_xf_mux   ; 

//=====================================
//
//          MAIN
//
//=====================================
// WF(WhiteningFunction) instance
WF u_WF(
	.i_op        ( i_op        )  ,
	.i_wk        ( i_wrsk      )  ,
	.i_wf_in     ( w_wf_in_mux )  ,
	
	.o_wf_out    ( w_wf_out    )   
);

// RF(RoundFunction) instance
RF u_RF(
	.i_op        ( i_op        )  , 
	.i_rf_final  ( i_rf_final  )  ,
	.i_rf_in     ( r_xf        )  ,
	.i_rsk       ( i_wrsk      )  ,

	.o_rf_out    ( w_rf_out    )    
);

// wf_in mux 
assign      w_wf_in_mux = (~i_xf_sel[2]) ? r_xf      :  // i_xf_sel[2] == 0
                                           i_text_in ;  // i_xf_sel[2] == 1

// xf mux
assign      w_xf_mux   = (i_xf_sel[1:0] == 2'b00) ? r_xf      : // i_xf_sel[1:0] == 0
                         (i_xf_sel[1:0] == 2'b01) ? w_wf_out  : // i_xf_sel[1:0] == 1
                                                    w_rf_out  ; // i_xf_sel[1:0] == 2, 3

// xf register 
always @(negedge rstn or posedge clk)
	if(~rstn) 
		r_xf <= #1 64'h0     ;
	else
		r_xf <= #1 w_xf_mux  ; 

// o_text_out
assign      o_text_out = r_xf;

endmodule


