//////////////////////////////////////////////////////////////////////
////                                                              ////
//// usbDevice.v                                                 ////
////                                                              ////
//// This file is part of the usbHostSlave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
//// Top level module for usbDevice
//// Instantiates a usbSlave, and controllers for EP0 and EP1
//// If you wish to implement another type of HID, then you will
//// need to modify usbROM.v, and EP1Mouse.v
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

module usbDevice (
  clk,
  rst,
  usbSlaveVP_in,
  usbSlaveVM_in,
  usbSlaveVP_out,
  usbSlaveVM_out,
  usbSlaveOE_n,
  usbDPlusPullup,
  vBusDetect
);

input clk;
input rst;
input usbSlaveVP_in;
input usbSlaveVM_in;
output usbSlaveVP_out;
output usbSlaveVM_out;
output usbSlaveOE_n;
output usbDPlusPullup;
input vBusDetect;

//local wires and regs
wire [7:0] wb_addr0;
wire wb_stb0;
wire wb_we0;
wire wbBusReq0;
wire wbBusGnt0;
wire [7:0] wb_addr1;
wire [7:0] wb_data_o1;
wire wb_stb1;
wire wb_we1;
wire wbBusReq1;
wire wbBusGnt1;
wire [7:0] wb_addr2;
wire [7:0] wb_data_o2;
wire wb_stb2;
wire wb_we2;
wire wbBusReq2;
wire wbBusGnt2;
wire [7:0] wb_adr;
wire [7:0] wb_dat_to_usb;
wire [7:0] wb_dat_from_usb;
wire wb_we;
wire wb_stb;
wire wb_ack;
reg [1:0] resetReg;
wire initComplete;
wire usbRstDet;
wire [7:0] memAddr;
wire [7:0] memData;
wire USBWireCtrlOut;
wire [1:0] USBWireDataIn;
wire [1:0] USBWireDataOut;


//Parameters declaration: 
defparam usbSlaveInst.EP0_FIFO_DEPTH = 64;
defparam usbSlaveInst.EP0_FIFO_ADDR_WIDTH = 6;
defparam usbSlaveInst.EP1_FIFO_DEPTH = 64;
defparam usbSlaveInst.EP1_FIFO_ADDR_WIDTH = 6;
defparam usbSlaveInst.EP2_FIFO_DEPTH = 64;
defparam usbSlaveInst.EP2_FIFO_ADDR_WIDTH = 6;
defparam usbSlaveInst.EP3_FIFO_DEPTH = 64;
defparam usbSlaveInst.EP3_FIFO_ADDR_WIDTH = 6;
usbSlave usbSlaveInst (
  .clk_i(clk),
  .rst_i(rst),
  .address_i(wb_adr),
  .data_i(wb_dat_to_usb),
  .data_o(wb_dat_from_usb),
  .we_i(wb_we),
  .strobe_i(wb_stb),
  .ack_o(wb_ack),
  .usbClk(clk),
  .slaveSOFRxedIntOut(),
  .slaveResetEventIntOut(),
  .slaveResumeIntOut(),
  .slaveTransDoneIntOut(),
  .slaveNAKSentIntOut(),
  .slaveVBusDetIntOut(),
  .USBWireDataIn(USBWireDataIn),
  .USBWireDataInTick(),
  .USBWireDataOut(USBWireDataOut),
  .USBWireDataOutTick(),
  .USBWireCtrlOut(USBWireCtrlOut),
  .USBFullSpeed(),
  .USBDPlusPullup(usbDPlusPullup),
  .USBDMinusPullup(),
  .vBusDetect(vBusDetect)
);

assign USBWireDataIn = {usbSlaveVP_in, usbSlaveVM_in};
assign {usbSlaveVP_out, usbSlaveVM_out} = USBWireDataOut;
assign usbSlaveOE_n = ~USBWireCtrlOut;

checkLineState u_checkLineState (
  .clk(clk),
  .rst(rst),
  .initComplete(initComplete),
  .usbRstDet(usbRstDet),
  .wb_ack(wb_ack),
  .wb_addr(wb_addr0),
  .wb_data_i(wb_dat_from_usb),
  .wb_stb(wb_stb0),
  .wb_we(wb_we0),
  .wbBusGnt(wbBusGnt0),
  .wbBusReq(wbBusReq0)
);


EP0 u_EP0 (
  .clk(clk), 
  .rst(rst | usbRstDet),
  .initComplete(initComplete),
  .wb_ack(wb_ack),
  .wb_addr(wb_addr1),
  .wb_data_i(wb_dat_from_usb),
  .wb_data_o(wb_data_o1),
  .wb_stb(wb_stb1),
  .wb_we(wb_we1),
  .wbBusGnt(wbBusGnt1),
  .wbBusReq(wbBusReq1),
  .memAddr(memAddr),
  .memData(memData),
  .memRdEn()
);

usbROM u_usbROM (
  .clk(clk),
  .addr(memAddr),
  .data(memData)
);


EP1Mouse u_EP1Mouse (
  .clk(clk),
  .rst(rst | usbRstDet),
  .initComplete(initComplete),
  .wb_ack(wb_ack),
  .wb_addr(wb_addr2),
  .wb_data_i(wb_dat_from_usb),
  .wb_data_o(wb_data_o2),
  .wb_stb(wb_stb2),
  .wb_we(wb_we2),
  .wbBusGnt(wbBusGnt2),
  .wbBusReq(wbBusReq2)
);

wishboneArb u_wishboneArb (
  .clk(clk),
  .rst(rst),

  .addr0_i(wb_addr0),
  .data0_i(8'h00),
  .stb0_i(wb_stb0),
  .we0_i(wb_we0),
  .req0(wbBusReq0),
  .gnt0(wbBusGnt0),

  .addr1_i(wb_addr1),
  .data1_i(wb_data_o1),
  .stb1_i(wb_stb1),
  .we1_i(wb_we1),
  .req1(wbBusReq1),
  .gnt1(wbBusGnt1),

  .addr2_i(wb_addr2),
  .data2_i(wb_data_o2),
  .stb2_i(wb_stb2),
  .we2_i(wb_we2),
  .req2(wbBusReq2),
  .gnt2(wbBusGnt2),


  .addr_o(wb_adr),
  .data_o(wb_dat_to_usb),
  .stb_o(wb_stb),
  .we_o(wb_we)
);


endmodule

