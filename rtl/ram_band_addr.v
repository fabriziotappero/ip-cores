`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description:
//   Convert "static" portion of a 650 address into a binary origin that is a
//   multiple of 600. Used to address RAM representing general storage. In the
//   real 650 this would be the band address which would select a band of five
//   drum tracks.
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

module ram_band_addr (
   input [0:6] addr_th, addr_h, addr_t,
   output reg  [0:14] origin
   );
    
   always @(*) begin
      case ({addr_th[`biq_q1], addr_h, addr_t[`biq_b5]})
         9'b0_01_00001_0: origin = 15'd0;
         9'b0_01_00001_1: origin = 15'd600;
         9'b0_01_00010_0: origin = 15'd1200;
         9'b0_01_00010_1: origin = 15'd1800;
         9'b0_01_00100_0: origin = 15'd2400;
         9'b0_01_00100_1: origin = 15'd3000;
         9'b0_01_01000_0: origin = 15'd3600;
         9'b0_01_01000_1: origin = 15'd4200;
         9'b0_01_10000_0: origin = 15'd4800;
         9'b0_01_10000_1: origin = 15'd5400;
         
         9'b0_10_00001_0: origin = 15'd6000;
         9'b0_10_00001_1: origin = 15'd6600;
         9'b0_10_00010_0: origin = 15'd7200;
         9'b0_10_00010_1: origin = 15'd7800;
         9'b0_10_00100_0: origin = 15'd8400;
         9'b0_10_00100_1: origin = 15'd9000;
         9'b0_10_01000_0: origin = 15'd9600;
         9'b0_10_01000_1: origin = 15'd10200;
         9'b0_10_10000_0: origin = 15'd10800;
         9'b0_10_10000_1: origin = 15'd11400;

         9'b1_01_00001_0: origin = 15'd12000;
         9'b1_01_00001_1: origin = 15'd12600;
         9'b1_01_00010_0: origin = 15'd13200;
         9'b1_01_00010_1: origin = 15'd13800;
         9'b1_01_00100_0: origin = 15'd14400;
         9'b1_01_00100_1: origin = 15'd15000;
         9'b1_01_01000_0: origin = 15'd15600;
         9'b1_01_01000_1: origin = 15'd16200;
         9'b1_01_10000_0: origin = 15'd16800;
         9'b1_01_10000_1: origin = 15'd17400;
         
         9'b1_10_00001_0: origin = 15'd18000;
         9'b1_10_00001_1: origin = 15'd18600;
         9'b1_10_00010_0: origin = 15'd19200;
         9'b1_10_00010_1: origin = 15'd19800;
         9'b1_10_00100_0: origin = 15'd20400;
         9'b1_10_00100_1: origin = 15'd21000;
         9'b1_10_01000_0: origin = 15'd21600;
         9'b1_10_01000_1: origin = 15'd22200;
         9'b1_10_10000_0: origin = 15'd22800;
         9'b1_10_10000_1: origin = 15'd23400;

         default:      origin = 15'd0;
      endcase;
   end;

endmodule
