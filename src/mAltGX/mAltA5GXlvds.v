

module mAltA5GXlvds (
	input 	i_SerRx,			
	output 	o_SerTx,			
	
	input 	i_RefClk125M,
	output 	o_RxClk,	
	output 	o_TxClk,	
	input 	i_GxBPwrDwn,
	input 	i_XcverDigitalRst,
    output 	o_PllLocked,
	
	output o_SignalDetect,		
	output [7:0] o8_RxCodeGroup,
	output 	o_RxCodeInvalid,	
	output 	o_RxCodeCtrl,		
	input 	i_RxBitSlip,
	
	input [7:0] i8_TxCodeGroup,
	input 	i_TxCodeValid,		
	input 	i_TxCodeCtrl,		
	input 	i_TxForceNegDisp,	
    output 	o_RunningDisparity);
	
	wire [9:0]	w10_txdata;
	wire [9:0]	w10_rxdata;
	wire [9:0] 	w10_txdatalocal;
	wire [9:0] 	w10_rxdatalocal;
	wire w_RxKErr,w_RxRdErr;
	wire w_TxClk,w_RxClk;
	wire w_BitSlip;
	
	
	mEnc8b10bMem u8b10bEnc(
	.i8_Din				(i8_TxCodeGroup),		//HGFEDCBA
	.i_Kin				(i_TxCodeCtrl),
	.i_ForceDisparity	(i_TxForceNegDisp),
	.i_Disparity		(~i_TxForceNegDisp),	//1 is positive, 0 is negative
	.o10_Dout			(w10_txdata),			//abcdeifghj
	.o_Rd				(o_RunningDisparity),
	.o_KErr				(),
	.i_Clk				(w_TxClk),
	.i_ARst_L			(~i_XcverDigitalRst));	
	
	mDec8b10bMem u8b10bDec(
	.o8_Dout			(o8_RxCodeGroup),		//HGFEDCBA
	.o_Kout				(o_RxCodeCtrl),
	.o_DErr				(),
	.o_KErr				(w_RxKErr),
	.o_DpErr			(w_RxRdErr),
	.i_ForceDisparity 	(1'b0),
	.i_Disparity		(1'b0),		
	.i10_Din			(w10_rxdata),			//abcdeifghj
	.o_Rd				(),	
	.i_Clk				(w_RxClk),
	.i_ARst_L			(~i_XcverDigitalRst));
	
	assign o_RxCodeInvalid = w_RxKErr|w_RxRdErr;
	assign o_SignalDetect = (~o_RxCodeInvalid)|o_RxCodeCtrl;
	
	mAltArriaVlvdsRx ulvdsrx (
	.rx_cda_reset			(w_RxCdaReset),
	.rx_channel_data_align 	(i_RxBitSlip),
	.rx_in					(i_SerRx),
	.rx_inclock				(i_RefClk125M),
	.rx_out					(w10_rxdata),
	.rx_locked				(o_PllLocked),
	.rx_reset				(w_RxReset),
	.rx_divfwdclk			(w_RxClk));
	
	/////////////////////////////////////////////////
	//Hold In Reset Until Stable
	/////////////////////////////////////////////////
	reg [11:0] r12_LockCnt;
	always@(posedge w_RxClk or negedge o_PllLocked)
		if((~o_PllLocked))
			r12_LockCnt<=12'h0;
		else begin
			if(~(&r12_LockCnt))
				r12_LockCnt<=r12_LockCnt+12'h1;
		end
			
	assign w_RxReset 	= ~r12_LockCnt[11];
	assign w_RxCdaReset = (r12_LockCnt[11:10]==2'b11)?1'b0:1'b1;
	
	reg [9:0] r10_txdata;
	mAltArriaVlvdsTx ulvdstx(
	.tx_in			(r10_txdata),
	.tx_inclock		(w_TxSerClk),		
	.tx_enable		(w_TxEnClk),		
	.tx_out			(o_SerTx));
	
	mAltLvdsPll uAltTxPll(
		.refclk		(i_RefClk125M), // refclk.clk
		.rst		(w_PorRst),     // reset.reset
		.outclk_0	(w_TxSerClk),	// outclk0.clk
		.outclk_1	(w_TxEnClk), 	// outclk1.clk
		.outclk_2	(w_TxClk), 		// outclk2.clk
		.locked    	(w_TxLocked)	// locked.export
	);
	
	reg [9:0] r10_txdata0;
	always@(posedge w_TxClk)
		r10_txdata <= w10_txdata;	
	
	assign o_RxClk = w_RxClk;
	assign o_TxClk = w_TxClk;
	
	reg [7:0] r8_PorTmr;	
	assign w_PorRst = ~(&r8_PorTmr);
	always@(posedge i_RefClk125M)
	begin 
		if(w_PorRst)
			r8_PorTmr <= r8_PorTmr+8'h1;
	end	

endmodule 