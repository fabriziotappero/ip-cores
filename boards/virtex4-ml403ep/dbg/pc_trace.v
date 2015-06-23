`timescale 1ns/10ps
`include "defines.v"

module pc_trace (
`ifdef DEBUG
    output reg [ 2:0] old_zet_st,
    output reg [19:0] dat,
    output reg        new_pc,
    output reg        st,
    output reg        stb,
    output            ack,
    output     [ 4:0] pack,
    output            addr_st,
`endif
    // PAD signals
    output trx_,

    input         clk,
    input         rst,
    input  [19:0] pc,
    input  [ 2:0] zet_st,
    output reg    block
  );

`ifndef DEBUG
  // Registers and nets
  reg [19:0] dat;
  reg [ 2:0] old_zet_st;
  reg        new_pc;
  reg        st;
  reg        stb;
  wire       ack;
`endif
  wire       op_st;
  wire       rom;

  // Module instantiations
  send_addr ser0 (
`ifdef DEBUG
    .pack (pack),
    .st   (addr_st),
`endif
    .trx_     (trx_),
    .wb_clk_i (clk),
    .wb_rst_i (rst),
    .wb_dat_i (dat),
    .wb_we_i  (stb),
    .wb_stb_i (stb),
    .wb_cyc_i (stb),
    .wb_ack_o (ack)
  );

  // Continous assignments
  assign op_st = (zet_st == 3'b0);
  assign rom   = pc[19:16]==4'hf || pc[19:16]==4'hc;

  // Behaviour
  // old_zet_st
  always @(posedge clk)
    old_zet_st <= rst ? 3'b0 : zet_st;

  // new_pc
  always @(posedge clk)
    new_pc <= rst ? 1'b0
      : (op_st ? (zet_st!=old_zet_st && !rom) : 1'b0);

  // block
  always @(posedge clk)
    block <= rst ? 1'b0
      : (new_pc ? (st & !ack) : (ack ? 1'b0 : block));

  // dat
  always @(posedge clk)
    dat <= rst ? 20'h0
         : ((new_pc & !st) ? pc : (ack ? pc : dat));

  // stb
  always @(posedge clk)
    stb <= rst ? 1'b0 : (ack ? 1'b0 : (st | new_pc));

  // st
  always @(posedge clk)
    st <= rst ? 1'b0
      : (st ? (ack ? (new_pc | block) : 1'b1) : new_pc);
endmodule
