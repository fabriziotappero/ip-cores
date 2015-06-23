/*******************************************************************************
 *
 * Copyright 2012, Sinclair R.F., Inc.
 *
 * Test bench for the latch peripheral.
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

reg [23:0] s_value = 24'h8735;
always @ (posedge s_clk)
  if (s_rst)
    s_value <= 24'h8735;
  else
    s_value <= { s_value[0+:23], ^{ s_value[15], s_value[13], s_value[12], s_value[10]} };

wire [7:0] s_test;
wire       s_test_wr;
wire       s_done;
tb_latch uut(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  .i_9value     (s_value[0+:9]),
  .i_24value    (s_value[0+:24]),
  .o_test       (s_test),
  .o_test_wr    (s_test_wr),
  .o_done       (s_done)
);

always @ (posedge s_clk)
  if (s_test_wr)
    $display("%12d : %x", $time, s_test);

always @ (posedge s_clk)
  if (s_done)
    $finish;

endmodule
