//////////////////////////////////////////////////////////////////////
////                                                              ////
//// hostSlaveMux.v                                               ////
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
//// Controls the select line for the mux that enables the sharing
//// of a single SerialInterfaceEgine between the hostController
//// and slaveController
//// Also a dumping area for any features common to host and slave 
//// operation. That is reset control and version number report.
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

module hostSlaveMux (
  SIEPortCtrlInToSIE,
  SIEPortCtrlInFromHost,
  SIEPortCtrlInFromSlave,
  SIEPortDataInToSIE, 
  SIEPortDataInFromHost, 
  SIEPortDataInFromSlave, 
  SIEPortWEnToSIE, 
  SIEPortWEnFromHost, 
  SIEPortWEnFromSlave, 
  fullSpeedPolarityToSIE,
  fullSpeedPolarityFromHost,
  fullSpeedPolarityFromSlave,
  fullSpeedBitRateToSIE,
  fullSpeedBitRateFromHost,
  fullSpeedBitRateFromSlave,
  noActivityTimeOutEnableToSIE,
  noActivityTimeOutEnableFromHost,
  noActivityTimeOutEnableFromSlave,
  dataIn, 
  dataOut,
  address,
  writeEn,
  strobe_i,
  busClk, 
  usbClk, 
  hostSlaveMuxSel,
  rstFromWire,
  rstSyncToBusClkOut,
  rstSyncToUsbClkOut
);


output [7:0] SIEPortCtrlInToSIE;
input [7:0] SIEPortCtrlInFromHost;
input [7:0] SIEPortCtrlInFromSlave;
output [7:0] SIEPortDataInToSIE; 
input [7:0] SIEPortDataInFromHost; 
input [7:0] SIEPortDataInFromSlave; 
output SIEPortWEnToSIE; 
input SIEPortWEnFromHost; 
input SIEPortWEnFromSlave; 
output fullSpeedPolarityToSIE;
input fullSpeedPolarityFromHost;
input fullSpeedPolarityFromSlave;
output fullSpeedBitRateToSIE;
input fullSpeedBitRateFromHost;
input fullSpeedBitRateFromSlave;
output noActivityTimeOutEnableToSIE;
input noActivityTimeOutEnableFromHost;
input noActivityTimeOutEnableFromSlave;
//hostSlaveMuxBI
input [7:0] dataIn;
input address;
input writeEn;
input strobe_i;
input busClk;
input usbClk;
input rstFromWire;
output rstSyncToBusClkOut;
output rstSyncToUsbClkOut;
output [7:0] dataOut;
input hostSlaveMuxSel;

reg [7:0] SIEPortCtrlInToSIE;
wire [7:0] SIEPortCtrlInFromHost;
wire [7:0] SIEPortCtrlInFromSlave;
reg [7:0] SIEPortDataInToSIE; 
wire [7:0] SIEPortDataInFromHost; 
wire [7:0] SIEPortDataInFromSlave; 
reg SIEPortWEnToSIE; 
wire SIEPortWEnFromHost; 
wire SIEPortWEnFromSlave; 
reg fullSpeedPolarityToSIE;
wire fullSpeedPolarityFromHost;
wire fullSpeedPolarityFromSlave;
reg fullSpeedBitRateToSIE;
wire fullSpeedBitRateFromHost;
wire fullSpeedBitRateFromSlave;
reg noActivityTimeOutEnableToSIE;
wire noActivityTimeOutEnableFromHost;
wire noActivityTimeOutEnableFromSlave;
//hostSlaveMuxBI
wire [7:0] dataIn;
wire address;
wire writeEn;
wire strobe_i;
wire busClk;
wire usbClk;
wire rstSyncToBusClkOut;
wire rstSyncToUsbClkOut;
wire rstFromWire;
wire [7:0] dataOut;
wire hostSlaveMuxSel;

//internal wires and regs
wire hostMode;

always @(hostMode or
  SIEPortCtrlInFromHost or
  SIEPortCtrlInFromSlave or
  SIEPortDataInFromHost or 
  SIEPortDataInFromSlave or 
  SIEPortWEnFromHost or 
  SIEPortWEnFromSlave or 
  fullSpeedPolarityFromHost or
  fullSpeedPolarityFromSlave or
  fullSpeedBitRateFromHost or
  fullSpeedBitRateFromSlave or
  noActivityTimeOutEnableFromHost or
  noActivityTimeOutEnableFromSlave)
begin
  if (hostMode == 1'b1) 
  begin
    SIEPortCtrlInToSIE <= SIEPortCtrlInFromHost;
    SIEPortDataInToSIE <=  SIEPortDataInFromHost;
    SIEPortWEnToSIE <= SIEPortWEnFromHost;
    fullSpeedPolarityToSIE <= fullSpeedPolarityFromHost;
    fullSpeedBitRateToSIE <= fullSpeedBitRateFromHost;
    noActivityTimeOutEnableToSIE <= noActivityTimeOutEnableFromHost;
  end
  else
  begin
    SIEPortCtrlInToSIE <= SIEPortCtrlInFromSlave;
    SIEPortDataInToSIE <=  SIEPortDataInFromSlave;
    SIEPortWEnToSIE <= SIEPortWEnFromSlave;
    fullSpeedPolarityToSIE <= fullSpeedPolarityFromSlave;
    fullSpeedBitRateToSIE <= fullSpeedBitRateFromSlave;
    noActivityTimeOutEnableToSIE <= noActivityTimeOutEnableFromSlave;
  end
end      

hostSlaveMuxBI u_hostSlaveMuxBI (
  .dataIn(dataIn), 
  .dataOut(dataOut),
  .address(address),
  .writeEn(writeEn), 
  .strobe_i(strobe_i),
  .busClk(busClk), 
  .usbClk(usbClk), 
  .hostMode(hostMode), 
  .hostSlaveMuxSel(hostSlaveMuxSel),  
  .rstFromWire(rstFromWire),
  .rstSyncToBusClkOut(rstSyncToBusClkOut),
  .rstSyncToUsbClkOut(rstSyncToUsbClkOut) );


endmodule
