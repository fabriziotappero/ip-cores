`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:20:11 06/01/2010 
// Design Name: 
// Module Name:    RGMII2GMII 
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
module RGMII2GMII(
    input [3:0] RGMII_RxD,
    input RGMII_RxCtl,
    input RGMII_RxClk,
    output reg [7:0] RxD,
    output reg RxDV,
    output reg RxER,
    output RxClk,
	 input ClkEN,
	 input rst
    );

wire [3:0] RxDH; 
wire [3:0] RxDL;
wire DV, ER;
reg DV1,ERR1;
reg DV2,ERR2;
wire [7:0] RxD1;
reg [3:0] RxD1H;
reg [3:0] RxD1L;
reg [7:0] RxD2;

	assign RxClk = RGMII_RxClk;
	
	genvar I;
	generate
	for(I=0;I<4;I=I+1)
	begin: genddr
	IDDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                      //    or "SAME_EDGE_PIPELINED" 
      .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) IDDR_inst (
      .Q1(RxDL[I]), // 1-bit output for positive edge of clock 
      .Q2(RxDH[I]), // 1-bit output for negative edge of clock
      .C(RGMII_RxClk),   // 1-bit clock input
      .CE(ClkEN), // 1-bit clock enable input
      .D(RGMII_RxD[I]),   // 1-bit DDR data input
      .R(rst),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );	
	end
	endgenerate
	
	IDDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                      //    or "SAME_EDGE_PIPELINED" 
      .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) IDDR_inst (
      .Q1(DV), // 1-bit output for positive edge of clock 
      .Q2(ER), // 1-bit output for negative edge of clock
      .C(RGMII_RxClk),   // 1-bit clock input
      .CE(ClkEN), // 1-bit clock enable input
      .D(RGMII_RxCtl),   // 1-bit DDR data input
      .R(rst),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );	
	
	always@(posedge RGMII_RxClk)
	begin
		RxD1L<=RxDL;
	end	
	
	always@(negedge RGMII_RxClk)
	begin
		RxD1H<=RxDH;	
	end
		
	assign RxD1 = {RxD1H, RxD1L};
	
	always@(posedge(RGMII_RxClk))
	begin
			RxD2 <= RxD1;
			RxD <= RxD2;
	end	
	
	always@(posedge(RGMII_RxClk))
	begin
		DV1 <= DV;
	end	
	always@(negedge(RGMII_RxClk))
	begin
		ERR1<= ER;
	end	
	always@(posedge(RGMII_RxClk))
	begin
			ERR2 <= ERR1;
			DV2 <= DV1;
			RxDV <= DV2;
			RxER <= (DV2^ERR2);
	end
endmodule
