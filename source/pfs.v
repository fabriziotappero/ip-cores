module pfs2 (clk, a, b);
	input clk;
	input a;
	output b;
	reg b;

	always @(posedge clk)
	begin
		b <= a;
	end
endmodule
