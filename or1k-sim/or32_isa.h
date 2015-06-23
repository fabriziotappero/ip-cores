//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.0
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2013
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2013 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------
#ifndef __OR32_ISA_H__
#define __OR32_ISA_H__

//-----------------------------------------------------------------
// General:
//-----------------------------------------------------------------
typedef unsigned int TInstruction;
typedef unsigned int TRegister;
typedef unsigned int TAddress;
typedef unsigned int TMemory;

enum ERegisters
{
    REG_0_ZERO,
    REG_1_SP,
    REG_2_FP,
    REG_3,
    REG_4,
    REG_5,
    REG_6,
    REG_7,
    REG_8,
    REG_9_LR,
    REG_10,
    REG_11,
    REG_12,
    REG_13,
    REG_14,
    REG_15,
    REG_16,
    REG_17,
    REG_18,
    REG_19,
    REG_20,
    REG_21,
    REG_22,
    REG_23,
    REG_24,
    REG_25,
    REG_26,
    REG_27,
    REG_28,
    REG_29,
    REG_30,
    REG_31,
    REGISTERS
};

//--------------------------------------------------------------------
// Instruction Encoding
//--------------------------------------------------------------------
#define OR32_OPCODE_SHIFT                   26
#define OR32_OPCODE_MASK                    0x3F
#define OR32_REG_D_SHIFT                    21
#define OR32_REG_D_MASK                     0x1F
#define OR32_REG_A_SHIFT                    16
#define OR32_REG_A_MASK                     0x1F
#define OR32_REG_B_SHIFT                    11
#define OR32_REG_B_MASK                     0x1F
#define OR32_IMM16_SHIFT                    0
#define OR32_IMM16_MASK                     0xFFFF
#define OR32_ADDR_SHIFT                     0
#define OR32_ADDR_MASK                      0x3FFFFFF
#define OR32_ADDR_SIGN_SHIFT                25
#define OR32_SHIFT_OP_SHIFT                 6
#define OR32_SHIFT_OP_MASK                  0x3
#define OR32_SFXXX_OP_SHIFT                 21
#define OR32_SFXXX_OP_MASK                  0x7FF
#define OR32_ALU_OP_L_SHIFT                 0
#define OR32_ALU_OP_L_MASK                  0xF
#define OR32_ALU_OP_H_SHIFT                 2
#define OR32_ALU_OP_H_MASK                  0xF0
#define OR32_STORE_IMM_L_SHIFT              0
#define OR32_STORE_IMM_L_MASK               0x7FF
#define OR32_STORE_IMM_H_SHIFT              10
#define OR32_STORE_IMM_H_MASK               0xF800
#define OR32_MFSPR_IMM_MASK                 0xFFFF
#define OR32_MTSPR_IMM_MASK                 0x7FF

//--------------------------------------------------------------------
// Instructions
//--------------------------------------------------------------------

// ALU Instructions
#define INST_OR32_ALU                       0x38
#define INST_OR32_ADD                            0x0000
#define INST_OR32_ADDC                           0x0001
#define INST_OR32_AND                            0x0003
#define INST_OR32_OR                             0x0004
#define INST_OR32_SLL                            0x0008
#define INST_OR32_SRA                            0x0028
#define INST_OR32_SRL                            0x0018
#define INST_OR32_SUB                            0x0002
#define INST_OR32_XOR                            0x0005
#define INST_OR32_MUL                            0x00c6
#define INST_OR32_MULU                           0x00cb

// INST_OR32_SHIFTI Instructions
#define INST_OR32_SHIFTI                    0x2e
#define INST_OR32_SLLI                           0x0000
#define INST_OR32_SRAI                           0x0002
#define INST_OR32_SRLI                           0x0001

// General Instructions
#define INST_OR32_ADDI                           0x0027
#define INST_OR32_ANDI                           0x0029
#define INST_OR32_BF                             0x0004
#define INST_OR32_BNF                            0x0003
#define INST_OR32_J                              0x0000
#define INST_OR32_JAL                            0x0001
#define INST_OR32_JALR                           0x0012
#define INST_OR32_JR                             0x0011
#define INST_OR32_LBS                            0x0024
#define INST_OR32_LHS                            0x0026
#define INST_OR32_LWS                            0x0022
#define INST_OR32_LBZ                            0x0023
#define INST_OR32_LHZ                            0x0025
#define INST_OR32_LWZ                            0x0021
#define INST_OR32_MFSPR                          0x002d
#define INST_OR32_MOVHI                          0x0006
#define INST_OR32_MTSPR                          0x0030
#define INST_OR32_NOP                            0x0005
#define INST_OR32_ORI                            0x002a
#define INST_OR32_RFE                            0x0009
#define INST_OR32_SB                             0x0036
#define INST_OR32_SH                             0x0037
#define INST_OR32_SW                             0x0035
#define INST_OR32_XORI                           0x002b
#define INST_OR32_LBS                            0x0024
#define INST_OR32_LBZ                            0x0023
#define INST_OR32_LHS                            0x0026
#define INST_OR32_LHZ                            0x0025
#define INST_OR32_LWZ                            0x0021
#define INST_OR32_LWS                            0x0022

// Set Flag Instructions
#define INST_OR32_SFXX                      0x2f
#define INST_OR32_SFXXI                     0x39
#define INST_OR32_SFEQ                           0x0720
#define INST_OR32_SFEQI                          0x05e0
#define INST_OR32_SFGES                          0x072b
#define INST_OR32_SFGESI                         0x05eb
#define INST_OR32_SFGEU                          0x0723
#define INST_OR32_SFGEUI                         0x05e3
#define INST_OR32_SFGTS                          0x072a
#define INST_OR32_SFGTSI                         0x05ea
#define INST_OR32_SFGTU                          0x0722
#define INST_OR32_SFGTUI                         0x05e2
#define INST_OR32_SFLES                          0x072d
#define INST_OR32_SFLESI                         0x05ed
#define INST_OR32_SFLEU                          0x0725
#define INST_OR32_SFLEUI                         0x05e5
#define INST_OR32_SFLTS                          0x072c
#define INST_OR32_SFLTSI                         0x05ec
#define INST_OR32_SFLTU                          0x0724
#define INST_OR32_SFLTUI                         0x05e4
#define INST_OR32_SFNE                           0x0721
#define INST_OR32_SFNEI                          0x05e1

// Misc Instructions
#define INST_OR32_MISC                      0x08
#define INST_OR32_SYS                            0x0020
#define INST_OR32_TRAP                           0x0021

//--------------------------------------------------------------------
// SPR Register Map
//--------------------------------------------------------------------
#define SPR_REG_VR                              0
    #define SPR_VERSION_CURRENT                 0x00000000
#define SPR_REG_SR                              17
#define SPR_REG_EPCR                            32
#define SPR_REG_ESR                             64

//--------------------------------------------------------------------
// SR Register bits
//--------------------------------------------------------------------
#define OR32_SR_SM                              0
#define OR32_SR_TEE                             1
#define OR32_SR_IEE                             2
#define OR32_SR_DCE                             3
#define OR32_SR_ICE                             4
#define OR32_SR_DME                             5
#define OR32_SR_IME                             6
#define OR32_SR_LEE                             7
#define OR32_SR_CE                              8
#define OR32_SR_F                               9
#define OR32_SR_F_BIT                           (1 << OR32_SR_F)
#define OR32_SR_CY                              10
#define OR32_SR_CY_BIT                          (1 << OR32_SR_CY)
#define OR32_SR_OV                              11
#define OR32_SR_OV_BIT                          (1 << OR32_SR_OV)
#define OR32_SR_OVE                             12
#define OR32_SR_DSX                             13
#define OR32_SR_EPH                             14
#define OR32_SR_FO                              15
#define OR32_SR_TED                             16

//--------------------------------------------------------------------
// OR32 NOP Control Codes
//--------------------------------------------------------------------
#define NOP_DATA_REG                            REG_3
#define NOP_NOP                                 0x0000
#define NOP_EXIT                                0x0001
#define NOP_REPORT                              0x0002
#define NOP_PUTC                                0x0004
#define NOP_TRACE_ON                            0x0008
#define NOP_TRACE_OFF                           0x0009
#define NOP_STATS_RESET                         0x000A
#define NOP_PROFILE_ON                          0x000B
#define NOP_PROFILE_OFF                         0x000C
#define NOP_STATS_MARKER                        0x000D

//--------------------------------------------------------------------
// OR32 Vectors
// NOTE: These differ from the real OR32 vectors for space reasons
//--------------------------------------------------------------------
#define VECTOR_RESET                            0x100
#define VECTOR_ILLEGAL_INST                     0x200
#define VECTOR_EXTINT                           0x300
#define VECTOR_SYSCALL                          0x400
#define VECTOR_TRAP                             0x600
#define VECTOR_NMI                              0x700
#define VECTOR_BUS_ERROR                        0x800

#endif

