/*******************************************************************************
 *
 * Copyright 2013, Sinclair R.F., Inc.
 *
 * Test bench for the UART peripheral.
 *
 ******************************************************************************/

`timescale 1ns/1ps

module tb;

// 10 MHz clock
reg s_clk = 1'b1;
always @ (s_clk)
  s_clk <= #50 ~s_clk;

reg s_rst = 1'b1;
initial begin
  repeat (5) @ (posedge s_clk);
  s_rst = 1'b0;
end

wire       s_uart1;
wire       s_uart2;
wire [7:0] s_data;
wire       s_data_wr;
wire       s_done;
tb_UART uut(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  // UART1
  .i_uart1_rx   (s_uart1),
  .o_uart1_tx   (s_uart1),
  // UART2
  .i_uart2_rx   (s_uart2),
  .o_uart2_tx   (s_uart2),
  // output data
  .o_data       (s_data),
  .o_data_wr    (s_data_wr),
  // program termination
  .o_done       (s_done)
);

always @ (posedge s_clk)
  if (s_data_wr)
    $display("%12d : %h", $time, s_data);

always @ (posedge s_clk)
  if (s_done)
    $finish;

endmodule
