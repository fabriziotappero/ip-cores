//////////////////////////////////////////////////////////////////
//                                                              //
//  Shift decoder for Edge Core                                 //       
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//  Shift decoder is part of the main controller/decoder at     //
//  decode stage. It decodes MIPS instruction and produces      //
//  control signals for the shift unit.
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

/* Shift unit control */
`define SLL_CTRL		2'b00
`define SRL_CTRL	 	2'b01
`define SRA_CTRL		2'b10

/* Shift Encoding */
`define SLL_FUNCT		6'b000000 // 0 
`define SRL_FUNCT		6'b000010 // 2
`define SRA_FUNCT		6'b000011 // 3
`define SLLV_FUNCT	6'b000100 // 4
`define SRLV_FUNCT	6'b000110 // 6
`define SRAV_FUNCT	6'b000111 // 7

module shifter_decoder
(
  input[5:0] Funct,
  
  output reg ShiftAmtVar_out,
  output reg[1:0] Shift_type
);

always @*
begin
  ShiftAmtVar_out = 1'b0;
  Shift_type <= 2'b00;

  case (Funct)
    `SLL_FUNCT : Shift_type <= `SLL_CTRL;
    `SLLV_FUNCT : 
      begin
        Shift_type <= `SLL_CTRL;
        ShiftAmtVar_out = 1'b1;
      end
    `SRL_FUNCT : Shift_type <= `SRL_CTRL;
    `SRLV_FUNCT : 
      begin
        Shift_type <= `SRL_CTRL;
        ShiftAmtVar_out = 1'b1;
      end
    `SRA_FUNCT : Shift_type <= `SRA_CTRL;
    `SRAV_FUNCT : 
      begin
        Shift_type <= `SRA_CTRL;
        ShiftAmtVar_out = 1'b1;
      end
    
  endcase
end

endmodule
