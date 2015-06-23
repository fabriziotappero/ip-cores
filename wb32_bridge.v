/* Copyright 2005-2006, Technologic Systems
 * All Rights Reserved.
 *
 * Author(s): Jesse Off <joff@embeddedARM.com>
 */
 
/*
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License v2 as published by
 *  the Free Software Foundation.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */


module wb32_bridge(
  wb_clk_i,
  wb_rst_i,

  wb16_adr_i,
  wb16_dat_i,
  wb16_dat_o,
  wb16_cyc_i,
  wb16_stb_i,
  wb16_we_i,
  wb16_ack_o,

  wbm_adr_o,
  wbm_dat_o,
  wbm_dat_i,
  wbm_cyc_o,
  wbm_stb_o,
  wbm_we_o,
  wbm_ack_i,
  wbm_sel_o
);

input wb_clk_i, wb_rst_i;
input [22:0] wb16_adr_i;
input [15:0] wb16_dat_i;
output [15:0] wb16_dat_o;
input wb16_cyc_i, wb16_stb_i, wb16_we_i;
output wb16_ack_o;

output [21:0] wbm_adr_o;
output [3:0] wbm_sel_o;
input [31:0] wbm_dat_i;
output [31:0] wbm_dat_o;
output wbm_cyc_o, wbm_stb_o, wbm_we_o;
input wbm_ack_i;

reg [15:0] datlatch;
reg wb16_ack_o, wbm_cyc_o, wbm_stb_o;

assign wb16_dat_o = wb16_adr_i[0] ? datlatch : wbm_dat_i[15:0];
always @(wb16_adr_i or wb16_we_i or wb16_cyc_i or wb16_stb_i or wbm_ack_i) begin
  wb16_ack_o = 1'b0;
  wbm_cyc_o = 1'b0;
  wbm_stb_o = 1'b0;
  if (wb16_cyc_i && wb16_stb_i) begin
    if (!wb16_we_i && wb16_adr_i[0]) begin
      wb16_ack_o = 1'b1;
    end else if (wb16_we_i && !wb16_adr_i[0]) begin
      wb16_ack_o = 1'b1;
    end else begin
      wbm_cyc_o = 1'b1;
      wbm_stb_o = 1'b1;
      wb16_ack_o = wbm_ack_i;
    end
  end  
end 

assign wbm_dat_o = {wb16_dat_i, datlatch};
assign wbm_we_o = wb16_we_i;
assign wbm_adr_o = wb16_adr_i[22:1];
assign wbm_sel_o = 4'b1111;
always @(posedge wb_clk_i) begin
  if (wbm_ack_i && wbm_stb_o && wbm_cyc_o && !wbm_we_o)
    datlatch <= wbm_dat_i[31:16]; 

  if (wb16_cyc_i && wb16_stb_i && wb16_we_i && !wb16_adr_i[0])
    datlatch <= wb16_dat_i;
end

endmodule