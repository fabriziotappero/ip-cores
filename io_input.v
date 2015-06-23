`timescale 1us/1ns
// This input module reads from the input switches
// This isn't of great use since
// we only have 8 input switches you can't
// enter negative #s or #s >99
// However, you could work out software to read
// everything (e.g., PB2 is negative,
// PB1 is enter 3rd  digit, PB0 is
// enter 1st digit and go
// Or something like that if you wanted to

module io_input(input clk, input oe, inout [12:0] value, input rst, input [7:0] sw);
   reg [12:0] v;
// Only drive output when asked
   assign value=oe?v:13'bz;
   
	// set v to next input value based on addr
   always @(posedge clk)
     begin
		v<={ 6'b0, sw };
     end

   
endmodule