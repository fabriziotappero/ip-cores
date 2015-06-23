/*******************************************************************************
 *
 * Copyright 2014, Sinclair R.F., Inc.
 *
 * Test bench for the core/9x8 math library.
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

wire [95:0] s_value;
wire        s_value_done;
wire        s_terminate;
uc inst_uc(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  // 8-bit test values
  .o_value      (s_value),
  .o_value_done (s_value_done),
  // termination strobe
  .o_terminate  (s_terminate)
);

always @ (posedge s_value_done)
  $display("%08h + %08h = %08h", s_value[64+:32], s_value[32+:32], s_value[0+:32]);

always @ (posedge s_terminate)
  $finish;

initial begin
  $dumpfile("tb.vcd");
  $dumpvars();
end

endmodule
