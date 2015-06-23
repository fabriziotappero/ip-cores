`timescale 1us/1ns

/* Flull blown BCD adder -- takes number + sign bit and returns result in same format
Note the number is always a positive representation
so that 1001 is -1

Also note that BCD and hex are exactly the same except for legal digits
do 13'h1001 is actually BCD -1 */

module bcdadd(input [16:0] a, input [12:0] b, output [16:0] z);
  wire [16:0] ain;
  wire [12:0] bin;
  wire [16:0] zout;
  wire [16:0] ztemp;
  // The bcdneg modules return either a positive # or a 9's compliment #
  bcdneg17 aneg(a,ain);
  bcdneg13 bneg(b,bin);
  // Add the converted numbers
  usum adder(ain,bin,zout);
  // the bcdneg module is reversible so if we feed it 9's compliment we get
  // our format back out
  bcdneg17 zneg(zout,ztemp);
  // sometimes you get -0 and we don't want that so filter it here
  assign z=(ztemp==17'h10000)?(17'h00000):ztemp;
endmodule