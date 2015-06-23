
// File        : ../RTL/serialInterfaceEngine/processTxByte.v
// Generated   : 11/10/06 05:37:23
// From        : ../RTL/serialInterfaceEngine/processTxByte.asf
// By          : FSM2VHDL ver. 5.0.0.9

//////////////////////////////////////////////////////////////////////
////                                                              ////
//// processTxByte
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

module processTxByte (JBit, KBit, TxByteCtrlIn, TxByteFullSpeedRateIn, TxByteIn, USBWireCtrl, USBWireData, USBWireFullSpeedRate, USBWireGnt, USBWireRdy, USBWireReq, USBWireWEn, clk, processTxByteRdy, processTxByteWEn, rst);
input   [1:0] JBit;
input   [1:0] KBit;
input   [7:0] TxByteCtrlIn;
input   TxByteFullSpeedRateIn;
input   [7:0] TxByteIn;
input   USBWireGnt;
input   USBWireRdy;
input   clk;
input   processTxByteWEn;
input   rst;
output  USBWireCtrl;
output  [1:0] USBWireData;
output  USBWireFullSpeedRate;
output  USBWireReq;
output  USBWireWEn;
output  processTxByteRdy;

wire    [1:0] JBit;
wire    [1:0] KBit;
wire    [7:0] TxByteCtrlIn;
wire    TxByteFullSpeedRateIn;
wire    [7:0] TxByteIn;
reg     USBWireCtrl, next_USBWireCtrl;
reg     [1:0] USBWireData, next_USBWireData;
reg     USBWireFullSpeedRate, next_USBWireFullSpeedRate;
wire    USBWireGnt;
wire    USBWireRdy;
reg     USBWireReq, next_USBWireReq;
reg     USBWireWEn, next_USBWireWEn;
wire    clk;
reg     processTxByteRdy, next_processTxByteRdy;
wire    processTxByteWEn;
wire    rst;

// diagram signals declarations
reg  [1:0]TXLineState, next_TXLineState;
reg  [3:0]TXOneCount, next_TXOneCount;
reg  [7:0]TxByteCtrl, next_TxByteCtrl;
reg  TxByteFullSpeedRate, next_TxByteFullSpeedRate;
reg  [7:0]TxByte, next_TxByte;
reg  [3:0]i, next_i;

// BINARY ENCODED state machine: prcTxB
// State codes definitions:
`define START_PTBY 5'b00000
`define PTBY_WAIT_EN 5'b00001
`define SEND_BYTE_UPDATE_BYTE 5'b00010
`define SEND_BYTE_WAIT_RDY 5'b00011
`define SEND_BYTE_CHK 5'b00100
`define SEND_BYTE_BIT_STUFF 5'b00101
`define SEND_BYTE_WAIT_RDY2 5'b00110
`define SEND_BYTE_CHK_FIN 5'b00111
`define PTBY_WAIT_GNT 5'b01000
`define STOP_SND_SE0_2 5'b01001
`define STOP_SND_SE0_1 5'b01010
`define STOP_CHK 5'b01011
`define STOP_SND_J 5'b01100
`define STOP_SND_IDLE 5'b01101
`define STOP_FIN 5'b01110
`define WAIT_RDY_WIRE 5'b01111
`define WAIT_RDY_PKT 5'b10000
`define LS_START_SND_IDLE3 5'b10001
`define LS_START_SND_J1 5'b10010
`define LS_START_SND_IDLE1 5'b10011
`define LS_START_SND_IDLE2 5'b10100
`define LS_START_FIN 5'b10101
`define LS_START_W_RDY1 5'b10110
`define LS_START_W_RDY2 5'b10111
`define LS_START_W_RDY3 5'b11000
`define STOP_W_RDY1 5'b11001
`define STOP_W_RDY2 5'b11010
`define STOP_W_RDY3 5'b11011
`define STOP_W_RDY4 5'b11100

reg [4:0] CurrState_prcTxB;
reg [4:0] NextState_prcTxB;


//--------------------------------------------------------------------
// Machine: prcTxB
//--------------------------------------------------------------------
//----------------------------------
// Next State Logic (combinatorial)
//----------------------------------
always @ (TxByteIn or TxByteCtrlIn or TxByteFullSpeedRateIn or JBit or i or TxByte or TXOneCount or TXLineState or KBit or processTxByteWEn or USBWireGnt or USBWireRdy or TxByteFullSpeedRate or TxByteCtrl or processTxByteRdy or USBWireData or USBWireCtrl or USBWireReq or USBWireWEn or USBWireFullSpeedRate or CurrState_prcTxB)
begin : prcTxB_NextState
  NextState_prcTxB <= CurrState_prcTxB;
  // Set default values for outputs and signals
  next_processTxByteRdy <= processTxByteRdy;
  next_USBWireData <= USBWireData;
  next_USBWireCtrl <= USBWireCtrl;
  next_USBWireReq <= USBWireReq;
  next_USBWireWEn <= USBWireWEn;
  next_i <= i;
  next_TxByte <= TxByte;
  next_TxByteCtrl <= TxByteCtrl;
  next_TXLineState <= TXLineState;
  next_TXOneCount <= TXOneCount;
  next_USBWireFullSpeedRate <= USBWireFullSpeedRate;
  next_TxByteFullSpeedRate <= TxByteFullSpeedRate;
  case (CurrState_prcTxB)
    `START_PTBY:
    begin
      next_processTxByteRdy <= 1'b0;
      next_USBWireData <= 2'b00;
      next_USBWireCtrl <= `TRI_STATE;
      next_USBWireReq <= 1'b0;
      next_USBWireWEn <= 1'b0;
      next_i <= 4'h0;
      next_TxByte <= 8'h00;
      next_TxByteCtrl <= 8'h00;
      next_TXLineState <= 2'b0;
      next_TXOneCount <= 4'h0;
      next_USBWireFullSpeedRate <= 1'b0;
      next_TxByteFullSpeedRate <= 1'b0;
      NextState_prcTxB <= `PTBY_WAIT_EN;
    end
    `PTBY_WAIT_EN:
    begin
      next_processTxByteRdy <= 1'b1;
      if ((processTxByteWEn == 1'b1) && (TxByteCtrlIn == `DATA_START))	
      begin
        NextState_prcTxB <= `PTBY_WAIT_GNT;
        next_processTxByteRdy <= 1'b0;
        next_TxByte <= TxByteIn;
        next_TxByteCtrl <= TxByteCtrlIn;
        next_TxByteFullSpeedRate <= TxByteFullSpeedRateIn;
        next_USBWireFullSpeedRate <= TxByteFullSpeedRateIn;
        next_TXOneCount <= 4'h0;
        next_TXLineState <= JBit;
        next_USBWireReq <= 1'b1;
      end
      else if (processTxByteWEn == 1'b1)	
      begin
        NextState_prcTxB <= `SEND_BYTE_UPDATE_BYTE;
        next_processTxByteRdy <= 1'b0;
        next_TxByte <= TxByteIn;
        next_TxByteCtrl <= TxByteCtrlIn;
        next_TxByteFullSpeedRate <= TxByteFullSpeedRateIn;
        next_USBWireFullSpeedRate <= TxByteFullSpeedRateIn;
        next_i <= 4'h0;
      end
    end
    `PTBY_WAIT_GNT:
      if (USBWireGnt == 1'b1)	
        NextState_prcTxB <= `WAIT_RDY_WIRE;
    `WAIT_RDY_WIRE:
      if ((USBWireRdy == 1'b1) && (TxByteFullSpeedRate  == 1'b0))	
        NextState_prcTxB <= `LS_START_SND_IDLE1;
      else if (USBWireRdy == 1'b1)	
      begin
        NextState_prcTxB <= `WAIT_RDY_PKT;
        //actively drive the first J bit
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `DRIVE;
        next_USBWireWEn <= 1'b1;
      end
    `WAIT_RDY_PKT:
    begin
      next_USBWireWEn <= 1'b0;
      NextState_prcTxB <= `SEND_BYTE_UPDATE_BYTE;
      next_i <= 4'h0;
    end
    `SEND_BYTE_UPDATE_BYTE:
    begin
      next_i <= i + 1'b1;
      next_TxByte <= {1'b0, TxByte[7:1] };
      if (TxByte[0] == 1'b1)                      //If this bit is 1, then
        next_TXOneCount <= TXOneCount + 1'b1;
          //increment 'TXOneCount'
      else                                        //else this is a zero bit
      begin
        next_TXOneCount <= 4'h0;
          //reset 'TXOneCount'
          if (TXLineState == JBit)
          next_TXLineState <= KBit;
              //toggle the line state
          else
          next_TXLineState <= JBit;
      end
      NextState_prcTxB <= `SEND_BYTE_WAIT_RDY;
    end
    `SEND_BYTE_WAIT_RDY:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_prcTxB <= `SEND_BYTE_CHK;
        next_USBWireWEn <= 1'b1;
        next_USBWireData <= TXLineState;
        next_USBWireCtrl <= `DRIVE;
      end
    `SEND_BYTE_CHK:
    begin
      next_USBWireWEn <= 1'b0;
      if (TXOneCount == `MAX_CONSEC_SAME_BITS)	
        NextState_prcTxB <= `SEND_BYTE_BIT_STUFF;
      else if (i != 4'h8)	
        NextState_prcTxB <= `SEND_BYTE_UPDATE_BYTE;
      else
        NextState_prcTxB <= `STOP_CHK;
    end
    `SEND_BYTE_BIT_STUFF:
    begin
      next_TXOneCount <= 4'h0;
      //reset 'TXOneCount'
      if (TXLineState == JBit)
        next_TXLineState <= KBit;
          //toggle the line state
      else
        next_TXLineState <= JBit;
      NextState_prcTxB <= `SEND_BYTE_WAIT_RDY2;
    end
    `SEND_BYTE_WAIT_RDY2:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_prcTxB <= `SEND_BYTE_CHK_FIN;
        next_USBWireWEn <= 1'b1;
        next_USBWireData <= TXLineState;
        next_USBWireCtrl <= `DRIVE;
      end
    `SEND_BYTE_CHK_FIN:
    begin
      next_USBWireWEn <= 1'b0;
      if (i == 4'h8)	
        NextState_prcTxB <= `STOP_CHK;
      else
        NextState_prcTxB <= `SEND_BYTE_UPDATE_BYTE;
    end
    `STOP_SND_SE0_2:
    begin
      next_USBWireWEn <= 1'b0;
      NextState_prcTxB <= `STOP_W_RDY2;
    end
    `STOP_SND_SE0_1:
      NextState_prcTxB <= `STOP_W_RDY1;
    `STOP_CHK:
      if (TxByteCtrl == `DATA_STOP)	
        NextState_prcTxB <= `STOP_SND_SE0_1;
      else if (TxByteCtrl == `DATA_STOP_PRE)	
        NextState_prcTxB <= `STOP_SND_J;
      else
        NextState_prcTxB <= `PTBY_WAIT_EN;
    `STOP_SND_J:
    begin
      next_USBWireWEn <= 1'b0;
      NextState_prcTxB <= `STOP_W_RDY3;
    end
    `STOP_SND_IDLE:
    begin
      next_USBWireWEn <= 1'b0;
      NextState_prcTxB <= `STOP_W_RDY4;
    end
    `STOP_FIN:
    begin
      next_USBWireWEn <= 1'b0;
      next_USBWireReq <= 1'b0;
      //release the wire
      NextState_prcTxB <= `PTBY_WAIT_EN;
    end
    `STOP_W_RDY1:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_prcTxB <= `STOP_SND_SE0_2;
        next_USBWireWEn <= 1'b1;
        next_USBWireData <= `SE0;
        next_USBWireCtrl <= `DRIVE;
      end
    `STOP_W_RDY2:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_prcTxB <= `STOP_SND_J;
        next_USBWireWEn <= 1'b1;
        next_USBWireData <= `SE0;
        next_USBWireCtrl <= `DRIVE;
      end
    `STOP_W_RDY3:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_prcTxB <= `STOP_SND_IDLE;
        next_USBWireWEn <= 1'b1;
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `DRIVE;
      end
    `STOP_W_RDY4:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_prcTxB <= `STOP_FIN;
        next_USBWireWEn <= 1'b1;
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `TRI_STATE;
      end
    `LS_START_SND_IDLE3:
    begin
      next_USBWireWEn <= 1'b0;
      NextState_prcTxB <= `LS_START_W_RDY2;
    end
    `LS_START_SND_J1:
    begin
      next_USBWireWEn <= 1'b0;
      NextState_prcTxB <= `LS_START_W_RDY3;
    end
    `LS_START_SND_IDLE1:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_prcTxB <= `LS_START_SND_IDLE2;
        next_USBWireWEn <= 1'b1;
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `TRI_STATE;
      end
    `LS_START_SND_IDLE2:
    begin
      next_USBWireWEn <= 1'b0;
      NextState_prcTxB <= `LS_START_W_RDY1;
    end
    `LS_START_FIN:
    begin
      next_USBWireWEn <= 1'b0;
      NextState_prcTxB <= `SEND_BYTE_UPDATE_BYTE;
      next_i <= 4'h0;
    end
    `LS_START_W_RDY1:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_prcTxB <= `LS_START_SND_IDLE3;
        next_USBWireWEn <= 1'b1;
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `TRI_STATE;
      end
    `LS_START_W_RDY2:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_prcTxB <= `LS_START_SND_J1;
        next_USBWireWEn <= 1'b1;
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `TRI_STATE;
      end
    `LS_START_W_RDY3:
      if (USBWireRdy == 1'b1)	
      begin
        NextState_prcTxB <= `LS_START_FIN;
        //Drive the first JBit
        next_USBWireWEn <= 1'b1;
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `DRIVE;
      end
  endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : prcTxB_CurrentState
  if (rst)	
    CurrState_prcTxB <= `START_PTBY;
  else
    CurrState_prcTxB <= NextState_prcTxB;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : prcTxB_RegOutput
  if (rst)	
  begin
    i <= 4'h0;
    TxByte <= 8'h00;
    TxByteCtrl <= 8'h00;
    TXLineState <= 2'b0;
    TXOneCount <= 4'h0;
    TxByteFullSpeedRate <= 1'b0;
    processTxByteRdy <= 1'b0;
    USBWireData <= 2'b00;
    USBWireCtrl <= `TRI_STATE;
    USBWireReq <= 1'b0;
    USBWireWEn <= 1'b0;
    USBWireFullSpeedRate <= 1'b0;
  end
  else 
  begin
    i <= next_i;
    TxByte <= next_TxByte;
    TxByteCtrl <= next_TxByteCtrl;
    TXLineState <= next_TXLineState;
    TXOneCount <= next_TXOneCount;
    TxByteFullSpeedRate <= next_TxByteFullSpeedRate;
    processTxByteRdy <= next_processTxByteRdy;
    USBWireData <= next_USBWireData;
    USBWireCtrl <= next_USBWireCtrl;
    USBWireReq <= next_USBWireReq;
    USBWireWEn <= next_USBWireWEn;
    USBWireFullSpeedRate <= next_USBWireFullSpeedRate;
  end
end

endmodule
