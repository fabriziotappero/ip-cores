`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:08:22 08/27/2012
// Design Name:   ethernet_test
// Module Name:   C:/Projects/Xilinx/Ethernet/ethernet_test_tb.v
// Project Name:  Ethernet
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ethernet_test
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ethernet_test_tb_ping;

	// Inputs
	reg clk_in;
	reg Ethernet_RDp;
	reg Ethernet_RDm;
	reg PushButton;

	// Outputs
	wire Ethernet_TDp;
	wire Ethernet_TDm;
	wire Ethernet_LED_Link;
	wire Ethernet_LED_Act;
	wire LED_Test;


	// Instantiate the Unit Under Test (UUT)
	ethernet_test uut (
		.clk_in(clk_in), 
		.Ethernet_RDp(Ethernet_RDp), 
		.Ethernet_RDm(Ethernet_RDm), 
		.Ethernet_TDp(Ethernet_TDp), 
		.Ethernet_TDm(Ethernet_TDm), 
		.Ethernet_LED_Link(Ethernet_LED_Link), 
		.Ethernet_LED_Act(Ethernet_LED_Act), 
		.PushButton(PushButton),
		.LED_Test(LED_Test)
	);

	initial begin
		// Initialize Inputs
		clk_in = 0;
		Ethernet_RDp = 0;
		Ethernet_RDm = 0;
		PushButton = 0;

		// Wait 1000 ns for global reset to finish
		#1000;
		// 8'h55
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h55
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h55
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h55
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h55
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h55
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h55
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'hD5
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		// 8'h00
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h12
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h34
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h56
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h78
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h90
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		// 8'h00
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h01
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h29
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'hd1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		// 8'h6c
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h98
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		// 8'h08
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h00
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h45
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h00
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h00
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h3c
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h3e
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'hbf
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		// 8'h00
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h00
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h80
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		// 8'h01
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h78
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h83
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		// 8'hc0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		// 8'ha8
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		// 8'h01
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h02
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'hc0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		// 8'ha8
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		// 8'h01
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h2c
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h08
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h00
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h41
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h5b
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h04
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h00
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h08
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h01
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h61
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h62
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h63
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h64
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h65
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h66
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h67
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h68
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h69
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h6a
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h6b
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h6c
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h6d
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h6e
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h6f
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h70
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h71
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h72
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h73
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h74
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h75
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h76
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h77
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h61
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h62
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h63
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h64
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h65
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h66
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h67
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h68
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'h69
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		// 8'hC8
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		// 8'h95
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		// 8'hE6
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		// 8'hE0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 0; Ethernet_RDm = 1; #50; Ethernet_RDp = 1; Ethernet_RDm = 0; // 0
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1
		#50; Ethernet_RDp = 1; Ethernet_RDm = 0; #50; Ethernet_RDp = 0; Ethernet_RDm = 1; // 1


	end


   parameter PERIOD = 20;
   always begin
      clk_in = 1'b0;
      #(PERIOD/2) clk_in = 1'b1;
      #(PERIOD/2);
   end  

      
endmodule

