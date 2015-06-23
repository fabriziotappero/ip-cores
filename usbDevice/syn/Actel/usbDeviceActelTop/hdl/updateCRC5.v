//////////////////////////////////////////////////////////////////////
////                                                              ////
//// updateCRC5.v                                                 ////
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

module updateCRC5 (rstCRC, CRCResult, CRCEn, CRC5_8BitIn, dataIn, ready, clk, rst);
input   rstCRC;
input   CRCEn;
input   CRC5_8BitIn;
input   [7:0] dataIn;
input   clk;
input   rst;
output  [4:0] CRCResult;
output ready;

wire   rstCRC;
wire   CRCEn;
wire   CRC5_8BitIn;
wire   [7:0] dataIn;
wire   clk;
wire   rst;
reg    [4:0] CRCResult;
reg ready;

reg doUpdateCRC;
reg [7:0] data;
reg [3:0] loopEnd;
reg [3:0] i;

always @(posedge clk)
begin
  if (rst == 1'b1 || rstCRC == 1'b1) begin
    doUpdateCRC <= 1'b0;
    i <= 4'h0;
    CRCResult <= 5'h1f;
    ready <= 1'b1;
  end
  else
  begin
    if (doUpdateCRC == 1'b0) begin
      if (CRCEn == 1'b1) begin
        ready <= 1'b0;
        doUpdateCRC <= 1'b1;
        data <= dataIn;
        if (CRC5_8BitIn == 1'b1) begin
          loopEnd <= 4'h7; 
        end
        else begin
          loopEnd <= 4'h2;
        end
      end
    end
    else begin
      i <= i + 1'b1;
      if ( (CRCResult[0] ^ data[0]) == 1'b1) begin
        CRCResult <= {1'b0, CRCResult[4:1]} ^ 5'h14;
      end
      else begin
        CRCResult <= {1'b0, CRCResult[4:1]};
      end
      data <= {1'b0, data[7:1]};
      if (i == loopEnd) begin
        doUpdateCRC <= 1'b0; 
        i <= 4'h0;
        ready <= 1'b1;
      end
    end
  end
end
    

endmodule
