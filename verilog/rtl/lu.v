//--------------------------------------------------------------------------------------------------
//
// Title       : lu
// Design      : MicroRISCII
// Author      : Ali Mashtizadeh
//
//--------------------------------------------------------------------------------------------------
`timescale 1ps / 1ps

`define		LOGIC_NOT	4'b00
`define		LOGIC_OR	4'b01
`define		LOGIC_AND	4'b10
`define		LOGIC_XOR	4'b11

module lu(a,b,logic_op,o);
	// Inputs
	input	[31:0]	a;
	wire	[31:0]	a;
	input	[31:0]	b;
	wire	[31:0]	b;
	input	[3:0]	logic_op;
	wire	[3:0]	logic_op;
	// Outputs
	output	[31:0]	o;
	reg		[31:0]	o;

	always @ (logic_op || a || b)
		case (logic_op)
			`LOGIC_NOT :  o = !(a);
			`LOGIC_OR : o = a || b;
			`LOGIC_AND : o = a && b;
			`LOGIC_XOR : o = a ^^ b;
		endcase

endmodule
