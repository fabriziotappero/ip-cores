/*******************************************************************************
 *
 * Copyright 2013, Sinclair R.F., Inc.
 *
 * Test bench for counter peripheral.
 *
 ******************************************************************************/

`timescale 1ns/1ps

module tb;

// 100 MHz clock
reg s_clk = 1'b1;
always @ (s_clk)
  s_clk <= #5 ~s_clk;

reg s_rst = 1'b1;
initial begin
  repeat (5) @ (posedge s_clk);
  s_rst = 1'b0;
end

reg [15:0] s_count = 16'd0;
always @ (posedge s_clk)
  s_count <= s_count + 16'd1;

wire [15:0] s_count_gray = { 1'b0, s_count[1+:15] } ^ s_count;

integer i_n_ones, ix;
always @ (s_count_gray) begin
  i_n_ones = 0;
  for (ix=0; ix<16; ix=ix+1)
    if (s_count_gray[ix])
      i_n_ones = i_n_ones + 1;
end

reg s_strobe = 1'b0;
always @ (posedge s_clk)
  s_strobe <= (5 <= i_n_ones) && (i_n_ones <= 7);

reg [15:0] s_strobe_count = 16'd0;
always @ (posedge s_clk)
  if (s_strobe)
    s_strobe_count <= s_strobe_count + 1'd1;

wire     [15:0] s_diag;
wire            s_diag_wr;
wire            s_done;
tb_counter uut(
  // synchronous reset and processor clock
  .i_rst                (s_rst),
  .i_clk                (s_clk),
  // narrow counter
  .i_strobe_narrow      (s_strobe),
  // wide counter
  .i_strobe_wide        (s_strobe),
  // diagnostic output
  .o_diag_msb           (s_diag[8+:8]),
  .o_diag_lsb           (s_diag[0+:8]),
  .o_diag_wr            (s_diag_wr),
  // termination signal
  .o_done               (s_done)
);

always @ (posedge s_clk) begin
  if (s_diag_wr)
    $display("0x%04H 0x%04H", s_strobe_count, s_diag);
end

always @ (posedge s_clk)
  if (s_done)
    $finish;

endmodule
