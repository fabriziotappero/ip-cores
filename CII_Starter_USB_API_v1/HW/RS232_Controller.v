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

module RS232_Controller(oDATA,iDATA,oTxD,oTxD_Busy,iTxD_Start,
						iRxD,oRxD_Ready,iCLK);
input [7:0] iDATA;
input iTxD_Start,iRxD,iCLK;
output [7:0] oDATA;
output oTxD,oTxD_Busy,oRxD_Ready;

async_receiver		u0	(	.clk(iCLK), .RxD(iRxD),
							.RxD_data_ready(oRxD_Ready),
						 	.RxD_data(oDATA));
async_transmitter	u1	(	.clk(iCLK), .TxD_start(iTxD_Start),
							.TxD_data(iDATA), .TxD(oTxD),
							.TxD_busy(oTxD_Busy));
							
endmodule