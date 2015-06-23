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
  usbHostOE_n,

  //
  // USB slave
  //
  usbSlaveVP,
  usbSlaveVM,
  usbSlaveOE_n,
  usbDPlusPullup,
  vBusDetect
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
  output usbHostOE_n;

  //
  // USB slave
  //
  inout usbSlaveVP;
  inout usbSlaveVM;
  output usbSlaveOE_n;
  output usbDPlusPullup;
  input vBusDetect;

//local wires and regs
reg [1:0] rstReg;
wire rst;
wire pll_locked;

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
  .usbDPlusPullup(usbDPlusPullup),
  .vBusDetect(vBusDetect)
);


assign {usbSlaveVP_in, usbSlaveVM_in} = {usbSlaveVP, usbSlaveVM};
assign {usbSlaveVP, usbSlaveVM} = (usbSlaveOE_n == 1'b0) ? {usbSlaveVP_out, usbSlaveVM_out} : 2'bzz;

endmodule


