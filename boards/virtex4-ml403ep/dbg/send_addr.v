`timescale 1ns/10ps
`include "defines.v"

module send_addr (
`ifdef DEBUG
    output reg [ 4:0] pack,
    output reg        st,
`endif
    // Serial pad signal
    output       trx_,

    // Wishbone slave interface
    input        wb_clk_i,
    input        wb_rst_i,
    input [19:0] wb_dat_i,
    input        wb_we_i,
    input        wb_stb_i,
    input        wb_cyc_i,
    output       wb_ack_o
  );

  // Registers and nets
`ifndef DEBUG
  reg  [4:0] pack;
  reg        st;
`endif
  wire       op;
  wire       start;
  wire       sack;
  wire [7:0] dat;
  wire [7:0] b0, b1, b2, b3, b4;

  // Module instantiation
  send_serial ss0 (
    .trx_ (trx_),

    .wb_clk_i (wb_clk_i),
    .wb_rst_i (wb_rst_i),
    .wb_dat_i (dat),
    .wb_we_i  (wb_we_i),
    .wb_stb_i (wb_stb_i),
    .wb_cyc_i (wb_cyc_i),
    .wb_ack_o (sack)
  );

  // Continuous assignments
  assign op       = wb_we_i & wb_stb_i & wb_cyc_i;
  assign start    = !st & op;
  assign wb_ack_o = st & sack & pack[4];

  assign dat = st & pack[0] ?
          (pack[1] ? (pack[2] ? (pack[3] ? (pack[4] ? 8'h0a : b0)
         : b1) : b2) : b3) : b4;

  assign b0 = { 1'b0, ascii(wb_dat_i[ 3: 0]) };
  assign b1 = { 1'b0, ascii(wb_dat_i[ 7: 4]) };
  assign b2 = { 1'b0, ascii(wb_dat_i[11: 8]) };
  assign b3 = { 1'b0, ascii(wb_dat_i[15:12]) };
  assign b4 = { 1'b0, ascii(wb_dat_i[19:16]) };

  // Behaviour
  // pack
  always @(posedge wb_clk_i)
    pack <= wb_rst_i ? 5'b0 : (start ? 5'b0
      : (st ? (sack ? { pack[3:0], 1'b1 } : pack) : 5'b0));

  // st
  always @(posedge wb_clk_i)
    st <= wb_rst_i ? 1'b0 : (st ? !wb_ack_o : op);

  function [6:0] ascii(input [3:0] num);
    if (num <= 4'd9) ascii = 7'h30 + num;
    else ascii = 7'd87 + num;
  endfunction
endmodule
