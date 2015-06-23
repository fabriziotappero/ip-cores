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

INCLUDE def_axi2apb.txt
OUTFILE PREFIX_ctrl.v

module  PREFIX_ctrl (PORTS);


   input              clk;
   input              reset;

   input              finish_wr;
   input              finish_rd;
   
   input              cmd_empty;
   input              cmd_read;
   input              WVALID;

   output 		      psel;
   output 		      penable;
   output 		      pwrite;
   input 		      pready;
   
   
   wire	 		      wstart;
   wire                       rstart;
   
   reg                        busy;
   reg                        psel;
   reg 			      penable;
   reg 			      pwrite;
   wire                       pack;
   wire                       cmd_ready;
   

   assign                     cmd_ready = (~busy) & (~cmd_empty);
   assign                     wstart = cmd_ready & (~cmd_read) & (~psel) & WVALID;
   assign                     rstart = cmd_ready & cmd_read & (~psel);
   
   assign             pack = psel & penable & pready;
   
   always @(posedge clk or posedge reset)
     if (reset)
       busy <= #FFD 1'b0;
     else if (psel)
       busy <= #FFD 1'b1;
     else if (finish_rd | finish_wr)
       busy <= #FFD 1'b0;
   
   always @(posedge clk or posedge reset)
     if (reset)
       psel <= #FFD 1'b0;
     else if (pack)
       psel <= #FFD 1'b0;
     else if (wstart | rstart)
       psel <= #FFD 1'b1;
   
   always @(posedge clk or posedge reset)
     if (reset)
       penable <= #FFD 1'b0;
     else if (pack)
       penable <= #FFD 1'b0;
     else if (psel)
       penable <= #FFD 1'b1;

   always @(posedge clk or posedge reset)
     if (reset)
       pwrite  <= #FFD 1'b0;
     else if (pack)
       pwrite  <= #FFD 1'b0;
     else if (wstart)
       pwrite  <= #FFD 1'b1;
   

endmodule

   
