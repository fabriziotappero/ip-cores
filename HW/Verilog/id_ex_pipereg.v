//////////////////////////////////////////////////////////////////
//                                                              //
//  ID/EX pipeline register                                     //
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//  Pipeline register lies between decode and execute stages    //
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

module id_ex_pipereg
#
(
  parameter N=32,
  parameter M=5
) 
(
  input clk,
  input reset,
  input en,
  input[N-1:0] read_value1_in,
  input[N-1:0] read_value2_in,
  input[M-1:0] Rs_in,
  input[M-1:0] Rt_in,
  input[M-1:0] Rd_in,
  input[N-1:0] SignImm_in,
  input[N-1:0] PCplus4_in,

  input[N-1:0] IR_in,
  input[5:0] opcode_in,
  input RegWrite_in,
  input[1:0] WBResultSelect_in,
  input MemWrite_in,
  input Branch_in,
  input Jump_in,
  input JumpR_in,
  input[3:0] ALUControl_in,
  input ALUSrcB_in,
  input RegDst_in,
  input UpperImm_in,
  input[2:0] BHW_in, /* byte or halfword or word ? */
  input ALUComp_in, /* Complement the ALU output */
  input[1:0] Shift_type_in,
  input ShiftAmtVar_in,
  input Shifter_or_ALU_in,
  input[1:0] MulDivRF_in,
  input hiEN_in,
  input loEN_in,
  input link_in,

  /* Coprocessor0 and exceptions signals */
  input undefinedEx_in,
  input breakEx_in,
  input divbyZero_in,
  input syscallEx_in,

  input[M-1:0] CP0_wa_in,
  input[M-1:0] CP0_ra_in,
  input[1:0] CP0_Inst_in,
  input[N-1:0] CP0_dout_in,
  input[N-1:0] CP0_din_in,

  /* Memory Reference size */
  input[1:0] MemRefSize_in,

  output[N-1:0] read_value1_out,
  output[N-1:0] read_value2_out,
  output[M-1:0] Rs_out,
  output[M-1:0] Rt_out,
  output[M-1:0] Rd_out,
  output[N-1:0] SignImm_out,
  output[N-1:0] PCplus4_out,

  output RegWrite_out,
  output[1:0] WBResultSelect_out,
  output MemWrite_out,
  output Branch_out,
  output Jump_out,
  output JumpR_out,
  output[3:0] ALUControl_out,
  output ALUSrcB_out,
  output RegDst_out,
  output UpperImm_out,
  output[2:0] BHW_out, /* byte or halfword or word ? */	
  output ALUComp_out,
  output[1:0] Shift_type_out,
  output ShiftAmtVar_out,
  output Shifter_or_ALU_out,
  output[1:0] MulDivRF_out,
  output hiEN_out,
  output loEN_out,
  output [5:0] opcode_out,
  output[N-1:0] IR_out,
  output link_out,

  /* Coprocessor0 and exceptions signals */
  output undefinedEx_out,
  output breakEx_out,
  output divbyZero_out,
  output syscallEx_out,

  output[M-1:0] CP0_wa_out,
  output[M-1:0] CP0_ra_out,
  output[1:0] CP0_Inst_out,
  output[N-1:0] CP0_dout_out,
  output[N-1:0] CP0_din_out,

  output[1:0] MemRefSize_out
   
);

/* Instruction register */
register IR
(
  .clk(clk), .reset(reset), .en(en),
  .d(IR_in),
  .q(IR_out)
);

/* Opcode */
register #(6)
opcode
(
  .clk(clk), .reset(reset), .en(en),
  .d(opcode_in),
  .q(opcode_out)
);

/* data values registers */
register rd1
(
  .clk(clk), .reset(reset), .en(en),
  .d(read_value1_in),
  .q(read_value1_out)
);

register rd2
(
  .clk(clk), .reset(reset), .en(en),
  .d(read_value2_in),
  .q(read_value2_out)
);

/* Rs, Rt and Rd addresses */
register #(5) Rs
(
  .clk(clk), .reset(reset), .en(en),
  .d(Rs_in),
  .q(Rs_out)
);

register #(5) 
Rt
(
  .clk(clk), .reset(reset), .en(en),
  .d(Rt_in),
  .q(Rt_out)
);

register #(5)
Rd
(
  .clk(clk), .reset(reset), .en(en),
  .d(Rd_in),
  .q(Rd_out)
);

/* Sign Immediate value */
register sign_imm
(
  .clk(clk), .reset(reset), .en(en),
  .d(SignImm_in),
  .q(SignImm_out)
);

/* PC + 4 register */
register PCplus4
(
  .clk(clk), .reset(reset), .en(en),
  .d(PCplus4_in),
  .q(PCplus4_out)
);

/* Control Signal */
register #(1) 
RegWrite
(
  .clk(clk), .reset(reset), .en(en),
  .d(RegWrite_in), 
  .q(RegWrite_out)
);

register #(2)
WBResultSelect
(
  .clk(clk), .reset(reset), .en(en),
  .d(WBResultSelect_in), 
  .q(WBResultSelect_out)
);

register #(1) 
MemWrite
(
  .clk(clk), .reset(reset), .en(en),
  .d(MemWrite_in),
  .q(MemWrite_out)
);

register #(1)
Branch
(
  .clk(clk), .reset(reset), .en(en),
  .d(Branch_in),
  .q(Branch_out)
);

register #(1)
Jump
(
  .clk(clk), .reset(reset), .en(en),
  .d(Jump_in),
  .q(Jump_out)
);

register #(1) 
JumpR
(
  .clk(clk), .reset(reset), .en(en),
  .d(JumpR_in),
  .q(JumpR_out)
);

register #(1)
link
(
  .clk(clk), .reset(reset), .en(en),
  .d(link_in),
  .q(link_out)
);

register #(4)
ALUControl
(
  .clk(clk), .reset(reset), .en(en),
  .d(ALUControl_in), 
  .q(ALUControl_out)
);

register #(1) 
ALUSrcB
(
  .clk(clk), .reset(reset), .en(en),
  .d(ALUSrcB_in),
  .q(ALUSrcB_out)
);

register #(1) 
RegDst
(
  .clk(clk), .reset(reset), .en(en),
  .d(RegDst_in),
  .q(RegDst_out)
);

register #(1)
UpperImm
(
  .clk(clk), .reset(reset), .en(en),
  .d(UpperImm_in),
  .q(UpperImm_out)
);

register #(3)
BHW
(
  .clk(clk), .reset(reset), .en(en),
  .d(BHW_in),
  .q(BHW_out)
);

register #(1) 
ALUComp 
(
  .clk(clk), .reset(reset), .en(en),
  .d(ALUComp_in),
  .q(ALUComp_out)
);

register #(2) 
Shift_type
(
  .clk(clk), .reset(reset), .en(en),
  .d(Shift_type_in), 
  .q(Shift_type_out)
);

register #(1)
ShiftAmtVar
(
  .clk(clk), .reset(reset), .en(en),
  .d(ShiftAmtVar_in), 
  .q(ShiftAmtVar_out)
);

register #(1)
Shifter_or_ALU
(
  .clk(clk), .reset(reset), .en(en),
  .d(Shifter_or_ALU_in), 
  .q(Shifter_or_ALU_out)
);

register #(2) 
MulDivRF
(
  .clk(clk), .reset(reset), .en(en), 
  .d(MulDivRF_in),
  .q(MulDivRF_out)
);

register #(1) 
hiEN
(
  .clk(clk), .reset(reset), .en(en),
  .d(hiEN_in),
  .q(hiEN_out)
);

register #(1)
loEN
(
  .clk(clk), .reset(reset), .en(en), 
  .d(loEN_in),
  .q(loEN_out)
);


/* Coprocessor zero related */
register #(1) 
undefinedEx
(
  .clk(clk), .reset(reset), .en(en),
  .d(undefinedEx_in), 
  .q(undefinedEx_out)
);

register #(1) 
breakEx
(
  .clk(clk), .reset(reset), .en(en),
  .d(breakEx_in),
  .q(breakEx_out)
);

register #(1) 
divbyZero
(
  .clk(clk), .reset(reset), .en(en),
  .d(divbyZero_in), 
  .q(divbyZero_out)
);

register #(1)
syscallEx
(
  .clk(clk), .reset(reset), .en(en),
  .d(syscallEx_in), 
  .q(syscallEx_out)
);

register #(5)
CP0_wa
(
  .clk(clk), .reset(reset), .en(en),
  .d(CP0_wa_in),
  .q(CP0_wa_out)
);

register #(5) 
CP0_ra
(
  .clk(clk), .reset(reset), .en(en),
  .d(CP0_ra_in),
  .q(CP0_ra_out)
);

register #(2)
CP0_Inst
(
  .clk(clk), .reset(reset), .en(en),
  .d(CP0_Inst_in),
  .q(CP0_Inst_out)
);

register CP0_dout
(
  .clk(clk), .reset(reset), .en(en),
  .d(CP0_dout_in),
  .q(CP0_dout_out)
);

register CP0_din
(
  .clk(clk), .reset(reset), .en(en),
  .d(CP0_din_in),
  .q(CP0_din_out)
);

/* Memory referece sizes */
register #(2) 
MemRefSize
(
  .clk(clk), .reset(reset), .en(en),
  .d(MemRefSize_in), 
  .q(MemRefSize_out)
);

endmodule
