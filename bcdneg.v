`timescale 1ns / 1ps
/* Find 9's compliment number 17 and 13 bit versions */
/* These pass positive numbers unchanged but convert negative ones or
   if you pass in a 9's compliment # you get the vtach format number
	back */

module bcdneg17(
    input [16:0] x,
    output [16:0] y
    );
 wire [15:0] yn;
 assign y[16]=x[16];
 bcdincr negplus({4'h9-x[15:12], 4'h9-x[11:8], 4'h9-x[7:4], 4'h9-x[3:0]},yn);
 assign y[15:0]=(x[16])?yn:x[15:0];
endmodule


module bcdneg13(input [12:0] x, output [12:0] y);
 wire [11:0] yn;
 assign y[12]=x[12];
 bcdincr negplus({ 4'h9-x[11:8], 4'h9-x[7:4], 4'h9-x[3:0]}, yn);
 assign y[11:0]=(x[12])?yn:x[11:0];
endmodule