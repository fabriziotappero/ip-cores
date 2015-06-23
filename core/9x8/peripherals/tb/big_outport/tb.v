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

wire     [25:0] s_vb;
wire            s_wr_26bit;
wire            s_wr_18bit;
wire      [8:0] s_min;
wire            s_wr_9bit;
wire            s_done;
tb_big_outport uut(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  // very big outport signal
  .o_vb         (s_vb),
  .o_wr_26bit   (s_wr_26bit),
  .o_wr_18bit   (s_wr_18bit),
  // minimal composite signal
  .o_min        (s_min),
  .o_wr_9bit    (s_wr_9bit),
  // termination signal
  .o_done       (s_done)
);

always @ (posedge s_clk) begin
  if (s_wr_26bit)
    $display("26-bit:  0x%08H", s_vb[0+:26]);
  if (s_wr_18bit)
    $display("18-bit:  0x%06H", s_vb[0+:18]);
  if (s_wr_9bit)
    $display(" 9-bit:  0x%03H", s_min);
end

always @ (posedge s_clk)
  if (s_done)
    $finish;

endmodule
