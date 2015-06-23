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

module	Multi_Sram(	//	Host Side
					oHS_DATA,iHS_DATA,iHS_ADDR,iHS_WE_N,iHS_OE_N,
					//	Async Side 1
					oAS1_DATA,iAS1_DATA,iAS1_ADDR,iAS1_WE_N,iAS1_OE_N,
					//	Async Side 2
					oAS2_DATA,iAS2_DATA,iAS2_ADDR,iAS2_WE_N,iAS2_OE_N,
					//	Async Side 3
					oAS3_DATA,iAS3_DATA,iAS3_ADDR,iAS3_WE_N,iAS3_OE_N,
					//	Control Signals
					iSelect,iRST_n,
					//	SRAM
					SRAM_DQ,
					SRAM_ADDR,
					SRAM_UB_N,
					SRAM_LB_N,
					SRAM_WE_N,
					SRAM_CE_N,
					SRAM_OE_N	);

//	Host Side
input	[17:0]	iHS_ADDR;
input	[15:0]	iHS_DATA;
output	[15:0]	oHS_DATA;
input			iHS_WE_N;
input			iHS_OE_N;
//	Async Side 1
input	[17:0]	iAS1_ADDR;
input	[15:0]	iAS1_DATA;
output	[15:0]	oAS1_DATA;
input			iAS1_WE_N;
input			iAS1_OE_N;
//	Async Side 2
input	[17:0]	iAS2_ADDR;
input	[15:0]	iAS2_DATA;
output	[15:0]	oAS2_DATA;
input			iAS2_WE_N;
input			iAS2_OE_N;
//	Async Side 3
input	[17:0]	iAS3_ADDR;
input	[15:0]	iAS3_DATA;
output	[15:0]	oAS3_DATA;
input			iAS3_WE_N;
input			iAS3_OE_N;
//	Control Signals
input	[1:0]	iSelect;
input			iRST_n;
//	SRAM Side
inout	[15:0]	SRAM_DQ;
output	[17:0]	SRAM_ADDR;
output			SRAM_UB_N,
				SRAM_LB_N,
				SRAM_WE_N,
				SRAM_CE_N,
				SRAM_OE_N;

assign	SRAM_DQ 	=	SRAM_WE_N 	 ?	16'hzzzz  :
						(iSelect==0) ? 	iHS_DATA  :
						(iSelect==1) ? 	iAS1_DATA :
						(iSelect==2) ? 	iAS2_DATA :
									  	iAS3_DATA ;

assign	oHS_DATA	=	(iSelect==0) ?  SRAM_DQ : 16'h0000 ; 			
assign	oAS1_DATA	=	(iSelect==1) ?  SRAM_DQ : 16'h0000 ; 			
assign	oAS2_DATA	=	(iSelect==2) ?  SRAM_DQ : 16'h0000 ; 			
assign	oAS3_DATA	=	(iSelect==3) ?  SRAM_DQ : 16'h0000 ;
	
assign	SRAM_ADDR	=	(iSelect==0) ?	iHS_ADDR	:
						(iSelect==1) ?	iAS1_ADDR	:
						(iSelect==2) ?	iAS2_ADDR	:
										iAS3_ADDR	;

assign	SRAM_WE_N	=	(iSelect==0) ?	iHS_WE_N	:
						(iSelect==1) ?	iAS1_WE_N	:
						(iSelect==2) ?	iAS2_WE_N	:
										iAS3_WE_N	;

assign	SRAM_OE_N	=	(iSelect==0) ?	iHS_OE_N	:
						(iSelect==1) ?	iAS1_OE_N	:
						(iSelect==2) ?	iAS2_OE_N	:
										iAS3_OE_N	;

assign	SRAM_CE_N	=	1'b0;
assign	SRAM_UB_N	=	1'b0;
assign	SRAM_LB_N	=	1'b0;

endmodule