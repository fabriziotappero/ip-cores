`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:43:51 05/14/2013
// Design Name:   top
// Module Name:   /home/alw/projects/vtachspartan/vtach_test.v
// Project Name:  vtachspartan
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module vtach_test;

	// Inputs
	reg clk;
	reg extreset;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk(clk), 
		.extreset(extreset)
	);
	
	always #1 clk=~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		extreset = 1;
	//	uut.mem.row0[0]=13'h105;
	//	uut.mem.row0[1]=13'h206;
	//	uut.mem.row0[2]=13'h670;
	//	uut.mem.row0[3]=13'h570;
	//	uut.mem.row0[4]=13'h900;
	//	uut.mem.row0[5]=13'h1001;
	//	uut.mem.row0[6]=13'h001;

		// Wait 100 ns for global reset to finish
      #100 extreset=0;
		// Add stimulus here

	end
      
endmodule

