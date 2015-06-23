//////////////////////////////////////////////////////////////////////
////                                                              ////
//// USBHostControlBI.v                                           ////
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
`include "usbHostControl_h.v"
 
module USBHostControlBI (address, dataIn, dataOut, writeEn,
  strobe_i,
  busClk, 
  rstSyncToBusClk,
  usbClk, 
  rstSyncToUsbClk,
  SOFSentIntOut, connEventIntOut, resumeIntOut, transDoneIntOut,
  TxTransTypeReg, TxSOFEnableReg,
  TxAddrReg, TxEndPReg, frameNumIn, 
  RxPktStatusIn, RxPIDIn,
  connectStateIn,
  SOFSentIn, connEventIn, resumeIntIn, transDoneIn,
  hostControlSelect,
  clrTransReq,
  preambleEn,
  SOFSync,
  TxLineState,
  LineDirectControlEn,
  fullSpeedPol, 
  fullSpeedRate,
  transReq,
  isoEn,
  SOFTimer
  );
input [3:0] address;
input [7:0] dataIn;
input writeEn; 
input strobe_i;
input busClk; 
input rstSyncToBusClk;
input usbClk; 
input rstSyncToUsbClk;
output [7:0] dataOut;
output SOFSentIntOut;
output connEventIntOut;
output resumeIntOut;
output transDoneIntOut;

output [1:0] TxTransTypeReg;
output TxSOFEnableReg;
output [6:0] TxAddrReg;
output [3:0] TxEndPReg;
input [10:0] frameNumIn;
input [7:0] RxPktStatusIn;
input [3:0] RxPIDIn;
input [1:0] connectStateIn;
input SOFSentIn;
input connEventIn;
input resumeIntIn;
input transDoneIn;
input hostControlSelect;
input clrTransReq;
output preambleEn;
output SOFSync;
output [1:0] TxLineState;
output LineDirectControlEn;
output fullSpeedPol; 
output fullSpeedRate;
output transReq;
output isoEn;     //enable isochronous mode
input [15:0] SOFTimer;

wire [3:0] address;
wire [7:0] dataIn;
wire writeEn;
wire strobe_i;
wire busClk; 
wire rstSyncToBusClk;
wire usbClk; 
wire rstSyncToUsbClk;
reg [7:0] dataOut;

reg SOFSentIntOut;
reg connEventIntOut;
reg resumeIntOut;
reg transDoneIntOut;

reg [1:0] TxTransTypeReg;
reg [1:0] TxTransTypeReg_reg1;
reg TxSOFEnableReg;
reg TxSOFEnableReg_reg1;
reg [6:0] TxAddrReg;
reg [6:0] TxAddrReg_reg1;
reg [3:0] TxEndPReg;
reg [3:0] TxEndPReg_reg1;
wire [10:0] frameNumIn;
wire [7:0] RxPktStatusIn;
wire [3:0] RxPIDIn;
wire [1:0] connectStateIn;

wire SOFSentIn;
wire connEventIn;
wire resumeIntIn;
wire transDoneIn;
wire hostControlSelect;
wire clrTransReq;
reg preambleEn;
reg preambleEn_reg1;
reg SOFSync;
reg SOFSync_reg1;
reg [1:0] TxLineState;
reg [1:0] TxLineState_reg1;
reg LineDirectControlEn;
reg LineDirectControlEn_reg1;
reg fullSpeedPol; 
reg fullSpeedPol_reg1; 
reg fullSpeedRate;
reg fullSpeedRate_reg1;
reg transReq;
reg transReq_reg1;
reg isoEn;
reg isoEn_reg1;
wire [15:0] SOFTimer;

//internal wire and regs
reg [1:0] TxControlReg;
reg [4:0] TxLineControlReg;
reg clrSOFReq;
reg clrConnEvtReq;
reg clrResInReq;
reg clrTransDoneReq;
reg SOFSentInt;
reg connEventInt;
reg resumeInt;
reg transDoneInt;
reg [3:0] interruptMaskReg;
reg setTransReq;
reg [2:0] resumeIntInExtend;
reg [2:0] transDoneInExtend;
reg [2:0] connEventInExtend;
reg [2:0] SOFSentInExtend;
reg [2:0] clrTransReqExtend;

//clock domain crossing sync registers
//STB = Sync To Busclk
reg [1:0] TxTransTypeRegSTB;
reg TxSOFEnableRegSTB;
reg [6:0] TxAddrRegSTB;
reg [3:0] TxEndPRegSTB;
reg preambleEnSTB;
reg SOFSyncSTB;
reg [1:0] TxLineStateSTB;
reg LineDirectControlEnSTB;
reg fullSpeedPolSTB; 
reg fullSpeedRateSTB;
reg transReqSTB;
reg isoEnSTB;   
reg [10:0] frameNumInSTB;
reg [10:0] frameNumInSTB_reg1;
reg [7:0] RxPktStatusInSTB;
reg [7:0] RxPktStatusInSTB_reg1;
reg [3:0] RxPIDInSTB;
reg [3:0] RxPIDInSTB_reg1;
reg [1:0] connectStateInSTB;
reg [1:0] connectStateInSTB_reg1;
reg [2:0] SOFSentInSTB;
reg [2:0] connEventInSTB;
reg [2:0] resumeIntInSTB;
reg [2:0] transDoneInSTB;
reg [2:0] clrTransReqSTB;
reg [15:0] SOFTimerSTB;
reg [15:0] SOFTimerSTB_reg1;

  
//sync write demux
always @(posedge busClk)
begin
  if (rstSyncToBusClk == 1'b1) begin
    isoEnSTB <= 1'b0;
    preambleEnSTB <= 1'b0;
    SOFSyncSTB <= 1'b0;
    TxTransTypeRegSTB <= 2'b00;
    TxLineControlReg <= 5'h00;
    TxSOFEnableRegSTB <= 1'b0;
    TxAddrRegSTB <= 7'h00;
    TxEndPRegSTB <= 4'h0;
    interruptMaskReg <= 4'h0;
  end
  else begin
    clrSOFReq <= 1'b0;
    clrConnEvtReq <= 1'b0;
    clrResInReq <= 1'b0;
    clrTransDoneReq <= 1'b0;
    setTransReq <= 1'b0;
    if (writeEn == 1'b1 && strobe_i == 1'b1 && hostControlSelect == 1'b1)
    begin
      case (address)
        `TX_CONTROL_REG : begin
          isoEnSTB <= dataIn[`ISO_ENABLE_BIT];
          preambleEnSTB <= dataIn[`PREAMBLE_ENABLE_BIT];
          SOFSyncSTB <= dataIn[`SOF_SYNC_BIT];
          setTransReq <= dataIn[`TRANS_REQ_BIT];
        end
        `TX_TRANS_TYPE_REG : TxTransTypeRegSTB <= dataIn[1:0];
        `TX_LINE_CONTROL_REG : TxLineControlReg <= dataIn[4:0];
        `TX_SOF_ENABLE_REG : TxSOFEnableRegSTB <= dataIn[`SOF_EN_BIT];
        `TX_ADDR_REG : TxAddrRegSTB <= dataIn[6:0];
        `TX_ENDP_REG : TxEndPRegSTB <= dataIn[3:0];
        `INTERRUPT_STATUS_REG :  begin
          clrSOFReq <= dataIn[`SOF_SENT_BIT];
          clrConnEvtReq <= dataIn[`CONNECTION_EVENT_BIT];
          clrResInReq <= dataIn[`RESUME_INT_BIT];
          clrTransDoneReq <= dataIn[`TRANS_DONE_BIT];
        end
        `INTERRUPT_MASK_REG  : interruptMaskReg <= dataIn[3:0];
      endcase
    end 
  end
end

//interrupt control
always @(posedge busClk)
begin
  if (rstSyncToBusClk == 1'b1) begin
    SOFSentInt <= 1'b0;
    connEventInt <= 1'b0;
    resumeInt <= 1'b0;
    transDoneInt <= 1'b0;
  end
  else begin
    if (SOFSentInSTB[1] == 1'b1 && SOFSentInSTB[0] == 1'b0)
      SOFSentInt <= 1'b1;
    else if (clrSOFReq == 1'b1)
      SOFSentInt <= 1'b0;
    
    if (connEventInSTB[1] == 1'b1 && connEventInSTB[0] == 1'b0)
      connEventInt <= 1'b1;
    else if (clrConnEvtReq == 1'b1)
      connEventInt <= 1'b0;
    
    if (resumeIntInSTB[1] == 1'b1 && resumeIntInSTB[0] == 1'b0)
      resumeInt <= 1'b1;
    else if (clrResInReq == 1'b1)
      resumeInt <= 1'b0;  

    if (transDoneInSTB[1] == 1'b1 && transDoneInSTB[0] == 1'b0)
      transDoneInt <= 1'b1;
    else if (clrTransDoneReq == 1'b1)
      transDoneInt <= 1'b0;
  end
end

//mask interrupts
always @(*) begin
  transDoneIntOut <= transDoneInt & interruptMaskReg[`TRANS_DONE_BIT];
  resumeIntOut <= resumeInt & interruptMaskReg[`RESUME_INT_BIT];
  connEventIntOut <= connEventInt & interruptMaskReg[`CONNECTION_EVENT_BIT];
  SOFSentIntOut <= SOFSentInt & interruptMaskReg[`SOF_SENT_BIT];
end  
  
//transaction request set/clear
//Since 'busClk' can be a higher freq than 'usbClk',
//'setTransReq' must be delayed with respect to other control signals, thus
//ensuring that control signals have been clocked through to 'usbClk' clock
//domain before the transaction request is asserted.
//Not sure this is required because there is at least two 'usbClk' ticks between
//detection of 'transReq' and sampling of related control signals.
always @(posedge busClk)
begin
  if (rstSyncToBusClk == 1'b1) begin
    transReqSTB <= 1'b0;
  end
  else begin
    if (setTransReq == 1'b1)
      transReqSTB <= 1'b1;
    else if (clrTransReqSTB[1] == 1'b1 && clrTransReqSTB[0] == 1'b0)
      transReqSTB <= 1'b0;
  end
end  
  
//break out control signals
always @(*) begin
  TxLineStateSTB <= TxLineControlReg[`TX_LINE_STATE_MSBIT:`TX_LINE_STATE_LSBIT];
  LineDirectControlEnSTB <= TxLineControlReg[`DIRECT_CONTROL_BIT];
  fullSpeedPolSTB <= TxLineControlReg[`FULL_SPEED_LINE_POLARITY_BIT]; 
  fullSpeedRateSTB <= TxLineControlReg[`FULL_SPEED_LINE_RATE_BIT];
end
  
// async read mux
always @(*)
begin
  case (address)
      `TX_CONTROL_REG : dataOut <= {4'b0000, isoEnSTB, preambleEnSTB, SOFSyncSTB, transReqSTB} ;
      `TX_TRANS_TYPE_REG : dataOut <= {6'b000000, TxTransTypeRegSTB};
      `TX_LINE_CONTROL_REG : dataOut <= {3'b000, TxLineControlReg};
      `TX_SOF_ENABLE_REG : dataOut <= {7'b0000000, TxSOFEnableRegSTB};
      `TX_ADDR_REG : dataOut <= {1'b0, TxAddrRegSTB};
      `TX_ENDP_REG : dataOut <= {4'h0, TxEndPRegSTB};
      `FRAME_NUM_MSB_REG : dataOut <= {5'b00000, frameNumInSTB[10:8]};
      `FRAME_NUM_LSB_REG : dataOut <= frameNumInSTB[7:0];
      `INTERRUPT_STATUS_REG :  dataOut <= {4'h0, SOFSentInt, connEventInt, resumeInt, transDoneInt};
      `INTERRUPT_MASK_REG  : dataOut <= {4'h0, interruptMaskReg};
      `RX_STATUS_REG  : dataOut <= RxPktStatusInSTB;
      `RX_PID_REG  : dataOut <= {4'b0000, RxPIDInSTB};
      `RX_CONNECT_STATE_REG : dataOut <= {6'b000000, connectStateInSTB};
      `HOST_SOF_TIMER_MSB_REG : dataOut <= SOFTimerSTB[15:8];
      default: dataOut <= 8'h00;
  endcase
end

//re-sync from busClk to usbClk. 
always @(posedge usbClk) begin
  if (rstSyncToUsbClk == 1'b1) begin
    isoEn <= 1'b0;
    isoEn_reg1 <= 1'b0;
    preambleEn <= 1'b0;
    preambleEn_reg1 <= 1'b0;
    SOFSync <= 1'b0;
    SOFSync_reg1 <= 1'b0;
    TxTransTypeReg <= 2'b00;
    TxTransTypeReg_reg1 <= 2'b00;
    TxSOFEnableReg <= 1'b0;
    TxSOFEnableReg_reg1 <= 1'b0;
    TxAddrReg <= {7{1'b0}};
    TxAddrReg_reg1 <= {7{1'b0}};
    TxEndPReg <= 4'h0;
    TxEndPReg_reg1 <= 4'h0;
    TxLineState <= 2'b00;
    TxLineState_reg1 <= 2'b00;
    LineDirectControlEn <= 1'b0;
    LineDirectControlEn_reg1 <= 1'b0;
    fullSpeedPol <= 1'b0; 
    fullSpeedPol_reg1 <= 1'b0; 
    fullSpeedRate <= 1'b0;
    fullSpeedRate_reg1 <= 1'b0;
    transReq <= 1'b0;
    transReq_reg1 <= 1'b0;
  end
  else begin
    isoEn_reg1 <= isoEnSTB;     
    isoEn <= isoEn_reg1;     
    preambleEn_reg1 <= preambleEnSTB;
    preambleEn <= preambleEn_reg1;
    SOFSync_reg1 <= SOFSyncSTB;
    SOFSync <= SOFSync_reg1;
    TxTransTypeReg_reg1 <= TxTransTypeRegSTB;
    TxTransTypeReg <= TxTransTypeReg_reg1;
    TxSOFEnableReg_reg1 <= TxSOFEnableRegSTB;
    TxSOFEnableReg <= TxSOFEnableReg_reg1;
    TxAddrReg_reg1 <= TxAddrRegSTB;
    TxAddrReg <= TxAddrReg_reg1;
    TxEndPReg_reg1 <= TxEndPRegSTB;
    TxEndPReg <= TxEndPReg_reg1;
    TxLineState_reg1 <= TxLineStateSTB;
    TxLineState <= TxLineState_reg1;
    LineDirectControlEn_reg1 <= LineDirectControlEnSTB;
    LineDirectControlEn <= LineDirectControlEn_reg1;
    fullSpeedPol_reg1 <= fullSpeedPolSTB; 
    fullSpeedPol <= fullSpeedPol_reg1; 
    fullSpeedRate_reg1 <= fullSpeedRateSTB;
    fullSpeedRate <= fullSpeedRate_reg1;
    transReq_reg1 <= transReqSTB;
    transReq <= transReq_reg1;
  end
end

//Extend  resumeIntIn etc from 1 tick to 3 ticks
always @(posedge usbClk) begin
  if (rstSyncToUsbClk == 1'b1) begin
    resumeIntInExtend <= 3'b000;
    transDoneInExtend <= 3'b000;
    connEventInExtend <= 3'b000;
    SOFSentInExtend <= 3'b000;
    clrTransReqExtend <= 3'b000;
  end
  else begin
    if (resumeIntIn == 1'b1)
      resumeIntInExtend <= 3'b111;
    else
      resumeIntInExtend <= {1'b0, resumeIntInExtend[2:1]};
    if (transDoneIn == 1'b1)
      transDoneInExtend <= 3'b111;
    else
      transDoneInExtend <= {1'b0, transDoneInExtend[2:1]};
    if (connEventIn == 1'b1)
      connEventInExtend <= 3'b111;
    else
      connEventInExtend <= {1'b0, connEventInExtend[2:1]};
    if (SOFSentIn == 1'b1)
      SOFSentInExtend <= 3'b111;
    else
      SOFSentInExtend <= {1'b0, SOFSentInExtend[2:1]};
    if (clrTransReq == 1'b1)
      clrTransReqExtend <= 3'b111;
    else
      clrTransReqExtend <= {1'b0, clrTransReqExtend[2:1]};
  end
end

//re-sync from usbClk to busClk. Since 'clrTransReq', 'transDoneIn' etc are only asserted 
//for 3 'usbClk' ticks, busClk freq must be greater than or equal to usbClk/3 freq
always @(posedge busClk) begin
  if (rstSyncToBusClk == 1'b1) begin
    SOFSentInSTB <= 3'b000;
    connEventInSTB <= 3'b000;
    resumeIntInSTB <= 3'b000;
    transDoneInSTB <= 3'b000;
    clrTransReqSTB <= 3'b000;
    frameNumInSTB <= {11{1'b0}};
    frameNumInSTB_reg1 <= {11{1'b0}};
    RxPktStatusInSTB <= 8'h00;
    RxPktStatusInSTB_reg1 <= 8'h00;
    RxPIDInSTB <= 4'h0;
    RxPIDInSTB_reg1 <= 4'h0;
    connectStateInSTB <= 2'b00;
    connectStateInSTB_reg1 <= 2'b00;
    SOFTimerSTB <= 16'h0000;
    SOFTimerSTB_reg1 <= 16'h0000;
  end
  else begin
    frameNumInSTB_reg1 <= frameNumIn;
    frameNumInSTB <= frameNumInSTB_reg1;
    RxPktStatusInSTB_reg1 <= RxPktStatusIn;
    RxPktStatusInSTB <= RxPktStatusInSTB_reg1;
    RxPIDInSTB_reg1 <= RxPIDIn;
    RxPIDInSTB <= RxPIDInSTB_reg1;
    connectStateInSTB_reg1 <= connectStateIn;
    connectStateInSTB <= connectStateInSTB_reg1;
    SOFSentInSTB <= {SOFSentInExtend[0], SOFSentInSTB[2:1]};
    connEventInSTB <= {connEventInExtend[0], connEventInSTB[2:1]};
    resumeIntInSTB <= {resumeIntInExtend[0], resumeIntInSTB[2:1]};
    transDoneInSTB <= {transDoneInExtend[0], transDoneInSTB[2:1]};
    clrTransReqSTB <= {clrTransReqExtend[0], clrTransReqSTB[2:1]};
    //FIXME. It is not safe to pass 'SOFTimer' multi-bit signal between clock domains this way
    //All the other multi-bit signals will be static at the time that they are
    //read, but 'SOFTimer' will not be static.
    SOFTimerSTB_reg1 <= SOFTimer; 
    SOFTimerSTB <= SOFTimerSTB_reg1; 
  end
end


endmodule
