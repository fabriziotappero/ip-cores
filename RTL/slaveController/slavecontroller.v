
// File        : ../RTL/slaveController/slavecontroller.v
// Generated   : 11/10/06 05:37:25
// From        : ../RTL/slaveController/slavecontroller.asf
// By          : FSM2VHDL ver. 5.0.0.9

//////////////////////////////////////////////////////////////////////
////                                                              ////
//// slaveController
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
`include "usbSlaveControl_h.v"
`include "usbConstants_h.v"


module slavecontroller (CRCError, NAKSent, RxByte, RxDataWEn, RxOverflow, RxStatus, RxTimeOut, SCGlobalEn, SOFRxed, USBEndPControlReg, USBEndPNakTransTypeReg, USBEndPTransTypeReg, USBEndP, USBTgtAddress, bitStuffError, clk, clrEPRdy, endPMuxErrorsWEn, endPointReadyToGetPkt, frameNum, getPacketREn, getPacketRdy, rst, sendPacketPID, sendPacketRdy, sendPacketWEn, stallSent, transDone);
input   CRCError;
input   [7:0] RxByte;
input   RxDataWEn;
input   RxOverflow;
input   [7:0] RxStatus;
input   RxTimeOut;
input   SCGlobalEn;
input   [4:0] USBEndPControlReg;
input   [6:0] USBTgtAddress;
input   bitStuffError;
input   clk;
input   getPacketRdy;
input   rst;
input   sendPacketRdy;
output  NAKSent;
output  SOFRxed;
output  [1:0] USBEndPNakTransTypeReg;
output  [1:0] USBEndPTransTypeReg;
output  [3:0] USBEndP;
output  clrEPRdy;
output  endPMuxErrorsWEn;
output  endPointReadyToGetPkt;
output  [10:0] frameNum;
output  getPacketREn;
output  [3:0] sendPacketPID;
output  sendPacketWEn;
output  stallSent;
output  transDone;

wire    CRCError;
reg     NAKSent, next_NAKSent;
wire    [7:0] RxByte;
wire    RxDataWEn;
wire    RxOverflow;
wire    [7:0] RxStatus;
wire    RxTimeOut;
wire    SCGlobalEn;
reg     SOFRxed, next_SOFRxed;
wire    [4:0] USBEndPControlReg;
reg     [1:0] USBEndPNakTransTypeReg, next_USBEndPNakTransTypeReg;
reg     [1:0] USBEndPTransTypeReg, next_USBEndPTransTypeReg;
reg     [3:0] USBEndP, next_USBEndP;
wire    [6:0] USBTgtAddress;
wire    bitStuffError;
wire    clk;
reg     clrEPRdy, next_clrEPRdy;
reg     endPMuxErrorsWEn, next_endPMuxErrorsWEn;
reg     endPointReadyToGetPkt, next_endPointReadyToGetPkt;
reg     [10:0] frameNum, next_frameNum;
reg     getPacketREn, next_getPacketREn;
wire    getPacketRdy;
wire    rst;
reg     [3:0] sendPacketPID, next_sendPacketPID;
wire    sendPacketRdy;
reg     sendPacketWEn, next_sendPacketWEn;
reg     stallSent, next_stallSent;
reg     transDone, next_transDone;

// diagram signals declarations
reg  [7:0]PIDByte, next_PIDByte;
reg  [6:0]USBAddress, next_USBAddress;
reg  [4:0]USBEndPControlRegCopy, next_USBEndPControlRegCopy;
reg  [7:0]addrEndPTemp, next_addrEndPTemp;
reg  [7:0]endpCRCTemp, next_endpCRCTemp;
reg  [1:0]tempUSBEndPTransTypeReg, next_tempUSBEndPTransTypeReg;

// BINARY ENCODED state machine: slvCntrl
// State codes definitions:
`define WAIT_RX1 5'b00000
`define FIN_SC 5'b00001
`define GET_TOKEN_WAIT_CRC 5'b00010
`define GET_TOKEN_WAIT_ADDR 5'b00011
`define GET_TOKEN_WAIT_STOP 5'b00100
`define CHK_PID 5'b00101
`define GET_TOKEN_CHK_SOF 5'b00110
`define PID_ERROR 5'b00111
`define CHK_RDY 5'b01000
`define IN_NAK_STALL 5'b01001
`define IN_CHK_RDY 5'b01010
`define SETUP_OUT_CHK 5'b01011
`define SETUP_OUT_SEND 5'b01100
`define SETUP_OUT_GET_PKT 5'b01101
`define START_S1 5'b01110
`define GET_TOKEN_DELAY 5'b01111
`define GET_TOKEN_CHK_ADDR 5'b10000
`define IN_RESP_GET_RESP 5'b10001
`define IN_RESP_DATA 5'b10010
`define IN_RESP_CHK_ISO 5'b10011

reg [4:0] CurrState_slvCntrl;
reg [4:0] NextState_slvCntrl;


//--------------------------------------------------------------------
// Machine: slvCntrl
//--------------------------------------------------------------------
//----------------------------------
// Next State Logic (combinatorial)
//----------------------------------
always @ (RxByte or tempUSBEndPTransTypeReg or endpCRCTemp or addrEndPTemp or USBEndPControlReg or RxDataWEn or RxStatus or PIDByte or USBEndPControlRegCopy or NAKSent or sendPacketRdy or getPacketRdy or CRCError or bitStuffError or RxOverflow or RxTimeOut or USBEndP or USBAddress or USBTgtAddress or SCGlobalEn or stallSent or SOFRxed or transDone or clrEPRdy or endPMuxErrorsWEn or getPacketREn or sendPacketWEn or sendPacketPID or USBEndPTransTypeReg or USBEndPNakTransTypeReg or frameNum or endPointReadyToGetPkt or CurrState_slvCntrl)
begin : slvCntrl_NextState
  NextState_slvCntrl <= CurrState_slvCntrl;
  // Set default values for outputs and signals
  next_stallSent <= stallSent;
  next_NAKSent <= NAKSent;
  next_SOFRxed <= SOFRxed;
  next_PIDByte <= PIDByte;
  next_transDone <= transDone;
  next_clrEPRdy <= clrEPRdy;
  next_endPMuxErrorsWEn <= endPMuxErrorsWEn;
  next_tempUSBEndPTransTypeReg <= tempUSBEndPTransTypeReg;
  next_getPacketREn <= getPacketREn;
  next_sendPacketWEn <= sendPacketWEn;
  next_sendPacketPID <= sendPacketPID;
  next_USBEndPTransTypeReg <= USBEndPTransTypeReg;
  next_USBEndPNakTransTypeReg <= USBEndPNakTransTypeReg;
  next_endpCRCTemp <= endpCRCTemp;
  next_addrEndPTemp <= addrEndPTemp;
  next_frameNum <= frameNum;
  next_USBAddress <= USBAddress;
  next_USBEndP <= USBEndP;
  next_USBEndPControlRegCopy <= USBEndPControlRegCopy;
  next_endPointReadyToGetPkt <= endPointReadyToGetPkt;
  case (CurrState_slvCntrl)
    `WAIT_RX1:
    begin
      next_stallSent <= 1'b0;
      next_NAKSent <= 1'b0;
      next_SOFRxed <= 1'b0;
      if (RxDataWEn == 1'b1 && 
        RxStatus == `RX_PACKET_START && 
        RxByte[1:0] == `TOKEN)	
      begin
        NextState_slvCntrl <= `GET_TOKEN_WAIT_ADDR;
        next_PIDByte <= RxByte;
      end
    end
    `FIN_SC:
    begin
      next_transDone <= 1'b0;
      next_clrEPRdy <= 1'b0;
      next_endPMuxErrorsWEn <= 1'b0;
      NextState_slvCntrl <= `WAIT_RX1;
    end
    `CHK_PID:
      if (PIDByte[3:0] == `SETUP)	
      begin
        NextState_slvCntrl <= `SETUP_OUT_GET_PKT;
        next_tempUSBEndPTransTypeReg <= `SC_SETUP_TRANS;
        next_getPacketREn <= 1'b1;
      end
      else if (PIDByte[3:0] == `OUT)	
      begin
        NextState_slvCntrl <= `SETUP_OUT_GET_PKT;
        next_tempUSBEndPTransTypeReg <= `SC_OUTDATA_TRANS;
        next_getPacketREn <= 1'b1;
      end
      else if ((PIDByte[3:0] == `IN) && (USBEndPControlRegCopy[`ENDPOINT_ISO_ENABLE_BIT] == 1'b0))	
      begin
        NextState_slvCntrl <= `IN_CHK_RDY;
        next_tempUSBEndPTransTypeReg <= `SC_IN_TRANS;
      end
      else if (((PIDByte[3:0] == `IN) && (USBEndPControlRegCopy [`ENDPOINT_READY_BIT] == 1'b1)) && (USBEndPControlRegCopy [`ENDPOINT_OUTDATA_SEQUENCE_BIT] == 1'b0))	
      begin
        NextState_slvCntrl <= `IN_RESP_DATA;
        next_tempUSBEndPTransTypeReg <= `SC_IN_TRANS;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `DATA0;
      end
      else if ((PIDByte[3:0] == `IN) && (USBEndPControlRegCopy [`ENDPOINT_READY_BIT] == 1'b1))	
      begin
        NextState_slvCntrl <= `IN_RESP_DATA;
        next_tempUSBEndPTransTypeReg <= `SC_IN_TRANS;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `DATA1;
      end
      else if (PIDByte[3:0] == `IN)	
      begin
        NextState_slvCntrl <= `CHK_RDY;
        next_tempUSBEndPTransTypeReg <= `SC_IN_TRANS;
      end
      else
        NextState_slvCntrl <= `PID_ERROR;
    `PID_ERROR:
      NextState_slvCntrl <= `WAIT_RX1;
    `CHK_RDY:
      if (USBEndPControlRegCopy [`ENDPOINT_READY_BIT] == 1'b1)	
      begin
        NextState_slvCntrl <= `FIN_SC;
        next_transDone <= 1'b1;
        next_clrEPRdy <= 1'b1;
        next_USBEndPTransTypeReg <= tempUSBEndPTransTypeReg;
        next_endPMuxErrorsWEn <= 1'b1;
      end
      else if (NAKSent == 1'b1)	
      begin
        NextState_slvCntrl <= `FIN_SC;
        next_USBEndPNakTransTypeReg <= tempUSBEndPTransTypeReg;
        next_endPMuxErrorsWEn <= 1'b1;
      end
      else
        NextState_slvCntrl <= `FIN_SC;
    `SETUP_OUT_CHK:
      if (USBEndPControlRegCopy [`ENDPOINT_READY_BIT] == 1'b0)	
      begin
        NextState_slvCntrl <= `SETUP_OUT_SEND;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `NAK;
        next_NAKSent <= 1'b1;
      end
      else if (USBEndPControlRegCopy [`ENDPOINT_SEND_STALL_BIT] == 1'b1)	
      begin
        NextState_slvCntrl <= `SETUP_OUT_SEND;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `STALL;
        next_stallSent <= 1'b1;
      end
      else
      begin
        NextState_slvCntrl <= `SETUP_OUT_SEND;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `ACK;
      end
    `SETUP_OUT_SEND:
    begin
      next_sendPacketWEn <= 1'b0;
      if (sendPacketRdy == 1'b1)	
        NextState_slvCntrl <= `CHK_RDY;
    end
    `SETUP_OUT_GET_PKT:
    begin
      next_getPacketREn <= 1'b0;
      if ((getPacketRdy == 1'b1) && (USBEndPControlRegCopy [`ENDPOINT_ISO_ENABLE_BIT] == 1'b1))	
        NextState_slvCntrl <= `CHK_RDY;
      else if ((getPacketRdy == 1'b1) && (CRCError == 1'b0 &&
        bitStuffError == 1'b0 && 
        RxOverflow == 1'b0 && 
        RxTimeOut == 1'b0))	
        NextState_slvCntrl <= `SETUP_OUT_CHK;
      else if (getPacketRdy == 1'b1)	
        NextState_slvCntrl <= `CHK_RDY;
    end
    `IN_NAK_STALL:
    begin
      next_sendPacketWEn <= 1'b0;
      if (sendPacketRdy == 1'b1)	
        NextState_slvCntrl <= `CHK_RDY;
    end
    `IN_CHK_RDY:
      if (USBEndPControlRegCopy [`ENDPOINT_READY_BIT] == 1'b0)	
      begin
        NextState_slvCntrl <= `IN_NAK_STALL;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `NAK;
        next_NAKSent <= 1'b1;
      end
      else if (USBEndPControlRegCopy [`ENDPOINT_SEND_STALL_BIT] == 1'b1)	
      begin
        NextState_slvCntrl <= `IN_NAK_STALL;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `STALL;
        next_stallSent <= 1'b1;
      end
      else if (USBEndPControlRegCopy [`ENDPOINT_OUTDATA_SEQUENCE_BIT] == 1'b0)	
      begin
        NextState_slvCntrl <= `IN_RESP_DATA;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `DATA0;
      end
      else
      begin
        NextState_slvCntrl <= `IN_RESP_DATA;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `DATA1;
      end
    `IN_RESP_GET_RESP:
    begin
      next_getPacketREn <= 1'b0;
      if (getPacketRdy == 1'b1)	
        NextState_slvCntrl <= `CHK_RDY;
    end
    `IN_RESP_DATA:
    begin
      next_sendPacketWEn <= 1'b0;
      if (sendPacketRdy == 1'b1)	
        NextState_slvCntrl <= `IN_RESP_CHK_ISO;
    end
    `IN_RESP_CHK_ISO:
      if (USBEndPControlRegCopy [`ENDPOINT_ISO_ENABLE_BIT] == 1'b1)	
        NextState_slvCntrl <= `CHK_RDY;
      else
      begin
        NextState_slvCntrl <= `IN_RESP_GET_RESP;
        next_getPacketREn <= 1'b1;
      end
    `START_S1:
      NextState_slvCntrl <= `WAIT_RX1;
    `GET_TOKEN_WAIT_CRC:
      if (RxDataWEn == 1'b1 && 
        RxStatus == `RX_PACKET_STREAM)	
      begin
        NextState_slvCntrl <= `GET_TOKEN_WAIT_STOP;
        next_endpCRCTemp <= RxByte;
      end
      else if (RxDataWEn == 1'b1 && 
        RxStatus != `RX_PACKET_STREAM)	
        NextState_slvCntrl <= `WAIT_RX1;
    `GET_TOKEN_WAIT_ADDR:
      if (RxDataWEn == 1'b1 && 
        RxStatus == `RX_PACKET_STREAM)	
      begin
        NextState_slvCntrl <= `GET_TOKEN_WAIT_CRC;
        next_addrEndPTemp <= RxByte;
      end
      else if (RxDataWEn == 1'b1 && 
        RxStatus != `RX_PACKET_STREAM)	
        NextState_slvCntrl <= `WAIT_RX1;
    `GET_TOKEN_WAIT_STOP:
      if ((RxDataWEn == 1'b1) && (RxByte[`CRC_ERROR_BIT] == 1'b0 &&
        RxByte[`BIT_STUFF_ERROR_BIT] == 1'b0 &&
        RxByte [`RX_OVERFLOW_BIT] == 1'b0))	
        NextState_slvCntrl <= `GET_TOKEN_CHK_SOF;
      else if (RxDataWEn == 1'b1)	
        NextState_slvCntrl <= `WAIT_RX1;
    `GET_TOKEN_CHK_SOF:
      if (PIDByte[3:0] == `SOF)	
      begin
        NextState_slvCntrl <= `WAIT_RX1;
        next_frameNum <= {endpCRCTemp[2:0],addrEndPTemp};
        next_SOFRxed <= 1'b1;
      end
      else
      begin
        NextState_slvCntrl <= `GET_TOKEN_DELAY;
        next_USBAddress <= addrEndPTemp[6:0];
        next_USBEndP <= { endpCRCTemp[2:0], addrEndPTemp[7]};
      end
    `GET_TOKEN_DELAY:    // Insert delay to allow USBEndP etc to update
      NextState_slvCntrl <= `GET_TOKEN_CHK_ADDR;
    `GET_TOKEN_CHK_ADDR:
      if (USBEndP < `NUM_OF_ENDPOINTS  &&
        USBAddress == USBTgtAddress &&
        SCGlobalEn == 1'b1 &&
        USBEndPControlReg[`ENDPOINT_ENABLE_BIT] == 1'b1)	
      begin
        NextState_slvCntrl <= `CHK_PID;
        next_USBEndPControlRegCopy <= USBEndPControlReg;
        next_endPointReadyToGetPkt <= USBEndPControlReg [`ENDPOINT_READY_BIT];
      end
      else
        NextState_slvCntrl <= `WAIT_RX1;
  endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : slvCntrl_CurrentState
  if (rst)	
    CurrState_slvCntrl <= `START_S1;
  else
    CurrState_slvCntrl <= NextState_slvCntrl;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : slvCntrl_RegOutput
  if (rst)	
  begin
    tempUSBEndPTransTypeReg <= 2'b00;
    addrEndPTemp <= 8'h00;
    endpCRCTemp <= 8'h00;
    USBAddress <= 7'b0000000;
    PIDByte <= 8'h00;
    USBEndPControlRegCopy <= 5'b00000;
    transDone <= 1'b0;
    getPacketREn <= 1'b0;
    sendPacketPID <= 4'b0;
    sendPacketWEn <= 1'b0;
    clrEPRdy <= 1'b0;
    USBEndPTransTypeReg <= 2'b00;
    USBEndPNakTransTypeReg <= 2'b00;
    NAKSent <= 1'b0;
    stallSent <= 1'b0;
    SOFRxed <= 1'b0;
    endPMuxErrorsWEn <= 1'b0;
    frameNum <= 11'b00000000000;
    USBEndP <= 4'h0;
    endPointReadyToGetPkt <= 1'b0;
  end
  else 
  begin
    tempUSBEndPTransTypeReg <= next_tempUSBEndPTransTypeReg;
    addrEndPTemp <= next_addrEndPTemp;
    endpCRCTemp <= next_endpCRCTemp;
    USBAddress <= next_USBAddress;
    PIDByte <= next_PIDByte;
    USBEndPControlRegCopy <= next_USBEndPControlRegCopy;
    transDone <= next_transDone;
    getPacketREn <= next_getPacketREn;
    sendPacketPID <= next_sendPacketPID;
    sendPacketWEn <= next_sendPacketWEn;
    clrEPRdy <= next_clrEPRdy;
    USBEndPTransTypeReg <= next_USBEndPTransTypeReg;
    USBEndPNakTransTypeReg <= next_USBEndPNakTransTypeReg;
    NAKSent <= next_NAKSent;
    stallSent <= next_stallSent;
    SOFRxed <= next_SOFRxed;
    endPMuxErrorsWEn <= next_endPMuxErrorsWEn;
    frameNum <= next_frameNum;
    USBEndP <= next_USBEndP;
    endPointReadyToGetPkt <= next_endPointReadyToGetPkt;
  end
end

endmodule