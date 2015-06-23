// Shift Register
// Author: Peter Lieber
//

module shiftr
(
	input				en_in,
	input				en_out,
	input				clk,
	input				rst,
	input				srst,

	input		[7:0]	data_in,
	output	[7:0] data_out
);

parameter DEPTH	= 16;
parameter DEPTHLOG = 4;

reg	[DEPTHLOG-1:0]		size;
reg							empty;

always @(posedge clk)
begin
	if (rst || srst)
	begin
		size <= 0;
		empty <= 1;
	end
	else if (empty == 1)
	begin
		if (en_in)
		begin
			empty <= 0;
		end
	end
	else
	begin
		if (en_in == 1 && en_out == 0)
		begin
			size <= size + 1;
		end
		else if (en_out == 1 && en_in == 0)
		begin
			if (size == 0)
				empty <= 1;
			else
				size <= size - 1;
		end
	end
end

genvar i;
generate
for (i=0; i<8; i=i+1)
begin : shiftregs
	gensrl shift_reg (
		.Q(data_out[i]),
		.A(size),
		.CE(en_in),
		.CLK(clk),
		.D(data_in[i])
	);
end
endgenerate

/*genvar i;
generate
for (i=0; i<8; i=i+1)
begin : shiftregs
	SRLC32E #(
		.INIT(32'h00000000)
	) shift_reg (
		.Q(data_out[i]),
		.Q31(),
		.A(size),
		.CE(en_in),
		.CLK(clk),
		.D(data_in[i])
	);
end
endgenerate*/

endmodule
