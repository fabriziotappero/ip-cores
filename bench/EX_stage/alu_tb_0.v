////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:23:03 02/08/2012
// Design Name:   alu
// Module Name:   F:/Projects/My_MIPS/mips_16/bench/EX_stage/alu_tb_0.v
// Project Name:  mips_16
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: alu
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

module alu_tb_0_v;

	// Inputs
	reg [15:0] a;
	reg [15:0] b;
	reg [2:0] cmd;

	// Outputs
	wire [15:0] r;
	reg [15:0] rand;
	integer i;
	
	// Instantiate the Unit Under Test (UUT)
	alu uut (
		.a(a), 
		.b(b), 
		.cmd(cmd), 
		.r(r)
	);

	initial begin
		// Initialize Inputs
		a = 0;
		b = 0;
		cmd = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		i=0;
		while(i<10) begin
			test_NC;
			test_ADD;
			test_SUB;
			test_AND;
			test_OR;
			test_XOR;
			test_SL;
			test_SR;
			test_SRU;
			i = i+1;
		end	
		$stop;
		$finish;
	end
	
	task test_NC;
		begin
			$write(" ALU_NC \t");
			a = $random % 32768;
			b = $random % 32768;
			cmd = `ALU_NC;
			#10
			// if(r == 16'bxxxxxxxxxxxxxxxx) 
				$write("ok ");
			// else
				// $write("error @ %t , get %d, expect %d", $time, r, a b);
			$write("\n");
		end
	endtask
	
	task test_ADD;
		begin
			$write(" ALU_ADD \t");
			a = $random % 32768;
			b = $random % 32768;
			cmd = `ALU_ADD;
			#10
			if(r == a + b) 
				$write("ok ");
			else
				$write("error @ %t , get %d, expect %d", $time, r, a+b);
			$write("\n");
		end
	endtask
	
	task test_SUB;
		begin
			$write(" ALU_SUB \t");
			a = $random % 32768;
			b = $random % 32768;
			cmd = `ALU_SUB;
			#10
			if(r == a - b) 
				$write("ok ");
			else
				$write("error @ %t , get %d, expect %d", $time, r, a-b);
			$write("\n");
		end
	endtask
	
	task test_AND;
		begin
			$write(" ALU_AND \t");
			// a = $random % 32768;
			// b = $random % 32768;
			a = 16'b0101010101010101;
			b = 16'b1010101001010101;
			cmd = `ALU_AND;
			#10
			if(r == 16'b0000000001010101) 
			// if(r == 16'd85) 
				$write("ok ");
			else
				$write("error @ %t , get %d, expect %d", $time, r, a&b);
			$write("\n");
		end
	endtask
	
	task test_OR;
		begin
			$write(" ALU_OR \t");
			a = $random % 32768;
			b = $random % 32768;
			cmd = `ALU_OR;
			#10
			if(r == a | b) 
				$write("ok ");
			else
				$write("error @ %t , get %d, expect %d", $time, r, a|b);
			$write("\n");
		end
	endtask
	
	task test_XOR;
		begin
			$write(" ALU_XOR \t");
			a = $random % 32768;
			b = $random % 32768;
			cmd = `ALU_XOR;
			#10
			if(r == a ^ b) 
				$write("ok ");
			else
				$write("error @ %t , get %d, expect %d", $time, r, a^b);
			$write("\n");
		end
	endtask
      
	task test_SL;
		begin
			$write(" ALU_SL \t");
			a = $random % 32768;
			b = {$random} % 16;
			cmd = `ALU_SL;
			#10
			if(r == a << b) 
				$write("ok ");
			else
				$write("error @ %t , get %d, expect %d", $time, r, a<<b);
			$write("\n");
		end
	endtask
	
	// task test_SR;
		// begin
			// $write(" ALU_SR \t");
			// a = $random % 32768;
			// b = {$random} % 16;
			// cmd = `ALU_SR;
			// #10
			// if(r == a / 2**b ) 
				// $write("ok ");
			// else
				// $write("error @ %t , get %d, expect %d", $time, r, (a/(2**b)));
			// $write("\n");
		// end
	// endtask
	task test_SR;
		begin
			$write(" ALU_SR \t");
			a = 16'b1111000011110000;
			b = 7;
			cmd = `ALU_SR;
			#10
			if(r == 16'b1111111111100001 ) 
				$write("ok ");
			else
				$write("error @ %t , get %d, expect %d", $time, r, 16'b1111111111100001);
			$write("\n");
		end
	endtask
	
	task test_SRU;
		begin
			$write(" ALU_SRU \t");
			a = $random % 32768;
			b = {$random} % 16;
			cmd = `ALU_SRU;
			#10
			if(r == a >> b ) 
				$write("ok ");
			else
				$write("error @ %t , get %d, expect %d", $time, r, a >> b);
			$write("\n");
		end
	endtask
	
endmodule

