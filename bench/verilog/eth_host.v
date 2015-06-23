//////////////////////////////////////////////////////////////////////
////                                                              ////
////  eth_host.v                                                  ////
////                                                              ////
////  This file is part of the Ethernet IP core project           ////
////  http://www.opencores.org/project,ethmac                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Igor Mohor (igorM@opencores.org)                      ////
////                                                              ////
////  All additional information is avaliable in the Readme.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001, 2002 Authors                             ////
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
//
//
//
//

`include "tb_eth_defines.v"
`include "timescale.v"

module eth_host
(
  // WISHBONE common
  wb_clk_i, wb_rst_i, 
  
  // WISHBONE master
  wb_adr_o, wb_sel_o, wb_we_o, wb_dat_i, wb_dat_o, wb_cyc_o, wb_stb_o, wb_ack_i, wb_err_i
);

parameter Tp=1;

input         wb_clk_i, wb_rst_i;

input  [31:0] wb_dat_i;
input         wb_ack_i, wb_err_i;

output [31:0] wb_adr_o, wb_dat_o;
output  [3:0] wb_sel_o;
output        wb_cyc_o, wb_stb_o, wb_we_o;

reg    [31:0] wb_adr_o, wb_dat_o;
reg     [3:0] wb_sel_o;
reg           wb_cyc_o, wb_stb_o, wb_we_o;

integer host_log;

// Reset pulse
initial
begin
  host_log = $fopen("eth_host.log");
end


task wb_write;

  input  [31:0] addr;
  input   [3:0] sel;
  input  [31:0] data;

  begin
    @ (posedge wb_clk_i);   // Sync. with clock
    #1;
    wb_adr_o = addr;
    wb_dat_o = data;
    wb_sel_o = sel;
    wb_cyc_o = 1;
    wb_stb_o = 1;
    wb_we_o  = 1;
  
    wait(wb_ack_i | wb_err_i);
    $fdisplay(host_log, "(%0t)(%m)wb_write (0x%0x) = 0x%0x", $time, wb_adr_o, wb_dat_o);
    @ (posedge wb_clk_i);   // Sync. with clock
    #1;
    wb_adr_o = 'hx;
    wb_dat_o = 'hx;
    wb_sel_o = 'hx;
    wb_cyc_o = 0;
    wb_stb_o = 0;
    wb_we_o  = 'hx;
  end
endtask


task wb_read;

  input  [31:0] addr;
  input   [3:0] sel;
  output [31:0] data;

  begin
    @ (posedge wb_clk_i);   // Sync. with clock
    #1;
    wb_adr_o = addr;
    wb_sel_o = sel;
    wb_cyc_o = 1;
    wb_stb_o = 1;
    wb_we_o  = 0;
  
    wait(wb_ack_i | wb_err_i);
    @ (posedge wb_clk_i);   // Sync. with clock
    data = wb_dat_i;
    $fdisplay(host_log, "(%0t)(%m)wb_read (0x%0x) = 0x%0x", $time, wb_adr_o, wb_dat_i);
    #1;
    wb_adr_o = 'hx;
    wb_sel_o = 'hx;
    wb_cyc_o = 0;
    wb_stb_o = 0;
    wb_we_o  = 'hx;
  end
endtask



endmodule
