//////////////////////////////////////////////////////////////////
//                                                              //
//  ALU decoder for Edge core                                   //
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//  ALU decoder decodes functions encoded in MIPS instruction   //
//  and sends out the appropriate command to ALU unit.          //
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

`define ADD_ALUOP   4'b0000
`define SUB_ALUOP   4'b0001
`define LOOK_FUNCT  4'b0010
`define INVAL       4'b0011
`define SLTI_ALUOP  4'b0100
`define ANDI_ALUOP  4'b0101
`define ORI_ALUOP   4'b0110
`define XORI_ALUOP  4'b0111
`define MUL_ALUOP   4'b1000

/* ALUControl output defines */
`define ADD_ALUCTRL   4'b0010
`define SUB_ALUCTRL   4'b0110
`define AND_ALUCTRL   4'b0000
`define OR_ALUCTRL    4'b0001
`define SLT_ALUCTRL   4'b0111
`define XOR_ALUCTRL   4'b0011
`define NOR_ALUCTRL   4'b0100
`define MUL_ALUCTRL   4'b1000

/* FUNCT defines INST[5:0] */
`define SLL_FUNCT   6'b000000 // 0 
`define SRL_FUNCT   6'b000010 // 2
`define SRA_FUNCT   6'b000011 // 3
`define SLLV_FUNCT  6'b000100 // 4
`define SRLV_FUNCT  6'b000110 // 6
`define SRAV_FUNCT  6'b000111 // 7
`define ADD_FUNCT   6'b100000 // 32
`define ADDU_FUNCT  6'b100001 // 33
`define SUB_FUNCT   6'b100010 // 34
`define SUBU_FUNCT  6'b100011 // 35
`define AND_FUNCT   6'b100100 // 36
`define OR_FUNCT    6'b100101 // 37
`define XOR_FUNCT   6'b100110 // 38
`define NOR_FUNCT   6'b100111 // 39
`define SLT_FUNCT   6'b101010 // 42
`define SLTU_FUNCT  6'b101011 // 43

module alu_decoder
(
  input[3:0] ALUop,
  input[5:0] Funct,
  output reg[3:0] ALUControl
);

always @*
begin

  case(ALUop)
    `ADD_ALUOP :  ALUControl <= `ADD_ALUCTRL;
    `SUB_ALUOP :  ALUControl <= `SUB_ALUCTRL;
    `SLTI_ALUOP:  ALUControl <= `SLT_ALUCTRL;
    `ANDI_ALUOP:  ALUControl <= `AND_ALUCTRL;
    `ORI_ALUOP :  ALUControl <= `OR_ALUCTRL;
    `XORI_ALUOP:  ALUControl <= `XOR_ALUCTRL;
    `MUL_ALUOP :  ALUControl <= `MUL_ALUCTRL;
    `LOOK_FUNCT:  ALUControl <= funct_decode(Funct);
    `INVAL     :  ALUControl <= 3'b000; /* (nop) Mapped to be add operation */
    default    :  ALUControl <= `ADD_ALUCTRL;
  endcase
end

function[3:0] funct_decode (input[5:0] funct);
  case (funct)		
    `ADD_FUNCT, 
    `ADDU_FUNCT:
      funct_decode = `ADD_ALUCTRL;
    `SUB_FUNCT,
    `SUBU_FUNCT:
      funct_decode = `SUB_ALUCTRL;
    `NOR_FUNCT,
    `OR_FUNCT: 
      funct_decode = `OR_ALUCTRL;
    `XOR_FUNCT: 
      funct_decode = `XOR_ALUCTRL;
    `SLT_FUNCT, `SLTU_FUNCT:
      funct_decode = `SLT_ALUCTRL;
    default: 
      funct_decode = 5'b00000;
  endcase 
		
endfunction 

endmodule
