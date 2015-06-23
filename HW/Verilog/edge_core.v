//////////////////////////////////////////////////////////////////
//                                                              //
//  Edge core                                                   //
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//  The main top module for Edge core. It contains the whole    //
//  data path and pipeline stuff.
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

`define BLTZ_OPCODE	6'b000001 // 1
`define BGEZ_OPCODE	6'b000001 // 1
`define JMP_OPCODE	6'b000010 // 2
`define JAL_OPCODE 	6'b000011 // 3
`define BEQ_OPCODE	6'b000100 // 4
`define BNE_OPCODE	6'b000101 // 5
`define BLEZ_OPCODE	6'b000110 // 6
`define BGTZ_OPCODE	6'b000111 // 7

module Edge_Core
#
(
  parameter N=32, M=5
)
(
  input clk,
  input reset,
  
  /* Instruction Memory */
  output[N-1:0] pc_toIMemory,
  input[N-1:0] instr_fromIMemory,
  
  /* Data Memory */
  output[N-1:0] Address_toDMemory, 
  output[N-1:0] WriteData_toDMemory,
  output MemWrite_toDMemory, /* Write Enable signal to data memory */
  input[N-1:0] RD_fromDMemory, /* Data rereived from data memory */
  output[1:0] MemRefSize, /* Zero Byte, Half word, or Word reference */
  input StallDataMemory, // Stall signal from data memory (Technology dependent)
  
  /* Interrupts */
  output CP0_TimerIntMatch,
  input IO_TimerIntReset
);


/******************************* PC Wires **************************************
*
*
*
*******************************************************************************/
wire pc_en;
wire PC_STALL_HAZARD;
wire[N-1:0] pc_current;
wire[N-1:0] pc_next;
wire[2:0] PCSrcM; /* PC src signal (from PCplus4 or from branch) */
wire PC_RESET;
wire PC_RESET_HAZARD;

/******************************* IF/ID Wires ***********************************
*
*
*
*******************************************************************************/
wire IF_ID_EN;
wire IF_ID_EN_GLOBAL;
wire IF_ID_STALL_HAZARD;

wire IF_ID_RESET; /* Final reset value */
wire IF_ID_RESET_GLOBAL; /* Blobal reset from the processor */
wire IF_ID_RESET_HAZARD; /* Reset due to hazard unit (flush) */
wire IF_ID_RESET_INT; /* Reset due to interrupt taken */
reg IF_ID_RESET_FINAL;

wire[N-1:0] IR_in;
wire[N-1:0] IR_out;
wire[N-1:0] PCplus4F;

/* Coprocessor0 and exceptions signals */
wire undefinedExD;
wire breakExD;
wire divbyZeroExD;
wire syscallExD;

wire[M-1:0] CP0_waD;
wire[M-1:0] CP0_raD;
wire[1:0] CP0_InstD;
wire[N-1:0] CP0_doutD;
wire[N-1:0] CP0_dinD;
wire mfc0D; /* Signal to MUX to choose register value from Coprocessor 0 */
wire[M-1:0] ra1D;
wire[1:0] MemRefSizeD;

/******************************** ID/EX Wires **********************************
*
*
*******************************************************************************/
wire ID_EX_EN;
wire ID_EX_RESET;
wire ID_EX_RESET_GLOBAL; 
wire ID_EX_RESET_HAZARD;
wire ID_EX_RESET_INT; 
wire ID_EX_RESET_FINAL;
wire ID_EX_STALL_HAZARD;
wire[M-1:0] read_reg1_in;
wire[M-1:0] read_reg2_in;
wire[M-1:0] write_reg1_in;
wire[N-1:0] read_value1_in;
wire[N-1:0] read_value2_in;
wire[M-1:0] Rt_in;
wire[M-1:0] Rd_in;
wire[N-1:0] SignImm_in;
wire[N-1:0] PCplus4D;
wire linkD;

wire RegWriteD;
wire[1:0] WBResultSelectD;
wire MemWriteD;
wire BranchD;
wire JumpD;
wire JumpRD;
wire[3:0] ALUControlD;
wire ALUSrcBD;
wire RegDstD;
wire ALUCompD;
wire[1:0] Shift_typeD;
wire ShiftAmtVarD;
wire Shifter_or_ALUD;
wire[1:0] MulDivRFD; /* Control Signal input to mux to choose between mul, div, 
rf wires */
wire hiEND, loEND; /* Enable load signal for lo and hi registers */
wire [5:0] opcodeD;
wire[N-1:0] IR_D; 
wire[N-1:0] PC_D;
wire isExW;
wire[N-1:0] rd2D; /* input of value2 to ID/EX register */
wire[M-1:0] read_reg1_out;
wire[M-1:0] read_reg2_out;
wire[M-1:0] write_reg1_out;
wire[N-1:0] read_value1_out;
wire[N-1:0] read_value2_out;
wire[M-1:0] Rs_out;
wire[M-1:0] Rt_out;
wire[M-1:0] Rd_out;
wire[N-1:0] SignImm_out;

/******************************* EX/MEM Wires **********************************
*
*
*******************************************************************************/
wire EX_MEM_EN;
wire EX_MEM_RESET;
wire EX_MEM_RESET_GLOBAL;
wire EX_MEM_RESET_INT;
wire EX_MEM_STALL_HAZARD;
wire[N-1:0] ALUoutE;
wire[N-1:0] PCBranchE;
wire[M-1:0] WriteRegE;

wire RegWriteE;
wire[1:0] WBResultSelectE;
wire MemWriteE;
wire BranchE;
wire JumpE;
wire JumpRE;
wire[3:0] ALUControlE;
wire ALUSrcBE;
wire RegDstE;
wire[N-1:0] SrcAE;
wire[N-1:0] SrcBE;
wire[N-1:0] IR_E;
wire[1:0] ForwardAE, ForwardBE; /* Forward signals coming from hazard unit */
wire[N-1:0] mux_ForwardDataAE, mux_ForwardDataBE;
wire[N-1:0] ALUoutEE;
wire UpperImmD;
wire UpperImmE;
wire ALUCompE;
wire[1:0] Shift_typeE;
wire ShiftAmtVarE;
wire Shifter_or_ALUE;
wire[N-1:0] Shift_ResultE;
wire[N-1:0] EX_Result;
wire[1:0] MulDivRFE; /* Control Signal input to mux to choose between mul, div,
rf wires */
wire hiENE, loENE; /* Enable load signal for lo and hi registers */
wire [5:0] opcodeE;
wire [N-1:0] JTA_E; /* Jump target address */
wire linkE;
wire[N-1:0] PCplus4E;
wire[1:0] MemRefSizeE;
wire zeroE;
wire SignE;

/* Coprocessor0 and exceptions signals */
wire undefinedExE;
wire breakExE;
wire divbyZeroExE;
wire syscallExE;

wire[M-1:0] CP0_waE;
wire[M-1:0] CP0_raE;
wire[1:0] CP0_InstE;
wire[N-1:0] CP0_doutE;
wire[N-1:0] CP0_dinE;

wire[N-1:0] shifted_imm_2;
wire[N-1:0] ALUoutCompE;
wire[4:0] ShiftAmtE;

/* Output wires from Mul/Div units */
wire[N-1:0] hiIn, loIn, hiE, loE;
wire[N-1:0] hiMulE, loMulE, hiDivE, loDivE;

/********************************** MEM/WB Wires *******************************
*
*
*******************************************************************************/

wire zeroM;
wire SignM;

wire[N-1:0] ALUoutM;
wire[N-1:0] WriteDataM;
wire[N-1:0] PCBranchM;
wire[M-1:0] WriteRegM;
wire RegWriteM;
wire[1:0] WBResultSelectM;
wire MemWriteM;
wire BranchM;
wire JumpM;
wire JumpRM;
wire[N-1:0] ReadDataM;
wire[N-1:0] hiM, loM;
wire [5:0] opcodeM;
wire [N-1:0] JTA_M; /* Jump target address */
wire[N-1:0] PCplus4M;
wire linkM;

/* Coprocessor0 and exceptions signals */
wire undefinedExM;
wire breakExM;
wire divbyZeroM;
wire syscallExM;

wire[M-1:0] CP0_waM;
wire[M-1:0] CP0_raM;
wire[1:0] CP0_InstM;
wire[N-1:0] CP0_doutM;
wire[N-1:0] CP0_dinM;   

wire[1:0] MemRefSizeM;

/****************************** WB Wires ***************************************
*
*
*******************************************************************************/
wire MEM_WB_EN;
wire MEM_WB_STALL_HAZARD;
wire[N-1:0] ReadDataW;
wire[N-1:0] ALUoutW;
wire[M-1:0] WriteRegW;
wire RegWriteW;
wire[1:0] WBResultSelectW;
wire[N-1:0] hiW, loW;
wire[N-1:0] PCplus4W;
wire[N-1:0] ResultW; /* Result to be written in RF */
wire linkW;
wire[N-1:0] ResultWWW;
wire[M-1:0] WriteRegWW;

/* Coprocessor0 and exceptions signals */
wire undefinedExW;
wire breakExW;
wire divbyZeroExW;
wire syscallExW;

wire[M-1:0] CP0_waW;
wire[M-1:0] CP0_raW;
wire[1:0] CP0_InstW;
wire[N-1:0] CP0_doutW;
wire[N-1:0] CP0_dinW;
wire[N-1:0] ImmSigned, ImmUSigned;
wire ImmSorU;

/* output of the 3-way mux (lw, lb, lh) */
wire[N-1:0] ResultWW, ResultSHW, ResultSB, ResultUHW, ResultUB;
/* Selection bits for ResultWW mux (comes from decoder) */
wire[2:0] bhwD, bhwE, bhwM, bhwW;

/****************************** Coprocessor0 Wires *****************************
*
*
*******************************************************************************/
wire[1:0] CP0_Inst;
wire[N-1:0] CP0_Cause;
wire[N-1:0] CP0_EPC;
wire[M-1:0] CP0_wa, CP0_ra;
wire[N-1:0] CP0_wd;
wire[N-1:0] CP0_rd;
wire[N-1:0] PC_W;
wire CP0_TimerIntMatch;

/****************************** Data path **************************************
*
*
*******************************************************************************/

/* Hazard Control Unit */
hazard_unit hazard_unit
(
  .CLK(clk),
  .rsE(Rs_out), .rtE(Rt_out),
  .rsD(IR_out[25:21]), .rtD(IR_out[20:16]),
  .DestRegE(WriteRegE),
  .DestRegM(WriteRegM), .DestRegW(WriteRegWW),
  .RegWriteE(RegWriteE),
  .RegWriteM(RegWriteM), .RegWriteW(RegWriteW),
  .loadE((WBResultSelectE)== 2'b01),
  .PCSrcM(PCSrcM),
  .MemWriteD(MemWriteD),
  .MemWriteE(MemWriteE),
  .StallF(PC_STALL_HAZARD),
  .StallD(IF_ID_STALL_HAZARD),
  .StallE(ID_EX_STALL_HAZARD),
  .StallM(EX_MEM_STALL_HAZARD),
  .StallW(MEM_WB_STALL_HAZARD),
  .FlushF(PC_RESET_HAZARD),
  .FlushD(IF_ID_RESET_HAZARD),
  .FlushE(ID_EX_RESET_HAZARD),
  .FlushM(EX_MEM_RESET_HAZARD),
  .ForwardAE(ForwardAE),
  .ForwardBE(ForwardBE),
  .StallDataMemory(StallDataMemory)
);


assign pc_en = (PCSrcM == 3'b000)? 
                ((~PC_STALL_HAZARD) & (~StallDataMemory))
                :
                1'b1 ;

assign IF_ID_RESET_GLOBAL = reset;
assign IF_ID_RESET_INT = 1'b0;

assign ID_EX_RESET_GLOBAL = reset;
assign ID_EX_RESET_INT = 1'b0;

assign EX_MEM_RESET_GLOBAL = reset;
assign EX_MEM_RESET_INT = 1'b0;

assign IF_ID_EN = (~IF_ID_STALL_HAZARD) & (~StallDataMemory);
assign ID_EX_EN = (~ID_EX_STALL_HAZARD) & (~StallDataMemory);
assign EX_MEM_EN = /*(~EX_MEM_STALL_HAZARD) &*/ (~StallDataMemory);
assign MEM_WB_EN = /*(~MEM_WB_STALL_HAZARD)*/ 1'b1;

assign PC_RESET = (reset);
assign IF_ID_RESET = 
  (IF_ID_RESET_GLOBAL |
   IF_ID_RESET_HAZARD |
   IF_ID_RESET_INT
  ) ?
    1'b1
  :
    1'b0;
    
assign ID_EX_RESET = 
  (ID_EX_RESET_GLOBAL |
   ID_EX_RESET_HAZARD |
   ID_EX_RESET_INT
   ) ?
    1'b1 
   :
    1'b0;
   
assign EX_MEM_RESET = 
  (EX_MEM_RESET_GLOBAL |
   EX_MEM_RESET_HAZARD |
   EX_MEM_RESET_INT
   ) ?
    1'b1 
   :
    1'b0;

assign MemRefSize = MemRefSizeM;

assign PC_W = PCplus4W - 4;

/* Excepetion detection and CP0 interaction */

assign isExW = 
  (undefinedExW ||
   breakExW     ||
   divbyZeroExW ||
   syscallExW
   ) ?
    1'b1
   :
    1'b0;

assign CP0_Cause = 
  (undefinedExW) ?
    32'h00000028 
  :
    (breakExW | divbyZeroExW)?
      32'h00000024 
    :
      (syscallExW)  ?
        32'h00000020 
      :
        32'h00000000;
                   
assign CP0_EPC = PC_W;

assign CP0_Inst = (isExW)? 2'd1 : CP0_InstW;

assign CP0_ra = IR_out[15:11];

assign CP0_waD = IR_out[15:11];
 
assign CP0_wa = CP0_waW;

assign CP0_InstD = (mtc0D)? 2'd3 : 2'd0;

assign CP0_din = CP0_dinW;

assign CP0_dinW = ResultWWW;

/* Coprocessor 0 */
Coprocessor0 cp0
(
  .clk(clk),
  .EPC(CP0_EPC),
  .Cause(CP0_Cause),
  .instruction(CP0_Inst),
  .ra(CP0_ra),
  .wa(CP0_wa),
  .WriteData(CP0_dinW),
  .IO_TimerIntReset(IO_TimerIntReset),
  .ReadData(CP0_rd),
  .TimerIntMatch(CP0_TimerIntMatch)
);

/* Mux signal to determine PC source at from memory pipleline stage */
assign PCSrcM = 
  ((BranchM == 1'b0 && JumpM == 1'b0 && JumpRM == 1'b0)? 
      ((isExW)? 3'b100 : 3'b000) /* Check for excpetions */
    : /* not a branch or jump */
      ((JumpM) ?
      /* Jump type */
        3'b010
      :
        ((JumpRM) ? 
        /* Jump Register */
          3'b011
        : 
          ((BranchM) ?
          /* Branch type */
            ((opcodeM == `BLTZ_OPCODE && SignM)? 
            ((Rt_out == 5'd0)? 3'b001 : 3'b000) : 
            (opcodeE == `BGEZ_OPCODE && SignM == 1'b0)?
            ((Rt_out == 5'd1)? 3'b001 : 3'b000) :
            (opcodeM == `BEQ_OPCODE && zeroM)? 3'b001 :
            (opcodeM == `BNE_OPCODE && zeroM == 1'b0)? 3'b001 :
            (opcodeM == `BLEZ_OPCODE && (SignM == 1 || zeroM == 0))? 3'b001 :
            (opcodeM == `BGTZ_OPCODE && SignM == 0 && zeroM == 0)? 3'b001 : 
            3'b000)
            :3'b000))));

assign pc_next =
  (reset == 1)? 32'd0          :
  (PCSrcM === 0)? PCplus4F     : 
  (PCSrcM === 1)? PCBranchM    :
  (PCSrcM === 2)? JTA_M        :
  (PCSrcM === 3)? ALUoutM      :
  (PCSrcM === 4)? 32'h80000180 : PCplus4F;
          
assign pc_toIMemory = pc_current;

/* PC + 4 adder at fetch pipeline stage */
adder pcplus4 
(
  .in1(pc_current),
  .in2(32'd4),
  .cin(1'b0),
  .out(PCplus4F)
);

/****************************** PC Register ************************************
*
*
*******************************************************************************/
register pc
(
  .clk(clk),
  .reset(PC_RESET),
  .en(pc_en),
  .d(pc_next),
  .q(pc_current)
);

/****************************** IF/ID Register *********************************
*
*
*******************************************************************************/
if_id_pipereg IF_ID_REG
(
  .clk(clk),
  .reset(IF_ID_RESET),
  .en(IF_ID_EN),
  .IR_in(instr_fromIMemory),
  .IR_out(IR_out),
  .PCplus4_in(PCplus4F),
  .PCplus4_out(PCplus4D),
  .PC_in(pc_current),
  .PC_out(PC_D)
);

/* Decode or controller */
controller ctrl
(
  .opcode(IR_out[31:26]),
  .func(IR_out[5:0]),
  .Instruction(IR_out),

  .RegWrite(RegWriteD),
  .WBResultSelect(WBResultSelectD),
  .MemWrite(MemWriteD),
  .Branch(BranchD),
  .Jump(JumpD),
  .JumpR(JumpRD),
  .ALUControl(ALUControlD),
  .ALUSrcB(ALUSrcBD),
  .RegDst(RegDstD),
  .UpperImm_out(UpperImmD),
  .BHW(bhwD),
  .ImmSorU_out(ImmSorU),
  .ALUComp_out(ALUCompD),
  .ShiftAmtVar_out(ShiftAmtVarD),
  .Shift_type_out(Shift_typeD),
  .Shifter_or_ALU_out(Shifter_or_ALUD),
  .MulDivRF(MulDivRFD),
  .hiEN(hiEND),
  .loEN(loEND),
  .link(linkD),
  .undefinedEx(undefinedExD),
  .syscallEx(syscallExD),
  .breakEx(breakExD),
  .mfc0(mfc0D),
  .mtc0(mtc0D),
  .MemRefSize(MemRefSizeD)
);

/* Check divide by Zero Exception */
assign divbyZeroExD = 
  (IR_out[31:26] == 0 && 
  (IR_out[5:0] == 26  || IR_out[5:0] == 27)
  ) ?
    1'b1
  :
    1'b0;
    
/* mux to choose between lb, lh and lw signed extended */
sign_extend #(32, 8) 
s_extend_byte
(
  .in(ResultW[7:0]),
  .out(ResultSB)
);

sign_extend #(32, 16)
s_extend_halfWord
(
  .in(ResultW[15:0]),
  .out(ResultSHW)
);

/* zero extend for lbu, lhu */
zero_extend #(32, 8)
z_extend_byte
(
  .in(ResultW[7:0]),
  .out(ResultUB)
);

zero_extend #(32, 16)
z_extend_halfWord
(
.in(ResultW[15:0]),
.out(ResultUHW)
);

/* bhw -> [S|U] byte or halfword or word */
mux_WBResult WBResult
(
  .Word(ResultW),
  .SByte(ResultSB), 
  .SHWord(ResultSHW),
  .UByte(ResultUB),
  .UHWord(ResultUHW),
  .s(bhwW),
  .WBResult(ResultWW)
);

assign WriteRegWW = (linkW)? 5'd31 : WriteRegW;
assign ResultWWW = (linkW)? PCplus4W : ResultWW;

/* Workaroud for mtc0 instruction */
assign ra1D = (mtc0D)? 5'd0 : IR_out[25:21];

/****** register file *********/
regfile rf(
  .clk(clk),
  .reset(reset),
  .ra1(ra1D),
  .ra2(IR_out[20:16]),
  .wa3(WriteRegWW),
  .we3(RegWriteW),
  .wd3(ResultWWW),
  .rd1(read_value1_in),
  .rd2(read_value2_in)
);

sign_extend sign_ex_unit
(
  .in(IR_out[15:0]),
  .out(ImmSigned)
);

zero_extend #(32, 16)
zero_ex_unit
(
  .in(IR_out[15:0]),
  .out(ImmUSigned)
);

/* Choose signed or unsgined immediate */
mux2 Imm_Signed_or_UnSgined
(
  .in1(ImmSigned),
  .in2(ImmUSigned),
  .s(ImmSorU),
  .out(SignImm_in)
);

/* Choose value2 from rf or CP0 */
assign rd2D = (mfc0D)? CP0_rd : read_value2_in;

/****************************** ID/EX Register *********************************
*
*
*******************************************************************************/

id_ex_pipereg ID_EX_REG
(
  .clk(clk),
  .reset(ID_EX_RESET),
  .en(ID_EX_EN),
  .IR_in(IR_out),
  .opcode_in(IR_out[31:26]),
  .read_value1_in(read_value1_in),
  .read_value2_in(rd2D),
  .Rs_in(IR_out[25:21]),
  .Rt_in(IR_out[20:16]),
  .Rd_in(IR_out[15:11]),
  .SignImm_in(SignImm_in),
  .PCplus4_in(PCplus4D),
  .RegWrite_in(RegWriteD),
  .WBResultSelect_in(WBResultSelectD),
  .MemWrite_in(MemWriteD),
  .Branch_in(BranchD),
  .Jump_in(JumpD),
  .JumpR_in(JumpRD),
  .ALUControl_in(ALUControlD),
  .ALUSrcB_in(ALUSrcBD),
  .RegDst_in(RegDstD),
  .UpperImm_in(UpperImmD),
  .BHW_in(bhwD),
  .ALUComp_in(ALUCompD),
  .Shift_type_in(Shift_typeD),
  .ShiftAmtVar_in(ShiftAmtVarD),
  .Shifter_or_ALU_in(Shifter_or_ALUD),
  .MulDivRF_in(MulDivRFD),
  .hiEN_in(hiEND),
  .loEN_in(loEND),
  .link_in(linkD),
  .undefinedEx_in(undefinedExD),
  .breakEx_in(breakExD),
  .divbyZero_in(divbyZeroExD),
  .syscallEx_in(syscallExD),
  .CP0_wa_in(CP0_waD),
  .CP0_ra_in(CP0_raD),
  .CP0_Inst_in(CP0_InstD),
  .CP0_dout_in(CP0_doutD),
  .CP0_din_in(CP0_dinD),
  .MemRefSize_in(MemRefSizeD),

  .read_value1_out(read_value1_out),
  .read_value2_out(read_value2_out),
  .Rs_out(Rs_out),
  .Rt_out(Rt_out),
  .Rd_out(Rd_out),
  .SignImm_out(SignImm_out),
  .PCplus4_out(PCplus4E),

  .RegWrite_out(RegWriteE),
  .WBResultSelect_out(WBResultSelectE),
  .MemWrite_out(MemWriteE),
  .Branch_out(BranchE),
  .Jump_out(JumpE),
  .JumpR_out(JumpRE),
  .ALUControl_out(ALUControlE),
  .ALUSrcB_out(ALUSrcBE),
  .RegDst_out(RegDstE),
  .UpperImm_out(UpperImmE),
  .BHW_out(bhwE),
  .ALUComp_out(ALUCompE),
  .Shift_type_out(Shift_typeE),
  .ShiftAmtVar_out(ShiftAmtVarE),
  .Shifter_or_ALU_out(Shifter_or_ALUE),
  .MulDivRF_out(MulDivRFE),
  .hiEN_out(hiENE),
  .loEN_out(loENE),
  .opcode_out(opcodeE),
  .IR_out(IR_E),
  .link_out(linkE),
  .undefinedEx_out(undefinedExE),
  .breakEx_out(breakExE),
  .divbyZero_out(divbyZeroExE),
  .syscallEx_out(syscallExE),
  .CP0_wa_out(CP0_waE),
  .CP0_ra_out(CP0_raE),
  .CP0_Inst_out(CP0_InstE),
  .CP0_dout_out(CP0_doutE),
  .CP0_din_out(CP0_dinE),
  .MemRefSize_out(MemRefSizeE)
);

/* MUX to choose register destination address */
mux2 #(5)
Rt_or_Rd
(
  .in1(Rt_out),
  .in2(Rd_out),
  .s(RegDstE),
  .out(WriteRegE)
);

/* Mux inputs :
    > From registe  r file
    > Forwarded from memory stage
    > Forwarded from WB stage
  Mux outputs
    > to ALU src A stage.
*/
assign mux_ForwardDataAE = (ForwardAE == 2'b00) ? 
  /* No forwarding SrcB coming from reg file */
    (read_value1_out) /* ForwardAE True part */
  : /* Hazard Detected and Data should be fowarded. Else part of ForwardAE*/
    (
      (ForwardAE == 2'b01)? 
        ResultWWW /* Data forwarded from WB stage */
      :
        (ForwardAE == 2'b10)? 
          ALUoutM  /* Data forwarded from Memory stage */
        :
          read_value1_out /* No forwarding : fill this to avoid generating a 
latch*/
    );

/* Mux inputs :
    > From register file
    > Forwarded from memory stage
    > Forwarded from WB stage
  Mux output
    > to ALU src B stage.
*/
assign mux_ForwardDataBE = (ForwardBE == 2'b00) ? 
  /* No forwarding SrcB coming from reg file */
    (read_value2_out) /* ForwardAE True part */
  : /* Hazard Detected and Data should be fowarded. Else part of ForwardAE*/
    (
      (ForwardBE == 2'b01)? 
        ResultWWW /* Data forwarded from WB stage */
      :
        (ForwardBE == 2'b10)? 
          ALUoutM  /* Data forwarded from Memory stage */
        :
          read_value2_out /* No forwarding : fill this to avoid generating a 
  latch*/
    );

  
/* SrcB to ALU whether from mux_ForwardDataE or signImmediate */
mux2 Rd2_or_SignImm
(
  .in1(mux_ForwardDataBE),
  .in2(SignImm_out),
  .s(ALUSrcBE),
  .out(SrcBE)
);

/* Multiplication unit */
mult_unit mult_unit
(
  .a(mux_ForwardDataAE),
  .b(SrcBE),
  .hi(hiMulE),
  .lo(loMulE)
);

/* Division unit */
div_unit div_unit
(
  .a(mux_ForwardDataAE),
  .b(SrcBE),
  .res(loDivE),
  .rem(hiDivE)
);

assign hiIn = 
  (MulDivRFE == 2'b00)? hiMulE :
  (MulDivRFE == 2'b01)? hiDivE :
  (MulDivRFE == 2'b10)? read_value1_out : 32'd0;
				  
assign loIn = 
  (MulDivRFE === 2'b00)? loMulE :
  (MulDivRFE === 2'b01)? loDivE :
  (MulDivRFE === 2'b10)? read_value1_out : 32'd0;

/* ALU */
alu alu
(
  .a(mux_ForwardDataAE),
  .b(SrcBE), 
  .f(ALUControlE),
  .y(ALUoutE), .zero(zeroE), 
  .sign(SignE)
);

/* Sign flag */
assign SignE = ALUoutE[N-1];

/* Shifter */
/* Choose Shift amount from instruction encoding or register */
mux2 #(5)
shamt_reg_or_inst
(
  .in1(SignImm_out[10:6]),
  .in2(read_value1_out[4:0]),
  .s(ShiftAmtVarE),
  .out(ShiftAmtE)
);

shift_unit shift_unit
(
  .in(mux_ForwardDataBE), 
  .shamt(ShiftAmtE),
  .shift_type(Shift_typeE),
  .out(Shift_ResultE)
);
 
mux2 aluout_or_shifterout
(
  .in1(ALUoutEE),
  .in2(Shift_ResultE),
  .s(Shifter_or_ALUE),
  .out(EX_Result)
);

/* mux to choose between ALU output or its one's complement */
mux2 aluout_or_comp
(
  .in1(ALUoutE),
  .in2(~ALUoutE),
  .s(ALUCompE),
  .out(ALUoutCompE)
);

/* Normal or lui operation */
mux2 normal_or_lui
(
  .in1(ALUoutCompE),
  .in2({ALUoutE[15:0],16'h0000}),
  .s(UpperImmE),
  .out(ALUoutEE)
);

/* Calculate BTA */
shift_left2 sl2
(
  .a(SignImm_out),
  .out(shifted_imm_2)
);

adder pcbranch_value
(
  .in1(shifted_imm_2),
  .in2(PCplus4E),
  .cin(1'b0),
  .out(PCBranchE)
);

/* Calculate JTA */
assign JTA_E = {PCplus4E[31:28], IR_E[25:0], 2'b00};

/****************************** EX/MEM Register ********************************
*
*
*******************************************************************************/
ex_mem_pipereg EX_MEM_REG
(
  .clk(clk),
  .reset(EX_MEM_RESET),
  .en(EX_MEM_EN),
  .opcode_in(opcodeE),
  .zero_in(zeroE),
  .sign_in(SignE),
  .ALUout_in(EX_Result),
  .WriteData_in(read_value2_out),
  .PCBranch_in(PCBranchE),
  .PCJump_in(JTA_E),
  .WriteReg_in(WriteRegE),

  .RegWrite_in(RegWriteE),
  .WBResultSelect_in(WBResultSelectE),
  .MemWrite_in(MemWriteE),
  .Branch_in(BranchE),
  .Jump_in(JumpE),
  .JumpR_in(JumpRE),
  .BHW_in(bhwE),
  .lo_in(loIn),
  .hi_in(hiIn),
  .loEN(loENE),
  .hiEN(hiENE),
  .link_in(linkE),
  .pcplus4_in(PCplus4E),
  .undefinedEx_in(undefinedExE),
  .breakEx_in(breakExE),
  .divbyZero_in(divbyZeroExE),
  .syscallEx_in(syscallExE),
  .CP0_wa_in(CP0_waE),
  .CP0_ra_in(CP0_raE),
  .CP0_Inst_in(CP0_InstE),
  .CP0_dout_in(CP0_doutE),
  .CP0_din_in(CP0_dinE),
  .MemRefSize_in(MemRefSizeE),

  .zero_out(zeroM),
  .sign_out(SignM),
  .ALUout_out(ALUoutM),
  .WriteData_out(WriteData_toDMemory),
  .PCBranch_out(PCBranchM),
  .WriteReg_out(WriteRegM),

  .RegWrite_out(RegWriteM),
  .WBResultSelect_out(WBResultSelectM),
  .MemWrite_out(MemWriteM),
  .Branch_out(BranchM),
  .Jump_out(JumpM),
  .JumpR_out(JumpRM),
  .BHW_out(bhwM),
  .lo_out(loM),
  .hi_out(hiM),
  .opcode_out(opcodeM),
  .PCJump_out(JTA_M),
  .link_out(linkM),
  .pcplus4_out(PCplus4M),
  .undefinedEx_out(undefinedExM),
  .breakEx_out(breakExM),
  .divbyZero_out(divbyZeroExM),
  .syscallEx_out(syscallExM),
  .CP0_wa_out(CP0_waM),
  .CP0_ra_out(CP0_raM),
  .CP0_Inst_out(CP0_InstM),
  .CP0_dout_out(CP0_doutM),
  .CP0_din_out(CP0_dinM),
  .MemRefSize_out(MemRefSizeM)
);

/* output address to data memory in case of loads and stores and data to be 
written into memory (stores) */
assign Address_toDMemory = ALUoutM;

/* output MemWrite Signal to data memory */
assign MemWrite_toDMemory = MemWriteM;

/* Get data from data memory */
assign ReadDataM = RD_fromDMemory;

/****************************** MEM/WB Register ********************************
*
*
*******************************************************************************/
mem_wb_pipereg MEM_WB_REG
(
  .clk(clk),
  .reset(reset),
  .en(MEM_WB_EN),

  .ReadData_in(ReadDataM),
  .ALUout_in(ALUoutM),
  .WriteReg_in(WriteRegM),
  .RegWrite_in(RegWriteM),
  .WBResultSelect_in(WBResultSelectM),
  .BHW_in(bhwM),
  .lo_in(loM),
  .hi_in(hiM),
  .link_in(linkM),
  .pcplus4_in(PCplus4M),
  .undefinedEx_in(undefinedExM),
  .breakEx_in(breakExM),
  .divbyZero_in(divbyZeroExM),
  .syscallEx_in(syscallExM),
  .CP0_wa_in(CP0_waM),
  .CP0_ra_in(CP0_raM),
  .CP0_Inst_in(CP0_InstM),
  .CP0_dout_in(CP0_doutM),
  .CP0_din_in(CP0_dinM),

  .ReadData_out(ReadDataW),
  .ALUout_out(ALUoutW),
  .WriteReg_out(WriteRegW),
  .RegWrite_out(RegWriteW),
  .WBResultSelect_out(WBResultSelectW),
  .BHW_out(bhwW),
  .lo_out(loW),
  .hi_out(hiW),
  .link_out(linkW),
  .pcplus4_out(PCplus4W),
  .undefinedEx_out(undefinedExW),
  .breakEx_out(breakExW),
  .divbyZero_out(divbyZeroExW),
  .syscallEx_out(syscallExW),
  .CP0_wa_out(CP0_waW),
  .CP0_ra_out(CP0_raW),
  .CP0_Inst_out(CP0_InstW),
  .CP0_dout_out(CP0_doutW)
);
 
 /* WBResult mux to choose between, ALUout, DataMemory, lo, hi */
assign ResultW = 
  (WBResultSelectW === 2'b00) ? ALUoutW :
  (WBResultSelectW === 2'b01) ? ReadDataW : 
  (WBResultSelectW === 2'b10) ? loW : hiW;
 
endmodule
