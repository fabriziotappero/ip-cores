//////////////////////////////////////////////////////////////////////
////                                                              ////
//// i2cSlaveTopAltera.v                                          ////
////                                                              ////
//// This file is part of the i2cSlave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
//// You will need to modify this file to implement your 
//// interface.
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
`include "i2cSlave_define.v"


module i2cSlaveTopAltera (
  clk,
  sda,
  scl,
  LED
);
input clk;
inout sda;
input scl;
output LED;

//local wires and regs
reg [1:0] rstReg;
wire rst;
wire pll_locked;
wire [7:0] myReg0;

assign LED = myReg0[0];

i2cSlave u_i2cSlave(
  .clk(clk),
  .rst(rst),
  .sda(sda),
  .scl(scl),
  .myReg0(myReg0),
  .myReg1(),
  .myReg2(),
  .myReg3(),
  .myReg4(8'h12),
  .myReg5(8'h34),
  .myReg6(8'h56),
  .myReg7(8'h78)

);

pll_48MHz	pll_48MHz_inst (
	.inclk0 ( clk ),
	.locked( pll_locked)
	);

//generate sync reset from pll lock signal
always @(posedge clk) begin
  rstReg[1:0] <= {rstReg[0], ~pll_locked};
end
assign rst = rstReg[1];

endmodule


 
