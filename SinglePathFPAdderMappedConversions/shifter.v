`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	UPT
// Engineer: 	Constantina-Elena Gavriliu
// 
// Create Date:    18:00:33 10/15/2013 
// Design Name: 
// Module Name:    shifter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 	d_ff.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
 
module shifter #(	parameter               	 INPUT_SIZE = 13,
						parameter                SHIFT_SIZE = 4,
						parameter                OUTPUT_SIZE = 24, //>INPUT_SIZE
						parameter                DIRECTION = 1,
						parameter                PIPELINE = 1,
						parameter [7:0]          POSITION = 8'b00000000)
					(a, arith, shft, shifted_a);
 
	input [INPUT_SIZE-1:0]   a;
	input                    arith;
	input [SHIFT_SIZE-1:0]   shft;
	output [OUTPUT_SIZE-1:0] shifted_a;
 
 
 
	wire [OUTPUT_SIZE-1:0]   a_temp_d[SHIFT_SIZE:0];
	wire [OUTPUT_SIZE-1:0]   a_temp_q[SHIFT_SIZE:0];
 
	assign a_temp_q[0][OUTPUT_SIZE-1 : OUTPUT_SIZE-INPUT_SIZE] = a;
	assign a_temp_q[0][OUTPUT_SIZE-1-INPUT_SIZE : 0] = arith; 
 
	generate
	begin : GENERATING
		genvar i;
		for (i = 0; i <= SHIFT_SIZE - 1; i = i + 1)
		begin : BARREL_SHIFTER_GENERATION
			if (DIRECTION == 1)
			begin : LEFT
					genvar j;
					for (j = 0; j <= OUTPUT_SIZE - 1; j = j + 1)
					begin : MUX_GEN_L
						if (j < 2 ** i)
						begin : ZERO_INS_L
							assign a_temp_d[i][j] = (shft[i] == 1'b0) ? a_temp_q[i][j] : arith;
						end
 
						if (j >= 2 ** i)
						begin : BIT_INS_L
							assign a_temp_d[i][j] = (shft[i] == 1'b0) ? a_temp_q[i][j] : a_temp_q[i][j-2**i];
						end
					end
				end
 
			if (DIRECTION == 0)
			begin : RIGHT
					genvar j;
					for (j = 0; j <= OUTPUT_SIZE - 1; j = j + 1)
					begin : MUX_GEN_R
						if (OUTPUT_SIZE - 1 < 2 ** i + j)
						begin : ZERO_INS_R
							assign a_temp_d[i][j] = (shft[i] == 1'b0) ? a_temp_q[i][j] : arith;
						end
 
						if (OUTPUT_SIZE - 1 >= 2 ** i + j)
						begin : BIT_INS_R
							assign a_temp_d[i][j] = (shft[i] == 1'b0) ? a_temp_q[i][j] : a_temp_q[i][j+2**i];
						end
					end
			end
 
			if (PIPELINE != 0)
			begin : PIPELINE_INSERTION
				if (POSITION[i] == 1'b1)
				begin : LATCH
					d_ff #(OUTPUT_SIZE) D_INS(.clk(clk), .rst(rst), .d(a_temp_d[i]), .q(a_temp_q[i + 1]));
				end
 
				if (POSITION[i] == 1'b0)
				begin : NO_LATCH
					assign a_temp_q[i + 1] = a_temp_d[i];
				end
			end
 
			if (PIPELINE == 0)
			begin : NO_PIPELINE
				assign a_temp_q[i + 1] = a_temp_d[i];
			end	
		end
	end
	endgenerate
 
	assign shifted_a = a_temp_q[SHIFT_SIZE];
 
endmodule

