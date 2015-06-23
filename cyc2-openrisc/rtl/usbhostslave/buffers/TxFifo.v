//////////////////////////////////////////////////////////////////////
////                                                              ////
//// TxFifo.v                                                     ////
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
////  parameterized TxFifo wrapper. Min depth = 2, Max depth = 65536
////  fifo write access via bus interface, fifo read access is direct
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
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
`include "timescale.v"

module TxFifo(
  busClk,
  usbClk,
  rstSyncToBusClk, 
  rstSyncToUsbClk, 
  fifoREn, 
  fifoEmpty,
  busAddress, 
  busWriteEn, 
  busStrobe_i,
  busFifoSelect,
  busDataIn,
  busDataOut,
  fifoDataOut ); 
  //FIFO_DEPTH = ADDR_WIDTH^2
  parameter FIFO_DEPTH = 64; 
  parameter ADDR_WIDTH = 6;   
  
input busClk; 
input usbClk; 
input rstSyncToBusClk; 
input rstSyncToUsbClk; 
input fifoREn; 
output fifoEmpty;
input [2:0] busAddress; 
input busWriteEn; 
input busStrobe_i;
input busFifoSelect;
input [7:0] busDataIn; 
output [7:0] busDataOut; 
output [7:0] fifoDataOut;

wire busClk; 
wire usbClk; 
wire rstSyncToBusClk; 
wire rstSyncToUsbClk; 
wire fifoREn; 
wire fifoEmpty;
wire [2:0] busAddress; 
wire busWriteEn; 
wire busStrobe_i;
wire busFifoSelect;
wire [7:0] busDataIn; 
wire [7:0] busDataOut; 
wire [7:0] fifoDataOut;

//internal wires and regs
wire fifoWEn;
wire forceEmptySyncToUsbClk;
wire forceEmptySyncToBusClk;
wire [15:0] numElementsInFifo;
wire fifoFull;

fifoRTL #(8, FIFO_DEPTH, ADDR_WIDTH) u_fifo(
  .wrClk(busClk), 
  .rdClk(usbClk), 
  .rstSyncToWrClk(rstSyncToBusClk), 
  .rstSyncToRdClk(rstSyncToUsbClk), 
  .dataIn(busDataIn), 
  .dataOut(fifoDataOut), 
  .fifoWEn(fifoWEn), 
  .fifoREn(fifoREn), 
  .fifoFull(fifoFull), 
  .fifoEmpty(fifoEmpty), 
  .forceEmptySyncToWrClk(forceEmptySyncToBusClk), 
  .forceEmptySyncToRdClk(forceEmptySyncToUsbClk), 
  .numElementsInFifo(numElementsInFifo) );
  
TxfifoBI u_TxfifoBI(
  .address(busAddress), 
  .writeEn(busWriteEn), 
  .strobe_i(busStrobe_i),
  .busClk(busClk), 
  .usbClk(usbClk), 
  .rstSyncToBusClk(rstSyncToBusClk), 
  .fifoSelect(busFifoSelect),
  .busDataIn(busDataIn), 
  .busDataOut(busDataOut), 
  .fifoWEn(fifoWEn),
  .forceEmptySyncToBusClk(forceEmptySyncToBusClk),
  .forceEmptySyncToUsbClk(forceEmptySyncToUsbClk),
  .numElementsInFifo(numElementsInFifo)
  );

endmodule
