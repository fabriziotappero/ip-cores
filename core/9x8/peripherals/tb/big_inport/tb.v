/*******************************************************************************
 *
 * Copyright 2013, Sinclair R.F., Inc.
 *
 * Test bench for big_inport peripheral.
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

wire     [25:0] s_vb            = 26'h1234567;
wire      [8:0] s_min           =  9'h19A;
wire      [7:0] s_diag;
wire            s_diag_wr;
wire            s_done;
tb_big_inport uut(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  // very big inport signal
  .i_vb         (s_vb),
  // minimal big inport signal
  .i_min        (s_min),
  // diagnostic echo of received value
  .o_diag       (s_diag),
  .o_diag_wr    (s_diag_wr),
  // termination signal
  .o_done       (s_done)
);

always @ (posedge s_clk)
  if (s_diag_wr)
    $display("%12d : %h", $time, s_diag);

always @ (posedge s_clk)
  if (s_done)
    $finish;

endmodule
