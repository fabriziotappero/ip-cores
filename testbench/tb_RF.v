//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Testbench of round function module for HIGHT Crypto Core    ////
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

module tb_RF;

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

reg[31:0]  i_rsk          ;  

reg[63:0]  i_rf_in        ;  
	
reg        i_rf_final     ;  

wire[63:0] o_rf_out       ;  



//=====================================
//
//          PORT MAPPING
//
//=====================================
// uud0
RF uut0_RF(
   .i_op      (i_op      ),  
   .i_rsk     (i_rsk     ), 
   .i_rf_in   (i_rf_in   ), 
   .i_rf_final(i_rf_final), 

   .o_rf_out  (o_rf_out  )
);
//=====================================
//
//          STIMULUS
//
//=====================================

// stimulus
integer i;
initial begin


	$display("============== TEST VECTORS 1 ==============");
// encryption & inter 
	i_op = 1'b0;
    i_rf_final = 1'b0; 
	i_rf_in = 64'h0000001100220033;
	i_rsk = 32'he7135b59;
    
	#50;	

	$display("Encryption&inter : i_rf_in = %16h , i_rsk = %8h o_rf_out : (%s) = %16h", 
                                 i_rf_in, i_rsk, (o_rf_out == 64'h00ce1138223f33e7) ? "Correct" : 
                                                                                      "Wrong", o_rf_out );
	#50;

// encryption & final 
	i_op = 1'b0;
	i_rf_final = 1'b1; 
	i_rf_in = 64'h5d3846d148a1def3;
	i_rsk = 32'hd1357c79;
	
	#50;
	
	$display("Encryption&final : i_rf_in = %16h , i_rsk = %8h o_rf_out : (%s) = %16h", 
                                 i_rf_in, i_rsk, (o_rf_out == 64'h003818d1d9a103f3) ? "Correct" : 
                                                                                      "Wrong", o_rf_out );

	#50;

// decryption & inter 
	i_op = 1'b1;
	i_rf_final = 1'b0; 
	i_rf_in = 64'h003818d1d9a103f3;
	i_rsk = 32'h797c35d1;

	#50;
	
	$display("decryption&inter : i_rf_in = %16h , i_rsk = %8h o_rf_out : (%s) = %16h", 
                                 i_rf_in, i_rsk, (o_rf_out == 64'hf35d3846d148a1de)? "Correct" : 
                                                                                     "Wrong", o_rf_out );
	#50;

// decryption & final 
	i_op = 1'b1; 
	i_rf_final = 1'b1; 
	i_rf_in = 64'he700ce1138223f33;
	i_rsk = 32'h595b13e7;
	
	#50;	
	
	$display("decryption&final : i_rf_in = %16h , i_rsk = %8h o_rf_out : (%s) = %16h", 
							     i_rf_in, i_rsk, (o_rf_out == 64'h0000001100220033) ? "Correct" : 
                                                                                      "Wrong", o_rf_out );
	#50;
  
	$display("============== TEST VECTORS 2 ==============");
// encryption & inter 
	i_op = 1'b0;
    i_rf_final = 1'b0; 
	i_rf_in = 64'h00ee222144886643;
	i_rsk = 32'h4e587e5a;
    
	#50;	

	$display("Encryption&inter : i_rf_in = %16h , i_rsk = %8h o_rf_out : (%s) = %16h", 
                                 i_rf_in, i_rsk, (o_rf_out == 64'hee2d21b1880a435f) ? "Correct" : 
                                                                                      "Wrong", o_rf_out );
	#50;

// encryption & final 
	i_op = 1'b0;
	i_rf_final = 1'b1; 
	i_rf_in = 64'hf7fdf850f8529dd8;
	i_rsk = 32'he2345934;
	
	#50;
	
	$display("Encryption&final : i_rf_in = %16h , i_rsk = %8h o_rf_out : (%s) = %16h", 
                                 i_rf_in, i_rsk, (o_rf_out == 64'h23fd9f50e552e6d8) ? "Correct" : 
                                                                                      "Wrong", o_rf_out );

	#50;

// decryption & inter 
	i_op = 1'b1;
	i_rf_final = 1'b0; 
	i_rf_in = 64'h23fd9f50e552e6d8;
	i_rsk = 32'h345934e2;

	#50;
	
	$display("decryption&inter : i_rf_in = %16h , i_rsk = %8h o_rf_out : (%s) = %16h", 
                                 i_rf_in, i_rsk, (o_rf_out == 64'hd8f7fdf850f8529d)? "Correct" : 
                                                                                     "Wrong", o_rf_out );
	#50;

// decryption & final 
	i_op = 1'b1; 
	i_rf_final = 1'b1; 
	i_rf_in = 64'h5fee2d21b1880a43; 
	i_rsk = 32'h5a7e584e;
	
	#50;	
	
	$display("decryption&final : i_rf_in = %16h , i_rsk = %8h o_rf_out : (%s) = %16h", 
							     i_rf_in, i_rsk, (o_rf_out == 64'h00ee222144886643) ? "Correct" : 
                                                                                      "Wrong", o_rf_out );
	#50;

	$display("============== TEST VECTORS 3 ==============");
// encryption & inter 
	i_op = 1'b0;
    i_rf_final = 1'b0; 
	i_rf_in = 64'h0123456889a9cdf2;
	i_rsk = 32'h27437b69;
    
	#50;	

	$display("Encryption&inter : i_rf_in = %16h , i_rsk = %8h o_rf_out : (%s) = %16h", 
                                 i_rf_in, i_rsk, (o_rf_out == 64'h23e16815a93af283) ? "Correct" : 
                                                                                      "Wrong", o_rf_out );
	#50;

// encryption & final 
	i_op = 1'b0;
	i_rf_final = 1'b1; 
	i_rf_in = 64'h21630d95692db157;
	i_rsk = 32'h61356c59;
	
	#50;
	
	$display("Encryption&final : i_rf_in = %16h , i_rsk = %8h o_rf_out : (%s) = %16h", 
                                 i_rf_in, i_rsk, (o_rf_out == 64'h7a63b2958d2df457) ? "Correct" : 
                                                                                      "Wrong", o_rf_out );

	#50;

// decryption & inter 
	i_op = 1'b1;
	i_rf_final = 1'b0; 
	i_rf_in = 64'h7a63b2958d2df457;
	i_rsk = 32'h596c3561;

	#50;
	
	$display("decryption&inter : i_rf_in = %16h , i_rsk = %8h o_rf_out : (%s) = %16h", 
                                 i_rf_in, i_rsk, (o_rf_out == 64'h5721630d95692db1)? "Correct" : 
                                                                                     "Wrong", o_rf_out );
	#50;

// decryption & final 
	i_op = 1'b1; 
	i_rf_final = 1'b1; 
	i_rf_in = 64'h8323e16815a93af2;
	i_rsk = 32'h697b4327;
	
	#50;	
	
	$display("decryption&final : i_rf_in = %16h , i_rsk = %8h o_rf_out : (%s) = %16h", 
							     i_rf_in, i_rsk, (o_rf_out == 64'h0123456889a9cdf2) ? "Correct" : 
                                                                                      "Wrong", o_rf_out );
	#50;

	$display("============== TEST VECTORS 4 ==============");
// encryption & inter 
	i_op = 1'b0;
    i_rf_final = 1'b0; 
	i_rf_in = 64'hb4366bbdeb6b4ad0;
	i_rsk = 32'h38789841;
    
	#50;	

	$display("Encryption&inter : i_rf_in = %16h , i_rsk = %8h o_rf_out : (%s) = %16h", 
                                 i_rf_in, i_rsk, (o_rf_out == 64'h368cbd8d6b48d053) ? "Correct" : 
                                                                                      "Wrong", o_rf_out );
	#50;

// encryption & final 
	i_op = 1'b0;
	i_rf_final = 1'b1; 
	i_rf_in = 64'h7d193f3390b731df;
	i_rsk = 32'hd75d461a;
	
	#50;
	
	$display("Encryption&final : i_rf_in = %16h , i_rsk = %8h o_rf_out : (%s) = %16h", 
                                 i_rf_in, i_rsk, (o_rf_out == 64'hcc197a3320b71fdf) ? "Correct" : 
                                                                                      "Wrong", o_rf_out );

	#50;

// decryption & inter 
	i_op = 1'b1;
	i_rf_final = 1'b0; 
	i_rf_in = 64'hcc197a3320b71fdf;
	i_rsk = 32'h1a465dd7;

	#50;
	
	$display("decryption&inter : i_rf_in = %16h , i_rsk = %8h o_rf_out : (%s) = %16h", 
                                 i_rf_in, i_rsk, (o_rf_out == 64'hdf7d193f3390b731)? "Correct" : 
                                                                                     "Wrong", o_rf_out );
	#50;

// decryption & final 
	i_op = 1'b1; 
	i_rf_final = 1'b1; 
	i_rf_in = 64'h53368cbd8d6b48d0;
	i_rsk = 32'h41987838;
	
	#50;	
	
	$display("decryption&final : i_rf_in = %16h , i_rsk = %8h o_rf_out : (%s) = %16h", 
							     i_rf_in, i_rsk, (o_rf_out == 64'hb4366bbdeb6b4ad0) ? "Correct" : 
                                                                                      "Wrong", o_rf_out );
	#50;

	$finish;

end


// vcd dump
initial begin
	$dumpfile("dump/sim_tb_RF.vcd");
	$dumpvars(0, tb_RF);
end


endmodule


