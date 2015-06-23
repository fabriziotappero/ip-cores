// two stage synchronizer

module sync2s(rst, clk, i, o);
	input rst;
	input clk;
	input i;
	output o;
	
	reg [1:0] s;
	always @(posedge clk)
		if (rst)
			s <= 0;
		else
			s <= {s[0],i};
			
	assign o = s[1];
	
endmodule
