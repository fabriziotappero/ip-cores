//////////////////////////////////////////////////////////////////
//                                                              //
//  Arithmetic and logic unit (ALU) for Edge core               //
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//  ALU supports add, sub, and, or and mul functions.           //
//  Also it outputs zero and sign flags.                        //
//                                                              //
//  Author(s):                                                  //
//      - Hesham AL-Matary, heshamelmatary@gmail.com            //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2014 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////

module alu
#
(
  parameter N=32
)
(
  input [N-1:0] a, b,
  input [3:0] f,
  output reg[N-1:0] y,
  output zero,
  output sign
);

wire [N-1:0] b_mux2_out;
wire [N-1:0] adder_out, tmp;
wire cout;

// first level mux 
mux2 mux2_out(b, ~b, f[2], b_mux2_out);

// Adder output
adder adder(a, b_mux2_out, f[2], cout, adder_out);

always @*
begin
  if(f[3] == 0)
  begin
    case(f[1:0])
      0: y = a & b_mux2_out;
      1: y = a | b_mux2_out;
      2: y = adder_out;
      3: y = f[2] ? ((adder_out[N-1] == 1'b1) ? 1 : 0) : 
      (a ^ b_mux2_out);
      default : y = 0;
    endcase
   end
    else // f[3] == 1
    begin
      case(f[2:0])
        3'b000: y = a * b;
        default : y = 0;
      endcase
    end
end

assign zero = (y == 0) ? 1'b1:1'b0;
assign sign = y[N-1];

endmodule
	
