//////////////////////////////////////////////////////////////////////
////                                                              ////
//// speedCtrlMux.v                                               ////
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

module speedCtrlMux (directCtrlRate, directCtrlPol, sendPacketRate, sendPacketPol, sendPacketSel, fullSpeedRate, fullSpeedPol);
input   directCtrlRate;
input   directCtrlPol;
input   sendPacketRate;
input   sendPacketPol;
input   sendPacketSel;
output  fullSpeedRate;
output  fullSpeedPol;

wire   directCtrlRate;
wire   directCtrlPol;
wire   sendPacketRate;
wire   sendPacketPol;
wire   sendPacketSel;
reg   fullSpeedRate;
reg   fullSpeedPol;


always @(directCtrlRate or directCtrlPol or sendPacketRate or sendPacketPol or sendPacketSel)
begin
  if (sendPacketSel == 1'b1) 
  begin
  fullSpeedRate <= sendPacketRate;
  fullSpeedPol <= sendPacketPol;
  end
  else
  begin
  fullSpeedRate <= directCtrlRate;
  fullSpeedPol <= directCtrlPol;
  end
end

endmodule
