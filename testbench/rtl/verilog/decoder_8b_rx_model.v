//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "decoder_8b_rx_model.v"                           ////
////                                                              ////
////  This file is part of the :                                  ////
////                                                              ////
//// "1000BASE-X IEEE 802.3-2008 Clause 36 - PCS project"         ////
////                                                              ////
////  http://opencores.org/project,1000base-x                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - D.W.Pegler Cambridge Broadband Networks Ltd           ////
////                                                              ////
////      { peglerd@gmail.com, dwp@cambridgebroadand.com }        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 AUTHORS. All rights reserved.             ////
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
////                                                              ////
//// This module is based on the coding method described in       ////
//// IEEE Std 802.3-2008 Clause 36 "Physical Coding Sublayer(PCS) ////
//// and Physical Medium Attachment (PMA) sublayer, type          ////
//// 1000BASE-X"; see :                                           ////
////                                                              ////
//// http://standards.ieee.org/about/get/802/802.3.html           ////
//// and                                                          ////
//// doc/802.3-2008_section3.pdf, Clause/Section 36.              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "timescale_tb.v"

module decoder_8b_rx_model #(
  parameter DEBUG       = 0,
  parameter out_delay   = 5,
  parameter in_delay    = 2
)(
  interface check_intf,
  
   // --- Clocks
   input SBYTECLK,

   input reset,

   input K,

   input disparity,

   input coding_err,

   input disparity_err,
  
   // -- Ten but input to decoder
   input [9:0] tbi,
  
   // --- Eight but output from decoder	  
   input [7:0] ebi
);
   
   import encoder_8b10b_threads::split;
   import encoder_8b10b_threads::decode;
   
   //----------------------------------------------------------------------------
  // Checker interface functions
  //----------------------------------------------------------------------------

   function automatic string check_intf.whoami();
      string buffer;
      $sformat(buffer, "%m");
      return buffer.substr(0, buffer.len()-17);
   endfunction

   //----------------------------------------------------------------------------
   // 10b symbol, disparity and coding checker 
   //----------------------------------------------------------------------------
   
   int     iteration = 0; 

   // Decoder signals
   reg [9:0]   decoder_10b_symbol = 10'b0; reg [7:0] decoder_8b_symbol = 8'b0;
   
   reg 	       decoder_K, decoder_disparity, decoder_disparity_err, decoder_code_err;
   
   reg [4:0]   decoder_X; reg [2:0] decoder_Y;
   
   // Checker signals
   reg [7:0]   checker_8b_symbol;
   
   reg 	       checker_K, checker_disparity, checker_disparity_err, checker_code_err;
   
   reg [4:0]   checker_X; reg [2:0] checker_Y; reg checker_errors;


   // Signal to indicate that there is a mismatch between the output of the decoder and the checker.
   reg 	       null_rd, decoder_checker_fail = 1'b1;
   
   task automatic decoder_8b_checker();

      // 8b output from decoder
      decoder_8b_symbol = ebi;
      decoder_disparity = disparity;
      decoder_disparity_err = disparity_err;
      decoder_code_err = coding_err;
      decoder_K = K;
      
      decoder_10b_symbol = tbi;
      
      // Encode the 8b decoder input symbol
      encoder_8b10b_threads::decode(decoder_10b_symbol, checker_disparity, checker_disparity, checker_K, 
				    checker_8b_symbol, checker_disparity_err, checker_code_err);
      
      // Split the checker 8b symbol into 5b/6b and 3b/4b components x and y - Dx.y and Kx.y 
      encoder_8b10b_threads::split(checker_8b_symbol, checker_X, checker_Y);
      
      // Are there any checker disparity or coding errors 
      if (DEBUG | (iteration & (checker_disparity_err | checker_code_err)))
	begin
	   
	   $display("Checker disparity/coding test %08d: [10b_symbol = %010b, RD = %01b, 8b_symbol = %08b, K = %01b, RD_err = %01b, CODE_err = %01b] : %s : %s%02d.%01d",
		    iteration, decoder_10b_symbol,
		    checker_disparity,  checker_8b_symbol, checker_K,  
		    checker_disparity_err, checker_code_err, 
		    ((checker_disparity_err | checker_code_err) ? "FAIL" : "PASSED"),
		    ((checker_K) ? "K" : "D"), checker_X, checker_Y);
	   
	   // Halt if disparity or coding errors
	   if (!DEBUG) $stop;
	end
      
      // Split the checker 8b symbol into 5b/6b and 3b/4b components x and y - Dx.y and Kx.y 
      encoder_8b10b_threads::split(decoder_8b_symbol, decoder_X, decoder_Y);

      // Are there any decoder disparity or coding errors 
      if (DEBUG | (iteration & (decoder_disparity_err | decoder_code_err)))
	begin
	   $display("Decoder disparity/coding test %08d: [10b_symbol = %010b, RD = %01b, 8b_symbol = %08b, K = %01b, RD_err = %01b, CODE_err = %01b] : %s : %s%02d.%01d",
		    iteration, decoder_10b_symbol,
		    decoder_disparity,  decoder_8b_symbol, decoder_K,  
		    decoder_disparity_err, decoder_code_err, 
		    ((decoder_disparity_err | decoder_code_err) ? "FAIL" : "PASSED"),
		    ((decoder_K) ? "K" : "D"), decoder_X, decoder_Y);
	   
	end
      
      // Does the output of the decoder match that of the checker ?
      decoder_checker_fail = ((decoder_8b_symbol != checker_8b_symbol) || (decoder_K != checker_K));
      
      // Make sure the resultant symbols are the same
      if (DEBUG | (iteration & decoder_checker_fail))
	begin
	   $display("Decoder/Checker 8b test %08d:  Decoder [8b_symbol = %010b, K = %01b], Checker [8b_symbol = %010b, K = %01b] : %s : Decoder[%s%02d.%01d] : Checker[%s%02d.%01d]",
		    iteration, decoder_8b_symbol, decoder_K, checker_8b_symbol, checker_K,   
		    (decoder_checker_fail ? "FAIL" : "PASSED"),
		    ((decoder_K) ? "K" : "D"), decoder_X, decoder_Y,
		    ((checker_K) ? "K" : "D"), checker_X, checker_Y);
	   
	   if (!DEBUG) $stop;
	   
	end
      
      iteration++;
   endtask // automatic
   
  initial   
    begin   
       // Intlialise disparity and coding errors
       checker_K = 0; checker_disparity_err = 0; checker_code_err = 0;
  
       // Initialise checker 8b/10b generation
       encoder_8b10b_threads::init(null_rd, checker_disparity, checker_errors);
       
       // Obtain initial sync...
       @(posedge SBYTECLK);		 

       while (1)
	 begin
	    // Handle receive from TBI interface
	    if (~reset) decoder_8b_checker();  
	    @(posedge SBYTECLK);
	 end
    end
endmodule

