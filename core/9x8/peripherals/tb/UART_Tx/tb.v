/*******************************************************************************
 *
 * Copyright 2012, Sinclair R.F., Inc.
 *
 * Test bench for the UART_Tx peripheral.
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

wire s_uart1_tx;
wire s_uart2_tx;
wire s_uart3_tx;
wire s_done;
tb_UART_Tx #(
  .G_CLK_FREQ_HZ        (100_000_000),
  .G_BAUD               (115200)
)uut(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  .o_uart1_tx   (s_uart1_tx),
  .o_uart2_tx   (s_uart2_tx),
  .o_uart3_tx   (s_uart3_tx),
  .o_done       (s_done)
);

always @ (s_uart1_tx, s_uart2_tx, s_uart3_tx, s_done)
  $display("%12d : %b %b %b", $time, s_uart1_tx, s_uart2_tx, s_uart3_tx);

always @ (posedge s_clk)
  if (s_done)
    $finish;

endmodule
