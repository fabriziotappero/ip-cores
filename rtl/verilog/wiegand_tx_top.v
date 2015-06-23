//////////////////////////////////////////////////////////////////////
////                                                              ////
////  wiegand_tx_top.v                                            ////
////                                                              ////
////                                                              ////
////  This file is part of the Wiegand Protocol Controller        ////
////  Wiegand Transmitter IP core                                 ////
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
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
//  Revisions at end of file
//


// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "wiegand_defines.v"

module wiegand_tx_top(
  
  one_o,
  zero_o,

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
  output reg one_o;
  output reg zero_o;
  
  //wishbone interface
  input                       wb_clk_i;
  input                       wb_rst_i;
  input  [`WB_WIDTH-1:0]      wb_dat_i;
  output [`WB_WIDTH-1:0]      wb_dat_o;
  input                       wb_cyc_i;
  input                       wb_stb_i;
  input [(`WB_WIDTH/8)-1:0]   wb_sel_i;
  input [2:0]                 wb_cti_i;
  input                       wb_we_i;
  input  [`WB_ADDR_WIDTH-1:0] wb_adr_i;
  output                      wb_ack_o;
  output                      wb_err_o;
  output                      wb_rty_o;
  
  //intermediate signals
wire                      rst;
reg                       idle;

wire [`WB_WIDTH-1:0]      dat_o;
wire [`WB_WIDTH-1:0]      dat_i;
wire [`WB_WIDTH-1:0]      pulsewidth;
wire [`WB_WIDTH-1:0]      p2p;
reg [4:0]                 p2pCnt;
wire [6:0]                msgLength;
reg [31:0]                word_out;
reg [2:0]                 state, next_state;
wire                      clk;
reg                       lock_cfg;
reg                       full_dly;
wire                      full;
reg                       bit, tx, data, done;
reg [`WB_WIDTH-1:0]       pulseCnt;
reg [6:0]                 bitCount, bitCountReg;
wire                      start_tx;
wire [`WB_WIDTH-1:0]      data_o;
wire                      rst_FIFO;
 
  /***************************** TX logic *********************************************************/
  //output registers clocked directly from the state machine
  always @(negedge clk or posedge rst) begin
    if (rst)  begin  
      one_o <= 1'b1;
      zero_o <= 1'b1;
    end
    else if (bit) begin
      if (word_out[31])
        one_o <= 1'b0;
      else
        zero_o <= 1'b0;
    end
    else begin
      one_o <= 1'b1;
      zero_o <= 1'b1;
    end
  end
  
  //counters enabled by state machine for programmable wiegand timing
  
  //pulse to pulse timing
  always @(negedge clk or posedge rst) begin
    if (rst)      p2pCnt <= 5'h0;
    else if (tx)  p2pCnt <= p2pCnt+1;
    else          p2pCnt <= 5'h0;
  end
  
  //pulse width timer
  always @(negedge clk or posedge rst) begin
    if (rst)                pulseCnt <= 5'h0;
    else if (bit)           pulseCnt <= pulseCnt+1;
    else                    pulseCnt <= 5'h0;
  end
  
  //message bit counter
  always @(negedge clk or posedge rst) begin
    if (rst)              bitCount <= 7'h0;
    else if (done)        bitCount <= bitCount+1;
    else if (idle)        bitCount <= 7'h0;
  end  
  
  always @(negedge clk or posedge rst) begin
    if (rst)              bitCountReg <= 7'h0;
    else if (done)        bitCountReg <= bitCountReg+1;
    else if (data)        bitCountReg <= 7'h0;
  end  
  
  //main state machine for transmitter
  always @(posedge clk or posedge rst) begin
    if (rst)  state <= `IDLE;
    else      state <= next_state;
  end
  
  always @ (*) begin
    next_state = `IDLE;
    bit = 1'b0;
    tx = 1'b0;
    data = 1'b0;
    done = 1'b0;
    idle = 1'b0;
    case (state)
      `IDLE: begin
        idle = 1'b1;
        if (start_tx) next_state = `DATA;
        else          next_state = `IDLE;
      end
      `DATA: begin
        data = 1'b1;
        next_state = `TX;
      end
      `TX: begin
        tx = 1'b1;
        if (bitCountReg == 6'h20)
          next_state = `DATA;
        else if (p2pCnt == p2p) begin     
          if (bitCount == msgLength) 
            next_state = `LASTBIT;
          else 
            next_state = `BIT;
        end
        else  next_state = `TX;
      end
      `BIT: begin
        bit = 1'b1;
        if (pulseCnt == pulsewidth) next_state = `DONE;
        else                        next_state = `BIT;
      end
      `LASTBIT: begin
        bit = 1'b1;
        if (pulseCnt == pulsewidth) next_state = `IDLE;
        else                        next_state = `LASTBIT;
      end
      `DONE: begin
        done = 1'b1;
        next_state = `TX;
      end
    endcase
  end
  
  //dont want config being changed during a write cycle
  always @(negedge clk or posedge rst) begin
    if (rst)      lock_cfg <= 1'b0;
    else          lock_cfg <= tx | done | bit | data;
  end
  
  /***************************** output FIFO *******************************************************/
  always @(posedge clk or posedge rst) begin
    if (rst)        word_out <= 32'h0;
    else if (data)  word_out <= data_o;
    else if (done)  word_out <= {word_out[30:0],1'b0};
  end
  
  always @(posedge clk or posedge rst) begin
    if (rst)    full_dly <= 1'b0;
    else        full_dly <= full;
  end
  
  fifo_wieg datafifowrite(~clk,~clk,dat_o,data_o,(rst | rst_FIFO),(~lock_cfg & wb_wr_en),data,full,empty);

  
  /***************************** WB interface *******************************************************/
  assign dat_i = data_o;
  wb_interface_wieg wb_interface(wb_rst_i,wb_clk_i,wb_stb_i,wb_ack_o,wb_adr_i,wb_we_i,wb_dat_i,wb_sel_i,
                              wb_dat_o,wb_cyc_i,wb_cti_i,wb_err_o,wb_rty_o,rst,dat_o,dat_i,msgLength,start_tx,
                              p2p,pulsewidth,clk,full_dly,lock_cfg,wb_wr_en,rst_FIFO,rd_en); 
 
  
endmodule

////////////////////////////////////////////////////////////////////
// CVS Revision History
//
// $Log:  $
//