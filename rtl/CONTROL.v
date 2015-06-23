//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Control module for HIGHT Crypto Core                        ////
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

module CONTROL(
	rstn           ,   
	clk            ,   

	i_mk_rdy       , 
	i_post_rdy     , 
	i_text_val     ,  

	o_rdy          ,  
	o_text_done    ,  

	o_xf_sel       , 
	o_rf_final     ,  

	o_key_sel      ,  
	o_rnd_idx      ,   
	o_wf_post_pre      
);


//=====================================
//
//          PARAMETERS 
//
//=====================================
localparam  S_IDLE       = 6'b1_10000;
localparam  S_KEY_CONFIG = 6'b1_00000;
localparam  S_RDY        = 6'b0_00000;
localparam  S_WF1        = 6'b0_00001;
localparam  S_RF1        = 6'b0_00010;
localparam  S_RF2        = 6'b0_00011;
localparam  S_RF3        = 6'b0_00100;
localparam  S_RF4        = 6'b0_00101;
localparam  S_RF5        = 6'b0_00110;
localparam  S_RF6        = 6'b0_00111;
localparam  S_RF7        = 6'b0_01000;
localparam  S_RF8        = 6'b0_01001;
localparam  S_RF9        = 6'b0_01010;
localparam  S_RF10       = 6'b0_01011;
localparam  S_RF11       = 6'b0_01100;
localparam  S_RF12       = 6'b0_01101;
localparam  S_RF13       = 6'b0_01110;
localparam  S_RF14       = 6'b0_01111;
localparam  S_RF15       = 6'b0_10000;
localparam  S_RF16       = 6'b0_10001;
localparam  S_RF17       = 6'b0_10010;
localparam  S_RF18       = 6'b0_10011;
localparam  S_RF19       = 6'b0_10100;
localparam  S_RF20       = 6'b0_10101;
localparam  S_RF21       = 6'b0_10110;
localparam  S_RF22       = 6'b0_10111;
localparam  S_RF23       = 6'b0_11000;
localparam  S_RF24       = 6'b0_11001;
localparam  S_RF25       = 6'b0_11010;
localparam  S_RF26       = 6'b0_11011;
localparam  S_RF27       = 6'b0_11100;
localparam  S_RF28       = 6'b0_11101;
localparam  S_RF29       = 6'b0_11110;
localparam  S_RF30       = 6'b0_11111;
localparam  S_RF31       = 6'b1_11111;
localparam  S_RF32       = 6'b1_11110;
localparam  S_DONE       = 6'b1_11100;
localparam  S_ERROR      = 6'b1_01010;


//=====================================
//
//          I/O PORTS 
//
//=====================================
input        rstn           ; 
input        clk            ;  

input        i_mk_rdy       ; 
input        i_post_rdy     ; 
input        i_text_val     ;  

output       o_rdy          ;  
output       o_text_done    ;  

output[2:0]  o_xf_sel       ; 
output       o_rf_final     ;  

output       o_key_sel      ;  
output[4:0]  o_rnd_idx      ;        	
output       o_wf_post_pre  ;    


//=====================================
//
//          REGISTERS
//
//=====================================
// state register
reg[5:0]    r_pstate        ;


//=====================================
//
//          WIRES
//
//=====================================
// nstate
reg[5:0]    w_nstate        ;


//=====================================
//
//          MAIN
//
//=====================================
// state register
always @(negedge rstn or posedge clk)
	if(~rstn) 
		r_pstate <= #1 S_IDLE  ;
	else
		r_pstate <= #1 w_nstate;


// nstate
always @(i_mk_rdy or i_text_val or i_post_rdy or r_pstate)
	case(r_pstate)
	S_IDLE       : 
	               begin
	                   if(i_mk_rdy)
	                       w_nstate <= S_RDY;
	                   else
	                       w_nstate <= S_KEY_CONFIG;
	               end	
	S_KEY_CONFIG : 
	               begin
	                   if(i_mk_rdy)
	                       w_nstate <= S_RDY;
	                   else
	                       w_nstate <= r_pstate;
	               end
	S_RDY        : 
	               begin
	                   if(i_text_val)
	                       if(i_mk_rdy)
	                           w_nstate <= S_WF1;
	                       else // ~i_mk_rdy
	                           w_nstate <= S_ERROR;
	                   else // ~i_text_val
	                       if(i_mk_rdy)
	                           w_nstate <= r_pstate;
	                       else // ~i_mk_rdy
	                           w_nstate <= S_KEY_CONFIG;
	               end
	S_WF1        : 
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF1;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF1        : 
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF2;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF2        : 
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF3;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF3        : 
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF4;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF4        :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF5;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF5        : 
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF6;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF6        :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF7;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF7        :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF8;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF8        :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF9;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF9        :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF10;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF10       :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF11;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF11       :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF12;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF12       : 
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF13;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF13       :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF14;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF14       :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF15;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF15       :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF16;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF16       :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF17;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF17       :   
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF18;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF18       :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF19;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF19       :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF20;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF20       :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF21;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF21       :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF22;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF22       :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF23;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF23       :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF24;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF24       : 
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF25;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF25       :   
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF26;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF26       :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF27;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF27       :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF28;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF28       :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF29;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF29       :   
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF30;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF30       :   
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF31;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF31       :  
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_RF32;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_RF32       :   
	               begin
	                   if(i_mk_rdy)
	                       w_nstate     <= S_DONE;
	                   else
	                       w_nstate     <= S_ERROR;
	               end
	S_DONE       :  
	               begin
	                   if(i_post_rdy)
	                       if(i_mk_rdy)
	                           w_nstate <= S_RDY;
	                       else
	                           w_nstate <= S_KEY_CONFIG;
	                   else
	                       w_nstate <= r_pstate;
	               end
	S_ERROR      :  
	               begin
	                   w_nstate <= S_IDLE;
	               end
	default      : 
	               begin	
	                   w_nstate <= S_ERROR;
	               end
	endcase


// o_rdy
assign      o_rdy         = i_mk_rdy & (r_pstate == S_RDY);

// o_text_done
assign      o_text_done   = (r_pstate == S_DONE) & i_post_rdy;

// o_xf_sel
assign      o_xf_sel[2]   = (r_pstate == S_RDY) & i_text_val;
assign      o_xf_sel[1:0] = ((r_pstate == S_RDY) & i_text_val)                            ? 2'b01 :
                            (((r_pstate != S_RDY) & ~r_pstate[5]) | (r_pstate == S_RF31)) ? 2'b10 :
                                                                    (r_pstate == S_RF32)  ? 2'b01 : 
                                                                                            2'b00 ;  
// o_rf_final
assign      o_rf_final    = (r_pstate == S_RF31);

// o_key_sel
assign      o_key_sel     = ((r_pstate == S_RDY) & i_text_val) | ((r_pstate != S_RDY) & (~r_pstate[5]));

// o_rnd_idx
assign      o_rnd_idx     = r_pstate[4:0];

// o_wf_post_pre
assign      o_wf_post_pre = (r_pstate == S_RF31);

endmodule




