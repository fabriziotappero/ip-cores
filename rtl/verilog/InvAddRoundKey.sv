`timescale 1ns/1ps

module InvAddRoundKey(
	input	[0:127]	din0,
	input	[0:127] din1,
	input	[0:127]	rkey,
	input	S,
	output	[0:127]	dout);
	
	logic	[0:127]	tmp;
	
	always_comb
		tmp <= S? din1 : din0;
		
	assign dout = tmp ^ rkey;
endmodule