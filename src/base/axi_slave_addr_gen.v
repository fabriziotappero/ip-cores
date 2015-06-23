<##//////////////////////////////////////////////////////////////////
////                                                             ////
////  Author: Eyal Hochberg                                      ////
////          eyal@provartec.com                                 ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2010 Provartec LTD                            ////
//// www.provartec.com                                           ////
//// info@provartec.com                                          ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// This source file is free software; you can redistribute it  ////
//// and/or modify it under the terms of the GNU Lesser General  ////
//// Public License as published by the Free Software Foundation.////
////                                                             ////
//// This source is distributed in the hope that it will be      ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied  ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     ////
//// PURPOSE.  See the GNU Lesser General Public License for more////
//// details. http://www.gnu.org/licenses/lgpl.html              ////
////                                                             ////
//////////////////////////////////////////////////////////////////##>

OUTFILE PREFIX_addr_gen.v

INCLUDE def_axi_slave.txt

module PREFIX_addr_gen(PORTS);
   
   input 		      clk;
   input 		      reset;

   input [ADDR_BITS-1:0]      cmd_addr;
   input [SIZE_BITS-1:0] 	  cmd_size;

   input 		      advance;
   input 		      restart;

   output [ADDR_BITS-1:0]     ADDR;

   
   reg [ADDR_BITS-1:0] 	      offset;
   wire [3:0] 		      size_bytes;		      

   assign 		      size_bytes =
			      cmd_size == 2'b00 ? 4'd1 :
			      cmd_size == 2'b01 ? 4'd2 :
			      cmd_size == 2'b10 ? 4'd4 :
			      cmd_size == 2'b11 ? 4'd8 : 4'd0;
   
   always @(posedge clk or posedge reset)
     if (reset)
       offset <= #FFD {ADDR_BITS{1'b0}};
     else if (restart)
       offset <= #FFD {ADDR_BITS{1'b0}};
     else if (advance)
       offset <= #FFD offset + size_bytes;

   assign 		      ADDR = cmd_addr + offset;


endmodule

   
