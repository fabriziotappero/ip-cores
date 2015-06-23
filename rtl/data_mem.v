/***************************************************
 * Module: data_mem
 * Project: mips_16
 * Author: fzy
 * Description: 
 *     a ram implementation, 16bit word width, address width can be configured be user
 *		further will be able to read external memory
 *
 * Revise history:
 *     
 ***************************************************/
`timescale 1ns/1ps
`include "mips_16_defs.v"
module data_mem
(
	input					clk,
	
	// address input, shared by read and write port
	input	[15:0]			mem_access_addr,
	
	// write port
	input	[15:0]			mem_write_data,
	input					mem_write_en,
	// read port
	output	[15:0]			mem_read_data
	
);


	reg [15:0] ram [(2**`DATA_MEM_ADDR_WIDTH)-1:0];

	wire [`DATA_MEM_ADDR_WIDTH-1 : 0] ram_addr = mem_access_addr[`DATA_MEM_ADDR_WIDTH-1 : 0];

	always @(posedge clk)
		if (mem_write_en)
			ram[ram_addr] <= mem_write_data;

	assign mem_read_data = ram[ram_addr]; 
   
endmodule 