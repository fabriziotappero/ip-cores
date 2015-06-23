`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Translate 2-of-5 drum code to bi-quinary.
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

module xlate5to7(
    input [0:4] in_5,
    output reg[0:6] out_7
    );

   always @(*) begin
      case (in_5)
         `drum2of5_0 : out_7 = `biq_0;
         `drum2of5_1 : out_7 = `biq_1;
         `drum2of5_2 : out_7 = `biq_2;
         `drum2of5_3 : out_7 = `biq_3;
         `drum2of5_4 : out_7 = `biq_4;
         `drum2of5_5 : out_7 = `biq_5;
         `drum2of5_6 : out_7 = `biq_6;
         `drum2of5_7 : out_7 = `biq_7;
         `drum2of5_8 : out_7 = `biq_8;
         `drum2of5_9 : out_7 = `biq_9;
         default  : out_7 = `biq_blank;   // invalid codes become all zeroes
      endcase;
   end;

endmodule
