/*******************************************************************************
 *
 * Copyright 2012, Sinclair R.F., Inc.
 *
 * Test bench for the UART_Tx peripheral.
 *
 ******************************************************************************/

`timescale 1ns/1ps

module tb;

// 7.3728 MHz clock
reg s_clk = 1'b1;
always @ (s_clk)
  s_clk <= #67.817 ~s_clk;

reg s_rst = 1'b1;
initial begin
  repeat (5) @ (posedge s_clk);
  s_rst = 1'b0;
end

wire [1:0] s_event;
wire       s_event_wr;
wire       s_done;
tb_timer #(
  .G_CLK_FREQ_HZ        (7_372_800),
  .G_BAUD               (115200)
)uut(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  .o_event      (s_event),
  .o_event_wr   (s_event_wr),
  .o_done       (s_done)
);

always @ (posedge s_clk)
  if (s_event_wr)
    $display("%12d : %d", $time, s_event);

always @ (posedge s_clk)
  if (s_done)
    $finish;

endmodule
