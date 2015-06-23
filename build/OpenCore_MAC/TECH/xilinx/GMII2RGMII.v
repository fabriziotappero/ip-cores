`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:57:12 06/01/2010 
// Design Name: 
// Module Name:    GMII2RGMII 
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
module GMII2RGMII(
    input [7:0] TxD,
    input TxClk,
    input TxEn,
    input TxErr,
    output [3:0] RGMII_TxD,
    output RGMII_TxCtl,
    output RGMII_TxClk,
	 input ClkEN,
	 input rst
    );

reg [3:0] TxHighNib;
reg [3:0] TxHighNib2;
reg [3:0] TxLowNib;
reg 	TX_EN1;
wire 	EN_xor_ERR1;
reg	EN_xor_ERR2;
reg	EN_xor_ERR3;

wire 	DDR_R;
reg 	DDR_S;
wire 	DDR_CE;
	
	

	initial 
	begin	
	DDR_S <= 0;	
	end
	
	assign DDR_CE = ClkEN;
	assign DDR_R = rst;
	
	always@(posedge(TxClk))
	begin
			TxLowNib <= TxD[3:0];		
	end
	
	always@(negedge(TxClk))
	begin
			TxHighNib <= TxD[7:4];	
			TxHighNib2	<= TxHighNib;
	end
	
	
	genvar I;
   generate
       for (I=0;I<4;I=I+1) 
       begin: gen_ddr
	// ODDR: Output Double Data Rate Output Register with Set, Reset
   //       and Clock Enable.
   //       Virtex-4/5
   // Xilinx HDL Language Template, version 10.1
			ODDR #(
				.DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
				.INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
				.SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
			) ODDR_inst (
				.Q(RGMII_TxD[I]),   // 1-bit DDR output
				.C(TxClk),   // 1-bit clock input
				.CE(DDR_CE), // 1-bit clock enable input
				.D1(TxLowNib[I]), // 1-bit data input (positive edge)
				.D2(TxHighNib2[I]), // 1-bit data input (negative edge)
				.R(DDR_R),   // 1-bit reset
				.S(DDR_S)    // 1-bit set
			);
       end
   endgenerate
		
	always@(posedge(TxClk))
	begin
		TX_EN1 <= TxEn;
		EN_xor_ERR2 <= EN_xor_ERR1;
	end
	
	always@(negedge(TxClk)) 
	begin
		EN_xor_ERR3 <= EN_xor_ERR2;
	end
	
	assign EN_xor_ERR1 = TxEn^TxErr;
	
	ODDR #(
				.DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
				.INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
				.SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
			) ODDR_inst (
				.Q(RGMII_TxCtl),   // 1-bit DDR output
				.C(TxClk),   // 1-bit clock input
				.CE(DDR_CE), // 1-bit clock enable input
				.D1(TX_EN1), // 1-bit data input (positive edge)
				.D2(EN_xor_ERR3), // 1-bit data input (negative edge)
				.R(DDR_R),   // 1-bit reset
				.S(DDR_S)    // 1-bit set
			);	

	ODDR #(
				.DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
				.INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
				.SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
			) ODDR_clk (
				.Q(RGMII_TxClk),   // 1-bit DDR output
				.C(TxClk),   // 1-bit clock input
				.CE(DDR_CE), // 1-bit clock enable input
				.D1(1), // 1-bit data input (positive edge)
				.D2(0), // 1-bit data input (negative edge)
				.R(DDR_R),   // 1-bit reset
				.S(DDR_S)    // 1-bit set
			);	
endmodule
