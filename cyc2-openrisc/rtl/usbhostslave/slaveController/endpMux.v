//////////////////////////////////////////////////////////////////////
////                                                              ////
//// endpMux.v                                                    ////
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
`include "usbSlaveControl_h.v" 

module endpMux (
  clk, 
  rst,
  currEndP,
  NAKSent,
  stallSent,
  CRCError,
  bitStuffError,
  RxOverflow,
  RxTimeOut,
  dataSequence,
  ACKRxed,
  transType,
  transTypeNAK,
  endPControlReg,
  clrEPRdy,
  endPMuxErrorsWEn,
  endP0ControlReg,
  endP1ControlReg,
  endP2ControlReg,
  endP3ControlReg,
  endP0StatusReg,
  endP1StatusReg,
  endP2StatusReg,
  endP3StatusReg,
  endP0TransTypeReg,
  endP1TransTypeReg,
  endP2TransTypeReg,
  endP3TransTypeReg,
  endP0NAKTransTypeReg,
  endP1NAKTransTypeReg,
  endP2NAKTransTypeReg,
  endP3NAKTransTypeReg,
  clrEP0Rdy,
  clrEP1Rdy,
  clrEP2Rdy,
  clrEP3Rdy);


input clk; 
input rst;
input [3:0] currEndP;
input NAKSent;
input stallSent;
input CRCError;
input bitStuffError;
input RxOverflow;
input RxTimeOut;
input dataSequence;
input ACKRxed;
input [1:0] transType;
input [1:0] transTypeNAK;
output [4:0] endPControlReg;
input clrEPRdy;
input endPMuxErrorsWEn;
input [4:0] endP0ControlReg;
input [4:0] endP1ControlReg;
input [4:0] endP2ControlReg;
input [4:0] endP3ControlReg;
output [7:0] endP0StatusReg;
output [7:0] endP1StatusReg;
output [7:0] endP2StatusReg;
output [7:0] endP3StatusReg;
output [1:0] endP0TransTypeReg;
output [1:0] endP1TransTypeReg;
output [1:0] endP2TransTypeReg;
output [1:0] endP3TransTypeReg;
output [1:0] endP0NAKTransTypeReg;
output [1:0] endP1NAKTransTypeReg;
output [1:0] endP2NAKTransTypeReg;
output [1:0] endP3NAKTransTypeReg;
output clrEP0Rdy;
output clrEP1Rdy;
output clrEP2Rdy;
output clrEP3Rdy;

wire clk; 
wire rst;
wire [3:0] currEndP;
wire NAKSent;
wire stallSent;
wire CRCError;
wire bitStuffError;
wire RxOverflow;
wire RxTimeOut;
wire dataSequence;
wire ACKRxed;
wire [1:0] transType;
wire [1:0] transTypeNAK;
reg [4:0] endPControlReg;
wire clrEPRdy;
wire endPMuxErrorsWEn;
wire [4:0] endP0ControlReg;
wire [4:0] endP1ControlReg;
wire [4:0] endP2ControlReg;
wire [4:0] endP3ControlReg;
reg [7:0] endP0StatusReg;
reg [7:0] endP1StatusReg;
reg [7:0] endP2StatusReg;
reg [7:0] endP3StatusReg;
reg [1:0] endP0TransTypeReg;
reg [1:0] endP1TransTypeReg;
reg [1:0] endP2TransTypeReg;
reg [1:0] endP3TransTypeReg;
reg [1:0] endP0NAKTransTypeReg;
reg [1:0] endP1NAKTransTypeReg;
reg [1:0] endP2NAKTransTypeReg;
reg [1:0] endP3NAKTransTypeReg;
reg clrEP0Rdy;
reg clrEP1Rdy;
reg clrEP2Rdy;
reg clrEP3Rdy;

//internal wires and regs
reg [7:0] endPStatusCombine;

//mux endPControlReg and clrEPRdy
always @(posedge clk)
begin
  case (currEndP[1:0])
    2'b00: begin
      endPControlReg <= endP0ControlReg;
      clrEP0Rdy <= clrEPRdy;
    end
    2'b01: begin
      endPControlReg <= endP1ControlReg;
      clrEP1Rdy <= clrEPRdy;
    end
    2'b10: begin
      endPControlReg <= endP2ControlReg;
      clrEP2Rdy <= clrEPRdy;
    end
    2'b11: begin
      endPControlReg <= endP3ControlReg;
      clrEP3Rdy <= clrEPRdy;
    end
  endcase  
end      

//mux endPNAKTransType, endPTransType, endPStatusReg
//If there was a NAK sent then set the NAKSent bit, and leave the other status reg bits untouched.
//else update the entire status reg
always @(posedge clk)
begin
  if (rst) begin
    endP0NAKTransTypeReg <= 2'b00;
    endP1NAKTransTypeReg <= 2'b00;
    endP2NAKTransTypeReg <= 2'b00;
    endP3NAKTransTypeReg <= 2'b00;
    endP0TransTypeReg <= 2'b00;
    endP1TransTypeReg <= 2'b00;
    endP2TransTypeReg <= 2'b00;
    endP3TransTypeReg <= 2'b00;
    endP0StatusReg <= 4'h0;
    endP1StatusReg <= 4'h0;
    endP2StatusReg <= 4'h0;
    endP3StatusReg <= 4'h0;
  end
  else begin
    if (endPMuxErrorsWEn == 1'b1) begin
      if (NAKSent == 1'b1) begin
        case (currEndP[1:0])
          2'b00: begin
            endP0NAKTransTypeReg <= transTypeNAK;
            endP0StatusReg <= endP0StatusReg | `NAK_SET_MASK; 
          end
          2'b01: begin
            endP1NAKTransTypeReg <= transTypeNAK;
            endP1StatusReg <= endP1StatusReg | `NAK_SET_MASK; 
          end
          2'b10: begin
            endP2NAKTransTypeReg <= transTypeNAK;
            endP2StatusReg <= endP2StatusReg | `NAK_SET_MASK; 
          end
          2'b11: begin
            endP3NAKTransTypeReg <= transTypeNAK;
            endP3StatusReg <= endP3StatusReg | `NAK_SET_MASK; 
          end
        endcase
      end
      else begin
        case (currEndP[1:0])
          2'b00: begin
            endP0TransTypeReg <= transType;
            endP0StatusReg <= endPStatusCombine; 
          end
          2'b01: begin
            endP1TransTypeReg <= transType;
            endP1StatusReg <= endPStatusCombine; 
          end
          2'b10: begin
            endP2TransTypeReg <= transType;
            endP2StatusReg <= endPStatusCombine; 
          end
          2'b11: begin
            endP3TransTypeReg <= transType;
            endP3StatusReg <= endPStatusCombine; 
          end
        endcase
      end
    end
  end
end
        

//combine status bits into a single word
always @(dataSequence or ACKRxed or stallSent or RxTimeOut or RxOverflow or bitStuffError or CRCError)
begin
  endPStatusCombine <= {dataSequence, ACKRxed, stallSent, 1'b0, RxTimeOut, RxOverflow, bitStuffError, CRCError};
end


endmodule
