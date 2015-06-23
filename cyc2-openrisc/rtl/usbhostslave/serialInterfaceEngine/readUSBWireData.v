//////////////////////////////////////////////////////////////////////
////                                                              ////
//// readUSBWireData.v                                            ////
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
////      This module reads data from the differential USB data lines
////      and writes into a 4 entry FIFO. The data is read from
////      the fifo and output from the module when the higher level
////      state machine is ready to receive the data.
////      This module must recover the clock phase from the incoming
////      USB data. 'sampleCnt' is reset to zero whenever a RX data
////      edge is detected. Note that due to metastability the data
////      at the edge may not be registered correctly, but this does
////      not matter. All that matters is that an edge was detected. The
////      data will be accurately sampled in the middle of the USB bit 
////      period without metastability issues. 
////      After the edge detect, 'sampleCnt' is incremented at every clock
////      tick, and when it indicates the middle of a USB bit period
////      the RX data is sampled and written to the input buffer.
////      Single clock tick adjustments to 'sampleCnt' can be made at 
////      every RX data edge detect without double sampling the incoming
////      data. However, the first RX data bit in a packet may cause 
////      'sampleCnt' to be adjusted by a value greater than a single 
////      clock tick, and this can result in double sampling of the 
////      first data bit a RX packet. This 
////      double sampled data must be rejected by the higher level module.
////      This is achieved by 
////      qualifying the outgoing data with 'RxWireActive'. Thus 
////      the first data bit in a RX packet may be double sampled
////      as the clock recovery mechanism synchronizes to 'RxBitsIn'
////      but the double sampled data will be rejected by the higher 
////      level module.
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
`include "usbSerialInterfaceEngine_h.v"

module readUSBWireData (RxBitsIn, RxDataInTick, RxBitsOut, SIERxRdyIn, SIERxWEn, fullSpeedRate, TxWireActiveDrive, clk, rst, noActivityTimeOut, RxWireActive, noActivityTimeOutEnable);
input   [1:0] RxBitsIn;
output  RxDataInTick;
input   SIERxRdyIn;
input   clk;
input   fullSpeedRate;
input   rst;
input   TxWireActiveDrive;
output  [1:0] RxBitsOut;
output  SIERxWEn;
output noActivityTimeOut;
output RxWireActive;
input  noActivityTimeOutEnable;

wire   [1:0] RxBitsIn;
reg    RxDataInTick;
wire   SIERxRdyIn;
wire   clk;
wire   fullSpeedRate;
wire   rst;
reg    [1:0] RxBitsOut;
reg    SIERxWEn;
reg    noActivityTimeOut;
reg    RxWireActive;
wire   noActivityTimeOutEnable;

// local registers
reg  [2:0]buffer0;
reg  [2:0]buffer1;
reg  [2:0]buffer2;
reg  [2:0]buffer3;
reg  [2:0]bufferCnt;
reg  [1:0]bufferInIndex;
reg  [1:0]bufferOutIndex;
reg decBufferCnt;
reg  [4:0]sampleCnt;
reg incBufferCnt;
reg  [1:0]oldRxBitsIn;
reg [1:0] RxBitsInReg;
reg [15:0] timeOutCnt;
reg [7:0] rxActiveCnt;
reg RxWireEdgeDetect;
reg RxWireActiveReg;
reg RxWireActiveReg2;
reg [1:0] RxBitsInSyncReg1;
reg [1:0] RxBitsInSyncReg2;

// buffer output state machine state codes:
`define WAIT_BUFFER_NOT_EMPTY 2'b00
`define WAIT_SIE_RX_READY 2'b01
`define SIE_RX_WRITE 2'b10

// re-synchronize incoming bits
always @(posedge clk) begin
  RxBitsInSyncReg1 <= RxBitsIn;
  RxBitsInSyncReg2 <= RxBitsInSyncReg1;
end

reg [1:0] bufferOutStMachCurrState;


always @(posedge clk) begin
  if (rst == 1'b1)
  begin
    bufferCnt <= 3'b000;
  end
  else begin
    if (incBufferCnt == 1'b1 && decBufferCnt == 1'b0)
      bufferCnt <= bufferCnt + 1'b1;
    else if (incBufferCnt == 1'b0 && decBufferCnt == 1'b1)
      bufferCnt <= bufferCnt - 1'b1;
  end
end



//Perform line rate clock recovery
//Recover the wire data, and store data to buffer
always @(posedge clk) begin
  if (rst == 1'b1)
  begin
    sampleCnt <= 5'b00000;
    incBufferCnt <= 1'b0;
    bufferInIndex <= 2'b00;
    buffer0 <= 3'b000;
    buffer1 <= 3'b000;
    buffer2 <= 3'b000;
    buffer3 <= 3'b000;
    RxDataInTick <= 1'b0;
    RxWireEdgeDetect <= 1'b0;
    RxWireActiveReg <= 1'b0;
    RxWireActiveReg2 <= 1'b0;
  end
  else begin
    RxWireActiveReg2 <= RxWireActiveReg; //Delay 'RxWireActiveReg' until after 'sampleCnt' has been reset
    RxBitsInReg <= RxBitsInSyncReg2;    
    oldRxBitsIn <= RxBitsInReg;
    incBufferCnt <= 1'b0;         //default value
    if ( (TxWireActiveDrive == 1'b0) && (RxBitsInSyncReg2 != RxBitsInReg)) begin  //if edge detected then
      sampleCnt <= 5'b00000;        
      RxWireEdgeDetect <= 1'b1;   // flag receive activity 
      RxWireActiveReg <= 1'b1;
      rxActiveCnt <= 8'h00;
    end
    else begin
      sampleCnt <= sampleCnt + 1'b1;
      RxWireEdgeDetect <= 1'b0;
      rxActiveCnt <= rxActiveCnt + 1'b1;
      //clear 'RxWireActiveReg' if no RX transitions for RX_EDGE_DET_TOUT USB bit periods 
      if ( (fullSpeedRate == 1'b1 && rxActiveCnt == `RX_EDGE_DET_TOUT * `FS_OVER_SAMPLE_RATE)
        || (fullSpeedRate == 1'b0 && rxActiveCnt == `RX_EDGE_DET_TOUT * `LS_OVER_SAMPLE_RATE) ) 
        RxWireActiveReg <= 1'b0;
    end
    if ( (fullSpeedRate == 1'b1 && sampleCnt[1:0] == 2'b10) || (fullSpeedRate == 1'b0 && sampleCnt == 5'b10000) )
    begin
      RxDataInTick <= !RxDataInTick;
      if (TxWireActiveDrive != 1'b1)  //do not read wire data when transmitter is active
      begin
        incBufferCnt <= 1'b1;
        bufferInIndex <= bufferInIndex + 1'b1;
        case (bufferInIndex)
          2'b00 : buffer0 <= {RxWireActiveReg2, oldRxBitsIn}; 
          2'b01 : buffer1 <= {RxWireActiveReg2, oldRxBitsIn};
          2'b10 : buffer2 <= {RxWireActiveReg2, oldRxBitsIn};
          2'b11 : buffer3 <= {RxWireActiveReg2, oldRxBitsIn};
        endcase
      end
    end
  end
end

        

//read from buffer, and output to SIEReceiver
always @(posedge clk) begin
  if (rst == 1'b1)
  begin
    decBufferCnt <= 1'b0;
    bufferOutIndex <= 2'b00;
    RxBitsOut <= 2'b00;
    SIERxWEn <= 1'b0;
    bufferOutStMachCurrState <= `WAIT_BUFFER_NOT_EMPTY;
  end
  else begin
    case (bufferOutStMachCurrState)
      `WAIT_BUFFER_NOT_EMPTY:
      begin
        if (bufferCnt != 3'b000)
          bufferOutStMachCurrState <= `WAIT_SIE_RX_READY;
      end
      `WAIT_SIE_RX_READY:
      begin
        if (SIERxRdyIn == 1'b1)
        begin 
          SIERxWEn <= 1'b1;
          bufferOutStMachCurrState <= `SIE_RX_WRITE;
          decBufferCnt <= 1'b1;
          bufferOutIndex <= bufferOutIndex + 1'b1;
          case (bufferOutIndex)
            2'b00 : begin RxBitsOut <= buffer0[1:0]; RxWireActive <= buffer0[2]; end
            2'b01 : begin RxBitsOut <= buffer1[1:0]; RxWireActive <= buffer1[2]; end
            2'b10 : begin RxBitsOut <= buffer2[1:0]; RxWireActive <= buffer2[2]; end
            2'b11 : begin RxBitsOut <= buffer3[1:0]; RxWireActive <= buffer3[2]; end
          endcase
        end
      end
      `SIE_RX_WRITE:
      begin
        SIERxWEn <= 1'b0;
        decBufferCnt <= 1'b0;
        bufferOutStMachCurrState <= `WAIT_BUFFER_NOT_EMPTY;
      end
    endcase
  end
end

//generate 'noActivityTimeOut' pulse if no tx or rx activity for RX_PACKET_TOUT USB bit periods
//'noActivityTimeOut'  pulse can only be generated when the host or slave getPacket
//process enables via 'noActivityTimeOutEnable' signal
//'noActivityTimeOut' pulse is used by host and slave getPacket processes to determine if 
//there has been a response time out.
always @(posedge clk) begin
  if (rst) begin
    timeOutCnt <= 16'h0000;
    noActivityTimeOut <= 1'b0;
  end
  else begin
    if (TxWireActiveDrive == 1'b1 || RxWireEdgeDetect == 1'b1 || noActivityTimeOutEnable == 1'b0)
      timeOutCnt <= 16'h0000;
    else
      timeOutCnt <= timeOutCnt + 1'b1;
    if ( (fullSpeedRate == 1'b1 && timeOutCnt == `RX_PACKET_TOUT * `FS_OVER_SAMPLE_RATE)
      || (fullSpeedRate == 1'b0 && timeOutCnt == `RX_PACKET_TOUT * `LS_OVER_SAMPLE_RATE) ) 
      noActivityTimeOut <= 1'b1; 
    else 
      noActivityTimeOut <= 1'b0;
  end
end


endmodule
