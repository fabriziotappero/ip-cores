//////////////////////////////////////////////////////////////////////
////                                                              ////
//// wishBoneBI.v                                                 ////
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
`include "wishBoneBus_h.v"

 
module wishBoneBI (
  address, dataIn, dataOut, writeEn, 
  strobe_i,
  ack_o,
  clk, rst,
  hostControlSel, 
  hostRxFifoSel, hostTxFifoSel,
  slaveControlSel,
  slaveEP0RxFifoSel, slaveEP1RxFifoSel, slaveEP2RxFifoSel, slaveEP3RxFifoSel, 
  slaveEP0TxFifoSel, slaveEP1TxFifoSel, slaveEP2TxFifoSel, slaveEP3TxFifoSel, 
  hostSlaveMuxSel,
  dataFromHostControl,
  dataFromHostRxFifo,
  dataFromHostTxFifo,
  dataFromSlaveControl,
  dataFromEP0RxFifo, dataFromEP1RxFifo, dataFromEP2RxFifo, dataFromEP3RxFifo,
  dataFromEP0TxFifo, dataFromEP1TxFifo, dataFromEP2TxFifo, dataFromEP3TxFifo,
  dataFromHostSlaveMux
   );
input clk;
input rst;
input [7:0] address;
input [7:0] dataIn;
output [7:0] dataOut;
input strobe_i;
output ack_o;
input writeEn;
output hostControlSel;
output hostRxFifoSel;
output hostTxFifoSel;
output slaveControlSel;
output slaveEP0RxFifoSel, slaveEP1RxFifoSel, slaveEP2RxFifoSel, slaveEP3RxFifoSel; 
output slaveEP0TxFifoSel, slaveEP1TxFifoSel, slaveEP2TxFifoSel, slaveEP3TxFifoSel; 
output hostSlaveMuxSel;
input [7:0] dataFromHostControl;
input [7:0] dataFromHostRxFifo;
input [7:0] dataFromHostTxFifo;
input [7:0] dataFromSlaveControl;
input [7:0] dataFromEP0RxFifo, dataFromEP1RxFifo, dataFromEP2RxFifo, dataFromEP3RxFifo;
input [7:0] dataFromEP0TxFifo, dataFromEP1TxFifo, dataFromEP2TxFifo, dataFromEP3TxFifo;
input [7:0] dataFromHostSlaveMux;


wire clk;
wire rst;
wire [7:0] address;
wire [7:0] dataIn;
reg [7:0] dataOut;
wire writeEn;
wire strobe_i;
reg ack_o;
reg hostControlSel;
reg hostRxFifoSel;
reg hostTxFifoSel;
reg slaveControlSel;
reg slaveEP0RxFifoSel, slaveEP1RxFifoSel, slaveEP2RxFifoSel, slaveEP3RxFifoSel; 
reg slaveEP0TxFifoSel, slaveEP1TxFifoSel, slaveEP2TxFifoSel, slaveEP3TxFifoSel; 
reg hostSlaveMuxSel;
wire [7:0] dataFromHostControl;
wire [7:0] dataFromHostRxFifo;
wire [7:0] dataFromHostTxFifo;
wire [7:0] dataFromSlaveControl;
wire [7:0] dataFromEP0RxFifo, dataFromEP1RxFifo, dataFromEP2RxFifo, dataFromEP3RxFifo;
wire [7:0] dataFromEP0TxFifo, dataFromEP1TxFifo, dataFromEP2TxFifo, dataFromEP3TxFifo;
wire [7:0] dataFromHostSlaveMux;

//internal wires and regs
reg ack_delayed;
reg ack_immediate;

//address decode and data mux
always @(address or
  dataFromHostControl or
  dataFromHostRxFifo or
  dataFromHostTxFifo or
  dataFromSlaveControl or
  dataFromEP0RxFifo or 
  dataFromEP1RxFifo or
  dataFromEP2RxFifo or
  dataFromEP3RxFifo or
  dataFromHostSlaveMux or 
  dataFromEP0TxFifo or
  dataFromEP1TxFifo or
  dataFromEP2TxFifo or
  dataFromEP3TxFifo)
begin
  hostControlSel <= 1'b0;
  hostRxFifoSel <= 1'b0;
  hostTxFifoSel <= 1'b0;
  slaveControlSel <= 1'b0;
  slaveEP0RxFifoSel <= 1'b0;
  slaveEP0TxFifoSel <= 1'b0;
  slaveEP1RxFifoSel <= 1'b0;
  slaveEP1TxFifoSel <= 1'b0;
  slaveEP2RxFifoSel <= 1'b0;
  slaveEP2TxFifoSel <= 1'b0;
  slaveEP3RxFifoSel <= 1'b0;
  slaveEP3TxFifoSel <= 1'b0;
  hostSlaveMuxSel <= 1'b0;
  case (address & `ADDRESS_DECODE_MASK)
    `HCREG_BASE : begin
      hostControlSel <= 1'b1;
      dataOut <= dataFromHostControl;
    end
    `HCREG_BASE_PLUS_0X10 : begin
      hostControlSel <= 1'b1;
      dataOut <= dataFromHostControl;
    end
    `HOST_RX_FIFO_BASE : begin
      hostRxFifoSel <= 1'b1;
      dataOut <= dataFromHostRxFifo;
    end
    `HOST_TX_FIFO_BASE : begin
      hostTxFifoSel <= 1'b1;
      dataOut <= dataFromHostTxFifo;
    end
    `SCREG_BASE : begin
      slaveControlSel <= 1'b1;
      dataOut <= dataFromSlaveControl;
    end
    `SCREG_BASE_PLUS_0X10 : begin
      slaveControlSel <= 1'b1;
      dataOut <= dataFromSlaveControl;
    end
    `EP0_RX_FIFO_BASE : begin
      slaveEP0RxFifoSel <= 1'b1;
      dataOut <= dataFromEP0RxFifo;
    end
    `EP0_TX_FIFO_BASE : begin
      slaveEP0TxFifoSel <= 1'b1;
      dataOut <= dataFromEP0TxFifo;
    end
    `EP1_RX_FIFO_BASE : begin
      slaveEP1RxFifoSel <= 1'b1;
      dataOut <= dataFromEP1RxFifo;
    end
    `EP1_TX_FIFO_BASE : begin
      slaveEP1TxFifoSel <= 1'b1;
      dataOut <= dataFromEP1TxFifo;
    end
    `EP2_RX_FIFO_BASE : begin
      slaveEP2RxFifoSel <= 1'b1;
      dataOut <= dataFromEP2RxFifo;
    end
    `EP2_TX_FIFO_BASE : begin
      slaveEP2TxFifoSel <= 1'b1;
      dataOut <= dataFromEP2TxFifo;
    end
    `EP3_RX_FIFO_BASE : begin
      slaveEP3RxFifoSel <= 1'b1;
      dataOut <= dataFromEP3RxFifo;
    end
    `EP3_TX_FIFO_BASE : begin
      slaveEP3TxFifoSel <= 1'b1;
      dataOut <= dataFromEP3TxFifo;
    end
    `HOST_SLAVE_CONTROL_BASE : begin
      hostSlaveMuxSel <= 1'b1; 
      dataOut <= dataFromHostSlaveMux;
    end
    default: 
      dataOut <= 8'h00;
  endcase
end

//delayed ack
always @(posedge clk) begin
  ack_delayed <= strobe_i;
end

//immediate ack
always @(strobe_i) begin
  ack_immediate <= strobe_i;
end 

//select between immediate and delayed ack
always @(writeEn or address or ack_delayed or ack_immediate) begin
  if (writeEn == 1'b0 &&
      (address == `HOST_RX_FIFO_BASE + `FIFO_DATA_REG ||
       address == `HOST_TX_FIFO_BASE + `FIFO_DATA_REG ||
       address == `EP0_RX_FIFO_BASE + `FIFO_DATA_REG ||
       address == `EP0_TX_FIFO_BASE + `FIFO_DATA_REG ||
       address == `EP1_RX_FIFO_BASE + `FIFO_DATA_REG ||
       address == `EP1_TX_FIFO_BASE + `FIFO_DATA_REG ||
       address == `EP2_RX_FIFO_BASE + `FIFO_DATA_REG ||
       address == `EP2_TX_FIFO_BASE + `FIFO_DATA_REG ||
       address == `EP3_RX_FIFO_BASE + `FIFO_DATA_REG ||
       address == `EP3_TX_FIFO_BASE + `FIFO_DATA_REG) )
  begin
    ack_o <= ack_delayed & ack_immediate;
  end
  else
  begin
    ack_o <= ack_immediate;
  end
end

endmodule
