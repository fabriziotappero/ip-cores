/*******************************************************************************
 *
 * Copyright 2012, Sinclair R.F., Inc.
 *
 * Test bench for the adder_16bit peripheral.
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

wire [7:0] s_v_out;
wire       s_v_wr;
wire       s_done;
tb_adder_16bit uut(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  .o_v_out      (s_v_out),
  .o_v_wr       (s_v_wr),
  .o_done       (s_done)
);

always @ (posedge s_clk)
  if (s_v_wr)
    $display("%12d : %h", $time, s_v_out);

always @ (posedge s_clk)
  if (s_done)
    $finish;

endmodule
