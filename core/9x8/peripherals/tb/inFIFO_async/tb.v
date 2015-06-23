/*******************************************************************************
 *
 * Copyright 2013, Sinclair R.F., Inc.
 *
 * Test bench for inFIFO_async peripheral.
 *
 ******************************************************************************/

`timescale 1ns/1ps

module tb;

// 100 MHz processor clock
reg s_clk = 1'b1;
always @ (s_clk)
  s_clk <= #5 ~s_clk;

// synchronous processor reset
reg s_rst = 1'b1;
initial begin
  repeat (5) @ (posedge s_clk);
  s_rst = 1'b0;
end

// 250 MHz data source clock
reg s_fast_clk = 1'b1;
always @ (s_fast_clk)
  s_fast_clk <= #2 ~s_fast_clk;

// Write data to the micro controller at varying rates.
reg [7:0] s_v  = 8'd0;
reg       s_wr = 1'b0;
wire      s_full;
initial begin
  @ (negedge s_rst);
  repeat(20)
    @ (posedge s_fast_clk);
  // write 5 values in quick succession
  s_wr <= 1'b1;
  repeat(5) begin
    @ (posedge s_fast_clk);
    s_v <= s_v + 8'd1;
  end
  s_wr <= 1'b0;
  // write 5 values once every 13*2.5+? = 100 clock cycles (this is
  // substantially slower than the micro controller can read the data).
  repeat (5) begin
    repeat(99)
      @ (posedge s_fast_clk);
    s_wr <= 1'b1;
    @ (posedge s_fast_clk);
    s_v <= s_v + 8'd1;
    s_wr <= 1'b0;
  end
  // write to the FIFO whenever it isn't full
  forever begin
    s_wr <= ~s_full;
    @ (posedge s_fast_clk);
    if (s_wr)
      s_v <= s_v + 8'd1;
  end
end

wire      [7:0] s_diag;
wire            s_diag_wr;
wire            s_done;
tb_inFIFO_async uut(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  // asynchronous input FIFO
  .i_aclk       (s_fast_clk),
  .i_data       (s_v),
  .i_data_wr    (s_wr),
  .o_data_full  (s_full),
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
