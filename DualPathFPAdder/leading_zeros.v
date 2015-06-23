`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	UPT
// Engineer: 	Constantina-Elena Gavriliu
// 
// Create Date:    18:50:09 10/17/2013 
// Design Name: 
// Module Name:    leading_zeros 
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
module leading_zeros #(	parameter SIZE_INT = 24,	//mantissa bits
						parameter SIZE_COUNTER	= 5,	//log2(size_mantissa) + 1 = 5)
						parameter PIPELINE = 2)	
							(a, ovf, lz);
 
	input [SIZE_INT-1:0]    a;
	input                   ovf;
	output [SIZE_COUNTER-1:0] lz;
 
 
	parameter 	nr_levels = SIZE_COUNTER - 1;
	parameter 	max_pow_2 = 2 ** SIZE_COUNTER;
	parameter 	size_lz = SIZE_COUNTER;
 
	wire [max_pow_2-1:0] a_complete;
	wire [max_pow_2-1:0] v_d[nr_levels-1:0];
	wire [max_pow_2-1:0] v_q[nr_levels-1:0];
	wire [max_pow_2-1:0] p_d[nr_levels-1:0];
	wire [max_pow_2-1:0] p_q[nr_levels-1:0];
	wire [size_lz-1:0]   lzc;
 
	assign a_complete[max_pow_2 - 1 : max_pow_2 - 1 - SIZE_INT + 1] = a;
	generate
		if (max_pow_2 != SIZE_INT)
		begin : gen_if
			assign a_complete[max_pow_2 - 1 - SIZE_INT : 0] = 0;
		end
	endgenerate
 
	generate
		begin : level_0
			genvar i;
			for (i = max_pow_2/4 - 1; i >= 0; i = i - 1)
			begin : level_0
				assign v_d[0][i] = (a_complete[4 * i + 3 : 4 * i] == 4'b0000) ? 1'b0 : 1'b1;
				assign p_d[0][2*i+1:2*i] = (a_complete[4 * i + 3] == 1'b1) ? 2'b00 : 
								(a_complete[4 * i + 2] == 1'b1) ? 2'b01 : 
								(a_complete[4 * i + 1] == 1'b1) ? 2'b10 : 2'b11;
			end
		end
	endgenerate
 
	generate
		begin : level_generation_begin
			genvar i;
			for (i = 1; i <= nr_levels - 1; i = i + 1)
			begin : level_generation
					genvar j;
					for (j = 0; j <= max_pow_2/(2 ** (i + 2)) - 1; j = j + 1)
					begin : v_levels
						assign v_d[i][j] = v_q[i - 1][2*j+1] | v_q[i - 1][2*j];
					end
 
				
					for (j = 0; j <= max_pow_2/(2 ** (i + 2)) - 1; j = j + 1)
					begin : p_levels
						assign p_d[i][(i+2)*j+i+1] = (~(v_q[i - 1][2*j+1]));
						assign p_d[i][(i+2)*j+i : (i+2)*j] = (v_q[i - 1][2*j+1] == 1'b1) ? p_q[i - 1][j*(2*i+2)+2*i+1 : j*(2*i+2) + i + 1] : p_q[i - 1][j*(2*i+2)+i : j*(2*i+2)];
					end
			end
		end
	endgenerate
 
	generate
		if (PIPELINE != 0)
		begin : pipeline_stages
				genvar i;
				for (i = 0; i <= nr_levels - 2; i = i + 1)
				begin : INSERTION
					if ((i + 1) % nr_levels/(PIPELINE + 1) == 0)
					begin : INS
						d_ff #(max_pow_2) P_Di(.clk(clk), .rst(rst), .d(p_d[i]), .q(p_q[i]));
						d_ff #(max_pow_2) V_Di(.clk(clk), .rst(rst), .d(v_d[i]), .q(v_q[i]));
					end
 
					if ((i + 1) % nr_levels/(PIPELINE + 1) != 0)
					begin : NO_INS
						assign p_q[i] = p_d[i];
						assign v_q[i] = v_d[i];
					end
				end
			assign p_q[nr_levels - 1] = p_d[nr_levels - 1];
			assign v_q[nr_levels - 1] = v_d[nr_levels - 1];
		end
	endgenerate 
 
	generate
		if (PIPELINE == 0)
		begin : no_pipeline
				genvar i;
				for (i = 0; i <= nr_levels - 1; i = i + 1)
				begin : NO_INSERTION
					assign p_q[i] = p_d[i];
					assign v_q[i] = v_d[i];
				end
		end
	endgenerate
 
	assign lzc[size_lz - 1:0] = p_q[nr_levels - 1][size_lz - 1:0];
 
	generate
		begin : lz_ovf_begin
			genvar i;
			for (i = 0; i <= size_lz - 1; i = i + 1)
			begin : lz_ovf
				assign lz[i] = lzc[i] & ((~ovf));
			end
		end
	endgenerate
 
endmodule