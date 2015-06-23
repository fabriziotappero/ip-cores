
// File        : ../RTL/serialInterfaceEngine/usbTxWireArbiter.v
// Generated   : 11/10/06 05:37:24
// From        : ../RTL/serialInterfaceEngine/usbTxWireArbiter.asf
// By          : FSM2VHDL ver. 5.0.0.9

//////////////////////////////////////////////////////////////////////
////                                                              ////
//// usbTxWireArbiter
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
`include "usbConstants_h.v"
`include "usbSerialInterfaceEngine_h.v"



module USBTxWireArbiter (SIETxCtrl, SIETxData, SIETxFSRate, SIETxGnt, SIETxReq, SIETxWEn, TxBits, TxCtl, TxFSRate, USBWireRdyIn, USBWireRdyOut, USBWireWEn, clk, prcTxByteCtrl, prcTxByteData, prcTxByteFSRate, prcTxByteGnt, prcTxByteReq, prcTxByteWEn, rst);
input   SIETxCtrl;
input   [1:0] SIETxData;
input   SIETxFSRate;
input   SIETxReq;
input   SIETxWEn;
input   USBWireRdyIn;
input   clk;
input   prcTxByteCtrl;
input   [1:0] prcTxByteData;
input   prcTxByteFSRate;
input   prcTxByteReq;
input   prcTxByteWEn;
input   rst;
output  SIETxGnt;
output  [1:0] TxBits;
output  TxCtl;
output  TxFSRate;
output  USBWireRdyOut;
output  USBWireWEn;
output  prcTxByteGnt;

wire    SIETxCtrl;
wire    [1:0] SIETxData;
wire    SIETxFSRate;
reg     SIETxGnt, next_SIETxGnt;
wire    SIETxReq;
wire    SIETxWEn;
reg     [1:0] TxBits, next_TxBits;
reg     TxCtl, next_TxCtl;
reg     TxFSRate, next_TxFSRate;
wire    USBWireRdyIn;
reg     USBWireRdyOut, next_USBWireRdyOut;
reg     USBWireWEn, next_USBWireWEn;
wire    clk;
wire    prcTxByteCtrl;
wire    [1:0] prcTxByteData;
wire    prcTxByteFSRate;
reg     prcTxByteGnt, next_prcTxByteGnt;
wire    prcTxByteReq;
wire    prcTxByteWEn;
wire    rst;

// diagram signals declarations
reg  muxSIENotPTXB, next_muxSIENotPTXB;

// BINARY ENCODED state machine: txWireArb
// State codes definitions:
`define START_TARB 2'b00
`define TARB_WAIT_REQ 2'b01
`define PTXB_ACT 2'b10
`define SIE_TX_ACT 2'b11

reg [1:0] CurrState_txWireArb;
reg [1:0] NextState_txWireArb;

// Diagram actions (continuous assignments allowed only: assign ...)

// processTxByte/SIETransmitter mux
always @(USBWireRdyIn)
begin
    USBWireRdyOut <= USBWireRdyIn;
end
always @(muxSIENotPTXB or SIETxWEn or SIETxData or
SIETxCtrl or prcTxByteWEn or prcTxByteData or prcTxByteCtrl or
SIETxFSRate or prcTxByteFSRate)
begin
    if (muxSIENotPTXB  == 1'b1)
    begin
        USBWireWEn <= SIETxWEn;
        TxBits <= SIETxData;
        TxCtl <= SIETxCtrl;
        TxFSRate <= SIETxFSRate;
    end
    else
    begin
        USBWireWEn <= prcTxByteWEn;
        TxBits <= prcTxByteData;
        TxCtl <= prcTxByteCtrl;
        TxFSRate <= prcTxByteFSRate;
    end
end

//--------------------------------------------------------------------
// Machine: txWireArb
//--------------------------------------------------------------------
//----------------------------------
// Next State Logic (combinatorial)
//----------------------------------
always @ (prcTxByteReq or SIETxReq or prcTxByteGnt or muxSIENotPTXB or SIETxGnt or CurrState_txWireArb)
begin : txWireArb_NextState
  NextState_txWireArb <= CurrState_txWireArb;
  // Set default values for outputs and signals
  next_prcTxByteGnt <= prcTxByteGnt;
  next_muxSIENotPTXB <= muxSIENotPTXB;
  next_SIETxGnt <= SIETxGnt;
  case (CurrState_txWireArb)
    `START_TARB:
      NextState_txWireArb <= `TARB_WAIT_REQ;
    `TARB_WAIT_REQ:
      if (prcTxByteReq == 1'b1)	
      begin
        NextState_txWireArb <= `PTXB_ACT;
        next_prcTxByteGnt <= 1'b1;
        next_muxSIENotPTXB <= 1'b0;
      end
      else if (SIETxReq == 1'b1)	
      begin
        NextState_txWireArb <= `SIE_TX_ACT;
        next_SIETxGnt <= 1'b1;
        next_muxSIENotPTXB <= 1'b1;
      end
    `PTXB_ACT:
      if (prcTxByteReq == 1'b0)	
      begin
        NextState_txWireArb <= `TARB_WAIT_REQ;
        next_prcTxByteGnt <= 1'b0;
      end
    `SIE_TX_ACT:
      if (SIETxReq == 1'b0)	
      begin
        NextState_txWireArb <= `TARB_WAIT_REQ;
        next_SIETxGnt <= 1'b0;
      end
  endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : txWireArb_CurrentState
  if (rst)	
    CurrState_txWireArb <= `START_TARB;
  else
    CurrState_txWireArb <= NextState_txWireArb;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : txWireArb_RegOutput
  if (rst)	
  begin
    muxSIENotPTXB <= 1'b0;
    prcTxByteGnt <= 1'b0;
    SIETxGnt <= 1'b0;
  end
  else 
  begin
    muxSIENotPTXB <= next_muxSIENotPTXB;
    prcTxByteGnt <= next_prcTxByteGnt;
    SIETxGnt <= next_SIETxGnt;
  end
end

endmodule