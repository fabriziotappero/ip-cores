`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description:
//   Convert dynamic portion of 650 address into a word offset in general
//   storage RAM.
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

module ram_word_offset (
   input [0:6] addr_t, addr_u,
   output reg  [0:9] offset
   );
    
   always @(*) begin
      case({addr_t[2:6], addr_u})
         12'b00001_01_00001: offset = 10'd0;
         12'b00001_01_00010: offset = 10'd12;
         12'b00001_01_00100: offset = 10'd24;
         12'b00001_01_01000: offset = 10'd36;
         12'b00001_01_10000: offset = 10'd48;
         12'b00001_10_00001: offset = 10'd60;
         12'b00001_10_00010: offset = 10'd72;
         12'b00001_10_00100: offset = 10'd84;
         12'b00001_10_01000: offset = 10'd96;
         12'b00001_10_10000: offset = 10'd108;

         12'b00010_01_00001: offset = 10'd120;
         12'b00010_01_00010: offset = 10'd132;
         12'b00010_01_00100: offset = 10'd144;
         12'b00010_01_01000: offset = 10'd156;
         12'b00010_01_10000: offset = 10'd168;
         12'b00010_10_00001: offset = 10'd180;
         12'b00010_10_00010: offset = 10'd192;
         12'b00010_10_00100: offset = 10'd204;
         12'b00010_10_01000: offset = 10'd216;
         12'b00010_10_10000: offset = 10'd228;

         12'b00100_01_00001: offset = 10'd240;
         12'b00100_01_00010: offset = 10'd252;
         12'b00100_01_00100: offset = 10'd264;
         12'b00100_01_01000: offset = 10'd276;
         12'b00100_01_10000: offset = 10'd288;
         12'b00100_10_00001: offset = 10'd300;
         12'b00100_10_00010: offset = 10'd312;
         12'b00100_10_00100: offset = 10'd324;
         12'b00100_10_01000: offset = 10'd336;
         12'b00100_10_10000: offset = 10'd348;

         12'b01000_01_00001: offset = 10'd360;
         12'b01000_01_00010: offset = 10'd372;
         12'b01000_01_00100: offset = 10'd384;
         12'b01000_01_01000: offset = 10'd396;
         12'b01000_01_10000: offset = 10'd408;
         12'b01000_10_00001: offset = 10'd420;
         12'b01000_10_00010: offset = 10'd432;
         12'b01000_10_00100: offset = 10'd444;
         12'b01000_10_01000: offset = 10'd456;
         12'b01000_10_10000: offset = 10'd468;

         12'b10000_01_00001: offset = 10'd480;
         12'b10000_01_00010: offset = 10'd492;
         12'b10000_01_00100: offset = 10'd504;
         12'b10000_01_01000: offset = 10'd516;
         12'b10000_01_10000: offset = 10'd528;
         12'b10000_10_00001: offset = 10'd540;
         12'b10000_10_00010: offset = 10'd552;
         12'b10000_10_00100: offset = 10'd564;
         12'b10000_10_01000: offset = 10'd576;
         12'b10000_10_10000: offset = 10'd588;

         default:      offset = 15'd0;
      endcase;
   end;

endmodule
