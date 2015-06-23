
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// EP0.v                                                 ////
////                                                              ////
//// This file is part of the usbHostSlave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
//// Implements EP0 control endpoint
//// Responds to 8-byte SETUP packets
//// of type GET_STATUS, GET_DESCRIPTOR and
//// SET_ADDRESS
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
`include "usbDevice_define.v"


module EP0 (clk, initComplete, memAddr, memData, memRdEn, rst, wb_ack, wb_addr, wb_data_i, wb_data_o, wb_stb, wb_we, wbBusGnt, wbBusReq);
input   clk;
input   [7:0]memData;
input   rst;
input   wb_ack;
input   [7:0]wb_data_i;
input   wbBusGnt;
output  initComplete;
output  [7:0]memAddr;
output  memRdEn;
output  [7:0]wb_addr;
output  [7:0]wb_data_o;
output  wb_stb;
output  wb_we;
output  wbBusReq;

wire    clk;
reg     initComplete, next_initComplete;
reg     [7:0]memAddr, next_memAddr;
wire    [7:0]memData;
reg     memRdEn, next_memRdEn;
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
reg bm_req_dir, next_bm_req_dir;
reg  [4:0]bm_req_recp, next_bm_req_recp;
reg  [1:0]bm_req_type, next_bm_req_type;
reg  [7:0]bRequest, next_bRequest;
reg  [7:0]cnt, next_cnt;
reg dataSeq, next_dataSeq;
reg  [7:0]epStatus, next_epStatus;
reg  [7:0]epTransType, next_epTransType;
reg localRst, next_localRst;
reg  [15:0]rxDataSize, next_rxDataSize;
reg transDone, next_transDone;
reg  [7:0]txDataIndex, next_txDataIndex;
reg  [7:0]txDataSize, next_txDataSize;
reg  [7:0]txPacketRemSize, next_txPacketRemSize;
reg updateUSBAddress, next_updateUSBAddress;
reg  [7:0]USBAddress, next_USBAddress;
reg  [15:0]wIndex, next_wIndex;
reg  [15:0]wLength, next_wLength;
reg  [15:0]wValue, next_wValue;

// BINARY ENCODED state machine: EP0St
// State codes definitions:
`define INIT_RST 6'b000000
`define INIT_WT_GNT 6'b000001
`define INIT_WT_RST 6'b000010
`define INIT_WT_VBUS 6'b000011
`define INIT_FIN 6'b000100
`define DO_TRANS_WT_GNT 6'b000101
`define DO_TRANS_TX_EMPTY 6'b000110
`define DO_TRANS_WR_TX_FIFO 6'b000111
`define DO_TRANS_RD_MEM 6'b001000
`define DO_TRANS_CHK_TX_DONE 6'b001001
`define DO_TRANS_TRANS_GO 6'b001010
`define DO_TRANS_WT_TRANS_DONE_WT_GNT 6'b001011
`define DO_TRANS_WT_TRANS_DONE_GET_RDY_STS 6'b001100
`define DO_TRANS_WT_TRANS_DONE_WT_UNGNT 6'b001101
`define DO_TRANS_WT_TRANS_DONE_CHK_DONE 6'b001110
`define CHK_TRANS_RD_STAT 6'b001111
`define CHK_TRANS_WT_GNT 6'b010000
`define CHK_TRANS_RD_RX_SIZE1 6'b010001
`define CHK_TRANS_RD_RX_SIZE2 6'b010010
`define CHK_TRANS_RD_TRANS_TYPE 6'b010011
`define CHK_TRANS_WT_UNGNT 6'b010100
`define SETUP_CHK_ERR 6'b010101
`define SETUP_GET_DATA_DAT1 6'b010110
`define SETUP_GET_DATA_WT_GNT 6'b010111
`define SETUP_GET_DATA_DAT2 6'b011000
`define SETUP_GET_DATA_DAT3 6'b011001
`define SETUP_GET_DATA_DAT4 6'b011010
`define SETUP_GET_DATA_DAT6 6'b011011
`define SETUP_GET_DATA_DAT5 6'b011100
`define SETUP_GET_DATA_DAT8 6'b011101
`define SETUP_GET_DATA_DAT7 6'b011110
`define SETUP_GET_DATA_WT_UNGNT 6'b011111
`define SETUP_GET_STAT 6'b100000
`define SETUP_SET_ADDR 6'b100001
`define SETUP_GET_DESC_S1 6'b100010
`define SETUP_CHK_MAX_LEN 6'b100011
`define OUT_CHK_SEQ 6'b100100
`define IN_CHK_ACK 6'b100101
`define IN_SET_PTR 6'b100110
`define IN_SET_ADDR 6'b100111
`define IN_WT_GNT 6'b101000
`define IN_WT_UNGNT 6'b101001
`define DO_TRANS_RX_EMPTY 6'b101010
`define DO_TRANS_WT_TRANS_DONE_DEL 6'b101011
`define START 6'b101100
`define INIT_CONN 6'b101101
`define INIT_WT_CONN 6'b101110
`define DO_TRANS_DEL 6'b101111
`define SETUP_PTR_SET 6'b110000

reg [5:0]CurrState_EP0St, NextState_EP0St;

// Diagram actions (continuous assignments allowed only: assign ...)
// diagram ACTION


// Machine: EP0St

// NextState logic (combinatorial)
always @ (wb_ack or wbBusGnt or cnt or wb_data_i or memData or txDataIndex or txDataSize or transDone or epStatus or epTransType or rxDataSize or bRequest or wValue or wLength or dataSeq or updateUSBAddress or txPacketRemSize or USBAddress or wb_addr or wb_data_o or wb_stb or wb_we or wbBusReq or initComplete or memAddr or memRdEn or bm_req_dir or bm_req_type or bm_req_recp or wIndex or CurrState_EP0St)
begin
  NextState_EP0St <= CurrState_EP0St;
  // Set default values for outputs and signals
  next_wb_addr <= wb_addr;
  next_wb_data_o <= wb_data_o;
  next_wb_stb <= wb_stb;
  next_wb_we <= wb_we;
  next_cnt <= cnt;
  next_wbBusReq <= wbBusReq;
  next_initComplete <= initComplete;
  next_memAddr <= memAddr;
  next_memRdEn <= memRdEn;
  next_txDataSize <= txDataSize;
  next_txDataIndex <= txDataIndex;
  next_transDone <= transDone;
  next_epStatus <= epStatus;
  next_rxDataSize <= rxDataSize;
  next_epTransType <= epTransType;
  next_bm_req_dir <= bm_req_dir;
  next_bm_req_type <= bm_req_type;
  next_bm_req_recp <= bm_req_recp;
  next_bRequest <= bRequest;
  next_wValue <= wValue;
  next_wIndex <= wIndex;
  next_wLength <= wLength;
  next_txPacketRemSize <= txPacketRemSize;
  next_USBAddress <= USBAddress;
  next_updateUSBAddress <= updateUSBAddress;
  next_dataSeq <= dataSeq;
  case (CurrState_EP0St)  // synopsys parallel_case full_case
    `START:
    begin
      next_initComplete <= 1'b0;
      next_wbBusReq <= 1'b0;
      next_wb_addr <= 8'h00;
      next_wb_data_o <= 8'h00;
      next_wb_stb <= 1'b0;
      next_wb_we <= 1'b0;
      next_txPacketRemSize <= 8'h00;
      next_txDataSize <= 8'h00;
      next_txDataIndex <= 8'h00;
      next_epTransType <= 8'h00;
      next_epStatus <= 8'h00;
      next_rxDataSize <= 16'h0000;
      next_cnt <= 8'h00;
      next_memRdEn <= 1'b0;
      next_memAddr <= 8'h00;
      next_updateUSBAddress <= 1'b0;
      next_transDone <= 1'b0;
      next_bm_req_type <= 2'b00;
      next_bm_req_dir <= 1'b0;
      next_bm_req_recp <= 5'b00000;
      next_bRequest <= 8'h00;
      next_wLength <= 16'h0000;
      next_wIndex <= 16'h0000;
      next_wValue <= 16'h0000;
      next_dataSeq <= 1'b0;
      next_USBAddress <= 8'h00;
      NextState_EP0St <= `INIT_WT_GNT;
    end
    `CHK_TRANS_RD_STAT:
    begin
      next_wb_addr <= `RA_EP0_STATUS_REG;
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b0;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `CHK_TRANS_RD_RX_SIZE1;
        next_wb_stb <= 1'b0;
        next_epStatus <= wb_data_i;
      end
    end
    `CHK_TRANS_WT_GNT:
    begin
      if (wbBusGnt == 1'b1)
      begin
        NextState_EP0St <= `CHK_TRANS_RD_STAT;
      end
    end
    `CHK_TRANS_RD_RX_SIZE1:
    begin
      next_wb_addr <= `RA_EP0_RX_FIFO_DATA_COUNT_MSB;
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b0;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `CHK_TRANS_RD_RX_SIZE2;
        next_wb_stb <= 1'b0;
        next_rxDataSize[15:8] <= wb_data_i;
      end
    end
    `CHK_TRANS_RD_RX_SIZE2:
    begin
      next_wb_addr <= `RA_EP0_RX_FIFO_DATA_COUNT_LSB;
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b0;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `CHK_TRANS_RD_TRANS_TYPE;
        next_wb_stb <= 1'b0;
        next_rxDataSize[7:0] <= wb_data_i;
      end
    end
    `CHK_TRANS_RD_TRANS_TYPE:
    begin
      next_wb_addr <= `RA_EP0_TRANSTYPE_STATUS_REG;
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b0;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `CHK_TRANS_WT_UNGNT;
        next_wb_stb <= 1'b0;
        next_epTransType <= wb_data_i;
      end
    end
    `CHK_TRANS_WT_UNGNT:
    begin
      next_wbBusReq <= 1'b0;
      if ((wbBusGnt == 1'b0) && ((epStatus & 8'h0f) != 8'h00))
      begin
        NextState_EP0St <= `DO_TRANS_WT_GNT;
      end
      else if ((wbBusGnt == 1'b0) && (epTransType == `SC_SETUP_TRANS))
      begin
        NextState_EP0St <= `SETUP_CHK_ERR;
      end
      else if ((wbBusGnt == 1'b0) && (epTransType == `SC_IN_TRANS))
      begin
        NextState_EP0St <= `IN_CHK_ACK;
      end
      else if ((wbBusGnt == 1'b0) && (epTransType == `SC_OUTDATA_TRANS))
      begin
        NextState_EP0St <= `OUT_CHK_SEQ;
      end
      else if (wbBusGnt == 1'b0)
      begin
        NextState_EP0St <= `DO_TRANS_WT_GNT;
      end
    end
    `DO_TRANS_WT_GNT:
    begin
      next_wbBusReq <= 1'b1;
      if (wbBusGnt == 1'b1)
      begin
        NextState_EP0St <= `DO_TRANS_TX_EMPTY;
      end
    end
    `DO_TRANS_TX_EMPTY:
    begin
      next_wb_addr <= `RA_EP0_TX_FIFO_CONTROL_REG;
      next_wb_data_o <= 8'h01;
      //force tx fifo empty
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `DO_TRANS_RX_EMPTY;
        next_wb_stb <= 1'b0;
      end
    end
    `DO_TRANS_WR_TX_FIFO:
    begin
      next_wb_data_o <= memData;
      next_wb_addr <= `RA_EP0_TX_FIFO_DATA_REG;
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `DO_TRANS_CHK_TX_DONE;
        next_wb_stb <= 1'b0;
      end
    end
    `DO_TRANS_RD_MEM:
    begin
      next_memAddr <= txDataIndex;
      next_memRdEn <= 1'b1;
      next_txDataSize <= txDataSize - 1'b1;
      next_txDataIndex <= txDataIndex + 1'b1;
      NextState_EP0St <= `DO_TRANS_DEL;
    end
    `DO_TRANS_CHK_TX_DONE:
    begin
      if (txDataSize == 8'h00)
      begin
        NextState_EP0St <= `DO_TRANS_TRANS_GO;
      end
      else
      begin
        NextState_EP0St <= `DO_TRANS_RD_MEM;
      end
    end
    `DO_TRANS_TRANS_GO:
    begin
      next_wb_addr <= `RA_EP0_CONTROL_REG;
      if (dataSeq == 1'b1)
      next_wb_data_o <= 8'h07;
      else
      next_wb_data_o <= 8'h03;
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `DO_TRANS_WT_TRANS_DONE_WT_GNT;
        next_wb_stb <= 1'b0;
        next_transDone <= 1'b0;
      end
    end
    `DO_TRANS_RX_EMPTY:
    begin
      next_wb_addr <= `RA_EP0_RX_FIFO_CONTROL_REG;
      next_wb_data_o <= 8'h01;
      //force rx fifo empty
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b1;
      if ((wb_ack == 1'b1) && (txDataSize != 8'h00))
      begin
        NextState_EP0St <= `DO_TRANS_RD_MEM;
        next_wb_stb <= 1'b0;
      end
      else if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `DO_TRANS_TRANS_GO;
        next_wb_stb <= 1'b0;
      end
    end
    `DO_TRANS_DEL:
    begin
      next_memRdEn <= 1'b0;
      NextState_EP0St <= `DO_TRANS_WR_TX_FIFO;
    end
    `DO_TRANS_WT_TRANS_DONE_WT_GNT:
    begin
      next_wbBusReq <= 1'b1;
      if (wbBusGnt == 1'b1)
      begin
        NextState_EP0St <= `DO_TRANS_WT_TRANS_DONE_GET_RDY_STS;
      end
    end
    `DO_TRANS_WT_TRANS_DONE_GET_RDY_STS:
    begin
      next_wb_addr <= `RA_EP0_CONTROL_REG;
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b0;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `DO_TRANS_WT_TRANS_DONE_WT_UNGNT;
        next_wb_stb <= 1'b0;
        next_transDone <= ~wb_data_i[`ENDPOINT_READY_BIT];
      end
    end
    `DO_TRANS_WT_TRANS_DONE_WT_UNGNT:
    begin
      next_wbBusReq <= 1'b0;
      if (wbBusGnt == 1'b0)
      begin
        NextState_EP0St <= `DO_TRANS_WT_TRANS_DONE_CHK_DONE;
      end
    end
    `DO_TRANS_WT_TRANS_DONE_CHK_DONE:
    begin
      if (transDone == 1'b1)
      begin
        NextState_EP0St <= `CHK_TRANS_WT_GNT;
        next_wbBusReq <= 1'b1;
      end
      else
      begin
        NextState_EP0St <= `DO_TRANS_WT_TRANS_DONE_DEL;
        next_cnt <= 8'h00;
      end
    end
    `DO_TRANS_WT_TRANS_DONE_DEL:
    begin
      next_cnt <= cnt + 1'b1;
      if (cnt == `ONE_USEC_DEL)
      begin
        NextState_EP0St <= `DO_TRANS_WT_TRANS_DONE_WT_GNT;
      end
    end
    `SETUP_CHK_ERR:
    begin
      if (rxDataSize != 16'h0008)
      begin
        NextState_EP0St <= `DO_TRANS_WT_GNT;
      end
      else
      begin
        NextState_EP0St <= `SETUP_GET_DATA_WT_GNT;
        next_wbBusReq <= 1'b1;
        next_txDataSize <= 8'h00;
        next_txPacketRemSize <= 8'h00;
        //default tx packet size
        next_dataSeq <= 1'b1;
        next_wb_addr <= `RA_EP0_RX_FIFO_DATA_REG;
        next_wb_we <= 1'b0;
      end
    end
    `SETUP_GET_STAT:
    begin
      if (bm_req_type == 2'b00)  begin
      next_txPacketRemSize <= 8'h02;
      if (bm_req_recp == 5'b00000)
      next_txDataIndex <= `ONE_ZERO_STAT_INDEX;
      else
      next_txDataIndex <= `ZERO_ZERO_STAT_INDEX;
      end
      else if (bm_req_type == 2'b10) begin
      next_txDataIndex <= `VENDOR_DATA_STAT_INDEX;
      next_txPacketRemSize <= 8'h02;
      end
      NextState_EP0St <= `SETUP_CHK_MAX_LEN;
    end
    `SETUP_SET_ADDR:
    begin
      if ( (wValue[15:7] == {9{1'b0}}) && (wIndex == 16'h0000) && (wLength == 16'h0000) ) begin
      next_USBAddress <= wValue[7:0];
      next_updateUSBAddress <= 1'b1;
      end
      NextState_EP0St <= `SETUP_CHK_MAX_LEN;
    end
    `SETUP_CHK_MAX_LEN:
    begin
      if (txPacketRemSize > wLength)
      next_txPacketRemSize <= wLength;
      NextState_EP0St <= `SETUP_PTR_SET;
    end
    `SETUP_PTR_SET:
    begin
      if (txPacketRemSize > `MAX_RESP_SIZE) begin
      next_txDataSize <= `MAX_RESP_SIZE;
      next_txPacketRemSize <= txPacketRemSize - `MAX_RESP_SIZE;
      end
      else begin
      next_txDataSize <= txPacketRemSize;
      next_txPacketRemSize <= 8'h00;
      end
      NextState_EP0St <= `DO_TRANS_WT_GNT;
    end
    `SETUP_GET_DATA_DAT1:
    begin
      next_wb_stb <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `SETUP_GET_DATA_DAT2;
        next_wb_stb <= 1'b0;
        next_bm_req_dir <= wb_data_i[7];
        next_bm_req_type <= wb_data_i[6:5];
        next_bm_req_recp <= wb_data_i[4:0];
      end
    end
    `SETUP_GET_DATA_WT_GNT:
    begin
      if (wbBusGnt == 1'b1)
      begin
        NextState_EP0St <= `SETUP_GET_DATA_DAT1;
      end
    end
    `SETUP_GET_DATA_DAT2:
    begin
      next_wb_stb <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `SETUP_GET_DATA_DAT3;
        next_wb_stb <= 1'b0;
        next_bRequest <= wb_data_i;
      end
    end
    `SETUP_GET_DATA_DAT3:
    begin
      next_wb_stb <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `SETUP_GET_DATA_DAT4;
        next_wb_stb <= 1'b0;
        next_wValue[7:0] <= wb_data_i;
      end
    end
    `SETUP_GET_DATA_DAT4:
    begin
      next_wb_stb <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `SETUP_GET_DATA_DAT5;
        next_wb_stb <= 1'b0;
        next_wValue[15:8] <= wb_data_i;
      end
    end
    `SETUP_GET_DATA_DAT6:
    begin
      next_wb_stb <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `SETUP_GET_DATA_DAT7;
        next_wb_stb <= 1'b0;
        next_wIndex[15:8] <= wb_data_i;
      end
    end
    `SETUP_GET_DATA_DAT5:
    begin
      next_wb_stb <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `SETUP_GET_DATA_DAT6;
        next_wb_stb <= 1'b0;
        next_wIndex[7:0] <= wb_data_i;
      end
    end
    `SETUP_GET_DATA_DAT8:
    begin
      next_wb_stb <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `SETUP_GET_DATA_WT_UNGNT;
        next_wb_stb <= 1'b0;
        next_wLength[15:8] <= wb_data_i;
        next_wbBusReq <= 1'b0;
      end
    end
    `SETUP_GET_DATA_DAT7:
    begin
      next_wb_stb <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `SETUP_GET_DATA_DAT8;
        next_wb_stb <= 1'b0;
        next_wLength[7:0] <= wb_data_i;
      end
    end
    `SETUP_GET_DATA_WT_UNGNT:
    begin
      if ((wbBusGnt == 1'b0) && (bRequest == `GET_STATUS))
      begin
        NextState_EP0St <= `SETUP_GET_STAT;
      end
      else if ((wbBusGnt == 1'b0) && (bRequest == `GET_DESCRIPTOR))
      begin
        NextState_EP0St <= `SETUP_GET_DESC_S1;
      end
      else if ((wbBusGnt == 1'b0) && (bRequest == `SET_ADDRESS))
      begin
        NextState_EP0St <= `SETUP_SET_ADDR;
      end
      else if (wbBusGnt == 1'b0)
      begin
        NextState_EP0St <= `DO_TRANS_WT_GNT;
      end
    end
    `SETUP_GET_DESC_S1:
    begin
      case (wValue[15:8])
      `DEV_DESC: begin
      next_txPacketRemSize <= `DEV_DESC_SIZE;
      next_txDataIndex <= `DEV_DESC_INDEX;
      end
      `CFG_DESC: begin
      next_txPacketRemSize <= `CFG_DESC_SIZE;
      next_txDataIndex <= `CFG_DESC_INDEX;
      end
      `REP_DESC: begin
      next_txPacketRemSize <= `REP_DESC_SIZE;
      next_txDataIndex <= `REP_DESC_INDEX;
      end
      `STRING_DESC: begin
      case (wValue[3:0])
      4'h0: begin
      next_txPacketRemSize <= `LANGID_DESC_SIZE;
      next_txDataIndex <= `LANGID_DESC_INDEX;
      end
      4'h1: begin
      next_txPacketRemSize <= `STRING1_DESC_SIZE;
      next_txDataIndex <= `STRING1_DESC_INDEX;
      end
      4'h2: begin
      next_txPacketRemSize <= `STRING2_DESC_SIZE;
      next_txDataIndex <= `STRING2_DESC_INDEX;
      end
      4'h3: begin
      next_txPacketRemSize <= `STRING3_DESC_SIZE;
      next_txDataIndex <= `STRING3_DESC_INDEX;
      end
      endcase
      end
      endcase
      NextState_EP0St <= `SETUP_CHK_MAX_LEN;
    end
    `IN_CHK_ACK:
    begin
      if (epStatus[`SC_ACK_RXED_BIT] != 1'b1)
      begin
        NextState_EP0St <= `DO_TRANS_WT_GNT;
      end
      else if (updateUSBAddress == 1'b1)
      begin
        NextState_EP0St <= `IN_WT_GNT;
      end
      else
      begin
        NextState_EP0St <= `IN_SET_PTR;
      end
    end
    `IN_SET_PTR:
    begin
      if (txPacketRemSize > `MAX_RESP_SIZE) begin
      next_txDataSize <= `MAX_RESP_SIZE;
      next_txPacketRemSize <= txPacketRemSize - `MAX_RESP_SIZE;
      end
      else begin
      next_txDataSize <= txPacketRemSize;
      next_txPacketRemSize <= 8'h00;
      end
      NextState_EP0St <= `DO_TRANS_WT_GNT;
    end
    `IN_SET_ADDR:
    begin
      next_wb_addr <= `RA_SC_ADDRESS;
      next_wb_data_o <= USBAddress;
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `IN_WT_UNGNT;
        next_wb_stb <= 1'b0;
        next_wbBusReq <= 1'b0;
      end
    end
    `IN_WT_GNT:
    begin
      next_wbBusReq <= 1'b1;
      next_updateUSBAddress <= 1'b0;
      if (wbBusGnt == 1'b1)
      begin
        NextState_EP0St <= `IN_SET_ADDR;
      end
    end
    `IN_WT_UNGNT:
    begin
      if (wbBusGnt == 1'b0)
      begin
        NextState_EP0St <= `IN_SET_PTR;
      end
    end
    `OUT_CHK_SEQ:
    begin
      if (epStatus[`SC_DATA_SEQUENCE_BIT] != dataSeq)
      begin
        NextState_EP0St <= `DO_TRANS_WT_GNT;
      end
      else
      begin
        NextState_EP0St <= `DO_TRANS_WT_GNT;
        next_dataSeq <= ~dataSeq;
      end
    end
    `INIT_RST:
    begin
      next_wb_addr <= `RA_HOST_SLAVE_MODE;
      next_wb_data_o <= 8'h2;
      //reset usbHostSlave
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `INIT_WT_RST;
        next_wb_stb <= 1'b0;
        next_cnt <= 8'h00;
      end
    end
    `INIT_WT_GNT:
    begin
      next_wbBusReq <= 1'b1;
      if (wbBusGnt == 1'b1)
      begin
        NextState_EP0St <= `INIT_RST;
      end
    end
    `INIT_WT_RST:
    begin
      next_cnt <= cnt + 1'b1;
      if (cnt == 8'hff)
      begin
        NextState_EP0St <= `INIT_WT_VBUS;
      end
    end
    `INIT_WT_VBUS:
    begin
      next_wb_addr <= `RA_SC_LINE_STATUS_REG;
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b0;
      if ((wb_ack == 1'b1)  && (wb_data_i[`VBUS_PRES_BIT] == 1'b1))
      begin
        NextState_EP0St <= `INIT_CONN;
        next_wb_stb <= 1'b0;
      end
    end
    `INIT_FIN:
    begin
      next_wbBusReq <= 1'b0;
      next_initComplete <= 1'b1;
      if (wbBusGnt == 1'b0)
      begin
        NextState_EP0St <= `DO_TRANS_WT_GNT;
      end
    end
    `INIT_CONN:
    begin
      next_wb_addr <= `RA_SC_CONTROL_REG;
      next_wb_data_o <= 8'h71;
      //connect to host, full speed
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b1;
      if (wb_ack == 1'b1)
      begin
        NextState_EP0St <= `INIT_WT_CONN;
        next_wb_stb <= 1'b0;
      end
    end
    `INIT_WT_CONN:
    begin
      next_wb_addr <= `RA_SC_LINE_STATUS_REG;
      next_wb_stb <= 1'b1;
      next_wb_we <= 1'b0;
      if ((wb_ack == 1'b1) && (wb_data_i[1:0] == `FULL_SPEED_CONNECT))
      begin
        NextState_EP0St <= `INIT_FIN;
        next_wb_stb <= 1'b0;
      end
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst == 1'b1)
    CurrState_EP0St <= `START;
  else
    CurrState_EP0St <= NextState_EP0St;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst == 1'b1)
  begin
    wb_addr <= 8'h00;
    wb_data_o <= 8'h00;
    wb_stb <= 1'b0;
    wb_we <= 1'b0;
    wbBusReq <= 1'b0;
    initComplete <= 1'b0;
    memAddr <= 8'h00;
    memRdEn <= 1'b0;
    cnt <= 8'h00;
    txDataSize <= 8'h00;
    txDataIndex <= 8'h00;
    transDone <= 1'b0;
    epStatus <= 8'h00;
    rxDataSize <= 16'h0000;
    epTransType <= 8'h00;
    bm_req_dir <= 1'b0;
    bm_req_type <= 2'b00;
    bm_req_recp <= 5'b00000;
    bRequest <= 8'h00;
    wValue <= 16'h0000;
    wIndex <= 16'h0000;
    wLength <= 16'h0000;
    txPacketRemSize <= 8'h00;
    USBAddress <= 8'h00;
    updateUSBAddress <= 1'b0;
    dataSeq <= 1'b0;
  end
  else 
  begin
    wb_addr <= next_wb_addr;
    wb_data_o <= next_wb_data_o;
    wb_stb <= next_wb_stb;
    wb_we <= next_wb_we;
    wbBusReq <= next_wbBusReq;
    initComplete <= next_initComplete;
    memAddr <= next_memAddr;
    memRdEn <= next_memRdEn;
    cnt <= next_cnt;
    txDataSize <= next_txDataSize;
    txDataIndex <= next_txDataIndex;
    transDone <= next_transDone;
    epStatus <= next_epStatus;
    rxDataSize <= next_rxDataSize;
    epTransType <= next_epTransType;
    bm_req_dir <= next_bm_req_dir;
    bm_req_type <= next_bm_req_type;
    bm_req_recp <= next_bm_req_recp;
    bRequest <= next_bRequest;
    wValue <= next_wValue;
    wIndex <= next_wIndex;
    wLength <= next_wLength;
    txPacketRemSize <= next_txPacketRemSize;
    USBAddress <= next_USBAddress;
    updateUSBAddress <= next_updateUSBAddress;
    dataSeq <= next_dataSeq;
  end
end

endmodule