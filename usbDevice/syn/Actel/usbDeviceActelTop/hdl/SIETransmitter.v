
// File        : ../RTL/serialInterfaceEngine/SIETransmitter.v
// Generated   : 10/15/06 20:31:22
// From        : ../RTL/serialInterfaceEngine/SIETransmitter.asf
// By          : FSM2VHDL ver. 5.0.0.9

//////////////////////////////////////////////////////////////////////
////                                                              ////
//// SIETransmitter
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// http://www.opencores.org/cores/usbhostslave/                 ////
////                                                              ////
//// Module Description:                                          ////
//// 
////                                                              ////
//// To Do:                                                       ////
//// 
////                                                              ////
//// Author(s):                                                   ////
//// - Steve Fielding, sfielding@base2designs.com                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2004 Steve Fielding and OPENCORES.ORG          ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
`include "timescale.v"
`include "usbSerialInterfaceEngine_h.v"
`include "usbConstants_h.v"


module SIETransmitter (CRC16En, CRC16Result, CRC16UpdateRdy, CRC5En, CRC5Result, CRC5UpdateRdy, CRC5_8Bit, CRCData, JBit, KBit, SIEPortCtrlIn, SIEPortDataIn, SIEPortTxRdy, SIEPortWEn, TxByteOutCtrl, TxByteOutFullSpeedRate, TxByteOut, USBWireCtrl, USBWireData, USBWireFullSpeedRate, USBWireGnt, USBWireRdy, USBWireReq, USBWireWEn, clk, fullSpeedRateIn, processTxByteRdy, processTxByteWEn, rst, rstCRC);
input   [15:0] CRC16Result;
input   CRC16UpdateRdy;
input   [4:0] CRC5Result;
input   CRC5UpdateRdy;
input   [1:0] JBit;
input   [1:0] KBit;
input   [7:0] SIEPortCtrlIn;
input   [7:0] SIEPortDataIn;
input   SIEPortWEn;
input   USBWireGnt;
input   USBWireRdy;
input   clk;
input   fullSpeedRateIn;
input   processTxByteRdy;
input   rst;
output  CRC16En;
output  CRC5En;
output  CRC5_8Bit;
output  [7:0] CRCData;
output  SIEPortTxRdy;
output  [7:0] TxByteOutCtrl;
output  TxByteOutFullSpeedRate;
output  [7:0] TxByteOut;
output  USBWireCtrl;
output  [1:0] USBWireData;
output  USBWireFullSpeedRate;
output  USBWireReq;
output  USBWireWEn;
output  processTxByteWEn;
output  rstCRC;

reg     CRC16En, next_CRC16En;
wire    [15:0] CRC16Result;
wire    CRC16UpdateRdy;
reg     CRC5En, next_CRC5En;
wire    [4:0] CRC5Result;
wire    CRC5UpdateRdy;
reg     CRC5_8Bit, next_CRC5_8Bit;
reg     [7:0] CRCData, next_CRCData;
wire    [1:0] JBit;
wire    [1:0] KBit;
wire    [7:0] SIEPortCtrlIn;
wire    [7:0] SIEPortDataIn;
reg     SIEPortTxRdy, next_SIEPortTxRdy;
wire    SIEPortWEn;
reg     [7:0] TxByteOutCtrl, next_TxByteOutCtrl;
reg     TxByteOutFullSpeedRate, next_TxByteOutFullSpeedRate;
reg     [7:0] TxByteOut, next_TxByteOut;
reg     USBWireCtrl, next_USBWireCtrl;
reg     [1:0] USBWireData, next_USBWireData;
reg     USBWireFullSpeedRate, next_USBWireFullSpeedRate;
wire    USBWireGnt;
wire    USBWireRdy;
reg     USBWireReq, next_USBWireReq;
reg     USBWireWEn, next_USBWireWEn;
wire    clk;
wire    fullSpeedRateIn;
wire    processTxByteRdy;
reg     processTxByteWEn, next_processTxByteWEn;
wire    rst;
reg     rstCRC, next_rstCRC;

// diagram signals declarations
reg  [7:0]SIEPortCtrl, next_SIEPortCtrl;
reg  [7:0]SIEPortData, next_SIEPortData;
reg  [2:0]i, next_i;
reg  [15:0]resumeCnt, next_resumeCnt;

// BINARY ENCODED state machine: SIETx
// State codes definitions:
`define DIR_CTL_CHK_FIN 6'b000000
`define RES_ST_CHK_FIN 6'b000001
`define PKT_ST_CHK_PID 6'b000010
`define PKT_ST_DATA_DATA_CHK_STOP 6'b000011
`define IDLE 6'b000100
`define PKT_ST_DATA_DATA_PKT_SENT 6'b000101
`define PKT_ST_DATA_PID_PKT_SENT 6'b000110
`define PKT_ST_HS_PKT_SENT 6'b000111
`define PKT_ST_TKN_CRC_PKT_SENT 6'b001000
`define PKT_ST_TKN_PID_PKT_SENT 6'b001001
`define PKT_ST_SPCL_PKT_SENT 6'b001010
`define PKT_ST_DATA_CRC_PKT_SENT1 6'b001011
`define PKT_ST_TKN_BYTE1_PKT_SENT1 6'b001100
`define PKT_ST_DATA_CRC_PKT_SENT2 6'b001101
`define RES_ST_SND_J_1 6'b001110
`define RES_ST_SND_J_2 6'b001111
`define RES_ST_SND_SE0_1 6'b010000
`define RES_ST_SND_SE0_2 6'b010001
`define START_SIETX 6'b010010
`define STX_CHK_ST 6'b010011
`define STX_WAIT_BYTE 6'b010100
`define PKT_ST_TKN_CRC_UPD_CRC 6'b010101
`define PKT_ST_TKN_BYTE1_UPD_CRC 6'b010110
`define PKT_ST_DATA_DATA_UPD_CRC 6'b010111
`define PKT_ST_TKN_CRC_WAIT_BYTE 6'b011000
`define PKT_ST_TKN_BYTE1_WAIT_BYTE 6'b011001
`define PKT_ST_DATA_DATA_WAIT_BYTE 6'b011010
`define DIR_CTL_WAIT_GNT 6'b011011
`define RES_ST_WAIT_GNT 6'b011100
`define PKT_ST_HS_WAIT_RDY 6'b011101
`define DIR_CTL_WAIT_RDY 6'b011110
`define PKT_ST_SPCL_WAIT_RDY 6'b011111
`define PKT_ST_TKN_CRC_WAIT_RDY 6'b100000
`define PKT_ST_TKN_PID_WAIT_RDY 6'b100001
`define PKT_ST_DATA_DATA_WAIT_RDY 6'b100010
`define RES_ST_WAIT_RDY 6'b100011
`define PKT_ST_TKN_BYTE1_WAIT_RDY 6'b100100
`define PKT_ST_DATA_PID_WAIT_RDY 6'b100101
`define PKT_ST_DATA_CRC_WAIT_RDY1 6'b100110
`define PKT_ST_DATA_CRC_WAIT_RDY2 6'b100111
`define PKT_ST_WAIT_RDY_PKT 6'b101000
`define RES_ST_W_RDY1 6'b101001
`define PKT_ST_TKN_CRC_WAIT_CRC_RDY 6'b101010
`define PKT_ST_DATA_DATA_WAIT_CRC_RDY 6'b101011
`define PKT_ST_TKN_BYTE1_WAIT_CRC_RDY 6'b101100
`define TX_LS_EOP_WAIT_GNT1 6'b101101
`define TX_LS_EOP_SND_SE0_2 6'b101110
`define TX_LS_EOP_SND_SE0_1 6'b101111
`define TX_LS_EOP_W_RDY1 6'b110000
`define TX_LS_EOP_SND_J 6'b110001
`define TX_LS_EOP_W_RDY2 6'b110010
`define TX_LS_EOP_W_RDY3 6'b110011
`define RES_ST_DELAY 6'b110100
`define RES_ST_W_RDY2 6'b110101
`define RES_ST_W_RDY3 6'b110110
`define RES_ST_W_RDY4 6'b110111
`define DIR_CTL_DELAY 6'b111000

reg [5:0] CurrState_SIETx;
reg [5:0] NextState_SIETx;


//--------------------------------------------------------------------
// Machine: SIETx
//--------------------------------------------------------------------
//----------------------------------
// Next State Logic (combinatorial)
//----------------------------------
always @ (SIEPortDataIn or SIEPortCtrlIn or fullSpeedRateIn or i or SIEPortData or CRC16Result or CRC5Result or KBit or resumeCnt or JBit or SIEPortCtrl or SIEPortWEn or USBWireGnt or USBWireRdy or processTxByteRdy or CRC16UpdateRdy or CRC5UpdateRdy or processTxByteWEn or TxByteOut or TxByteOutCtrl or USBWireData or USBWireCtrl or USBWireReq or USBWireWEn or rstCRC or CRCData or CRC5En or CRC5_8Bit or CRC16En or SIEPortTxRdy or TxByteOutFullSpeedRate or USBWireFullSpeedRate or CurrState_SIETx)
begin : SIETx_NextState
  NextState_SIETx <= CurrState_SIETx;
  // Set default values for outputs and signals
  next_processTxByteWEn <= processTxByteWEn;
  next_TxByteOut <= TxByteOut;
  next_TxByteOutCtrl <= TxByteOutCtrl;
  next_USBWireData <= USBWireData;
  next_USBWireCtrl <= USBWireCtrl;
  next_USBWireReq <= USBWireReq;
  next_USBWireWEn <= USBWireWEn;
  next_rstCRC <= rstCRC;
  next_CRCData <= CRCData;
  next_CRC5En <= CRC5En;
  next_CRC5_8Bit <= CRC5_8Bit;
  next_CRC16En <= CRC16En;
  next_SIEPortTxRdy <= SIEPortTxRdy;
  next_SIEPortData <= SIEPortData;
  next_SIEPortCtrl <= SIEPortCtrl;
  next_i <= i;
  next_resumeCnt <= resumeCnt;
  next_TxByteOutFullSpeedRate <= TxByteOutFullSpeedRate;
  next_USBWireFullSpeedRate <= USBWireFullSpeedRate;
  case (CurrState_SIETx)
    `IDLE:
      NextState_SIETx <= `STX_WAIT_BYTE;
    `START_SIETX:
    begin
      next_processTxByteWEn <= 1'b0;
      next_TxByteOut <= 8'h00;
      next_TxByteOutCtrl <= 8'h00;
      next_USBWireData <= 2'b00;
      next_USBWireCtrl <= `TRI_STATE;
      next_USBWireReq <= 1'b0;
      next_USBWireWEn <= 1'b0;
      next_rstCRC <= 1'b0;
      next_CRCData <= 8'h00;
      next_CRC5En <= 1'b0;
      next_CRC5_8Bit <= 1'b0;
      next_CRC16En <= 1'b0;
      next_SIEPortTxRdy <= 1'b0;
      next_SIEPortData <= 8'h00;
      next_SIEPortCtrl <= 8'h00;
      next_i <= 3'h0;
      next_resumeCnt <= 16'h0000;
      next_TxByteOutFullSpeedRate <= 1'b0;
      next_USBWireFullSpeedRate <= 1'b0;
      NextState_SIETx <= `STX_WAIT_BYTE;
    end
    `STX_CHK_ST:
      if ((SIEPortCtrl == `TX_PACKET_START) && (SIEPortData[3:0] == `SOF || SIEPortData[3:0] == `PREAMBLE))	
      begin
        NextState_SIETx <= `PKT_ST_WAIT_RDY_PKT;
        next_TxByteOutFullSpeedRate <= 1'b1;
        //SOF and PRE always at full speed
      end
      else if (SIEPortCtrl == `TX_PACKET_START)	
        NextState_SIETx <= `PKT_ST_WAIT_RDY_PKT;
      else if (SIEPortCtrl == `TX_LS_KEEP_ALIVE)	
      begin
        NextState_SIETx <= `TX_LS_EOP_WAIT_GNT1;
        next_USBWireReq <= 1'b1;
      end
      else if (SIEPortCtrl == `TX_DIRECT_CONTROL)	
      begin
        NextState_SIETx <= `DIR_CTL_WAIT_GNT;
        next_USBWireReq <= 1'b1;
      end
      else if (SIEPortCtrl == `TX_IDLE)	
        NextState_SIETx <= `IDLE;
      else if (SIEPortCtrl == `TX_RESUME_START)	
      begin
        NextState_SIETx <= `RES_ST_WAIT_GNT;
        next_USBWireReq <= 1'b1;
        next_resumeCnt <= 16'h0000;
        next_USBWireFullSpeedRate <= 1'b0;
        //resume always uses low speed timing
      end
    `STX_WAIT_BYTE:
    begin
      next_SIEPortTxRdy <= 1'b1;
      if (SIEPortWEn == 1'b1)	
      begin
        NextState_SIETx <= `STX_CHK_ST;
        next_SIEPortData <= SIEPortDataIn;
        next_SIEPortCtrl <= SIEPortCtrlIn;
        next_SIEPortTxRdy <= 1'b0;
        next_TxByteOutFullSpeedRate <= fullSpeedRateIn;
        next_USBWireFullSpeedRate <= fullSpeedRateIn;
      end
    end
    `DIR_CTL_CHK_FIN:
    begin
      next_USBWireWEn <= 1'b0;
      next_i <= i + 1'b1;
      if (i == 3'h7)	
      begin
        NextState_SIETx <= `STX_WAIT_BYTE;
        next_USBWireReq <= 1'b0;
      end
      else
        NextState_SIETx <= `DIR_CTL_DELAY;
    end
    `DIR_CTL_WAIT_GNT:
    begin
      next_i <= 3'h0;
      if (USBWireGnt == 1'b1)	
        NextState_SIETx <= `DIR_CTL_WAIT_RDY;
    end
    `DIR_CTL_WAIT_RDY:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_SIETx <= `DIR_CTL_CHK_FIN;
        next_USBWireData <= SIEPortData[1:0];
        next_USBWireCtrl <= `DRIVE;
        next_USBWireWEn <= 1'b1;
      end
    `DIR_CTL_DELAY:
      NextState_SIETx <= `DIR_CTL_WAIT_RDY;
    `PKT_ST_CHK_PID:
    begin
      next_processTxByteWEn <= 1'b0;
      if (SIEPortData[1:0] == `TOKEN)	
        NextState_SIETx <= `PKT_ST_TKN_PID_WAIT_RDY;
      else if (SIEPortData[1:0] == `HANDSHAKE)	
        NextState_SIETx <= `PKT_ST_HS_WAIT_RDY;
      else if (SIEPortData[1:0] == `DATA)	
        NextState_SIETx <= `PKT_ST_DATA_PID_WAIT_RDY;
      else if (SIEPortData[1:0] == `SPECIAL)	
        NextState_SIETx <= `PKT_ST_SPCL_WAIT_RDY;
    end
    `PKT_ST_WAIT_RDY_PKT:
      if (processTxByteRdy == 1'b1)	
      begin
        NextState_SIETx <= `PKT_ST_CHK_PID;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= `SYNC_BYTE;
        next_TxByteOutCtrl <= `DATA_START;
      end
    `PKT_ST_DATA_CRC_PKT_SENT1:
    begin
      next_processTxByteWEn <= 1'b0;
      NextState_SIETx <= `PKT_ST_DATA_CRC_WAIT_RDY2;
    end
    `PKT_ST_DATA_CRC_PKT_SENT2:
    begin
      next_processTxByteWEn <= 1'b0;
      NextState_SIETx <= `STX_WAIT_BYTE;
    end
    `PKT_ST_DATA_CRC_WAIT_RDY1:
      if (processTxByteRdy == 1'b1)	
      begin
        NextState_SIETx <= `PKT_ST_DATA_CRC_PKT_SENT1;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= ~CRC16Result[7:0];
        next_TxByteOutCtrl <= `DATA_STREAM;
      end
    `PKT_ST_DATA_CRC_WAIT_RDY2:
      if (processTxByteRdy == 1'b1)	
      begin
        NextState_SIETx <= `PKT_ST_DATA_CRC_PKT_SENT2;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= ~CRC16Result[15:8];
        next_TxByteOutCtrl <= `DATA_STOP;
      end
    `PKT_ST_DATA_DATA_CHK_STOP:
      if (SIEPortCtrl == `TX_PACKET_STOP)	
        NextState_SIETx <= `PKT_ST_DATA_CRC_WAIT_RDY1;
      else
        NextState_SIETx <= `PKT_ST_DATA_DATA_WAIT_CRC_RDY;
    `PKT_ST_DATA_DATA_PKT_SENT:
    begin
      next_processTxByteWEn <= 1'b0;
      NextState_SIETx <= `PKT_ST_DATA_DATA_WAIT_BYTE;
    end
    `PKT_ST_DATA_DATA_UPD_CRC:
    begin
      next_CRCData <= SIEPortData;
      next_CRC16En <= 1'b1;
      NextState_SIETx <= `PKT_ST_DATA_DATA_WAIT_RDY;
    end
    `PKT_ST_DATA_DATA_WAIT_BYTE:
    begin
      next_SIEPortTxRdy <= 1'b1;
      if (SIEPortWEn == 1'b1)	
      begin
        NextState_SIETx <= `PKT_ST_DATA_DATA_CHK_STOP;
        next_SIEPortData <= SIEPortDataIn;
        next_SIEPortCtrl <= SIEPortCtrlIn;
        next_SIEPortTxRdy <= 1'b0;
      end
    end
    `PKT_ST_DATA_DATA_WAIT_RDY:
    begin
      next_CRC16En <= 1'b0;
      if (processTxByteRdy == 1'b1)	
      begin
        NextState_SIETx <= `PKT_ST_DATA_DATA_PKT_SENT;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= SIEPortData;
        next_TxByteOutCtrl <= `DATA_STREAM;
      end
    end
    `PKT_ST_DATA_DATA_WAIT_CRC_RDY:
      if (CRC16UpdateRdy == 1'b1)	
        NextState_SIETx <= `PKT_ST_DATA_DATA_UPD_CRC;
    `PKT_ST_DATA_PID_PKT_SENT:
    begin
      next_processTxByteWEn <= 1'b0;
      next_rstCRC <= 1'b0;
      NextState_SIETx <= `PKT_ST_DATA_DATA_WAIT_BYTE;
    end
    `PKT_ST_DATA_PID_WAIT_RDY:
      if (processTxByteRdy == 1'b1)	
      begin
        NextState_SIETx <= `PKT_ST_DATA_PID_PKT_SENT;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= SIEPortData;
        next_TxByteOutCtrl <= `DATA_STREAM;
        next_rstCRC <= 1'b1;
      end
    `PKT_ST_HS_PKT_SENT:
    begin
      next_processTxByteWEn <= 1'b0;
      NextState_SIETx <= `STX_WAIT_BYTE;
    end
    `PKT_ST_HS_WAIT_RDY:
      if (processTxByteRdy == 1'b1)	
      begin
        NextState_SIETx <= `PKT_ST_HS_PKT_SENT;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= SIEPortData;
        next_TxByteOutCtrl <= `DATA_STOP;
      end
    `PKT_ST_SPCL_PKT_SENT:
    begin
      next_processTxByteWEn <= 1'b0;
      NextState_SIETx <= `STX_WAIT_BYTE;
    end
    `PKT_ST_SPCL_WAIT_RDY:
      if (processTxByteRdy == 1'b1)	
      begin
        NextState_SIETx <= `PKT_ST_SPCL_PKT_SENT;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= SIEPortData;
        next_TxByteOutCtrl <= `DATA_STOP;
      end
    `PKT_ST_TKN_BYTE1_PKT_SENT1:
    begin
      next_processTxByteWEn <= 1'b0;
      NextState_SIETx <= `PKT_ST_TKN_CRC_WAIT_BYTE;
    end
    `PKT_ST_TKN_BYTE1_UPD_CRC:
    begin
      next_CRCData <= SIEPortData;
      next_CRC5_8Bit <= 1'b1;
      next_CRC5En <= 1'b1;
      NextState_SIETx <= `PKT_ST_TKN_BYTE1_WAIT_RDY;
    end
    `PKT_ST_TKN_BYTE1_WAIT_BYTE:
    begin
      next_SIEPortTxRdy <= 1'b1;
      if (SIEPortWEn == 1'b1)	
      begin
        NextState_SIETx <= `PKT_ST_TKN_BYTE1_WAIT_CRC_RDY;
        next_SIEPortData <= SIEPortDataIn;
        next_SIEPortCtrl <= SIEPortCtrlIn;
        next_SIEPortTxRdy <= 1'b0;
      end
    end
    `PKT_ST_TKN_BYTE1_WAIT_RDY:
    begin
      next_CRC5En <= 1'b0;
      if (processTxByteRdy == 1'b1)	
      begin
        NextState_SIETx <= `PKT_ST_TKN_BYTE1_PKT_SENT1;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= SIEPortData;
        next_TxByteOutCtrl <= `DATA_STREAM;
      end
    end
    `PKT_ST_TKN_BYTE1_WAIT_CRC_RDY:
      if (CRC5UpdateRdy == 1'b1)	
        NextState_SIETx <= `PKT_ST_TKN_BYTE1_UPD_CRC;
    `PKT_ST_TKN_CRC_PKT_SENT:
    begin
      next_processTxByteWEn <= 1'b0;
      NextState_SIETx <= `STX_WAIT_BYTE;
    end
    `PKT_ST_TKN_CRC_UPD_CRC:
    begin
      next_CRCData <= SIEPortData;
      next_CRC5_8Bit <= 1'b0;
      next_CRC5En <= 1'b1;
      NextState_SIETx <= `PKT_ST_TKN_CRC_WAIT_RDY;
    end
    `PKT_ST_TKN_CRC_WAIT_BYTE:
    begin
      next_SIEPortTxRdy <= 1'b1;
      if (SIEPortWEn == 1'b1)	
      begin
        NextState_SIETx <= `PKT_ST_TKN_CRC_WAIT_CRC_RDY;
        next_SIEPortData <= SIEPortDataIn;
        next_SIEPortCtrl <= SIEPortCtrlIn;
        next_SIEPortTxRdy <= 1'b0;
      end
    end
    `PKT_ST_TKN_CRC_WAIT_RDY:
    begin
      next_CRC5En <= 1'b0;
      if (processTxByteRdy == 1'b1)	
      begin
        NextState_SIETx <= `PKT_ST_TKN_CRC_PKT_SENT;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= {~CRC5Result, SIEPortData[2:0] };
        next_TxByteOutCtrl <= `DATA_STOP;
      end
    end
    `PKT_ST_TKN_CRC_WAIT_CRC_RDY:
      if (CRC5UpdateRdy == 1'b1)	
        NextState_SIETx <= `PKT_ST_TKN_CRC_UPD_CRC;
    `PKT_ST_TKN_PID_PKT_SENT:
    begin
      next_processTxByteWEn <= 1'b0;
      next_rstCRC <= 1'b0;
      NextState_SIETx <= `PKT_ST_TKN_BYTE1_WAIT_BYTE;
    end
    `PKT_ST_TKN_PID_WAIT_RDY:
      if (processTxByteRdy == 1'b1)	
      begin
        NextState_SIETx <= `PKT_ST_TKN_PID_PKT_SENT;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= SIEPortData;
        next_TxByteOutCtrl <= `DATA_STREAM;
        next_rstCRC <= 1'b1;
      end
    `RES_ST_CHK_FIN:
    begin
      next_USBWireWEn <= 1'b0;
      if (resumeCnt == `HOST_TX_RESUME_TIME)	
        NextState_SIETx <= `RES_ST_W_RDY1;
      else
        NextState_SIETx <= `RES_ST_DELAY;
    end
    `RES_ST_SND_J_1:
    begin
      next_USBWireWEn <= 1'b0;
      NextState_SIETx <= `RES_ST_W_RDY4;
    end
    `RES_ST_SND_J_2:
    begin
      next_USBWireWEn <= 1'b0;
      next_USBWireReq <= 1'b0;
      NextState_SIETx <= `STX_WAIT_BYTE;
      next_USBWireFullSpeedRate <= fullSpeedRateIn;
    end
    `RES_ST_SND_SE0_1:
    begin
      next_USBWireWEn <= 1'b0;
      NextState_SIETx <= `RES_ST_W_RDY2;
    end
    `RES_ST_SND_SE0_2:
    begin
      next_USBWireWEn <= 1'b0;
      NextState_SIETx <= `RES_ST_W_RDY3;
    end
    `RES_ST_WAIT_GNT:
      if (USBWireGnt == 1'b1)	
        NextState_SIETx <= `RES_ST_WAIT_RDY;
    `RES_ST_WAIT_RDY:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_SIETx <= `RES_ST_CHK_FIN;
        next_USBWireData <= KBit;
        next_USBWireCtrl <= `DRIVE;
        next_USBWireWEn <= 1'b1;
        next_resumeCnt <= resumeCnt  + 1'b1;
      end
    `RES_ST_W_RDY1:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_SIETx <= `RES_ST_SND_SE0_1;
        next_USBWireData <= `SE0;
        next_USBWireCtrl <= `DRIVE;
        next_USBWireWEn <= 1'b1;
      end
    `RES_ST_DELAY:
      NextState_SIETx <= `RES_ST_WAIT_RDY;
    `RES_ST_W_RDY2:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_SIETx <= `RES_ST_SND_SE0_2;
        next_USBWireData <= `SE0;
        next_USBWireCtrl <= `DRIVE;
        next_USBWireWEn <= 1'b1;
      end
    `RES_ST_W_RDY3:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_SIETx <= `RES_ST_SND_J_1;
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `DRIVE;
        next_USBWireWEn <= 1'b1;
      end
    `RES_ST_W_RDY4:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_SIETx <= `RES_ST_SND_J_2;
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `TRI_STATE;
        next_USBWireWEn <= 1'b1;
      end
    `TX_LS_EOP_WAIT_GNT1:
      if (USBWireGnt == 1'b1)	
        NextState_SIETx <= `TX_LS_EOP_W_RDY1;
    `TX_LS_EOP_SND_SE0_2:
    begin
      next_USBWireWEn <= 1'b0;
      NextState_SIETx <= `TX_LS_EOP_W_RDY3;
    end
    `TX_LS_EOP_SND_SE0_1:
    begin
      next_USBWireWEn <= 1'b0;
      NextState_SIETx <= `TX_LS_EOP_W_RDY2;
    end
    `TX_LS_EOP_W_RDY1:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_SIETx <= `TX_LS_EOP_SND_SE0_1;
        next_USBWireData <= `SE0;
        next_USBWireCtrl <= `DRIVE;
        next_USBWireWEn <= 1'b1;
      end
    `TX_LS_EOP_SND_J:
    begin
      next_USBWireWEn <= 1'b0;
      next_USBWireReq <= 1'b0;
      NextState_SIETx <= `STX_WAIT_BYTE;
    end
    `TX_LS_EOP_W_RDY2:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_SIETx <= `TX_LS_EOP_SND_SE0_2;
        next_USBWireData <= `SE0;
        next_USBWireCtrl <= `DRIVE;
        next_USBWireWEn <= 1'b1;
      end
    `TX_LS_EOP_W_RDY3:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_SIETx <= `TX_LS_EOP_SND_J;
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `DRIVE;
        next_USBWireWEn <= 1'b1;
      end
  endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : SIETx_CurrentState
  if (rst)	
    CurrState_SIETx <= `START_SIETX;
  else
    CurrState_SIETx <= NextState_SIETx;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : SIETx_RegOutput
  if (rst)	
  begin
    SIEPortData <= 8'h00;
    SIEPortCtrl <= 8'h00;
    i <= 3'h0;
    resumeCnt <= 16'h0000;
    processTxByteWEn <= 1'b0;
    TxByteOut <= 8'h00;
    TxByteOutCtrl <= 8'h00;
    USBWireData <= 2'b00;
    USBWireCtrl <= `TRI_STATE;
    USBWireReq <= 1'b0;
    USBWireWEn <= 1'b0;
    rstCRC <= 1'b0;
    CRCData <= 8'h00;
    CRC5En <= 1'b0;
    CRC5_8Bit <= 1'b0;
    CRC16En <= 1'b0;
    SIEPortTxRdy <= 1'b0;
    TxByteOutFullSpeedRate <= 1'b0;
    USBWireFullSpeedRate <= 1'b0;
  end
  else 
  begin
    SIEPortData <= next_SIEPortData;
    SIEPortCtrl <= next_SIEPortCtrl;
    i <= next_i;
    resumeCnt <= next_resumeCnt;
    processTxByteWEn <= next_processTxByteWEn;
    TxByteOut <= next_TxByteOut;
    TxByteOutCtrl <= next_TxByteOutCtrl;
    USBWireData <= next_USBWireData;
    USBWireCtrl <= next_USBWireCtrl;
    USBWireReq <= next_USBWireReq;
    USBWireWEn <= next_USBWireWEn;
    rstCRC <= next_rstCRC;
    CRCData <= next_CRCData;
    CRC5En <= next_CRC5En;
    CRC5_8Bit <= next_CRC5_8Bit;
    CRC16En <= next_CRC16En;
    SIEPortTxRdy <= next_SIEPortTxRdy;
    TxByteOutFullSpeedRate <= next_TxByteOutFullSpeedRate;
    USBWireFullSpeedRate <= next_USBWireFullSpeedRate;
  end
end

endmodule