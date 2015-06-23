//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Key scheduler for HIGHT Crypto Core                         ////
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

module KEY_SCHED(
	rstn          , 
	clk           ,  
	
	i_mk          ,  

	i_op          ,  

	i_key_sel     , 
	i_rnd_idx     , 
	i_wf_post_pre , 

	o_rnd_key       
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

input[127:0] i_mk           ;  

input        i_op           ; 

input        i_key_sel      ;  
input[4:0]   i_rnd_idx      ; 
input        i_wf_post_pre  ; 

output[31:0] o_rnd_key      ; 


//=====================================
//
//          REGISTERS
//
//=====================================
// r_rnd_key_3x ~ r_rnd_key_0x register
reg[7:0]    r_rnd_key_3x    ;
reg[7:0]    r_rnd_key_2x    ;
reg[7:0]    r_rnd_key_1x    ;
reg[7:0]    r_rnd_key_0x    ;


//=====================================
//
//          WIRES
//
//=====================================
// w_wk3x ~ w_wk0x
wire[7:0]   w_wk3x          ;
wire[7:0]   w_wk2x          ;
wire[7:0]   w_wk1x          ;
wire[7:0]   w_wk0x          ;

// w_sk3x ~ w_sk0x
wire[7:0]   w_sk3x          ;
wire[7:0]   w_sk2x          ;
wire[7:0]   w_sk1x          ;
wire[7:0]   w_sk0x          ;


//=====================================
//
//          MAIN
//
//=====================================
// WKG(Whitening Key Generator) instance
WKG u_WKG(
	.i_op           (i_op         ) , 
                                  
	.i_wf_post_pre  (i_wf_post_pre) ,
	                
	.i_mk3to0       (i_mk[31:0]   ) ,
	.i_mk15to12     (i_mk[127:96] ) , 
                                  
	.o_wk3_7        (w_wk3x       ) ,  
	.o_wk2_6        (w_wk2x       ) ,   
	.o_wk1_5        (w_wk1x       ) ,  
	.o_wk0_4        (w_wk0x       )   
);

// SKG(SubKey Generator) instance
SKG u_SKG(
	.i_op           (i_op         ) ,
	.i_rnd_idx      (i_rnd_idx    ) ,
	.i_mk           (i_mk         ) , 
                                  
	.o_sk3x         (w_sk3x       ) ,  
	.o_sk2x         (w_sk2x       ) ,  
	.o_sk1x         (w_sk1x       ) ,  
	.o_sk0x         (w_sk0x       )     
);

// r_rnd_key_3x ~ r_rnd_key_0x register
always @(negedge rstn or posedge clk)
	if(~rstn) begin
		r_rnd_key_3x <= #1 8'h00;
		r_rnd_key_2x <= #1 8'h00;
		r_rnd_key_1x <= #1 8'h00;
		r_rnd_key_0x <= #1 8'h00;
	end
	else begin
		if(~i_key_sel) begin
			r_rnd_key_3x <= #1 w_wk3x;
			r_rnd_key_2x <= #1 w_wk2x;
			r_rnd_key_1x <= #1 w_wk1x;
			r_rnd_key_0x <= #1 w_wk0x;
		end
		else begin
			r_rnd_key_3x <= #1 w_sk3x;
			r_rnd_key_2x <= #1 w_sk2x;
			r_rnd_key_1x <= #1 w_sk1x;
			r_rnd_key_0x <= #1 w_sk0x;
		end
	end 

// o_rnd_key
assign      o_rnd_key = {r_rnd_key_3x,r_rnd_key_2x,r_rnd_key_1x,r_rnd_key_0x}; 

endmodule




















