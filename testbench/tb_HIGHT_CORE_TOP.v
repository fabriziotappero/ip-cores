//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Testbench of top module for HIGHT Crypto Core               ////
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

`timescale 1ns/1ps

module tb_HIGHT_CORE_TOP;

event do_finish;

//=====================================
//
//          PARAMETERS 
//
//=====================================
parameter HP_CLK = 5; // Half period of Clock


//=====================================
//
//          I/O PORTS 
//
//=====================================
reg        rstn         ; 
reg        clk          ;  

reg        i_mk_rdy     ;  
reg[127:0] i_mk         ;  

reg        i_post_rdy   ;  

reg        i_op         ;  

reg        i_text_val   ;  
reg[63:0]  i_text_in    ;  

wire       o_text_done  ;  
wire[63:0] o_text_out   ;  

wire       o_rdy        ;       


//=====================================
//
//          PORT MAPPING
//
//=====================================
// uut
HIGHT_CORE_TOP uut_HIGHT_CORE_TOP(
	.rstn        (rstn       ) , 
	.clk         (clk        ) ,  
	                         
	.i_mk_rdy    (i_mk_rdy   ) ,  
	.i_mk        (i_mk       ) ,  
                             
	.i_post_rdy  (i_post_rdy ) ,  
                             
	.i_op        (i_op       ) ,  
                             
	.i_text_val  (i_text_val ) ,  
	.i_text_in   (i_text_in  ) ,  
                             
	.o_text_done (o_text_done) ,  
	.o_text_out  (o_text_out ) , 
                  
	.o_rdy       (o_rdy      ) 
);


//=====================================
//
//          STIMULUS
//
//=====================================
// clock generation
initial begin
	clk = 1'b0;
	forever clk = #(HP_CLK) ~clk;	
end

// reset generation
initial begin
	rstn = 1'b1;
	@(posedge clk);
	@(negedge clk);
	rstn = 1'b0;
	repeat(2) @(negedge clk);
	rstn = 1'b1;
end

// input generation
initial begin
	$display("===== SIM START =====");
	// insert your code

	/******** Encryption w/ test vectr 1 *******/
	// initial input value
	i_mk_rdy   = 1'b1;
	i_mk       = 128'h0011_2233_4455_6677_8899_aabb_ccdd_eeff;
	i_op       = 1'b0;
	i_post_rdy = 1'b1;
	i_text_val = 1'b0;	
	i_text_in  = 64'h0000_0000_0000_0000;

	// reset time
	@(negedge rstn);
	@(posedge rstn);
	@(negedge clk);

	// Key Config Phase
	@(negedge clk);
	i_mk_rdy  = 1'b0;
	repeat(4) @(posedge clk);
	@(negedge clk);
	i_mk_rdy = 1'b1;

	//// first ciphering //// 
	// insert 2 clock delay
	@(posedge clk);
	repeat(2) @(posedge clk);	

	// insert text
	@(negedge clk);
	i_text_val = 1'b1;
	@(negedge clk);
	i_text_val = 1'b0;
	
	// wait text done 
	wait(o_text_done)
	@(posedge clk);

	// post rdy inactive
	@(negedge clk);
	i_post_rdy = 1'b0;	


	//// second ciphering ////
	// insert text
	@(negedge clk);
	i_text_val = 1'b1;
	@(negedge clk);
	i_text_val = 1'b0;
	
	// wait done state
	wait(uut_HIGHT_CORE_TOP.u_CONTROL.r_pstate == uut_HIGHT_CORE_TOP.u_CONTROL.S_DONE)
	@(posedge clk);
	
	// insert 3clk delay
	repeat(3) @(posedge clk);

	// post rdy active
	i_post_rdy = 1'b1;

	// delay	
	repeat(10) @(posedge clk);



	/******** Decryption w/ test vectr 1 *******/
	// initial input value
	i_mk_rdy   = 1'b1;
	i_mk       = 128'h0011_2233_4455_6677_8899_aabb_ccdd_eeff;
	i_op       = 1'b1;
	i_post_rdy = 1'b1;
	i_text_val = 1'b0;	
	i_text_in  = 64'h00f4_18ae_d94f_03f2;

	// Key Config Phase
	@(negedge clk);
	i_mk_rdy  = 1'b0;
	repeat(4) @(posedge clk);
	@(negedge clk);
	i_mk_rdy = 1'b1;

	//// first ciphering //// 
	// insert 2 clock delay
	@(posedge clk);
	repeat(2) @(posedge clk);	

	// insert text
	@(negedge clk);
	i_text_val = 1'b1;
	@(negedge clk);
	i_text_val = 1'b0;
	
	// wait text done 
	wait(o_text_done)
	@(posedge clk);

	// post rdy inactive
	@(negedge clk);
	i_post_rdy = 1'b0;	


	//// second ciphering ////
	// insert text
	@(negedge clk);
	i_text_val = 1'b1;
	@(negedge clk);
	i_text_val = 1'b0;
	
	// wait done state
	wait(uut_HIGHT_CORE_TOP.u_CONTROL.r_pstate == uut_HIGHT_CORE_TOP.u_CONTROL.S_DONE)
	@(posedge clk);
	
	// insert 3clk delay
	repeat(3) @(posedge clk);

	// post rdy active
	i_post_rdy = 1'b1;

	// delay
	repeat(20) @(posedge clk);

	
	
	/******** Encryption w/ test vectr 2 *******/
	// initial input value
	i_mk_rdy   = 1'b1;
	i_mk       = 128'hffee_ddcc_bbaa_9988_7766_5544_3322_1100;
	i_op       = 1'b0;
	i_post_rdy = 1'b1;
	i_text_val = 1'b0;	
	i_text_in  = 64'h0011_2233_4455_6677;

	// Key Config Phase
	@(negedge clk);
	i_mk_rdy  = 1'b0;
	repeat(4) @(posedge clk);
	@(negedge clk);
	i_mk_rdy = 1'b1;

	//// first ciphering //// 
	// insert 2 clock delay
	@(posedge clk);
	repeat(2) @(posedge clk);	

	// insert text
	@(negedge clk);
	i_text_val = 1'b1;
	@(negedge clk);
	i_text_val = 1'b0;
	
	// wait text done 
	wait(o_text_done)
	@(posedge clk);

	// post rdy inactive
	@(negedge clk);
	i_post_rdy = 1'b0;	


	//// second ciphering ////
	// insert text
	@(negedge clk);
	i_text_val = 1'b1;
	@(negedge clk);
	i_text_val = 1'b0;
	
	// wait done state
	wait(uut_HIGHT_CORE_TOP.u_CONTROL.r_pstate == uut_HIGHT_CORE_TOP.u_CONTROL.S_DONE)
	@(posedge clk);
	
	// insert 3clk delay
	repeat(3) @(posedge clk);

	// post rdy active
	i_post_rdy = 1'b1;

	// delay	
	repeat(10) @(posedge clk);



	/******** Decryption w/ test vectr 2 *******/
	// initial input value
	i_mk_rdy   = 1'b1;
	i_mk       = 128'hffee_ddcc_bbaa_9988_7766_5544_3322_1100;
	i_op       = 1'b1;
	i_post_rdy = 1'b1;
	i_text_val = 1'b0;	
	i_text_in  = 64'h23ce_9f72_e543_e6d8;

	// Key Config Phase
	@(negedge clk);
	i_mk_rdy  = 1'b0;
	repeat(4) @(posedge clk);
	@(negedge clk);
	i_mk_rdy = 1'b1;

	//// first ciphering //// 
	// insert 2 clock delay
	@(posedge clk);
	repeat(2) @(posedge clk);	

	// insert text
	@(negedge clk);
	i_text_val = 1'b1;
	@(negedge clk);
	i_text_val = 1'b0;
	
	// wait text done 
	wait(o_text_done)
	@(posedge clk);

	// post rdy inactive
	@(negedge clk);
	i_post_rdy = 1'b0;	


	//// second ciphering ////
	// insert text
	@(negedge clk);
	i_text_val = 1'b1;
	@(negedge clk);
	i_text_val = 1'b0;
	
	// wait done state
	wait(uut_HIGHT_CORE_TOP.u_CONTROL.r_pstate == uut_HIGHT_CORE_TOP.u_CONTROL.S_DONE)
	@(posedge clk);
	
	// insert 3clk delay
	repeat(3) @(posedge clk);

	// post rdy active
	i_post_rdy = 1'b1;

	// delay
	repeat(20) @(posedge clk);
	
	
	/******** Encryption w/ test vectr 3 *******/
	// initial input value
	i_mk_rdy   = 1'b1;
	i_mk       = 128'h0001_0203_0405_0607_0809_0a0b_0c0d_0e0f;
	i_op       = 1'b0;
	i_post_rdy = 1'b1;
	i_text_val = 1'b0;	
	i_text_in  = 64'h0123_4567_89ab_cdef;

	// Key Config Phase
	@(negedge clk);
	i_mk_rdy  = 1'b0;
	repeat(4) @(posedge clk);
	@(negedge clk);
	i_mk_rdy = 1'b1;

	//// first ciphering //// 
	// insert 2 clock delay
	@(posedge clk);
	repeat(2) @(posedge clk);	

	// insert text
	@(negedge clk);
	i_text_val = 1'b1;
	@(negedge clk);
	i_text_val = 1'b0;
	
	// wait text done 
	wait(o_text_done)
	@(posedge clk);

	// post rdy inactive
	@(negedge clk);
	i_post_rdy = 1'b0;	


	//// second ciphering ////
	// insert text
	@(negedge clk);
	i_text_val = 1'b1;
	@(negedge clk);
	i_text_val = 1'b0;
	
	// wait done state
	wait(uut_HIGHT_CORE_TOP.u_CONTROL.r_pstate == uut_HIGHT_CORE_TOP.u_CONTROL.S_DONE)
	@(posedge clk);
	
	// insert 3clk delay
	repeat(3) @(posedge clk);

	// post rdy active
	i_post_rdy = 1'b1;

	// delay	
	repeat(10) @(posedge clk);



	/******** Decryption w/ test vectr 3 *******/
	// initial input value
	i_mk_rdy   = 1'b1;
	i_mk       = 128'h0001_0203_0405_0607_0809_0a0b_0c0d_0e0f;
	i_op       = 1'b1;
	i_post_rdy = 1'b1;
	i_text_val = 1'b0;	
	i_text_in  = 64'h7a6f_b2a2_8d23_f466;

	// Key Config Phase
	@(negedge clk);
	i_mk_rdy  = 1'b0;
	repeat(4) @(posedge clk);
	@(negedge clk);
	i_mk_rdy = 1'b1;

	//// first ciphering //// 
	// insert 2 clock delay
	@(posedge clk);
	repeat(2) @(posedge clk);	

	// insert text
	@(negedge clk);
	i_text_val = 1'b1;
	@(negedge clk);
	i_text_val = 1'b0;
	
	// wait text done 
	wait(o_text_done)
	@(posedge clk);

	// post rdy inactive
	@(negedge clk);
	i_post_rdy = 1'b0;	


	//// second ciphering ////
	// insert text
	@(negedge clk);
	i_text_val = 1'b1;
	@(negedge clk);
	i_text_val = 1'b0;
	
	// wait done state
	wait(uut_HIGHT_CORE_TOP.u_CONTROL.r_pstate == uut_HIGHT_CORE_TOP.u_CONTROL.S_DONE)
	@(posedge clk);
	
	// insert 3clk delay
	repeat(3) @(posedge clk);

	// post rdy active
	i_post_rdy = 1'b1;

	// delay
	repeat(20) @(posedge clk);	
	
	/******** Encryption w/ test vectr 4 *******/
	// initial input value
	i_mk_rdy   = 1'b1;
	i_mk       = 128'h28db_c3bc_49ff_d87d_cfa5_09b1_1d42_2be7;
	i_op       = 1'b0;
	i_post_rdy = 1'b1;
	i_text_val = 1'b0;	
	i_text_in  = 64'hb41e_6be2_eba8_4a14;

	// Key Config Phase
	@(negedge clk);
	i_mk_rdy  = 1'b0;
	repeat(4) @(posedge clk);
	@(negedge clk);
	i_mk_rdy = 1'b1;

	//// first ciphering //// 
	// insert 2 clock delay
	@(posedge clk);
	repeat(2) @(posedge clk);	

	// insert text
	@(negedge clk);
	i_text_val = 1'b1;
	@(negedge clk);
	i_text_val = 1'b0;
	
	// wait text done 
	wait(o_text_done)
	@(posedge clk);

	// post rdy inactive
	@(negedge clk);
	i_post_rdy = 1'b0;	


	//// second ciphering ////
	// insert text
	@(negedge clk);
	i_text_val = 1'b1;
	@(negedge clk);
	i_text_val = 1'b0;
	
	// wait done state
	wait(uut_HIGHT_CORE_TOP.u_CONTROL.r_pstate == uut_HIGHT_CORE_TOP.u_CONTROL.S_DONE)
	@(posedge clk);
	
	// insert 3clk delay
	repeat(3) @(posedge clk);

	// post rdy active
	i_post_rdy = 1'b1;

	// delay	
	repeat(10) @(posedge clk);



	/******** Decryption w/ test vectr 4 *******/
	// initial input value
	i_mk_rdy   = 1'b1;
	i_mk       = 128'h28db_c3bc_49ff_d87d_cfa5_09b1_1d42_2be7;
	i_op       = 1'b1;
	i_post_rdy = 1'b1;
	i_text_val = 1'b0;	
	i_text_in  = 64'hcc04_7a75_209c_1fc6;

	// Key Config Phase
	@(negedge clk);
	i_mk_rdy  = 1'b0;
	repeat(4) @(posedge clk);
	@(negedge clk);
	i_mk_rdy = 1'b1;

	//// first ciphering //// 
	// insert 2 clock delay
	@(posedge clk);
	repeat(2) @(posedge clk);	

	// insert text
	@(negedge clk);
	i_text_val = 1'b1;
	@(negedge clk);
	i_text_val = 1'b0;
	
	// wait text done 
	wait(o_text_done)
	@(posedge clk);

	// post rdy inactive
	@(negedge clk);
	i_post_rdy = 1'b0;	


	//// second ciphering ////
	// insert text
	@(negedge clk);
	i_text_val = 1'b1;
	@(negedge clk);
	i_text_val = 1'b0;
	
	// wait done state
	wait(uut_HIGHT_CORE_TOP.u_CONTROL.r_pstate == uut_HIGHT_CORE_TOP.u_CONTROL.S_DONE)
	@(posedge clk);
	
	// insert 3clk delay
	repeat(3) @(posedge clk);

	// post rdy active
	i_post_rdy = 1'b1;

	// delay
	repeat(10) @(posedge clk);
	-> do_finish;
end

// state monitoring
reg[20*8:1] state;
always @(uut_HIGHT_CORE_TOP.u_CONTROL.r_pstate) begin
	case(uut_HIGHT_CORE_TOP.u_CONTROL.r_pstate)
	uut_HIGHT_CORE_TOP.u_CONTROL.S_IDLE        : state <= "IDLE      ";   
    uut_HIGHT_CORE_TOP.u_CONTROL.S_KEY_CONFIG  : state <= "KEY_CONFIG";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RDY         : state <= "RDY       ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_WF1         : state <= "WF1       ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF1         : state <= "RF1       ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF2         : state <= "RF2       ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF3         : state <= "RF3       ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF4         : state <= "RF4       ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF5         : state <= "RF5       ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF6         : state <= "RF6       ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF7         : state <= "RF7       ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF8         : state <= "RF8       ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF9         : state <= "RF9       ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF10        : state <= "RF10      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF11        : state <= "RF11      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF12        : state <= "RF12      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF13        : state <= "RF13      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF14        : state <= "RF14      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF15        : state <= "RF15      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF16        : state <= "RF16      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF17        : state <= "RF17      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF18        : state <= "RF18      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF19        : state <= "RF19      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF20        : state <= "RF20      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF21        : state <= "RF21      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF22        : state <= "RF22      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF23        : state <= "RF23      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF24        : state <= "RF24      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF25        : state <= "RF25      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF26        : state <= "RF26      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF27        : state <= "RF27      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF28        : state <= "RF28      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF29        : state <= "RF29      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF30        : state <= "RF30      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF31        : state <= "RF31      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_RF32        : state <= "RF32      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_DONE        : state <= "DONE      ";
    uut_HIGHT_CORE_TOP.u_CONTROL.S_ERROR       : state <= "ERROR     ";
	endcase 
end

// finish 
initial begin
	@do_finish
	$finish;	
end

// vcd dump
initial begin
	$dumpfile("dump/sim_tb_HIGHT_CORE_TOP.vcd");
	$dumpvars(0, tb_HIGHT_CORE_TOP);
end

endmodule


