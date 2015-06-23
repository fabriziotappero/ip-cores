//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Testbench for Verilog translation of SystemC DES            ////
////                                                              ////
////  This file is part of the SystemC DES                        ////
////                                                              ////
////  Description:                                                ////
////  DES testbench                                               ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////   - Add more test cases                                      ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, jcastilo@opencores.org               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.1.1.1  2004/07/05 17:31:18  jcastillo
// First import
//

`timescale 10ns/1ns

module top;



reg clk, reset, load_i, decrypt_i;
reg [63:0] data_i, key_i;
wire [63:0] data_o;
wire ready_o;

reg [191:0]  tmp;
reg	[191:0]	x[6:0];
integer		ZZZ;
integer     select;


des d1(clk,reset,load_i,decrypt_i,data_i,key_i,data_o,ready_o);

   initial

   begin
	$display("\n\n");
	$display("******************************************");
	$display("* DES core simulation started ...        *");
	$display("******************************************");
	$display("\n");
	$display("Running\n");
	
	
	clk = 'b1;
	reset = 'b0;  
    @(posedge clk);
	@(posedge clk);
	reset = 'b1;
		
    ZZZ=0;
    
	
	//Decrypt
	//              Key               Data
	x[ZZZ]=192'h0cb76ea9864252f4_34ffd445a8f4e555_a1971ff745ad8b38; ZZZ=ZZZ+1;
	x[ZZZ]=192'h0123456789ABCDEF_0000000000000000_14AAD7F4DBB4E094; ZZZ=ZZZ+1;
	x[ZZZ]=192'h0000000000000000_123456789ABCDEF0_9D2A73F6A9070648; ZZZ=ZZZ+1;
	x[ZZZ]=192'h23FE536344578A49_123456789ABCDEF0_F4E5D5EFAA638C43; ZZZ=ZZZ+1;
	
	//Encrypt
	x[ZZZ]=192'h0123456789ABCDEF_0000000000000000_D5D44FF720683D0D; ZZZ=ZZZ+1;
      x[ZZZ]=192'h0000000000000000_123456789ABCDEF0_9D2A73F6A9070648; ZZZ=ZZZ+1;
      x[ZZZ]=192'h23FE536344578A49_123456789ABCDEF0_1862EC2AA88BA258; ZZZ=ZZZ+1;

	
	for(select=0;select<ZZZ;select=select+1)
	begin
	   
	   @(posedge clk);
  	   load_i = 1'b0;
	   decrypt_i = !(select>3);
	   tmp=x[select];
	   key_i=tmp[191:128];
	   data_i=tmp[127:64];
	   load_i = #1 1'b1;
	   @(posedge clk);
	   load_i = #1 1'b0;
	   
       while(!ready_o)	@(posedge clk);
	   //$display("Got %x", data_o);
	   if(data_o!=tmp[63:0])
	     $display("ERROR: (%0d) Expected %x Got %x", select, tmp[63:0], data_o);
	   
    end
   	
	$display("");
	$display("**************************************");
	$display("* DES Test done ...                  *");
	$display("**************************************");
	$display("");

	$finish;
   end
   always #5 clk = !clk;

endmodule
