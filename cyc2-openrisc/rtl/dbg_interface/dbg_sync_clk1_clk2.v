//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_sync_clk1_clk2.v                                        ////
////                                                              ////
////  This file is part of the SoC/OpenRISC Development Interface ////
////  http://www.opencores.org/cores/DebugInterface/              ////
////                                                              ////
////  Author(s):                                                  ////
////      - Igor Mohor (igorM@opencores.org)                      ////
////                                                              ////
////  All additional information is avaliable in the Readme.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 Authors                                   ////
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
// Revision 1.1  2006/12/21 16:46:58  vak
// Initial revision imported from
// http://www.opencores.org/cvsget.cgi/or1k/orp/orp_soc/rtl/verilog.
//
// Revision 1.1.1.1  2002/03/21 16:55:44  lampret
// First import of the "new" XESS XSV environment.
//
//
// Revision 1.3  2001/11/26 10:47:09  mohor
// Crc generation is different for read or write commands. Small synthesys fixes.
//
// Revision 1.2  2001/10/19 11:40:01  mohor
// dbg_timescale.v changed to timescale.v This is done for the simulation of
// few different cores in a single project.
//
// Revision 1.1.1.1  2001/09/13 13:49:19  mohor
// Initial official release.
//
//
//
//
// 

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

// FF in clock domain 1 is being set by a signal from the clock domain 2
module dbg_sync_clk1_clk2 (clk1, clk2, reset1, reset2, set2, sync_out);

parameter   Tp = 1;

input   clk1;
input   clk2;
input   reset1;
input   reset2;
input   set2;

output  sync_out;

reg     set2_q;
reg     set2_q2;
reg     set1_q;
reg     set1_q2;
reg     clear2_q;
reg     clear2_q2;
reg     sync_out;

wire    z;

assign z = set2 | set2_q & ~clear2_q2;


// Latching and synchronizing "set" to clk2
always @ (posedge clk2 or posedge reset2)
begin
  if(reset2)
    set2_q <=#Tp 1'b0;
  else
    set2_q <=#Tp z;
end


always @ (posedge clk2 or posedge reset2)
begin
  if(reset2)
    set2_q2 <=#Tp 1'b0;
  else
    set2_q2 <=#Tp set2_q;
end


// Synchronizing "set" to clk1
always @ (posedge clk1 or posedge reset1)
begin
  if(reset1)
    set1_q <=#Tp 1'b0;
  else
    set1_q <=#Tp set2_q2;
end


always @ (posedge clk1 or posedge reset1)
begin
  if(reset1)
    set1_q2 <=#Tp 1'b0;
  else
    set1_q2 <=#Tp set1_q;
end


// Synchronizing "clear" to clk2
always @ (posedge clk2 or posedge reset2)
begin
  if(reset2)
    clear2_q <=#Tp 1'b0;
  else
    clear2_q <=#Tp set1_q2;
end


always @ (posedge clk2 or posedge reset2)
begin
  if(reset2)
    clear2_q2 <=#Tp 1'b0;
  else
    clear2_q2 <=#Tp clear2_q;
end


always @ (posedge clk1 or posedge reset1)
begin
  if(reset1)
    sync_out <=#Tp 1'b0;
  else
    sync_out <=#Tp set1_q2;
end

endmodule
