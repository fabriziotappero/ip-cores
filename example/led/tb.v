/*******************************************************************************
 *
 * Copyright 2012, Sinclair R.F., Inc.
 *
 * Test bench for led.v.
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
  repeat(100) @ (posedge s_clk);
  $finish;
end

led uut(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  // outport ports
  .o_led        ()
);

initial begin
  $dumpfile("tb.vcd");
  $dumpvars();
end

endmodule
