
// File        : ../RTL/serialInterfaceEngine/siereceiver.v
// Generated   : 11/10/06 05:37:23
// From        : ../RTL/serialInterfaceEngine/siereceiver.asf
// By          : FSM2VHDL ver. 5.0.0.9

//////////////////////////////////////////////////////////////////////
////                                                              ////
//// SIEReceiver
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


module SIEReceiver (RxWireDataIn, RxWireDataWEn, clk, connectState, rst);
input   [1:0] RxWireDataIn;
input   RxWireDataWEn;
input   clk;
input   rst;
output  [1:0] connectState;

wire    [1:0] RxWireDataIn;
wire    RxWireDataWEn;
wire    clk;
reg     [1:0] connectState, next_connectState;
wire    rst;

// diagram signals declarations
reg  [3:0]RXStMachCurrState, next_RXStMachCurrState;
reg  [7:0]RXWaitCount, next_RXWaitCount;
reg  [1:0]RxBits, next_RxBits;

// BINARY ENCODED state machine: rcvr
// State codes definitions:
`define WAIT_FS_CONN_CHK_RX_BITS 4'b0000
`define WAIT_LS_CONN_CHK_RX_BITS 4'b0001
`define LS_CONN_CHK_RX_BITS 4'b0010
`define DISCNCT_CHK_RXBITS 4'b0011
`define WAIT_BIT 4'b0100
`define START_SRX 4'b0101
`define FS_CONN_CHK_RX_BITS1 4'b0110
`define WAIT_LS_DIS_CHK_RX_BITS 4'b0111
`define WAIT_FS_DIS_CHK_RX_BITS2 4'b1000

reg [3:0] CurrState_rcvr;
reg [3:0] NextState_rcvr;


//--------------------------------------------------------------------
// Machine: rcvr
//--------------------------------------------------------------------
//----------------------------------
// Next State Logic (combinatorial)
//----------------------------------
always @ (RxWireDataIn or RxBits or RXWaitCount or RxWireDataWEn or RXStMachCurrState or connectState or CurrState_rcvr)
begin : rcvr_NextState
  NextState_rcvr <= CurrState_rcvr;
  // Set default values for outputs and signals
  next_RxBits <= RxBits;
  next_RXStMachCurrState <= RXStMachCurrState;
  next_RXWaitCount <= RXWaitCount;
  next_connectState <= connectState;
  case (CurrState_rcvr)
    `WAIT_BIT:
      if ((RxWireDataWEn == 1'b1) && (RXStMachCurrState == `WAIT_LOW_SPEED_CONN_ST))	
      begin
        NextState_rcvr <= `WAIT_LS_CONN_CHK_RX_BITS;
        next_RxBits <= RxWireDataIn;
      end
      else if ((RxWireDataWEn == 1'b1) && (RXStMachCurrState == `CONNECT_LOW_SPEED_ST))	
      begin
        NextState_rcvr <= `LS_CONN_CHK_RX_BITS;
        next_RxBits <= RxWireDataIn;
      end
      else if ((RxWireDataWEn == 1'b1) && (RXStMachCurrState == `CONNECT_FULL_SPEED_ST))	
      begin
        NextState_rcvr <= `FS_CONN_CHK_RX_BITS1;
        next_RxBits <= RxWireDataIn;
      end
      else if ((RxWireDataWEn == 1'b1) && (RXStMachCurrState == `WAIT_LOW_SP_DISCONNECT_ST))	
      begin
        NextState_rcvr <= `WAIT_LS_DIS_CHK_RX_BITS;
        next_RxBits <= RxWireDataIn;
      end
      else if ((RxWireDataWEn == 1'b1) && (RXStMachCurrState == `WAIT_FULL_SP_DISCONNECT_ST))	
      begin
        NextState_rcvr <= `WAIT_FS_DIS_CHK_RX_BITS2;
        next_RxBits <= RxWireDataIn;
      end
      else if ((RxWireDataWEn == 1'b1) && (RXStMachCurrState == `DISCONNECT_ST))	
      begin
        NextState_rcvr <= `DISCNCT_CHK_RXBITS;
        next_RxBits <= RxWireDataIn;
      end
      else if ((RxWireDataWEn == 1'b1) && (RXStMachCurrState == `WAIT_FULL_SPEED_CONN_ST))	
      begin
        NextState_rcvr <= `WAIT_FS_CONN_CHK_RX_BITS;
        next_RxBits <= RxWireDataIn;
      end
    `START_SRX:
    begin
      next_RXStMachCurrState <= `DISCONNECT_ST;
      next_RXWaitCount <= 8'h00;
      next_connectState <= `DISCONNECT;
      next_RxBits <= 2'b00;
      NextState_rcvr <= `WAIT_BIT;
    end
    `DISCNCT_CHK_RXBITS:
      if (RxBits == `ZERO_ONE)	
      begin
        NextState_rcvr <= `WAIT_BIT;
        next_RXStMachCurrState <= `WAIT_LOW_SPEED_CONN_ST;
        next_RXWaitCount <= 8'h00;
      end
      else if (RxBits == `ONE_ZERO)	
      begin
        NextState_rcvr <= `WAIT_BIT;
        next_RXStMachCurrState <= `WAIT_FULL_SPEED_CONN_ST;
        next_RXWaitCount <= 8'h00;
      end
      else
        NextState_rcvr <= `WAIT_BIT;
    `WAIT_FS_CONN_CHK_RX_BITS:
    begin
      if (RxBits == `ONE_ZERO)
      begin
        next_RXWaitCount <= RXWaitCount + 1'b1;
          if (RXWaitCount == `CONNECT_WAIT_TIME)
          begin
          next_connectState <= `FULL_SPEED_CONNECT;
          next_RXStMachCurrState <= `CONNECT_FULL_SPEED_ST;
          end
      end
      else
      begin
        next_RXStMachCurrState <= `DISCONNECT_ST;
      end
      NextState_rcvr <= `WAIT_BIT;
    end
    `WAIT_LS_CONN_CHK_RX_BITS:
    begin
      if (RxBits == `ZERO_ONE)
      begin
        next_RXWaitCount <= RXWaitCount + 1'b1;
          if (RXWaitCount == `CONNECT_WAIT_TIME)
          begin
          next_connectState <= `LOW_SPEED_CONNECT;
          next_RXStMachCurrState <= `CONNECT_LOW_SPEED_ST;
          end
      end
      else
      begin
        next_RXStMachCurrState <= `DISCONNECT_ST;
      end
      NextState_rcvr <= `WAIT_BIT;
    end
    `LS_CONN_CHK_RX_BITS:
    begin
      NextState_rcvr <= `WAIT_BIT;
      if (RxBits == `SE0)
      begin
        next_RXStMachCurrState <= `WAIT_LOW_SP_DISCONNECT_ST;
        next_RXWaitCount <= 0;
      end
    end
    `FS_CONN_CHK_RX_BITS1:
    begin
      NextState_rcvr <= `WAIT_BIT;
      if (RxBits == `SE0)
      begin
        next_RXStMachCurrState <= `WAIT_FULL_SP_DISCONNECT_ST;
        next_RXWaitCount <= 0;
      end
    end
    `WAIT_LS_DIS_CHK_RX_BITS:
    begin
      NextState_rcvr <= `WAIT_BIT;
      if (RxBits == `SE0)
      begin
        next_RXWaitCount <= RXWaitCount + 1'b1;
          if (RXWaitCount == `DISCONNECT_WAIT_TIME)
          begin
          next_RXStMachCurrState <= `DISCONNECT_ST;
          next_connectState <= `DISCONNECT;
          end
      end
      else
      begin
        next_RXStMachCurrState <= `CONNECT_LOW_SPEED_ST;
      end
    end
    `WAIT_FS_DIS_CHK_RX_BITS2:
    begin
      NextState_rcvr <= `WAIT_BIT;
      if (RxBits == `SE0)
      begin
        next_RXWaitCount <= RXWaitCount + 1'b1;
          if (RXWaitCount == `DISCONNECT_WAIT_TIME)
          begin
          next_RXStMachCurrState <= `DISCONNECT_ST;
          next_connectState <= `DISCONNECT;
          end
      end
      else
      begin
        next_RXStMachCurrState <= `CONNECT_FULL_SPEED_ST;
      end
    end
  endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : rcvr_CurrentState
  if (rst)	
    CurrState_rcvr <= `START_SRX;
  else
    CurrState_rcvr <= NextState_rcvr;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : rcvr_RegOutput
  if (rst)	
  begin
    RXStMachCurrState <= `DISCONNECT_ST;
    RXWaitCount <= 8'h00;
    RxBits <= 2'b00;
    connectState <= `DISCONNECT;
  end
  else 
  begin
    RXStMachCurrState <= next_RXStMachCurrState;
    RXWaitCount <= next_RXWaitCount;
    RxBits <= next_RxBits;
    connectState <= next_connectState;
  end
end

endmodule