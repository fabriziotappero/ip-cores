//////////////////////////////////////////////////////////////////////
////                                                              ////
////  sport_top.v                                                 ////
////                                                              ////
////                                                              ////
////  This file is part of the SPORT controller                   ////
////  http://www.opencores.org/projects/sport/                    ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Jeff Anderson                                          ////
////       jeaander@opencores.org                                 ////
////                                                              ////
////                                                              ////
////  All additional information is available in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2014 Authors                                   ////
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
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//// The SPORT protocol is maintained by Analog Devices, Inc      ////
//// This product has been tested to interoperate with certified  ////
//// devices, but has not been certified itself.  This product    ////
//// should be certified through prior to claiming strict         ////
//// adherence to the standard.                                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
//  Revisions at end of file
//


// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "sport_defines.v"

module sport_top(
  
  DTxPRI,
  DTxSEC,
  TSCLKx,
  TFSx,
  DRxPRI,
  DRxSEC,
  RSCLKx,
  RFSx,
  
  rx_int,
  rxclk,
  txclk,

  wb_clk_i,
  wb_rst_i,
  wb_dat_i,
  wb_dat_o,
  wb_cyc_i,
  wb_stb_i,
  wb_we_i,
  wb_adr_i,
  wb_ack_o,
  wb_err_o,
  wb_rty_o
);
  //to PHY layer
  output DTxPRI;
  output DTxSEC;
  output TSCLKx;
  output TFSx;
  input DRxPRI;
  input DRxSEC;
  output RSCLKx;
  output RFSx;
  
  //wishbone interface
  input                       wb_clk_i;
  input                       wb_rst_i;
  input  [`WB_WIDTH-1:0]       wb_dat_i;
  output [`WB_WIDTH-1:0]       wb_dat_o;
  input                       wb_cyc_i;
  input                       wb_stb_i;
  input                       wb_we_i;
  input  [`WB_ADDR_WIDTH-1:0]  wb_adr_i;
  output                      wb_ack_o;
  output                      wb_err_o;
  output                      wb_rty_o;
  
  //interrupt signals back to chip
  output                      rx_int;
  input                       rxclk;
  input                       txclk;
  
  //intermediate signals
wire                      rst;
reg [`WB_WIDTH:0]          data;
reg [2:0]                 state, next_state;
reg [2:0]                 rxstate, next_rxstate;
wire                      clk;
reg                       lock_cfg;

reg  [31:0]               rxPri, rxSec;

wire [4:0]                rxsampleCnt;
wire [`SPORT_FIFODEPTH-1:0]                rxpacketCnt;
wire [4:0]                txsampleCnt;
wire [`SPORT_FIFODEPTH-1:0]                txpacketCnt;
wire [31:0]                word_in;
wire [31:0]                word_out;
wire                      rxsecEn;
wire                      rxlateFS_earlyFSn;
wire                      txsecEn;
wire                      txlateFS_earlyFSn;
wire                      tx_actHi;
wire                      rx_actHi;
wire                      msbFirst;
wire                      tx_start, rx_start;

//registers for clock gating between clock domains
reg [4:0]                rxsampleCnt_rxint;
reg [`SPORT_FIFODEPTH-1:0]                rxpacketCnt_rxint;
reg [4:0]                txsampleCnt_txint;
reg [`SPORT_FIFODEPTH-1:0]                txpacketCnt_txint;
reg                      rxsecEn_rxint;
reg                      rxlateFS_earlyFSn_rxint;
reg                      txsecEn_txint;
reg                      txlateFS_earlyFSn_txint;
reg                      tx_actHi_txint;
reg                      rx_actHi_rxint;
reg                      msbFirst_txint;
reg                      tx_start_txint, rx_start_rxint;
reg [4:0]                rxsampleCnt_rx;
reg [`SPORT_FIFODEPTH-1:0]                rxpacketCnt_rx;
reg [4:0]                txsampleCnt_tx;
reg [`SPORT_FIFODEPTH-1:0]                txpacketCnt_tx;
reg                      rxsecEn_rx;
reg                      rxlateFS_earlyFSn_rx;
reg                      txsecEn_tx;
reg                      txlateFS_earlyFSn_tx;
reg                      tx_actHi_tx;
reg                      rx_actHi_rx;
reg                      msbFirst_tx;
reg                      tx_start_tx, rx_start_rx; 
reg                      rxidle;
reg                      rx;
reg                      rxFS;
reg                      txidle;
reg                      tx;
reg                      txFS; 
reg [31:0]               word_outM, word_outL;

reg                      txfs, rxfs;
wire  [31:0]             data_out;

  /***************************** RX logic **********************************************************/
  assign RSCLKx = rxclk;
  assign RFSx = rx_actHi_rxint? rxFS:~rxFS;  
  
  //main RX state machine
  always @(posedge rxclk or posedge rst) begin
    if (rst)    rxstate <= `RESET;
    else        rxstate <= next_rxstate;
  end
  
  always @(*) begin
    next_rxstate = `IDLE;
    rxidle = 1'b0;
    rx = 1'b0;
    rxfs = 1'b0;
    case (state)
      `RESET: begin next_rxstate = `IDLE; end
      `IDLE:  begin
        rxidle = 1'b1;
        if (rx_start_rxint)  next_rxstate = `FS;
        else          next_rxstate = `IDLE;
      end
      `FS: begin
        rxfs = 1'b1;
        next_rxstate = `RX;
      end
      `RX: begin
        rx = 1'b1;
        if (rxsampleCnt_rx == rxsampleCnt_rxint)         next_rxstate = `IDLE;
        else if (rxpacketCnt_rx == rxpacketCnt_rxint) next_rxstate = `FS;
        else                                next_rxstate = `RX;
      end
      default: next_rxstate = `IDLE;
    endcase
  end
  
  //input shift registers
  always @(posedge rxclk or posedge rst) begin
    if (rst) begin
      rxPri <= 32'h0;
      rxSec <= 32'h0;
    end
    else begin
      rxPri <= {rxPri[30:0],DRxPRI};
      rxSec <= {rxSec[30:0],DRxSEC};
    end
  end
  
  //counter for message length
  always @(posedge rxclk or posedge rst) begin
    if (rst)      rxsampleCnt_rx <= 5'h0;
    else if (rx)  begin
      if (rxsecEn_rxint)  rxsampleCnt_rx <= rxsampleCnt_rx+2;
      else        rxsampleCnt_rx <= rxsampleCnt_rx+1;
    end
    else          rxsampleCnt_rx <= 5'h0;
  end
  
  always @(posedge rxclk or posedge rst) begin
    if (rst)      rxpacketCnt_rx <= 5'h0;
    else if (rx)  begin
      if (rxsecEn_rxint)  rxpacketCnt_rx <= rxpacketCnt_rx+2;
      else        rxpacketCnt_rx <= rxpacketCnt_rx+1;
    end
    else          rxpacketCnt_rx <= 5'h0;
  end
  
  //framesync signal
  always @(posedge rxclk or posedge rst) begin
    if (rst)  rxFS <= 1'b0;
    else      rxFS <= rxlateFS_earlyFSn_rxint? rx : rxfs;
  end
  
  /***************************** TX logic **********************************************************/
  assign TSCLKx = txclk;
  assign TFSx = tx_actHi_txint? txFS:~txFS;
  
  //main TX state machine
  always @(posedge txclk or posedge rst) begin
    if (rst)    state <= `RESET;
    else        state <= next_state;
  end
  
  always @(*) begin
    next_state = `IDLE;
    txidle = 1'b0;
    tx = 1'b0;
    txfs = 1'b0;
    case (state)
      `RESET: begin next_state = `IDLE; end
      `IDLE:  begin
        txidle = 1'b1;
        if (tx_start_txint)  next_state = `FS;
        else          next_state = `IDLE;
      end
      `FS: begin
        txfs = 1'b1;
        next_state = `TX;
      end
      `TX: begin
        tx = 1'b1;
        if (txsampleCnt_tx == txsampleCnt_txint)         next_state = `IDLE;
        else if (txpacketCnt_tx == txpacketCnt_txint) next_state = `FS;
        else                                next_state = `TX;
      end
      default: next_state = `IDLE;
    endcase
  end
  
  //counter for message length
  always @(posedge txclk or posedge rst) begin
    if (rst)      txsampleCnt_tx <= 5'h0;
    else if (tx)  begin
      if (txsecEn_txint)  txsampleCnt_tx <= txsampleCnt_tx+2;
      else        txsampleCnt_tx <= txsampleCnt_tx+1;
    end
    else          txsampleCnt_tx <= 5'h0;
  end
  
  always @(posedge txclk or posedge rst) begin
    if (rst)      txpacketCnt_tx <= 5'h0;
    else if (tx) begin
      if (txsecEn_txint)  txpacketCnt_tx <= txpacketCnt_tx+2;
      else        txpacketCnt_tx <= txpacketCnt_tx+1;
    end
    else          txpacketCnt_tx <= 5'h0;
  end
  
  //logic for routing output data to ports
  assign DTxPRI = msbFirst? word_outM[31]:word_outL[31];
  assign DTxSEC = txsecEn_tx? (msbFirst? word_outM[16]:word_outL[16]):1'b0;
  
  //output word MSB first
  always @(posedge txclk or posedge rst) begin
    if (rst)      word_outM <= 32'h0;
    else if (tx)  word_outM <= {word_outM[30:0],1'b0};
    else if (txfs)  word_outM <= data_out;
  end
  
  //output word LSB first
  always @(posedge txclk or posedge rst) begin
    if (rst)      word_outL <= 32'h0;
    else if (tx)  word_outL <= {word_outL[30:0],1'b0};
    else if (txfs)  word_outL <= {data_out[0],data_out[1],data_out[2],data_out[3],data_out[4],data_out[5],data_out[6],data_out[7],
                                data_out[8],data_out[9],data_out[10],data_out[11],data_out[12],data_out[13],data_out[14],data_out[15],
                                data_out[16],data_out[17],data_out[18],data_out[19],data_out[20],data_out[21],data_out[22],data_out[23],
                                data_out[24],data_out[25],data_out[26],data_out[27],data_out[28],data_out[29],data_out[30],data_out[31]};
  end
  
  //framesync signal
  always @(posedge txclk or posedge rst) begin
    if (rst)  txFS <= 1'b0;
    else      txFS <= txlateFS_earlyFSn_txint? tx : txfs;
  end
  
  /***************************** input FIFO *******************************************************/

  fifo_sport datafifowrite(clk,txclk,wb_data_i,data_out,rst,wb_wr_en,wei_rd_en,fullwrite,emptywrite);
  fifo_sport datafiforead(rxclk,clk,wb_data_i,data_o,rst,wb_wr_en,wei_rd_en,fullread,emptyread);

  
  /***************************** WB interface *******************************************************/
  //gate clocks at change in clock domains
  
  always @(posedge rxclk or posedge rst) begin
    if (rst)  rxsampleCnt_rxint <= 5'h0;
    else      rxsampleCnt_rxint <= rxsampleCnt;
  end
  
  always @(posedge rxclk or posedge rst) begin
    if (rst)  rxpacketCnt_rxint <= `SPORT_FIFODEPTH'h0;
    else      rxpacketCnt_rxint <= rxpacketCnt;
  end
  
  always @(posedge txclk or posedge rst) begin
    if (rst)  txsampleCnt_txint <= 5'h0;
    else      txsampleCnt_txint <= txsampleCnt;
  end
  
  always @(posedge txclk or posedge rst) begin
    if (rst)  txpacketCnt_txint <= `SPORT_FIFODEPTH'h0;
    else      txpacketCnt_txint <= txpacketCnt;
  end

  always @(posedge rxclk or posedge rst) begin
    if (rst)  rxsecEn_rxint <= 1'b0;
    else      rxsecEn_rxint <= rxsecEn;
  end

  always @(posedge rxclk or posedge rst) begin
    if (rst)  rxlateFS_earlyFSn_rxint <= 1'b0;
    else      rxlateFS_earlyFSn_rxint <= rxlateFS_earlyFSn;
    
  end
  
  always @(posedge txclk or posedge rst) begin
    if (rst)  txlateFS_earlyFSn_txint <= 1'b0;
    else      txlateFS_earlyFSn_txint <= txlateFS_earlyFSn;
    
  end
  
  always @(posedge txclk or posedge rst) begin
    if (rst)  txsecEn_txint <= 1'b0;
    else      txsecEn_txint <= txsecEn;
  end

  always @(posedge txclk or posedge rst) begin
    if (rst)  txlateFS_earlyFSn_txint <= 1'b0;
    else      txlateFS_earlyFSn_txint <= txlateFS_earlyFSn;
  end

  always @(posedge txclk or posedge rst) begin
    if (rst)  tx_actHi_txint <= 1'b0;
    else      tx_actHi_txint <= tx_actHi;
  end

  always @(posedge rxclk or posedge rst) begin
    if (rst)  rx_actHi_rxint <= 1'b0;
    else      rx_actHi_rxint <= rx_actHi;
  end

  always @(posedge txclk or posedge rst) begin
    if (rst)  msbFirst_txint <= 1'b0;
    else      msbFirst_txint <= msbFirst;
  end

  always @(posedge txclk or posedge rst) begin
    if (rst)  tx_start_txint <= 1'b0;
    else      tx_start_txint <= tx_start;
  end
  
  always @(posedge rxclk or posedge rst) begin
    if (rst)  rx_start_rxint <= 1'b0;
    else      rx_start_rxint <= rx_start;
  end
  
  wb_interface_sport wb_interface(wb_rst_i,wb_clk_i,wb_stb_i,wb_ack_o,wb_adr_i,wb_we_i,wb_dat_i,wb_sel_i,
                              wb_dat_o,wb_cyc_i,wb_cti_i,wb_err_o,wb_rty_o,rxsampleCnt,
                              rxpacketCnt,txsampleCnt,txpacketCnt,word_in,word_out,rxsecEn,rxlateFS_earlyFSn,
                              txsecEn,txlateFS_earlyFSn,tx_actHi,rx_actHi,msbFirst,tx_start, rx_start,rx_int); 
  
endmodule

////////////////////////////////////////////////////////////////////
// CVS Revision History
//
// $Log:  $
//