//////////////////////////////////////////////////////////////////
//                                                              //
//  Shift unit for Edge core                                    //       
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//  Shift unit handling different types of shifts : right, left,//
//  arithmetic and logical.                                     //
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

`define SLL		2'b00
`define SRL 	2'b01
`define SRA		2'b10

module shift_unit
#(parameter N=32)
(
  input[N-1:0] in,
  input[4:0] shamt,
  input[1:0] shift_type,

  output reg[N-1:0] out
);

wire[N-1:0] sl_result, srl_result, sra_result;

shifter_left sl
(
  .in(in),
  .shamt(shamt),
  .out(sl_result)
);

shifter_right_logical 
srl
(
  .in(in),
  .shamt(shamt),
  .out(srl_result)
);

shifter_right_arithmetic sra
(
  .in(in),
  .shamt(shamt),
  .out(sra_result)
);

always @(*)
  case (shift_type)
    `SLL: out <= sl_result;
    `SRL: out <= srl_result;
    `SRA: out <= sra_result;
    default: out <= in;
  endcase

endmodule
