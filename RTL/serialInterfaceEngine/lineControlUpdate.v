//////////////////////////////////////////////////////////////////////
////                                                              ////
//// lineControlUpdate.v                                          ////
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
`include "usbSerialInterfaceEngine_h.v"

module lineControlUpdate(fullSpeedPolarity, fullSpeedBitRate, JBit, KBit);
input fullSpeedPolarity;
input fullSpeedBitRate;
output [1:0] JBit;
output [1:0] KBit;

wire fullSpeedPolarity;
wire fullSpeedBitRate;
reg [1:0] JBit;
reg [1:0] KBit;



always @(fullSpeedPolarity)
begin
    if (fullSpeedPolarity == 1'b1)
  begin
      JBit = `ONE_ZERO;
      KBit = `ZERO_ONE;
    end
    else
  begin
      JBit = `ZERO_ONE;
      KBit = `ONE_ZERO;
    end
end


endmodule
