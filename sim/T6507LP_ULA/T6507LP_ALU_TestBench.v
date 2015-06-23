`timescale 1ns / 1ps
module T6507LP_ALU_TestBench(input dummy,output error);

`include  "T6507LP_Package.v"

reg clk_i;
reg n_rst_i;
reg alu_enable;
wire [7:0] alu_result;
wire [7:0] alu_status;
reg [7:0] alu_opcode;
reg [7:0] alu_a;

//`include "T6507LP_Package.v"

T6507LP_ALU DUT (
			.clk_i		(clk_i),
			.n_rst_i	(n_rst_i),
			.alu_enable	(alu_enable),
			.alu_result	(alu_result),
			.alu_status	(alu_status),
			.alu_opcode	(alu_opcode),
			.alu_a		(alu_a)
		);

/*
localparam period = 10;

always begin
	#(period/2) clk_i = ~clk_i;
end


initial
begin
	clk_i = 0;
	n_rst_i = 1;
	@(negedge clk_i);
	n_rst_i = 0;
	alu_opcode = LDA_IMM;
	alu_a = 0;
	@(negedge clk_i);
	alu_opcode = ADC_IMM;
	alu_a = 1;
	while (1) begin
		$display("op1 = %h op2 =  c = %h d = %h n = %h v = %h ", alu_a, alu_status[C], alu_status[D], alu_status[N], alu_status[V]);
	end
	$finish;
end
*/
endmodule

