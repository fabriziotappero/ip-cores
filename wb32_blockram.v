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


module wb32_blockram(
  wb_clk_i,
  wb_rst_i,

  wb1_adr_i,
  wb1_dat_i,
  wb1_dat_o,
  wb1_cyc_i,
  wb1_stb_i,
  wb1_ack_o,
  wb1_we_i,
  wb1_sel_i,

  wb2_adr_i,
  wb2_dat_i,
  wb2_dat_o,
  wb2_cyc_i,
  wb2_stb_i,
  wb2_ack_o,
  wb2_we_i,
  wb2_sel_i
);

input wb_clk_i, wb_rst_i;
input [10:0] wb1_adr_i, wb2_adr_i;
input [31:0] wb1_dat_i, wb2_dat_i;
input wb1_cyc_i, wb2_cyc_i, wb1_stb_i, wb2_stb_i, wb1_we_i, wb2_we_i;
input [3:0] wb1_sel_i, wb2_sel_i;
output [31:0] wb1_dat_o, wb2_dat_o;
output reg wb1_ack_o, wb2_ack_o;

/* Set if wb1 and wb2 are opposite endianness */
parameter endian_swap = 1'b0;

reg [31:0] blockram_data_i;
reg [10:0] blockram_rdadr_i, blockram_wradr_i;
wire [31:0] blockram_data_o;
reg [3:0] blockram_wren;
altera_ram blockram0(
  .clock(wb_clk_i),
  .data(blockram_data_i[7:0]),
  .rdaddress(blockram_rdadr_i),
  .wraddress(blockram_wradr_i),
  .wren(blockram_wren[0]),
  .q(blockram_data_o[7:0])
);
altera_ram blockram1(
  .clock(wb_clk_i),
  .data(blockram_data_i[15:8]),
  .rdaddress(blockram_rdadr_i),
  .wraddress(blockram_wradr_i),
  .wren(blockram_wren[1]),
  .q(blockram_data_o[15:8])
);
altera_ram blockram2(
  .clock(wb_clk_i),
  .data(blockram_data_i[23:16]),
  .rdaddress(blockram_rdadr_i),
  .wraddress(blockram_wradr_i),
  .wren(blockram_wren[2]),
  .q(blockram_data_o[23:16])
);
altera_ram blockram3(
  .clock(wb_clk_i),
  .data(blockram_data_i[31:24]),
  .rdaddress(blockram_rdadr_i),
  .wraddress(blockram_wradr_i),
  .wren(blockram_wren[3]),
  .q(blockram_data_o[31:24])
);

reg rdowner = 1'b0;
reg wrowner = 1'b0;
reg wb1_rdreq, wb2_rdreq, wb1_wrreq, wb2_wrreq;
always @(rdowner or wrowner or wb1_adr_i or wb2_adr_i or wb1_dat_i or
  wb2_dat_i or wb1_sel_i or wb2_sel_i or rdowner or wrowner or
  wb2_wrreq or wb1_wrreq or endian_swap) begin
  if (rdowner) blockram_rdadr_i = wb2_adr_i;
  else blockram_rdadr_i = wb1_adr_i;

  blockram_wren = 4'b0000;
  if (wrowner) begin
    blockram_wradr_i = wb2_adr_i;
    if (endian_swap) begin
      blockram_data_i = {wb2_dat_i[7:0], wb2_dat_i[15:8], wb2_dat_i[23:16],
                         wb2_dat_i[31:24]};
      if (wb2_wrreq) blockram_wren = {wb2_sel_i[0], wb2_sel_i[1], wb2_sel_i[2],
                                      wb2_sel_i[3]};
    end else begin
      blockram_data_i = wb2_dat_i;
      if (wb2_wrreq) blockram_wren = wb2_sel_i;
    end
  end else begin
    blockram_wradr_i = wb1_adr_i;
    blockram_data_i = wb1_dat_i;
    if (wb1_wrreq) blockram_wren = wb1_sel_i;
  end
end

assign wb1_dat_o = blockram_data_o;
assign wb2_dat_o = endian_swap ? {blockram_data_o[7:0], 
  blockram_data_o[15:8], blockram_data_o[23:16], blockram_data_o[31:24]} : 
  blockram_data_o;

always @(wb1_cyc_i or wb1_stb_i or wb1_we_i or wb_rst_i or
  wb2_cyc_i or wb2_stb_i or wb2_we_i or rdowner or wrowner or
  wb1_ack_o or wb2_ack_o) begin
  wb1_rdreq = wb1_cyc_i && wb1_stb_i && !wb1_we_i && !wb1_ack_o;
  wb2_rdreq = wb2_cyc_i && wb2_stb_i && !wb2_we_i && !wb2_ack_o;
  wb1_wrreq = wb1_cyc_i && wb1_stb_i && wb1_we_i && !wb1_ack_o;
  wb2_wrreq = wb2_cyc_i && wb2_stb_i && wb2_we_i && !wb2_ack_o;

  if (rdowner) begin
    if (wb1_rdreq && !wb2_rdreq) rdowner = 1'b0;
    else rdowner = 1'b1;
  end else begin
    if (!wb1_rdreq && wb2_rdreq) rdowner = 1'b1;
    else rdowner = 1'b0;
  end

  if (wrowner) begin
    if (wb1_wrreq && !wb2_wrreq) wrowner = 1'b0;
    else wrowner = 1'b1;
  end else begin
    if (!wb1_wrreq && wb2_wrreq) wrowner = 1'b1;
    else wrowner = 1'b0;
  end

  if (wb_rst_i) begin
    rdowner = 1'b0;
    wrowner = 1'b0;
  end
end

always @(posedge wb_clk_i) begin
  wb1_ack_o <= 1'b0;
  wb2_ack_o <= 1'b0;
  if (wb1_rdreq && !rdowner && !wb1_ack_o) begin
    wb1_ack_o <= 1'b1;
  end else if (wb2_rdreq && rdowner && !wb2_ack_o) begin
    wb2_ack_o <= 1'b1;
  end

  if (wb1_wrreq && !wrowner && !wb1_ack_o) begin
    wb1_ack_o <= 1'b1;
  end else if (wb2_wrreq && wrowner && !wb2_ack_o) begin
    wb2_ack_o <= 1'b1;
  end
end

endmodule