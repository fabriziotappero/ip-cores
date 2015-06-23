//////////////////////////////////////////////////////////////////////
////                                                              ////
////  wb_interface.v                                              ////
////                                                              ////
////                                                              ////
////  This file is part of the SPORT Controller                   ////
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
//// Copyright (C) 2013 Authors                                   ////
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

 //WB interface definitions imported from wiegand_defines
`include "sport_defines.v"

module wb_interface_sport (
      // WB bus
    wb_rst_i,
    wb_clk_i,
 
    wb_stb_i,
    wb_ack_o,
    wb_addr_i,
    wb_we_i,
    wb_dat_i,
    wb_sel_i,
    wb_dat_o,
    wb_cyc_i,
    wb_cti_i,
    wb_err_o,
    wb_rty_o,
    
    rxsampleCnt,
    rxpacketCnt,
    txsampleCnt,
    txpacketCnt,
    dat_i,
    dat_o,
    rxsecEn,
    rxlateFS_earlyFSn,
    txsecEn,
    txlateFS_earlyFSn,
    tx_actHi,
    rx_actHi,
    msbFirst,
    tx_start, 
    rx_start,
    rx_int
                    
    
); 

//--------------------------------------
// Wish Bone Interface
// -------------------------------------      
input                       wb_rst_i;
input                       wb_clk_i;
input                       wb_stb_i;
output                      wb_ack_o;
input [`WB_ADDR_WIDTH-1:0]  wb_addr_i;
input                       wb_we_i; // 1 - Write , 0 - Read
input [`WB_WIDTH-1:0]       wb_dat_i;
input [(`WB_WIDTH/8)-1:0]   wb_sel_i; // Byte enable
output [`WB_WIDTH-1:0]      dat_o;
input [`WB_WIDTH-1:0]       dat_i;    //data to and from WB interface, but not on WB
output [`WB_WIDTH-1:0]      wb_dat_o;
input                       wb_cyc_i;
input  [2:0]                wb_cti_i;
output                      wb_err_o;
output                      wb_rty_o;
 
//----------------------------------------
// interface to SPORT control logic
//----------------------------------------

output [4:0]                rxsampleCnt;
output [`SPORT_FIFODEPTH-1:0]                rxpacketCnt;
output [4:0]                txsampleCnt;
output [`SPORT_FIFODEPTH-1:0]                txpacketCnt;
output                      rxsecEn;
output                      rxlateFS_earlyFSn;
output                      txsecEn;
output                      txlateFS_earlyFSn;
output                      tx_actHi;
output                      rx_actHi;
output                      msbFirst;
output                      tx_start, rx_start;
output                      rx_int;

reg [`WB_WIDTH-1:0]       rxreg;
reg [`WB_WIDTH-1:0]       txreg;
wire                      err_int;
wire                      rty_int;
wire                      full;


/************************  standard WB stuff  ***************************/
reg ack,err,rty;
assign wb_ack_o = ack;
assign wb_err_o = err;
assign wb_rty_o = rty;
assign rst_o = wb_rst_i;
assign rst = wb_rst_i;
assign dat_o = wb_dat_i;
assign ack_o = ack;
assign stb_o = wb_stb_i;
assign cyc_o = wb_cyc_i;
assign we_o = wb_we_i;

//ACK logic
always @(posedge wb_clk_i or posedge rst) begin
  if (rst)  ack <= 1'b0;
  else      ack <= (~|(`SPORT_ADDR_MASK & wb_addr_i) & wb_stb_i & wb_cyc_i & ~err_int & ~rty_int);
end

//ERR logic if the FIFO is full
assign err_int = (~(wb_addr_i ^ `SPORT_ADDR) & wb_stb_i & wb_cyc_i & wb_we_i & full);
always @(posedge wb_clk_i or posedge rst) begin
  if (rst)      err <= 1'b0;
  else          err <= err_int;
end

//retry if we're in the middle of a write cycle
assign rty_int = (~|(`SPORT_ADDR_MASK & wb_addr_i) & wb_stb_i & wb_cyc_i & wb_we_i);
always @(posedge wb_clk_i or posedge rst) begin
  if (rst) rty <= 1'b0;
  else     rty <= rty_int;
end

//pass-thru clock
assign clk_o = wb_clk_i;

/************************  configuration registers  *************************/

assign lock_cfg_rx = rxreg[`SPORT_FIFODEPTH+10];
assign lock_cfg_tx = txreg[`SPORT_FIFODEPTH+10];
assign rxsecEn = rxreg[`SPORT_FIFODEPTH+9];
assign rxlateFS_earlyFSn = rxreg[`SPORT_FIFODEPTH+8];
assign txsecEn = txreg[`SPORT_FIFODEPTH+9];
assign txlateFS_earlyFSn = txreg[`SPORT_FIFODEPTH+8];
assign tx_actHi = txreg[`SPORT_FIFODEPTH+7];
assign rx_actHi = rxreg[`SPORT_FIFODEPTH+7];
assign tx_start = txreg[`SPORT_FIFODEPTH+6];
assign msbFirst = txreg[`SPORT_FIFODEPTH+5];
assign rx_start = rxreg[`SPORT_FIFODEPTH+6];
assign rx_int = rxreg[`SPORT_FIFODEPTH+5];
assign rxsampleCnt = rxreg[`SPORT_FIFODEPTH+4:`SPORT_FIFODEPTH];
assign rxpacketCnt = rxreg[`SPORT_FIFODEPTH-1:0];
assign txsampleCnt = txreg[`SPORT_FIFODEPTH+4:`SPORT_FIFODEPTH];
assign txpacketCnt = txreg[`SPORT_FIFODEPTH-1:0];

//defines the pulse width of the controller
always @(negedge wb_clk_i or posedge rst) begin
  if (rst)        rxreg <= `WB_WIDTH'hA;
  else if ((wb_addr_i == `WB_CNFG_RX) && (wb_stb_i & wb_cyc_i & wb_we_i & ~lock_cfg_rx)) rxreg <= wb_dat_i;
end


//defines the pulse to pulse delayof the controller
always @(negedge wb_clk_i or posedge rst) begin
  if (rst)                                                                              txreg <= `WB_WIDTH'h0;
  else if ((wb_addr_i == `WB_CNFG_TX) && (wb_stb_i & wb_cyc_i & wb_we_i & ~lock_cfg_tx))  txreg <= wb_dat_i;
end

//readback registers on valid WB read cycle
assign wb_dat_rdbk = ((wb_addr_i == `WB_CNFG_RX)? rxreg : txreg);
assign wb_dat_o = (wb_stb_i & wb_cyc_i & ~wb_we_i)? wb_dat_rdbk : `WB_WIDTH'hz;

/*******************************  DATA FIFO  ********************************************/

//fifo for TX data.
assign wb_wr_en = (wb_addr_i == `SPORT_ADDR) && (wb_stb_i & wb_cyc_i & wb_we_i & ~full);
assign wb_rd_en = (wb_addr_i == `SPORT_ADDR) && (wb_stb_i & wb_cyc_i & ~wb_we_i);
endmodule

//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: $
//