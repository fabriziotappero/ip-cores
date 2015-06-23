module RS232_Controller(oDATA,iDATA,oTxD,oTxD_Busy,iTxD_Start,
						iRxD,oRxD_Ready,oRxD_ERROR,oRxD_idle,iCLK,RST_n);
input [7:0] iDATA;
input iTxD_Start,iRxD,iCLK,RST_n;
output [7:0] oDATA;
output oTxD,oTxD_Busy,oRxD_Ready,oRxD_ERROR,oRxD_idle;

async_receiver		u0	(	/*.RST_n(RST_n),*/.clk(iCLK), .RxD(iRxD),
							.RxD_data_ready(oRxD_Ready),/*.RxD_data_error(oRxD_ERROR),*/
						 	.RxD_data(oDATA),.RxD_idle(oRxD_idle));
//serie					u0	(	.n_reset(RST_n),.clk(iCLK), .rx_in(iRxD),
//							.d_rdy(oRxD_Ready),.d_err(oRxD_ERROR),
//						 	.rx_data(oDATA));
async_transmitter	u1	(	/*.RST_n(RST_n),*/.clk(iCLK), .TxD_start(iTxD_Start),
							.TxD_data(iDATA), .TxD(oTxD),
							.TxD_busy(oTxD_Busy));
							
endmodule
