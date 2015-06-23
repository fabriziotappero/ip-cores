///////////////////////////////////////////////////////////////////////////////////////////////////
//
// File: random_pulse_generator.v
// File history:
//      Version 1: 2015-03-24: Created
//
// Description: 
//
// Poisson process generator. 
// Generate Poisson process with desired inversed rate (number of clocks per hit).
// The rate is defined by parameter LN2_PERIOD. For example, the LN2_PERIOD=4 will generate 
// in average one pulse per 16 clocks.
// 
// Author: Andrey Sukhanov
//
/////////////////////////////////////////////////////////////////////////////////////////////////// 
`timescale 1ns/1ps

//''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
module pseudo_random(input  clk, ce, rst, output reg [31:0] q);
// 32-bit uniform pseudo-random number generator, based on fibonacci LFSR
// Other 32-bit uniform random generators can be used as well.

wire feedback = q[31]^q[29]^q[28]^ q[27]^ q[23]^q[20]^ q[19]^q[17]^ q[15]^q[14]^q[12]^ q[11]^q[9]^ q[4]^ q[3]^q[2];
//feedback term B89ADA1C, other terms can be found from this table
// http://www.ece.cmu.edu/~koopman/lfsr/index.html

always @(posedge clk or posedge rst)
  if (rst) 
    q <= 32'haaaaaaaa;   // the start is more random with this initialization
  else if (ce)
    q <= {q[30:0], feedback} ;
endmodule
//,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
//''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
module random_pulse_generator( input clk, ce, rst, output reg q);

parameter LN2_PERIOD = 4; // 1 < LN2_PERIOD < 31
// log2 of the inversed process rate , 

parameter MASK = {LN2_PERIOD{1'b0}}; // any number with LN2_PERIOD bits can be used as a MASK
wire [31:0] uniform_random;
wire [LN2_PERIOD-1:0] sample;
pseudo_random pseudo_random_gen(clk, ce, rst, uniform_random);

assign sample = uniform_random[LN2_PERIOD-1:0]; // any subset of LN2_PERIOD bits can be used as a sample
always @ (posedge clk)
    if(ce) begin
        if (sample == MASK) q <= 1'b1;
        if (q) q <= 1'b0;
    end
endmodule
//,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
