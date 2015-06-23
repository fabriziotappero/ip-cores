/*******************************************************************************
 *
 * Copyright 2015, Sinclair R.F., Inc.
 *
 * Test bench for the servo_motor peripheral.
 *
 ******************************************************************************/

`timescale 1ns/1ps

module tb;

// 8 MHz clock
reg s_clk = 1'b1;
always @ (s_clk)
  s_clk <= #62.5 ~s_clk;

reg s_rst = 1'b1;
initial begin
  repeat (5) @ (posedge s_clk);
  s_rst = 1'b0;
end

wire    s_triple_0;
wire    s_triple_1;
wire    s_triple_2;
wire    s_done;
tb_servo_motor uut(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  // 3 linked servo motor
  .o_triple_0   (s_triple_0),
  .o_triple_1   (s_triple_1),
  .o_triple_2   (s_triple_2),
  // program termination
  .o_done       (s_done)
);

always @ (s_triple_0)
  $display("%12d : s_triple_0 %h", $time, s_triple_0);
always @ (s_triple_1)
  $display("%12d : s_triple_1 %h", $time, s_triple_1);
always @ (s_triple_2)
  $display("%12d : s_triple_2 %h", $time, s_triple_2);

always @ (posedge s_clk)
  if (s_done)
    $finish;

//initial begin
//  $dumpfile("tb.vcd");
//  $dumpvars();
//end

endmodule
