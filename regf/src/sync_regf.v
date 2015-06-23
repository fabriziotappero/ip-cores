//////////////////////////////////////////////////////////////////////
////                                                              ////
//// sync_regf                                                    ////
////                                                              ////
//// This file is part of the SXP opencores effort.               ////
//// <http://www.opencores.org/cores/sxp/>                        ////
////                                                              ////
//// Module Description:                                          ////
//// Synchronous reg file (Less latency than memory reg file)     ////
////                                                              ////
//// To Do:                                                       ////
////                                                              ////
//// Author(s):                                                   ////
//// - Sam Gladstone                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 Sam Gladstone and OPENCORES.ORG           ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// $Id: sync_regf.v,v 1.2 2001-11-09 00:05:49 samg Exp $ 
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

module sync_regf (
		clk,			// system clock
		reset_b,		// power on reset
		halt,			// system wide halt
	   	addra,			// Port A read address 
                a_en,			// Port A read enable
		addrb,			// Port B read address 
                b_en,			// Port B read enable 
		addrc,			// Port C write address 
	        dc,			// Port C write data 
		wec,			// Port C write enable 

		qra,			// Port A registered output data	
		qrb);			// Port B registered output data 	

parameter AWIDTH = 5;
parameter DSIZE  = 32;

input clk;
input reset_b;
input halt;
input [AWIDTH-1:0] addra;
input a_en;
input [AWIDTH-1:0] addrb;
input b_en;
input [AWIDTH-1:0] addrc;
input [DSIZE-1:0] dc;
input wec;

output [DSIZE-1:0] qra;
output [DSIZE-1:0] qrb;

// Internal varibles and signals
integer i;

reg [DSIZE-1:0] reg_file [0:(1<<AWIDTH)-1];	// Syncronous Reg file

assign qra = ((addrc == addra) && wec) ? dc : reg_file[addra];
assign qrb = ((addrc == addrb) && wec) ? dc : reg_file[addrb];

always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      for (i=0;i<(1<<AWIDTH);i=i+1)
        reg_file [i] <= {DSIZE{1'b x}};
    else
      if (wec)
        reg_file[addrc] <= dc;
  end

task reg_display;
  integer k;
  begin
    for (k=0;k<(1<<AWIDTH);k=k+1)
      $display("Location %d = %h",k,reg_file[k]); 
  end
endtask

endmodule
