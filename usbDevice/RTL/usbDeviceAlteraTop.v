//////////////////////////////////////////////////////////////////////
////                                                              ////
//// usbDeviceAlteraTop.v                                                 ////
////                                                              ////
//// This file is part of the spiMaster opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
//// Top level module for Altera FPGA and NXP ISP1105 USB PHY.
//// Specifically it targets the Base2Designs Altera Development board.
//// Instantiates a PLL so that the lock signal can be used
//// to reset the logic, and ties unused control signals
//// to the off or disabled state
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
//`define PHY_ISP1105
module usbDeviceAlteraTop (

	//
	// Global signals
	//
		clk,

	//
	// SDRAM
	//
	mc_addr,
	mc_ba,
	mc_dqm,
	mc_we_,
	mc_cas_,
	mc_ras_,
	mc_cke_,
	sdram_cs,
	sdram_clk,

  //
  // SPI bus
  //
  spiClk,
  spiMasterDataOut,
  spiCS_n,


  //
  // USB host
  //
  //usbHostOE_n,

  //
  // USB slave
  //
  //usbSlaveVP,
  //usbSlaveVM,

  //usbSlaveOE_n,
  //usbDPlusPullup,
  //vBusDetect,

  //
  // Santa Cruz header
  //
  SC_P_CLK,
  SC_RST_N,
  SC_CS_N,
  SC_P0,
  SC_P1,
  SC_P2,
  SC_P3,
  SC_P4,
  SC_P5,
  SC_P6,
  SC_P7,
  SC_P8,
  SC_P9,
  SC_P10,
  SC_P11,
  SC_P12,
  SC_P13,
  SC_P14,
  SC_P15,
  SC_P16,
  SC_P17,
  SC_P18,
  SC_P19,
  SC_P20,
  SC_P21,
  SC_P22,
  SC_P23,
  SC_P24,
  SC_P25,
  SC_P26,
  SC_P27,
  SC_P28,
  SC_P29,
  SC_P30,
  SC_P31,
  SC_P32,
  SC_P33,
  SC_P34,
  SC_P35,
  SC_P36,
  SC_P37,
  SC_P38,
  SC_P39



);
	//
	// Global signals
	//
	input	clk;

	//
	// SDRAM
	//
	output	[11:0]	mc_addr;
	output	[1:0]	mc_ba;
	output	[3:0]	mc_dqm;
	output		mc_we_;
	output		mc_cas_;
	output		mc_ras_;
	output		mc_cke_;
	output		sdram_cs;
	output		sdram_clk;

  //
  // SPI bus
  //
  output spiClk;
  output spiMasterDataOut;
  output spiCS_n;

  //
  // USB host
  //
  //output usbHostOE_n;

  //
  // USB slave
  //
  //inout usbSlaveVP;
  //inout usbSlaveVM;

  //output usbSlaveOE_n;
  //output usbDPlusPullup;
  //input vBusDetect;

`ifdef PHY_ISP1105
  output SC_P_CLK;
  output SC_RST_N;
  output SC_CS_N;
  output SC_P0;
  output SC_P1;
  output SC_P2;
  output SC_P3;
  output SC_P4;
  output SC_P5;
  output SC_P6;
  output SC_P7;
  output SC_P8;
  output SC_P9;
  output SC_P10;
  output SC_P11;
  output SC_P12;
  output SC_P13;
  output SC_P14;
  output SC_P15;
  output SC_P16;
  output SC_P17;
  output SC_P18;
  output SC_P19;
  input SC_P20;
  output SC_P21;
  inout SC_P22;
  inout SC_P23;
  output SC_P24;
  output SC_P25;
  output SC_P26;
  output SC_P27;
  output SC_P28;
  output SC_P29;
  output SC_P30;
  output SC_P31;
  output SC_P32;
  output SC_P33;
  output SC_P34;
  output SC_P35;
  output SC_P36;
  output SC_P37;
  output SC_P38;
  output SC_P39;
`else
  output SC_P_CLK;
  output SC_RST_N;
  output SC_CS_N;
  output SC_P0;
  output SC_P1;
  input SC_P2;
  output SC_P3;
  input SC_P4;
  output SC_P5;
  output SC_P6;
  output SC_P7;
  output SC_P8;
  output SC_P9;
  output SC_P10;
  output SC_P11;
  output SC_P12;
  output SC_P13;
  output SC_P14;
  output SC_P15;
  output SC_P16;
  output SC_P17;
  output SC_P18;
  output SC_P19;
  output SC_P20;
  output SC_P21;
  input SC_P22;
  output SC_P23;
  input SC_P24;
  output SC_P25;
  output SC_P26;
  output SC_P27;
  output SC_P28;
  output SC_P29;
  output SC_P30;
  output SC_P31;
  output SC_P32;
  output SC_P33;
  output SC_P34;
  output SC_P35;
  output SC_P36;
  output SC_P37;
  output SC_P38;
  output SC_P39;
`endif



//local wires and regs
reg [1:0] rstReg;
wire rst;
wire pll_locked;
wire usbSlaveVP_in;
wire usbSlaveVM_in;
wire usbSlaveVP_out;
wire usbSlaveVM_out;
wire usbSlaveFullSpeed;

assign mc_addr = {12{1'b0}};
assign mc_ba = 2'b00;
assign mc_dqm = 4'h0;
assign mc_we_ = 1'b1;
assign mc_cas_ = 1'b1;
assign mc_ras_ = 1'b1;
assign mc_cke_ = 1'b1;
assign sdram_cs = 1'b1;
assign sdram_clk = 1'b1;
assign spiClk = 1'b0;
assign spiMasterDataOut = 1'b0;
assign spiCS_n = 1'b1;
assign usbHostOE_n = 1'b1;

pll_48MHz	pll_48MHz_inst (
	.inclk0 ( clk ),
	.locked( pll_locked)
	);

//generate sync reset from pll lock signal
always @(posedge clk) begin
  rstReg[1:0] <= {rstReg[0], ~pll_locked};
end
assign rst = rstReg[1];


usbDevice u_usbDevice (
  .clk(clk),
  .rst(rst),
  .usbSlaveVP_in(usbSlaveVP_in),
  .usbSlaveVM_in(usbSlaveVM_in),
  .usbSlaveVP_out(usbSlaveVP_out),
  .usbSlaveVM_out(usbSlaveVM_out),
  .usbSlaveOE_n(usbSlaveOE_n),
  .USBFullSpeed(usbSlaveFullSpeed),
  .usbDPlusPullup(usbDPlusPullup),
  .usbDMinusPullup(usbDMinusPullup),
  .vBusDetect(vBusDetect)
);

`ifdef PHY_ISP1105
assign {usbSlaveVP_in, usbSlaveVM_in} = {usbSlaveVP, usbSlaveVM};
assign {usbSlaveVP, usbSlaveVM} = (usbSlaveOE_n == 1'b0) ? {usbSlaveVP_out, usbSlaveVM_out} : 2'bzz;
`else
assign vBusDetect = 1'b1;
`endif

`ifdef PHY_ISP1105
  assign SC_P_CLK = 1'b0;
  assign SC_RST_N = 1'b0;
  assign SC_CS_N = 1'b0;
  assign SC_P0 = 1'b0;
  assign SC_P1 = 1'b0;
  assign SC_P2 = 1'b0;
  assign SC_P3 = 1'b0;
  assign SC_P4 = 1'b0;
  assign SC_P5 = 1'b0;
  assign SC_P6 = 1'b0;
  assign SC_P7 = 1'b0;
  assign SC_P8 = 1'b0;
  assign SC_P9 = 1'b0;
  assign SC_P10 = 1'b0;
  assign SC_P11 = 1'b0;
  assign SC_P12 = 1'b0;
  assign SC_P13 = 1'b0;
  assign SC_P14 = 1'b0;
  assign SC_P15 = 1'b0;
  assign SC_P16 = 1'b0;
  assign SC_P17 = 1'b0;
  assign SC_P18 = 1'b0;
  assign SC_P19 = 1'b0;
  assign vBusDetect = SC_P20;
  assign SC_P21 = 1'b0;
  assign SC_P22 = usbSlaveVM;
  assign SC_P23 = usbSlaveVP;
  assign SC_P24 = usbSlaveOE_n;
  assign SC_P25 = 1'b0;
  assign SC_P26 = usbDPlusPullup;
  assign SC_P27 = 1'b0;
  assign SC_P28 = usbHostOE_n;
  assign SC_P29 = 1'b0;
  assign SC_P30 = 1'b0;
  assign SC_P31 = 1'b0;
  assign SC_P32 = 1'b0;
  assign SC_P33 = 1'b0;
  assign SC_P34 = 1'b0;
  assign SC_P35 = 1'b0;
  assign SC_P36 = 1'b0;
  assign SC_P37 = 1'b0;
  assign SC_P38 = 1'b0;
  assign SC_P39 = 1'b0;
`else
  assign SC_P_CLK = 1'b0;
  assign SC_RST_N = 1'b0;
  assign SC_CS_N = 1'b0;
  assign SC_P0 = usbSlaveFullSpeed;
  assign SC_P1 = 1'b0;
  assign usbSlaveVM_in = SC_P2;
  assign SC_P3 = 1'b0;
  assign usbSlaveVP_in = SC_P4;
  assign SC_P5 = 1'b0;
  assign SC_P6 = usbSlaveOE_n;
  assign SC_P7 = 1'b0;
  assign SC_P8 = usbSlaveVM_out;
  assign SC_P9 = 1'b0;
  assign SC_P10 = usbSlaveVP_out;
  assign SC_P11 = 1'b0;
  assign SC_P12 = usbDPlusPullup;
  assign SC_P13 = 1'b0;
  assign SC_P14 = usbDMinusPullup;
  assign SC_P15 = 1'b0;
  assign SC_P16 = 1'b0;
  assign SC_P17 = 1'b0;
  assign SC_P18 = 1'b0;
  assign SC_P19 = 1'b0;
  assign SC_P20 = 1'b0;
  assign SC_P21 = 1'b0;
  assign usbHostVM_in = SC_P22;
  assign SC_P23 = 1'b0;
  assign usbHostVP_in = SC_P24;
  assign SC_P25 = usbHostOE_n;
  assign SC_P26 = 1'b0;
  assign SC_P27 = 1'b0;
  assign SC_P28 = 1'b0;
  assign SC_P29 = 1'b0;
  assign SC_P30 = 1'b0;
  assign SC_P31 = 1'b0;
  assign SC_P32 = 1'b0;
  assign SC_P33 = 1'b0;
  assign SC_P34 = 1'b0;
  assign SC_P35 = 1'b0;
  assign SC_P36 = 1'b0;
  assign SC_P37 = 1'b0;
  assign SC_P38 = 1'b0;
  assign SC_P39 = 1'b0;
`endif



endmodule


