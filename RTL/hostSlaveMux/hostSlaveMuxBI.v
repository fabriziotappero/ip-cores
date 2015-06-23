//////////////////////////////////////////////////////////////////////
////                                                              ////
//// hostSlaveMuxBI.v                                             ////
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
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
`include "usbHostSlave_h.v"

module hostSlaveMuxBI (dataIn, dataOut, address, writeEn, strobe_i, busClk, usbClk,
  hostMode, hostSlaveMuxSel, rstFromWire, rstSyncToBusClkOut, rstSyncToUsbClkOut);

input [7:0] dataIn;
input address;
input writeEn;
input strobe_i;
input busClk;
input usbClk;
output [7:0] dataOut;
input hostSlaveMuxSel;
output hostMode;
input rstFromWire;
output rstSyncToBusClkOut;
output rstSyncToUsbClkOut;

wire [7:0] dataIn;
wire address;
wire writeEn;
wire strobe_i;
wire busClk;
wire usbClk;
reg [7:0] dataOut;
wire hostSlaveMuxSel;
reg hostMode;
wire rstFromWire;
reg rstSyncToBusClkOut;
reg rstSyncToUsbClkOut;

//internal wire and regs
reg [5:0] rstShift;
reg rstFromBus;
reg rstSyncToUsbClkFirst;

//sync write demux
always @(posedge busClk)
begin
  if (rstSyncToBusClkOut == 1'b1)
    hostMode <= 1'b0;
  else begin
    if (writeEn == 1'b1 && hostSlaveMuxSel == 1'b1 && strobe_i == 1'b1 && address == `HOST_SLAVE_CONTROL_REG )
      hostMode <= dataIn[0];
    end
    if (writeEn == 1'b1 && hostSlaveMuxSel == 1'b1 && strobe_i == 1'b1 && address == `HOST_SLAVE_CONTROL_REG && dataIn[1] == 1'b1 )
      rstFromBus <= 1'b1;
    else
      rstFromBus <= 1'b0;
end

// async read mux
always @(address or hostMode)
begin
  case (address)
    `HOST_SLAVE_CONTROL_REG: dataOut <= {7'h0, hostMode};
    `HOST_SLAVE_VERSION_REG: dataOut <= `USBHOSTSLAVE_VERSION_NUM;
  endcase
end

// reset control
//generate 'rstSyncToBusClk'
//assuming that 'busClk' < 5 * 'usbClk'. ie 'busClk' < 240MHz
always @(posedge busClk) begin
  if (rstFromWire == 1'b1 || rstFromBus == 1'b1) 
    rstShift <= 6'b111111;
  else
    rstShift <= {1'b0, rstShift[5:1]};
end

always @(rstShift)
  rstSyncToBusClkOut <= rstShift[0];

// double sync across clock domains to generate 'forceEmptySyncToWrClk'
always @(posedge usbClk) begin
    rstSyncToUsbClkFirst <= rstSyncToBusClkOut;
    rstSyncToUsbClkOut <= rstSyncToUsbClkFirst;
end

endmodule
