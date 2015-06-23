//Legal Notice: (C)2006 Altera Corporation. All rights reserved. Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

module Multi_Sdram(	//	Host Side
					oHS_DATA,iHS_DATA,iHS_ADDR,iHS_RD,iHS_WR,oHS_Done,
					//	Async Side 1
					oAS1_DATA,iAS1_DATA,iAS1_ADDR,iAS1_WR_n,
					//	Async Side 2
					oAS2_DATA,iAS2_DATA,iAS2_ADDR,iAS2_WR_n,
					//	Async Side 3
					oAS3_DATA,iAS3_DATA,iAS3_ADDR,iAS3_WR_n,
					//	Control Signals
					iSelect,iCLK, iRST_n,
					//	SDRAM Interface
        			SA,BA,CS_N,CKE,RAS_N,CAS_N,WE_N,DQ,DQM,SDR_CLK);
//	Host Side
input	[21:0]	iHS_ADDR;
input	[15:0]	iHS_DATA;
input			iHS_RD;
input			iHS_WR;
output	[15:0]	oHS_DATA;
output			oHS_Done;
//	Async Side 1
input	[21:0]	iAS1_ADDR;
input	[15:0]	iAS1_DATA;
input			iAS1_WR_n;
output	[15:0]	oAS1_DATA;
//	Async Side 2
input	[21:0]	iAS2_ADDR;
input	[15:0]	iAS2_DATA;
input			iAS2_WR_n;
output	[15:0]	oAS2_DATA;
//	Async Side 3
input	[21:0]	iAS3_ADDR;
input	[15:0]	iAS3_DATA;
input			iAS3_WR_n;
output	[15:0]	oAS3_DATA;
//	Control Signals
input	[1:0]	iSelect;
input			iCLK;
input			iRST_n;
//	SDRAM Interface
output	[11:0]	SA;
output	[1:0]	BA;
output			CS_N;
output			CKE;
output			RAS_N;
output			CAS_N;
output			WE_N;
inout	[15:0]	DQ;
output	[1:0]	DQM;
output			SDR_CLK;
//	Internal SDRAM Link
wire	[21:0]	mSDR_ADDR;
wire	[15:0]	mM2C_DATA;
wire	[15:0]	mC2M_DATA;
wire			mSDR_RD;
wire			mSDR_WR;
wire			mSDR_Done;

Sdram_Multiplexer	u0	(	//	Host Side
							oHS_DATA,iHS_DATA,iHS_ADDR,iHS_RD,iHS_WR,oHS_Done,
							//	Async Side 1
							oAS1_DATA,iAS1_DATA,iAS1_ADDR,iAS1_WR_n,
							//	Async Side 2
							oAS2_DATA,iAS2_DATA,iAS2_ADDR,iAS2_WR_n,
							//	Async Side 3
							oAS3_DATA,iAS3_DATA,iAS3_ADDR,iAS3_WR_n,
							//	SDRAM Side
							mM2C_DATA,mC2M_DATA,mSDR_ADDR,mSDR_RD,mSDR_WR,mSDR_Done,
							//	Control Signals
							iSelect,iCLK,iRST_n	);

Sdram_Controller	u1	(	//	HOST
        					.REF_CLK(iCLK),.RESET_N(iRST_n),
							.ADDR({1'b0,mSDR_ADDR}),
							.WR(mSDR_WR),.RD(mSDR_RD),.DONE(mSDR_Done),
       						.DATAIN(mM2C_DATA),.DATAOUT(mC2M_DATA),
							.IN_REQ(),.OUT_VALID(),.DM(2'b00),
							.LENGTH(8'h01),
							//	SDRAM
        					.SA(SA),
        					.BA(BA),
        					.CS_N(CS_N),
        					.CKE(CKE),
        					.RAS_N(RAS_N),
        					.CAS_N(CAS_N),
        					.WE_N(WE_N),
        					.DQ(DQ),
        					.DQM(DQM),
							.SDR_CLK(SDR_CLK)
       						);

endmodule