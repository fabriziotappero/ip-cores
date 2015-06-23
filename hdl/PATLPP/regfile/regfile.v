// Register File
// Author: Peter Lieber
//

module regfile
(
	input				clk,
	input				rst,

	input				wren_low,
	input				wren_high,
	input		[3:0]	address,

	input		[15:0]	data_in,
	output	[15:0]	data_out
);

reg	[15:0]	mem[15:0];
wire				we;
wire	[15:0]	write_data;

assign data_out = mem[address];
assign we = wren_high | wren_low;
assign write_data = (wren_high & ~wren_low) ? {data_in[7:0], data_out[7:0]} :
							(~wren_high & wren_low) ? {data_out[15:8], data_in[7:0]} : 
							data_in;

always @(posedge clk)
begin
	if (we)
		mem[address] <= write_data;
end

endmodule 
