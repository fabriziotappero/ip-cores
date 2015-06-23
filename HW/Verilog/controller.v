//////////////////////////////////////////////////////////////////
//                                                              //
//  Instruction decoder at decode stage for Edge core           //
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//  Instruction decoder receives MIPS instruction and emits the //
//  appropriate control signal for each unit in the pipeline.   //
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

/* OPCODE defines INST[31:26] */
`define RTYPE_OPCODE 6'b000000 // 0

/* Immediates */
`define ADDI_OPCODE   6'b001000 // 8
`define ADDIU_OPCODE  6'b001001 // 9
`define SLTI_OPCODE   6'b001010 // 10
`define SLTIU_OPCODE  6'b001011 // 11
`define ANDI_OPCODE   6'b001100 // 12
`define ORI_OPCODE    6'b001101 // 13
`define XORI_OPCODE   6'b001110 // 14

/* loads */
`define LUI_OPCODE  6'b001111 // 15
`define CP0_OPCODE  6'b010000 // 16 mfc0, mtc0
`define MUL_OPCODE  6'b011100 // 28
`define LB_OPCODE   6'b100000 // 32
`define LH_OPCODE   6'b100001 // 33
`define LW_OPCODE   6'b100011 // 35
`define LBU_OPCODE  6'b100100 // 36
`define LHU_OPCODE  6'b100101 // 37

`define SB_OPCODE   6'b101000 // 40
`define SH_OPCODE   6'b101001 // 41
`define SW_OPCODE   6'b101011 // 43

`define BLTZ_OPCODE 6'b000001 // 1
`define BGEZ_OPCODE 6'b000001 // 1
`define JMP_OPCODE  6'b000010 // 2
`define JAL_OPCODE  6'b000011 // 3
`define BEQ_OPCODE  6'b000100 // 4
`define BNE_OPCODE  6'b000101 // 5
`define BLEZ_OPCODE 6'b000110 // 6
`define BGTZ_OPCODE 6'b000111 // 7

/* FUNCT defines INST[5:0] */
`define SLL_FUNCT   6'b000000 // 0 
`define SRL_FUNCT   6'b000010 // 2
`define SRA_FUNCT   6'b000011 // 3
`define SLLV_FUNCT  6'b000100 // 4
`define SRLV_FUNCT  6'b000110 // 6
`define SRAV_FUNCT  6'b000111 // 7
`define JR_FUNCT    6'b001000 // 8
`define JALR_FUNCT  6'b001001 // 9
`define SYSCALL_FUNCT 6'b001100 // 12
`define BREAK_FUNCT 6'b001101 // 13
`define MFHI_FUNCT  6'b010000 // 16
`define MTHI_FUNCT  6'b010001 // 17
`define MFLO_FUNCT  6'b010010 // 18
`define MTLO_FUNCT  6'b010011 // 19
`define MULT_FUNCT  6'b011000 // 24
`define MULTU_FUNCT 6'b011001 // 25
`define DIV_FUNCT   6'b011010 // 26
`define DIVU_FUNCT  6'b011011 // 27
`define ADD_FUNCT   6'b100000 // 32
`define ADDU_FUNCT  6'b100001 // 33
`define SUB_FUNCT   6'b100010 // 34
`define SUBU_FUNCT  6'b100011 // 35
`define AND_FUNCT   6'b100100 // 36
`define OR_FUNCT    6'b100101 // 37
`define XOR_FUNCT   6'b100110 // 38
`define SLT_FUNCT   6'b101010 // 42
`define SLTU_FUNCT  6'b101011 // 43

/* Memory Reference sizes */
`define BYTE_REF  2'b01
`define HW_REF    2'b10
`define W_REF     2'b11

module controller
(
  input[5:0] opcode,
  input[5:0] func,
  input[31:0] Instruction,
  
  output reg RegWrite,
  output reg[1:0] WBResultSelect,
  output reg MemWrite,
  output reg Branch,
  output reg Jump,
  output reg JumpR, /* Jump to address in Register */
  output [3:0] ALUControl,
  output reg ALUSrcB,
  output reg RegDst,
  output reg UpperImm_out,
  output reg [2:0] BHW, /* byte or halfword or word ? */
  output reg ImmSorU_out, /* Signed or Unsgined Immediate ? */
  output reg ALUComp_out, /*  One complement of ALU output (useful for inst 
like nor */
  output ShiftAmtVar_out, /* Whether shift amount comes from instruction 
or register */
  output [1:0] Shift_type_out, /* Choose shifter type from [Right | LEFT] 
[Logical | Arithmetic] */
  output reg Shifter_or_ALU_out, /* Choose Result between ALUoutput and 
Shifter output */
  output reg[1:0] MulDivRF, /* Choose input to hi/lo registers from Mul, Div, 
or RF */
  output reg hiEN, /* Enable(load) hi register */
  output reg loEN,	 /* Enable(load) lo register */
  output reg link, /* if link == 1 > Put pc+4 into ra */
  output reg undefinedEx, /* Undefined instruction Excption */
  output reg syscallEx, /* System call excpetion */
  output reg breakEx, /* Break expetion */
  output reg mfc0, /* get value from coprocessor 0 */
  output reg mtc0, /* Write enable Co-processor 0 registers */
  output reg[1:0] MemRefSize /* Zero of no mem ref, 1 for byte, 2 for hw, 3 
for w)*/
);

reg[3:0] ALUop;

always @*
begin
  RegWrite = 1'b0;
  WBResultSelect <= 2'b00;
  MemWrite <= 1'b0;
  Branch <= 1'b0;
  Jump <= 1'b0;
  JumpR <= 1'b0;
  ALUSrcB <= 1'b0;
  RegDst <= 1'b0;
  ALUop <= 4'b0000;
  UpperImm_out <= 1'b0;
  BHW <= 3'b000;
  ImmSorU_out <= 0;
  ALUComp_out <= 0;
  Shifter_or_ALU_out <= 0;
  MulDivRF <= 2'b11; /* Zero hi, lo registers */
  hiEN <= 1'b0;
  loEN <= 1'b0;
  link <= 1'b0;
  undefinedEx <= 1'b0;
  syscallEx <= 1'b0;
  breakEx <= 1'b0;
  mfc0 <= 1'b0;
  mtc0 <= 1'b0;
  MemRefSize = 2'b00; /* No memory reference */
  
  /* Every new instruction opcode should be added here */
  
  case (opcode)
    `RTYPE_OPCODE: /* R-Type */
      begin
        RegWrite = 1'b1;
        ALUop <= 4'b0010;
        RegDst <= 1'b1;
        
        if (func == `SLL_FUNCT || func == `SRL_FUNCT ||
          func == `SRA_FUNCT || func == `SLLV_FUNCT||
          func == `SRLV_FUNCT|| func == `SRAV_FUNCT) /* Shift Operation */
          Shifter_or_ALU_out <= 1;
        if (func == `JR_FUNCT)
        begin
          JumpR <= 1'b1;
          RegWrite = 1'b0;
          ALUop <= 4'b0000;
        end
        if (func == `JALR_FUNCT)
        begin
          JumpR <= 1'b1;
          RegWrite = 1'b1;
          ALUop <= 4'b0000;
          link <= 1'b1;
        end
      case(func)
        `MTHI_FUNCT : 
        begin
          RegWrite = 1'b0;  
          hiEN <= 1'b1;
          MulDivRF <= 2'b10;
        end
        `MTLO_FUNCT :
        begin
          RegWrite = 1'b0;  
          loEN <= 1'b1;
          MulDivRF <= 2'b10;
        end
        `MULT_FUNCT :
        begin
          RegWrite = 1'b0;
          hiEN <= 1'b1;
          loEN <= 1'b1;
          MulDivRF <= 2'b00;
        end
        `MULTU_FUNCT :
        begin
            RegWrite = 1'b0;
          hiEN <= 1'b1;
          loEN <= 1'b1;
          MulDivRF <= 2'b00;
        end
        `DIV_FUNCT :
        begin
            RegWrite = 1'b0;
          hiEN <= 1'b1;
          loEN <= 1'b1;
          MulDivRF <= 2'b01;
       end
          `DIVU_FUNCT : 
          begin
            RegWrite = 1'b0;
            hiEN <= 1'b1;
            loEN <= 1'b1;
            MulDivRF <= 2'b01;
          end
          `MFLO_FUNCT:
            WBResultSelect <= 2'b10;
          `MFHI_FUNCT:
            WBResultSelect <= 2'b11;
          `SYSCALL_FUNCT:
            syscallEx <= 1'b1;
          `BREAK_FUNCT:
            breakEx <= 1'b1;
      endcase
      
        end
      `ADDI_OPCODE:
      begin
        RegWrite = 1'b1;
        ALUSrcB <= 1'b1;
      end
      `ADDIU_OPCODE:
      begin
        RegWrite = 1'b1;
        ALUSrcB <= 1'b1;
      end
      `SLTI_OPCODE:
      begin
        RegWrite = 1'b1;
        ALUop <= 4'b100;
        ALUSrcB <= 1'b1;
      end
      `SLTIU_OPCODE:
      begin
        RegWrite = 1'b1;
        ALUop <= 4'b0010;
        ALUSrcB <= 1'b1;
        ImmSorU_out <= 1'b1;
      end
      `ANDI_OPCODE:
      begin
        RegWrite = 1'b1;
        ALUop <= 4'b0101;
        ALUSrcB <= 1'b1;
      end
      `ORI_OPCODE:
      begin
        RegWrite = 1'b1;
        ALUop <= 4'b0110;
        ALUSrcB <= 1'b1;
      end
      `XORI_OPCODE:
      begin
        RegWrite = 1'b1;
        ALUop <= 4'b0111;
        ALUSrcB <= 1'b1;
      end
      `MUL_OPCODE:
      begin
        RegWrite = 1'b1;
        ALUop <= 4'b1000;
        RegDst <= 1'b1;
      end
      `LUI_OPCODE: /* Load upper immediate */
      begin 
        UpperImm_out <= 1'b1;
        RegWrite = 1'b1;
        ALUSrcB <= 1'b1;
      end
      `LB_OPCODE: /* load signed byte */
      begin 
        RegWrite = 1'b1;
        WBResultSelect <= 2'b01;
        ALUSrcB <= 1'b1;
        BHW <= 3'b001;
        MemRefSize = 2'b01;
      end
      `LH_OPCODE: /* load signed halfword */
      begin 
        RegWrite = 1'b1;
        WBResultSelect <= 2'b01;
        ALUSrcB <= 1'b1;
        BHW <= 3'b010;
        MemRefSize = 2'b10;
      end
      `LW_OPCODE: /* load word */
      begin
        RegWrite = 1'b1;
        WBResultSelect <= 2'b01;
        ALUSrcB <= 1'b1;
        MemRefSize = 2'b11;
      end
      `LBU_OPCODE: /* load unsigned byte */
      begin 
        RegWrite = 1'b1;
        WBResultSelect <= 2'b01;
        ALUSrcB <= 1'b1;
        BHW <= 3'b011;
        MemRefSize = 2'b01;
      end
      `LHU_OPCODE: /* load unsigned byte */
      begin 
        RegWrite = 1'b1;
        WBResultSelect <= 2'b01;
        ALUSrcB <= 1'b1;
        BHW <= 3'b100;
        MemRefSize = 2'b10;
      end
      `SB_OPCODE:
      begin
        MemWrite <= 1'b1;
        ALUSrcB <= 1'b1;
        MemRefSize = 2'b01;
      end
      `SH_OPCODE:
      begin
        MemWrite <= 1'b1;
        ALUSrcB <= 1'b1;
        MemRefSize = 2'b10;
      end
      `SW_OPCODE: /* store */
      begin
        MemWrite <= 1'b1;
        ALUSrcB <= 1'b1;
        MemRefSize = 2'b11;
      end
      `BEQ_OPCODE,
      `BNE_OPCODE: /* branch if equale */
      begin 
        Branch <= 1'b1;
        ALUop <= 4'b0001;
      end
      `BLTZ_OPCODE, `BGEZ_OPCODE, `BLEZ_OPCODE, `BGTZ_OPCODE:
      begin
        Branch <= 1'b1; 
      end
      `JMP_OPCODE:
        Jump <= 1'b1;
      `JAL_OPCODE:
      begin
        Jump <= 1'b1;
        link <= 1'b1;
        RegWrite = 1'b1;
      end
      `CP0_OPCODE:
      begin
        if(Instruction[25:21] == 5'd0) //mfc0
        begin
          mfc0 <= 1'b1;
          RegWrite = 1'b1;
          RegDst <= 1'b0;
        end
        else if(Instruction[25:21] == 5'd4) //mtc0
        begin
          mtc0 <= 1'b1;
        end
    end
      default: /* Undefined instruction exception */
      begin
        undefinedEx <= 1'b1;
      end
  endcase
end

alu_decoder dec
(
.ALUop(ALUop),
.Funct(func),
.ALUControl(ALUControl)
);

shifter_decoder shift_dec
(
.Funct(func),
.Shift_type(Shift_type_out),
.ShiftAmtVar_out(ShiftAmtVar_out)
);

endmodule
