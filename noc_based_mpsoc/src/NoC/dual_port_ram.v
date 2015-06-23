// Quartus II Verilog Template
// True Dual Port RAM with single clock
`timescale 1ns / 1ps

module dual_port_ram
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6, parameter CORE_NUMBER=0)
(
	input [(DATA_WIDTH-1):0] data_a, data_b,
	input [(ADDR_WIDTH-1):0] addr_a, addr_b,
	input we_a, we_b, clk,
	output  reg [(DATA_WIDTH-1):0] q_a, q_b
);







	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	// Port A 
	always @ (posedge clk)
	begin
		if (we_a) 
		begin
			ram[addr_a] <= data_a;
			q_a <= data_a;
		end
		else 
		begin
			q_a <= ram[addr_a];
		end 
	end 

	// Port B 
	always @ (posedge clk)
	begin
		if (we_b) 
		begin
			ram[addr_b] <= data_b;
			q_b <= data_b;
		end
		else 
		begin
			q_b <= ram[addr_b];
		end 
	end






	
	
	
	
	//synthesis translate_off
	integer	i;
	initial begin
	
	for(i=0;i<2**ADDR_WIDTH;i=i+1)
		ram[i]=i+ (CORE_NUMBER << 25);
	end //initial
	
	
	//synthesis translate_on

endmodule



module fifo_ram 	#(
	parameter DATA_WIDTH	= 32,
	parameter ADDR_WIDTH	= 8
	)
	(
		input [DATA_WIDTH-1			:		0] 	wr_data,		
		input [ADDR_WIDTH-1			:		0]		wr_addr,
		input [ADDR_WIDTH-1			:		0]		rd_addr,
		input												wr_en,
		input												rd_en,
		input 											clk,
		output reg 	[DATA_WIDTH-1	:		0]		rd_data
	);	

	 
	
	reg [DATA_WIDTH-1:0] queue [2**ADDR_WIDTH-1:0] /* synthesis ramstyle = "no_rw_check , M9K" */;
	
	always @(posedge clk ) begin
		if (wr_en)
			queue[wr_addr] <= wr_data;
		if (rd_en)
			rd_data <=
				// synthesis translate_off
				#1
				// synthesis translate_on
				queue[rd_addr];
	end
	
	
endmodule
