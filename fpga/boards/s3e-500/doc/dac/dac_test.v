//
// dac_test.v -- test bench for DAC control circuit
//

`include "dac.v"

`timescale 1ns/1ns

module dac_test;

  reg clk;                        // system clock (50 MHz)
  reg reset_in;                   // reset, input
  reg reset_s1;                   // reset, first synchronizer
  reg reset;                      // reset, second synchronizer
  reg [15:0] sample_l;
  reg [15:0] sample_r;
  wire next;
  wire sck;
  wire sdi;
  wire ld;

  // instantiate the controller
  dac dac_1(clk, reset,
            sample_l, sample_r, next,
            sck, sdi, ld);

  // simulation control
  initial begin
    #0     $dumpfile("dump.vcd");
           $dumpvars(0, dac_test);
           sample_l = 16'h0FF0;
           sample_r = 16'hAA55;
           clk = 1;
           reset_in = 1;
    #145   reset_in = 0;
    #90000 $finish;
  end

  // clock generator
  always begin
    #10 clk = ~clk;               // 20 nsec cycle time
  end

  // reset synchronizer
  always @(posedge clk) begin
    reset_s1 <= reset_in;
    reset <= reset_s1;
  end

endmodule
