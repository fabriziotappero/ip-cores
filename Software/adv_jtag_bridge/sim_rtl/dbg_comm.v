//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_comm.v                                                  ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC/OpenRISC Development Interface ////
////  http://www.opencores.org/cores/DebugInterface/              ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor  (igorm@opencores.org)                      ////
////       Nathan Yawn (nathan.yawn@opencores.org)                ////
////                                                              ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000-2008 Authors                              ////
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
// $Log: dbg_comm.v,v $
// Revision 1.4  2011-10-28 01:13:26  natey
// Ran through dos2unix.
//
// Revision 1.3  2009-05-17 20:55:57  Nathan
// Changed email address to opencores.org
//
// Revision 1.2  2008/07/22 18:23:25  Nathan
// Added clock and reset outputs to make simulation system simpler.  Fixed P_TRST signal name.  Added fflush calls to make file IO work as quickly as possible.  Write the data out bit on falling clock edge. Cleanup.
//
// Revision 1.1  2002/03/28 19:59:54  lampret
// Added bench directory
//
// Revision 1.1.1.1  2001/11/04 18:51:07  lampret
// First import.
//
// Revision 1.3  2001/09/24 14:06:13  mohor
// Changes connected to the OpenRISC access (SPR read, SPR write).
//
// Revision 1.2  2001/09/20 10:10:30  mohor
// Working version. Few bugs fixed, comments added.
//
// Revision 1.1.1.1  2001/09/13 13:49:19  mohor
// Initial official release.
//
//
//
//
//



`define GDB_IN	"e:/tmp/gdb_in.dat"
`define GDB_OUT	"e:/tmp/gdb_out.dat"


module dbg_comm(
   SYS_CLK,
   SYS_RSTN,
   P_TMS, 
   P_TCK, 
   P_TRST, 
   P_TDI, 
   P_TDO
   );

parameter Tp = 20;

output  SYS_CLK;
output  SYS_RSTN;
output		P_TMS;
output		P_TCK;
output		P_TRST;
output		P_TDI;
input		 P_TDO;

// Signal for the whole system
reg SYS_CLK;
reg SYS_RSTN;

// For handling data from the input file
integer handle1, handle2;
reg [4:0] memory[0:0];

wire P_TCK;
wire P_TRST;
wire P_TDI;
wire P_TMS;
wire P_TDO;

// Temp. signal
reg [3:0] in_word_r;



// Provide the wishbone / CPU / system clock
initial
begin
  SYS_CLK = 1'b0;
  forever #5 SYS_CLK = ~SYS_CLK; 
end

// Provide the system reset
initial
begin
   SYS_RSTN = 1'b1;
   #200 SYS_RSTN = 1'b0;
   #5000 SYS_RSTN = 1'b1;
end

// Set the initial state of the JTAG pins
initial
begin
  in_word_r = 4'h0;  // This sets the TRSTN output active...
end

// Handle input from a file for the JTAG pins
initial
begin
  #5500;  // Wait until reset is complete
  while(1)
  begin
    #Tp;
    $readmemh(`GDB_OUT, memory);
    if(!(memory[0] & 5'b10000))
    begin
	   in_word_r = memory[0][3:0];
      handle1 = $fopen(`GDB_OUT);
      $fwrite(handle1, "%h", 5'b10000 | memory[0]);  // To ack that we read dgb_out.dat
      $fflush(handle1);
      $fclose(handle1);
    end
  end
end

// Send the current state of the JTAG output to a file 
always @ (P_TDO or negedge P_TCK)
begin
  handle2 = $fopen(`GDB_IN);
  $fdisplay(handle2, "%b", P_TDO);
  $fflush(handle2);
  $fclose(handle2);
end

// Note these must match the bit definitions in the JTAG bridge program (adv_jtag_bridge)
assign P_TCK = in_word_r[0];
assign P_TRST = in_word_r[1];
assign P_TDI = in_word_r[2];
assign P_TMS = in_word_r[3];


endmodule // TAP

