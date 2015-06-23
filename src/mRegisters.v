/*
Copyright © 2012 JeffLieu-lieumychuong@gmail.com

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
Remarks		:
Revision	:
	Date	Author		Description
02/09/12	Jefflieu
*/
`timescale 1ns/100ps
`include "SGMIIDefs.v"
module mRegisters(
	input w_ARstLogic_L,
	input i_Clk,
	input i_Cyc,
	input i_Stb,
	input i_WEn,
	input [07:00] i8_Addr,
	input [31:00] i32_WrData,
	output reg [31:00] o32_RdData,
	output reg o_Ack,
	output o_Stall,
	
	inout io_Mdio,
	input i_Mdc,
	
	//This is used in Phy-Side SGMII 
	input 	i_PhyLink,
	input	i_PhyDuplex,
	input 	[1:0] i2_PhySpeed,	
	
	//MAC-Side Speed,
	output	[01:00] o2_SGMIISpeed,
	//MAC-Side Duplex,
	output	o_SGMIIDuplex,
	
	
	//Register in and out,
	output  [20:00] o21_LinkTimer,
	
	input	[02:00] i3_XmitState,
	input	[15:00] i16_TxConfigReg,
	output o_MIIRst_L,
	output o_ANEnable,
	output o_ANRestart,
	output o_Loopback,
	output o_GXBPowerDown,
	output [15:00] o16_LcAdvAbility,
	input 	i_ANComplete,
	input	i_SyncStatus,		
	input [15:00] i16_LpAdvAbility);
	
	//TODO: Local BUs interface to setup registers
	//Register Write	
	wire	w_Write;
	reg 	r_Write;
	wire	w_WritePulse;
	wire	[04:00]	w5_Addr;
	wire	[15:00] w16_WrData;
	reg 	[15:00] r16_CtrlReg0;
	reg 	[15:00] r16_CtrlReg4;
	wire	[15:00]	w16_StatusReg1;
	reg		[15:00] r16_ModeReg;
	wire	[15:00] w16_LcAdvAbility;
	wire 	w_UseAsSGMII;
	reg 	r_Read;
	wire	w_Read;
	wire	w_ReadPulse;
	wire	w_SGMII_PHY;
	reg [20:00] r21_LinkTimer;
	reg [15:00] r16_ScratchRev;
	wire w_UseLcConfig;
	
	assign o21_LinkTimer = r21_LinkTimer;
	assign w5_Addr = i8_Addr[6:2];
	assign w16_WrData = i32_WrData[15:00];
	assign w_Write = (i_Cyc & i_Stb & i_WEn);
	assign w_WritePulse = w_Write & (~r_Write);	
	assign w_Read = (i_Cyc & i_Stb & (~i_WEn));
	assign w_ReadPulse = w_Read & (~r_Read);
	assign o_Stall = (w_Write|w_Read)&(~o_Ack);
	always@(posedge i_Clk or negedge w_ARstLogic_L)
	if(w_ARstLogic_L==1'b0)
		begin
			r16_CtrlReg4 <= `cReg4Default;
			r16_CtrlReg0 <= `cReg0Default;			
			r16_ModeReg  <= `cRegXDefault;
			r21_LinkTimer <= `cRegLinkTimerDefault;
			r16_ScratchRev <= 16'h1_0_00;
		end 
	else
	begin
		//Write Controller
		r_Write <= w_Write;
		o_Ack  <= w_WritePulse|w_ReadPulse;		
		//Control Register 0
		if(w_WritePulse && w5_Addr==5'b00000) r16_CtrlReg0 <= w16_WrData;		
		else begin
			if(i3_XmitState==`cXmitCONFIG) r16_CtrlReg0[9] <= 1'b0;
			r16_CtrlReg0[15] <= 1'b0;
		end
			
		
		if(w_WritePulse && w5_Addr==5'b00100) r16_CtrlReg4 <= w16_WrData;		
		
		if(w_WritePulse && w5_Addr==5'b01000) r21_LinkTimer[15:00] <= w16_WrData;
		if(w_WritePulse && w5_Addr==5'b01001) r21_LinkTimer[20:16] <= w16_WrData[4:0];
		if(w_WritePulse && w5_Addr==5'b01010) r16_ScratchRev 	<= w16_WrData;
		if(w_WritePulse && w5_Addr==5'b11111) r16_ModeReg  		<= w16_WrData;
		
		//Read Controller
		r_Read <= w_Read;	
		
		if(w_ReadPulse) 
			case(w5_Addr)
			5'h00:		o32_RdData <= {16'h0,r16_CtrlReg0};
			5'h01: 		o32_RdData <= {16'h0,w16_StatusReg1};
			5'h02: 		o32_RdData <= 32'h0;
			5'h03: 		o32_RdData <= 32'h0;
			5'h04: 		o32_RdData <= {16'h0,w16_LcAdvAbility};
			5'h05: 		o32_RdData <= {16'h0,i16_LpAdvAbility};
			5'h08:		o32_RdData <= {16'h0,r21_LinkTimer[15:00]};
			5'h09:		o32_RdData <= {16'h0,11'h0,r21_LinkTimer[20:16]};
			5'h0A:		o32_RdData <= r16_ScratchRev;
			5'h1F:		o32_RdData <= r16_ModeReg;
			default: 	o32_RdData <= 32'h0;
			endcase		
	end
	assign o_ANRestart 		= r16_CtrlReg0[9];
	assign o_MIIRst_L		= ~r16_CtrlReg0[15];
	assign o_ANEnable 		= r16_CtrlReg0[12];	
	assign o_Loopback		= r16_CtrlReg0[14];
	assign o_GXBPowerDown 	= r16_CtrlReg0[11];
	assign o16_LcAdvAbility = w16_LcAdvAbility;
	
	assign w16_LcAdvAbility = (w_UseAsSGMII==1'b0)?({1'b0,i16_TxConfigReg[15],r16_CtrlReg4[13:12],3'b000,r16_CtrlReg4[8:7],2'b01,5'b00000})://1000-X mode
								((w_SGMII_PHY==1'b1)?({i_PhyLink,i16_TxConfigReg[15],1'b0,(i_PhyDuplex|r16_CtrlReg4[12]),(i2_PhySpeed|r16_CtrlReg4[11:10]),10'h1})://SGMII mode - PHY Side
								({1'b0,i16_TxConfigReg[15],1'b0,3'b000,10'h1}));//SGMII mode - MAC Side
	
	assign w16_StatusReg1 = {9'h0,i_ANComplete,2'b01,i_SyncStatus,2'b0};
	assign w_UseAsSGMII 	= r16_ModeReg[0];
	assign w_SGMII_PHY		= r16_ModeReg[1];
	assign w_UseLcConfig	= r16_ModeReg[2];
	assign o2_SGMIISpeed	= (w_UseAsSGMII==1'b0)?2'b10:((w_UseLcConfig==1'b0)?i16_LpAdvAbility[11:10]:{r16_CtrlReg0[6]|i2_PhySpeed[1],r16_CtrlReg0[13]|i2_PhySpeed[0]});
	assign o_SGMIIDuplex 	= (w_UseAsSGMII==1'b0)?1'b1:((w_UseLcConfig==1'b0)?i16_LpAdvAbility[12]:{r16_CtrlReg0[8]|i_PhyDuplex});

endmodule
