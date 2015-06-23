//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Testbench of whitening function for HIGHT Crypto Core       ////
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

module tb_WF;


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

reg        i_op           ;  
reg[63:0]  i_wf_in        ;  
reg[31:0]  i_wk           ;  

wire[63:0] o_wf_out       ;  

//=====================================
//
//          
//
//=====================================
// uud0
WF uut0_WF(
     .i_op    (i_op    ),      
     .i_wf_in (i_wf_in ),
     .i_wk    (i_wk    ),

	 .o_wf_out(o_wf_out)
);



//=====================================
//
//          STIMULUS
//
//=====================================


// stimulus
integer i;
initial begin
	#1000;
    

	$display("//===============================//");
	$display("//========= SIM START ===========//");
	$display("//===============================//");
	$display("********** Test vectors 1 *********");
       i_op = 1'b0;   
       i_wf_in = 64'h00_00_00_00_00_00_00_00 ;
       i_wk = 32'h00_11_22_33 ;
	#50;
     $display ("Encryption(I)   : i_wf_in = %16h, i_wk = %8h ==> o_wf_out (%s) = %16h" , i_wf_in, i_wk, (o_wf_out == 64'h0000001100220033) ? "Correct" : "Wrong", o_wf_out );
	#50;
	
       i_op = 1'b0;
	   i_wf_in = 64'h00_38_18_d1_d9_a1_03_f3;
       i_wk = 32'hcc_dd_ee_ff;
	#50;
     $display ("Encryption(F)   : i_wf_in = %16h, i_wk = %8h ==> o_wf_out (%s) = %16h" , i_wf_in, i_wk, (o_wf_out == 64'h00f418aed94f03f2) ? "Correct" : "Wrong", o_wf_out );
	#50;

       i_op = 1'b1;   
       i_wf_in = 64'h00_f4_18_ae_d9_4f_03_f2 ;
       i_wk = 32'hcc_dd_ee_ff ;
	#50;
	 $display ("Decryption (F-) : i_wf_in = %16h, i_wk = %8h ==> o_wf_out (%s) = %16h ", i_wf_in, i_wk, (o_wf_out == 64'h003818d1d9a103f3) ? "Correct" : "Wrong", o_wf_out); 
	#50;	
     
	   i_op = 1'b1;
	   i_wf_in = 64'h00_00_00_11_00_22_00_33;
       i_wk = 32'h00_11_22_33;
	#50;
	 $display ("Decryption (I-) : i_wf_in = %16h, i_wk = %8h ==> o_wf_out (%s) = %16h ", i_wf_in, i_wk, (o_wf_out == 64'h0000000000000000) ? "Correct" : "Wrong", o_wf_out); 
	#50;




	$display("********** Test vectors 2 *********");
       i_op = 1'b0;   
       i_wf_in = 64'h00_11_22_33_44_55_66_77 ;
       i_wk = 32'hff_ee_dd_cc ;
	#50;
     $display ("Encryption(I)  : i_wf_in = %16h, i_wk = %8h ==> o_wf_out (%s) = %16h" , i_wf_in, i_wk, (o_wf_out == 64'h00ee222144886643) ? "Correct" : "Wrong", o_wf_out);
	#50;
	
       i_op = 1'b0;
	   i_wf_in = 64'h23_fd_9f_50_e5_52_e6_d8;
       i_wk = 32'h33_22_11_00;
	#50;
     $display ("Encryption(F)  : i_wf_in = %16h, i_wk = %8h ==> o_wf_out (%s) = %16h" , i_wf_in, i_wk, (o_wf_out == 64'h23ce9f72e543e6d8) ? "Correct" : "Wrong", o_wf_out);
	#50;

       i_op = 1'b1;   
       i_wf_in = 64'h23_ce_9f_72_e5_43_e6_d8 ;
       i_wk = 32'h33_22_11_00 ;
	#50;
	 $display ("Decryption(F-) : i_wf_in = %16h, i_wk = %8h ==> o_wf_out (%s) = %16h ", i_wf_in, i_wk, (o_wf_out == 64'h23fd9f50e552e6d8) ? "Correct" : "Wrong", o_wf_out); 
	#50;	
     
	   i_op = 1'b1;
	   i_wf_in = 64'h00_ee_22_21_44_88_66_43;
       i_wk = 32'hff_ee_dd_cc;
	#50;
	 $display ("Decryption(I-) : i_wf_in = %16h, i_wk = %8h ==> o_wf_out (%s) = %16h ", i_wf_in, i_wk, (o_wf_out == 64'h0011223344556677) ? "Correct" : "Wrong", o_wf_out); 
	#50;




	$display("********** Test vectors 3 *********");
       i_op = 1'b0;   
       i_wf_in = 64'h01_23_45_67_89_ab_cd_ef ;
       i_wk = 32'h00_01_02_03 ;
	#50;
     $display ("Encryption(I) : i_wf_in = %16h, i_wk = %8h ==> o_wf_out (%s) = %16h" , i_wf_in, i_wk, (o_wf_out == 64'h0123456889a9cdf2) ? "Correct" : "Wrong", o_wf_out);
	#50;
	
       i_op = 1'b0;
	   i_wf_in = 64'h7a_63_b2_95_8d_2d_f4_57;
       i_wk = 32'h0c_0d_0e_0f;
	#50;
     $display ("Encryption(F) : i_wf_in = %16h, i_wk = %8h ==> o_wf_out (%s) = %16h" , i_wf_in, i_wk, (o_wf_out == 64'h7a6fb2a28d23f466) ? "Correct" : "Wrong", o_wf_out);
	#50;

       i_op = 1'b1;   
       i_wf_in = 64'h7a_6f_b2_a2_8d_23_f4_66 ;
       i_wk = 32'h0c_0d_0e_0f ;
	#50;
	 $display ("Decryption(F-) : i_wf_in = %16h, i_wk = %8h ==> o_wf_out (%s) = %16h ", i_wf_in, i_wk, (o_wf_out == 64'h7a63b2958d2df457) ? "Correct" : "Wrong", o_wf_out); 
	#50;	
     
	   i_op = 1'b1;
	   i_wf_in = 64'h01_23_45_68_89_a9_cd_f2;
       i_wk = 32'h00_01_02_03;
	#50;
	 $display ("Decryption(I-) : i_wf_in = %16h, i_wk = %8h ==> o_wf_out (%s) = %16h ", i_wf_in, i_wk, (o_wf_out == 64'h0123456789abcdef) ? "Correct" : "Wrong", o_wf_out); 
	#50;




	$display("********** Test vectors 4 *********");
       i_op = 1'b0;   
       i_wf_in = 64'hb4_1e_6b_e2_eb_a8_4a_14 ;
       i_wk = 32'h28_db_c3_bc ;
	#50;
     $display ("Encryption(I) : i_wf_in = %16h, i_wk = %8h ==> o_wf_out (%s) = %16h" , i_wf_in, i_wk, (o_wf_out == 64'hb4366bbdeb6b4ad0) ? "Correct" : "Wrong", o_wf_out);
	#50;
	
       i_op = 1'b0;
	   i_wf_in = 64'hcc_19_7a_33_20_b7_1f_df;
       i_wk = 32'h1d_42_2b_e7;
	#50;
     $display ("Encryption(F) : i_wf_in = %16h, i_wk = %8h ==> o_wf_out (%s) = %16h" , i_wf_in, i_wk, (o_wf_out == 64'hcc047a75209c1fc6) ? "Correct" : "Wrong", o_wf_out);
	#50;

       i_op = 1'b1;   
       i_wf_in = 64'hcc_04_7a_75_20_9c_1f_c6 ;
       i_wk = 32'h1d_42_2b_e7 ;
	#50;
	 $display ("Decryption(F-) : i_wf_in = %16h, i_wk = %8h ==> o_wf_out (%s) = %16h ", i_wf_in, i_wk, (o_wf_out == 64'hcc197a3320b71fdf) ? "Correct" : "Wrong", o_wf_out); 
	#50;	
     
	   i_op = 1'b1;
	   i_wf_in = 64'hb4_36_6b_bd_eb_6b_4a_d0;
       i_wk = 32'h28_db_c3_bc;
	#50;
	 $display ("Decryption(I-): i_wf_in = %16h, i_wk = %8h ==> o_wf_out (%s) = %16h ", i_wf_in, i_wk, (o_wf_out == 64'hb41e6be2eba84a14) ? "Correct" : "Wrong", o_wf_out); 
	#50;




	$display("========== SIM END ==========");
	$finish;
	end

// vcd dump
initial begin
	$dumpfile("dump/sim_tb_WF.vcd");
	$dumpvars(0, tb_WF);
end


endmodule

