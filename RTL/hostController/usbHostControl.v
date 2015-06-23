//////////////////////////////////////////////////////////////////////
////                                                              ////
//// usbHostControl.v                                             ////
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

module usbHostControl(
  busClk, rstSyncToBusClk,
  usbClk, rstSyncToUsbClk,
  //sendPacket
  TxFifoRE, TxFifoData, TxFifoEmpty,
  //getPacket
  RxFifoWE, RxFifoData, RxFifoFull,
  RxByteStatus, RxData, RxDataValid,
  SIERxTimeOut, SIERxTimeOutEn,
  //speedCtrlMux
  fullSpeedRate, fullSpeedPol,
  //HCTxPortArbiter
  HCTxPortEn, HCTxPortRdy,
  HCTxPortData, HCTxPortCtrl,
  //rxStatusMonitor
  connectStateIn, 
  resumeDetectedIn,
  //USBHostControlBI 
  busAddress,
  busDataIn, 
  busDataOut, 
  busWriteEn,
  busStrobe_i,
  SOFSentIntOut, 
  connEventIntOut, 
  resumeIntOut, 
  transDoneIntOut,
  hostControlSelect
    );

input busClk;
input rstSyncToBusClk;
input usbClk;
input rstSyncToUsbClk;
//sendPacket
output TxFifoRE;
input [7:0] TxFifoData;
input TxFifoEmpty;
//getPacket
output RxFifoWE;
output [7:0] RxFifoData;
input RxFifoFull;
input [7:0] RxByteStatus;
input [7:0] RxData;
input RxDataValid;
input SIERxTimeOut;
output SIERxTimeOutEn;
//speedCtrlMux
output fullSpeedRate;
output fullSpeedPol;
//HCTxPortArbiter
output HCTxPortEn;
input HCTxPortRdy;
output [7:0] HCTxPortData;
output [7:0] HCTxPortCtrl;
//rxStatusMonitor
input [1:0] connectStateIn;
input resumeDetectedIn;
//USBHostControlBI 
input [3:0] busAddress;
input [7:0] busDataIn; 
output [7:0] busDataOut; 
input busWriteEn;
input busStrobe_i;
output SOFSentIntOut; 
output connEventIntOut; 
output resumeIntOut; 
output transDoneIntOut;
input hostControlSelect;

wire busClk;
wire rstSyncToBusClk;
wire usbClk;
wire rstSyncToUsbClk;
wire [10:0] frameNum;
wire SOFSent;
wire TxFifoRE;
wire [7:0] TxFifoData;
wire TxFifoEmpty;
wire RxFifoWE;
wire [7:0] RxFifoData;
wire RxFifoFull;
wire [7:0] RxByteStatus;
wire [7:0] RxData;
wire RxDataValid;
wire SIERxTimeOut;
wire SIERxTimeOutEn;
wire fullSpeedRate;
wire fullSpeedPol;
wire HCTxPortEn;
wire HCTxPortRdy;
wire [7:0] HCTxPortData;
wire [7:0] HCTxPortCtrl;
wire [1:0] connectStateIn;
wire resumeDetectedIn;
wire [3:0] busAddress;
wire [7:0] busDataIn; 
wire [7:0] busDataOut; 
wire busWriteEn;
wire busStrobe_i;
wire SOFSentIntOut; 
wire connEventIntOut; 
wire resumeIntOut; 
wire transDoneIntOut;
wire hostControlSelect;

//internal wiring
wire SOFTimerClr;
wire getPacketREn;
wire getPacketRdy;
wire HCTxGnt;
wire HCTxReq;
wire [3:0] HC_PID;
wire HC_SP_WEn;
wire SOFTxGnt;
wire SOFTxReq;
wire SOF_SP_WEn;
wire SOFEnable;
wire SOFSyncEn;
wire sendPacketCPReadyIn;
wire sendPacketCPReadyOut;
wire [3:0] sendPacketCPPIDIn;
wire [3:0] sendPacketCPPIDOut;
wire sendPacketCPWEnIn;
wire sendPacketCPWEnOut;
wire [7:0] SOFCntlCntl;
wire [7:0] SOFCntlData;
wire SOFCntlGnt;
wire SOFCntlReq;
wire SOFCntlWEn;
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
wire [15:0] SOFTimer;
wire clrTxReq;
wire transDone;
wire transReq;
wire isoEn;
wire [1:0] transType;
wire preAmbleEnable;
wire [1:0] directLineState;
wire directLineCtrlEn;
wire [6:0] TxAddr;
wire [3:0] TxEndP;
wire [7:0] RxPktStatus;
wire [3:0] RxPID;
wire [1:0] connectStateOut;
wire resumeIntFromRxStatusMon;
wire connectionEventFromRxStatusMon;

USBHostControlBI u_USBHostControlBI 
  (.address(busAddress),
  .dataIn(busDataIn), 
  .dataOut(busDataOut), 
  .writeEn(busWriteEn),
  .strobe_i(busStrobe_i),
  .busClk(busClk), 
  .rstSyncToBusClk(rstSyncToBusClk),
  .usbClk(usbClk), 
  .rstSyncToUsbClk(rstSyncToUsbClk),
  .SOFSentIntOut(SOFSentIntOut), 
  .connEventIntOut(connEventIntOut), 
  .resumeIntOut(resumeIntOut), 
  .transDoneIntOut(transDoneIntOut),
  .TxTransTypeReg(transType), 
  .TxSOFEnableReg(SOFEnable),
  .TxAddrReg(TxAddr), 
  .TxEndPReg(TxEndP), 
  .frameNumIn(frameNum), 
  .RxPktStatusIn(RxPktStatus), 
  .RxPIDIn(RxPID),
  .connectStateIn(connectStateOut),
  .SOFSentIn(SOFSent), 
  .connEventIn(connectionEventFromRxStatusMon), 
  .resumeIntIn(resumeIntFromRxStatusMon), 
  .transDoneIn(transDone),
  .hostControlSelect(hostControlSelect),
  .clrTransReq(clrTxReq),
  .preambleEn(preAmbleEnable),
  .SOFSync(SOFSyncEn),
  .TxLineState(directLineState),
  .LineDirectControlEn(directLineCtrlEn),
  .fullSpeedPol(fullSpeedPol), 
  .fullSpeedRate(fullSpeedRate),
  .transReq(transReq),
  .isoEn(isoEn),
  .SOFTimer(SOFTimer)
  );


hostcontroller u_hostController
  (.RXStatus(RxPktStatus), 
  .clearTXReq(clrTxReq),
  .clk(usbClk),
  .getPacketREn(getPacketREn),
  .getPacketRdy(getPacketRdy),
  .rst(rstSyncToUsbClk),
  .sendPacketArbiterGnt(HCTxGnt),
  .sendPacketArbiterReq(HCTxReq),
  .sendPacketPID(HC_PID),
  .sendPacketRdy(sendPacketCPReadyOut),
  .sendPacketWEn(HC_SP_WEn),
  .transDone(transDone),
  .transReq(transReq),
  .transType(transType),
  .isoEn(isoEn) );

SOFController u_SOFController
  (.HCTxPortCntl(SOFCntlCntl),
  .HCTxPortData(SOFCntlData),
  .HCTxPortGnt(SOFCntlGnt),
  .HCTxPortRdy(HCTxPortRdy),
  .HCTxPortReq(SOFCntlReq),
  .HCTxPortWEn(SOFCntlWEn),
  .SOFEnable(SOFEnable),
  .SOFTimerClr(SOFTimerClr),
  .SOFTimer(SOFTimer),
  .clk(usbClk),
  .rst(rstSyncToUsbClk) ); 

SOFTransmit u_SOFTransmit
  (.SOFEnable(SOFEnable),
  .SOFSent(SOFSent),
  .SOFSyncEn(SOFSyncEn),
  .SOFTimerClr(SOFTimerClr),
  .SOFTimer(SOFTimer),
  .clk(usbClk),
  .rst(rstSyncToUsbClk),
  .sendPacketArbiterGnt(SOFTxGnt),
  .sendPacketArbiterReq(SOFTxReq),
  .sendPacketRdy(sendPacketCPReadyOut),
  .sendPacketWEn(SOF_SP_WEn),
  .fullSpeedRate(fullSpeedRate) );  


sendPacketArbiter u_sendPacketArbiter
  (.HCTxGnt(HCTxGnt),
  .HCTxReq(HCTxReq),
  .HC_PID(HC_PID),
  .HC_SP_WEn(HC_SP_WEn),
  .SOFTxGnt(SOFTxGnt),
  .SOFTxReq(SOFTxReq),
  .SOF_SP_WEn(SOF_SP_WEn),
  .clk(usbClk),
  .rst(rstSyncToUsbClk),
  .sendPacketPID(sendPacketCPPIDIn),
  .sendPacketWEnable(sendPacketCPWEnIn) );    

sendPacketCheckPreamble u_sendPacketCheckPreamble
  (.sendPacketCPPID(sendPacketCPPIDIn),
  .clk(usbClk),
  .preAmbleEnable(preAmbleEnable),
  .rst(rstSyncToUsbClk),
  .sendPacketCPReady(sendPacketCPReadyOut),
  .sendPacketCPWEn(sendPacketCPWEnIn),
  .sendPacketPID(sendPacketCPPIDOut),
  .sendPacketRdy(sendPacketCPReadyIn),
  .sendPacketWEn(sendPacketCPWEnOut) );

sendPacket u_sendPacket
  (.HCTxPortCntl(sendPacketCntl),
  .HCTxPortData(sendPacketData),
  .HCTxPortGnt(sendPacketGnt),
  .HCTxPortRdy(HCTxPortRdy),
  .HCTxPortReq(sendPacketReq),
  .HCTxPortWEn(sendPacketWEn),
  .PID(sendPacketCPPIDOut),
  .TxAddr(TxAddr),
  .TxEndP(TxEndP),
  .clk(usbClk),
  .fifoData(TxFifoData),
  .fifoEmpty(TxFifoEmpty),
  .fifoReadEn(TxFifoRE),
  .frameNum(frameNum),
  .rst(rstSyncToUsbClk),
  .sendPacketRdy(sendPacketCPReadyIn),
  .sendPacketWEn(sendPacketCPWEnOut),
  .fullSpeedPolarity(fullSpeedPol) );
  
directControl u_directControl
  (.HCTxPortCntl(directCntlCntl),
  .HCTxPortData(directCntlData),
  .HCTxPortGnt(directCntlGnt),
  .HCTxPortRdy(HCTxPortRdy),
  .HCTxPortReq(directCntlReq),
  .HCTxPortWEn(directCntlWEn),
  .clk(usbClk),
  .directControlEn(directLineCtrlEn),
  .directControlLineState(directLineState),
  .rst(rstSyncToUsbClk) ); 

HCTxPortArbiter u_HCTxPortArbiter
  (.HCTxPortCntl(HCTxPortCtrl),
  .HCTxPortData(HCTxPortData),
  .HCTxPortWEnable(HCTxPortEn),
  .SOFCntlCntl(SOFCntlCntl),
  .SOFCntlData(SOFCntlData),
  .SOFCntlGnt(SOFCntlGnt),
  .SOFCntlReq(SOFCntlReq),
  .SOFCntlWEn(SOFCntlWEn),
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

getPacket u_getPacket
  (.RXDataIn(RxData),
  .RXDataValid(RxDataValid),
  .RXFifoData(RxFifoData),
  .RXFifoFull(RxFifoFull),
  .RXFifoWEn(RxFifoWE),
  .RXPacketRdy(getPacketRdy),
  .RXPktStatus(RxPktStatus),
  .RXStreamStatusIn(RxByteStatus),
  .RxPID(RxPID),
  .SIERxTimeOut(SIERxTimeOut),
  .SIERxTimeOutEn(SIERxTimeOutEn),
  .clk(usbClk),
  .getPacketEn(getPacketREn),
  .rst(rstSyncToUsbClk) ); 

rxStatusMonitor  u_rxStatusMonitor
  (.connectStateIn(connectStateIn),
  .connectStateOut(connectStateOut),
  .resumeDetectedIn(resumeDetectedIn),
  .connectionEventOut(connectionEventFromRxStatusMon),
  .resumeIntOut(resumeIntFromRxStatusMon),
  .clk(usbClk),
  .rst(rstSyncToUsbClk)  );

endmodule

  
  




