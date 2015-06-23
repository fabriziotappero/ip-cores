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

module Multi_Flash(	//	Host Side
					oHS_DATA,iHS_DATA,iHS_ADDR,iHS_CMD,oHS_Ready,iHS_Start,
					//	Async Side 1
					oAS1_DATA,iAS1_ADDR,
					//	Async Side 2
					oAS2_DATA,iAS2_ADDR,
					//	Async Side 3
					oAS3_DATA,iAS3_ADDR,
					//	Control Signals
					iSelect,iCLK,iRST_n,
					//	Flash Interface
					FL_DQ,FL_ADDR,FL_WE_n,FL_CE_n,FL_OE_n,FL_RST_n);
//	Host Side
input	[21:0]	iHS_ADDR;	
input	[7:0]	iHS_DATA;
input	[2:0]	iHS_CMD;
input			iHS_Start;
output	[7:0]	oHS_DATA;
output			oHS_Ready;
//	Async Side 1
input	[21:0]	iAS1_ADDR;
output	[7:0]	oAS1_DATA;
//	Async Side 2
input	[21:0]	iAS2_ADDR;
output	[7:0]	oAS2_DATA;
//	Async Side 3
input	[21:0]	iAS3_ADDR;
output	[7:0]	oAS3_DATA;
//	Control	Signals
input	[1:0]	iSelect;
input			iCLK;
input			iRST_n;
//	Flash Interface	
output	[21:0]	FL_ADDR;
inout	[7:0]	FL_DQ;
output			FL_OE_n;
output			FL_CE_n;
output			FL_WE_n;
output			FL_RST_n;
//	Internal Flash Link
wire	[7:0]	mM2C_FL_DATA;
wire	[7:0]	mC2M_FL_DATA;
wire			mFL_Ready;
wire	[21:0]	mFL_ADDR;
wire	[2:0]	mFL_CMD;
wire			mFL_Start;


Flash_Multiplexer	u0	(	//	Host Side
							oHS_DATA,iHS_DATA,iHS_ADDR,iHS_CMD,oHS_Ready,iHS_Start,
							//	Async Side 1
							oAS1_DATA,iAS1_ADDR,
							//	Async Side 2
							oAS2_DATA,iAS2_ADDR,
							//	Async Side 3
							oAS3_DATA,iAS3_ADDR,
							//	Flash Side
							mM2C_FL_DATA,mC2M_FL_DATA,mFL_ADDR,mFL_CMD,mFL_Ready,mFL_Start,
							//	Control Signals
							iSelect,iCLK,iRST_n);

Flash_Controller	u1	(	//	Control Interface
							mC2M_FL_DATA,mM2C_FL_DATA,mFL_ADDR,mFL_CMD,
							mFL_Ready,mFL_Start,iCLK,iRST_n,
							//	Flash Interface
							FL_DQ,FL_ADDR,FL_WE_n,FL_CE_n,FL_OE_n,FL_RST_n);

endmodule