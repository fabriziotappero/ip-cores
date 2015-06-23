//////////////////////////////////////////////////////////////////////
////                                                              ////
//// usbSlaveControl.v                                            ////
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

module usbSlaveControl(
  busClk, 
  rstSyncToBusClk,
  usbClk, 
  rstSyncToUsbClk,
  //getPacket
  RxByteStatus, RxData, RxDataValid,
  SIERxTimeOut, RxFifoData, SIERxTimeOutEn,
  //speedCtrlMux
  fullSpeedRate, fullSpeedPol,
  connectSlaveToHost,
  //SCTxPortArbiter
  SCTxPortEn, SCTxPortRdy,
  SCTxPortData, SCTxPortCtrl,
  //rxStatusMonitor
  vBusDetect,
  connectStateIn, 
  resumeDetectedIn,
  //USBHostControlBI 
  busAddress,
  busDataIn, 
  busDataOut, 
  busWriteEn,
  busStrobe_i,
  SOFRxedIntOut, 
  resetEventIntOut, 
  resumeIntOut, 
  transDoneIntOut,
  vBusDetIntOut,
  NAKSentIntOut,
  slaveControlSelect,
  //fifoMux
  TxFifoEP0REn,
  TxFifoEP1REn,
  TxFifoEP2REn,
  TxFifoEP3REn,
  TxFifoEP0Data,
  TxFifoEP1Data,
  TxFifoEP2Data,
  TxFifoEP3Data,
  TxFifoEP0Empty,
  TxFifoEP1Empty,
  TxFifoEP2Empty,
  TxFifoEP3Empty,
  RxFifoEP0WEn,
  RxFifoEP1WEn,
  RxFifoEP2WEn,
  RxFifoEP3WEn,
  RxFifoEP0Full,
  RxFifoEP1Full,
  RxFifoEP2Full,
  RxFifoEP3Full
    );

input busClk; 
input rstSyncToBusClk;
input usbClk; 
input rstSyncToUsbClk;
//getPacket
input [7:0] RxByteStatus;
input [7:0] RxData;
input RxDataValid;
input SIERxTimeOut; 
output SIERxTimeOutEn;
output [7:0] RxFifoData;
//speedCtrlMux
output fullSpeedRate;
output fullSpeedPol;
output connectSlaveToHost;
//HCTxPortArbiter
output SCTxPortEn;
input SCTxPortRdy;
output [7:0] SCTxPortData;
output [7:0] SCTxPortCtrl;
//rxStatusMonitor
input vBusDetect;
input [1:0] connectStateIn;
input resumeDetectedIn;
//USBHostControlBI 
input [4:0] busAddress;
input [7:0] busDataIn; 
output [7:0] busDataOut; 
input busWriteEn;
input busStrobe_i;
output SOFRxedIntOut; 
output resetEventIntOut; 
output resumeIntOut; 
output transDoneIntOut;
output vBusDetIntOut;
output NAKSentIntOut;
input slaveControlSelect;
//fifoMux
output TxFifoEP0REn;
output TxFifoEP1REn;
output TxFifoEP2REn;
output TxFifoEP3REn;
input [7:0] TxFifoEP0Data;
input [7:0] TxFifoEP1Data;
input [7:0] TxFifoEP2Data;
input [7:0] TxFifoEP3Data;
input TxFifoEP0Empty;
input TxFifoEP1Empty;
input TxFifoEP2Empty;
input TxFifoEP3Empty;
output RxFifoEP0WEn;
output RxFifoEP1WEn;
output RxFifoEP2WEn;
output RxFifoEP3WEn;
input RxFifoEP0Full;
input RxFifoEP1Full;
input RxFifoEP2Full;
input RxFifoEP3Full;

wire busClk; 
wire rstSyncToBusClk;
wire usbClk; 
wire rstSyncToUsbClk;
wire [7:0] RxByteStatus;
wire [7:0] RxData;
wire RxDataValid;
wire SIERxTimeOut;
wire SIERxTimeOutEn;
wire [7:0] RxFifoData;
wire fullSpeedRate;
wire fullSpeedPol;
wire connectSlaveToHost;
wire [7:0] SCTxPortData;
wire [7:0] SCTxPortCtrl;
wire [1:0] connectStateIn;
wire resumeDetectedIn;
wire [4:0] busAddress;
wire [7:0] busDataIn; 
wire [7:0] busDataOut; 
wire busWriteEn;
wire busStrobe_i;
wire SOFRxedIntOut; 
wire resetEventIntOut; 
wire resumeIntOut; 
wire transDoneIntOut;
wire vBusDetIntOut;
wire NAKSentIntOut;
wire slaveControlSelect;
wire TxFifoEP0REn;
wire TxFifoEP1REn;
wire TxFifoEP2REn;
wire TxFifoEP3REn;
wire [7:0] TxFifoEP0Data;
wire [7:0] TxFifoEP1Data;
wire [7:0] TxFifoEP2Data;
wire [7:0] TxFifoEP3Data;
wire TxFifoEP0Empty;
wire TxFifoEP1Empty;
wire TxFifoEP2Empty;
wire TxFifoEP3Empty;
wire RxFifoEP0WEn;
wire RxFifoEP1WEn;
wire RxFifoEP2WEn;
wire RxFifoEP3WEn;
wire RxFifoEP0Full;
wire RxFifoEP1Full;
wire RxFifoEP2Full;
wire RxFifoEP3Full;

//internal wiring
wire [7:0] directCntlCntl;
wire [7:0] directCntlData;
wire directCntlGnt;
wire directCntlReq;
wire directCntlWEn;
wire [7:0] sendPacketCntl;
wire [7:0] sendPacketData;
wire sendPacketGnt;
wire sendPacketReq;
wire sendPacketWEn;    
wire SCTxPortArbRdyOut;
wire transDone;
wire [1:0] directLineState;
wire directLineCtrlEn;
wire [3:0] RxPID;
wire [1:0] connectStateOut;
wire resumeIntFromRxStatusMon;
wire [1:0] endP0TransTypeReg;
wire [1:0] endP1TransTypeReg;
wire [1:0] endP2TransTypeReg;
wire [1:0] endP3TransTypeReg;
wire [1:0] endP0NAKTransTypeReg;
wire [1:0] endP1NAKTransTypeReg;
wire [1:0] endP2NAKTransTypeReg;
wire [1:0] endP3NAKTransTypeReg;
wire [4:0] endP0ControlReg;
wire [4:0] endP1ControlReg;
wire [4:0] endP2ControlReg;
wire [4:0] endP3ControlReg;
wire [7:0] endP0StatusReg;
wire [7:0] endP1StatusReg;
wire [7:0] endP2StatusReg;
wire [7:0] endP3StatusReg;
wire [6:0] USBTgtAddress;
wire [10:0] frameNum;
wire clrEP0Rdy;
wire clrEP1Rdy;
wire clrEP2Rdy;
wire clrEP3Rdy;
wire SCGlobalEn;
wire ACKRxed; 
wire CRCError; 
wire RXOverflow; 
wire RXTimeOut; 
wire bitStuffError; 
wire dataSequence; 
wire stallSent;
wire NAKSent;
wire SOFRxed;
wire [4:0] endPControlReg;
wire [1:0] transTypeNAK;
wire [1:0] transType;
wire [3:0] currEndP;
wire getPacketREn;
wire getPacketRdy;
wire [3:0] slaveControllerPIDOut;
wire slaveControllerReadyIn;
wire slaveControllerWEnOut;
wire TxFifoRE;
wire [7:0] TxFifoData;
wire TxFifoEmpty;
wire RxFifoWE;
wire RxFifoFull;
wire resetEventFromRxStatusMon;
wire clrEPRdy;
wire endPMuxErrorsWEn;
wire endPointReadyFromSlaveCtrlrToGetPkt;

USBSlaveControlBI u_USBSlaveControlBI
  (.address(busAddress),
  .dataIn(busDataIn), 
  .dataOut(busDataOut), 
  .writeEn(busWriteEn),
  .strobe_i(busStrobe_i),
  .busClk(busClk), 
  .rstSyncToBusClk(rstSyncToBusClk),
  .usbClk(usbClk), 
  .rstSyncToUsbClk(rstSyncToUsbClk),
  .SOFRxedIntOut(SOFRxedIntOut), 
  .resetEventIntOut(resetEventIntOut), 
  .resumeIntOut(resumeIntOut), 
  .transDoneIntOut(transDoneIntOut),
  .vBusDetIntOut(vBusDetIntOut),
  .NAKSentIntOut(NAKSentIntOut),
  .endP0TransTypeReg(endP0TransTypeReg), 
  .endP0NAKTransTypeReg(endP0NAKTransTypeReg),
  .endP1TransTypeReg(endP1TransTypeReg), 
  .endP1NAKTransTypeReg(endP1NAKTransTypeReg),
  .endP2TransTypeReg(endP2TransTypeReg), 
  .endP2NAKTransTypeReg(endP2NAKTransTypeReg),
  .endP3TransTypeReg(endP3TransTypeReg), 
  .endP3NAKTransTypeReg(endP3NAKTransTypeReg),
  .endP0ControlReg(endP0ControlReg),
  .endP1ControlReg(endP1ControlReg),
  .endP2ControlReg(endP2ControlReg),
  .endP3ControlReg(endP3ControlReg),
  .EP0StatusReg(endP0StatusReg),
  .EP1StatusReg(endP1StatusReg),
  .EP2StatusReg(endP2StatusReg),
  .EP3StatusReg(endP3StatusReg),
  .SCAddrReg(USBTgtAddress), 
  .frameNum(frameNum),
  .connectStateIn(connectStateOut),
  .vBusDetectIn(vBusDetect),
  .SOFRxedIn(SOFRxed), 
  .resetEventIn(resetEventFromRxStatusMon), 
  .resumeIntIn(resumeIntFromRxStatusMon), 
  .transDoneIn(transDone),
  .NAKSentIn(NAKSent),
  .slaveControlSelect(slaveControlSelect),
  .clrEP0Ready(clrEP0Rdy), 
  .clrEP1Ready(clrEP1Rdy), 
  .clrEP2Ready(clrEP2Rdy), 
  .clrEP3Ready(clrEP3Rdy),
  .TxLineState(directLineState),
  .LineDirectControlEn(directLineCtrlEn),
  .fullSpeedPol(fullSpeedPol), 
  .fullSpeedRate(fullSpeedRate),
  .connectSlaveToHost(connectSlaveToHost),
  .SCGlobalEn(SCGlobalEn)
  );

slavecontroller u_slavecontroller
  (.CRCError(CRCError), 
  .NAKSent(NAKSent), 
  .RxByte(RxData), 
  .RxDataWEn(RxDataValid), 
  .RxOverflow(RXOverflow), 
  .RxStatus(RxByteStatus), 
  .RxTimeOut(RXTimeOut), 
  .SCGlobalEn(SCGlobalEn), 
  .SOFRxed(SOFRxed), 
  .USBEndPControlReg(endPControlReg), 
  .USBEndPNakTransTypeReg(transTypeNAK), 
  .USBEndPTransTypeReg(transType), 
  .USBEndP(currEndP), 
  .USBTgtAddress(USBTgtAddress),
  .bitStuffError(bitStuffError), 
  .clk(usbClk), 
  .clrEPRdy(clrEPRdy), 
  .endPMuxErrorsWEn(endPMuxErrorsWEn), 
  .frameNum(frameNum), 
  .getPacketREn(getPacketREn), 
  .getPacketRdy(getPacketRdy), 
  .rst(rstSyncToUsbClk), 
  .sendPacketPID(slaveControllerPIDOut), 
  .sendPacketRdy(slaveControllerReadyIn), 
  .sendPacketWEn(slaveControllerWEnOut), 
  .stallSent(stallSent), 
  .transDone(transDone),
  .endPointReadyToGetPkt(endPointReadyFromSlaveCtrlrToGetPkt)
    );


endpMux u_endpMux (
  .clk(usbClk), 
  .rst(rstSyncToUsbClk),
  .currEndP(currEndP),
  .NAKSent(NAKSent),
  .stallSent(stallSent),
  .CRCError(CRCError),
  .bitStuffError(bitStuffError),
  .RxOverflow(RXOverflow),
  .RxTimeOut(RXTimeOut),
  .dataSequence(dataSequence),
  .ACKRxed(ACKRxed),
  .transType(transType),
  .transTypeNAK(transTypeNAK),
  .endPControlReg(endPControlReg),
  .clrEPRdy(clrEPRdy),
  .endPMuxErrorsWEn(endPMuxErrorsWEn),
  .endP0ControlReg(endP0ControlReg),
  .endP1ControlReg(endP1ControlReg),
  .endP2ControlReg(endP2ControlReg),
  .endP3ControlReg(endP3ControlReg),
  .endP0StatusReg(endP0StatusReg),
  .endP1StatusReg(endP1StatusReg),
  .endP2StatusReg(endP2StatusReg),
  .endP3StatusReg(endP3StatusReg),
  .endP0TransTypeReg(endP0TransTypeReg),
  .endP1TransTypeReg(endP1TransTypeReg),
  .endP2TransTypeReg(endP2TransTypeReg),
  .endP3TransTypeReg(endP3TransTypeReg),
  .endP0NAKTransTypeReg(endP0NAKTransTypeReg),
  .endP1NAKTransTypeReg(endP1NAKTransTypeReg),
  .endP2NAKTransTypeReg(endP2NAKTransTypeReg),
  .endP3NAKTransTypeReg(endP3NAKTransTypeReg),
  .clrEP0Rdy(clrEP0Rdy),
  .clrEP1Rdy(clrEP1Rdy),
  .clrEP2Rdy(clrEP2Rdy),
  .clrEP3Rdy(clrEP3Rdy)
    );

slaveSendPacket u_slaveSendPacket
  (.PID(slaveControllerPIDOut), 
  .SCTxPortCntl(sendPacketCntl),
  .SCTxPortData(sendPacketData),
  .SCTxPortGnt(sendPacketGnt),
  .SCTxPortRdy(SCTxPortArbRdyOut),
  .SCTxPortReq(sendPacketReq),
  .SCTxPortWEn(sendPacketWEn),
  .clk(usbClk),
  .fifoData(TxFifoData),
  .fifoEmpty(TxFifoEmpty),
  .fifoReadEn(TxFifoRE),
  .rst(rstSyncToUsbClk),
  .sendPacketRdy(slaveControllerReadyIn),
  .sendPacketWEn(slaveControllerWEnOut) );

slaveDirectControl u_slaveDirectControl
  (.SCTxPortCntl(directCntlCntl),
  .SCTxPortData(directCntlData),
  .SCTxPortGnt(directCntlGnt),
  .SCTxPortRdy(SCTxPortArbRdyOut),
  .SCTxPortReq(directCntlReq),
  .SCTxPortWEn(directCntlWEn),
  .clk(usbClk),
  .directControlEn(directLineCtrlEn),
  .directControlLineState(directLineState),
  .rst(rstSyncToUsbClk) ); 

SCTxPortArbiter u_SCTxPortArbiter
  (.SCTxPortCntl(SCTxPortCtrl),
  .SCTxPortData(SCTxPortData),
  .SCTxPortRdyIn(SCTxPortRdy),
  .SCTxPortRdyOut(SCTxPortArbRdyOut),
  .SCTxPortWEnable(SCTxPortEn),
  .clk(usbClk),
  .directCntlCntl(directCntlCntl),
  .directCntlData(directCntlData),
  .directCntlGnt(directCntlGnt),
  .directCntlReq(directCntlReq),
  .directCntlWEn(directCntlWEn),
  .rst(rstSyncToUsbClk),
  .sendPacketCntl(sendPacketCntl),
  .sendPacketData(sendPacketData),
  .sendPacketGnt(sendPacketGnt),
  .sendPacketReq(sendPacketReq),
  .sendPacketWEn(sendPacketWEn) );    


slaveGetPacket u_slaveGetPacket
  (.ACKRxed(ACKRxed), 
  .CRCError(CRCError), 
  .RXDataIn(RxData),
  .RXDataValid(RxDataValid),
  .RXFifoData(RxFifoData),
  .RXFifoFull(RxFifoFull),
  .RXFifoWEn(RxFifoWE),
  .RXPacketRdy(getPacketRdy),
  .RXStreamStatusIn(RxByteStatus),
  .RxPID(RxPID),
  .SIERxTimeOut(SIERxTimeOut),
  .SIERxTimeOutEn(SIERxTimeOutEn),
  .clk(usbClk),
  .RXOverflow(RXOverflow), 
  .RXTimeOut(RXTimeOut), 
  .bitStuffError(bitStuffError), 
  .dataSequence(dataSequence), 
  .getPacketEn(getPacketREn),
  .rst(rstSyncToUsbClk),
  .endPointReady(endPointReadyFromSlaveCtrlrToGetPkt)
  ); 

slaveRxStatusMonitor  u_slaveRxStatusMonitor
  (.connectStateIn(connectStateIn),
  .connectStateOut(connectStateOut),
  .resumeDetectedIn(resumeDetectedIn),
  .resetEventOut(resetEventFromRxStatusMon),
  .resumeIntOut(resumeIntFromRxStatusMon),
  .clk(usbClk),
  .rst(rstSyncToUsbClk)  );    
  
fifoMux u_fifoMux (
  .currEndP(currEndP),
  //TxFifo
  .TxFifoREn(TxFifoRE),
  .TxFifoEP0REn(TxFifoEP0REn),
  .TxFifoEP1REn(TxFifoEP1REn),
  .TxFifoEP2REn(TxFifoEP2REn),
  .TxFifoEP3REn(TxFifoEP3REn),
  .TxFifoData(TxFifoData),
  .TxFifoEP0Data(TxFifoEP0Data),
  .TxFifoEP1Data(TxFifoEP1Data),
  .TxFifoEP2Data(TxFifoEP2Data),
  .TxFifoEP3Data(TxFifoEP3Data),
  .TxFifoEmpty(TxFifoEmpty),
  .TxFifoEP0Empty(TxFifoEP0Empty),
  .TxFifoEP1Empty(TxFifoEP1Empty),
  .TxFifoEP2Empty(TxFifoEP2Empty),
  .TxFifoEP3Empty(TxFifoEP3Empty),
  //RxFifo
  .RxFifoWEn(RxFifoWE),
  .RxFifoEP0WEn(RxFifoEP0WEn),
  .RxFifoEP1WEn(RxFifoEP1WEn),
  .RxFifoEP2WEn(RxFifoEP2WEn),
  .RxFifoEP3WEn(RxFifoEP3WEn),
  .RxFifoFull(RxFifoFull),
  .RxFifoEP0Full(RxFifoEP0Full),
  .RxFifoEP1Full(RxFifoEP1Full),
  .RxFifoEP2Full(RxFifoEP2Full),
  .RxFifoEP3Full(RxFifoEP3Full)
    );

endmodule

  
  




