`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:50:09 12/01/2010 
// Design Name: 
// Module Name:    acs 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module acs(clk, rst, frame_rst, en, in1, in2, out);

parameter	r					=	1,	//r = 2 radix4; r = 3 radix8; r = 1 radix2;
				n					=	2,  //current version only support n = 2
				m					=	7,
				k					=	1,
				nu					=	6,
				state				=	64,
				tb_length		=	128,
				tb_length_log	=	7,
				bitwise			=	1,
				reglen			=	11;

input			clk, rst, frame_rst, en;

input		[0:bitwise-1]			in1;
input		[0:bitwise-1]			in2;
input		[0:bitwise-1]			in3;
input		[0:bitwise-1]			in4;
input		[0:bitwise-1]			in5;
input		[0:bitwise-1]			in6;
input		[0:bitwise-1]			in7;
input		[0:bitwise-1]			in8;
output	[0:state-1]				out;

wire		[0:state-1]				out;
reg 	  	[0:bitwise+1+(r-1)-1]						hamm_dist1					[0:2**(n*r)-1];
wire 		[0:reglen-1]			branch_metric_calc_w		[0:2*r-1][0:state-1];		//wire
wire		[0:2*r*(2*r-1)-1]		decision_tmp_w				[0:state-1];					//wire	
reg 		[0:reglen-1]			branch_metric				[0:state-1];					//reg
reg		[0:r-1]					decision						[0:state-1];					//reg

integer			i, j, fid, rcv, hdf, bmf;
reg		[0:(r*n)-1]				hamming_index_reg			[0:state-1][0:2**r-1];
reg		[0:3]					en_reg;

genvar			gi, gj, gk, gii, gjj, gkk;

//`include "hamming_index_16.v"
//`include "hamming_index_8.v"
//`include "hamming_index_4.v"
//`include "hamming_index_2.v"

initial
begin
	hdf = $fopen("hamming_dist.txt","w");
	bmf = $fopen("branch_metric.txt","w");
	if (r == 1)
		fid = $fopen("hamming_index_reg_2.txt", "r");
	else if (r == 2)
		fid = $fopen("hamming_index_reg_4.txt", "r");
	else if (r == 8)
		fid = $fopen("hamming_index_reg_8.txt", "r");
	for (i = 0; i < state; i = i + 1)
		for (j = 0; j < 2**r; j = j + 1)
			rcv = $fscanf(fid, "%b", hamming_index_reg[i][j]);
end

always @(clk, rst, en)
begin
	if (rst == 0)
		en_reg = 0;
	else if (clk == 1)
		if (frame_rst == 1)
			en_reg = 0;
		else if (en == 1)
			en_reg = { en, en_reg[0:2] };
end

always @ (clk, rst, en)
begin
	if(rst == 0)
	begin
		hamm_dist1[0] = 0;
		hamm_dist1[1] = 0;
		hamm_dist1[2] = 0;
		hamm_dist1[3] = 0;
	end
	else if(clk == 1)
	begin
		if(frame_rst == 1)
		begin
			hamm_dist1[0] = 0;
			hamm_dist1[1] = 0;
			hamm_dist1[2] = 0;
			hamm_dist1[3] = 0;
		end		
		else if(en_reg[1] == 1)
		begin
			hamm_dist1[0] = {1'b0, ( in1)} + {1'b0, ( in2)};
			hamm_dist1[1] = {1'b0, ( in1)} + {1'b0, (~in2)};
			hamm_dist1[2] = {1'b0, (~in1)} + {1'b0, ( in2)};
			hamm_dist1[3] = {1'b0, (~in1)} + {1'b0, (~in2)};
			for (i = 0; i < 2**(n*r); i = i + 1)
				$fdisplay(hdf, "%d", hamm_dist1[i]);
		end				
	end

end

generate for (gi = 0; gi < state; gi = gi + 1) begin : g10
	for (gj = 0; gj < 2**r; gj = gj + 1) begin : g11
		assign branch_metric_calc_w[gj][gi] = branch_metric[(gi*(2**r)+gj)%state] + hamm_dist1[hamming_index_reg[gi][gj]];
	end
end
endgenerate

generate for (gi = 0; gi < state; gi = gi + 1) begin : g12
	assign decision_tmp_w[gi] = branch_metric_calc_w[0][gi] > branch_metric_calc_w[1][gi];
end
endgenerate

generate for (gi = 0; gi < state; gi = gi + 1)
begin : g15
	always @ (clk, rst)
	begin
		if (rst == 0)
			decision[gi] = 0;
		else if (clk == 1)
			if (frame_rst == 1)	
				decision[gi] = 0;
			else if (en_reg[2] == 1)
				decision[gi] = decision_tmp_w[gi];
	end
end
endgenerate

generate for (gi = 0; gi < state; gi = gi + 1)
begin : g16
	always @ (clk, rst)
	begin : g16_1
		if (rst == 0)
			branch_metric[gi] = 0;
		else if (clk == 1)
			if (frame_rst == 1)	
				branch_metric[gi] = 0;
			else if (en_reg[2] == 1)
				branch_metric[gi] = branch_metric_calc_w[decision_tmp_w[gi]][gi];
	end
end
endgenerate

always @ (posedge clk)
begin
	for (i = 0; i < state; i = i + 1)
		$fwrite(bmf, "cmp %4.3d with %4.3d, decision is %2.1d, decision_w is %2.1d, result is %4.3d\n", branch_metric_calc_w[0][i], branch_metric_calc_w[1][i], decision[i], decision_tmp_w[i], branch_metric[i]);
	$fwrite(bmf, "================================================================================================================================\n");
end

generate for (gi = 0; gi < state; gi = gi + 1)
begin : assgn_out
	assign out[gi] = decision[gi];
end
endgenerate;

endmodule
