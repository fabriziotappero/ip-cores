module single_port_ram 
#(
	parameter DATA_WIDTH=8,
	parameter ADDR_WIDTH=6)
(
	input						clk,
	input						we,
	input	[DATA_WIDTH - 1:0]	d_wr,
	input	[ADDR_WIDTH - 1:0]	addr,
	output	[DATA_WIDTH - 1:0]	d_rd
);

	reg [DATA_WIDTH - 1:0] RAM_array [2**ADDR_WIDTH - 1:0];
	reg [ADDR_WIDTH - 1:0] read_addr_reg;

	always @ (posedge clk)
	begin
		if (we)
			RAM_array[addr] <= d_wr;
		read_addr_reg <= addr;
	end

	assign d_rd = RAM_array[read_addr_reg];
endmodule
