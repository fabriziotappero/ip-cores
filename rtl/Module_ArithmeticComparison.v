`timescale 1ns / 1ps
`include "aDefinitions.v"

//------------------------------------------------------------------
module ArithmeticComparison
(
	input wire					Clock,
	input wire[`WIDTH-1:0] 	X,Y,
	input wire[2:0] 			iOperation,
	input wire					iInputReady,
	output reg 					OutputReady,
	output reg					Result
);


wire [`WIDTH-1:0] wX,wY;
wire SignX,SignY;
reg rGreaterThan;
wire wUGt,wULT,wEQ;

assign SignX = (X == 0) ? 0: X[31];
assign SignY = (Y == 0) ? 0: Y[31];

assign wX = ( SignX ) ? ~X + 1'b1 : X;
assign wY = ( SignY ) ? ~Y + 1'b1 : Y;

assign wUGt = wX > wY;
assign wULT = wX < wY;
assign wEQ = wX == wY;

always @ ( * )
begin
	case ( {SignX,SignY} )
		//Greater than test ( X > Y )
		2'b00: rGreaterThan = wUGt;		//both numbers positive
		2'b01: rGreaterThan = 1;			//X positive, y negative	
		2'b10: rGreaterThan = 0;			//X negative, y positive
		2'b11: rGreaterThan = wULT;		//X negative, y negative
	endcase
end

always @ ( posedge Clock )
begin

if (iInputReady)
begin
	case ( iOperation )
		3'b000: Result = rGreaterThan;			//X > Y
		3'b001: Result = ~rGreaterThan;  		//X < Y
		3'b010: Result = wEQ;						//X == Y
		3'b011: Result = ~wEQ;						//X != Y
		3'b100: Result = rGreaterThan || wEQ; 	// X >= Y
		3'b101: Result = ~rGreaterThan || wEQ; // X <= Y
		default: Result = 0;
	endcase
		OutputReady = 1;
end
else
		OutputReady = 0;
end


endmodule
//---------------------------------------------