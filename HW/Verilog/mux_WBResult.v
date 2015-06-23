//////////////////////////////////////////////////////////////////
//                                                              //
//  Write back result select mux                                //
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//  Multiplixer to choose from different result size            //               
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

`define loadWord 		3'b000 /* LW (normal load word) */
`define loadSByte		3'b001 /* LB (load signed byte) */
`define loadSHWord	3'b010 /* LH (load signed half word) */
`define loadUByte		3'b011 /* LBU (load unsigned byte) */
`define loadUHWord 	3'b100 /* LHU (load unsgined half word) */

module mux_WBResult
#
(
  parameter N=32
)
(
  input[N-1:0] Word,
  input[N-1:0] SByte,
  input[N-1:0] SHWord,
  input[N-1:0] UByte,
  input[N-1:0] UHWord,
  input[2:0] s,
  output reg[N-1:0] WBResult
);

always @(*)
  case (s)
    `loadWord: WBResult = Word;
    `loadSByte: WBResult = SByte;
    `loadSHWord: WBResult = SHWord;
    `loadUByte: WBResult = UByte;
    `loadUHWord: WBResult = UHWord;
    default: WBResult = Word;
  endcase
endmodule
