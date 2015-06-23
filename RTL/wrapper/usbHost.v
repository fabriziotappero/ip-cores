//////////////////////////////////////////////////////////////////////
////                                                              ////
//// usbHost.v                                                    ////
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
////   Top level module
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

module usbHost(
  clk_i,
  rst_i,
  address_i, 
  data_i, 
  data_o, 
  we_i, 
  strobe_i,
  ack_o,
  usbClk,
  hostSOFSentIntOut, 
  hostConnEventIntOut, 
  hostResumeIntOut, 
  hostTransDoneIntOut,
  USBWireDataIn,
  USBWireDataInTick,
  USBWireDataOut,
  USBWireDataOutTick,
  USBWireCtrlOut,
  USBFullSpeed
   );
  parameter HOST_FIFO_DEPTH = 64; //HOST_FIFO_DEPTH = 2^HOST_ADDR_WIDTH
  parameter HOST_FIFO_ADDR_WIDTH = 6;   
  

input clk_i;               //Wishbone bus clock. Maximum 5*usbClk=240MHz
input rst_i;               //Wishbone bus sync reset. Synchronous to 'clk_i'. Resets all logic
input [7:0] address_i;     //Wishbone bus address in
input [7:0] data_i;        //Wishbone bus data in
output [7:0] data_o;       //Wishbone bus data out
input we_i;                //Wishbone bus write enable in
input strobe_i;            //Wishbone bus strobe in
output ack_o;              //Wishbone bus acknowledge out
input usbClk;              //usb clock. 48Mhz +/-0.25%
output hostSOFSentIntOut; 
output hostConnEventIntOut; 
output hostResumeIntOut; 
output hostTransDoneIntOut;
input [1:0] USBWireDataIn;
output [1:0] USBWireDataOut;
output USBWireDataOutTick;
output USBWireDataInTick;
output USBWireCtrlOut;
output USBFullSpeed;

wire clk_i;
wire rst_i;
wire [7:0] address_i; 
wire [7:0] data_i; 
wire [7:0] data_o; 
wire we_i; 
wire strobe_i;
wire ack_o;
wire usbClk;
wire hostSOFSentIntOut; 
wire hostConnEventIntOut; 
wire hostResumeIntOut; 
wire hostTransDoneIntOut;
wire [1:0] USBWireDataIn;
wire [1:0] USBWireDataOut;
wire USBWireDataOutTick;
wire USBWireDataInTick;
wire USBWireCtrlOut;
wire USBFullSpeed;

//internal wiring
wire hostControlSel;
wire slaveControlSel;
wire hostRxFifoSel; 
wire hostTxFifoSel;
wire hostSlaveMuxSel;
wire [7:0] dataFromHostControl;
wire [7:0] dataFromSlaveControl;
wire [7:0] dataFromHostRxFifo;
wire [7:0] dataFromHostTxFifo;
wire [7:0] dataFromHostSlaveMux;
wire hostTxFifoRE; 
wire [7:0] hostTxFifoData; 
wire hostTxFifoEmpty;
wire hostRxFifoWE; 
wire [7:0] hostRxFifoData; 
wire hostRxFifoFull;
wire [7:0] RxCtrlOut; 
wire [7:0] RxDataFromSIE; 
wire RxDataOutWEn;
wire fullSpeedBitRateFromHost; 
wire fullSpeedPolarityFromHost;
wire SIEPortWEnFromHost; 
wire SIEPortTxRdy;
wire [7:0] SIEPortDataInFromHost; 
wire [7:0] SIEPortCtrlInFromHost;
wire [1:0] connectState; 
wire resumeDetected;
wire [7:0] SIEPortDataInToSIE;
wire SIEPortWEnToSIE;
wire [7:0] SIEPortCtrlInToSIE;
wire fullSpeedPolarityToSIE;
wire fullSpeedBitRateToSIE;
wire noActivityTimeOut;
wire rstSyncToBusClk;
wire rstSyncToUsbClk;
wire noActivityTimeOutEnableToSIE;
wire noActivityTimeOutEnableFromHost;

// This is not a bug.
// USBFullSpeed controls the PHY edge speed.
// The only time that the PHY needs to operate with low speed edge rate is
// when the host is directly connected to a low speed device. And when this is true, fullSpeedPolarity
// will be low. When the host is connected to a low speed device via a hub, then speed can be full or low
// but according to spec edge speed must be full rate edge speed. 
assign USBFullSpeed = fullSpeedPolarityToSIE;
//assign USBFullSpeed = fullSpeedBitRateToSIE;

usbHostControl u_usbHostControl(
  .busClk(clk_i), 
  .rstSyncToBusClk(rstSyncToBusClk),
  .usbClk(usbClk), 
  .rstSyncToUsbClk(rstSyncToUsbClk),
  .TxFifoRE(hostTxFifoRE), 
  .TxFifoData(hostTxFifoData), 
  .TxFifoEmpty(hostTxFifoEmpty),
  .RxFifoWE(hostRxFifoWE), 
  .RxFifoData(hostRxFifoData), 
  .RxFifoFull(hostRxFifoFull),
  .RxByteStatus(RxCtrlOut), 
  .RxData(RxDataFromSIE), 
  .RxDataValid(RxDataOutWEn),
  .SIERxTimeOut(noActivityTimeOut),
  .SIERxTimeOutEn(noActivityTimeOutEnableFromHost),
  .fullSpeedRate(fullSpeedBitRateFromHost), 
  .fullSpeedPol(fullSpeedPolarityFromHost),
  .HCTxPortEn(SIEPortWEnFromHost), 
  .HCTxPortRdy(SIEPortTxRdy),
  .HCTxPortData(SIEPortDataInFromHost), 
  .HCTxPortCtrl(SIEPortCtrlInFromHost),
  .connectStateIn(connectState), 
  .resumeDetectedIn(resumeDetected),
  .busAddress(address_i[3:0]),
  .busDataIn(data_i), 
  .busDataOut(dataFromHostControl), 
  .busWriteEn(we_i),
  .busStrobe_i(strobe_i),
  .SOFSentIntOut(hostSOFSentIntOut), 
  .connEventIntOut(hostConnEventIntOut), 
  .resumeIntOut(hostResumeIntOut), 
  .transDoneIntOut(hostTransDoneIntOut),
  .hostControlSelect(hostControlSel) );


wishBoneBI u_wishBoneBI (
  .address(address_i), 
  .dataIn(data_i), 
  .dataOut(data_o), 
  .writeEn(we_i), 
  .strobe_i(strobe_i),
  .ack_o(ack_o),
  .clk(clk_i), 
  .rst(rstSyncToBusClk),
  .hostControlSel(hostControlSel), 
  .hostRxFifoSel(hostRxFifoSel), 
  .hostTxFifoSel(hostTxFifoSel),
  .slaveControlSel(),
  .slaveEP0RxFifoSel(), 
  .slaveEP1RxFifoSel(),
  .slaveEP2RxFifoSel(), 
  .slaveEP3RxFifoSel(), 
  .slaveEP0TxFifoSel(), 
  .slaveEP1TxFifoSel(), 
  .slaveEP2TxFifoSel(), 
  .slaveEP3TxFifoSel(), 
  .hostSlaveMuxSel(hostSlaveMuxSel),
  .dataFromHostControl(dataFromHostControl),
  .dataFromHostRxFifo(dataFromHostRxFifo),
  .dataFromHostTxFifo(dataFromHostTxFifo),
  .dataFromSlaveControl(8'h00),
  .dataFromEP0RxFifo(8'h00), 
  .dataFromEP1RxFifo(8'h00), 
  .dataFromEP2RxFifo(8'h00), 
  .dataFromEP3RxFifo(8'h00),
  .dataFromEP0TxFifo(8'h00), 
  .dataFromEP1TxFifo(8'h00), 
  .dataFromEP2TxFifo(8'h00), 
  .dataFromEP3TxFifo(8'h00),
  .dataFromHostSlaveMux(dataFromHostSlaveMux)
   );


assign SIEPortCtrlInToSIE = SIEPortCtrlInFromHost;
assign SIEPortDataInToSIE = SIEPortDataInFromHost;
assign SIEPortWEnToSIE = SIEPortWEnFromHost;
assign fullSpeedPolarityToSIE = fullSpeedPolarityFromHost;
assign fullSpeedBitRateToSIE = fullSpeedBitRateFromHost;
assign noActivityTimeOutEnableToSIE = noActivityTimeOutEnableFromHost;

hostSlaveMuxBI u_hostSlaveMuxBI (
  .dataIn(data_i), 
  .dataOut(dataFromHostSlaveMux),
  .address(address_i[0]),
  .writeEn(we_i),
  .strobe_i(strobe_i),
  .usbClk(usbClk), 
  .busClk(clk_i), 
  .hostMode(hostMode), 
  .hostSlaveMuxSel(hostSlaveMuxSel),  
  .rstFromWire(rst_i),
  .rstSyncToBusClkOut(rstSyncToBusClk),
  .rstSyncToUsbClkOut(rstSyncToUsbClk)
);

usbSerialInterfaceEngine u_usbSerialInterfaceEngine(
  .clk(usbClk), 
  .rst(rstSyncToUsbClk),
  .USBWireDataIn(USBWireDataIn),
  .USBWireDataOut(USBWireDataOut),
  .USBWireDataInTick(USBWireDataInTick),
  .USBWireDataOutTick(USBWireDataOutTick),
  .USBWireCtrlOut(USBWireCtrlOut),
  .connectState(connectState),
  .resumeDetected(resumeDetected),
  .RxCtrlOut(RxCtrlOut), 
  .RxDataOutWEn(RxDataOutWEn), 
  .RxDataOut(RxDataFromSIE), 
  .SIEPortCtrlIn(SIEPortCtrlInToSIE),
  .SIEPortDataIn(SIEPortDataInToSIE), 
  .SIEPortTxRdy(SIEPortTxRdy), 
  .SIEPortWEn(SIEPortWEnToSIE), 
  .fullSpeedPolarity(fullSpeedPolarityToSIE),
  .fullSpeedBitRate(fullSpeedBitRateToSIE),
  .noActivityTimeOut(noActivityTimeOut),
  .noActivityTimeOutEnable(noActivityTimeOutEnableToSIE)
);



//---Host fifos
TxFifo #(HOST_FIFO_DEPTH, HOST_FIFO_ADDR_WIDTH) HostTxFifo (
  .usbClk(usbClk), 
  .busClk(clk_i), 
  .rstSyncToBusClk(rstSyncToBusClk), 
  .rstSyncToUsbClk(rstSyncToUsbClk), 
  .fifoREn(hostTxFifoRE), 
  .fifoEmpty(hostTxFifoEmpty),
  .busAddress(address_i[2:0]), 
  .busWriteEn(we_i), 
  .busStrobe_i(strobe_i),
  .busFifoSelect(hostTxFifoSel),
  .busDataIn(data_i), 
  .busDataOut(dataFromHostTxFifo),
  .fifoDataOut(hostTxFifoData) );


RxFifo #(HOST_FIFO_DEPTH, HOST_FIFO_ADDR_WIDTH) HostRxFifo(
  .usbClk(usbClk), 
  .busClk(clk_i),
  .rstSyncToBusClk(rstSyncToBusClk), 
  .rstSyncToUsbClk(rstSyncToUsbClk), 
  .fifoWEn(hostRxFifoWE), 
  .fifoFull(hostRxFifoFull),
  .busAddress(address_i[2:0]), 
  .busWriteEn(we_i), 
  .busStrobe_i(strobe_i),
  .busFifoSelect(hostRxFifoSel),
  .busDataIn(data_i), 
  .busDataOut(dataFromHostRxFifo),
  .fifoDataIn(hostRxFifoData)  );


endmodule

  
  




