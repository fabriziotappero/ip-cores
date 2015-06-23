/*******************************************************************************
 *
 * Copyright 2014, Sinclair R.F., Inc.
 *
 * Test bench for the UART peripheral with CTS/CTSn and RTR/RTRn signals.
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
wire       s_uart1_cts;
wire       s_uart2;
wire       s_uart2_ctsn;
wire       s_uart3;
wire       s_uart3_ctsn;
wire [7:0] s_data;
wire       s_data_wr;
wire       s_done;
tb_UART_CTS_RTR uut(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  // UART1
  .o_uart1_tx   (s_uart1),
  .i_uart1_cts  (s_uart1_cts),
  // UART2
  .i_uart2_rx   (s_uart1),
  .o_uart2_tx   (s_uart2),
  .o_uart2_rtr  (s_uart1_cts),
  .i_uart2_ctsn (s_uart2_ctsn),
  // UART3
  .i_uart3_rx   (s_uart2),
  .o_uart3_tx   (s_uart3),
  .o_uart3_rtrn (s_uart2_ctsn),
  .i_uart3_ctsn (s_uart3_ctsn),
  // UART4
  .i_uart4_rx   (s_uart3),
  .o_uart4_rtrn (s_uart3_ctsn),
  // output data
  .o_data       (s_data),
  .o_data_wr    (s_data_wr),
  // program termination
  .o_done       (s_done)
);

always @ (posedge s_clk)
  if (s_data_wr)
    $display("%12d : %c", $time, s_data);

always @ (posedge s_clk)
  if (s_done)
    $finish;

//initial begin
//  $dumpfile("tb.vcd");
//  $dumpvars();
//end

endmodule
