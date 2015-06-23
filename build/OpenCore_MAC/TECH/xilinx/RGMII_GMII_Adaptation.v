`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:19:29 06/01/2010 
// Design Name: 
// Module Name:    RGMII_GMII_Adaptation 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: This implementation follows the recommendations in XAPP692 of Mary Low
//
//////////////////////////////////////////////////////////////////////////////////
module RGMII_GMII_Adaptation(
	 input [2:0] Speed,
	 input RxClkPhase,//0: normal, 1 shift 90deg
    input [7:0] TxD,
    input TxEN,
    input TxER,
    input TxClk,
    output [7:0] RxD,
    output RxDV,
    output RxER,
    output RxClk,
	 output RxClk_MAC,//for MAC Rx block which works at half Rx Clock in 100/10 mode and at full Rx clk in 1G mode
    output [3:0] RGMII_TxD,
    output RGMII_TxCtl,
    output RGMII_TxClk,
    input [3:0] RGMII_RxD,
    input RGMII_RxCtl,
    input RGMII_RxClk,
    output reg [3:0] Status,
	 input CE,
	 input rst
    );

wire RXDVi,RXERi;
wire [7:0] RXDi;

reg RxSync_Rst,RxSync_Rst1;
reg TxSync_Rst,TxSync_Rst1;

reg RxCE, RxCE1;
reg TxCE, TxCE1;

wire RxClkDiv2;
wire CLK0, CLKFB, CLK_RX, CLK_180, CLK_90;

	assign RxDV = RXDVi;
	assign RxER = RXERi;
	assign RxD = RXDi;
	
		
	
GMII2RGMII TX_Adapter(.TxD(TxD),.TxClk(TxClk),.TxEn(TxEN),.TxErr(TxER),
							.RGMII_TxD(RGMII_TxD),.RGMII_TxCtl(RGMII_TxCtl),.RGMII_TxClk(RGMII_TxClk),
							.ClkEN(TxCE),.rst(TxSync_Rst));


RGMII2GMII RX_Adapter(.RGMII_RxD(RGMII_RxD),.RGMII_RxCtl(RGMII_RxCtl),.RGMII_RxClk(CLK_RX),
								.RxD(RXDi),.RxDV(RXDVi),.RxER(RXERi),.RxClk(RxClk),.ClkEN(RxCE),.rst(RxSync_Rst));

	always@(posedge(rst) or posedge(CLK_RX))
	begin
			if(rst)
			begin
				Status <= 4'b0;
			end
			else 
			begin
			if(~(RXDVi|RXERi))
				begin
					Status <= RXDi;
				end
			end
	end
	
	always@(posedge(CLK_RX))
	begin
		if(rst)
			RxSync_Rst1 <= 1;
		else
			RxSync_Rst1 <= 0;
		RxSync_Rst <= RxSync_Rst1;
		RxCE <= RxCE1;
		RxCE1 <= CE;
	end
	
	always@(posedge(TxClk))
	begin
		if(rst)
			TxSync_Rst1 <= 1;
		else
			TxSync_Rst1 <= 0;
		TxSync_Rst <= TxSync_Rst1;
		TxCE <= TxCE1;
		TxCE1 <= CE;
	end
	
	//DCM for Receiving Path
	  DCM_BASE #(
      .CLKDV_DIVIDE(2.0), // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                          //   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      .CLKFX_DIVIDE(2), // Can be any integer from 1 to 32
      .CLKFX_MULTIPLY(4), // Can be any integer from 2 to 32
      .CLKIN_DIVIDE_BY_2("FALSE"), // TRUE/FALSE to enable CLKIN divide by two feature
      .CLKIN_PERIOD(10.0), // Specify period of input clock in ns from 1.25 to 1000.00
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
   ) DCM_BASE_inst (
      .CLK0(CLK0),         // 0 degree DCM CLK output
      .CLK180(CLK_180),     // 180 degree DCM CLK output
      .CLK270(),     // 270 degree DCM CLK output
      .CLK2X(),       // 2X DCM CLK output
      .CLK2X180(), // 2X, 180 degree DCM CLK out
      .CLK90(CLK_90),       // 90 degree DCM CLK output
      .CLKDV(RxClkDiv2),       // Divided DCM CLK out (CLKDV_DIVIDE)
      .CLKFX(),       // DCM CLK synthesis out (M/D)
      .CLKFX180(), // 180 degree CLK synthesis out
      .LOCKED(),     // DCM LOCK status output
      .CLKFB(CLKFB),       // DCM clock feedback
      .CLKIN(RGMII_RxClk),       // Clock input (from IBUFG, BUFG or DCM)
      .RST(rst)            // DCM asynchronous reset input
   );
	
	BUFG BUFG_inst (
      .O(CLKFB),     // Clock buffer output
      .I(CLK0)      // Clock buffer input
   );
	//Use this to have the same amount of delay
	BUFGMUX BUFGMUX_inst (
      .O(CLK_RX),    // Clock MUX output
      .I0(CLK0),  // Clock0 input
      .I1(CLK_90),  // Clock1 input
      .S(RxClkPhase)     // Clock select input
   );
	
	//	BUFG BUFG_RX_inst (
	//      .O(CLK_RX),     // Clock buffer output
	//      .I(CLK_90)      // Clock buffer input
	//   );
	//assign CLK_RX = CLKFB;	
	BUFGMUX RxClkMux(
							.I0(RxClkDiv2),
							.I1(CLK0),
							.O(RxClk_MAC),
							.S(Speed[2]));
	
endmodule
