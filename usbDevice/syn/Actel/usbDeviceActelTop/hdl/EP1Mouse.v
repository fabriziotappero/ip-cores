
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// EP1Mouse.v                                                 ////
////                                                              ////
//// This file is part of the usbHostSlave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
//// Implements EP1 as a IN endpoint
//// simulating a mouse (a broken one) by 
//// responding to IN requests with a constant (x,y) <= (1,1)
//// which causes the mouse pointer to move from 
//// top left to bottom right of the screen
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
`include "usbHostSlaveReg_define.v"

module EP1Mouse (clk, initComplete, rst, wb_ack, wb_addr, wb_data_i, wb_data_o, wb_stb, wb_we, wbBusGnt, wbBusReq);
input   clk;
input   initComplete;
input   rst;
input   wb_ack;
input   [7:0]wb_data_i;
input   wbBusGnt;
output  [7:0]wb_addr;
output  [7:0]wb_data_o;
output  wb_stb;
output  wb_we;
output  wbBusReq;

wire    clk;
wire    initComplete;
wire    rst;
wire    wb_ack;
reg     [7:0]wb_addr, next_wb_addr;
wire    [7:0]wb_data_i;
reg     [7:0]wb_data_o, next_wb_data_o;
reg     wb_stb, next_wb_stb;
reg     wb_we, next_wb_we;
wire    wbBusGnt;
reg     wbBusReq, next_wbBusReq;

// diagram signals declarations
reg  [7:0]cnt, next_cnt;
reg dataSeq, next_dataSeq;
reg localRst, next_localRst;
reg transDone, next_transDone;

// BINARY ENCODED state machine: EP1St
// State codes definitions:
`define DO_TRANS_WT_GNT 4'b0000
`define DO_TRANS_TX_EMPTY 4'b0001
`define DO_TRANS_WR_TX_FIFO1 4'b0010
`define DO_TRANS_TRANS_GO 4'b0011
`define DO_TRANS_WT_TRANS_DONE_WT_GNT 4'b0100
`define DO_TRANS_WT_TRANS_DONE_GET_RDY_STS 4'b0101
`define DO_TRANS_WT_TRANS_DONE_WT_UNGNT 4'b0110
`define DO_TRANS_WT_TRANS_DONE_CHK_DONE 4'b0111
`define START 4'b1000
`define DO_TRANS_WR_TX_FIFO2 4'b1001
`define DO_TRANS_WR_TX_FIFO3 4'b1010
`define DO_TRANS_WT_TRANS_DONE_DEL 4'b1011

reg [3:0]CurrState_EP1St, NextState_EP1St;

// Diagram actions (continuous assignments allowed only: assign ...)
// diagram ACTION


// Machine: EP1St

// NextState logic (combinatorial)
always @ (wbBusGnt or wb_ack or wb_data_i or transDone or initComplete or cnt or wbBusReq or wb_addr or wb_data_o or wb_stb or wb_we or dataSeq or CurrState_EP1St)
begin
  NextState_EP1St <= CurrState_EP1St;
  // Set default values for outputs and signals
  next_wbBusReq <= wbBusReq;
  next_wb_addr <= wb_addr;
  next_wb_data_o <= wb_data_o;
  next_wb_stb <= wb_stb;
  next_wb_we <= wb_we;
  next_dataSeq <= dataSeq;
  next_transDone <= transDone;
  next_cnt <= cnt;
  case (CurrState_EP1St)  // synopsys parallel_case full_case
    `START:
    begin
      next_wbBusReq <= 1'b0;
      next_wb_addr <= 8'h00;
      next_wb_data_o <= 8'h00;
      next_wb_stb <= 1'b0;
      next_wb_we <= 1'b0;
      next_cnt <= 8'h00;
      next_dataSeq <= 1'b0;
      next_transDone <= 1'b0;
      if (initComplete == 1'b1)
      begin
        NextState_EP1St <= `DO_TRANS_WT_GNT;
      end
    end
    `DO_TRANS_WT_GNT:
    begin
      next_wbBusReq <= 1'b1;
      if (wbBusGnt == 1'b1)
      begin
        NextState_EP1St <= `DO_TRANS_TX_EMPTY;
      end
    end
    `DO_TRANS_TX_EMPTY:
    begin
      next_wb_addr <= `RA_EP1_TX_FIFO_CONTROL_REG;
      next_wb_data_o <= 8'h01;
      //force tx fifo empty
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP1St <= `DO_TRANS_WR_TX_FIFO1;
        next_wb_stb <= 1'b0;
        next_wb_addr <= `RA_EP1_TX_FIFO_DATA_REG;
        next_wb_we <= 1'b1;
      end
    end
    `DO_TRANS_WR_TX_FIFO1:
    begin
      next_wb_data_o <= 8'h00;
      next_wb_stb <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP1St <= `DO_TRANS_WR_TX_FIFO2;
        next_wb_stb <= 1'b0;
      end
    end
    `DO_TRANS_TRANS_GO:
    begin
      next_wb_addr <= `RA_EP1_CONTROL_REG;
      if (dataSeq == 1'b1)
      next_wb_data_o <= 8'h07;
      else
      next_wb_data_o <= 8'h03;
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP1St <= `DO_TRANS_WT_TRANS_DONE_WT_GNT;
        next_wb_stb <= 1'b0;
        if (dataSeq == 1'b1)
        next_dataSeq <= 1'b0;
        else
        next_dataSeq <= 1'b1;
        next_transDone <= 1'b0;
      end
    end
    `DO_TRANS_WR_TX_FIFO2:
    begin
      next_wb_data_o <= 8'h01;
      next_wb_stb <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP1St <= `DO_TRANS_WR_TX_FIFO3;
        next_wb_stb <= 1'b0;
      end
    end
    `DO_TRANS_WR_TX_FIFO3:
    begin
      next_wb_data_o <= 8'h01;
      next_wb_stb <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP1St <= `DO_TRANS_TRANS_GO;
        next_wb_stb <= 1'b0;
      end
    end
    `DO_TRANS_WT_TRANS_DONE_WT_GNT:
    begin
      next_wbBusReq <= 1'b1;
      if (wbBusGnt == 1'b1)
      begin
        NextState_EP1St <= `DO_TRANS_WT_TRANS_DONE_GET_RDY_STS;
      end
    end
    `DO_TRANS_WT_TRANS_DONE_GET_RDY_STS:
    begin
      next_wb_addr <= `RA_EP1_CONTROL_REG;
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b0;
      if (wb_ack == 1'b1)
      begin
        NextState_EP1St <= `DO_TRANS_WT_TRANS_DONE_WT_UNGNT;
        next_wb_stb <= 1'b0;
        next_transDone <= ~wb_data_i[`ENDPOINT_READY_BIT];
      end
    end
    `DO_TRANS_WT_TRANS_DONE_WT_UNGNT:
    begin
      next_wbBusReq <= 1'b0;
      if (wbBusGnt == 1'b0)
      begin
        NextState_EP1St <= `DO_TRANS_WT_TRANS_DONE_CHK_DONE;
      end
    end
    `DO_TRANS_WT_TRANS_DONE_CHK_DONE:
    begin
      if (transDone == 1'b1)
      begin
        NextState_EP1St <= `DO_TRANS_WT_GNT;
      end
      else
      begin
        NextState_EP1St <= `DO_TRANS_WT_TRANS_DONE_DEL;
        next_cnt <= 8'h00;
      end
    end
    `DO_TRANS_WT_TRANS_DONE_DEL:
    begin
      next_cnt <= cnt + 1'b1;
      if (cnt == `ONE_USEC_DEL)
      begin
        NextState_EP1St <= `DO_TRANS_WT_TRANS_DONE_WT_GNT;
      end
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst == 1'b1)
    CurrState_EP1St <= `START;
  else
    CurrState_EP1St <= NextState_EP1St;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst == 1'b1)
  begin
    wbBusReq <= 1'b0;
    wb_addr <= 8'h00;
    wb_data_o <= 8'h00;
    wb_stb <= 1'b0;
    wb_we <= 1'b0;
    dataSeq <= 1'b0;
    transDone <= 1'b0;
    cnt <= 8'h00;
  end
  else 
  begin
    wbBusReq <= next_wbBusReq;
    wb_addr <= next_wb_addr;
    wb_data_o <= next_wb_data_o;
    wb_stb <= next_wb_stb;
    wb_we <= next_wb_we;
    dataSeq <= next_dataSeq;
    transDone <= next_transDone;
    cnt <= next_cnt;
  end
end

endmodule