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

module	SRAM_16Bit_512K(//	Host Data
						oDATA,iDATA,iADDR,
						iWE_N,iOE_N,
						iCE_N,
						iUB_N,iLB_N,
						//	SRAM
						SRAM_DQ,
						SRAM_ADDR,
						SRAM_UB_N,
						SRAM_LB_N,
						SRAM_WE_N,
						SRAM_CE_N,
						SRAM_OE_N
						);
//	Host Side
input	[15:0]	iDATA;
output	[15:0]	oDATA;
input	[17:0]	iADDR;
input			iWE_N,iOE_N;
input			iCE_N;
input			iUB_N,iLB_N;
//	SRAM Side
inout	[15:0]	SRAM_DQ;
output	[17:0]	SRAM_ADDR;
output			SRAM_UB_N,
				SRAM_LB_N,
				SRAM_WE_N,
				SRAM_CE_N,
				SRAM_OE_N;

assign	SRAM_DQ 	=	SRAM_WE_N ? 16'hzzzz : iDATA;
assign	oDATA		=	SRAM_DQ;
assign	SRAM_ADDR	=	iADDR;
assign	SRAM_WE_N	=	iWE_N;
assign	SRAM_OE_N	=	iOE_N;
assign	SRAM_CE_N	=	iCE_N;
assign	SRAM_UB_N	=	SRAM_UB_N;
assign	SRAM_LB_N	=	SRAM_LB_N;

endmodule