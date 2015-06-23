//////////////////////////////////////////////////////////////////////
////                                                              ////
////  eth_memory.v                                                ////
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

module eth_memory
(
  wb_clk_i, wb_rst_i, wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i, 
  wb_stb_i, wb_ack_o, wb_err_o, wb_dat_o, wb_dat_i
);

parameter Tp=1;

input         wb_clk_i, wb_rst_i;
input  [31:0] wb_adr_i, wb_dat_i;
input   [3:0] wb_sel_i;
input         wb_we_i, wb_cyc_i, wb_stb_i;

output        wb_ack_o, wb_err_o;
output [31:0] wb_dat_o;

reg           wb_ack_o, wb_err_o;
reg    [31:0] wb_dat_o;

reg     [7:0] memory0 [0:65535];
reg     [7:0] memory1 [0:65535];
reg     [7:0] memory2 [0:65535];
reg     [7:0] memory3 [0:65535];

integer memory_log;

// Reset pulse
initial
begin
  memory_log = $fopen("eth_memory.log");
  wb_ack_o = 0;
  wb_err_o = 0;
end


always @ (posedge wb_clk_i)
begin
  if(wb_cyc_i & wb_stb_i)
    begin
      repeat(1) @ (posedge wb_clk_i);     // Waiting 3 clock cycles before ack is set
        begin                             // (you can add some random function here)
          #1;
          wb_ack_o = 1'b1;
          if(~wb_we_i)
            begin
              if(wb_adr_i[1:0] == 2'b00)       // word access
                begin
                  wb_dat_o[31:24] = memory3[wb_adr_i[17:2]];
                  wb_dat_o[23:16] = memory2[wb_adr_i[17:2]];
                  wb_dat_o[15:08] = memory1[wb_adr_i[17:2]];
                  wb_dat_o[07:00] = memory0[wb_adr_i[17:2]];
                end
              else if(wb_adr_i[1:0] == 2'b10)       // half access
                begin
                  wb_dat_o[31:24] = 0;
                  wb_dat_o[23:16] = 0;
                  wb_dat_o[15:08] = memory1[wb_adr_i[17:2]];
                  wb_dat_o[07:00] = memory0[wb_adr_i[17:2]];
                end
              else if(wb_adr_i[1:0] == 2'b01)       // byte access
                begin
                  wb_dat_o[31:24] = 0;
                  wb_dat_o[23:16] = memory2[wb_adr_i[17:2]];
                  wb_dat_o[15:08] = 0;
                  wb_dat_o[07:00] = 0;
                end
              else if(wb_adr_i[1:0] == 2'b11)       // byte access
                begin
                  wb_dat_o[31:24] = 0;
                  wb_dat_o[23:16] = 0;
                  wb_dat_o[15:08] = 0;
                  wb_dat_o[07:00] = memory0[wb_adr_i[17:2]];
                end

              $fdisplay(memory_log, "(%0t)(%m)wb_read (0x%0x) = 0x%0x", $time, wb_adr_i, wb_dat_o);
            end
          else
            begin
              $fdisplay(memory_log, "(%0t)(%m)wb_write (0x%0x) = 0x%0x", $time, wb_adr_i, wb_dat_i);
              if(wb_sel_i[0])
                memory0[wb_adr_i[17:2]] = wb_dat_i[7:0];
              if(wb_sel_i[1])
                memory1[wb_adr_i[17:2]] = wb_dat_i[15:8];
              if(wb_sel_i[2])
                memory2[wb_adr_i[17:2]] = wb_dat_i[23:16];
              if(wb_sel_i[3])
                memory3[wb_adr_i[17:2]] = wb_dat_i[31:24];
            end
        end
      @ (posedge wb_clk_i);
      wb_ack_o <=#Tp 1'b0;
    end
end



endmodule
