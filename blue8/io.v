/*
    This file is part of Blue8.

    These modules are from Ed Doering


*/

`timescale 1ns / 1ps
module DisplayHex (
// Digit display interface for Digilent DIO1, DIO4 and Spartan-3 boards
//
// - Accepts two 8-bit values on input, and displays the hexadecimal
//     representation of each value on the four-digit seven-segment display
// - Uses multiplexed display scheme with 100 Hz refresh to minimize flicker.
// - Requires 50MHz master clock
// - Requires active-high master reset (all segments active on reset)
//
// Instantiation template:
/*
DigitDisplay instancename (
	// System connections
    .gClock(  ), 
    .gReset(  ), 	 // Active high

    // Data inputs
    .iRight(  ),   // 8-bit value
    .iLeft(  ),    // 8-bit value

    // Direct connections to DIO1 or DIO4 board:
    // Segment selectors
    .oSegmentA(  ), 
    .oSegmentB(  ), 
    .oSegmentC(  ), 
    .oSegmentD(  ), 
    .oSegmentE(  ), 
    .oSegmentF(  ), 
    .oSegmentG(  ), 
    .oSegmentDP(  ),
    
    // Digit selectors 
    .oDigitRight(  ), 
    .oDigitMiddleRight(  ), 
    .oDigitMiddleLeft(  ), 
    .oDigitLeft(  )
    );
	// Use 0 for DIO4 and Spartan-3 boards, 1 for DIO1 board (parameter defaults to 0 
	// when 'defparam' line is omitted).
*/
// End of instantiation template
//
// Author: Ed Doering
// Created: 21 Jan 2003
// Revised: 16 Mar 2004 (added parameter to choose digit select assertion level)
// 	16 Aug 2005 (updated for Spartan-3; updated signal names)

	// Global system resources:
	input gClock,	// System clock (50 MHz)
	input gReset,	// Master reset (active high)

	// Inputs:
	input [7:0] iRight,	// Value to display on right two digits
	input [7:0] iLeft,	// Value to display on left two digits
	input [3:0] indp,    // input decimal points

	// Outputs:
	output reg oSegmentA,	// LED segment a (active low)
	output reg oSegmentB,	// etc.
	output reg oSegmentC,
	output reg oSegmentD,
	output reg oSegmentE,
	output reg oSegmentF,
	output reg oSegmentG,
	output reg oSegmentDP,	// LED decimal point
	output reg oDigitRight,	// Rightmost digit enable (active high)
	output reg oDigitMiddleRight,	// etc.
	output reg oDigitMiddleLeft,
	output reg oDigitLeft
);

// User-adjustable constants
parameter pClockFrequency = 50;	// Clock frequency in MHz
parameter pRefreshFrequency = 100;	// Display refresh rate (for entire display) in Hz

// Upper limit for frequency divider counter
parameter pUpperLimit = (pClockFrequency * 1000000) / (4 * pRefreshFrequency);
//parameter pUpperLimit = 2; // for simulation only

// Number of bits for frequency divider counter (will accommodate 
// refresh frequencies down to 1 Hz)
parameter pDividerCounterBits = 24;


// Registered identifiers:
reg [pDividerCounterBits-1:0] rCycles;
reg [1:0] rDigitSelect;
reg [7:0] rNybble;
reg [3:0] rDigit;
reg wDecimalPoint;
reg [6:0] rCharacter;

// Frequency divider and 2-bit counter for digit selector
always @ (posedge gClock or posedge gReset)
	if (gReset) begin
		rCycles <= 0;
		rDigitSelect <= 3;
	end
	else
		if (rCycles == pUpperLimit)	begin
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
always @ (rDigitSelect or iRight or iLeft or indp)
	case (rDigitSelect)
		2'b00 : begin rNybble <= iRight[3:0]; wDecimalPoint <= indp[0]; end
		2'b01 : begin rNybble <= iRight[7:4]; wDecimalPoint <= indp[1]; end
		2'b10 : begin rNybble <= iLeft[3:0]; wDecimalPoint <= indp[2]; end
		2'b11 : begin rNybble <= iLeft[7:4]; wDecimalPoint <= indp[3]; end
	endcase

// Convert 4-bit value to character
always @ (rNybble)
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
always @ (posedge gClock or posedge gReset)
	if (gReset) begin
		oSegmentA <= 0;
		oSegmentB <= 0;
		oSegmentC <= 0;
		oSegmentD <= 0;
		oSegmentE <= 0;
		oSegmentF <= 0;
		oSegmentG <= 0;
		oSegmentDP <= 0;
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
		oSegmentDP <= wDecimalPoint;
		oDigitRight <= rDigit[0];
		oDigitMiddleRight <= rDigit[1];
		oDigitMiddleLeft <= rDigit[2];
		oDigitLeft <= rDigit[3];
	end

endmodule

//-----------------------------------------------------------------------------

module Debouncer (
// Switch debouncer for Digilent FPGA boards
//
// Requires a 50MHz clock, and implements a 10ms wait period.
// Includes glitch suppression. Built-in synchronizer.
// Outputs include a debounced replica of the input signal, and
// single clock period pulse outputs to indicate rising edge and
// falling edge detected (of clean signal).
//
// 10ms at 50MHz is 500,000 master clock cycles, requiring 19 bits
// of register space.

	// Global system resources:
	input gClock,	// System clock (must be 50 MHz)
	input gReset,	// Master reset (asynchronous, active high)

	// Inputs:
	input iBouncy,	// Bouncy switch signal

	// Outputs:
	output reg oDebounced,	// Debounced replica of switch signal
	output reg oPulseOnRisingEdge,	// Single pulse to indicate rising edge detected
	output reg oPulseOnFallingEdge	// Single pulse to indicate falling edge detected
);

// Constant parameters
parameter pInitialValue = 0;
parameter pTimerWidth = 19;
parameter pInitialTimerValue = 19'd500_000; // for synthesis
//parameter pInitialTimerValue = 19'd2; // for simulation

// Registered identifiers:
reg	rInitializeTimer;
reg	rWaitForTimer;
reg	rSaveInput;
reg	rBouncy_Syncd;
reg	[pTimerWidth-1:0] rTimer;

// Wire identifiers:
wire	wTransitionDetected;
wire	wTimerFinished;

// Controller:
always @ (posedge gClock or posedge gReset)
	if (gReset)
		{rInitializeTimer,rWaitForTimer,rSaveInput} <= {3'b100};
	else begin
		rInitializeTimer <= rInitializeTimer && !wTransitionDetected ||
							rSaveInput;
		rWaitForTimer <= rInitializeTimer && wTransitionDetected ||
							rWaitForTimer && !wTimerFinished;
		rSaveInput <= rWaitForTimer && wTimerFinished;
	end		

// Datapath:
always @ (posedge gClock or posedge gReset)
	if (gReset) begin
		rBouncy_Syncd <= 0;
		oDebounced <= pInitialValue;
		oPulseOnRisingEdge <= 0;
		oPulseOnFallingEdge <= 0;
		rTimer <= pInitialTimerValue;
	end
	else begin
		rBouncy_Syncd <= iBouncy;
		oDebounced <= (rSaveInput) ? rBouncy_Syncd : oDebounced;
		oPulseOnRisingEdge <= (rSaveInput && rBouncy_Syncd);
		oPulseOnFallingEdge <= (rSaveInput && !rBouncy_Syncd);
		rTimer <= (rInitializeTimer) ? pInitialTimerValue : rTimer - 1;
	end

assign wTransitionDetected = rBouncy_Syncd ^ oDebounced;
assign wTimerFinished = (rTimer == 0);

endmodule