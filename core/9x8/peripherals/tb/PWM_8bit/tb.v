/*******************************************************************************
 *
 * Copyright 2012, Sinclair R.F., Inc.
 *
 * Test bench for the PWM_8bit peripheral.
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

wire            s_pwm_sr;
wire            s_pwm_sn;
wire            s_pwm_si;
wire      [2:0] s_pwm_multi;
wire            s_done;
tb_PWM_8bit #(
  .G_CLK_FREQ_HZ        (100_000_000)
)uut(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  .o_pwm_sr     (s_pwm_sr),
  .o_pwm_sn     (s_pwm_sn),
  .o_pwm_si     (s_pwm_si),
  .o_pwm_multi  (s_pwm_multi),
  .o_done       (s_done)
);

always @ (s_pwm_sr, s_pwm_sn, s_pwm_si, s_pwm_multi)
  $display("%12d : %b %b %b %3b", $time, s_pwm_sr, s_pwm_sn, s_pwm_si, s_pwm_multi);

always @ (posedge s_clk)
  if (s_done)
    $finish;

endmodule
