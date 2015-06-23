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

	wire [4:0] dataout_h;
	wire [4:0] dataout_l;
	wire [4:0] datain;
	
	assign RxClk = RGMII_RxClk;

	DDR_I DDR_I_instance(
	.datain(datain),
	.inclock(RGMII_RxClk),
	.dataout_h(dataout_h),
	.dataout_l(dataout_l));

	assign datain = {RGMII_RxCtl,RGMII_RxD};
	assign RxDL = dataout_h[3:0];
	assign RxDH = dataout_l[3:0];
	assign DV = dataout_h[4];
	assign ER = dataout_l[4];
	
	
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
