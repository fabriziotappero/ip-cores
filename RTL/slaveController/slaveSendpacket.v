
// File        : ../RTL/slaveController/slaveSendpacket.v
// Generated   : 11/10/06 05:37:26
// From        : ../RTL/slaveController/slaveSendpacket.asf
// By          : FSM2VHDL ver. 5.0.0.9

//////////////////////////////////////////////////////////////////////
////                                                              ////
//// slaveSendPacket
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
//
`include "timescale.v"
`include "usbSerialInterfaceEngine_h.v"
`include "usbConstants_h.v"

module slaveSendPacket (PID, SCTxPortCntl, SCTxPortData, SCTxPortGnt, SCTxPortRdy, SCTxPortReq, SCTxPortWEn, clk, fifoData, fifoEmpty, fifoReadEn, rst, sendPacketRdy, sendPacketWEn);
input   [3:0] PID;
input   SCTxPortGnt;
input   SCTxPortRdy;
input   clk;
input   [7:0] fifoData;
input   fifoEmpty;
input   rst;
input   sendPacketWEn;
output  [7:0] SCTxPortCntl;
output  [7:0] SCTxPortData;
output  SCTxPortReq;
output  SCTxPortWEn;
output  fifoReadEn;
output  sendPacketRdy;

wire    [3:0] PID;
reg     [7:0] SCTxPortCntl, next_SCTxPortCntl;
reg     [7:0] SCTxPortData, next_SCTxPortData;
wire    SCTxPortGnt;
wire    SCTxPortRdy;
reg     SCTxPortReq, next_SCTxPortReq;
reg     SCTxPortWEn, next_SCTxPortWEn;
wire    clk;
wire    [7:0] fifoData;
wire    fifoEmpty;
reg     fifoReadEn, next_fifoReadEn;
wire    rst;
reg     sendPacketRdy, next_sendPacketRdy;
wire    sendPacketWEn;

// diagram signals declarations
reg  [7:0]PIDNotPID;

// BINARY ENCODED state machine: slvSndPkt
// State codes definitions:
`define START_SP1 4'b0000
`define SP_WAIT_ENABLE 4'b0001
`define SP1_WAIT_GNT 4'b0010
`define SP_SEND_PID_WAIT_RDY 4'b0011
`define SP_SEND_PID_FIN 4'b0100
`define FIN_SP1 4'b0101
`define SP_D0_D1_READ_FIFO 4'b0110
`define SP_D0_D1_WAIT_READ_FIFO 4'b0111
`define SP_D0_D1_FIFO_EMPTY 4'b1000
`define SP_D0_D1_FIN 4'b1001
`define SP_D0_D1_TERM_BYTE 4'b1010
`define SP_NOT_DATA 4'b1011
`define SP_D0_D1_CLR_WEN 4'b1100
`define SP_D0_D1_CLR_REN 4'b1101

reg [3:0] CurrState_slvSndPkt;
reg [3:0] NextState_slvSndPkt;

// Diagram actions (continuous assignments allowed only: assign ...)

always @(PID)
begin
    PIDNotPID <=  { (PID ^ 4'hf), PID };
end

//--------------------------------------------------------------------
// Machine: slvSndPkt
//--------------------------------------------------------------------
//----------------------------------
// Next State Logic (combinatorial)
//----------------------------------
always @ (PIDNotPID or fifoData or sendPacketWEn or SCTxPortGnt or SCTxPortRdy or PID or fifoEmpty or sendPacketRdy or SCTxPortReq or SCTxPortWEn or SCTxPortData or SCTxPortCntl or fifoReadEn or CurrState_slvSndPkt)
begin : slvSndPkt_NextState
  NextState_slvSndPkt <= CurrState_slvSndPkt;
  // Set default values for outputs and signals
  next_sendPacketRdy <= sendPacketRdy;
  next_SCTxPortReq <= SCTxPortReq;
  next_SCTxPortWEn <= SCTxPortWEn;
  next_SCTxPortData <= SCTxPortData;
  next_SCTxPortCntl <= SCTxPortCntl;
  next_fifoReadEn <= fifoReadEn;
  case (CurrState_slvSndPkt)
    `START_SP1:
      NextState_slvSndPkt <= `SP_WAIT_ENABLE;
    `SP_WAIT_ENABLE:
      if (sendPacketWEn == 1'b1)	
      begin
        NextState_slvSndPkt <= `SP1_WAIT_GNT;
        next_sendPacketRdy <= 1'b0;
        next_SCTxPortReq <= 1'b1;
      end
    `SP1_WAIT_GNT:
      if (SCTxPortGnt == 1'b1)	
        NextState_slvSndPkt <= `SP_SEND_PID_WAIT_RDY;
    `FIN_SP1:
    begin
      NextState_slvSndPkt <= `SP_WAIT_ENABLE;
      next_sendPacketRdy <= 1'b1;
      next_SCTxPortReq <= 1'b0;
    end
    `SP_NOT_DATA:
      NextState_slvSndPkt <= `FIN_SP1;
    `SP_SEND_PID_WAIT_RDY:
      if (SCTxPortRdy == 1'b1)	
      begin
        NextState_slvSndPkt <= `SP_SEND_PID_FIN;
        next_SCTxPortWEn <= 1'b1;
        next_SCTxPortData <= PIDNotPID;
        next_SCTxPortCntl <= `TX_PACKET_START;
      end
    `SP_SEND_PID_FIN:
    begin
      next_SCTxPortWEn <= 1'b0;
      if (PID == `DATA0 || PID == `DATA1)	
        NextState_slvSndPkt <= `SP_D0_D1_FIFO_EMPTY;
      else
        NextState_slvSndPkt <= `SP_NOT_DATA;
    end
    `SP_D0_D1_READ_FIFO:
    begin
      next_SCTxPortWEn <= 1'b1;
      next_SCTxPortData <= fifoData;
      next_SCTxPortCntl <= `TX_PACKET_STREAM;
      NextState_slvSndPkt <= `SP_D0_D1_CLR_WEN;
    end
    `SP_D0_D1_WAIT_READ_FIFO:
      if (SCTxPortRdy == 1'b1)	
      begin
        NextState_slvSndPkt <= `SP_D0_D1_CLR_REN;
        next_fifoReadEn <= 1'b1;
      end
    `SP_D0_D1_FIFO_EMPTY:
      if (fifoEmpty == 1'b0)	
        NextState_slvSndPkt <= `SP_D0_D1_WAIT_READ_FIFO;
      else
        NextState_slvSndPkt <= `SP_D0_D1_TERM_BYTE;
    `SP_D0_D1_FIN:
    begin
      next_SCTxPortWEn <= 1'b0;
      NextState_slvSndPkt <= `FIN_SP1;
    end
    `SP_D0_D1_TERM_BYTE:
      if (SCTxPortRdy == 1'b1)	
      begin
        NextState_slvSndPkt <= `SP_D0_D1_FIN;
        //Last byte is not valid data,
        //but the 'TX_PACKET_STOP' flag is required
        //by the SIE state machine to detect end of data packet
        next_SCTxPortWEn <= 1'b1;
        next_SCTxPortData <= 8'h00;
        next_SCTxPortCntl <= `TX_PACKET_STOP;
      end
    `SP_D0_D1_CLR_WEN:
    begin
      next_SCTxPortWEn <= 1'b0;
      NextState_slvSndPkt <= `SP_D0_D1_FIFO_EMPTY;
    end
    `SP_D0_D1_CLR_REN:
    begin
      next_fifoReadEn <= 1'b0;
      NextState_slvSndPkt <= `SP_D0_D1_READ_FIFO;
    end
  endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : slvSndPkt_CurrentState
  if (rst)	
    CurrState_slvSndPkt <= `START_SP1;
  else
    CurrState_slvSndPkt <= NextState_slvSndPkt;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : slvSndPkt_RegOutput
  if (rst)	
  begin
    sendPacketRdy <= 1'b1;
    SCTxPortReq <= 1'b0;
    SCTxPortWEn <= 1'b0;
    SCTxPortData <= 8'h00;
    SCTxPortCntl <= 8'h00;
    fifoReadEn <= 1'b0;
  end
  else 
  begin
    sendPacketRdy <= next_sendPacketRdy;
    SCTxPortReq <= next_SCTxPortReq;
    SCTxPortWEn <= next_SCTxPortWEn;
    SCTxPortData <= next_SCTxPortData;
    SCTxPortCntl <= next_SCTxPortCntl;
    fifoReadEn <= next_fifoReadEn;
  end
end

endmodule