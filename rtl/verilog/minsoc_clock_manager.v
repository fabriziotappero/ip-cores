
`include "minsoc_defines.v"

module minsoc_clock_manager(
	clk_i, 
	clk_o
);

// 
// Parameters 
// 
   parameter    divisor = 2;
  
input clk_i;
output clk_o;
   
`ifdef NO_CLOCK_DIVISION
assign clk_o = clk_i;

`elsif GENERIC_CLOCK_DIVISION
reg [31:0] clock_divisor;
reg clk_int;
always @ (posedge clk_i)
begin
	clock_divisor <= clock_divisor + 1'b1;
	if ( clock_divisor >= divisor/2 - 1 ) begin
		clk_int <= ~clk_int;
		clock_divisor <= 32'h0000_0000;
	end
end
assign clk_o = clk_int;

`elsif FPGA_CLOCK_DIVISION
`ifdef ALTERA_FPGA
altera_pll #
(
    .FREQ_DIV(divisor)
)
minsoc_altera_pll
(
    .inclk0(clk_i),
    .c0(clk_o)
);
   
`elsif XILINX_FPGA
xilinx_dcm #
(
    .divisor(divisor)
)
minsoc_xilinx_dcm
(
    .clk_i(clk_i), 
    .clk_o(clk_o)
);

`endif	// !ALTERA_FPGA/XILINX_FPGA
`endif	// !NO_CLOCK_DIVISION/GENERIC_CLOCK_DIVISION/FPGA_CLOCK_DIVISION


endmodule
