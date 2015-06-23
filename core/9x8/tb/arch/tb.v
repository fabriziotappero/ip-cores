/*******************************************************************************
 *
 * Copyright 2012, Sinclair R.F., Inc.
 *
 * Test bench for the various arch.v.
 *
 ******************************************************************************/

`timescale 1ns/1ps

module tb;

reg s_clk = 1'b1;
always @ (s_clk) s_clk <= #5 ~s_clk;

reg s_rst = 1'b1;
initial begin
  repeat (5) @ (posedge s_clk);
  s_rst <= 1'b0;
  @ (posedge s_done_strobe);
  repeat (6) @ (negedge s_clk);
  $finish;
end

wire s_done_strobe;
arch uut(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  // simulation completed strobe
  .o_done_strobe(s_done_strobe)
);

endmodule
