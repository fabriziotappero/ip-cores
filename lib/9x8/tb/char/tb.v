/*******************************************************************************
 *
 * Copyright 2013, Sinclair R.F., Inc.
 *
 * Test bench for the core/9x8 libraries.
 *
 ******************************************************************************/

`timescale 1ns/1ps

module tb;

reg s_clk = 1'b1;
always @ (s_clk)
  s_clk <= #5 ~s_clk;

reg s_rst = 1'b1;
initial begin
  repeat (5) @ (posedge s_clk)
  s_rst <= 1'b0;
end

wire [7:0] s_value;
wire       s_value_wr;
wire       s_terminate_str;
uc inst_uc(
  // synchronous reset and processor clock
  .i_rst                (s_rst),
  .i_clk                (s_clk),
  // 8-bit test values
  .o_value              (s_value),
  .o_value_wr           (s_value_wr),
  // termination strobe
  .o_terminate_str      (s_terminate_str)
);

always @ (posedge s_value_wr)
  $display("%02h", s_value);

always @ (posedge s_terminate_str)
  $finish;

endmodule
