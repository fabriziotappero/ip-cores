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
// *File Name: openMSP430_defines.v
// 
// *Module Description:
//                      openMSP430 Configuration file
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 57 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2010-02-01 23:56:03 +0100 (Mo, 01 Feb 2010) $
//----------------------------------------------------------------------------
`include "openMSP430_undefines.v"

//----------------------------------------------------------------------------
// SYSTEM CONFIGURATION
//----------------------------------------------------------------------------

// Program Memory Size:
//                    9 ->  1 kB
//                   10 ->  2 kB
//                   11 ->  4 kB
//                   12 ->  8 kB
//                   13 -> 16 kB
//                   14 -> 32 kB
`define PMEM_AWIDTH 12

// Data Memory Size:
//                    6 ->  128 B
//                    7 ->  256 B
//                    8 ->  512 B
//                    9 ->    1 kB
//                   10 ->    2 kB
//                   11 ->    4 kB
//                   12 ->    8 kB
//                   13 ->   16 kB
//                   14 ->   32 kB
`define DMEM_AWIDTH 10

//----------------------------------------------------------------------------
// REMOTE DEBUGGING INTERFACE CONFIGURATION
//----------------------------------------------------------------------------

// Include Debug interface
`define DBG_EN

// Debug interface selection
//             `define DBG_UART -> Enable UART (8N1) debug interface
//             `define DBG_JTAG -> DON'T UNCOMMENT, NOT SUPPORTED
//
`define DBG_UART
//`define DBG_JTAG

// Number of hardware breakpoints (each unit contains 2 hw address breakpoints)
//             `define DBG_HWBRK_0 -> Include hardware breakpoints unit 0
//             `define DBG_HWBRK_1 -> Include hardware breakpoints unit 1
//             `define DBG_HWBRK_2 -> Include hardware breakpoints unit 2
//             `define DBG_HWBRK_3 -> Include hardware breakpoints unit 3
//
`define  DBG_HWBRK_0
`define  DBG_HWBRK_1
`define  DBG_HWBRK_2
`define  DBG_HWBRK_3


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
`define PMEM_SIZE  (2 << `PMEM_AWIDTH)
`define DMEM_SIZE  (2 << `DMEM_AWIDTH)

// Data Memory Base Adresses
`define DMEM_BASE  16'h0200

// Program & Data Memory most significant address bit (for 16 bit words)
`define PMEM_MSB   `PMEM_AWIDTH-1
`define DMEM_MSB   `DMEM_AWIDTH-1


// Instructions type
`define INST_SO  0
`define INST_JMP 1
`define INST_TO  2

// Single-operand arithmetic
`define RRC    0
`define SWPB   1
`define RRA    2
`define SXT    3
`define PUSH   4
`define CALL   5
`define RETI   6
`define IRQ    7

// Conditional jump
`define JNE    0
`define JEQ    1
`define JNC    2
`define JC     3
`define JN     4
`define JGE    5
`define JL     6
`define JMP    7

// Two-operand arithmetic
`define MOV    0
`define ADD    1
`define ADDC   2
`define SUBC   3
`define SUB    4
`define CMP    5
`define DADD   6
`define BIT    7
`define BIC    8
`define BIS    9
`define XOR   10
`define AND   11

// Addressing modes
`define DIR      0
`define IDX      1
`define INDIR    2
`define INDIR_I  3
`define SYMB     4
`define IMM      5
`define ABS      6
`define CONST    7

// Execution state machine
`define E_IRQ_0    4'h0
`define E_IRQ_1    4'h1
`define E_IRQ_2    4'h2
`define E_IRQ_3    4'h3
`define E_IRQ_4    4'h4
`define E_SRC_AD   4'h5
`define E_SRC_RD   4'h6
`define E_SRC_WR   4'h7
`define E_DST_AD   4'h8
`define E_DST_RD   4'h9
`define E_DST_WR   4'hA
`define E_EXEC     4'hB
`define E_JUMP     4'hC
`define E_IDLE     4'hD

// ALU control signals
`define ALU_SRC_INV   0
`define ALU_INC       1
`define ALU_INC_C     2
`define ALU_ADD       3
`define ALU_AND       4
`define ALU_OR        5
`define ALU_XOR       6
`define ALU_DADD      7
`define ALU_STAT_7    8
`define ALU_STAT_F    9
`define ALU_SHIFT    10
`define EXEC_NO_WR   11

// Debug interface
`define DBG_UART_WR   18
`define DBG_UART_BW   17
`define DBG_UART_ADDR 16:11

// Debug interface CPU_CTL register
`define HALT        0
`define RUN         1
`define ISTEP       2
`define SW_BRK_EN   3
`define FRZ_BRK_EN  4
`define RST_BRK_EN  5
`define CPU_RST     6

// Debug interface CPU_STAT register
`define HALT_RUN    0
`define PUC_PND     1
`define SWBRK_PND   3
`define HWBRK0_PND  4
`define HWBRK1_PND  5

// Debug interface BRKx_CTL register
`define BRK_MODE_RD 0
`define BRK_MODE_WR 1
`define BRK_MODE    1:0
`define BRK_EN      2
`define BRK_I_EN    3
`define BRK_RANGE   4

// Basic clock module: BCSCTL1 Control Register
`define DIVAx       5:4

// Basic clock module: BCSCTL2 Control Register
`define SELS        3
`define DIVSx       2:1

// Timer A: TACTL Control Register
`define TASSELx     9:8
`define TAIDx       7:6
`define TAMCx       5:4
`define TACLR       2
`define TAIE        1
`define TAIFG       0

// Timer A: TACCTLx Capture/Compare Control Register
`define TACMx      15:14
`define TACCISx    13:12
`define TASCS      11
`define TASCCI     10
`define TACAP       8
`define TAOUTMODx   7:5
`define TACCIE      4
`define TACCI       3
`define TAOUT       2
`define TACOV       1
`define TACCIFG     0

//
// DEBUG INTERFACE EXTRA CONFIGURATION
//======================================

// Debug interface: Software breakpoint opcode
`define DBG_SWBRK_OP 16'h4343

// Debug interface ID
`define DBG_ID  24'h4D5350

// Debug UART interface auto data synchronization
// If the following define is commented out, then
// the DBG_UART_BAUD and DBG_DCO_FREQ need to be properly
// defined.
`define DBG_UART_AUTO_SYNC

// Debug UART interface data rate
//      In order to properly setup the UART debug interface, you
//      need to specify the DCO_CLK frequency (DBG_DCO_FREQ) and
//      the chosen BAUD rate from the UART interface.
//
//`define DBG_UART_BAUD    9600
//`define DBG_UART_BAUD   19200
//`define DBG_UART_BAUD   38400
//`define DBG_UART_BAUD   57600
//`define DBG_UART_BAUD  115200
//`define DBG_UART_BAUD  230400
//`define DBG_UART_BAUD  460800
//`define DBG_UART_BAUD  576000
//`define DBG_UART_BAUD  921600
`define DBG_UART_BAUD 2000000
`define DBG_DCO_FREQ  20000000
`define DBG_UART_CNT ((`DBG_DCO_FREQ/`DBG_UART_BAUD)-1)

// Enable/Disable the hardware breakpoint RANGE mode
`define HWBRK_RANGE 1'b0

// Check configuration
`ifdef DBG_EN
 `ifdef DBG_UART
   `ifdef DBG_JTAG
CONFIGURATION ERROR: JTAG AND UART DEBUG INTERFACE ARE BOTH ENABLED
   `endif
 `else
   `ifdef DBG_JTAG
CONFIGURATION ERROR: JTAG INTERFACE NOT SUPPORTED
   `else
CONFIGURATION ERROR: JTAG OR UART DEBUG INTERFACE SHOULD BE ENABLED
   `endif
 `endif
`endif

