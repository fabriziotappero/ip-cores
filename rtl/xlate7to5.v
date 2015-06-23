`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Translate bi-quinary to 2-of-5 drum code.
// 
// Additional Comments:
//
// Copyright (c) 2015 Robert Abeles
//
// This source file is free software; you can redistribute it
// and/or modify it under the terms of the GNU Lesser General
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any
// later version.
//
// This source is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General
// Public License along with this source; if not, download it
// from http://www.opencores.org/lgpl.shtml
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module xlate7to5(
    input [0:6] in_7,
    output reg[0:4] out_5
    );

   always @(*) begin
      case (in_7)
         `biq_0 : out_5 = `drum2of5_0;
         `biq_1 : out_5 = `drum2of5_1;
         `biq_2 : out_5 = `drum2of5_2;
         `biq_3 : out_5 = `drum2of5_3;
         `biq_4 : out_5 = `drum2of5_4;
         `biq_5 : out_5 = `drum2of5_5;
         `biq_6 : out_5 = `drum2of5_6;
         `biq_7 : out_5 = `drum2of5_7;
         `biq_8 : out_5 = `drum2of5_8;
         `biq_9 : out_5 = `drum2of5_9;
         default    : out_5 = `drum2of5_blank;  // invalid codes become zeroes
      endcase;
   end;
endmodule
