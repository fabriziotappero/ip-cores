
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// checkLineState.v                                 ////
////                                                              ////
//// This file is part of the usbHostSlave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
//// Checks USB line state. When reset state detected
//// asserts usbRstDet for one clock tick
//// usbRstDet is used to reset most of the logic.
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
//// Copyright (C) 2008 Steve Fielding and OPENCORES.ORG          ////
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
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
`include "timescale.v"
`include "usbSlaveControl_h.v"
`include "usbHostSlaveReg_define.v"
`include "usbSerialInterfaceEngine_h.v"
`include "usbDevice_define.v"
module checkLineState (clk, initComplete, rst, usbRstDet, wb_ack, wb_addr, wb_data_i, wb_stb, wb_we, wbBusGnt, wbBusReq);
input   clk;
input   initComplete;
input   rst;
input   wb_ack;
input   [7:0]wb_data_i;
input   wbBusGnt;
output  usbRstDet;
output  [7:0]wb_addr;
output  wb_stb;
output  wb_we;
output  wbBusReq;

wire    clk;
wire    initComplete;
wire    rst;
reg     usbRstDet, next_usbRstDet;
wire    wb_ack;
reg     [7:0]wb_addr, next_wb_addr;
wire    [7:0]wb_data_i;
reg     wb_stb, next_wb_stb;
reg     wb_we, next_wb_we;
wire    wbBusGnt;
reg     wbBusReq, next_wbBusReq;

// diagram signals declarations
reg  [15:0]cnt, next_cnt;
reg  [1:0]resetState, next_resetState;

// BINARY ENCODED state machine: chkLSt
// State codes definitions:
`define START 3'b000
`define GET_STAT 3'b001
`define WT_GNT 3'b010
`define SET_RST_DET 3'b011
`define DEL_ONE_MSEC 3'b100

reg [2:0]CurrState_chkLSt, NextState_chkLSt;

// Diagram actions (continuous assignments allowed only: assign ...)
// diagram ACTION


// Machine: chkLSt

// NextState logic (combinatorial)
always @ (initComplete or wb_ack or resetState or wbBusGnt or cnt or usbRstDet or wbBusReq or wb_addr or wb_stb or wb_we or CurrState_chkLSt)
begin
  NextState_chkLSt <= CurrState_chkLSt;
  // Set default values for outputs and signals
  next_usbRstDet <= usbRstDet;
  next_wbBusReq <= wbBusReq;
  next_wb_addr <= wb_addr;
  next_wb_stb <= wb_stb;
  next_wb_we <= wb_we;
  next_cnt <= cnt;
  next_resetState <= resetState;
  case (CurrState_chkLSt)  // synopsys parallel_case full_case
    `START:
    begin
      next_usbRstDet <= 1'b0;
      next_wbBusReq <= 1'b0;
      next_wb_addr <= 8'h00;
      next_wb_stb <= 1'b0;
      next_wb_we <= 1'b0;
      next_cnt <= 16'h0000;
      next_resetState <= 2'b00;
      if (initComplete == 1'b1)
      begin
        NextState_chkLSt <= `WT_GNT;
      end
    end
    `GET_STAT:
    begin
      next_wb_addr <= `RA_SC_LINE_STATUS_REG;
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_chkLSt <= `SET_RST_DET;
        next_wb_stb <= 1'b0;
        if ( (wb_data_i[1:0] == `DISCONNECT) || (wb_data_i[`VBUS_PRES_BIT] == 1'b0) )
        next_resetState <= {resetState[0], 1'b1};
        else
        next_resetState <= 2'b00;
        next_wbBusReq <= 1'b0;
      end
    end
    `WT_GNT:
    begin
      next_wbBusReq <= 1'b1;
      if (wbBusGnt == 1'b1)
      begin
        NextState_chkLSt <= `GET_STAT;
      end
    end
    `SET_RST_DET:
    begin
      NextState_chkLSt <= `DEL_ONE_MSEC;
      if (resetState == 2'b11) // if reset condition aserted for 2mS
      next_usbRstDet <= 1'b1;
      next_cnt <= 16'h0000;
    end
    `DEL_ONE_MSEC:
    begin
      next_cnt <= cnt + 1'b1;
      next_usbRstDet <= 1'b0;
      if (cnt == `ONE_MSEC_DEL)
      begin
        NextState_chkLSt <= `WT_GNT;
      end
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst == 1'b1)
    CurrState_chkLSt <= `START;
  else
    CurrState_chkLSt <= NextState_chkLSt;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst == 1'b1)
  begin
    usbRstDet <= 1'b0;
    wbBusReq <= 1'b0;
    wb_addr <= 8'h00;
    wb_stb <= 1'b0;
    wb_we <= 1'b0;
    cnt <= 16'h0000;
    resetState <= 2'b00;
  end
  else 
  begin
    usbRstDet <= next_usbRstDet;
    wbBusReq <= next_wbBusReq;
    wb_addr <= next_wb_addr;
    wb_stb <= next_wb_stb;
    wb_we <= next_wb_we;
    cnt <= next_cnt;
    resetState <= next_resetState;
  end
end

endmodule