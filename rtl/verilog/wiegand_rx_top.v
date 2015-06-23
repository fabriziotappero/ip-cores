//////////////////////////////////////////////////////////////////////
////                                                              ////
////  wiegand_rx_top.v                                            ////
////                                                              ////
////                                                              ////
////  This file is part of the Wiegand Protocol Controller        ////
////  Wiegand Receiver IP core                                    ////
////  http://www.opencores.org/projects/wiegand/                  ////
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
//// The wiegand protocol is maintained by                        ////
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
`include "wiegand_defines.v"

module wiegand_rx_top(
  one_i,
  zero_i,

  wb_clk_i,
  wb_rst_i,
  wb_dat_i,
  wb_dat_o,
  wb_cyc_i,
  wb_stb_i,
  wb_cti_i,
  wb_sel_i,
  wb_we_i,
  wb_adr_i,
  wb_ack_o,
  wb_err_o,
  wb_rty_o
);
  //to PHY layer
  input one_i;
  input zero_i;
  
  //wishbone interface
  input                       wb_clk_i;
  input                       wb_rst_i;
  input  [`WB_WIDTH-1:0]      wb_dat_i;
  output [`WB_WIDTH-1:0]      wb_dat_o;
  input                       wb_cyc_i;
  input                       wb_stb_i;
  input                       wb_we_i;
  input [(`WB_WIDTH/8)-1:0]   wb_sel_i;
  input [2:0]                 wb_cti_i;
  input  [`WB_ADDR_WIDTH-1:0] wb_adr_i;
  output                      wb_ack_o;
  output                      wb_err_o;
  output                      wb_rty_o;
  
  //intermediate signals
wire                          rst;
reg [`WB_WIDTH:0]             data;

wire [`WB_WIDTH-1:0]          dat_i;
wire [`WB_WIDTH-1:0]          dat_o;
wire [`WB_WIDTH-1:0]          data_o;
wire [`WB_WIDTH-1:0]      pulsewidth;
wire [`WB_WIDTH-1:0]      p2p;
reg  [(`WB_ADDR_WIDTH/2)-1:0] sampleCnt;
wire [6:0]                    msgLength;
reg [`WB_ADDR_WIDTH-1:0]      word_in;
reg [`WB_ADDR_WIDTH-1:0]      fifo_out;
reg [1:0]                     zero_edge, one_edge;
reg [1:0]                     zero_det, one_det;
wire                          clk;
reg                           lock_cfg;
reg [3:0]                     filter1;
reg [3:0]                     filter0;
reg [1:0]                     filterCnt;
reg                           sampleTime;
reg                           filterEn;
reg [5:0]                     bitCount,tpiCnt;
wire                          start_tx;
wire [5:0]                    tpi;
wire                          errorClr;
reg                           msgDone, msgError,msgDoneDly;

  /***************************** RX logic **********************************************************/
  //negedge detectors for each line
  assign zero = ~zero_det[0] & zero_det[1];
  always @(posedge clk or posedge rst) begin
    if (rst)  zero_det <= 2'b11;
    else      zero_det <= {zero_det[0],zero_i};
  end
  
  assign one = ~one_det[0] & one_det[1];
  always @(posedge clk or posedge rst) begin
    if (rst)  one_det <= 2'b11;
    else      one_det <= {one_det[0],one_i};
  end
  
  //posedge detectors for each line
  assign notzero = zero_det[0] & ~zero_det[1];  
  assign notone = one_det[0] & ~one_det[1];
  
  //@ negedge, filter for noise on teh line; filtering for noise by taking samples during the PW
  //starting the sampling at halfway through teh pulse to ensure dampening occurs before sample
  assign filtered1 = (~|filter1) & ~one_det[1];
  assign filtered0 = (~|filter0) & ~zero_det[1];
  always @(posedge clk or posedge rst) begin
    if (rst)  begin
      filter1 <= 4'h0;
      filter0 <= 4'h0;
      filterCnt <= 2'h0;
    end
    else if (sampleTime)   begin
      filter1 <= {filter1[2:0],one_det[0]};
      filter0 <= {filter0[2:0],zero_det[0]};
      filterCnt <= filterCnt+1;
    end
  end
  
  always @(posedge clk or posedge rst) begin
    if (rst)            sampleCnt <= 3'h0;
    else if (filterEn)  sampleCnt <= sampleCnt+1;
  end
  
  always @(posedge clk or posedge rst) begin
    if (rst)                                  sampleTime <= 1'b0;
    else  sampleTime <= ((sampleCnt == {pulsewidth[2:0]}) || (sampleCnt == {1'h0,pulsewidth[2:1]}) || (sampleCnt == {2'h0,pulsewidth[2]}));
  end 
  
  always @(negedge clk or posedge rst) begin
    if (rst)                    filterEn <= 1'b0;
    else if (one | zero)        filterEn <= 1'b1;
    else if (filterCnt == 2'h3) filterEn <= 1'b0;  
  end
  
  //then write bit to appropriate data register sub-bit; increment counter
  always @(negedge clk or posedge rst) begin
    if (rst)                        word_in <= 32'h0;
    else if (filtered1 | filtered0) word_in <= {word_in[30:0],filtered1};
  end
  
  always @(negedge clk or posedge rst) begin
    if (rst)                        bitCount <= 6'h0;
    else if (filtered1 | filtered0) bitCount <= bitCount+1;
    else if (msgDoneDly)            bitCount <= 6'h0;
  end
  
  //when linesa re not being driven, check to see that tpi is not exceeded;
  //exceeded tpi means data transfer is done, and packet length should be checked
  assign tpi = p2p[5:0];
  always @(negedge clk or posedge rst) begin
    if (rst)                                tpiCnt <= 6'h0;
    else if (~|{notzero,notone,zero,one})   tpiCnt <= tpiCnt+1;
    else                                    tpiCnt <= 6'h0;
  end
  
  always @(posedge clk or posedge rst) begin
    if (rst)  msgDone <= 1'b0;
    else      msgDone <= ~|(tpiCnt ^ tpi);
  end
  
  always @(posedge clk or posedge rst) begin
    if (rst)  msgDoneDly <= 1'b0;
    else      msgDoneDly <= msgDone;
  end
  
  //configuration is locked at start_tx/start_rx until a message error is found
  always @(posedge clk or posedge rst) begin
    if (rst)            lock_cfg <= 1'b0;
    else if (start_tx)  lock_cfg <= 1'b1;
    else if (msgError)  lock_cfg <= 1'b0;
  end 
  
  //if rx msglength does not match expected msglength, then flag an error
  assign errorClr = p2p[6];
  always @(negedge clk or posedge rst) begin
    if (rst)            msgError <= 1'b0;
    else if (errorClr)  msgError <= 1'b0;
    else                msgError <= msgDone & |(bitCount ^ msgLength);
  end

  
  /***************************** input FIFO *******************************************************/
  fifo_wieg datafifowrite(~clk,~clk,dat_i,data_o,(rst | rst_FIFO),wr_en,rd_en,full,empty);
  
  always @(posedge clk or posedge rst) begin
    if (rst)        fifo_out <= `WB_WIDTH'h0;
    else if (rd_en) fifo_out <= data_o;
  end
  
  
  
  /***************************** WB interface *******************************************************/
  assign dat_i = fifo_out;
  wb_interface_wieg wb_interface(wb_rst_i,wb_clk_i,wb_stb_i,wb_ack_o,wb_adr_i,wb_we_i,wb_dat_i,wb_sel_i,
                              wb_dat_o,wb_cyc_i,wb_cti_i,wb_err_o,wb_rty_o,rst,dat_o,dat_i,msgLength,start_tx,
                              p2p,pulsewidth,clk,full_dly,lock_cfg,wb_wr_en,rst_FIFO,rd_en); 

endmodule

////////////////////////////////////////////////////////////////////
// CVS Revision History
//
// $Log:  $
//