/*
 *  Copyright (c) 2008  Zeus Gomez Marmolejo <zeus@opencores.org>
 *
 *  This file is part of the Zet processor. This processor is free
 *  hardware; you can redistribute it and/or modify it under the terms of
 *  the GNU General Public License as published by the Free Software
 *  Foundation; either version 3, or (at your option) any later version.
 *
 *  Zet is distrubuted in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
 *  License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Zet; see the file COPYING. If not, see
 *  <http://www.gnu.org/licenses/>.
 */

`include "defines.v"

module zbt_cntrl (
`ifdef DEBUG
    output reg [2:0] cnt,
    output           op,
`endif

    // Wishbone slave interface
    input             wb_clk_i,
    input             wb_rst_i,
    input      [15:0] wb_dat_i,
    output reg [15:0] wb_dat_o,
    input      [19:1] wb_adr_i,
    input             wb_we_i,
    input      [ 1:0] wb_sel_i,
    input             wb_stb_i,
    input             wb_cyc_i,
    output            wb_ack_o,

    // Pad signals
    output            sram_clk_,
    output reg [20:0] sram_addr_,
    inout      [31:0] sram_data_,
    output reg        sram_we_n_,
    output reg [ 3:0] sram_bw_,
    output reg        sram_cen_,
    output            sram_adv_ld_n_
  );

  // Registers and nets
  reg  [31:0] wr;
  wire        nload;

`ifndef DEBUG
  reg [ 3:0] cnt;
  wire       op;
`endif

  // Continuous assignments
  assign op   = wb_stb_i & wb_cyc_i;
  assign nload = |cnt;

  assign sram_clk_      = wb_clk_i;
  assign sram_adv_ld_n_ = 1'b0;
  assign sram_data_     = (op && wb_we_i) ? wr : 32'hzzzzzzzz;
  assign wb_ack_o       = cnt[3];

  // Behaviour
  // cnt
  always @(posedge wb_clk_i)
    cnt <= wb_rst_i ? 4'b0
         : { cnt[2:0], nload ? 1'b0 : op };

  // wb_dat_o
  always @(posedge wb_clk_i)
    wb_dat_o <= cnt[2] ? (wb_adr_i[1] ? sram_data_[31:16]
                                      : sram_data_[15:0]) : wb_dat_o;

  // sram_addr_
  always @(posedge wb_clk_i)
    sram_addr_ <= op ? { 3'b0, wb_adr_i[19:2] } : sram_addr_;

  // sram_we_n_
  always @(posedge wb_clk_i)
    sram_we_n_ <= wb_we_i ? (nload ? 1'b1 : !op) : 1'b1;

  // sram_bw_
  always @(posedge wb_clk_i)
    sram_bw_ <= wb_adr_i[1] ? { ~wb_sel_i, 2'b11 }
                            : { 2'b11, ~wb_sel_i };

  // sram_cen_
  always @(posedge wb_clk_i)
    sram_cen_ <= wb_rst_i ? 1'b1 : !op;

  // wr
  always @(posedge wb_clk_i)
    wr <= op ? (wb_adr_i[1] ? { wb_dat_i, 16'h0 }
                            : { 16'h0, wb_dat_i }) : wr;
endmodule
