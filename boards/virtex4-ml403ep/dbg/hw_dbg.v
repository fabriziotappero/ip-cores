/*
 *  Copyright (c) 2009  Zeus Gomez Marmolejo <zeus@opencores.org>
 *
 *  Nobody can figure out what this file is for... hehe
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

`timescale 1ns/10ps

module hw_dbg (
    input      clk,
    input      rst_lck,
    output reg rst,
    input      butc_,
    input      bute_,
    input      butw_,
    input      butn_,
    input      buts_,

    // Wishbone master interface for the VDU
    output reg [15:0] vdu_dat_o,
    output reg [11:1] vdu_adr_o,
    output            vdu_we_o,
    output            vdu_stb_o,
    output     [ 1:0] vdu_sel_o,
    output reg        vdu_tga_o,
    input             vdu_ack_i,

    // Wishbone master interface for the ZBT SRAM
    input      [15:0] zbt_dat_i,
    output     [19:1] zbt_adr_o,
    output            zbt_we_o,
    output     [ 1:0] zbt_sel_o,
    output reg        zbt_stb_o,
    input             zbt_ack_i
  );

  // Registers and nets
  reg [ 5:0] st;
  reg        op;
  reg [ 6:0] cur;
  reg        mr, ml, md, mu, dm;
  reg        br, bl, bd, bu, bc;
  reg [15:0] cnt;
  reg [ 4:0] i;
  reg [19:0] adr;
  reg [ 2:0] sp;
  reg [15:0] col;
  reg [ 3:0] nibb;
  reg [ 7:0] low_adr;

  wire [7:0] o;
  wire       cur_dump;
  wire       action;
  wire [2:0] off;
  wire [3:0] nib, inc_nib, dec_nib;
  wire       up_down;
  wire       left_right;
  wire       spg;

  // Module instantiations
  init_msg msg0 (
    .i (i),
    .o (o)
  );

  inc i0 (
    .i (nib),
    .o (inc_nib)
  );

  dec d0 (
    .i (nib),
    .o (dec_nib)
  );

  // Continuous assignments
  assign vdu_we_o  = op;
  assign vdu_stb_o = op;
  assign vdu_sel_o = 2'b11;
  assign zbt_we_o  = 1'b0;
  assign zbt_sel_o = 2'b11;
  assign cur_dump  = (cur < 7'd25 && cur > 7'd19);
  assign off       = cur - 7'd20;
  assign nib = off==3'd0 ? adr[19:16]
            : (off==3'd1 ? adr[15:12]
            : (off==3'd2 ? adr[11:8]
            : (off==3'd3 ? adr[7:4] : adr[3:0])));

  assign left_right = mr | ml;
  assign up_down    = mu | md;
  assign action     = left_right | up_down | dm;
  assign spg        = sp>3'b0;
  assign zbt_adr_o  = { adr[19:5] + low_adr[7:4], low_adr[3:0] };

  // Behaviour
  always @(posedge clk)
    if (rst_lck)
      begin
        vdu_dat_o <= 16'd12;
        vdu_adr_o <= 11'h4;
        vdu_tga_o <= 1'b1;
        st  <= 6'd0;
        op  <= 1'b1;
        i   <= 4'h0;
        zbt_stb_o <= 1'b0;
      end
    else
      case (st)
        6'd0: if (vdu_ack_i) begin
                vdu_dat_o <= { 8'h06, o };
                vdu_adr_o <= i + 5'h4;
                vdu_tga_o <= 1'b0;
                st <= (i==5'd21) ? 6'h2 : 6'h1;
                op <= 1'b0;
                i  <= i + 5'h1;
              end
        6'd1: if (!vdu_ack_i) begin
                st <= 6'h0;
                op <= 1'b1;
                i  <= i;
              end
        6'd2: // main wait state
              if (!vdu_ack_i && action) begin
                vdu_dat_o <= mr ? (cur==7'd15 ? 7'd20 : cur + 7'b1)
                           : ((ml && cur==7'd20) ? 7'd15 : cur - 7'b1);
                vdu_adr_o <= 11'h0;
                vdu_tga_o <= 1'b1;
                st  <= left_right ? 6'h3 : (dm ? 6'h5 : 6'h4);
                op  <= left_right;
                col  <= 16'd80;
                sp   <= 2'h3;
                nibb <= 4'h0;
              end
        6'd3: if (vdu_ack_i) begin
                vdu_dat_o <= 16'h0;
                vdu_adr_o <= 11'h0;
                vdu_tga_o <= 1'b1;
                st <= 6'h2;
                op <= 1'b0;
              end
        6'd4: // redraw the mem_dump counter
              if (!vdu_ack_i) begin
                vdu_dat_o <= { 8'h03, itoa(nib) };
                vdu_adr_o <= cur;
                vdu_tga_o <= 1'b0;
                st <= 6'h3;
                op <= 1'b1;
              end
        6'd5: // memory dump
              if (!vdu_ack_i) begin
                vdu_dat_o <= { 8'h05, spg ? 8'h20 : itoa(nibb) };
                vdu_adr_o <= col;
                vdu_tga_o <= 1'b0;
                st <= 6'h6;
                op <= 1'b1;
                sp <= spg ? (sp - 3'b1) : 3'd4;
                col <= col + 16'd1;
                nibb <= spg ? nibb : (nibb + 4'h2);
              end
        6'd6: if (vdu_ack_i) begin
                st <= (col==16'd160) ? 6'h7 : 6'h5;
                op <= 1'b0;
              end
        6'd7: begin
                low_adr <= 8'h0;
                st <= 6'h8;
              end
        6'd8: if (!vdu_ack_i) begin
                vdu_dat_o <= { 8'h5, itoa(zbt_adr_o[7:4]) };
                vdu_adr_o <= col;
                st <= 6'd9;
                op <= 1'b1;
              end
        6'd9: if (vdu_ack_i) begin
                st <= 6'd10;
                op <= 1'b0;
                col <= col + 16'd1;
              end
        6'd10: if (!zbt_ack_i) begin
                st <= 6'd11;
                zbt_stb_o <= 1'b1;
              end
        6'd11: if (zbt_ack_i) begin
                st <= 6'd12;
                zbt_stb_o <= 1'b0;
              end
        6'd12: if (!vdu_ack_i) begin
                vdu_dat_o <= { 8'h7, itoa(zbt_dat_i[15:12]) };
                vdu_adr_o <= col;
                st <= 6'd13;
                op <= 1'b1;
              end
        6'd13: if (vdu_ack_i) begin
                st <= 6'd14;
                op <= 1'b0;
                col <= col + 16'd1;
              end
        6'd14: if (!vdu_ack_i) begin
                vdu_dat_o <= { 8'h7, itoa(zbt_dat_i[11:8]) };
                vdu_adr_o <= col;
                st <= 6'd15;
                op <= 1'b1;
              end
        6'd15: if (vdu_ack_i) begin
                st <= 6'd16;
                op <= 1'b0;
                col <= col + 16'd1;
              end
        6'd16: if (!vdu_ack_i) begin
                vdu_dat_o <= { 8'h7, itoa(zbt_dat_i[7:4]) };
                vdu_adr_o <= col;
                st <= 6'd17;
                op <= 1'b1;
              end
        6'd17: if (vdu_ack_i) begin
                st <= 6'd18;
                op <= 1'b0;
                col <= col + 16'd1;
              end
        6'd18: if (!vdu_ack_i) begin
                vdu_dat_o <= { 8'h7, itoa(zbt_dat_i[3:0]) };
                vdu_adr_o <= col;
                st <= 6'd19;
                op <= 1'b1;
              end
        6'd19: if (vdu_ack_i) begin
                st <= (zbt_adr_o[4:1]==4'hf) ? 6'd22 : 6'd20;
                op <= 1'b0;
                col <= col + 16'd1;
                low_adr <= low_adr + 8'h1;
              end
        6'd20: if (!vdu_ack_i) begin
                vdu_dat_o <= 16'h0720;
                vdu_adr_o <= col;
                st <= 6'd21;
                op <= 1'b1;
              end
        6'd21: if (vdu_ack_i) begin
                st <= 6'd10;
                op <= 1'b0;
                col <= col + 16'd1;
              end
        6'd22: st <= (low_adr==8'h0) ? 6'd2 : 6'd8;
      endcase

  // rst
  always @(posedge clk)
    rst <= rst_lck ? 1'b1 : ((butc_ && cur==7'd12) ? 1'b0 : rst);

  // cur
  always @(posedge clk)
    cur <= rst_lck ? 7'd12 : (mr ? (cur==7'd15 ? 7'd20 : cur + 7'b1)
                           : (ml ? (cur==7'd20 ? 7'd15 : cur - 7'b1) : cur));

  // adr
  always @(posedge clk)
    adr <= rst_lck ? 16'h0
      : (mu ? (off==3'd0 ? { inc_nib, adr[15:0] }
            : (off==3'd1 ? { adr[19:16], inc_nib, adr[11:0] }
            : (off==3'd2 ? { adr[19:12], inc_nib, adr[7:0] }
            : (off==3'd3 ? { adr[19:8], inc_nib, adr[3:0] }
            : { adr[19:4], inc_nib }))))
      : (md ? (off==3'd0 ? { dec_nib, adr[15:0] }
            : (off==3'd1 ? { adr[19:16], dec_nib, adr[11:0] }
            : (off==3'd2 ? { adr[19:12], dec_nib, adr[7:0] }
            : (off==3'd3 ? { adr[19:8], dec_nib, adr[3:0] }
            : { adr[19:4], dec_nib })))) : adr));

  // mr - move right
  always @(posedge clk)
    mr <= rst_lck ? 1'b0 : (bute_ && !br
                            && cnt==16'h0 && cur != 7'd24);

  // br - button right
  always @(posedge clk) br <= (cnt==16'h0 ? bute_ : br);

  // ml - move right
  always @(posedge clk)
    ml <= rst_lck ? 1'b0 : (butw_ && !bl
                            && cnt==16'h0 && cur != 7'd12);

  // bl - button right
  always @(posedge clk) bl <= (cnt==16'h0 ? butw_ : bl);

  // md - move down
  always @(posedge clk)
    md <= rst_lck ? 1'b0 : (buts_ && !bd && cnt==16'h0 && cur_dump);

  // bd - button down
  always @(posedge clk) bd <= (cnt==16'h0 ? buts_ : bd);

  // mu - move up
  always @(posedge clk)
    mu <= rst_lck ? 1'b0 : (butn_ && !bu && cnt==16'h0 && cur_dump);

  // bu - button up
  always @(posedge clk) bu <= (cnt==16'h0 ? butn_ : bu);

  // dm - dump
  always @(posedge clk)
    dm <= rst_lck ? 1'b0 : (butc_ && !bc && cur==7'd13);

  // bc - center button
  always @(posedge clk) bc <= (cnt==16'h0 ? butc_ : bc);

  // cnt - button counter
  always @(posedge clk) cnt <= cnt + 1'b1;

  function [7:0] itoa;
    input [3:0] i;
    begin
      if (i < 8'd10) itoa = i + 8'h30;
      else itoa = i + 8'h57;
    end
  endfunction
endmodule

module init_msg (
    input      [4:0] i,
    output reg [7:0] o
  );

  // Behaviour
  always @(i)
    case (i)
      5'h00: o <= 8'h68; // h
      5'h01: o <= 8'h77; // w
      5'h02: o <= 8'h5f; // _
      5'h03: o <= 8'h64; // d
      5'h04: o <= 8'h62; // b
      5'h05: o <= 8'h67; // g
      5'h06: o <= 8'h20; //
      5'h07: o <= 8'h5b; // [
      5'h08: o <= 8'h43; // C
      5'h09: o <= 8'h44; // D
      5'h0a: o <= 8'h57; // W
      5'h0b: o <= 8'h42; // B
      5'h0c: o <= 8'h5d; // ]
      5'h0d: o <= 8'h20; //
      5'h0f: o <= 8'h78; // x
      default: o <= 8'h30; // 0
    endcase
endmodule

module inc (
    input      [3:0] i,
    output reg [3:0] o
  );

  // Behaviour
  always @(i)
    case (i)
      4'h0: o <= 4'h1;
      4'h1: o <= 4'h2;
      4'h2: o <= 4'h3;
      4'h3: o <= 4'h4;
      4'h4: o <= 4'h5;
      4'h5: o <= 4'h6;
      4'h6: o <= 4'h7;
      4'h7: o <= 4'h8;
      4'h8: o <= 4'h9;
      4'h9: o <= 4'ha;
      4'ha: o <= 4'hb;
      4'hb: o <= 4'hc;
      4'hc: o <= 4'hd;
      4'hd: o <= 4'he;
      4'he: o <= 4'hf;
      default: o <= 4'h0;
    endcase
endmodule

module dec (
    input      [3:0] i,
    output reg [3:0] o
  );

  // Behaviour
  always @(i)
    case (i)
      4'h0: o <= 4'hf;
      4'h1: o <= 4'h0;
      4'h2: o <= 4'h1;
      4'h3: o <= 4'h2;
      4'h4: o <= 4'h3;
      4'h5: o <= 4'h4;
      4'h6: o <= 4'h5;
      4'h7: o <= 4'h6;
      4'h8: o <= 4'h7;
      4'h9: o <= 4'h8;
      4'ha: o <= 4'h9;
      4'hb: o <= 4'ha;
      4'hc: o <= 4'hb;
      4'hd: o <= 4'hc;
      4'he: o <= 4'hd;
      default: o <= 4'he;
    endcase
endmodule
