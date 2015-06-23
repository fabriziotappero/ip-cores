/*******************************************************************************
 *
 * Copyright 2015, Sinclair R.F., Inc.
 *
 * Test bench for the stepper_motor peripheral.
 *
 ******************************************************************************/

`timescale 1ns/1ps

module tb;

// 2 MHz clock
reg s_clk = 1'b1;
always @ (s_clk)
  s_clk <= #250 ~s_clk;

reg s_rst = 1'b1;
initial begin
  repeat (5) @ (posedge s_clk);
  s_rst = 1'b0;
end

wire    s_stepper_dir;
wire    s_stepper_step;
wire    s_done;
tb_stepper_motor uut(
  // synchronous reset and processor clock
  .i_rst                (s_rst),
  .i_clk                (s_clk),
  // stepper motor controls
  .o_stepper_dir        (s_stepper_dir),
  .o_stepper_step       (s_stepper_step),
  .i_stepper_error      (1'b0),
  // program termination
  .o_done               (s_done)
);

always @ (posedge s_stepper_step)
  $display("%12d : dir = %h", $time, s_stepper_dir);

always @ (negedge s_clk)
  if (s_done)
    $finish;

//initial begin
//  $dumpfile("tb.vcd");
//  $dumpvars(1,tb);
//end

endmodule
