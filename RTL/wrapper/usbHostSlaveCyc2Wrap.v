//////////////////////////////////////////////////////////////////////
////                                                              ////
//// usbHostSlaveCyc2Wrap.v                                     ////
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
////   Top level module wrapper. 
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


module usbHostSlaveCyc2Wrap(
  clk_i, 
  rst_i,
  address_i, 
  data_i, 
  data_o, 
  we_i, 
  strobe_i,
  ack_o,
  irq, 
  usbClk,
  USBWireVP,
  USBWireVM,
  USBWireOE_n,
  USBFullSpeed
   );

input clk_i;
input rst_i;
input [7:0] address_i; 
input [7:0] data_i; 
output [7:0] data_o; 
input we_i; 
input strobe_i;
output ack_o;
output irq; 
input usbClk;
inout USBWireVP /* synthesis useioff=1 */;
inout USBWireVM /* synthesis useioff=1 */;
output USBWireOE_n /* synthesis useioff=1 */;
output USBFullSpeed /* synthesis useioff=1 */;

wire clk_i;
wire rst_i;
wire [7:0] address_i; 
wire [7:0] data_i; 
wire [7:0] data_o; 
wire irq;
wire usbClk;
wire USBWireDataOutTick;
wire USBWireDataInTick;
wire USBFullSpeed;

//internal wiring 
wire hostSOFSentIntOut; 
wire hostConnEventIntOut; 
wire hostResumeIntOut; 
wire hostTransDoneIntOut;
wire slaveSOFRxedIntOut; 
wire slaveResetEventIntOut; 
wire slaveResumeIntOut; 
wire slaveTransDoneIntOut;
wire slaveNAKSentIntOut;
wire USBWireCtrlOut;
wire [1:0] USBWireDataIn;
wire [1:0] USBWireDataOut;


assign irq = hostSOFSentIntOut | hostConnEventIntOut |
             hostResumeIntOut | hostTransDoneIntOut |
             slaveSOFRxedIntOut | slaveResetEventIntOut |
             slaveResumeIntOut | slaveTransDoneIntOut |
             slaveNAKSentIntOut;

assign USBWireDataIn = {USBWireVP, USBWireVM};
assign {USBWireVP, USBWireVM} = (USBWireCtrlOut == 1'b1) ? USBWireDataOut : 2'bzz;
assign USBWireOE_n = ~USBWireCtrlOut;

//Parameters declaration: 
defparam usbHostSlaveInst.HOST_FIFO_DEPTH = 64;
parameter HOST_FIFO_DEPTH = 64;
defparam usbHostSlaveInst.HOST_FIFO_ADDR_WIDTH = 6;
parameter HOST_FIFO_ADDR_WIDTH = 6;
defparam usbHostSlaveInst.EP0_FIFO_DEPTH = 64;
parameter EP0_FIFO_DEPTH = 64;
defparam usbHostSlaveInst.EP0_FIFO_ADDR_WIDTH = 6;
parameter EP0_FIFO_ADDR_WIDTH = 6;
defparam usbHostSlaveInst.EP1_FIFO_DEPTH = 64;
parameter EP1_FIFO_DEPTH = 64;
defparam usbHostSlaveInst.EP1_FIFO_ADDR_WIDTH = 6;
parameter EP1_FIFO_ADDR_WIDTH = 6;
defparam usbHostSlaveInst.EP2_FIFO_DEPTH = 64;
parameter EP2_FIFO_DEPTH = 64;
defparam usbHostSlaveInst.EP2_FIFO_ADDR_WIDTH = 6;
parameter EP2_FIFO_ADDR_WIDTH = 6;
defparam usbHostSlaveInst.EP3_FIFO_DEPTH = 64;
parameter EP3_FIFO_DEPTH = 64;
defparam usbHostSlaveInst.EP3_FIFO_ADDR_WIDTH = 6;
parameter EP3_FIFO_ADDR_WIDTH = 6;
usbHostSlave usbHostSlaveInst (
  .clk_i(clk_i),
  .rst_i(rst_i),
  .address_i(address_i),
  .data_i(data_i),
  .data_o(data_o),
  .we_i(we_i),
  .strobe_i(strobe_i),
  .ack_o(ack_o),
  .usbClk(usbClk),
  .hostSOFSentIntOut(hostSOFSentIntOut),
  .hostConnEventIntOut(hostConnEventIntOut),
  .hostResumeIntOut(hostResumeIntOut),
  .hostTransDoneIntOut(hostTransDoneIntOut),
  .slaveSOFRxedIntOut(slaveSOFRxedIntOut),
  .slaveResetEventIntOut(slaveResetEventIntOut),
  .slaveResumeIntOut(slaveResumeIntOut),
  .slaveTransDoneIntOut(slaveTransDoneIntOut),
  .slaveNAKSentIntOut(slaveNAKSentIntOut),
  .USBWireDataIn(USBWireDataIn),
  .USBWireDataInTick(USBWireDataInTick),
  .USBWireDataOut(USBWireDataOut),
  .USBWireDataOutTick(USBWireDataOutTick),
  .USBWireCtrlOut(USBWireCtrlOut),
  .USBFullSpeed(USBFullSpeed));


endmodule

  
  




