`timescale 1ns / 1ps
// Debounce switch inputs
module debounce (
	// Global system resources:
	input clk,	// System clock (must be 50 MHz)
	input rst,	// Master reset (asynchronous, active high)

	// Inputs:
	input rawinput,	// Bouncy switch signal

	// Outputs:
	output reg btnout	// Debounced replica of switch signal
);

// Constant parameters
parameter initval = 0;  // default button state
parameter timerwidth = 19;
parameter inittimer = 19'd100_000; // for synthesis
//parameter inittimer = 19'd2; // for simulation

// Registered identifiers:
reg	rInitializeTimer;
reg	rWaitForTimer;
reg	rSaveInput;
reg	rBouncy_Syncd;
reg	[timerwidth-1:0] rTimer;

// Wire identifiers:
wire	wTransitionDetected;
wire	wTimerFinished;

// Controller:
always @ (posedge clk or posedge rst)
	if (rst)
		{rInitializeTimer,rWaitForTimer,rSaveInput} <= {3'b100};
	else begin
		rInitializeTimer <= rInitializeTimer && !wTransitionDetected ||
							rSaveInput;
		rWaitForTimer <= rInitializeTimer && wTransitionDetected ||
							rWaitForTimer && !wTimerFinished;
		rSaveInput <= rWaitForTimer && wTimerFinished;
	end		

// Datapath:
always @ (posedge clk or posedge rst)
	if (rst) begin
		rBouncy_Syncd <= 0;
		btnout <= initval;
		rTimer <= inittimer;
	end
	else begin
		rBouncy_Syncd <= rawinput;
		btnout <= (rSaveInput) ? rBouncy_Syncd : btnout;
		rTimer <= (rInitializeTimer) ? inittimer : rTimer - 1;
	end

assign wTransitionDetected = rBouncy_Syncd ^ btnout;
assign wTimerFinished = (rTimer == 0);

endmodule
