//--------------------------------------------------------------------------------
// Entity   mux_21 
// Version: 1.0
// Author:  Ashwin Mendon 
// Description: 32 bit 4:1 Multiplexer
//--------------------------------------------------------------------------------

// Copyright (C) 2012
// Ashwin A. Mendon
//
// This file is part of SATA2 core.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.  


module mux_41 
   (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [31:0] c,
    input wire [31:0] d,
    input wire [1:0] sel,
    output reg [31:0] o
    );

  always @ (a or b or c or d or sel)
  begin
    case (sel)
      2'b00: 
          o = a;
      2'b01: 
          o = b;
      2'b10: 
          o = c; 
      2'b11:
          o = d;  
     endcase     
  end

endmodule

