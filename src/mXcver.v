/*
Developed By Subtleware Corporation Pte Ltd 2011
File		:
Description	:
Remarks		:
Revision	:
	Date	Author	Description
*/

module mXcver #(parameter pXcverName="AltCycIV") (

	input	i_SerRx,
	output	o_SerTx,
	
	input 	i_RefClk125M,
	output 	o_TxClk,
	input	i_CalClk,
	input	i_GxBPwrDwn,
	input	i_XcverDigitalRst,
	output	o_PllLocked,
	output	o_SignalDetect,
	output	[07:00] 	o8_RxCodeGroup,
	output	o_RxCodeInvalid,
	output	o_RxCodeCtrl,
	
	input	[07:00] 	i8_TxCodeGroup,
	input	i_TxCodeValid,
	input	i_TxCodeCtrl,
	input	i_TxForceNegDisp,
	output	o_RunningDisparity);



	generate 		
	if(pXcverName=="AltCycIV")		
		begin:AltCycIVXcver
		wire [04:00] w5_ReconfigFromGxb;
		wire [03:00] w4_ReconfigToGxb;
		wire w_Reconfiguring;
		mAltGX u0AltGX (
		.cal_blk_clk		(i_CalClk),
		.gxb_powerdown		(i_GxBPwrDwn),
		.pll_inclk			(i_RefClk125M),
		.reconfig_clk		(i_CalClk),
		.reconfig_togxb		(w4_ReconfigToGxb),
		.rx_analogreset		(1'b0),
		.pll_locked			(o_PllLocked),
		.reconfig_fromgxb	(w5_ReconfigFromGxb),
		
		.rx_digitalreset	(i_XcverDigitalRst),
		.rx_datain			(i_SerRx),
		.tx_dataout			(o_SerTx),
			
		.tx_ctrlenable		(i_TxCodeCtrl),
		.tx_datain			(i8_TxCodeGroup),
		.tx_digitalreset	(i_XcverDigitalRst),
			
		.rx_errdetect		(o_RxCodeInvalid),
		.rx_ctrldetect		(o_RxCodeCtrl),
		.rx_dataout			(o8_RxCodeGroup),	
		.rx_disperr			(),		
		.rx_patterndetect	(),
		.rx_rlv				(),
		.rx_syncstatus		(o_SignalDetect),
		.tx_clkout			(o_TxClk));
		
		assign o_RunningDisparity = 1'b0;
		
		  mAltGXReconfig u0AltGXReconfig(
			.reconfig_clk		(i_CalClk),
			.reconfig_fromgxb 	(w5_ReconfigFromGxb),
			.busy				(w_Reconfiguring),
			.reconfig_togxb		(w4_ReconfigToGxb));		
		end	
	endgenerate
	
	
	generate 		
	if(pXcverName=="AltArriaV")
		begin:AltArriaVXcver
		wire [091:00] w92_ReconfigFromGxb;
		wire [139:00] w140_ReconfigToGxb;
		wire w_Reconfiguring;		
		mAltAvgxXcver uAltXCver(
		.phy_mgmt_clk			(i_RefClk125M),         //       phy_mgmt_clk.clk
		.phy_mgmt_clk_reset		(1'b0),   		// phy_mgmt_clk_reset.reset
		.phy_mgmt_address		(8'h0),     //           phy_mgmt.address
		.phy_mgmt_read			(1'b0),        //                   .read
		.phy_mgmt_readdata		(),    //                   .readdata
		.phy_mgmt_waitrequest	(), //                   .waitrequest
		.phy_mgmt_write			(1'b0),       //                   .write
		.phy_mgmt_writedata		(32'h0),   //                   .writedata
		.tx_ready			(),             //           tx_ready.export
		.rx_ready			(),             //           rx_ready.export
		.pll_ref_clk		(i_RefClk125M),          //        pll_ref_clk.clk
		.tx_serial_data		(o_SerTx),       //     tx_serial_data.export
		.pll_locked			(o_PllLocked),           //         pll_locked.export
		.rx_serial_data		(i_SerRx),       //     rx_serial_data.export
		.rx_runningdisp		(o_RunningDisparity),       //     rx_runningdisp.export
		.rx_patterndetect	(w_PatternDtec),     //   rx_patterndetect.export
		.rx_disperr			(w_DispErr),           //         rx_disperr.export
		.rx_errdetect		(w_ErrDtec),         //       rx_errdetect.export
		.rx_syncstatus		(w_SyncStatus),        //      rx_syncstatus.export
		.tx_clkout			(o_TxClk),            //          tx_clkout.export
		.rx_clkout			(),            //          rx_clkout.export
		.tx_parallel_data	(i8_TxCodeGroup),     //   tx_parallel_data.export
		.tx_datak			(i_TxCodeCtrl),             //           tx_datak.export
		.rx_parallel_data	(o8_RxCodeGroup),     //   rx_parallel_data.export
		.rx_datak			(o_RxCodeCtrl),             //           rx_datak.export
		.reconfig_from_xcvr	(w92_ReconfigFromGxb),   // reconfig_from_xcvr.reconfig_from_xcvr
		.reconfig_to_xcvr   (w140_ReconfigToGxb)  //   reconfig_to_xcvr.reconfig_to_xcvr
	);	
		assign o_SignalDetect = ~(w_ErrDtec|w_DispErr);
		assign o_RxCodeInvalid = w_ErrDtec;
		
		mAltAvgxReconfig uReconfig(
		.reconfig_busy		(w_Reconfiguring),		// reconfig_busy.reconfig_busy
		.mgmt_clk_clk		(i_CalClk),              	// mgmt_clk_clk.clk
		.mgmt_rst_reset		(i_XcverDigitalRst),            		// mgmt_rst_reset.reset
		.reconfig_mgmt_address		(8'h0),     	// reconfig_mgmt.address
		.reconfig_mgmt_read			(1'b0),        	// .read
		.reconfig_mgmt_readdata		(),    			// .readdata
		.reconfig_mgmt_waitrequest	(), 			// .waitrequest
		.reconfig_mgmt_write		(1'b0),       	// .write
		.reconfig_mgmt_writedata	(32'h0),   		// .writedata
		.reconfig_to_xcvr			(w140_ReconfigToGxb),// reconfig_to_xcvr.reconfig_to_xcvr
		.reconfig_from_xcvr         (w92_ReconfigFromGxb)// reconfig_from_xcvr.reconfig_from_xcvr
	);
		  
		end	
	endgenerate

	
	
endmodule
