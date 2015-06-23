
// File        : ../RTL/serialInterfaceEngine/processRxByte.v
// Generated   : 11/10/06 05:37:22
// From        : ../RTL/serialInterfaceEngine/processRxByte.asf
// By          : FSM2VHDL ver. 5.0.0.9

//////////////////////////////////////////////////////////////////////
////                                                              ////
//// processRxByte
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

module processRxByte (CRC16En, CRC16Result, CRC16UpdateRdy, CRC5En, CRC5Result, CRC5UpdateRdy, CRC5_8Bit, CRCData, RxByteIn, RxCtrlIn, RxCtrlOut, RxDataOutWEn, RxDataOut, clk, processRxByteRdy, processRxDataInWEn, rst, rstCRC);
input   [15:0] CRC16Result;
input   CRC16UpdateRdy;
input   [4:0] CRC5Result;
input   CRC5UpdateRdy;
input   [7:0] RxByteIn;
input   [7:0] RxCtrlIn;
input   clk;
input   processRxDataInWEn;
input   rst;
output  CRC16En;
output  CRC5En;
output  CRC5_8Bit;
output  [7:0] CRCData;
output  [7:0] RxCtrlOut;
output  RxDataOutWEn;
output  [7:0] RxDataOut;
output  processRxByteRdy;
output  rstCRC;

reg     CRC16En, next_CRC16En;
wire    [15:0] CRC16Result;
wire    CRC16UpdateRdy;
reg     CRC5En, next_CRC5En;
wire    [4:0] CRC5Result;
wire    CRC5UpdateRdy;
reg     CRC5_8Bit, next_CRC5_8Bit;
reg     [7:0] CRCData, next_CRCData;
wire    [7:0] RxByteIn;
wire    [7:0] RxCtrlIn;
reg     [7:0] RxCtrlOut, next_RxCtrlOut;
reg     RxDataOutWEn, next_RxDataOutWEn;
reg     [7:0] RxDataOut, next_RxDataOut;
wire    clk;
reg     processRxByteRdy, next_processRxByteRdy;
wire    processRxDataInWEn;
wire    rst;
reg     rstCRC, next_rstCRC;

// diagram signals declarations
reg  ACKRxed, next_ACKRxed;
reg  CRCError, next_CRCError;
reg  NAKRxed, next_NAKRxed;
reg  [2:0]RXByteStMachCurrState, next_RXByteStMachCurrState;
reg  [9:0]RXDataByteCnt, next_RXDataByteCnt;
reg  [7:0]RxByte, next_RxByte;
reg  [7:0]RxCtrl, next_RxCtrl;
reg  RxOverflow, next_RxOverflow;
reg  [7:0]RxStatus;
reg  RxTimeOut, next_RxTimeOut;
reg  Signal1, next_Signal1;
reg  bitStuffError, next_bitStuffError;
reg  dataSequence, next_dataSequence;
reg  stallRxed, next_stallRxed;

// BINARY ENCODED state machine: prRxByte
// State codes definitions:
`define CHK_ST 4'b0000
`define START_PRBY 4'b0001
`define WAIT_BYTE 4'b0010
`define IDLE_CHK_START 4'b0011
`define CHK_SYNC_DO 4'b0100
`define CHK_PID_DO_CHK 4'b0101
`define CHK_PID_FIRST_BYTE_PROC 4'b0110
`define HSHAKE_FIN 4'b0111
`define HSHAKE_CHK 4'b1000
`define TOKEN_CHK_STRM 4'b1001
`define TOKEN_FIN 4'b1010
`define DATA_FIN 4'b1011
`define DATA_CHK_STRM 4'b1100
`define TOKEN_WAIT_CRC 4'b1101
`define DATA_WAIT_CRC 4'b1110

reg [3:0] CurrState_prRxByte;
reg [3:0] NextState_prRxByte;

// Diagram actions (continuous assignments allowed only: assign ...)

always @
(next_CRCError or next_bitStuffError or
  next_RxOverflow or next_NAKRxed or
  next_stallRxed or next_ACKRxed or
  next_dataSequence)
begin
    RxStatus <=
    {1'b0, next_dataSequence,
    next_ACKRxed,
    next_stallRxed, next_NAKRxed,
    next_RxOverflow,
    next_bitStuffError, next_CRCError };
end

//--------------------------------------------------------------------
// Machine: prRxByte
//--------------------------------------------------------------------
//----------------------------------
// Next State Logic (combinatorial)
//----------------------------------
always @ (RxByteIn or RxCtrlIn or RxCtrl or RxStatus or RxByte or RXDataByteCnt or CRC16Result or CRC5Result or RXByteStMachCurrState or processRxDataInWEn or CRC16UpdateRdy or CRC5UpdateRdy or CRCError or bitStuffError or RxOverflow or RxTimeOut or NAKRxed or stallRxed or ACKRxed or dataSequence or RxDataOut or RxCtrlOut or RxDataOutWEn or rstCRC or CRCData or CRC5En or CRC5_8Bit or CRC16En or processRxByteRdy or CurrState_prRxByte)
begin : prRxByte_NextState
  NextState_prRxByte <= CurrState_prRxByte;
  // Set default values for outputs and signals
  next_RxByte <= RxByte;
  next_RxCtrl <= RxCtrl;
  next_RXByteStMachCurrState <= RXByteStMachCurrState;
  next_CRCError <= CRCError;
  next_bitStuffError <= bitStuffError;
  next_RxOverflow <= RxOverflow;
  next_RxTimeOut <= RxTimeOut;
  next_NAKRxed <= NAKRxed;
  next_stallRxed <= stallRxed;
  next_ACKRxed <= ACKRxed;
  next_dataSequence <= dataSequence;
  next_RxDataOut <= RxDataOut;
  next_RxCtrlOut <= RxCtrlOut;
  next_RxDataOutWEn <= RxDataOutWEn;
  next_rstCRC <= rstCRC;
  next_CRCData <= CRCData;
  next_CRC5En <= CRC5En;
  next_CRC5_8Bit <= CRC5_8Bit;
  next_CRC16En <= CRC16En;
  next_RXDataByteCnt <= RXDataByteCnt;
  next_processRxByteRdy <= processRxByteRdy;
  case (CurrState_prRxByte)
    `CHK_ST:
      if (RXByteStMachCurrState == `HS_BYTE_ST)	
        NextState_prRxByte <= `HSHAKE_CHK;
      else if (RXByteStMachCurrState == `TOKEN_BYTE_ST)	
        NextState_prRxByte <= `TOKEN_WAIT_CRC;
      else if (RXByteStMachCurrState == `DATA_BYTE_ST)	
        NextState_prRxByte <= `DATA_WAIT_CRC;
      else if (RXByteStMachCurrState == `IDLE_BYTE_ST)	
        NextState_prRxByte <= `IDLE_CHK_START;
      else if (RXByteStMachCurrState == `CHECK_SYNC_ST)	
        NextState_prRxByte <= `CHK_SYNC_DO;
      else if (RXByteStMachCurrState == `CHECK_PID_ST)	
        NextState_prRxByte <= `CHK_PID_DO_CHK;
    `START_PRBY:
    begin
      next_RxByte <= 8'h00;
      next_RxCtrl <= 8'h00;
      next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
      next_CRCError <= 1'b0;
      next_bitStuffError <= 1'b0;
      next_RxOverflow <= 1'b0;
      next_RxTimeOut <= 1'b0;
      next_NAKRxed <= 1'b0;
      next_stallRxed <= 1'b0;
      next_ACKRxed <= 1'b0;
      next_dataSequence <= 1'b0;
      next_RxDataOut <= 8'h00;
      next_RxCtrlOut <= 8'h00;
      next_RxDataOutWEn <= 1'b0;
      next_rstCRC <= 1'b0;
      next_CRCData <= 8'h00;
      next_CRC5En <= 1'b0;
      next_CRC5_8Bit <= 1'b0;
      next_CRC16En <= 1'b0;
      next_RXDataByteCnt <= 10'h00;
      next_processRxByteRdy <= 1'b1;
      NextState_prRxByte <= `WAIT_BYTE;
    end
    `WAIT_BYTE:
      if (processRxDataInWEn == 1'b1)	
      begin
        NextState_prRxByte <= `CHK_ST;
        next_RxByte <= RxByteIn;
        next_RxCtrl <= RxCtrlIn;
        next_processRxByteRdy <= 1'b0;
      end
    `HSHAKE_FIN:
    begin
      next_RxDataOutWEn <= 1'b0;
      next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
      NextState_prRxByte <= `WAIT_BYTE;
      next_processRxByteRdy <= 1'b1;
    end
    `HSHAKE_CHK:
    begin
      NextState_prRxByte <= `HSHAKE_FIN;
      if (RxCtrl != `DATA_STOP) //If more than PID rxed, then report error
        next_RxOverflow <= 1'b1;
      next_RxDataOut <= RxStatus;
      next_RxCtrlOut <= `RX_PACKET_STOP;
      next_RxDataOutWEn <= 1'b1;
    end
    `CHK_PID_DO_CHK:
      if ((RxByte[7:4] ^ RxByte[3:0] ) != 4'hf)	
      begin
        NextState_prRxByte <= `WAIT_BYTE;
        next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
        next_processRxByteRdy <= 1'b1;
      end
      else
      begin
        NextState_prRxByte <= `CHK_PID_FIRST_BYTE_PROC;
        next_CRCError <= 1'b0;
        next_bitStuffError <= 1'b0;
        next_RxOverflow <= 1'b0;
        next_NAKRxed <= 1'b0;
        next_stallRxed <= 1'b0;
        next_ACKRxed <= 1'b0;
        next_dataSequence <= 1'b0;
        next_RxTimeOut <= 1'b0;
        next_RXDataByteCnt <= 10'h000;
        next_RxDataOut <= RxByte;
        next_RxCtrlOut <= `RX_PACKET_START;
        next_RxDataOutWEn <= 1'b1;
        next_rstCRC <= 1'b1;
      end
    `CHK_PID_FIRST_BYTE_PROC:
    begin
      next_rstCRC <= 1'b0;
      next_RxDataOutWEn <= 1'b0;
      case (RxByte[1:0] )
          `SPECIAL:                              //Special PID.
          next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
          `TOKEN:                                //Token PID
          begin
          next_RXByteStMachCurrState <= `TOKEN_BYTE_ST;
          next_RXDataByteCnt <= 0;
          end
          `HANDSHAKE:                            //Handshake PID
          begin
              case (RxByte[3:2] )
                  2'b00:
              next_ACKRxed <= 1'b1;
                  2'b10:
              next_NAKRxed <= 1'b1;
                  2'b11:
              next_stallRxed <= 1'b1;
                  default:
                  begin
                      $display ("Invalid Handshake PID detected in ProcessRXByte\n");
                  end
              endcase
          next_RXByteStMachCurrState <= `HS_BYTE_ST;
          end
          `DATA:                                  //Data PID
          begin
              case (RxByte[3:2] )
                  2'b00:
              next_dataSequence <= 1'b0;
                  2'b10:
              next_dataSequence <= 1'b1;
                  default:
                      $display ("Invalid DATA PID detected in ProcessRXByte\n");
              endcase
          next_RXByteStMachCurrState <= `DATA_BYTE_ST;
          next_RXDataByteCnt <= 0;
          end
      endcase
      NextState_prRxByte <= `WAIT_BYTE;
      next_processRxByteRdy <= 1'b1;
    end
    `DATA_FIN:
    begin
      next_CRC16En <= 1'b0;
      next_RxDataOutWEn <= 1'b0;
      NextState_prRxByte <= `WAIT_BYTE;
      next_processRxByteRdy <= 1'b1;
    end
    `DATA_CHK_STRM:
    begin
      next_RXDataByteCnt <= RXDataByteCnt + 1'b1;
      case (RxCtrl)
          `DATA_STOP:
          begin
              if (CRC16Result != 16'hb001)
            next_CRCError <= 1'b1;
          next_RxDataOut <= RxStatus;
          next_RxCtrlOut <= `RX_PACKET_STOP;
          next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
          end
          `DATA_BIT_STUFF_ERROR:
          begin
          next_bitStuffError <= 1'b1;
          next_RxDataOut <= RxStatus;
          next_RxCtrlOut <= `RX_PACKET_STOP;
          next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
          end
          `DATA_STREAM:
          begin
          next_RxDataOut <= RxByte;
          next_RxCtrlOut <= `RX_PACKET_STREAM;
          next_CRCData <= RxByte;
          next_CRC16En <= 1'b1;
          end
          default:
          begin
          next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
          end
      endcase
      next_RxDataOutWEn <= 1'b1;
      NextState_prRxByte <= `DATA_FIN;
    end
    `DATA_WAIT_CRC:
      if (CRC16UpdateRdy == 1'b1)	
        NextState_prRxByte <= `DATA_CHK_STRM;
    `TOKEN_CHK_STRM:
    begin
      next_RXDataByteCnt <= RXDataByteCnt + 1'b1;
      case (RxCtrl)
          `DATA_STOP:
          begin
              if (CRC5Result != 5'h6)
            next_CRCError <= 1'b1;
          next_RxDataOut <= RxStatus;
          next_RxCtrlOut <= `RX_PACKET_STOP;
          next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
          end
          `DATA_BIT_STUFF_ERROR:
          begin
          next_bitStuffError <= 1'b1;
          next_RxDataOut <= RxStatus;
          next_RxCtrlOut <= `RX_PACKET_STOP;
          next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
          end
          `DATA_STREAM:
          begin
              if (RXDataByteCnt > 10'h2)
              begin
            next_RxOverflow <= 1'b1;
            next_RxDataOut <= RxStatus;
            next_RxCtrlOut <= `RX_PACKET_STOP;
            next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
              end
              else
              begin
            next_RxDataOut <= RxByte;
            next_RxCtrlOut <= `RX_PACKET_STREAM;
            next_CRCData <= RxByte;
            next_CRC5_8Bit <= 1'b1;
            next_CRC5En <= 1'b1;
              end
          end
          default:
          begin
          next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
          end
      endcase
      next_RxDataOutWEn <= 1'b1;
      NextState_prRxByte <= `TOKEN_FIN;
    end
    `TOKEN_FIN:
    begin
      next_CRC5En <= 1'b0;
      next_RxDataOutWEn <= 1'b0;
      NextState_prRxByte <= `WAIT_BYTE;
      next_processRxByteRdy <= 1'b1;
    end
    `TOKEN_WAIT_CRC:
      if (CRC5UpdateRdy == 1'b1)	
        NextState_prRxByte <= `TOKEN_CHK_STRM;
    `CHK_SYNC_DO:
    begin
      if (RxByte == `SYNC_BYTE)
        next_RXByteStMachCurrState <= `CHECK_PID_ST;
      else
        next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
      NextState_prRxByte <= `WAIT_BYTE;
      next_processRxByteRdy <= 1'b1;
    end
    `IDLE_CHK_START:
    begin
      if (RxCtrl == `DATA_START)
        next_RXByteStMachCurrState <= `CHECK_SYNC_ST;
      NextState_prRxByte <= `WAIT_BYTE;
      next_processRxByteRdy <= 1'b1;
    end
  endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : prRxByte_CurrentState
  if (rst)	
    CurrState_prRxByte <= `START_PRBY;
  else
    CurrState_prRxByte <= NextState_prRxByte;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : prRxByte_RegOutput
  if (rst)	
  begin
    RxByte <= 8'h00;
    RxCtrl <= 8'h00;
    RXByteStMachCurrState <= `IDLE_BYTE_ST;
    CRCError <= 1'b0;
    bitStuffError <= 1'b0;
    RxOverflow <= 1'b0;
    RxTimeOut <= 1'b0;
    NAKRxed <= 1'b0;
    stallRxed <= 1'b0;
    ACKRxed <= 1'b0;
    dataSequence <= 1'b0;
    RXDataByteCnt <= 10'h00;
    RxDataOut <= 8'h00;
    RxCtrlOut <= 8'h00;
    RxDataOutWEn <= 1'b0;
    rstCRC <= 1'b0;
    CRCData <= 8'h00;
    CRC5En <= 1'b0;
    CRC5_8Bit <= 1'b0;
    CRC16En <= 1'b0;
    processRxByteRdy <= 1'b1;
  end
  else 
  begin
    RxByte <= next_RxByte;
    RxCtrl <= next_RxCtrl;
    RXByteStMachCurrState <= next_RXByteStMachCurrState;
    CRCError <= next_CRCError;
    bitStuffError <= next_bitStuffError;
    RxOverflow <= next_RxOverflow;
    RxTimeOut <= next_RxTimeOut;
    NAKRxed <= next_NAKRxed;
    stallRxed <= next_stallRxed;
    ACKRxed <= next_ACKRxed;
    dataSequence <= next_dataSequence;
    RXDataByteCnt <= next_RXDataByteCnt;
    RxDataOut <= next_RxDataOut;
    RxCtrlOut <= next_RxCtrlOut;
    RxDataOutWEn <= next_RxDataOutWEn;
    rstCRC <= next_rstCRC;
    CRCData <= next_CRCData;
    CRC5En <= next_CRC5En;
    CRC5_8Bit <= next_CRC5_8Bit;
    CRC16En <= next_CRC16En;
    processRxByteRdy <= next_processRxByteRdy;
  end
end

endmodule