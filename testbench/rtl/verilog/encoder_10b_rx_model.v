//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "encoder_10b_rx_model.v"                          ////
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

module encoder_10b_rx_model #(
  parameter DEBUG       = 0,
  parameter out_delay   = 5,
  parameter in_delay    = 2
)(
  interface check_intf,
  
   // --- Clocks
   input SBYTECLK,

   input reset,
		  
   // --- Ten bit input bus	  
   input [9:0] tbi_rx
);

   //----------------------------------------------------------------------------
  // Checker interface functions
  //----------------------------------------------------------------------------

   function automatic string check_intf.whoami();
      string buffer;
      $sformat(buffer, "%m");
      return buffer.substr(0, buffer.len()-17);
   endfunction

   //----------------------------------------------------------------------------
   // 10B symbol, disparity and coding checker 
   //----------------------------------------------------------------------------
   
   integer     iteration = 0; 
   
   reg [9:0]   checker_10b_symbol = 10'b0; reg [7:0] checker_8B_symbol = 8'b0;
   
   reg 	       null_rd, checker_rd, checker_k, checker_rd_err, checker_code_err;
   
   integer     checker_x, checker_y, checker_errors;
   
   task automatic encoder_10b_checker();

      // Pull the next byte
      checker_10b_symbol = tbi_rx;
      
      // Decode the 10b symbol from the checker model
      encoder_8b10b_threads::decode(checker_10b_symbol, checker_rd, checker_rd, checker_k, 
				    checker_8B_symbol, checker_rd_err, checker_code_err);

      // Split the 8b symbol into 5b/6b and 3b/4b components x and y - Dx.y and Kx.y 
      encoder_8b10b_threads::split(checker_8B_symbol, checker_x, checker_y);

      // Only check for errors after the first symbol
      //if (DEBUG | (iteration & (checker_rd_err | checker_code_err)))
      if (DEBUG)
	begin  
	   $display("Checker 10b %08d: [10b_symbol = %010b, RD = %01b, 8B_symbol = %08b, K = %01b, RD_err = %01b, CODE_err = %01b] : %s : %s%02d.%01d",
		    iteration, checker_10b_symbol,
		    checker_rd,  checker_8B_symbol, checker_k,  
		    checker_rd_err, checker_code_err, 
		    ((checker_rd_err | checker_code_err) ? "FAIL" : "PASSED"),
		    ((checker_k) ? "K" : "D"), checker_x, checker_y);
	   
	   // Halt if disparity or coding errors
	   if (!DEBUG) $stop;
	end
      
      iteration++;
   endtask // automatic
   
  initial   
    begin   
       // Intlialise disparity and coding errors
       checker_k = 0; checker_rd_err = 0; checker_code_err = 0;
  
       // Initialise checker 8B/10b generation
       encoder_8b10b_threads::init(null_rd, checker_rd, checker_errors);
       
       // On startup, the receiver (decoder) should assume +ve or -ve disparity
       // See IEEE 802.3-2005 Clause 35 - 36.2.4.4
       // I'm overiding the statup disparity set in encoder_8b10b_threads::init
       // so that it starts as -ve.
       checker_rd = 0;
       
       // Obtain initial sync...
       @(posedge SBYTECLK);		 

       while (~reset)
	 begin
	    // Handle receive from TBI interface
	    encoder_10b_checker();  
	    @(posedge SBYTECLK);
	 end
    end
endmodule

