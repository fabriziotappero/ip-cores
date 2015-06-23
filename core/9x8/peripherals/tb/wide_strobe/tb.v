/*******************************************************************************
 *
 * Copyright 2013, Sinclair R.F., Inc.
 *
 * Test bench for big_outport peripheral.
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

wire            s_min;
wire      [3:0] s_med;
wire      [7:0] s_max;
wire            s_done;
tb_wide_strobe uut(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  // narrow strobe bus
  .o_min        (s_min),
  // medium-width strobe bus
  .o_med        (s_med),
  // maximum-width strobe bus
  .o_max        (s_max),
  // termination signal
  .o_done       (s_done)
);

always @ (posedge s_clk) begin
  if ( s_min) $display("%12d : %d", $time, s_min);
  if (|s_med) $display("%12d : %h", $time, s_med);
  if (|s_max) $display("%12d : %h", $time, s_max);
end

always @ (posedge s_clk)
  if (s_done)
    $finish;

endmodule
