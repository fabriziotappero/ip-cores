//////////////////////////////////////////////////////////////////////
////                                                              ////
////  SPORT_defines.v                                           ////
////                                                              ////
////                                                              ////
////  This file is part of the SPORT Controller                 ////
////  http://www.opencores.org/projects/SPORT/                  ////
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
 
/**********************  WISHBONE DEFINES  ***************************/
// define the WB bus width; uncomment ONE correct width
//`define WB_WIDTH64
`define WB_WIDTH32
//`define WB_WIDTH16
//`define WB_WIDTH08


`ifdef WB_WIDTH64
  `define WB_WIDTH 64
  `define SPORT_WIDTH64
`elsif WB_WIDTH32
  `define WB_WIDTH 32
  `define SPORT_WIDTH32
`elsif WB_WIDTH16
  `define WB_WIDTH 16
  `define SPORT_WIDTH16
`else
  `define WB_WIDTH 8
  `define SPORT_WIDTH8
`endif

//define the width of WB address
`define WB_ADDR_WIDTH 6

/*********************** SPORT DEFINES *****************************/
//SPORT_WIDTH defined above

//define depth of FIFO 
`define SPORT_FIFODEPTH 10
  
//uncomment a single implementation of FIFO;
`define SPORT_CUSTOMFIFO
//`define SPORT_XILINX
//`define SPORT_ALTERA

//set to base address of controller; base address is data FIFO, and the config registers are relative to it
`define SPORT_ADDR 6'h01
`define SPORT_ADDR_MASK 6'h20

`define WB_CNFG_RX `SPORT_ADDR+1
`define WB_CNFG_TX `SPORT_ADDR+2

`define RESET 3'h0
`define IDLE  3'h1
`define FS    3'h3
`define RX    3'h2
`define TX    3'h2
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: $
//
