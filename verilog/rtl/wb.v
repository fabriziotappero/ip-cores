//--------------------------------------------------------------------------------------------------
//
// Title       : wb
// Design      : MicroRISCII
// Author      : Ali Mashtizadeh
//
//-------------------------------------------------------------------------------------------------
`timescale 1ps / 1ps

module wb(clk,wb_halt,d_in,d_out,d_sel_in,d_sel_out,dwe_in,dwe_out,wb_flush);
	// Inputs
	input			clk;
	wire			clk;
	input			wb_halt;
	wire			wb_halt;
	input	[31:0]	d_in;
	wire	[31:0]	d_in;
	input	[3:0]	d_sel_in;
	wire	[3:0]	d_sel_in;
	input			dwe_in;
	wire			dwe_in;
	input			wb_flush;
	wire			wb_flush;

	// Outputs
	output	[31:0]	d_out;
	reg		[31:0]	d_out;
	output	[3:0]	d_sel_out;
	reg		[3:0]	d_sel_out;
	output			dwe_out;
	reg				dwe_out;

	always @ (posedge clk)
		begin
			if (wb_halt == 1'b0)
				begin
					d_out = d_in;
					d_sel_out = d_sel_in;
					if (wb_flush == 1'b1)
						dwe_out = 1'b0;
					else
						dwe_out = dwe_in;
				end
		end

endmodule
