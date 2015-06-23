/*******************************************************************************
 *
 * Copyright 2013, Sinclair R.F., Inc.
 *
 * Test bench for outFIFO_async peripheral.
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

// 250 MHz data readout clock
reg s_fast_clk = 1'b1;
always @ (s_fast_clk)
  s_fast_clk <= #2 ~s_fast_clk;

// enable the data readout after a delay
reg s_readout_en = 1'b0;
initial begin
  repeat(25*40) @ (posedge s_fast_clk);
  s_readout_en <= 1'b1;
end

//
// Instantiate the processor.
//

wire      [7:0] s_diag;
wire            s_empty;
wire            s_done;

wire            s_diag_rd = ~s_empty && s_readout_en;
reg             s_empty_clk = 1'b0;

tb_outFIFO_async uut(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  // asynchronous output FIFO
  .i_aclk       (s_fast_clk),
  .o_data       (s_diag),
  .i_data_rd    (s_diag_rd),
  .o_data_empty (s_empty),
  // feed-back empty condition
  .i_empty      (s_empty_clk),
  // termination signal
  .o_done       (s_done)
);

always @ (posedge s_clk)
  s_empty_clk <= s_empty;

// validation output
always @ (posedge s_fast_clk)
  if (s_diag_rd)
    $display("%12d : %h", $time, s_diag);

// termination signal
always @ (posedge s_clk)
  if (s_done)
    $finish;

endmodule
