//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Top module for HIGHT Crypto Core                            ////
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

module HIGHT_CORE_TOP(
	rstn         , 
	clk          ,  
	
	i_mk_rdy     ,  
	i_mk         ,  

	i_post_rdy   ,  

	i_op         ,  

	i_text_val   ,  
	i_text_in    ,  

	o_text_done  ,  
	o_text_out   , 
     
	o_rdy            
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
input        rstn         ; 
input        clk          ;  

input        i_mk_rdy     ;  
input[127:0] i_mk         ;  

input        i_post_rdy   ;  

input        i_op         ;  

input        i_text_val   ;  
input[63:0]  i_text_in    ;  

output       o_text_done  ;  
output[63:0] o_text_out   ;  

output       o_rdy        ;       


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
wire[31:0]  w_rnd_key     ; 

wire[2:0]   w_xf_sel      ;
wire        w_rf_final    ;

wire        w_key_sel     ;
wire[4:0]   w_rnd_idx     ;
wire        w_wf_post_pre ;


//=====================================
//
//          MAIN
//
//=====================================
// CYPTO_PATH instance 
CRYPTO_PATH u_CRYPTO_PATH(
	.rstn           ( rstn          ) ,   
	.clk            ( clk           ) ,  

	.i_op           ( i_op          ) ,  

	.i_wrsk         ( w_rnd_key     ) ,   

	.i_text_in      ( i_text_in     ) ,  
	
	.i_xf_sel       ( w_xf_sel      ) ,   
	.i_rf_final     ( w_rf_final    ) ,  

	.o_text_out     ( o_text_out    )    
);


// KEY_SCHED instance
KEY_SCHED u_KEY_SCHED(
	.rstn           ( rstn          ) , 
	.clk            ( clk           ) ,  
	
	.i_mk           ( i_mk          ) ,  

	.i_op           ( i_op          ) ,  

	.i_key_sel      ( w_key_sel     ) , 
	.i_rnd_idx      ( w_rnd_idx     ) , 
	.i_wf_post_pre  ( w_wf_post_pre ) , 

	.o_rnd_key      ( w_rnd_key     )   
);


// CONTROL instance
CONTROL u_CONTROL(
	.rstn           ( rstn          ) ,   
	.clk            ( clk           ) ,   

	.i_mk_rdy       ( i_mk_rdy      ) , 
	.i_post_rdy     ( i_post_rdy    ) , 
	.i_text_val     ( i_text_val    ) ,  


	.o_rdy          ( o_rdy         ) ,  
	.o_text_done    ( o_text_done   ) ,  

	.o_xf_sel       ( w_xf_sel      ) , 
	.o_rf_final     ( w_rf_final    ) ,  

	.o_key_sel      ( w_key_sel     ) ,  
	.o_rnd_idx      ( w_rnd_idx     ) ,   
	.o_wf_post_pre  ( w_wf_post_pre )     
);


endmodule


