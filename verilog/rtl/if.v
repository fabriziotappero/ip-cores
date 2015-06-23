//--------------------------------------------------------------------------------------------------
//
// Title       : if
// Design      : MicroRISCII
// Author      : Ali Mashtizadeh
//
//-------------------------------------------------------------------------------------------------
`timescale 1ps / 1ps

module wb(clk,if_halt,idata_in,idata_addr,idata_ready,opcode,opcode_pc);
	// Inputs
	input			clk;
	wire			clk;
	input			if_halt;
	wire			if_halt;
	input	[31:0]	idata_in;
	wire	[31:0]	idata_in;
	input	[31:0]	idata_addr;
	wire	[31:0]	idata_addr;
	input			idata_ready;
	wire			idata_ready;
	// Outputs
	output	[31:0]	opcode;
	reg		[31:0]	opcode;
	output	[31:0]	opcode_pc;
	reg		[31:0]	opcode_pc;

	always @ (posedge clk)
		if (if_halt == 1'b0)
			if (idata_ready == 1'b1)
				begin
					opcode = idata_in;
					opcode_pc = idata_addr;
				end
			else // NOP Until Instruction Found
				begin // Don't stall pipeline ;)
					opcode = 32'b0;
					opcode_pc = 32'b0;
				end

endmodule
