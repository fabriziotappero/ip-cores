//////////////////////////////////////////////////////////////////////
////                                                              ////
//// cpu_behavioral.v                                             ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC Debug Interface.               ////
////  http://www.opencores.org/projects/DebugInterface/           ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor (igorm@opencores.org)                       ////
////                                                              ////
////                                                              ////
////  All additional information is avaliable in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 - 2004 Authors                            ////
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
// $Log: cpu_behavioral.v,v $
// Revision 1.2  2010-01-08 01:41:08  Nathan
// Removed unused, non-existant include from CPU behavioral model.  Minor text edits.
//
// Revision 1.1  2008/07/08 19:11:55  Nathan
// Added second testbench to simulate a complete system, including OR1200, wb_conbus, and onchipram.  Renamed sim-only testbench directory from verilog to simulated_system.
//
// Revision 1.1  2008/06/18 18:34:48  Nathan
// Initial working version.  Only Wishbone module implemented.  Simple testbench included, with CPU and Wishbone behavioral models from the old dbg_interface.
//
// Revision 1.1.1.1  2008/05/14 12:07:35  Nathan
// Original from OpenCores
//
// Revision 1.4  2004/03/28 20:27:40  igorm
// New release of the debug interface (3rd. release).
//
// Revision 1.3  2004/01/22 11:07:28  mohor
// test stall_test added.
//
// Revision 1.2  2004/01/17 18:01:31  mohor
// New version.
//
// Revision 1.1  2004/01/17 17:01:25  mohor
// Almost finished.
//
//
//
//
//
`include "timescale.v"


module cpu_behavioral
                   (
                    // CPU signals
                    cpu_rst_i,
                    cpu_clk_o,
                    cpu_addr_i,
                    cpu_data_o,
                    cpu_data_i,
                    cpu_bp_o,
                    cpu_stall_i,
                    cpu_stb_i,
                    cpu_we_i,
                    cpu_ack_o,
                    cpu_rst_o
                   );


// CPU signals
input         cpu_rst_i;
output        cpu_clk_o;
input  [31:0] cpu_addr_i;
output [31:0] cpu_data_o;
input  [31:0] cpu_data_i;
output        cpu_bp_o;
input         cpu_stall_i;
input         cpu_stb_i;
input         cpu_we_i;
output        cpu_ack_o;
output        cpu_rst_o;

reg           cpu_clk_o;
reg    [31:0] cpu_data_o;
reg           cpu_bp_o;
reg           cpu_ack_o;
reg           cpu_ack_q;
wire          cpu_ack;
initial
begin
  cpu_clk_o = 1'b0;
  forever #5 cpu_clk_o = ~cpu_clk_o;
end


initial
begin
  cpu_bp_o = 1'b0;
end

assign #200 cpu_ack = cpu_stall_i & cpu_stb_i;



always @ (posedge cpu_clk_o or posedge cpu_rst_i)
begin
  if (cpu_rst_i)
    begin
      cpu_ack_o <= #1 1'b0;
      cpu_ack_q <= #1 1'b0;
    end
  else
    begin
      cpu_ack_o <= #1 cpu_ack;
      cpu_ack_q <= #1 cpu_ack_o;
    end
end

always @ (posedge cpu_clk_o or posedge cpu_rst_i)
begin
  if (cpu_rst_i)
    cpu_data_o <= #1 32'h12345678;
  else if (cpu_ack_o && (!cpu_ack_q))
    cpu_data_o <= #1 cpu_data_o + 32'h11111111;
end




endmodule

