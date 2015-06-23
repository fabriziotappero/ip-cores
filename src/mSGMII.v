/*
Copyright � 2012 JeffLieu-jefflieu@fpga-ipcores.com

	This file is part of SGMII-IP-Core.
    SGMII-IP-Core is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SGMII-IP-Core is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with SGMII-IP-Core.  If not, see <http://www.gnu.org/licenses/>.

File		:
Description	:
	This core implements:
	B1000-X Standard
	PCS/PMA of SGMII MAC Side
Remarks		:
Revision	:
	Date	Author		Description
02/09/12	Jefflieu
*/

`timescale 1ns/10ps
`include "SGMIIDefs.v"

module mSGMII 
(
	//Tranceiver Interface
	input	i_SerRx,
	output	o_SerTx,
	input	i_CalClk,
	input	i_RefClk125M,
	input	i_ARstHardware_L,

	//Local BUS interface
	//Wishbonebus, single transaction mode (non-pipeline slave)
	input	i_Cyc,
	input	i_Stb,
	input	i_WEn,
	input	[31:00] 	i32_WrData,
	input	[07:00]		iv_Addr,
	output	[31:00]		o32_RdData,
	output	o_Ack,
	
	input	i_Mdc,
	inout	io_Mdio,
	
	output	o_Linkup,
	output	o_ANDone,
	//This is used in Phy-Side SGMII 
	input 	i_PhyLink,
	input	i_PhyDuplex,
	input 	[1:0] i2_PhySpeed,	
	
	
	output	[1:0] o2_SGMIISpeed,
	output	o_SGMIIDuplex,
	
	//GMII Interface
	output 	o_TxClk,
	output 	o_RxClk,
	input	[07:00] i8_TxD,
	input	i_TxEN,
	input	i_TxER,
	output	[07:00] o8_RxD,
	output	o_RxDV,
	output	o_RxER,
	output	o_GMIIClk,
	output	o_MIIClk,
	output	o_Col,
	output	o_Crs);
	
	wire 	w_ClkTx,w_ClkRx;	
	wire 	w_ClkSys;
	wire	w_Loopback;
	reg		r_RestartAN;
	wire	w_ANEnable;
	wire	[15:00] w16_Status;
	wire 	w_MIIRst_L;
	wire	w_ANComplete;
	
	wire 	[07:00] w8_RxCG_SyncToRxver;
	wire	w_RxCGInv_SyncToRxver;
	wire	w_RxCGCtrl_SyncToRxver;
	wire	w_SyncStatus,w_RxEven,w_IsComma,w_OSValid;
	wire	w_IsI1Set,w_IsI2Set,w_IsC1Set,w_IsC2Set,w_IsTSet,w_IsVSet,w_IsSSet,w_IsRSet;
	
	wire	w_Receiving;
	wire	w_Transmitting;
	wire	w_CheckEndKDK,w_CheckEndKD21_5D0_0,w_CheckEndKD2_2D0_0,w_CheckEndTRK,w_CheckEndTRR,w_CheckEndRRR,w_CheckEndRRK,w_CheckEndRRS;
	reg		r_CheckEndKDK,r_CheckEndKD21_5D0_0,r_CheckEndKD2_2D0_0,r_CheckEndTRK,r_CheckEndTRR,r_CheckEndRRR,r_CheckEndRRK,r_CheckEndRRS;
	
	wire	[2:0] w3_XmitState;
	wire	[16:01] w16_TxConfigReg;
	wire 	[15:00] w16_RxConfigReg;
	wire	[15:00] w16_LcAdvAbility;
	wire	[15:00] w16_LpAdvAbility;
	wire	w_RUDIConfig;
	wire	w_RUDIIdle;
	wire	w_RUDIInvalid;
	wire	w_ARstLogic_L;
	wire 	w_MIIReset_L;
	wire	w_ANRestart;
	//This delay stage is for the function checkend
	reg	[07:00]	r8_RxCodeGroup[0:2];
	reg 	r_RxCgInvalid[0:2];
	reg 	r_RxCgCtrl[0:2];
	wire  	[2:0] w3_PreCheckIsSSet;
	wire  	[2:0] w3_PreCheckIsTSet;
	wire  	[2:0] w3_PreCheckIsRSet;
	wire	[2:0] w3_PreCheckIsComma;
	wire 	[2:0] w3_PreCheckIsD21_5;
	wire	[2:0] w3_PreCheckIsD2_2;
	wire	[2:0] w3_PreCheckIsD;
	wire	[2:0] w3_PreCheckIsD0_0;
	wire 	w_GxBPowerDown;
	wire	w_TxCodeCtrl, w_TxCodeValid, w_RxCodeInvalid, w_RxCodeCtrl;
	wire 	[07:00] w8_TxCode, w8_RxCode;
	wire	w_SignalDetect;
	wire	w_TxForceNegDisp;
	wire	w_PllLocked;
	wire	[20:00] w21_LinkTimer;
	wire 	w_TxEN,w_TxER,w_RxER, w_RxDV;
	wire	[07:00] w8_RxD, w8_TxD;
	wire 	w_BitSlip;
	wire 	w_Invalid;//Not Used
	wire 	w_TxEven;//Not Used
	wire 	w_CurrentParity;
	
	//MII Clock Gen
	reg [6:0] 	r7_Cntr;
	reg r_MIIClk;
	reg r_MIIClk_D;
	wire w_SamplingClk;
	
	integer DELAY;
	
	assign o_Linkup = w_SyncStatus;
	assign o_ANDone = w_ANComplete;
	assign o_TxClk = w_ClkTx;
	assign o_RxClk = w_ClkRx;
	
	mRateAdapter	u0RateAdapter(
	//MAC Side signal
	.i_TxClk		(o_MIIClk),	
	.i_TxEN			(i_TxEN	),
	.i_TxER			(i_TxER	),	
	.i8_TxD			(i8_TxD	),			
	.i_RxClk		(o_MIIClk),
	.o_RxEN			(o_RxDV),
	.o_RxER			(o_RxER),
	.o8_RxD			(o8_RxD),
	.i2_Speed		(o2_SGMIISpeed),
	//SGMII PHY side
	.i_SamplingClk	(w_SamplingClk),
	.i_GClk			(w_ClkSys),
	.o_TxEN			(w_TxEN),
	.o_TxER			(w_TxER),
	.o8_TxD			(w8_TxD),
	.i_RxEN			(w_RxDV),
	.i_RxER			(w_RxER),
	.i8_RxD			(w8_RxD));
	
	generate
		genvar STAGE;
		for(STAGE=0;STAGE<3;STAGE=STAGE+1)
		begin:PreCheck
			assign w3_PreCheckIsComma[STAGE] 	= (r_RxCgInvalid[STAGE]==1'b0 && r_RxCgCtrl[STAGE]==1'b1 && r8_RxCodeGroup[STAGE]==`K28_5)?1'b1:1'b0;			
			assign w3_PreCheckIsTSet[STAGE] 	= (r_RxCgInvalid[STAGE]==1'b0 && r_RxCgCtrl[STAGE]==1'b1 && r8_RxCodeGroup[STAGE]==`K29_7)?1'b1:1'b0;
			assign w3_PreCheckIsRSet[STAGE] 	= (r_RxCgInvalid[STAGE]==1'b0 && r_RxCgCtrl[STAGE]==1'b1 && r8_RxCodeGroup[STAGE]==`K23_7)?1'b1:1'b0;
			assign w3_PreCheckIsD21_5[STAGE] 	= (r_RxCgInvalid[STAGE]==1'b0 && r_RxCgCtrl[STAGE]==1'b0 && r8_RxCodeGroup[STAGE]==`D21_5)?1'b1:1'b0;
			assign w3_PreCheckIsD2_2[STAGE] 	= (r_RxCgInvalid[STAGE]==1'b0 && r_RxCgCtrl[STAGE]==1'b0 && r8_RxCodeGroup[STAGE]==`D2_2)?1'b1:1'b0;
			assign w3_PreCheckIsD[STAGE]		= (r_RxCgInvalid[STAGE]==1'b0 && r_RxCgCtrl[STAGE]==1'b0)?1'b1:1'b0;
			assign w3_PreCheckIsD0_0[STAGE] 	= (r_RxCgInvalid[STAGE]==1'b0 && r_RxCgCtrl[STAGE]==1'b0 && r8_RxCodeGroup[STAGE]==`D0_0)?1'b1:1'b0;
			assign w3_PreCheckIsSSet[STAGE]		= (r_RxCgInvalid[STAGE]==1'b0 && r_RxCgCtrl[STAGE]==1'b1 && r8_RxCodeGroup[STAGE]==`K27_7)?1'b1:1'b0;
		end
	endgenerate
	
	assign w_CheckEndKDK 		= w3_PreCheckIsComma[2] & w3_PreCheckIsD[1]&w3_PreCheckIsComma[0];
	assign w_CheckEndRRR 		= &(w3_PreCheckIsRSet);
	assign w_CheckEndTRK 		= w3_PreCheckIsTSet[2] & w3_PreCheckIsRSet[1] & w3_PreCheckIsComma[0];
	assign w_CheckEndTRR 		= w3_PreCheckIsTSet[2] & w3_PreCheckIsRSet[1] & w3_PreCheckIsRSet[0];
	assign w_CheckEndKD21_5D0_0	= w3_PreCheckIsComma[2] & w3_PreCheckIsD21_5[1] & w3_PreCheckIsD2_2[0];
	assign w_CheckEndKD2_2D0_0 	= w3_PreCheckIsComma[2] & w3_PreCheckIsD2_2[1] & w3_PreCheckIsD2_2[0];
	assign w_CheckEndRRK		= w3_PreCheckIsRSet[2] & w3_PreCheckIsRSet[1] & w3_PreCheckIsComma[0];
	assign w_CheckEndRRS		= w3_PreCheckIsRSet[2] & w3_PreCheckIsRSet[1] & w3_PreCheckIsSSet[0];
	
	always@(posedge w_ClkRx)
		begin
			r8_RxCodeGroup[0] 	<= w8_RxCode;
			r_RxCgCtrl[0] 		<= w_RxCodeCtrl;
			r_RxCgInvalid[0] 	<= w_RxCodeInvalid;
			for(DELAY=1;DELAY<3;DELAY=DELAY+1)
				begin
				r8_RxCodeGroup[DELAY] 	<= r8_RxCodeGroup[DELAY-1];
				r_RxCgInvalid[DELAY] 	<= r_RxCgInvalid[DELAY-1];
				r_RxCgCtrl[DELAY]		<= r_RxCgCtrl[DELAY-1];				
				end			
		end
		
	assign o_Col = w_Transmitting & w_Receiving;
	assign o_Crs = 1'b0;
	assign w_ARstLogic_L 	= w_PllLocked & i_ARstHardware_L & (w_MIIRst_L);
	mRegisters	u0Registers(
	.w_ARstLogic_L	(w_ARstLogic_L),
	.i_Clk			(w_ClkSys),
	.i_Cyc			(i_Cyc),
	.i_Stb			(i_Stb),
	.i_WEn			(i_WEn),
	.i8_Addr		(iv_Addr),
	.i32_WrData		(i32_WrData),
	.o32_RdData		(o32_RdData),
	.o_Ack			(o_Ack),
	.o_Stall		(),
	
	.io_Mdio		(io_Mdio),
	.i_Mdc			(i_Mdc),
	
	//Register in and out,
	
	//MAC-Side SGMII
	.o2_SGMIISpeed		(o2_SGMIISpeed),
	.o_SGMIIDuplex		(o_SGMIIDuplex),
	
	//Phy-Side SGMII
	.i_PhyLink			(i_PhyLink	),
	.i_PhyDuplex		(i_PhyDuplex),
	.i2_PhySpeed		(i2_PhySpeed),
	.o21_LinkTimer		(w21_LinkTimer),
	
	.i16_TxConfigReg	(w16_TxConfigReg),
	.o_MIIRst_L			(w_MIIRst_L),
	.o_ANEnable			(w_ANEnable),
	.o_ANRestart		(w_ANRestart),
	.o_Loopback			(w_Loopback),
	.o_GXBPowerDown		(w_GxBPowerDown),
	.o16_LcAdvAbility	(w16_LcAdvAbility),
	.i3_XmitState		(w3_XmitState),
	.i_SyncStatus		(w_SyncStatus),	
	.i_ANComplete		(w_ANComplete),
	.i16_LpAdvAbility	(w16_LpAdvAbility));
	
	 mSyncCtrl u0SyncCtrl(
	.i_Clk				(w_ClkRx		),
	.i_Cke				((~w_GxBPowerDown)	),
	.i_ARst_L			(w_ARstLogic_L	),
	.i_CtrlLoopBack		(w_Loopback		),
    
	.i8_RxCodeGroupIn	(r8_RxCodeGroup[2]	),
	.i_RxCodeInvalid	(r_RxCgInvalid[2]	),
	.i_RxCodeCtrl		(r_RxCgCtrl[2]		),
	.i_SignalDetect		(w_SignalDetect		),
	
	.o8_RxCodeGroupOut	(w8_RxCG_SyncToRxver	),	
	.o_RxCodeInvalid	(w_RxCGInv_SyncToRxver	),
	.o_RxCodeCtrl		(w_RxCGCtrl_SyncToRxver	),
	.o_RxEven			(w_RxEven				),
	.o_SyncStatus		(w_SyncStatus			),	
	.o_BitSlip			(w_BitSlip),
	.o_IsComma			(w_IsComma	),
	.o_OrderedSetValid	(w_OSValid	),
	.o_IsI1Set			(w_IsI1Set	),
	.o_IsI2Set			(w_IsI2Set	),
	.o_IsC1Set			(w_IsC1Set	),
	.o_IsC2Set			(w_IsC2Set	),
	.o_IsTSet			(w_IsTSet	),
	.o_IsVSet			(w_IsVSet	),
	.o_IsSSet			(w_IsSSet	),
	.o_IsRSet			(w_IsRSet	));
	
	always@(posedge w_ClkRx)
	begin
	r_CheckEndKDK			<= w_CheckEndKDK;
	r_CheckEndKD21_5D0_0	<= w_CheckEndKD21_5D0_0;
	r_CheckEndKD2_2D0_0	    <= w_CheckEndKD2_2D0_0;
	r_CheckEndTRK			<= w_CheckEndTRK;
	r_CheckEndTRR			<= w_CheckEndTRR;
	r_CheckEndRRR			<= w_CheckEndRRR;	   
	r_CheckEndRRK			<= w_CheckEndRRK;
	r_CheckEndRRS			<= w_CheckEndRRS;
	end
	
	mReceive	u0Receive(
	.i8_RxCodeGroupIn		(w8_RxCG_SyncToRxver	),
	.i_RxCodeInvalid       	(w_RxCGInv_SyncToRxver	),
	.i_RxCodeCtrl          	(w_RxCGCtrl_SyncToRxver	),
	.i_RxEven 	         	(w_RxEven				),
	
	.i3_Xmit				(w3_XmitState),
	
	.i_IsComma				(w_IsComma	),
	.i_OrderedSetValid      (w_OSValid	),
	.i_IsI1Set              (w_IsI1Set	),
	.i_IsI2Set              (w_IsI2Set	),
	.i_IsC1Set              (w_IsC1Set	),
	.i_IsC2Set              (w_IsC2Set	),
	.i_IsTSet               (w_IsTSet	),
	.i_IsVSet               (w_IsVSet	),
	.i_IsSSet               (w_IsSSet	),
	.i_IsRSet               (w_IsRSet	),
	
	.i_CheckEndKDK			(r_CheckEndKDK			),
	.i_CheckEndKD21_5D0_0	(r_CheckEndKD21_5D0_0	),
	.i_CheckEndKD2_2D0_0	(r_CheckEndKD2_2D0_0	),
	.i_CheckEndTRK			(r_CheckEndTRK			),
	.i_CheckEndTRR			(r_CheckEndTRR			),
	.i_CheckEndRRR			(r_CheckEndRRR			),
	.i_CheckEndRRK			(r_CheckEndRRK			),
	.i_CheckEndRRS			(r_CheckEndRRS			),
	
	.o16_RxConfigReg	(w16_RxConfigReg),
	.o_RUDIConfig		(w_RUDIConfig),
	.o_RUDIIdle			(w_RUDIIdle),
	.o_RUDIInvalid		(w_RUDIInvalid),
		
	.o_RxDV				(w_RxDV	),
	.o_RxER				(w_RxER	),
	.o8_RxD				(w8_RxD	),
	.o_Invalid			(w_Invalid),
	.o_Receiving		(w_Receiving),
	.i_Clk				(w_ClkRx),
	.i_ARst_L			(w_ARstLogic_L));
	
	mANCtrl	u0ANCtrl(
	.i_Clk				(w_ClkRx			),
	.i_ARst_L			(w_ARstLogic_L		),
	.i_Cke				((~w_GxBPowerDown)		),
	.i_RestartAN		(w_ANRestart		),
	.i_SyncStatus		(w_SyncStatus		),
	.i_ANEnable			(w_ANEnable			),
	.i21_LinkTimer		(w21_LinkTimer		),
	.i16_LcAdvAbility	(w16_LcAdvAbility	),
	.o16_LpAdvAbility	(w16_LpAdvAbility	),
	.o_ANComplete		(w_ANComplete		),
	.i16_RxConfigReg	(w16_RxConfigReg	),
	.i_RUDIConfig		(w_RUDIConfig		),
	.i_RUDIIdle			(w_RUDIIdle			),
	.i_RUDIInvalid		(w_RUDIInvalid		),	
	.o3_Xmit			(w3_XmitState		),
	.o16_TxConfigReg	(w16_TxConfigReg	));
	
	mTransmit	u0Transmit(
	.i3_Xmit			(w3_XmitState		),
	.i16_ConfigReg		(w16_TxConfigReg	),
		
	.i_TxEN				(w_TxEN				),	
	.i_TxER				(w_TxER				),
	.i8_TxD				(w8_TxD				),
		
		
	.o_Xmitting			(w_Transmitting		),	
	.o_TxEven			(w_TxEven			),
	.o8_TxCodeGroupOut	(w8_TxCode			),
	.o_TxCodeValid		(w_TxCodeValid		),
	.o_TxCodeCtrl		(w_TxCodeCtrl		),
	.i_CurrentParity	(w_CurrentParity	),
	
	.i_Clk				(w_ClkTx			),
	.i_ARst_L			(w_ARstLogic_L		));
	
	assign w_SignalDetect=~w_RxCodeInvalid;
	
	/*mXcver #(.pXcverName("AltArriaV"))u0Xcver(

	.i_SerRx			(i_SerRx			),
	.o_SerTx			(o_SerTx			),
		
	.i_RefClk125M		(i_RefClk125M		),
	.o_TxClk			(w_ClkSys			),
	.i_CalClk			(i_RefClk125M		),
	.i_GxBPwrDwn		(w_GxBPowerDown		),
	.i_XcverDigitalRst	(~w_ARstLogic_L		),	
	.o_PllLocked		(w_PllLocked		),
	
	.o_SignalDetect		(),
	.o8_RxCodeGroup		(w8_RxCode			),
	.o_RxCodeInvalid	(w_RxCodeInvalid	),
	.o_RxCodeCtrl		(w_RxCodeCtrl		),
	
	.i8_TxCodeGroup		(w8_TxCode			),
	.i_TxCodeValid		(w_TxCodeValid		),
	.i_TxCodeCtrl		(w_TxCodeCtrl		),
	.i_TxForceNegDisp	(w_TxForceNegDisp	),
	.o_RunningDisparity	(w_CurrentParity));*/
	
	
	mAltA5GXlvds u0Xcverlvds(
	.i_SerRx			(i_SerRx			),
	.o_SerTx			(o_SerTx			),
		
	.i_RefClk125M		(i_RefClk125M		),
	.o_TxClk			(w_ClkTx			),
	.o_RxClk			(w_ClkRx			),
	.i_GxBPwrDwn		(w_GxBPowerDown		),
	.i_XcverDigitalRst	(~i_ARstHardware_L	),	
	.o_PllLocked		(w_PllLocked		),
	.i_RxBitSlip		(w_BitSlip			),
	
	.o_SignalDetect		(),
	.o8_RxCodeGroup		(w8_RxCode			),
	.o_RxCodeInvalid	(w_RxCodeInvalid	),
	.o_RxCodeCtrl		(w_RxCodeCtrl		),
	
	.i8_TxCodeGroup		(w8_TxCode			),
	.i_TxCodeValid		(w_TxCodeValid		),
	.i_TxCodeCtrl		(w_TxCodeCtrl		),
	.i_TxForceNegDisp	(1'b0	),
	.o_RunningDisparity	(w_CurrentParity));
	
	assign w_ClkSys	 = w_ClkTx;
	assign o_GMIIClk = w_ClkSys;
	
	always@(posedge w_ClkSys or negedge i_ARstHardware_L )
	if(~i_ARstHardware_L)
	begin
		r7_Cntr 	<= 7'h0;
		r_MIIClk 	<= 1'b0;	
	end else		
	begin
		if(o2_SGMIISpeed==2'b01)
			begin
			if(r7_Cntr==7'h4) r7_Cntr<=7'h0; else r7_Cntr<=r7_Cntr+7'h1;
			if(r7_Cntr==7'h4) r_MIIClk<=1'b1; else if(r7_Cntr==7'h1) r_MIIClk<=1'b0;
			end
		else if(o2_SGMIISpeed==2'b00)
			begin
			if(r7_Cntr==7'h49) r7_Cntr<=7'h0; else r7_Cntr<=r7_Cntr+7'h1;
			if(r7_Cntr==7'h49) r_MIIClk<=1'b1; else if(r7_Cntr==7'h24) r_MIIClk<=1'b0;
			end		
		r_MIIClk_D <= r_MIIClk;
	end
	assign w_SamplingClk = (r_MIIClk_D & (~r_MIIClk));
		
	//Insert Clock Buffer or PLL if necessary
	mClkBuf u0ClkBuf(.i_Clk(r_MIIClk),.o_Clk(o_MIIClk));

endmodule





