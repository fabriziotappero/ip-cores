
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// hostController
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
`include "usbConstants_h.v"


module hostcontroller (RXStatus, clearTXReq, clk, getPacketREn, getPacketRdy, isoEn, rst, sendPacketArbiterGnt, sendPacketArbiterReq, sendPacketPID, sendPacketRdy, sendPacketWEn, transDone, transReq, transType);
input   [7:0] RXStatus;
input   clk;
input   getPacketRdy;
input   isoEn;
input   rst;
input   sendPacketArbiterGnt;
input   sendPacketRdy;
input   transReq;
input   [1:0] transType;
output  clearTXReq;
output  getPacketREn;
output  sendPacketArbiterReq;
output  [3:0] sendPacketPID;
output  sendPacketWEn;
output  transDone;

wire    [7:0] RXStatus;
reg     clearTXReq, next_clearTXReq;
wire    clk;
reg     getPacketREn, next_getPacketREn;
wire    getPacketRdy;
wire    isoEn;
wire    rst;
wire    sendPacketArbiterGnt;
reg     sendPacketArbiterReq, next_sendPacketArbiterReq;
reg     [3:0] sendPacketPID, next_sendPacketPID;
wire    sendPacketRdy;
reg     sendPacketWEn, next_sendPacketWEn;
reg     transDone, next_transDone;
wire    transReq;
wire    [1:0] transType;

// diagram signals declarations
reg  [3:0]delCnt, next_delCnt;

// BINARY ENCODED state machine: hstCntrl
// State codes definitions:
`define START_HC 6'b000000
`define TX_REQ 6'b000001
`define CHK_TYPE 6'b000010
`define FLAG 6'b000011
`define IN_WAIT_DATA_RXED 6'b000100
`define IN_CHK_FOR_ERROR 6'b000101
`define IN_CLR_SP_WEN2 6'b000110
`define SETUP_CLR_SP_WEN1 6'b000111
`define SETUP_CLR_SP_WEN2 6'b001000
`define FIN 6'b001001
`define WAIT_GNT 6'b001010
`define SETUP_WAIT_PKT_RXED 6'b001011
`define IN_WAIT_IN_SENT 6'b001100
`define OUT0_WAIT_RX_DATA 6'b001101
`define OUT0_WAIT_DATA0_SENT 6'b001110
`define OUT0_WAIT_OUT_SENT 6'b001111
`define SETUP_HC_WAIT_RDY 6'b010000
`define IN_WAIT_SP_RDY1 6'b010001
`define IN_WAIT_SP_RDY2 6'b010010
`define OUT0_WAIT_SP_RDY1 6'b010011
`define SETUP_WAIT_SETUP_SENT 6'b010100
`define SETUP_WAIT_DATA_SENT 6'b010101
`define IN_CLR_SP_WEN1 6'b010110
`define IN_WAIT_ACK_SENT 6'b010111
`define OUT0_CLR_WEN1 6'b011000
`define OUT0_CLR_WEN2 6'b011001
`define OUT1_WAIT_RX_DATA 6'b011010
`define OUT1_WAIT_OUT_SENT 6'b011011
`define OUT1_WAIT_DATA1_SENT 6'b011100
`define OUT1_WAIT_SP_RDY1 6'b011101
`define OUT1_CLR_WEN1 6'b011110
`define OUT1_CLR_WEN2 6'b011111
`define OUT0_CHK_ISO 6'b100000

reg [5:0] CurrState_hstCntrl;
reg [5:0] NextState_hstCntrl;


//--------------------------------------------------------------------
// Machine: hstCntrl
//--------------------------------------------------------------------
//----------------------------------
// Next State Logic (combinatorial)
//----------------------------------
always @ (delCnt or transReq or transType or sendPacketArbiterGnt or getPacketRdy or sendPacketRdy or isoEn or RXStatus or sendPacketArbiterReq or transDone or clearTXReq or sendPacketWEn or getPacketREn or sendPacketPID or CurrState_hstCntrl)
begin : hstCntrl_NextState
  NextState_hstCntrl <= CurrState_hstCntrl;
  // Set default values for outputs and signals
  next_sendPacketArbiterReq <= sendPacketArbiterReq;
  next_transDone <= transDone;
  next_clearTXReq <= clearTXReq;
  next_delCnt <= delCnt;
  next_sendPacketWEn <= sendPacketWEn;
  next_getPacketREn <= getPacketREn;
  next_sendPacketPID <= sendPacketPID;
  case (CurrState_hstCntrl) // synopsys parallel_case full_case
    `START_HC:
      NextState_hstCntrl <= `TX_REQ;
    `TX_REQ:
      if (transReq == 1'b1)	
      begin
        NextState_hstCntrl <= `WAIT_GNT;
        next_sendPacketArbiterReq <= 1'b1;
      end
    `CHK_TYPE:
      if (transType == `IN_TRANS)	
        NextState_hstCntrl <= `IN_WAIT_SP_RDY1;
      else if (transType == `OUTDATA0_TRANS)	
        NextState_hstCntrl <= `OUT0_WAIT_SP_RDY1;
      else if (transType == `OUTDATA1_TRANS)	
        NextState_hstCntrl <= `OUT1_WAIT_SP_RDY1;
      else if (transType == `SETUP_TRANS)	
        NextState_hstCntrl <= `SETUP_HC_WAIT_RDY;
    `FLAG:
    begin
      next_transDone <= 1'b1;
      next_clearTXReq <= 1'b1;
      next_sendPacketArbiterReq <= 1'b0;
      next_delCnt <= 4'h0;
      NextState_hstCntrl <= `FIN;
    end
    `FIN:
    begin
      next_clearTXReq <= 1'b0;
      next_transDone <= 1'b0;
      next_delCnt <= delCnt + 1'b1;
      //now wait for 'transReq' to clear
      if (delCnt == 4'hf)	
        NextState_hstCntrl <= `TX_REQ;
    end
    `WAIT_GNT:
      if (sendPacketArbiterGnt == 1'b1)	
        NextState_hstCntrl <= `CHK_TYPE;
    `SETUP_CLR_SP_WEN1:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_hstCntrl <= `SETUP_WAIT_SETUP_SENT;
    end
    `SETUP_CLR_SP_WEN2:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_hstCntrl <= `SETUP_WAIT_DATA_SENT;
    end
    `SETUP_WAIT_PKT_RXED:
    begin
      next_getPacketREn <= 1'b0;
      if (getPacketRdy == 1'b1)	
        NextState_hstCntrl <= `FLAG;
    end
    `SETUP_HC_WAIT_RDY:
      if (sendPacketRdy == 1'b1)	
      begin
        NextState_hstCntrl <= `SETUP_CLR_SP_WEN1;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `SETUP;
      end
    `SETUP_WAIT_SETUP_SENT:
      if (sendPacketRdy == 1'b1)	
      begin
        NextState_hstCntrl <= `SETUP_CLR_SP_WEN2;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `DATA0;
      end
    `SETUP_WAIT_DATA_SENT:
      if (sendPacketRdy == 1'b1)	
      begin
        NextState_hstCntrl <= `SETUP_WAIT_PKT_RXED;
        next_getPacketREn <= 1'b1;
      end
    `IN_WAIT_DATA_RXED:
    begin
      next_getPacketREn <= 1'b0;
      if (getPacketRdy == 1'b1)	
        NextState_hstCntrl <= `IN_CHK_FOR_ERROR;
    end
    `IN_CHK_FOR_ERROR:
      if (isoEn == 1'b1)	
        NextState_hstCntrl <= `FLAG;
      else if (RXStatus [`HC_CRC_ERROR_BIT] == 1'b0 &&
        RXStatus [`HC_BIT_STUFF_ERROR_BIT] == 1'b0 &&
        RXStatus [`HC_RX_OVERFLOW_BIT] == 1'b0 &&
        RXStatus [`HC_NAK_RXED_BIT] == 1'b0 &&
        RXStatus [`HC_STALL_RXED_BIT] == 1'b0 &&
        RXStatus [`HC_RX_TIME_OUT_BIT] == 1'b0)	
        NextState_hstCntrl <= `IN_WAIT_SP_RDY2;
      else
        NextState_hstCntrl <= `FLAG;
    `IN_CLR_SP_WEN2:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_hstCntrl <= `IN_WAIT_ACK_SENT;
    end
    `IN_WAIT_IN_SENT:
      if (sendPacketRdy == 1'b1)	
      begin
        NextState_hstCntrl <= `IN_WAIT_DATA_RXED;
        next_getPacketREn <= 1'b1;
      end
    `IN_WAIT_SP_RDY1:
      if (sendPacketRdy == 1'b1)	
      begin
        NextState_hstCntrl <= `IN_CLR_SP_WEN1;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `IN;
      end
    `IN_WAIT_SP_RDY2:
      if (sendPacketRdy == 1'b1)	
      begin
        NextState_hstCntrl <= `IN_CLR_SP_WEN2;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `ACK;
      end
    `IN_CLR_SP_WEN1:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_hstCntrl <= `IN_WAIT_IN_SENT;
    end
    `IN_WAIT_ACK_SENT:
      if (sendPacketRdy == 1'b1)	
        NextState_hstCntrl <= `FLAG;
    `OUT0_WAIT_RX_DATA:
    begin
      next_getPacketREn <= 1'b0;
      if (getPacketRdy == 1'b1)	
        NextState_hstCntrl <= `FLAG;
    end
    `OUT0_WAIT_DATA0_SENT:
      if (sendPacketRdy == 1'b1)	
        NextState_hstCntrl <= `OUT0_CHK_ISO;
    `OUT0_WAIT_OUT_SENT:
      if (sendPacketRdy == 1'b1)	
      begin
        NextState_hstCntrl <= `OUT0_CLR_WEN2;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `DATA0;
      end
    `OUT0_WAIT_SP_RDY1:
      if (sendPacketRdy == 1'b1)	
      begin
        NextState_hstCntrl <= `OUT0_CLR_WEN1;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `OUT;
      end
    `OUT0_CLR_WEN1:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_hstCntrl <= `OUT0_WAIT_OUT_SENT;
    end
    `OUT0_CLR_WEN2:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_hstCntrl <= `OUT0_WAIT_DATA0_SENT;
    end
    `OUT0_CHK_ISO:
      if (isoEn == 1'b0)	
      begin
        NextState_hstCntrl <= `OUT0_WAIT_RX_DATA;
        next_getPacketREn <= 1'b1;
      end
      else
        NextState_hstCntrl <= `FLAG;
    `OUT1_WAIT_RX_DATA:
    begin
      next_getPacketREn <= 1'b0;
      if (getPacketRdy == 1'b1)	
        NextState_hstCntrl <= `FLAG;
    end
    `OUT1_WAIT_OUT_SENT:
      if (sendPacketRdy == 1'b1)	
      begin
        NextState_hstCntrl <= `OUT1_CLR_WEN2;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `DATA1;
      end
    `OUT1_WAIT_DATA1_SENT:
      if (sendPacketRdy == 1'b1)	
      begin
        NextState_hstCntrl <= `OUT1_WAIT_RX_DATA;
        next_getPacketREn <= 1'b1;
      end
    `OUT1_WAIT_SP_RDY1:
      if (sendPacketRdy == 1'b1)	
      begin
        NextState_hstCntrl <= `OUT1_CLR_WEN1;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `OUT;
      end
    `OUT1_CLR_WEN1:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_hstCntrl <= `OUT1_WAIT_OUT_SENT;
    end
    `OUT1_CLR_WEN2:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_hstCntrl <= `OUT1_WAIT_DATA1_SENT;
    end
  endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : hstCntrl_CurrentState
  if (rst)	
    CurrState_hstCntrl <= `START_HC;
  else
    CurrState_hstCntrl <= NextState_hstCntrl;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : hstCntrl_RegOutput
  if (rst)	
  begin
    delCnt <= 4'h0;
    transDone <= 1'b0;
    clearTXReq <= 1'b0;
    getPacketREn <= 1'b0;
    sendPacketArbiterReq <= 1'b0;
    sendPacketWEn <= 1'b0;
    sendPacketPID <= 4'b0;
  end
  else 
  begin
    delCnt <= next_delCnt;
    transDone <= next_transDone;
    clearTXReq <= next_clearTXReq;
    getPacketREn <= next_getPacketREn;
    sendPacketArbiterReq <= next_sendPacketArbiterReq;
    sendPacketWEn <= next_sendPacketWEn;
    sendPacketPID <= next_sendPacketPID;
  end
end

endmodule
