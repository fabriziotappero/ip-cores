`timescale 1ns / 1ps
`include "aDefinitions.v"

//-------------------------------------------------------------------
module ControlRegister
(
	input wire Clock,
	input wire Reset,
	input wire[15:0]	iControlRegister,
	output wire[15:0] oControlRegister
);

reg [15:0] rControlRegister;

assign oControlRegister = rControlRegister;

always @ (posedge Clock)
begin
	if ( Reset )
		rControlRegister <= 16'b0;
	else
	begin
		rControlRegister <= iControlRegister;
	end
end

endmodule
//-------------------------------------------------------------------