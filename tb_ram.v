`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:38:56 11/29/2010 
// Design Name: 
// Module Name:    tb_ram 
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
module tb_ram(rst, clk, frame_rst, en, in1, in2, in3, in4, out_tb, out_dc);

parameter		state					=	64;
parameter		nu						=	6;
parameter		tb_length			=	128;
parameter		tb_length_log		=	7;
parameter		radix					=	4;		//1: radix-2;   2: radix-4		3: radix-8

localparam		data_width			=	state;
localparam		ram_depth			=	tb_length/radix;
localparam		addr_width			=	tb_length_log;

input								rst, clk, frame_rst, en;
input		[0:data_width-1]	in1;
input		[0:data_width-1]	in2;
input		[0:data_width-1]	in3;
input		[0:data_width-1]	in4;
output	[0:radix-1]			out_tb;
output	[0:radix-1]			out_dc;

reg	[0:3]					en_reg;
reg	[0:nu-1]				tb_state;
reg	[0:nu-1]				dec_state;
wire	[0:radix-1]			tb_tmp;
wire	[0:radix-1]			dc_tmp;
wire	[0:radix-1]			dc_tmp_tmp;
wire	[0:data_width-1]	out_w			[0:3][0:radix-1];
reg	[0:data_width-1]	in_reg	[0:radix-1];
reg	[0:addr_width-1]	counter_tb		;
reg	[0:addr_width-1]	counter_tbn		;
wire	[0:addr_width-1]	counter_tb_w	;
wire	[0:addr_width-1]	counter_tbn_w	;

reg	[0:1]		counter_id0		;
reg	[0:1]		counter_id1		;
reg	[0:1]		counter_id2		;
reg	[0:1]		counter_id3		;
wire	[0:1]		counter_id0_w	;
wire	[0:1]		counter_id1_w	;
wire	[0:1]		counter_id2_w	;
wire	[0:1]		counter_id3_w	;

genvar gi, gj;

initial
begin
	dec_state = 7;
	tb_state  = 7;
	counter_id0 = 0;
	counter_id1 = 1;
	counter_id2 = 2;
	counter_id3 = 3;
	counter_tb = 0;
	counter_tbn = -1;
end

always @ (clk, rst)
begin
	if 	(rst == 0)		counter_tb = 0;
	else if(clk == 1)
		if	(frame_rst == 1)	counter_tb = 0;
		else if (en == 1)		counter_tb = (counter_tb + 1) % ram_depth;
end

assign counter_tb_w = counter_tb;
assign counter_tbn_w = ~counter_tb;

always @ (clk, rst)
begin
	if 	(rst == 0)
	begin
		counter_id0 = 0;
		counter_id1 = 1;
		counter_id2 = 2;
		counter_id3 = 3;
	end
	else if	(clk == 1)
		if	(frame_rst == 1)
		begin
			counter_id0 = 0;
			counter_id1 = 1;
			counter_id2 = 2;
			counter_id3 = 3;
		end
		else if (counter_tb == ram_depth - 1)
		begin
			counter_id0 = (counter_id0 + 1) % 4;
			counter_id1 = (counter_id1 + 1) % 4;
			counter_id2 = (counter_id2 + 1) % 4;
			counter_id3 = (counter_id3 + 1) % 4;
		end
end

assign counter_id0_w = counter_id0;
assign counter_id1_w = counter_id1;
assign counter_id2_w = counter_id2;
assign counter_id3_w = counter_id3;

always @ (counter_id0_w)
begin
	case(counter_id0_w)
		2'b00	:	en_reg = 4'b1000;
		2'b01	:	en_reg = 4'b0100;
		2'b10	:	en_reg = 4'b0010;
		2'b11	:	en_reg = 4'b0001;
	endcase
end

generate
	if (radix == 1)
	begin
		always @ (in1, clk)
		begin
			in_reg[0] = in1;
		end
	end
	else if (radix == 2)
	begin
		always @ (in1, in2, clk)
		begin
			in_reg[0] = in1;
			in_reg[1] = in2;
		end
	end
	else if (radix == 3)
	begin
		always @ (in1, in2, in3, clk)
		begin
			in_reg[0] = in1;
			in_reg[1] = in2;
			in_reg[2] = in3;
		end
	end
	else if (radix == 4)
	begin
		always @ (in1, in2, in3, in4, clk)
		begin
			in_reg[0] = in1;
			in_reg[1] = in2;
			in_reg[2] = in3;
			in_reg[3] = in4;
		end
	end
endgenerate

generate for (gi = 0; gi < radix; gi = gi + 1)
begin : sel
	assign tb_tmp[gi] = out_w[counter_id3_w][gi][tb_state];
	assign dc_tmp[gi] = out_w[counter_id1_w][gi][dec_state];
	assign dc_tmp_tmp[gi] = out_w[counter_id1_w][gi][tb_state];
end
endgenerate

generate for (gi = 0; gi < 4; gi = gi + 1)
begin : ram
	for (gj = 0; gj < radix; gj = gj + 1)
	begin : r
		dpram		#(	data_width,
						ram_depth,
						addr_width)
						
		ram_inst	(	in_reg[gj], 
						out_w[gi][gj], 
						counter_tbn_w,
						counter_tb_w,
						clk, 
						rst, 
						frame_rst,
						en_reg[gi]);
	end
end
endgenerate

always @ (posedge clk)
begin
	if (counter_tb == ram_depth - 1)
	begin
		dec_state = {tb_state[radix:nu-1], dc_tmp_tmp};
		tb_state = 7;
	end
	else
	begin
		dec_state = {dec_state[radix:nu-1], dc_tmp};
		tb_state = {tb_state[radix:nu-1], tb_tmp};	
	end
end

generate for (gi = 0; gi < radix; gi = gi + 1)
begin : assgn_out
	assign out_tb[gi] = tb_state[gi];
	assign out_dc[gi] = dec_state[gi];
end
endgenerate

endmodule
