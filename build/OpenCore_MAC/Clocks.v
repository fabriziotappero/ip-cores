`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:13:01 06/02/2010 
// Design Name: 
// Module Name:    Clocks 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Clocks(
    input V4_Clk_125M,
    input V4_Clk_27M,
    input V4_Clk_13M5,
	 input V4_Clk_66M,
	 input [2:0] Speed,
    output Clk_125M,
    output Clk_27M,
    output Clk_13M5,
	 output Clk_25M,
	 output Clk_66M,
	 output Clk_125M_90,
	 output TxClk,
	 output TxClk_MAC,
    input rst
    );

reg  Clk2m5;
reg  Clk2m5div2;
reg  Clk25div2;
wire Clk25div2i;
wire Clk2m5i;

wire ClkTx;
wire ClkTxdiv2;

wire Clk25, Clk25i;
wire Clk125, Clk125i;
wire Clk125_90;
	// DCM_BASE: Base Digital Clock Manager Circuit
   //           Virtex-4/5
   // Xilinx HDL Language Template, version 10.1

   DCM_BASE #(
      .CLKDV_DIVIDE(5.0), // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                          //   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      .CLKFX_DIVIDE(5), // Can be any integer from 1 to 32
      .CLKFX_MULTIPLY(2), // Can be any integer from 2 to 32
      .CLKIN_DIVIDE_BY_2("FALSE"), // TRUE/FALSE to enable CLKIN divide by two feature
      .CLKIN_PERIOD(8.0), // Specify period of input clock in ns from 1.25 to 1000.00
      .CLKOUT_PHASE_SHIFT("NONE"), // Specify phase shift mode of NONE or FIXED
      .CLK_FEEDBACK("1X"), // Specify clock feedback of NONE, 1X or 2X
      .DCM_PERFORMANCE_MODE("MAX_SPEED"), // Can be MAX_SPEED or MAX_RANGE
      .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                            //   an integer from 0 to 15
      .DFS_FREQUENCY_MODE("LOW"), // LOW or HIGH frequency mode for frequency synthesis
      .DLL_FREQUENCY_MODE("LOW"), // LOW, HIGH, or HIGH_SER frequency mode for DLL
      .DUTY_CYCLE_CORRECTION("TRUE"), // Duty cycle correction, TRUE or FALSE
      .FACTORY_JF(16'hf0f0), // FACTORY JF value suggested to be set to 16'hf0f0
      .PHASE_SHIFT(0), // Amount of fixed phase shift from -255 to 1023
      .STARTUP_WAIT("FALSE") // Delay configuration DONE until DCM LOCK, TRUE/FALSE
   ) DCM_BASE_125M (
      .CLK0(Clk125),         // 0 degree DCM CLK output
      .CLK180(),     // 180 degree DCM CLK output
      .CLK270(),     // 270 degree DCM CLK output
      .CLK2X(),       // 2X DCM CLK output
      .CLK2X180(), // 2X, 180 degree DCM CLK out
      .CLK90(Clk125_90),       // 90 degree DCM CLK output
      .CLKDV(Clk25),       // Divided DCM CLK out (CLKDV_DIVIDE)
      .CLKFX(),       // DCM CLK synthesis out (M/D)
      .CLKFX180(), // 180 degree CLK synthesis out
      .LOCKED(),     // DCM LOCK status output
      .CLKFB(Clk125i),       // DCM clock feedback
      .CLKIN(V4_Clk_125M),       // Clock input (from IBUFG, BUFG or DCM)
      .RST(rst)            // DCM asynchronous reset input
   );

	BUFG BUFG_inst (
      .O(Clk125i),     // Clock buffer output
      .I(Clk125)      // Clock buffer input
   );
	
	assign Clk_125M = Clk125i;
	
	BUFG BUFG25_inst (
      .O(Clk25i),     // Clock buffer output
      .I(Clk25)      // Clock buffer input
   );
	
	BUFG BUF125_90(
	.O(Clk_125M_90),
	.I(Clk125_90));
	
	assign Clk_25M = Clk25i;

   // End of DCM_BASE_inst instantiation
	
//	always@(posedge Clk25i or posedge rst)
//	if(rst)
//	begin
//	cntr <= 0;
//	Clk2m5 <= 0;
//	Clk2m5div2 <= 0;
//	Clk25div2 <= 0;	
//	end
//	else
//	begin
//		if(cntr==9) cntr<=0; else cntr<=cntr+1;
//		if(cntr==0 || cntr==5) Clk2m5 <= ~Clk2m5;
//		if(cntr==0) Clk2m5div2 <= ~Clk2m5div2;
//		Clk25div2 <= ~Clk25div2;
//	end
	


endmodule
