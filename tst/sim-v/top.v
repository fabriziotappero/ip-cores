//
// top.v -- top-level module to test lfsr128 with LogicProbe
//

`include "lfsr128.v"
`timescale 1ns/1ns

module top;

  reg clk;
  reg reset_in_n;
  wire [3:0] s;
  wire rs232_txd;

  lfsr128 lfsr(clk, reset_in_n, s, rs232_txd);

  initial begin
    #0     $dumpfile("dump.vcd");
           $dumpvars(0, top);
           clk = 1;
           reset_in_n = 0;
    #145   reset_in_n = 1;
    #20000 $finish;
  end

  always begin
    #10 clk = ~clk;
  end

endmodule
