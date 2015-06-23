
// File        : ../RTL/hostController/softransmit.v
// Generated   : 11/10/06 05:37:21
// From        : ../RTL/hostController/softransmit.asf
// By          : FSM2VHDL ver. 5.0.0.9

//////////////////////////////////////////////////////////////////////
////                                                              ////
//// softransmit
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
`include "usbHostControl_h.v"


module SOFTransmit (SOFEnable, SOFSent, SOFSyncEn, SOFTimerClr, SOFTimer, clk, rst, sendPacketArbiterGnt, sendPacketArbiterReq, sendPacketRdy, sendPacketWEn, fullSpeedRate);
input   SOFEnable;		// After host software asserts SOFEnable, must wait TBD time before asserting SOFSyncEn
input   SOFSyncEn;
input   [15:0] SOFTimer;
input   clk;
input   rst;
input   sendPacketArbiterGnt;
input   sendPacketRdy;
output  SOFSent;		// single cycle pulse
output  SOFTimerClr;		// Single cycle pulse
output  sendPacketArbiterReq;
output  sendPacketWEn;
input   fullSpeedRate;

wire    SOFEnable;
reg     SOFSent, next_SOFSent;
wire    SOFSyncEn;
reg     SOFTimerClr, next_SOFTimerClr;
wire    [15:0] SOFTimer;
wire    clk;
wire    rst;
wire    sendPacketArbiterGnt;
reg     sendPacketArbiterReq, next_sendPacketArbiterReq;
wire    sendPacketRdy;
reg     sendPacketWEn, next_sendPacketWEn;
reg     [15:0] SOFNearTime;

// diagram signals declarations
reg  [7:0]i, next_i;

// BINARY ENCODED state machine: SOFTx
// State codes definitions:
`define START_STX 3'b000
`define WAIT_SOF_NEAR 3'b001
`define WAIT_SP_GNT 3'b010
`define WAIT_SOF_NOW 3'b011
`define SOF_FIN 3'b100
`define DLY_SOF_CHK1 3'b101
`define DLY_SOF_CHK2 3'b110

reg [2:0] CurrState_SOFTx;
reg [2:0] NextState_SOFTx;


//--------------------------------------------------------------------
// Machine: SOFTx
//--------------------------------------------------------------------
//----------------------------------
// Next State Logic (combinatorial)
//----------------------------------
always @ (i or SOFTimer or SOFSyncEn or SOFEnable or sendPacketArbiterGnt or sendPacketRdy or sendPacketArbiterReq or sendPacketWEn or SOFTimerClr or SOFSent or CurrState_SOFTx)
begin : SOFTx_NextState
  NextState_SOFTx <= CurrState_SOFTx;
  // Set default values for outputs and signals
  next_sendPacketArbiterReq <= sendPacketArbiterReq;
  next_sendPacketWEn <= sendPacketWEn;
  next_SOFTimerClr <= SOFTimerClr;
  next_SOFSent <= SOFSent;
  next_i <= i;
  case (CurrState_SOFTx)
    `START_STX:
      NextState_SOFTx <= `WAIT_SOF_NEAR;
    `WAIT_SOF_NEAR:
      if (SOFTimer >= SOFNearTime  ||
        (SOFSyncEn == 1'b1 &&
        SOFEnable == 1'b1))	
      begin
        NextState_SOFTx <= `WAIT_SP_GNT;
        next_sendPacketArbiterReq <= 1'b1;
      end
    `WAIT_SP_GNT:
      if (sendPacketArbiterGnt == 1'b1 && sendPacketRdy == 1'b1)	
        NextState_SOFTx <= `WAIT_SOF_NOW;
    `WAIT_SOF_NOW:
      if (SOFTimer >= `SOF_TX_TIME)	
      begin
        NextState_SOFTx <= `SOF_FIN;
        next_sendPacketWEn <= 1'b1;
        next_SOFTimerClr <= 1'b1;
        next_SOFSent <= 1'b1;
      end
      else if (SOFEnable == 1'b0)	
      begin
        NextState_SOFTx <= `SOF_FIN;
        next_SOFTimerClr <= 1'b1;
      end
    `SOF_FIN:
    begin
      next_sendPacketWEn <= 1'b0;
      next_SOFTimerClr <= 1'b0;
      next_SOFSent <= 1'b0;
      if (sendPacketRdy == 1'b1)	
      begin
        NextState_SOFTx <= `DLY_SOF_CHK1;
        next_i <= 8'h00;
      end
    end
    `DLY_SOF_CHK1:
    begin
      next_i <= i + 1'b1;
      if (i==8'hff)	
      begin
        NextState_SOFTx <= `DLY_SOF_CHK2;
        next_sendPacketArbiterReq <= 1'b0;
        next_i <= 8'h00;
      end
    end
    `DLY_SOF_CHK2:
    begin
      next_i <= i + 1'b1;
      if (i==8'hff)	
        NextState_SOFTx <= `WAIT_SOF_NEAR;
    end
  endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : SOFTx_CurrentState
  if (rst)	
    CurrState_SOFTx <= `START_STX;
  else
    CurrState_SOFTx <= NextState_SOFTx;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : SOFTx_RegOutput
  if (rst)	
  begin
    i <= 8'h00;
    SOFSent <= 1'b0;
    SOFTimerClr <= 1'b0;
    sendPacketArbiterReq <= 1'b0;
    sendPacketWEn <= 1'b0;
    SOFNearTime <= 16'h0000;
  end
  else 
  begin
    i <= next_i;
    SOFSent <= next_SOFSent;
    SOFTimerClr <= next_SOFTimerClr;
    sendPacketArbiterReq <= next_sendPacketArbiterReq;
    sendPacketWEn <= next_sendPacketWEn;
    if (fullSpeedRate == 1'b1)
      SOFNearTime <= `SOF_TX_TIME - `SOF_TX_MARGIN;
    else
      SOFNearTime <= `SOF_TX_TIME - `SOF_TX_MARGIN_LOW_SPEED;
  end
end

endmodule
