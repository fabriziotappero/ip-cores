//////////////////////////////////////////////////////////////////////
////                                                              ////
//// registerInterface.v                                          ////
////                                                              ////
//// This file is part of the i2cSlave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
//// You will need to modify this file to implement your 
//// interface.
//// Add your control and status bytes/bits to module inputs and outputs,
//// and also to the I2C read and write process blocks  
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


module registerInterface (
  clk,
  addr,
  dataIn,
  writeEn,
  dataOut,
  myReg0,
  myReg1,
  myReg2,
  myReg3,
  myReg4,
  myReg5,
  myReg6,
  myReg7

);
input clk;
input [7:0] addr;
input [7:0] dataIn;
input writeEn;
output [7:0] dataOut;
output [7:0] myReg0;
output [7:0] myReg1;
output [7:0] myReg2;
output [7:0] myReg3;
input [7:0] myReg4;
input [7:0] myReg5;
input [7:0] myReg6;
input [7:0] myReg7;

reg [7:0] dataOut;
reg [7:0] myReg0;
reg [7:0] myReg1;
reg [7:0] myReg2;
reg [7:0] myReg3;

// --- I2C Read
always @(posedge clk) begin
  case (addr)
    8'h00: dataOut <= myReg0;  
    8'h01: dataOut <= myReg1;  
    8'h02: dataOut <= myReg2;  
    8'h03: dataOut <= myReg3;  
    8'h04: dataOut <= myReg4;  
    8'h05: dataOut <= myReg5;  
    8'h06: dataOut <= myReg6;  
    8'h07: dataOut <= myReg7;  
    default: dataOut <= 8'h00;
  endcase
end

// --- I2C Write
always @(posedge clk) begin
  if (writeEn == 1'b1) begin
    case (addr)
      8'h00: myReg0 <= dataIn;  
      8'h01: myReg1 <= dataIn;
      8'h02: myReg2 <= dataIn;
      8'h03: myReg3 <= dataIn;
    endcase
  end
end

endmodule


 
