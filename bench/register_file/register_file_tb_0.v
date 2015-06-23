

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:38:17 02/08/2012
// Design Name:   register_file
// Module Name:   F:/Projects/My_MIPS/mips_16/bench/register_file/register_file_tb_0.v
// Project Name:  mips_16
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: register_file
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
`include "mips_16_defs.v"

module register_file_tb_0_v;

	// Inputs
	reg clk;
	reg rst;
	reg reg_write_en;
	reg [2:0] reg_write_dest;
	reg [15:0] reg_write_data;
	reg [2:0] reg_read_addr_1;
	reg [2:0] reg_read_addr_2;

	// Outputs
	wire [15:0] reg_read_data_1;
	wire [15:0] reg_read_data_2;

	// Instantiate the Unit Under Test (UUT)
	register_file uut (
		.clk(clk), 
		.rst(rst), 
		.reg_write_en(reg_write_en), 
		.reg_write_dest(reg_write_dest), 
		.reg_write_data(reg_write_data), 
		.reg_read_addr_1(reg_read_addr_1), 
		.reg_read_data_1(reg_read_data_1), 
		.reg_read_addr_2(reg_read_addr_2), 
		.reg_read_data_2(reg_read_data_2)
	);
	
	parameter CLK_PERIOD = 10;
	always #(CLK_PERIOD /2) 
		clk =~clk;
	integer i;
	reg [15:0] rand;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		reg_write_en = 0;
		reg_write_dest = 0;
		reg_write_data = 0;
		reg_read_addr_1 = 0;
		reg_read_addr_2 = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#(CLK_PERIOD/2)
		#1
		#(CLK_PERIOD*1) rst = 1;
		#(CLK_PERIOD*1) rst = 0;
		
		#(CLK_PERIOD*10)
		display_all_regs;
		write_all_regs;
		read_all_regs_from_read_port_1;
		read_all_regs_from_read_port_2;
		write_and_read_all_regs;
		$stop;
		$finish;
	end
    
	task display_all_regs;
		begin
			$display("display_all_regs:");
			$display("------------------------------");
			$display("R0\tR1\tR2\tR3\tR4\tR5\tR6\tR7");
			for(i=0; i<8; i=i+1)
					$write("%d\t",uut.reg_array[i]);
			$display("\n------------------------------");
		end
	endtask
	
	task read_all_regs_from_read_port_1;
		begin
			$display("read_all_regs_from_read_port_1:");
			$display("------------------------------");
			$display("R0\tR1\tR2\tR3\tR4\tR5\tR6\tR7");
			i=0;
			while(i<8) begin
				reg_read_addr_1 = i;
				#(CLK_PERIOD*1)
				$write("%d\t",reg_read_data_1);
				i=i+1;
			end
			$display("\n------------------------------");
		end
	endtask
	
	task read_all_regs_from_read_port_2;
		begin
			$display("read_all_regs_from_read_port_2:");
			$display("------------------------------");
			$display("R0\tR1\tR2\tR3\tR4\tR5\tR6\tR7");
			i=0;
			while(i<8) begin
				reg_read_addr_2 = i;
				#(CLK_PERIOD*1)
				$write("%d\t",reg_read_data_2);
				i=i+1;
			end
			$display("\n------------------------------");
		end
	endtask
	
	task write_all_regs;
		begin
			$display("write_all_regs(random):");
			$display("------------------------------");
			$display("R0\tR1\tR2\tR3\tR4\tR5\tR6\tR7");
			i=0;
			while(i<8) begin
				reg_write_en=1;
				reg_write_dest = i;
				reg_write_data = $random % 32768;
				#(CLK_PERIOD*1)
				$write("%d\t",uut.reg_array[i]);
				reg_write_en=0;
				i=i+1;
			end
			$display("\n------------------------------");
		end
	endtask
	
	reg [15:0] read_tmp_1[7:0];
	reg [15:0] read_tmp_2[7:0];
	
	task write_and_read_all_regs;
		begin
			$display("write_and_read_all_regs(random):");
			$display("------------------------------");
			$display("R0\tR1\tR2\tR3\tR4\tR5\tR6\tR7");
			$display("newly wrote values:");
			$display("------------------------------");
			i=0;
			while(i<8) begin
				reg_write_en=1;
				reg_write_dest = i;
				reg_write_data = $random % 32768;
				reg_read_addr_1 = i;
				reg_read_addr_2 = i-1;
				#(CLK_PERIOD*0.5)
				read_tmp_1[i]=reg_read_data_1;
				if(reg_read_data_1 > 0)
					read_tmp_2[i-1]=reg_read_data_2;
				#(CLK_PERIOD*0.5)
				$write("%d\t",uut.reg_array[i]);
				reg_write_en=0;
				i=i+1;
			end
			reg_read_addr_2 = i-1;
			#(CLK_PERIOD*0.5)
			read_tmp_2[i-1]=reg_read_data_2;
			#(CLK_PERIOD*0.5)
			$display("\n------------------------------");
			
			$display("read from port 1 (read regs being wrote will hold its value):");
			$display("------------------------------");
			i=0;
			while(i<8) begin
				$write("%d\t",read_tmp_1[i]);
				i=i+1;
			end
			$display("\n------------------------------");
			
			$display("read from port 2 (read wrote regs will get its new value):");
			$display("------------------------------");
			i=0;
			while(i<8) begin
				$write("%d\t",read_tmp_2[i]);
				i=i+1;
			end
			$display("\n------------------------------");
		end
	endtask
endmodule

