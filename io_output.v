`timescale 1us/1ns

// Output module just sets the board's displays
module io_output(input clk, input oe, input [12:0] value, input reset, 
	output segA, output segB, output segC, output segD, output segE, output segF, output segG,
	output ds0, output ds1, output ds2, output ds3);

   wire [12:0] v;
	reg [12:0] val;
	// this does most of the real work
	DisplayHex leds(clk,reset,val,segA, segB, segC, segD, segE, segF, segG, ds0, ds1, ds2, ds3);
// convert all x's to 0's
// if you read uninit memory it shows up as x's in simulation
   assign v=((value===13'bxxxxxxxxxxxxx)?13'b0:value);
// digits
   always @(posedge clk)
     if (oe)
		 val<=v;
endmodule // io_output

	  