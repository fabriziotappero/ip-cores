//----------------------------------------------------------------------------
// Copyright (C) 2001 Authors
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//----------------------------------------------------------------------------
// 
// *File Name: openMSP430_undefines.v
// 
// *Module Description:
//                      openMSP430 Verilog `undef file
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 23 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2009-08-30 18:39:26 +0200 (Sun, 30 Aug 2009) $
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// SYSTEM CONFIGURATION
//----------------------------------------------------------------------------

// Program Memory Size:
`ifdef PMEM_AWIDTH
`undef PMEM_AWIDTH
`endif

// Data Memory Size:
`ifdef DMEM_AWIDTH
`undef DMEM_AWIDTH
`endif

//----------------------------------------------------------------------------
// REMOTE DEBUGGING INTERFACE CONFIGURATION
//----------------------------------------------------------------------------

// Include Debug interface
`ifdef DBG_EN
`undef DBG_EN
`endif

// Debug interface selection
`ifdef DBG_UART
`undef DBG_UART
`endif
`ifdef DBG_JTAG
`undef DBG_JTAG
`endif

// Number of hardware breakpoints
`ifdef DBG_HWBRK_0
`undef DBG_HWBRK_0
`endif
`ifdef DBG_HWBRK_1
`undef DBG_HWBRK_1
`endif
`ifdef DBG_HWBRK_2
`undef DBG_HWBRK_2
`endif
`ifdef DBG_HWBRK_3
`undef DBG_HWBRK_3
`endif


//==========================================================================//
//==========================================================================//
//==========================================================================//
//==========================================================================//
//=====        SYSTEM CONSTANTS --- !!!!!!!! DO NOT EDIT !!!!!!!!      =====//
//==========================================================================//
//==========================================================================//
//==========================================================================//
//==========================================================================//

// Program and Data Memory sizes
`ifdef PMEM_SIZE
`undef PMEM_SIZE
`endif
`ifdef DMEM_SIZE
`undef DMEM_SIZE
`endif

// Data Memory Base Adresses
`ifdef DMEM_BASE
`undef DMEM_BASE
`endif

// Program & Data Memory most significant address bit (for 16 bit words)
`ifdef PMEM_MSB
`undef PMEM_MSB
`endif
`ifdef DMEM_MSB
`undef DMEM_MSB
`endif


// Instructions type
`ifdef INST_SO
`undef INST_SO
`endif
`ifdef INST_JMP
`undef INST_JMP
`endif
`ifdef INST_TO
`undef INST_TO
`endif

// Single-operand arithmetic
`ifdef RRC
`undef RRC
`endif
`ifdef SWPB
`undef SWPB
`endif
`ifdef RRA
`undef RRA
`endif
`ifdef SXT
`undef SXT
`endif
`ifdef PUSH
`undef PUSH
`endif
`ifdef CALL
`undef CALL
`endif
`ifdef RETI
`undef RETI
`endif
`ifdef IRQ
`undef IRQ
`endif

// Conditional jump
`ifdef JNE
`undef JNE
`endif
`ifdef JEQ
`undef JEQ
`endif
`ifdef JNC
`undef JNC
`endif
`ifdef JC
`undef JC
`endif
`ifdef JN
`undef JN
`endif
`ifdef JGE
`undef JGE
`endif
`ifdef JL
`undef JL
`endif
`ifdef JMP
`undef JMP
`endif

// Two-operand arithmetic
`ifdef MOV
`undef MOV
`endif
`ifdef ADD
`undef ADD
`endif
`ifdef ADDC
`undef ADDC
`endif
`ifdef SUBC
`undef SUBC
`endif
`ifdef SUB
`undef SUB
`endif
`ifdef CMP
`undef CMP
`endif
`ifdef DADD
`undef DADD
`endif
`ifdef BIT
`undef BIT
`endif
`ifdef BIC
`undef BIC
`endif
`ifdef BIS
`undef BIS
`endif
`ifdef XOR
`undef XOR
`endif
`ifdef AND
`undef AND
`endif

// Addressing modes
`ifdef DIR
`undef DIR
`endif
`ifdef IDX
`undef IDX
`endif
`ifdef INDIR
`undef INDIR
`endif
`ifdef INDIR_I
`undef INDIR_I
`endif
`ifdef SYMB
`undef SYMB
`endif
`ifdef IMM
`undef IMM
`endif
`ifdef ABS
`undef ABS
`endif
`ifdef CONST
`undef CONST
`endif

// Execution state machine
`ifdef E_IRQ_0
`undef E_IRQ_0
`endif
`ifdef E_IRQ_1
`undef E_IRQ_1
`endif
`ifdef E_IRQ_2
`undef E_IRQ_2
`endif
`ifdef E_IRQ_3
`undef E_IRQ_3
`endif
`ifdef E_IRQ_4
`undef E_IRQ_4
`endif
`ifdef E_SRC_AD
`undef E_SRC_AD
`endif
`ifdef E_SRC_RD
`undef E_SRC_RD
`endif
`ifdef E_SRC_WR
`undef E_SRC_WR
`endif
`ifdef E_DST_AD
`undef E_DST_AD
`endif
`ifdef E_DST_RD
`undef E_DST_RD
`endif
`ifdef E_DST_WR
`undef E_DST_WR
`endif
`ifdef E_EXEC
`undef E_EXEC
`endif
`ifdef E_JUMP
`undef E_JUMP
`endif
`ifdef E_IDLE
`undef E_IDLE
`endif

// ALU control signals
`ifdef ALU_SRC_INV
`undef ALU_SRC_INV
`endif
`ifdef ALU_INC
`undef ALU_INC
`endif
`ifdef ALU_INC_C
`undef ALU_INC_C
`endif
`ifdef ALU_ADD
`undef ALU_ADD
`endif
`ifdef ALU_AND
`undef ALU_AND
`endif
`ifdef ALU_OR
`undef ALU_OR
`endif
`ifdef ALU_XOR
`undef ALU_XOR
`endif
`ifdef ALU_DADD
`undef ALU_DADD
`endif
`ifdef ALU_STAT_7
`undef ALU_STAT_7
`endif
`ifdef ALU_STAT_F
`undef ALU_STAT_F
`endif
`ifdef ALU_SHIFT
`undef ALU_SHIFT
`endif
`ifdef EXEC_NO_WR
`undef EXEC_NO_WR
`endif

// Debug interface
`ifdef DBG_UART_WR
`undef DBG_UART_WR
`endif
`ifdef DBG_UART_BW
`undef DBG_UART_BW
`endif
`ifdef DBG_UART_ADDR
`undef DBG_UART_ADDR
`endif

// Debug interface CPU_CTL register
`ifdef HALT
`undef HALT
`endif
`ifdef RUN
`undef RUN
`endif
`ifdef ISTEP
`undef ISTEP
`endif
`ifdef SW_BRK_EN
`undef SW_BRK_EN
`endif
`ifdef FRZ_BRK_EN
`undef FRZ_BRK_EN
`endif
`ifdef RST_BRK_EN
`undef RST_BRK_EN
`endif
`ifdef CPU_RST
`undef CPU_RST
`endif

// Debug interface CPU_STAT register
`ifdef HALT_RUN
`undef HALT_RUN
`endif
`ifdef PUC_PND
`undef PUC_PND
`endif
`ifdef SWBRK_PND
`undef SWBRK_PND
`endif
`ifdef HWBRK0_PND
`undef HWBRK0_PND
`endif
`ifdef HWBRK1_PND
`undef HWBRK1_PND
`endif

// Debug interface BRKx_CTL register
`ifdef BRK_MODE_RD
`undef BRK_MODE_RD
`endif
`ifdef BRK_MODE_WR
`undef BRK_MODE_WR
`endif
`ifdef BRK_MODE
`undef BRK_MODE
`endif
`ifdef BRK_EN
`undef BRK_EN
`endif
`ifdef BRK_I_EN
`undef BRK_I_EN
`endif
`ifdef BRK_RANGE
`undef BRK_RANGE
`endif

// Basic clock module: BCSCTL1 Control Register
`ifdef DIVAx
`undef DIVAx
`endif

// Basic clock module: BCSCTL2 Control Register
`ifdef SELS
`undef SELS
`endif
`ifdef DIVSx
`undef DIVSx
`endif

// Timer A: TACTL Control Register
`ifdef TASSELx
`undef TASSELx
`endif
`ifdef TAIDx
`undef TAIDx
`endif
`ifdef TAMCx
`undef TAMCx
`endif
`ifdef TACLR
`undef TACLR
`endif
`ifdef TAIE
`undef TAIE
`endif
`ifdef TAIFG
`undef TAIFG
`endif

// Timer A: TACCTLx Capture/Compare Control Register
`ifdef TACMx
`undef TACMx
`endif
`ifdef TACCISx
`undef TACCISx
`endif
`ifdef TASCS
`undef TASCS
`endif
`ifdef TASCCI
`undef TASCCI
`endif
`ifdef TACAP
`undef TACAP
`endif
`ifdef TAOUTMODx
`undef TAOUTMODx
`endif
`ifdef TACCIE
`undef TACCIE
`endif
`ifdef TACCI
`undef TACCI
`endif
`ifdef TAOUT
`undef TAOUT
`endif
`ifdef TACOV
`undef TACOV
`endif
`ifdef TACCIFG
`undef TACCIFG
`endif

//
// DEBUG INTERFACE EXTRA CONFIGURATION
//======================================

// Debug interface: Software breakpoint opcode
`ifdef DBG_SWBRK_OP
`undef DBG_SWBRK_OP
`endif

// Debug interface ID
`ifdef DBG_ID
`undef DBG_ID
`endif

// Debug UART interface auto data synchronization
`ifdef DBG_UART_AUTO_SYNC
`undef DBG_UART_AUTO_SYNC
`endif

// Debug UART interface data rate
`ifdef DBG_UART_BAUD
`undef DBG_UART_BAUD
`endif
`ifdef DBG_DCO_FREQ
`undef DBG_DCO_FREQ
`endif
`ifdef DBG_UART_CNT
`undef DBG_UART_CNT
`endif
