/***************************************************
 * Module: register_file
 * Project: mips_16
 * Author: fzy
 * Description: 
 * 	a 8-entry 16-bit register file, 
 *	with 1 synchronized write port and 2 asynchonized read port
  *
 *	NOTE: for Register 0, read data from it will always be 0, 
 *		and write operatioins will also be discarded.
 *	
 * Revise history:
 *     
 ***************************************************/
`timescale 1ns/1ps
`include "mips_16_defs.v"

module register_file
(
	input				clk,
	input				rst,
	
	// write port
	input				reg_write_en,
	input		[2:0]	reg_write_dest,
	input		[15:0]	reg_write_data,
	
	//read port 1
	input		[2:0]	reg_read_addr_1,
	output		[15:0]	reg_read_data_1,
	//read port 2
	input		[2:0]	reg_read_addr_2,
	output		[15:0]	reg_read_data_2
);
	reg	[15:0]	reg_array [7:0];
	
	// write port
	//reg [2:0] i;
	always @ (posedge clk or posedge rst) begin
		if(rst) begin
			// for(i=0; i<8; i=i+1)
				// reg_array[i] <= 15'b0;
			reg_array[0] <= 15'b0;
			reg_array[1] <= 15'b0;
			reg_array[2] <= 15'b0;
			reg_array[3] <= 15'b0;
			reg_array[4] <= 15'b0;
			reg_array[5] <= 15'b0;
			reg_array[6] <= 15'b0;
			reg_array[7] <= 15'b0;	
		end
		else begin
			if(reg_write_en) begin
				reg_array[reg_write_dest] <= reg_write_data;
			end
		end
		
	end
	
	//read port 1
	// always @ (*) begin
		// if( reg_read_addr_1 == 0) begin
			// reg_read_data_1 = 15'b0;
		// end
		// else begin
			// reg_read_data_1 = reg_array[reg_read_addr_1];
		// end
	// end
	assign reg_read_data_1 = ( reg_read_addr_1 == 0)? 15'b0 : reg_array[reg_read_addr_1];
	
	//read port 2
	// always @ (*) begin
		// if( reg_read_addr_2 == 0) begin
			// reg_read_data_2 = 15'b0;
		// end
		// else begin
			// reg_read_data_2 = reg_array[reg_read_addr_2];
		// end
	// end
	assign reg_read_data_2 = ( reg_read_addr_2 == 0)? 15'b0 : reg_array[reg_read_addr_2];

endmodule 