//////////////////////////////////////////////////////////////////////
////                                                              ////
//// rxStatusMonitor.v                                            ////
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

module rxStatusMonitor(connectStateIn, connectStateOut, resumeDetectedIn, connectionEventOut, resumeIntOut, clk, rst);

input [1:0] connectStateIn;
input resumeDetectedIn;
input clk;
input rst;
output connectionEventOut;
output [1:0] connectStateOut;
output resumeIntOut;

wire [1:0] connectStateIn;
wire resumeDetectedIn;
reg connectionEventOut;
reg [1:0] connectStateOut;
reg resumeIntOut;
wire clk;
wire rst;

reg [1:0]oldConnectState;
reg oldResumeDetected;

always @(connectStateIn)
begin
  connectStateOut <= connectStateIn;
end


always @(posedge clk)
begin
  if (rst == 1'b1)
  begin
    oldConnectState <= connectStateIn;
    oldResumeDetected <= resumeDetectedIn;
  end
  else
  begin
    oldConnectState <= connectStateIn;
    oldResumeDetected <= resumeDetectedIn;
    if (oldConnectState != connectStateIn)
      connectionEventOut <= 1'b1;
    else
      connectionEventOut <= 1'b0;
    if (resumeDetectedIn == 1'b1 && oldResumeDetected == 1'b0)
      resumeIntOut <= 1'b1;
    else 
      resumeIntOut <= 1'b0;
  end
end

endmodule
