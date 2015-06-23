//////////////////////////////////////////////////////////////////////
////                                                              ////
////  wiegand_defines.v                                           ////
////                                                              ////
////                                                              ////
////  This file is part of the Wiegand Controller                 ////
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
  `define WB_DATA_W 63:0
  `define WIEGAND_WIDTH64
`elsif WB_WIDTH32
  `define WB_WIDTH 32
  `define WB_DATA_W 31:0
  `define WIEGAND_WIDTH32
`elsif WB_WIDTH16
  `define WB_WIDTH 16
  `define WB_DATA_W 15:0
  `define WIEGAND_WIDTH16
`else
  `define WB_WIDTH 8
  `define WB_DATA_W 7:0
  `define WIEGAND_WIDTH8
`endif

//define the width of WB address
`define WB_ADDR_WIDTH 6

/*********************** WIEGAND DEFINES *****************************/
//WIEGAND_WIDTH defined above
`define WB_ADDR_WIDTH_DIV2  (`WIEGAND_ADDR)/2
//define depth of FIFO for 64-bit message format;  largest message I've seen in open literature;  64/`WB_WIDTH
`define WIEGAND_FIFODEPTH 3
  
//uncomment a single implementation of FIFO;
`define WIEGAND_CUSTOMFIFO

//set to base address of controller; base address is data FIFO, and the config registers are relative to it
`define WIEG_ADDR_MASK 6'b111100
`define WIEGAND_ADDR 6'h00

`define WB_CNFG_PW (`WIEGAND_ADDR)+1
`define WB_CNFG_P2P (`WIEGAND_ADDR)+2
`define WB_CNFG_MSGSIZE (`WIEGAND_ADDR)+3

//states in teh state machine
`define BIT  3'b111
`define LASTBIT   3'b100
`define IDLE  3'b000
`define DATA  3'b001
`define TX    3'b101
`define DONE  3'b110


//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: $
//
