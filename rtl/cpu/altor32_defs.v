//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.1
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2014
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2014 Ultra-Embedded.com
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

//-----------------------------------------------------------------
// ALU Operations
//-----------------------------------------------------------------
`define ALU_NONE                                4'b0000
`define ALU_SHIFTL                              4'b0001
`define ALU_SHIFTR                              4'b0010
`define ALU_SHIRTR_ARITH                        4'b0011
`define ALU_ADD                                 4'b0100
`define ALU_ADDC                                4'b0101
`define ALU_SUB                                 4'b0110
`define ALU_AND                                 4'b0111
`define ALU_OR                                  4'b1000
`define ALU_XOR                                 4'b1001
`define ALU_COMPARE                             4'b1010

//-----------------------------------------------------------------
// ALU Instructions
//-----------------------------------------------------------------
`define INST_OR32_ALU                            8'h38
`define INST_OR32_ADD                            8'h00
`define INST_OR32_ADDC                           8'h01
`define INST_OR32_AND                            8'h03
`define INST_OR32_OR                             8'h04
`define INST_OR32_SLL                            8'h08
`define INST_OR32_SRA                            8'h28
`define INST_OR32_SRL                            8'h18
`define INST_OR32_SUB                            8'h02
`define INST_OR32_XOR                            8'h05
`define INST_OR32_MUL                            8'hc6
`define INST_OR32_MULU                           8'hcb

//-----------------------------------------------------------------
// INST_OR32_SHIFTI Instructions
//-----------------------------------------------------------------
`define INST_OR32_SHIFTI                         8'h2E
`define INST_OR32_SLLI                           2'b00
`define INST_OR32_SRAI                           2'b10
`define INST_OR32_SRLI                           2'b01

//-----------------------------------------------------------------
// General Instructions
//-----------------------------------------------------------------
`define INST_OR32_ADDI                           8'h27
`define INST_OR32_ANDI                           8'h29
`define INST_OR32_BF                             8'h04
`define INST_OR32_BNF                            8'h03
`define INST_OR32_J                              8'h00
`define INST_OR32_JAL                            8'h01
`define INST_OR32_JALR                           8'h12
`define INST_OR32_JR                             8'h11
`define INST_OR32_MFSPR                          8'h2D
`define INST_OR32_MOVHI                          8'h06
`define INST_OR32_MTSPR                          8'h30
`define INST_OR32_NOP                            8'h05
`define INST_OR32_ORI                            8'h2A
`define INST_OR32_RFE                            8'h09
`define INST_OR32_SB                             8'h36
`define INST_OR32_SH                             8'h37
`define INST_OR32_SW                             8'h35
`define INST_OR32_XORI                           8'h2B
`define INST_OR32_LBS                            8'h24
`define INST_OR32_LBZ                            8'h23
`define INST_OR32_LHS                            8'h26
`define INST_OR32_LHZ                            8'h25
`define INST_OR32_LWZ                            8'h21
`define INST_OR32_LWS                            8'h22

//-----------------------------------------------------------------
// Set Flag Instructions
//-----------------------------------------------------------------
`define INST_OR32_SFXX                           8'h39
`define INST_OR32_SFXXI                          8'h2F
`define INST_OR32_SFMASK                         16'hFD3F
`define INST_OR32_SFEQ                           16'h0520
`define INST_OR32_SFGES                          16'h052B
`define INST_OR32_SFGEU                          16'h0523
`define INST_OR32_SFGTS                          16'h052A
`define INST_OR32_SFGTU                          16'h0522
`define INST_OR32_SFLES                          16'h052D
`define INST_OR32_SFLEU                          16'h0525
`define INST_OR32_SFLTS                          16'h052C
`define INST_OR32_SFLTU                          16'h0524
`define INST_OR32_SFNE                           16'h0521

//-----------------------------------------------------------------
// Misc Instructions
//-----------------------------------------------------------------
`define INST_OR32_MISC                           8'h08
`define INST_OR32_SYS                            8'h20
`define INST_OR32_TRAP                           8'h21
`define INST_OR32_CUST1                          8'h1C

`define INST_OR32_BUBBLE                         8'h3F
`define OPCODE_INST_BUBBLE                       32'hFC000000

//-----------------------------------------------------------------
// SPR Register Map
//-----------------------------------------------------------------
`define SPR_REG_VR                               16'h0000
`define SPR_VERSION_CURRENT                      8'h00
`define SPR_REG_SR                               16'h0011
`define SPR_REG_EPCR                             16'h0020
`define SPR_REG_ESR                              16'h0040

`define SPR_REG_MACLO                            16'h0080
`define SPR_REG_MACHI                            16'h0081

//-----------------------------------------------------------------
// SR Register bits
//-----------------------------------------------------------------
`define SR_SM                                    0
`define SR_TEE                                   1
`define SR_IEE                                   2
`define SR_DCE                                   3
`define SR_ICE                                   4
`define SR_DME                                   5
`define SR_IME                                   6
`define SR_LEE                                   7
`define SR_CE                                    8
`define SR_F                                     9
`define SR_CY                                    10
`define SR_OV                                    11
`define SR_OVE                                   12
`define SR_DSX                                   13
`define SR_EPH                                   14
`define SR_FO                                    15
`define SR_SUMRA                                 16
`define SR_ICACHE_FLUSH                          17
`define SR_DCACHE_FLUSH                          18
`define SR_STEP                                  19
`define SR_DBGEN                                 20

//-----------------------------------------------------------------
// OR32 Vectors
// NOTE: These differ from the real OR32 vectors for space reasons
//-----------------------------------------------------------------
`define VECTOR_RESET                             32'h00000100
`define VECTOR_ILLEGAL_INST                      32'h00000200
`define VECTOR_EXTINT                            32'h00000300
`define VECTOR_SYSCALL                           32'h00000400
`define VECTOR_TRAP                              32'h00000600
`define VECTOR_BUS_ERROR                         32'h00000800
