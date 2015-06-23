`timescale 1ns / 1ps
// Drive the 7 segment displays
// Note that it displays 3 digits + sign
// It is capable of displaying hex
// Even though anything >9 in a 4 bit nybble
// would be an error
module DisplayHex (


	// Global system resources:
	input clk,	// System clock 
	input rst,	// Master reset (active high)

	// Inputs:
	input [12:0] inval,
	
	// Outputs:
	output reg oSegmentA,	// LED segment a (active low)
	output reg oSegmentB,	// etc.
	output reg oSegmentC,
	output reg oSegmentD,
	output reg oSegmentE,
	output reg oSegmentF,
	output reg oSegmentG,
	output reg oDigitRight,	// Rightmost digit enable (active high)
	output reg oDigitMiddleRight,	// etc.
	output reg oDigitMiddleLeft,
	output reg oDigitLeft
);

// User-adjustable constants
parameter clkfreq = 16;	// Clock frequency in MHz
parameter dispfreq = 100;	// Display refresh rate (for entire display) in Hz

// Upper limit for frequency divider counter
parameter uplimit = (clkfreq * 1000000) / (4 * dispfreq);
//parameter pUpperLimit = 2; // for simulation only

// Number of bits for frequency divider counter 
parameter ctrbits = 24;


// Registered identifiers:
reg [ctrbits-1:0] rCycles;
reg [1:0] rDigitSelect;
reg [3:0] rNybble;
reg [3:0] rDigit;
reg [6:0] rCharacter;

// Frequency divider and 2-bit counter for digit selector
always @ (posedge clk or posedge rst)
	if (rst) begin
		rCycles <= 0;
		rDigitSelect <= 3;
	end
	else
		if (rCycles == uplimit)	begin
			rCycles <= 0;
			rDigitSelect <= rDigitSelect - 1;
		end
		else
			rCycles <= rCycles + 1;

// Decode the digit selector to four control lines
always @ (rDigitSelect)
		case (rDigitSelect)
			2'b00 : rDigit <= 4'b1110;
			2'b01 : rDigit <= 4'b1101;
			2'b10 : rDigit <= 4'b1011; 
			2'b11 : rDigit <= 4'b0111;
		endcase


// MUX the four 4-bit inputs to a single 4-bit value
always @ (rDigitSelect or inval )
	case (rDigitSelect)
		2'b00 :  rNybble <= inval[3:0]; 
		2'b01 :  rNybble <= inval[7:4]; 
		2'b10 :  rNybble <= inval[11:8]; 
		2'b11 :  rNybble <= { 3'b0, inval[12]};
	endcase

// Convert 4-bit value to character
always @ (rNybble or rDigitSelect)
	if (rDigitSelect==2'b11)   // see if it is time to do the sign
	   rCharacter <= rNybble?~(7'b0000001):~(7'b0000000);
	else
	case (rNybble)       //     abcdefg
		4'h0 : rCharacter <= ~(7'b1111110);
		4'h1 : rCharacter <= ~(7'b0110000);
		4'h2 : rCharacter <= ~(7'b1101101);
		4'h3 : rCharacter <= ~(7'b1111001);
		4'h4 : rCharacter <= ~(7'b0110011);
		4'h5 : rCharacter <= ~(7'b1011011);
		4'h6 : rCharacter <= ~(7'b1011111);
		4'h7 : rCharacter <= ~(7'b1110000);
		4'h8 : rCharacter <= ~(7'b1111111);
		4'h9 : rCharacter <= ~(7'b1111011);
		4'ha : rCharacter <= ~(7'b1110111);
		4'hb : rCharacter <= ~(7'b0011111);
		4'hc : rCharacter <= ~(7'b1001110);
		4'hd : rCharacter <= ~(7'b0111101);
		4'he : rCharacter <= ~(7'b1001111);
		4'hf : rCharacter <= ~(7'b1000111);
		default : rCharacter <= ~(7'b1001001);	
	endcase

// Create registered outputs (for glitch-free output)
always @ (posedge clk or posedge rst)
	if (rst) begin
		oSegmentA <= 0;
		oSegmentB <= 0;
		oSegmentC <= 0;
		oSegmentD <= 0;
		oSegmentE <= 0;
		oSegmentF <= 0;
		oSegmentG <= 0;
		oDigitRight <= 1'b1;
		oDigitMiddleRight <= 1'b1;
		oDigitMiddleLeft <= 1'b1;
		oDigitLeft <= 1'b1;
	end
	else begin
		oSegmentA <= rCharacter[6];
		oSegmentB <= rCharacter[5];
		oSegmentC <= rCharacter[4];
		oSegmentD <= rCharacter[3];
		oSegmentE <= rCharacter[2];
		oSegmentF <= rCharacter[1];
		oSegmentG <= rCharacter[0];
		oDigitRight <= rDigit[0];
		oDigitMiddleRight <= rDigit[1];
		oDigitMiddleLeft <= rDigit[2];
		oDigitLeft <= rDigit[3];
	end

endmodule
