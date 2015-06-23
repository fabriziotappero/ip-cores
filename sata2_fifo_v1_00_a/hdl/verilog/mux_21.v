//--------------------------------------------------------------------------------
// Entity   mux_21 
// Version: 1.0
// Author:  Ashwin Mendon 
// Description: 2 bit 2:1 Multiplexer
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


module mux_21 
   (
    input wire [1:0] a,
    input wire [1:0] b,
    input wire   sel,
    output reg [1:0] o
    );

  always @ (a or b or sel)
  begin
    case (sel)
      1'b0: 
          o = a;
      1'b1: 
          o = b;
    endcase
  end

endmodule

