`timescale 1ns / 1ps

// by Jason Stewart
// http://www.cs.unc.edu/~stewart/comp290-ghw/vga.html

//********************************************************
// Filename:  counter_tc.v
//
// Parameterized counter module with sync reset 
// and terminal count.
//********************************************************
module counter_tc(clk, reset, q, tc);
  parameter N = 8;       // number of bits
  parameter TCNT = 256;  // desired terminal count

  input  clk, reset;
  output tc;
  reg    tc;
  output [N-1:0] q;
  reg    [N-1:0] q;

  // check for one less than what you want ...
  wire tc_tmp;
  assign tc_tmp = (q==TCNT-2);

  // ... then register (causes 1-cycle delay)
  always @(posedge clk)
    if (reset) tc <= 0;
    else tc <= tc_tmp;

  // counter
  always @(posedge clk)
    if (reset) q <= 0;
    else
      begin
        if (tc) q <= 0;
        else q <= q + 1;
      end
endmodule

//********************************************************
// Filename:  counter_tc_ce.v
//
// Parameterized counter module with sync reset, 
// clock enable, and terminal count.
//********************************************************
module counter_tc_ce(clk, reset, enable, q, tc);
  parameter N = 8;       // number of bits
  parameter TCNT = 256;  // desired terminal count

  input  clk, reset, enable;
  output tc;
  reg    tc;
  output [N-1:0] q;
  reg    [N-1:0] q;

  // check for one less than what you want ...
  wire tc_tmp;
  assign tc_tmp = (q==TCNT-2);

  // ... then register (causes 1-cycle delay)
  always @(posedge clk)
    if (reset) tc <= 0;
    else tc <= tc_tmp;

  // counter
  always @(posedge clk)
    if (reset) q <= 0;
    else if (enable)
      begin
        if (tc) q <= 0;
        else q <= q + 1;
      end
endmodule

//********************************************************
// Filename:  pulse_gen.v
//
// Parameterized pulse_gen module with sync reset. 
// The output is registered.
//
// Basically, just a comparator that outputs a one 
// when the count falls between two values and a 
// zero otherwise. START + LENGTH should fall within 
// the counter range (plus one). That is, this module 
// doesn't deal with counter rollover.
//********************************************************
module pulse_gen(clk,reset,count,pulse);
  parameter N = 8;      // number of counter bits
  parameter START = 0;  // start count
  parameter LENGTH = 1; // pulse length (number of cycles)

  input clk, reset;
  input [N-1:0] count;
  output pulse;
  reg pulse;

  always @(posedge clk)
    if (reset) pulse <= 0;
    else
      begin
        if ((count>=START)&&(count<START+LENGTH)) pulse <= 1;
        else pulse <= 0;
      end
endmodule

//********************************************************
// Filename:  pulse_high_low.v
//
// Outputs a 1-cycle pulse when din transitions from 
// high to low. Sync reset. Output is registered.
//********************************************************
module pulse_high_low(clk,reset,din,pulse);
  input clk, reset, din;
  output pulse;
  reg pulse;
  reg din_reg;

  // 1-cycle delay reg
  always @(posedge clk)
    if (reset) din_reg <= 0;
    else din_reg <= din;

  // check for old value high, current value low
  always @(posedge clk)
    if (reset) pulse <= 0;
    else
      begin
        if (~din && din_reg) pulse <= 1;
        else pulse <= 0;
      end
endmodule
