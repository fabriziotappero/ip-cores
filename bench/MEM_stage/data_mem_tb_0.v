////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:50:26 02/09/2012
// Design Name:   data_mem
// Module Name:   F:/Projects/My_MIPS/mips_16/bench/MEM_stage/data_mem_tb_0.v
// Project Name:  mips_16
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: data_mem
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
`include "mips_16_defs.v"
module data_mem_tb_0_v;

	// Inputs
	reg clk;
	reg [15:0] mem_access_addr;
	reg [15:0] mem_write_data;
	reg mem_write_en;

	// Outputs
	wire [15:0] mem_read_data;
	
	parameter CLK_PERIOD = 10;
	always #(CLK_PERIOD /2) 
		clk =~clk;
	reg [15:0] rand;
	integer i;
	
	// Instantiate the Unit Under Test (UUT)
	data_mem uut (
		.clk(clk), 
		.mem_access_addr(mem_access_addr), 
		.mem_write_data(mem_write_data), 
		.mem_write_en(mem_write_en), 
		.mem_read_data(mem_read_data)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		mem_access_addr = 0;
		mem_write_data = 0;
		mem_write_en = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#(CLK_PERIOD/2)
		#1
		
		
		write_mem;
		read_mem;
		//read_write_mem;
		$stop;
	end
    
	reg [`DATA_MEM_ADDR_WIDTH-1 : 0] addr_temp [7:0];
	reg [15 : 0] data_temp [7:0];
	task write_mem;
		begin
			$display("write_memory. random_addr, random data:");
			
			i=0;
			while(i<8) begin
				addr_temp[i] = {$random} % (2**`DATA_MEM_ADDR_WIDTH);
				data_temp[i] = $random % 32768;
			i = i+1;
			end
			$display("------------------------------");
			$display("wrote address:");
			i=0;
			while(i<8) begin
				$write("%d\t", addr_temp[i]);
				i = i+1;
			end
			
			$display("\n------------------------------");
			$display("wrote data:");
			i=0;
			while(i<8) begin
				mem_write_en = 1;
				mem_access_addr = addr_temp[i];
				mem_write_data = data_temp[i];
				#(CLK_PERIOD*1)
				$write("%d\t", uut.ram[mem_access_addr]);
				mem_write_en = 0;
				i = i+1;
			end
			$display("\n------------------------------");
		end
	endtask
	
	integer err_num = 0;
	task read_mem;
		begin
			$display("read data from addresses above and check");
			i=0;
			while(i<8) begin
				mem_access_addr = addr_temp[i];
				#(CLK_PERIOD*0.5)
				if( mem_read_data != data_temp[i]) begin
					$display("error @ %d, expect %d, read %d",
							mem_access_addr, data_temp[i], mem_read_data);
					err_num = err_num +1;
				end
				#(CLK_PERIOD*0.5)
				i = i+1;
			end
			$display("check over, %d errors", err_num);
			$display("\n------------------------------");
		end
	endtask
endmodule

