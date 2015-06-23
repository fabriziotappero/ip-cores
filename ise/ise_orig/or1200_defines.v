//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's definitions                                        ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Parameters of the OR1200 core                               ////
////                                                              ////
////  To Do:                                                      ////
////   - add parameters that are missing                          ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.44  2005/10/19 11:37:56  jcastillo
// Added support for RAMB16 Xilinx4/Spartan3 primitives
//
// Revision 1.43  2005/01/07 09:23:39  andreje
// l.ff1 and l.cmov instructions added
//
// Revision 1.42  2004/06/08 18:17:36  lampret
// Non-functional changes. Coding style fixes.
//
// Revision 1.41  2004/05/09 20:03:20  lampret
// By default l.cust5 insns are disabled
//
// Revision 1.40  2004/05/09 19:49:04  lampret
// Added some l.cust5 custom instructions as example
//
// Revision 1.39  2004/04/08 11:00:46  simont
// Add support for 512B instruction cache.
//
// Revision 1.38  2004/04/05 08:29:57  lampret
// Merged branch_qmem into main tree.
//
// Revision 1.35.4.6  2004/02/11 01:40:11  lampret
// preliminary HW breakpoints support in debug unit (by default disabled). To enable define OR1200_DU_HWBKPTS.
//
// Revision 1.35.4.5  2004/01/15 06:46:38  markom
// interface to debug changed; no more opselect; stb-ack protocol
//
// Revision 1.35.4.4  2004/01/11 22:45:46  andreje
// Separate instruction and data QMEM decoders, QMEM acknowledge and byte-select added
//
// Revision 1.35.4.3  2003/12/17 13:43:38  simons
// Exception prefix configuration changed.
//
// Revision 1.35.4.2  2003/12/05 00:05:03  lampret
// Static exception prefix.
//
// Revision 1.35.4.1  2003/07/08 15:36:37  lampret
// Added embedded memory QMEM.
//
// Revision 1.35  2003/04/24 00:16:07  lampret
// No functional changes. Added defines to disable implementation of multiplier/MAC
//
// Revision 1.34  2003/04/20 22:23:57  lampret
// No functional change. Only added customization for exception vectors.
//
// Revision 1.33  2003/04/07 20:56:07  lampret
// Fixed OR1200_CLKDIV_x_SUPPORTED defines. Better description.
//
// Revision 1.32  2003/04/07 01:26:57  lampret
// RFRAM defines comments updated. Altera LPM option added.
//
// Revision 1.31  2002/12/08 08:57:56  lampret
// Added optional support for WB B3 specification (xwb_cti_o, xwb_bte_o). Made xwb_cab_o optional.
//
// Revision 1.30  2002/10/28 15:09:22  mohor
// Previous check-in was done by mistake.
//
// Revision 1.29  2002/10/28 15:03:50  mohor
// Signal scanb_sen renamed to scanb_en.
//
// Revision 1.28  2002/10/17 20:04:40  lampret
// Added BIST scan. Special VS RAMs need to be used to implement BIST.
//
// Revision 1.27  2002/09/16 03:13:23  lampret
// Removed obsolete comment.
//
// Revision 1.26  2002/09/08 05:52:16  lampret
// Added optional l.div/l.divu insns. By default they are disabled.
//
// Revision 1.25  2002/09/07 19:16:10  lampret
// If SR[CY] implemented with OR1200_IMPL_ADDC enabled, l.add/l.addi also set SR[CY].
//
// Revision 1.24  2002/09/07 05:42:02  lampret
// Added optional SR[CY]. Added define to enable additional (compare) flag modifiers. Defines are OR1200_IMPL_ADDC and OR1200_ADDITIONAL_FLAG_MODIFIERS.
//
// Revision 1.23  2002/09/04 00:50:34  lampret
// Now most of the configuration registers are updatded automatically based on defines in or1200_defines.v.
//
// Revision 1.22  2002/09/03 22:28:21  lampret
// As per Taylor Su suggestion all case blocks are full case by default and optionally (OR1200_CASE_DEFAULT) can be disabled to increase clock frequncy.
//
// Revision 1.21  2002/08/22 02:18:55  lampret
// Store buffer has been tested and it works. BY default it is still disabled until uClinux confirms correct operation on FPGA board.
//
// Revision 1.20  2002/08/18 21:59:45  lampret
// Disable SB until it is tested
//
// Revision 1.19  2002/08/18 19:53:08  lampret
// Added store buffer.
//
// Revision 1.18  2002/08/15 06:04:11  lampret
// Fixed Xilinx trace buffer address. REported by Taylor Su.
//
// Revision 1.17  2002/08/12 05:31:44  lampret
// Added OR1200_WB_RETRY. Moved WB registered outsputs / samples inputs into lower section.
//
// Revision 1.16  2002/07/14 22:17:17  lampret
// Added simple trace buffer [only for Xilinx Virtex target]. Fixed instruction fetch abort when new exception is recognized.
//
// Revision 1.15  2002/06/08 16:20:21  lampret
// Added defines for enabling generic FF based memory macro for register file.
//
// Revision 1.14  2002/03/29 16:24:06  lampret
// Changed comment about synopsys to _synopsys_ because synthesis was complaining about unknown directives
//
// Revision 1.13  2002/03/29 15:16:55  lampret
// Some of the warnings fixed.
//
// Revision 1.12  2002/03/28 19:25:42  lampret
// Added second type of Virtual Silicon two-port SRAM (for register file). Changed defines for VS STP RAMs.
//
// Revision 1.11  2002/03/28 19:13:17  lampret
// Updated defines.
//
// Revision 1.10  2002/03/14 00:30:24  lampret
// Added alternative for critical path in DU.
//
// Revision 1.9  2002/03/11 01:26:26  lampret
// Fixed async loop. Changed multiplier type for ASIC.
//
// Revision 1.8  2002/02/11 04:33:17  lampret
// Speed optimizations (removed duplicate _cyc_ and _stb_). Fixed D/IMMU cache-inhibit attr.
//
// Revision 1.7  2002/02/01 19:56:54  lampret
// Fixed combinational loops.
//
// Revision 1.6  2002/01/19 14:10:22  lampret
// Fixed OR1200_XILINX_RAM32X1D.
//
// Revision 1.5  2002/01/18 07:56:00  lampret
// No more low/high priority interrupts (PICPR removed). Added tick timer exception. Added exception prefix (SR[EPH]). Fixed single-step bug whenreading NPC.
//
// Revision 1.4  2002/01/14 09:44:12  lampret
// Default ASIC configuration does not sample WB inputs.
//
// Revision 1.3  2002/01/08 00:51:08  lampret
// Fixed typo. OR1200_REGISTERED_OUTPUTS was not defined. Should be.
//
// Revision 1.2  2002/01/03 21:23:03  lampret
// Uncommented OR1200_REGISTERED_OUTPUTS for FPGA target.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.20  2001/12/04 05:02:36  lampret
// Added OR1200_GENERIC_MULTP2_32X32 and OR1200_ASIC_MULTP2_32X32
//
// Revision 1.19  2001/11/27 19:46:57  lampret
// Now FPGA and ASIC target are separate.
//
// Revision 1.18  2001/11/23 21:42:31  simons
// Program counter divided to PPC and NPC.
//
// Revision 1.17  2001/11/23 08:38:51  lampret
// Changed DSR/DRR behavior and exception detection.
//
// Revision 1.16  2001/11/20 21:30:38  lampret
// Added OR1200_REGISTERED_INPUTS.
//
// Revision 1.15  2001/11/19 14:29:48  simons
// Cashes disabled.
//
// Revision 1.14  2001/11/13 10:02:21  lampret
// Added 'setpc'. Renamed some signals (except_flushpipe into flushpipe etc)
//
// Revision 1.13  2001/11/12 01:45:40  lampret
// Moved flag bit into SR. Changed RF enable from constant enable to dynamic enable for read ports.
//
// Revision 1.12  2001/11/10 03:43:57  lampret
// Fixed exceptions.
//
// Revision 1.11  2001/11/02 18:57:14  lampret
// Modified virtual silicon instantiations.
//
// Revision 1.10  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.9  2001/10/19 23:28:46  lampret
// Fixed some synthesis warnings. Configured with caches and MMUs.
//
// Revision 1.8  2001/10/14 13:12:09  lampret
// MP3 version.
//
// Revision 1.1.1.1  2001/10/06 10:18:36  igorm
// no message
//
// Revision 1.3  2001/08/17 08:01:19  lampret
// IC enable/disable.
//
// Revision 1.2  2001/08/13 03:36:20  lampret
// Added cfg regs. Moved all defines into one defines.v file. More cleanup.
//
// Revision 1.1  2001/08/09 13:39:33  lampret
// Major clean-up.
//
// Revision 1.2  2001/07/22 03:31:54  lampret
// Fixed RAM's oen bug. Cache bypass under development.
//
// Revision 1.1  2001/07/20 00:46:03  lampret
// Development version of RTL. Libraries are missing.
//
//

//
// Dump VCD
//
//`define OR1200_VCD_DUMP

//
// Generate debug messages during simulation
//
//`define OR1200_VERBOSE

//  `define OR1200_ASIC
////////////////////////////////////////////////////////
//
// Typical configuration for an ASIC
//
`ifdef OR1200_ASIC

//
// Target ASIC memories
//
//`define OR1200_ARTISAN_SSP
//`define OR1200_ARTISAN_SDP
//`define OR1200_ARTISAN_STP
`define OR1200_VIRTUALSILICON_SSP
//`define OR1200_VIRTUALSILICON_STP_T1
//`define OR1200_VIRTUALSILICON_STP_T2

//
// Do not implement Data cache
//
`define OR1200_NO_DC

//
// Do not implement Insn cache
//
`define OR1200_NO_IC

//
// Do not implement Data MMU
//
`define OR1200_NO_DMMU

//
// Do not implement Insn MMU
//
`define OR1200_NO_IMMU

//
// Select between ASIC optimized and generic multiplier
//
//`define OR1200_ASIC_MULTP2_32X32
`define OR1200_GENERIC_MULTP2_32X32

//
// Size/type of insn/data cache if implemented
//
// `define OR1200_IC_1W_512B
// `define OR1200_IC_1W_4KB
`define OR1200_IC_1W_8KB
// `define OR1200_DC_1W_4KB
`define OR1200_DC_1W_8KB

`else


/////////////////////////////////////////////////////////
//
// Typical configuration for an FPGA
//

//
// Target FPGA memories
//
//`define OR1200_ALTERA_LPM
//`define OR1200_XILINX_RAMB16
//`define OR1200_XILINX_RAMB4
//`define OR1200_XILINX_RAM32X1D
//`define OR1200_USE_RAM16X1D_FOR_RAM32X1D
`define OR1200_RAM_MODELS_VIRTEX
`define BLK_MEM_GEN


//
// Do not implement Data cache
//
//`define OR1200_NO_DC

//
// Do not implement Insn cache
//
//`define OR1200_NO_IC

//
// Do not implement Data MMU
//
//`define OR1200_NO_DMMU

//
// Do not implement Insn MMU
//
//`define OR1200_NO_IMMU

//
// Select between ASIC and generic multiplier
//
// (Generic seems to trigger a bug in the Cadence Ncsim simulator)
//
//`define OR1200_ASIC_MULTP2_32X32
`define OR1200_GENERIC_MULTP2_32X32

//
// Size/type of insn/data cache if implemented
// (consider available FPGA memory resources)
//
//`define OR1200_IC_1W_512B
`define OR1200_IC_1W_4KB
//`define OR1200_IC_1W_8KB
`define OR1200_DC_1W_4KB
//`define OR1200_DC_1W_8KB

`endif


//////////////////////////////////////////////////////////
//
// Do not change below unless you know what you are doing
//

//
// Enable RAM BIST
//
// At the moment this only works for Virtual Silicon
// single port RAMs. For other RAMs it has not effect.
// Special wrapper for VS RAMs needs to be provided
// with scan flops to facilitate bist scan.
//
//`define OR1200_BIST

//
// Register OR1200 WISHBONE outputs
// (must be defined/enabled)
//
`define OR1200_REGISTERED_OUTPUTS

//
// Register OR1200 WISHBONE inputs
//
// (must be undefined/disabled)
//
//`define OR1200_REGISTERED_INPUTS

//
// Disable bursts if they are not supported by the
// memory subsystem (only affect cache line fill)
//
//`define OR1200_NO_BURSTS
//

//
// WISHBONE retry counter range
//
// 2^value range for retry counter. Retry counter
// is activated whenever *wb_rty_i is asserted and
// until retry counter expires, corresponding
// WISHBONE interface is deactivated.
//
// To disable retry counters and *wb_rty_i all together,
// undefine this macro.
//
//`define OR1200_WB_RETRY 7

//
// WISHBONE Consecutive Address Burst
//
// This was used prior to WISHBONE B3 specification
// to identify bursts. It is no longer needed but
// remains enabled for compatibility with old designs.
//
// To remove *wb_cab_o ports undefine this macro.
//
`define OR1200_WB_CAB

//
// WISHBONE B3 compatible interface
//
// This follows the WISHBONE B3 specification.
// It is not enabled by default because most
// designs still don't use WB b3.
//
// To enable *wb_cti_o/*wb_bte_o ports,
// define this macro.
//
//`define OR1200_WB_B3

//
// Enable additional synthesis directives if using
// _Synopsys_ synthesis tool
//
//`define OR1200_ADDITIONAL_SYNOPSYS_DIRECTIVES

//
// Enables default statement in some case blocks
// and disables Synopsys synthesis directive full_case
//
// By default it is enabled. When disabled it
// can increase clock frequency.
//
`define OR1200_CASE_DEFAULT

//
// Operand width / register file address width
//
// (DO NOT CHANGE)
//
`define OR1200_OPERAND_WIDTH		32
`define OR1200_REGFILE_ADDR_WIDTH	5

//
// l.add/l.addi/l.and and optional l.addc/l.addic
// also set (compare) flag when result of their
// operation equals zero
//
// At the time of writing this, default or32
// C/C++ compiler doesn't generate code that
// would benefit from this optimization.
//
// By default this optimization is disabled to
// save area.
//
//`define OR1200_ADDITIONAL_FLAG_MODIFIERS

//
// Implement l.addc/l.addic instructions
//
// By default implementation of l.addc/l.addic
// instructions is enabled in case you need them.
// If you don't use them, then disable implementation
// to save area.
//
`define OR1200_IMPL_ADDC

//
// Implement carry bit SR[CY]
//
// By default implementation of SR[CY] is enabled
// to be compliant with the simulator. However
// SR[CY] is explicitly only used by l.addc/l.addic
// instructions and if these two insns are not
// implemented there is not much point having SR[CY].
//
`define OR1200_IMPL_CY

//
// Implement optional l.div/l.divu instructions
//
// By default divide instructions are not implemented
// to save area and increase clock frequency. or32 C/C++
// compiler can use soft library for division.
//
// To implement divide, multiplier needs to be implemented.
//
//`define OR1200_IMPL_DIV

//
// Implement rotate in the ALU
//
// At the time of writing this, or32
// C/C++ compiler doesn't generate rotate
// instructions. However or32 assembler
// can assemble code that uses rotate insn.
// This means that rotate instructions
// must be used manually inserted.
//
// By default implementation of rotate
// is disabled to save area and increase
// clock frequency.
//
//`define OR1200_IMPL_ALU_ROTATE

//
// Type of ALU compare to implement
//
// Try either one to find what yields
// higher clock frequencyin your case.
//
//`define OR1200_IMPL_ALU_COMP1
`define OR1200_IMPL_ALU_COMP2

//
// Implement multiplier
//
// By default multiplier is implemented
//
`define OR1200_MULT_IMPLEMENTED

//
// Implement multiply-and-accumulate
//
// By default MAC is implemented. To
// implement MAC, multiplier needs to be
// implemented.
//
`define OR1200_MAC_IMPLEMENTED

//
// Low power, slower multiplier
//
// Select between low-power (larger) multiplier
// and faster multiplier. The actual difference
// is only AND logic that prevents distribution
// of operands into the multiplier when instruction
// in execution is not multiply instruction
//
//`define OR1200_LOWPWR_MULT

//
// Clock ratio RISC clock versus WB clock
//
// If you plan to run WB:RISC clock fixed to 1:1, disable
// both defines
//
// For WB:RISC 1:2 or 1:1, enable OR1200_CLKDIV_2_SUPPORTED
// and use clmode to set ratio
//
// For WB:RISC 1:4, 1:2 or 1:1, enable both defines and use
// clmode to set ratio
//
`define OR1200_CLKDIV_2_SUPPORTED
//`define OR1200_CLKDIV_4_SUPPORTED

//
// Type of register file RAM
//
// Memory macro w/ two ports (see or1200_tpram_32x32.v)
//`define OR1200_RFRAM_TWOPORT
//
// Memory macro dual port (see or1200_dpram_32x32.v)
//`define OR1200_RFRAM_DUALPORT
//
// Generic (flip-flop based) register file (see or1200_rfram_generic.v)
//`define OR1200_RFRAM_GENERIC

//
// Type of mem2reg aligner to implement.
//
// Once OR1200_IMPL_MEM2REG2 yielded faster
// circuit, however with today tools it will
// most probably give you slower circuit.
//
`define OR1200_IMPL_MEM2REG1
//`define OR1200_IMPL_MEM2REG2

//
// ALUOPs
//
`define OR1200_ALUOP_WIDTH	4
`define OR1200_ALUOP_NOP	4'd4
/* Order defined by arith insns that have two source operands both in regs
   (see binutils/include/opcode/or32.h) */
`define OR1200_ALUOP_ADD	4'd0
`define OR1200_ALUOP_ADDC	4'd1
`define OR1200_ALUOP_SUB	4'd2
`define OR1200_ALUOP_AND	4'd3
`define OR1200_ALUOP_OR		4'd4
`define OR1200_ALUOP_XOR	4'd5
`define OR1200_ALUOP_MUL	4'd6
`define OR1200_ALUOP_CUST5	4'd7
`define OR1200_ALUOP_SHROT	4'd8
`define OR1200_ALUOP_DIV	4'd9
`define OR1200_ALUOP_DIVU	4'd10
/* Order not specifically defined. */
`define OR1200_ALUOP_IMM	4'd11
`define OR1200_ALUOP_MOVHI	4'd12
`define OR1200_ALUOP_COMP	4'd13
`define OR1200_ALUOP_MTSR	4'd14
`define OR1200_ALUOP_MFSR	4'd15
`define OR1200_ALUOP_CMOV 4'd14
`define OR1200_ALUOP_FF1  4'd15
//
// MACOPs
//
`define OR1200_MACOP_WIDTH	2
`define OR1200_MACOP_NOP	2'b00
`define OR1200_MACOP_MAC	2'b01
`define OR1200_MACOP_MSB	2'b10

//
// Shift/rotate ops
//
`define OR1200_SHROTOP_WIDTH	2
`define OR1200_SHROTOP_NOP	2'd0
`define OR1200_SHROTOP_SLL	2'd0
`define OR1200_SHROTOP_SRL	2'd1
`define OR1200_SHROTOP_SRA	2'd2
`define OR1200_SHROTOP_ROR	2'd3

// Execution cycles per instruction
`define OR1200_MULTICYCLE_WIDTH	2
`define OR1200_ONE_CYCLE		2'd0
`define OR1200_TWO_CYCLES		2'd1

// Operand MUX selects
`define OR1200_SEL_WIDTH		2
`define OR1200_SEL_RF			2'd0
`define OR1200_SEL_IMM			2'd1
`define OR1200_SEL_EX_FORW		2'd2
`define OR1200_SEL_WB_FORW		2'd3

//
// BRANCHOPs
//
`define OR1200_BRANCHOP_WIDTH		3
`define OR1200_BRANCHOP_NOP		3'd0
`define OR1200_BRANCHOP_J		3'd1
`define OR1200_BRANCHOP_JR		3'd2
`define OR1200_BRANCHOP_BAL		3'd3
`define OR1200_BRANCHOP_BF		3'd4
`define OR1200_BRANCHOP_BNF		3'd5
`define OR1200_BRANCHOP_RFE		3'd6

//
// LSUOPs
//
// Bit 0: sign extend
// Bits 1-2: 00 doubleword, 01 byte, 10 halfword, 11 singleword
// Bit 3: 0 load, 1 store
`define OR1200_LSUOP_WIDTH		4
`define OR1200_LSUOP_NOP		4'b0000
`define OR1200_LSUOP_LBZ		4'b0010
`define OR1200_LSUOP_LBS		4'b0011
`define OR1200_LSUOP_LHZ		4'b0100
`define OR1200_LSUOP_LHS		4'b0101
`define OR1200_LSUOP_LWZ		4'b0110
`define OR1200_LSUOP_LWS		4'b0111
`define OR1200_LSUOP_LD		4'b0001
`define OR1200_LSUOP_SD		4'b1000
`define OR1200_LSUOP_SB		4'b1010
`define OR1200_LSUOP_SH		4'b1100
`define OR1200_LSUOP_SW		4'b1110

// FETCHOPs
`define OR1200_FETCHOP_WIDTH		1
`define OR1200_FETCHOP_NOP		1'b0
`define OR1200_FETCHOP_LW		1'b1

//
// Register File Write-Back OPs
//
// Bit 0: register file write enable
// Bits 2-1: write-back mux selects
`define OR1200_RFWBOP_WIDTH		3
`define OR1200_RFWBOP_NOP		3'b000
`define OR1200_RFWBOP_ALU		3'b001
`define OR1200_RFWBOP_LSU		3'b011
`define OR1200_RFWBOP_SPRS		3'b101
`define OR1200_RFWBOP_LR		3'b111

// Compare instructions
`define OR1200_COP_SFEQ       3'b000
`define OR1200_COP_SFNE       3'b001
`define OR1200_COP_SFGT       3'b010
`define OR1200_COP_SFGE       3'b011
`define OR1200_COP_SFLT       3'b100
`define OR1200_COP_SFLE       3'b101
`define OR1200_COP_X          3'b111
`define OR1200_SIGNED_COMPARE 'd3
`define OR1200_COMPOP_WIDTH	4

//
// TAGs for instruction bus
//
`define OR1200_ITAG_IDLE	4'h0	// idle bus
`define	OR1200_ITAG_NI		4'h1	// normal insn
`define OR1200_ITAG_BE		4'hb	// Bus error exception
`define OR1200_ITAG_PE		4'hc	// Page fault exception
`define OR1200_ITAG_TE		4'hd	// TLB miss exception

//
// TAGs for data bus
//
`define OR1200_DTAG_IDLE	4'h0	// idle bus
`define	OR1200_DTAG_ND		4'h1	// normal data
`define OR1200_DTAG_AE		4'ha	// Alignment exception
`define OR1200_DTAG_BE		4'hb	// Bus error exception
`define OR1200_DTAG_PE		4'hc	// Page fault exception
`define OR1200_DTAG_TE		4'hd	// TLB miss exception


//////////////////////////////////////////////
//
// ORBIS32 ISA specifics
//

// SHROT_OP position in machine word
`define OR1200_SHROTOP_POS		7:6

// ALU instructions multicycle field in machine word
`define OR1200_ALUMCYC_POS		9:8

//
// Instruction opcode groups (basic)
//
`define OR1200_OR32_J                 6'b000000
`define OR1200_OR32_JAL               6'b000001
`define OR1200_OR32_BNF               6'b000011
`define OR1200_OR32_BF                6'b000100
`define OR1200_OR32_NOP               6'b000101
`define OR1200_OR32_MOVHI             6'b000110
`define OR1200_OR32_XSYNC             6'b001000
`define OR1200_OR32_RFE               6'b001001
/* */
`define OR1200_OR32_JR                6'b010001
`define OR1200_OR32_JALR              6'b010010
`define OR1200_OR32_MACI              6'b010011
/* */
`define OR1200_OR32_LWZ               6'b100001
`define OR1200_OR32_LBZ               6'b100011
`define OR1200_OR32_LBS               6'b100100
`define OR1200_OR32_LHZ               6'b100101
`define OR1200_OR32_LHS               6'b100110
`define OR1200_OR32_ADDI              6'b100111
`define OR1200_OR32_ADDIC             6'b101000
`define OR1200_OR32_ANDI              6'b101001
`define OR1200_OR32_ORI               6'b101010
`define OR1200_OR32_XORI              6'b101011
`define OR1200_OR32_MULI              6'b101100
`define OR1200_OR32_MFSPR             6'b101101
`define OR1200_OR32_SH_ROTI 	      6'b101110
`define OR1200_OR32_SFXXI             6'b101111
/* */
`define OR1200_OR32_MTSPR             6'b110000
`define OR1200_OR32_MACMSB            6'b110001
/* */
`define OR1200_OR32_SW                6'b110101
`define OR1200_OR32_SB                6'b110110
`define OR1200_OR32_SH                6'b110111
`define OR1200_OR32_ALU               6'b111000
`define OR1200_OR32_SFXX              6'b111001
//`define OR1200_OR32_CUST5             6'b111100


/////////////////////////////////////////////////////
//
// Exceptions
//

//
// Exception vectors per OR1K architecture:
// 0xPPPPP100 - reset
// 0xPPPPP200 - bus error
// ... etc
// where P represents exception prefix.
//
// Exception vectors can be customized as per
// the following formula:
// 0xPPPPPNVV - exception N
//
// P represents exception prefix
// N represents exception N
// VV represents length of the individual vector space,
//   usually it is 8 bits wide and starts with all bits zero
//

//
// PPPPP and VV parts
//
// Sum of these two defines needs to be 28
//
`define OR1200_EXCEPT_EPH0_P 20'h00000
`define OR1200_EXCEPT_EPH1_P 20'hF0000
`define OR1200_EXCEPT_V		   8'h00

//
// N part width
//
`define OR1200_EXCEPT_WIDTH 4

//
// Definition of exception vectors
//
// To avoid implementation of a certain exception,
// simply comment out corresponding line
//
`define OR1200_EXCEPT_UNUSED		`OR1200_EXCEPT_WIDTH'hf
`define OR1200_EXCEPT_TRAP		`OR1200_EXCEPT_WIDTH'he
`define OR1200_EXCEPT_BREAK		`OR1200_EXCEPT_WIDTH'hd
`define OR1200_EXCEPT_SYSCALL		`OR1200_EXCEPT_WIDTH'hc
`define OR1200_EXCEPT_RANGE		`OR1200_EXCEPT_WIDTH'hb
`define OR1200_EXCEPT_ITLBMISS		`OR1200_EXCEPT_WIDTH'ha
`define OR1200_EXCEPT_DTLBMISS		`OR1200_EXCEPT_WIDTH'h9
`define OR1200_EXCEPT_INT		`OR1200_EXCEPT_WIDTH'h8
`define OR1200_EXCEPT_ILLEGAL		`OR1200_EXCEPT_WIDTH'h7
`define OR1200_EXCEPT_ALIGN		`OR1200_EXCEPT_WIDTH'h6
`define OR1200_EXCEPT_TICK		`OR1200_EXCEPT_WIDTH'h5
`define OR1200_EXCEPT_IPF		`OR1200_EXCEPT_WIDTH'h4
`define OR1200_EXCEPT_DPF		`OR1200_EXCEPT_WIDTH'h3
`define OR1200_EXCEPT_BUSERR		`OR1200_EXCEPT_WIDTH'h2
`define OR1200_EXCEPT_RESET		`OR1200_EXCEPT_WIDTH'h1
`define OR1200_EXCEPT_NONE		`OR1200_EXCEPT_WIDTH'h0


/////////////////////////////////////////////////////
//
// SPR groups
//

// Bits that define the group
`define OR1200_SPR_GROUP_BITS	15:11

// Width of the group bits
`define OR1200_SPR_GROUP_WIDTH 	5

// Bits that define offset inside the group
`define OR1200_SPR_OFS_BITS 10:0

// List of groups
`define OR1200_SPR_GROUP_SYS	5'd00
`define OR1200_SPR_GROUP_DMMU	5'd01
`define OR1200_SPR_GROUP_IMMU	5'd02
`define OR1200_SPR_GROUP_DC	5'd03
`define OR1200_SPR_GROUP_IC	5'd04
`define OR1200_SPR_GROUP_MAC	5'd05
`define OR1200_SPR_GROUP_DU	5'd06
`define OR1200_SPR_GROUP_PM	5'd08
`define OR1200_SPR_GROUP_PIC	5'd09
`define OR1200_SPR_GROUP_TT	5'd10


/////////////////////////////////////////////////////
//
// System group
//

//
// System registers
//
`define OR1200_SPR_CFGR		7'd0
`define OR1200_SPR_RF		6'd32	// 1024 >> 5
`define OR1200_SPR_NPC		11'd16
`define OR1200_SPR_SR		11'd17
`define OR1200_SPR_PPC		11'd18
`define OR1200_SPR_EPCR		11'd32
`define OR1200_SPR_EEAR		11'd48
`define OR1200_SPR_ESR		11'd64

//
// SR bits
//
`define OR1200_SR_WIDTH 16
`define OR1200_SR_SM   0
`define OR1200_SR_TEE  1
`define OR1200_SR_IEE  2
`define OR1200_SR_DCE  3
`define OR1200_SR_ICE  4
`define OR1200_SR_DME  5
`define OR1200_SR_IME  6
`define OR1200_SR_LEE  7
`define OR1200_SR_CE   8
`define OR1200_SR_F    9
`define OR1200_SR_CY   10	// Unused
`define OR1200_SR_OV   11	// Unused
`define OR1200_SR_OVE  12	// Unused
`define OR1200_SR_DSX  13	// Unused
`define OR1200_SR_EPH  14
`define OR1200_SR_FO   15
`define OR1200_SR_CID  31:28	// Unimplemented

//
// Bits that define offset inside the group
//
`define OR1200_SPROFS_BITS 10:0

//
// Default Exception Prefix
//
// 1'b0 - OR1200_EXCEPT_EPH0_P (0x0000_0000)
// 1'b1 - OR1200_EXCEPT_EPH1_P (0xF000_0000)
//
`define OR1200_SR_EPH_DEF	1'b0

/////////////////////////////////////////////////////
//
// Power Management (PM)
//

// Define it if you want PM implemented
`define OR1200_PM_IMPLEMENTED

// Bit positions inside PMR (don't change)
`define OR1200_PM_PMR_SDF 3:0
`define OR1200_PM_PMR_DME 4
`define OR1200_PM_PMR_SME 5
`define OR1200_PM_PMR_DCGE 6
`define OR1200_PM_PMR_UNUSED 31:7

// PMR offset inside PM group of registers
`define OR1200_PM_OFS_PMR 11'b0

// PM group
`define OR1200_SPRGRP_PM 5'd8

// Define if PMR can be read/written at any address inside PM group
`define OR1200_PM_PARTIAL_DECODING

// Define if reading PMR is allowed
`define OR1200_PM_READREGS

// Define if unused PMR bits should be zero
`define OR1200_PM_UNUSED_ZERO


/////////////////////////////////////////////////////
//
// Debug Unit (DU)
//

// Define it if you want DU implemented
`define OR1200_DU_IMPLEMENTED

//
// Define if you want HW Breakpoints
// (if HW breakpoints are not implemented
// only default software trapping is
// possible with l.trap insn - this is
// however already enough for use
// with or32 gdb)
//
//`define OR1200_DU_HWBKPTS

// Number of DVR/DCR pairs if HW breakpoints enabled
`define OR1200_DU_DVRDCR_PAIRS 8

// Define if you want trace buffer
//`define OR1200_DU_TB_IMPLEMENTED

//
// Address offsets of DU registers inside DU group
//
// To not implement a register, doq not define its address
//
`ifdef OR1200_DU_HWBKPTS
`define OR1200_DU_DVR0		11'd0
`define OR1200_DU_DVR1		11'd1
`define OR1200_DU_DVR2		11'd2
`define OR1200_DU_DVR3		11'd3
`define OR1200_DU_DVR4		11'd4
`define OR1200_DU_DVR5		11'd5
`define OR1200_DU_DVR6		11'd6
`define OR1200_DU_DVR7		11'd7
`define OR1200_DU_DCR0		11'd8
`define OR1200_DU_DCR1		11'd9
`define OR1200_DU_DCR2		11'd10
`define OR1200_DU_DCR3		11'd11
`define OR1200_DU_DCR4		11'd12
`define OR1200_DU_DCR5		11'd13
`define OR1200_DU_DCR6		11'd14
`define OR1200_DU_DCR7		11'd15
`endif
`define OR1200_DU_DMR1		11'd16
`ifdef OR1200_DU_HWBKPTS
`define OR1200_DU_DMR2		11'd17
`define OR1200_DU_DWCR0		11'd18
`define OR1200_DU_DWCR1		11'd19
`endif
`define OR1200_DU_DSR		11'd20
`define OR1200_DU_DRR		11'd21
`ifdef OR1200_DU_TB_IMPLEMENTED
`define OR1200_DU_TBADR		11'h0ff
`define OR1200_DU_TBIA		11'h1xx
`define OR1200_DU_TBIM		11'h2xx
`define OR1200_DU_TBAR		11'h3xx
`define OR1200_DU_TBTS		11'h4xx
`endif

// Position of offset bits inside SPR address
`define OR1200_DUOFS_BITS	10:0

// DCR bits
`define OR1200_DU_DCR_DP	0
`define OR1200_DU_DCR_CC	3:1
`define OR1200_DU_DCR_SC	4
`define OR1200_DU_DCR_CT	7:5

// DMR1 bits
`define OR1200_DU_DMR1_CW0	1:0
`define OR1200_DU_DMR1_CW1	3:2
`define OR1200_DU_DMR1_CW2	5:4
`define OR1200_DU_DMR1_CW3	7:6
`define OR1200_DU_DMR1_CW4	9:8
`define OR1200_DU_DMR1_CW5	11:10
`define OR1200_DU_DMR1_CW6	13:12
`define OR1200_DU_DMR1_CW7	15:14
`define OR1200_DU_DMR1_CW8	17:16
`define OR1200_DU_DMR1_CW9	19:18
`define OR1200_DU_DMR1_CW10	21:20
`define OR1200_DU_DMR1_ST	22
`define OR1200_DU_DMR1_BT	23
`define OR1200_DU_DMR1_DXFW	24
`define OR1200_DU_DMR1_ETE	25

// DMR2 bits
`define OR1200_DU_DMR2_WCE0	0
`define OR1200_DU_DMR2_WCE1	1
`define OR1200_DU_DMR2_AWTC	12:2
`define OR1200_DU_DMR2_WGB	23:13

// DWCR bits
`define OR1200_DU_DWCR_COUNT	15:0
`define OR1200_DU_DWCR_MATCH	31:16

// DSR bits
`define OR1200_DU_DSR_WIDTH	14
`define OR1200_DU_DSR_RSTE	0
`define OR1200_DU_DSR_BUSEE	1
`define OR1200_DU_DSR_DPFE	2
`define OR1200_DU_DSR_IPFE	3
`define OR1200_DU_DSR_TTE	4
`define OR1200_DU_DSR_AE	5
`define OR1200_DU_DSR_IIE	6
`define OR1200_DU_DSR_IE	7
`define OR1200_DU_DSR_DME	8
`define OR1200_DU_DSR_IME	9
`define OR1200_DU_DSR_RE	10
`define OR1200_DU_DSR_SCE	11
`define OR1200_DU_DSR_BE	12
`define OR1200_DU_DSR_TE	13

// DRR bits
`define OR1200_DU_DRR_RSTE	0
`define OR1200_DU_DRR_BUSEE	1
`define OR1200_DU_DRR_DPFE	2
`define OR1200_DU_DRR_IPFE	3
`define OR1200_DU_DRR_TTE	4
`define OR1200_DU_DRR_AE	5
`define OR1200_DU_DRR_IIE	6
`define OR1200_DU_DRR_IE	7
`define OR1200_DU_DRR_DME	8
`define OR1200_DU_DRR_IME	9
`define OR1200_DU_DRR_RE	10
`define OR1200_DU_DRR_SCE	11
`define OR1200_DU_DRR_BE	12
`define OR1200_DU_DRR_TE	13

// Define if reading DU regs is allowed
`define OR1200_DU_READREGS

// Define if unused DU registers bits should be zero
`define OR1200_DU_UNUSED_ZERO

// Define if IF/LSU status is not needed by devel i/f
`define OR1200_DU_STATUS_UNIMPLEMENTED

/////////////////////////////////////////////////////
//
// Programmable Interrupt Controller (PIC)
//

// Define it if you want PIC implemented
`define OR1200_PIC_IMPLEMENTED

// Define number of interrupt inputs (2-31)
`define OR1200_PIC_INTS 20

// Address offsets of PIC registers inside PIC group
`define OR1200_PIC_OFS_PICMR 2'd0
`define OR1200_PIC_OFS_PICSR 2'd2

// Position of offset bits inside SPR address
`define OR1200_PICOFS_BITS 1:0

// Define if you want these PIC registers to be implemented
`define OR1200_PIC_PICMR
`define OR1200_PIC_PICSR

// Define if reading PIC registers is allowed
`define OR1200_PIC_READREGS

// Define if unused PIC register bits should be zero
`define OR1200_PIC_UNUSED_ZERO


/////////////////////////////////////////////////////
//
// Tick Timer (TT)
//

// Define it if you want TT implemented
`define OR1200_TT_IMPLEMENTED

// Address offsets of TT registers inside TT group
`define OR1200_TT_OFS_TTMR 1'd0
`define OR1200_TT_OFS_TTCR 1'd1

// Position of offset bits inside SPR group
`define OR1200_TTOFS_BITS 0

// Define if you want these TT registers to be implemented
`define OR1200_TT_TTMR
`define OR1200_TT_TTCR

// TTMR bits
`define OR1200_TT_TTMR_TP 27:0
`define OR1200_TT_TTMR_IP 28
`define OR1200_TT_TTMR_IE 29
`define OR1200_TT_TTMR_M 31:30

// Define if reading TT registers is allowed
`define OR1200_TT_READREGS


//////////////////////////////////////////////
//
// MAC
//
`define OR1200_MAC_ADDR		0	// MACLO 0xxxxxxxx1, MACHI 0xxxxxxxx0
`define OR1200_MAC_SPR_WE		// Define if MACLO/MACHI are SPR writable

//
// Shift {MACHI,MACLO} into destination register when executing l.macrc
//
// According to architecture manual there is no shift, so default value is 0.
//
// However the implementation has deviated in this from the arch manual and had hard coded shift by 28 bits which
// is a useful optimization for MP3 decoding (if using libmad fixed point library). Shifts are no longer
// default setup, but if you need to remain backward compatible, define your shift bits, which were normally
// dest_GPR = {MACHI,MACLO}[59:28]
`define OR1200_MAC_SHIFTBY	0	// 0 = According to arch manual, 28 = obsolete backward compatibility


//////////////////////////////////////////////
//
// Data MMU (DMMU)
//

//
// Address that selects between TLB TR and MR
//
`define OR1200_DTLB_TM_ADDR	7

//
// DTLBMR fields
//
`define	OR1200_DTLBMR_V_BITS	0
`define	OR1200_DTLBMR_CID_BITS	4:1
`define	OR1200_DTLBMR_RES_BITS	11:5
`define OR1200_DTLBMR_VPN_BITS	31:13

//
// DTLBTR fields
//
`define	OR1200_DTLBTR_CC_BITS	0
`define	OR1200_DTLBTR_CI_BITS	1
`define	OR1200_DTLBTR_WBC_BITS	2
`define	OR1200_DTLBTR_WOM_BITS	3
`define	OR1200_DTLBTR_A_BITS	4
`define	OR1200_DTLBTR_D_BITS	5
`define	OR1200_DTLBTR_URE_BITS	6
`define	OR1200_DTLBTR_UWE_BITS	7
`define	OR1200_DTLBTR_SRE_BITS	8
`define	OR1200_DTLBTR_SWE_BITS	9
`define	OR1200_DTLBTR_RES_BITS	11:10
`define OR1200_DTLBTR_PPN_BITS	31:13

//
// DTLB configuration
//
`define	OR1200_DMMU_PS		13					// 13 for 8KB page size
`define	OR1200_DTLB_INDXW	6					// 6 for 64 entry DTLB	7 for 128 entries
`define OR1200_DTLB_INDXL	`OR1200_DMMU_PS				// 13			13
`define OR1200_DTLB_INDXH	`OR1200_DMMU_PS+`OR1200_DTLB_INDXW-1	// 18			19
`define	OR1200_DTLB_INDX	`OR1200_DTLB_INDXH:`OR1200_DTLB_INDXL	// 18:13		19:13
`define OR1200_DTLB_TAGW	32-`OR1200_DTLB_INDXW-`OR1200_DMMU_PS	// 13			12
`define OR1200_DTLB_TAGL	`OR1200_DTLB_INDXH+1			// 19			20
`define	OR1200_DTLB_TAG		31:`OR1200_DTLB_TAGL			// 31:19		31:20
`define	OR1200_DTLBMRW		`OR1200_DTLB_TAGW+1			// +1 because of V bit
`define	OR1200_DTLBTRW		32-`OR1200_DMMU_PS+5			// +5 because of protection bits and CI

//
// Cache inhibit while DMMU is not enabled/implemented
//
// cache inhibited 0GB-4GB		1'b1
// cache inhibited 0GB-2GB		!dcpu_adr_i[31]
// cache inhibited 0GB-1GB 2GB-3GB	!dcpu_adr_i[30]
// cache inhibited 1GB-2GB 3GB-4GB	dcpu_adr_i[30]
// cache inhibited 2GB-4GB (default)	dcpu_adr_i[31]
// cached 0GB-4GB			1'b0
//
`define OR1200_DMMU_CI			dcpu_adr_i[31]


//////////////////////////////////////////////
//
// Insn MMU (IMMU)
//

//
// Address that selects between TLB TR and MR
//
`define OR1200_ITLB_TM_ADDR	7

//
// ITLBMR fields
//
`define	OR1200_ITLBMR_V_BITS	0
`define	OR1200_ITLBMR_CID_BITS	4:1
`define	OR1200_ITLBMR_RES_BITS	11:5
`define OR1200_ITLBMR_VPN_BITS	31:13

//
// ITLBTR fields
//
`define	OR1200_ITLBTR_CC_BITS	0
`define	OR1200_ITLBTR_CI_BITS	1
`define	OR1200_ITLBTR_WBC_BITS	2
`define	OR1200_ITLBTR_WOM_BITS	3
`define	OR1200_ITLBTR_A_BITS	4
`define	OR1200_ITLBTR_D_BITS	5
`define	OR1200_ITLBTR_SXE_BITS	6
`define	OR1200_ITLBTR_UXE_BITS	7
`define	OR1200_ITLBTR_RES_BITS	11:8
`define OR1200_ITLBTR_PPN_BITS	31:13

//
// ITLB configuration
//
`define	OR1200_IMMU_PS		13					// 13 for 8KB page size
`define	OR1200_ITLB_INDXW	6					// 6 for 64 entry ITLB	7 for 128 entries
`define OR1200_ITLB_INDXL	`OR1200_IMMU_PS				// 13			13
`define OR1200_ITLB_INDXH	`OR1200_IMMU_PS+`OR1200_ITLB_INDXW-1	// 18			19
`define	OR1200_ITLB_INDX	`OR1200_ITLB_INDXH:`OR1200_ITLB_INDXL	// 18:13		19:13
`define OR1200_ITLB_TAGW	32-`OR1200_ITLB_INDXW-`OR1200_IMMU_PS	// 13			12
`define OR1200_ITLB_TAGL	`OR1200_ITLB_INDXH+1			// 19			20
`define	OR1200_ITLB_TAG		31:`OR1200_ITLB_TAGL			// 31:19		31:20
`define	OR1200_ITLBMRW		`OR1200_ITLB_TAGW+1			// +1 because of V bit
`define	OR1200_ITLBTRW		32-`OR1200_IMMU_PS+3			// +3 because of protection bits and CI

//
// Cache inhibit while IMMU is not enabled/implemented
// Note: all combinations that use icpu_adr_i cause async loop
//
// cache inhibited 0GB-4GB		1'b1
// cache inhibited 0GB-2GB		!icpu_adr_i[31]
// cache inhibited 0GB-1GB 2GB-3GB	!icpu_adr_i[30]
// cache inhibited 1GB-2GB 3GB-4GB	icpu_adr_i[30]
// cache inhibited 2GB-4GB (default)	icpu_adr_i[31]
// cached 0GB-4GB			1'b0
//
`define OR1200_IMMU_CI			1'b0


/////////////////////////////////////////////////
//
// Insn cache (IC)
//

// 3 for 8 bytes, 4 for 16 bytes etc
`define OR1200_ICLS		4

//
// IC configurations
//
`ifdef OR1200_IC_1W_512B
`define OR1200_ICSIZE   9     // 512
`define OR1200_ICINDX   `OR1200_ICSIZE-2 // 7
`define OR1200_ICINDXH  `OR1200_ICSIZE-1 // 8
`define OR1200_ICTAGL   `OR1200_ICINDXH+1 // 9
`define OR1200_ICTAG    `OR1200_ICSIZE-`OR1200_ICLS // 5
`define OR1200_ICTAG_W  24
`endif
`ifdef OR1200_IC_1W_4KB
`define OR1200_ICSIZE			12			// 4096
`define OR1200_ICINDX			`OR1200_ICSIZE-2	// 10
`define OR1200_ICINDXH			`OR1200_ICSIZE-1	// 11
`define OR1200_ICTAGL			`OR1200_ICINDXH+1	// 12
`define	OR1200_ICTAG			`OR1200_ICSIZE-`OR1200_ICLS	// 8
`define	OR1200_ICTAG_W			21
`endif
`ifdef OR1200_IC_1W_8KB
`define OR1200_ICSIZE			13			// 8192
`define OR1200_ICINDX			`OR1200_ICSIZE-2	// 11
`define OR1200_ICINDXH			`OR1200_ICSIZE-1	// 12
`define OR1200_ICTAGL			`OR1200_ICINDXH+1	// 13
`define	OR1200_ICTAG			`OR1200_ICSIZE-`OR1200_ICLS	// 9
`define	OR1200_ICTAG_W			20
`endif


/////////////////////////////////////////////////
//
// Data cache (DC)
//

// 3 for 8 bytes, 4 for 16 bytes etc
`define OR1200_DCLS		4

// Define to perform store refill (potential performance penalty)
// `define OR1200_DC_STORE_REFILL

//
// DC configurations
//
`ifdef OR1200_DC_1W_4KB
`define OR1200_DCSIZE			12			// 4096
`define OR1200_DCINDX			`OR1200_DCSIZE-2	// 10
`define OR1200_DCINDXH			`OR1200_DCSIZE-1	// 11
`define OR1200_DCTAGL			`OR1200_DCINDXH+1	// 12
`define	OR1200_DCTAG			`OR1200_DCSIZE-`OR1200_DCLS	// 8
`define	OR1200_DCTAG_W			21
`endif
`ifdef OR1200_DC_1W_8KB
`define OR1200_DCSIZE			13			// 8192
`define OR1200_DCINDX			`OR1200_DCSIZE-2	// 11
`define OR1200_DCINDXH			`OR1200_DCSIZE-1	// 12
`define OR1200_DCTAGL			`OR1200_DCINDXH+1	// 13
`define	OR1200_DCTAG			`OR1200_DCSIZE-`OR1200_DCLS	// 9
`define	OR1200_DCTAG_W			20
`endif

/////////////////////////////////////////////////
//
// Store buffer (SB)
//

//
// Store buffer
//
// It will improve performance by "caching" CPU stores
// using store buffer. This is most important for function
// prologues because DC can only work in write though mode
// and all stores would have to complete external WB writes
// to memory.
// Store buffer is between DC and data BIU.
// All stores will be stored into store buffer and immediately
// completed by the CPU, even though actual external writes
// will be performed later. As a consequence store buffer masks
// all data bus errors related to stores (data bus errors
// related to loads are delivered normally).
// All pending CPU loads will wait until store buffer is empty to
// ensure strict memory model. Right now this is necessary because
// we don't make destinction between cached and cache inhibited
// address space, so we simply empty store buffer until loads
// can begin.
//
// It makes design a bit bigger, depending what is the number of
// entries in SB FIFO. Number of entries can be changed further
// down.
//
//`define OR1200_SB_IMPLEMENTED

//
// Number of store buffer entries
//
// Verified number of entries are 4 and 8 entries
// (2 and 3 for OR1200_SB_LOG). OR1200_SB_ENTRIES must
// always match 2**OR1200_SB_LOG.
// To disable store buffer, undefine
// OR1200_SB_IMPLEMENTED.
//
`define OR1200_SB_LOG		2	// 2 or 3
`define OR1200_SB_ENTRIES	4	// 4 or 8


/////////////////////////////////////////////////
//
// Quick Embedded Memory (QMEM)
//

//
// Quick Embedded Memory
//
// Instantiation of dedicated insn/data memory (RAM or ROM).
// Insn fetch has effective throughput 1insn / clock cycle.
// Data load takes two clock cycles / access, data store
// takes 1 clock cycle / access (if there is no insn fetch)).
// Memory instantiation is shared between insn and data,
// meaning if insn fetch are performed, data load/store
// performance will be lower.
//
// Main reason for QMEM is to put some time critical functions
// into this memory and to have predictable and fast access
// to these functions. (soft fpu, context switch, exception
// handlers, stack, etc)
//
// It makes design a bit bigger and slower. QMEM sits behind
// IMMU/DMMU so all addresses are physical (so the MMUs can be
// used with QMEM and QMEM is seen by the CPU just like any other
// memory in the system). IC/DC are sitting behind QMEM so the
// whole design timing might be worse with QMEM implemented.
//
//`define OR1200_QMEM_IMPLEMENTED

//
// Base address and mask of QMEM
//
// Base address defines first address of QMEM. Mask defines
// QMEM range in address space. Actual size of QMEM is however
// determined with instantiated RAM/ROM. However bigger
// mask will reserve more address space for QMEM, but also
// make design faster, while more tight mask will take
// less address space but also make design slower. If
// instantiated RAM/ROM is smaller than space reserved with
// the mask, instatiated RAM/ROM will also be shadowed
// at higher addresses in reserved space.
//
`define OR1200_QMEM_IADDR	32'h0080_0000
`define OR1200_QMEM_IMASK	32'hfff0_0000	// Max QMEM size 1MB
`define OR1200_QMEM_DADDR  32'h0080_0000
`define OR1200_QMEM_DMASK  32'hfff0_0000 // Max QMEM size 1MB

//
// QMEM interface byte-select capability
//
// To enable qmem_sel* ports, define this macro.
//
//`define OR1200_QMEM_BSEL

//
// QMEM interface acknowledge
//
// To enable qmem_ack port, define this macro.
//
//`define OR1200_QMEM_ACK

/////////////////////////////////////////////////////
//
// VR, UPR and Configuration Registers
//
//
// VR, UPR and configuration registers are optional. If 
// implemented, operating system can automatically figure
// out how to use the processor because it knows 
// what units are available in the processor and how they
// are configured.
//
// This section must be last in or1200_defines.v file so
// that all units are already configured and thus
// configuration registers are properly set.
// 

// Define if you want configuration registers implemented
`define OR1200_CFGR_IMPLEMENTED

// Define if you want full address decode inside SYS group
`define OR1200_SYS_FULL_DECODE

// Offsets of VR, UPR and CFGR registers
`define OR1200_SPRGRP_SYS_VR		4'h0
`define OR1200_SPRGRP_SYS_UPR		4'h1
`define OR1200_SPRGRP_SYS_CPUCFGR	4'h2
`define OR1200_SPRGRP_SYS_DMMUCFGR	4'h3
`define OR1200_SPRGRP_SYS_IMMUCFGR	4'h4
`define OR1200_SPRGRP_SYS_DCCFGR	4'h5
`define OR1200_SPRGRP_SYS_ICCFGR	4'h6
`define OR1200_SPRGRP_SYS_DCFGR	4'h7

// VR fields
`define OR1200_VR_REV_BITS		5:0
`define OR1200_VR_RES1_BITS		15:6
`define OR1200_VR_CFG_BITS		23:16
`define OR1200_VR_VER_BITS		31:24

// VR values
`define OR1200_VR_REV			6'h01
`define OR1200_VR_RES1			10'h000
`define OR1200_VR_CFG			8'h00
`define OR1200_VR_VER			8'h12

// UPR fields
`define OR1200_UPR_UP_BITS		0
`define OR1200_UPR_DCP_BITS		1
`define OR1200_UPR_ICP_BITS		2
`define OR1200_UPR_DMP_BITS		3
`define OR1200_UPR_IMP_BITS		4
`define OR1200_UPR_MP_BITS		5
`define OR1200_UPR_DUP_BITS		6
`define OR1200_UPR_PCUP_BITS		7
`define OR1200_UPR_PMP_BITS		8
`define OR1200_UPR_PICP_BITS		9
`define OR1200_UPR_TTP_BITS		10
`define OR1200_UPR_RES1_BITS		23:11
`define OR1200_UPR_CUP_BITS		31:24

// UPR values
`define OR1200_UPR_UP			1'b1
`ifdef OR1200_NO_DC
`define OR1200_UPR_DCP			1'b0
`else
`define OR1200_UPR_DCP			1'b1
`endif
`ifdef OR1200_NO_IC
`define OR1200_UPR_ICP			1'b0
`else
`define OR1200_UPR_ICP			1'b1
`endif
`ifdef OR1200_NO_DMMU
`define OR1200_UPR_DMP			1'b0
`else
`define OR1200_UPR_DMP			1'b1
`endif
`ifdef OR1200_NO_IMMU
`define OR1200_UPR_IMP			1'b0
`else
`define OR1200_UPR_IMP			1'b1
`endif
`define OR1200_UPR_MP			1'b1	// MAC always present
`ifdef OR1200_DU_IMPLEMENTED
`define OR1200_UPR_DUP			1'b1
`else
`define OR1200_UPR_DUP			1'b0
`endif
`define OR1200_UPR_PCUP			1'b0	// Performance counters not present
`ifdef OR1200_DU_IMPLEMENTED
`define OR1200_UPR_PMP			1'b1
`else
`define OR1200_UPR_PMP			1'b0
`endif
`ifdef OR1200_DU_IMPLEMENTED
`define OR1200_UPR_PICP			1'b1
`else
`define OR1200_UPR_PICP			1'b0
`endif
`ifdef OR1200_DU_IMPLEMENTED
`define OR1200_UPR_TTP			1'b1
`else
`define OR1200_UPR_TTP			1'b0
`endif
`define OR1200_UPR_RES1			13'h0000
`define OR1200_UPR_CUP			8'h00

// CPUCFGR fields
`define OR1200_CPUCFGR_NSGF_BITS	3:0
`define OR1200_CPUCFGR_HGF_BITS	4
`define OR1200_CPUCFGR_OB32S_BITS	5
`define OR1200_CPUCFGR_OB64S_BITS	6
`define OR1200_CPUCFGR_OF32S_BITS	7
`define OR1200_CPUCFGR_OF64S_BITS	8
`define OR1200_CPUCFGR_OV64S_BITS	9
`define OR1200_CPUCFGR_RES1_BITS	31:10

// CPUCFGR values
`define OR1200_CPUCFGR_NSGF		4'h0
`define OR1200_CPUCFGR_HGF		1'b0
`define OR1200_CPUCFGR_OB32S		1'b1
`define OR1200_CPUCFGR_OB64S		1'b0
`define OR1200_CPUCFGR_OF32S		1'b0
`define OR1200_CPUCFGR_OF64S		1'b0
`define OR1200_CPUCFGR_OV64S		1'b0
`define OR1200_CPUCFGR_RES1		22'h000000

// DMMUCFGR fields
`define OR1200_DMMUCFGR_NTW_BITS	1:0
`define OR1200_DMMUCFGR_NTS_BITS	4:2
`define OR1200_DMMUCFGR_NAE_BITS	7:5
`define OR1200_DMMUCFGR_CRI_BITS	8
`define OR1200_DMMUCFGR_PRI_BITS	9
`define OR1200_DMMUCFGR_TEIRI_BITS	10
`define OR1200_DMMUCFGR_HTR_BITS	11
`define OR1200_DMMUCFGR_RES1_BITS	31:12

// DMMUCFGR values
`ifdef OR1200_NO_DMMU
`define OR1200_DMMUCFGR_NTW		2'h0	// Irrelevant
`define OR1200_DMMUCFGR_NTS		3'h0	// Irrelevant
`define OR1200_DMMUCFGR_NAE		3'h0	// Irrelevant
`define OR1200_DMMUCFGR_CRI		1'b0	// Irrelevant
`define OR1200_DMMUCFGR_PRI		1'b0	// Irrelevant
`define OR1200_DMMUCFGR_TEIRI		1'b0	// Irrelevant
`define OR1200_DMMUCFGR_HTR		1'b0	// Irrelevant
`define OR1200_DMMUCFGR_RES1		20'h00000
`else
`define OR1200_DMMUCFGR_NTW		2'h0	// 1 TLB way
`define OR1200_DMMUCFGR_NTS 3'h`OR1200_DTLB_INDXW	// Num TLB sets
`define OR1200_DMMUCFGR_NAE		3'h0	// No ATB entries
`define OR1200_DMMUCFGR_CRI		1'b0	// No control register
`define OR1200_DMMUCFGR_PRI		1'b0	// No protection reg
`define OR1200_DMMUCFGR_TEIRI		1'b1	// TLB entry inv reg impl.
`define OR1200_DMMUCFGR_HTR		1'b0	// No HW TLB reload
`define OR1200_DMMUCFGR_RES1		20'h00000
`endif

// IMMUCFGR fields
`define OR1200_IMMUCFGR_NTW_BITS	1:0
`define OR1200_IMMUCFGR_NTS_BITS	4:2
`define OR1200_IMMUCFGR_NAE_BITS	7:5
`define OR1200_IMMUCFGR_CRI_BITS	8
`define OR1200_IMMUCFGR_PRI_BITS	9
`define OR1200_IMMUCFGR_TEIRI_BITS	10
`define OR1200_IMMUCFGR_HTR_BITS	11
`define OR1200_IMMUCFGR_RES1_BITS	31:12

// IMMUCFGR values
`ifdef OR1200_NO_IMMU
`define OR1200_IMMUCFGR_NTW		2'h0	// Irrelevant
`define OR1200_IMMUCFGR_NTS		3'h0	// Irrelevant
`define OR1200_IMMUCFGR_NAE		3'h0	// Irrelevant
`define OR1200_IMMUCFGR_CRI		1'b0	// Irrelevant
`define OR1200_IMMUCFGR_PRI		1'b0	// Irrelevant
`define OR1200_IMMUCFGR_TEIRI		1'b0	// Irrelevant
`define OR1200_IMMUCFGR_HTR		1'b0	// Irrelevant
`define OR1200_IMMUCFGR_RES1		20'h00000
`else
`define OR1200_IMMUCFGR_NTW		2'h0	// 1 TLB way
`define OR1200_IMMUCFGR_NTS 3'h`OR1200_ITLB_INDXW	// Num TLB sets
`define OR1200_IMMUCFGR_NAE		3'h0	// No ATB entry
`define OR1200_IMMUCFGR_CRI		1'b0	// No control reg
`define OR1200_IMMUCFGR_PRI		1'b0	// No protection reg
`define OR1200_IMMUCFGR_TEIRI		1'b1	// TLB entry inv reg impl
`define OR1200_IMMUCFGR_HTR		1'b0	// No HW TLB reload
`define OR1200_IMMUCFGR_RES1		20'h00000
`endif

// DCCFGR fields
`define OR1200_DCCFGR_NCW_BITS		2:0
`define OR1200_DCCFGR_NCS_BITS		6:3
`define OR1200_DCCFGR_CBS_BITS		7
`define OR1200_DCCFGR_CWS_BITS		8
`define OR1200_DCCFGR_CCRI_BITS		9
`define OR1200_DCCFGR_CBIRI_BITS	10
`define OR1200_DCCFGR_CBPRI_BITS	11
`define OR1200_DCCFGR_CBLRI_BITS	12
`define OR1200_DCCFGR_CBFRI_BITS	13
`define OR1200_DCCFGR_CBWBRI_BITS	14
`define OR1200_DCCFGR_RES1_BITS	31:15

// DCCFGR values
`ifdef OR1200_NO_DC
`define OR1200_DCCFGR_NCW		3'h0	// Irrelevant
`define OR1200_DCCFGR_NCS		4'h0	// Irrelevant
`define OR1200_DCCFGR_CBS		1'b0	// Irrelevant
`define OR1200_DCCFGR_CWS		1'b0	// Irrelevant
`define OR1200_DCCFGR_CCRI		1'b1	// Irrelevant
`define OR1200_DCCFGR_CBIRI		1'b1	// Irrelevant
`define OR1200_DCCFGR_CBPRI		1'b0	// Irrelevant
`define OR1200_DCCFGR_CBLRI		1'b0	// Irrelevant
`define OR1200_DCCFGR_CBFRI		1'b1	// Irrelevant
`define OR1200_DCCFGR_CBWBRI		1'b0	// Irrelevant
`define OR1200_DCCFGR_RES1		17'h00000
`else
`define OR1200_DCCFGR_NCW		3'h0	// 1 cache way
`define OR1200_DCCFGR_NCS (`OR1200_DCTAG)	// Num cache sets
`define OR1200_DCCFGR_CBS (`OR1200_DCLS-4)	// 16 byte cache block
`define OR1200_DCCFGR_CWS		1'b0	// Write-through strategy
`define OR1200_DCCFGR_CCRI		1'b1	// Cache control reg impl.
`define OR1200_DCCFGR_CBIRI		1'b1	// Cache block inv reg impl.
`define OR1200_DCCFGR_CBPRI		1'b0	// Cache block prefetch reg not impl.
`define OR1200_DCCFGR_CBLRI		1'b0	// Cache block lock reg not impl.
`define OR1200_DCCFGR_CBFRI		1'b1	// Cache block flush reg impl.
`define OR1200_DCCFGR_CBWBRI		1'b0	// Cache block WB reg not impl.
`define OR1200_DCCFGR_RES1		17'h00000
`endif

// ICCFGR fields
`define OR1200_ICCFGR_NCW_BITS		2:0
`define OR1200_ICCFGR_NCS_BITS		6:3
`define OR1200_ICCFGR_CBS_BITS		7
`define OR1200_ICCFGR_CWS_BITS		8
`define OR1200_ICCFGR_CCRI_BITS		9
`define OR1200_ICCFGR_CBIRI_BITS	10
`define OR1200_ICCFGR_CBPRI_BITS	11
`define OR1200_ICCFGR_CBLRI_BITS	12
`define OR1200_ICCFGR_CBFRI_BITS	13
`define OR1200_ICCFGR_CBWBRI_BITS	14
`define OR1200_ICCFGR_RES1_BITS	31:15

// ICCFGR values
`ifdef OR1200_NO_IC
`define OR1200_ICCFGR_NCW		3'h0	// Irrelevant
`define OR1200_ICCFGR_NCS 		4'h0	// Irrelevant
`define OR1200_ICCFGR_CBS 		1'b0	// Irrelevant
`define OR1200_ICCFGR_CWS		1'b0	// Irrelevant
`define OR1200_ICCFGR_CCRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_CBIRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_CBPRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_CBLRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_CBFRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_CBWBRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_RES1		17'h00000
`else
`define OR1200_ICCFGR_NCW		3'h0	// 1 cache way
`define OR1200_ICCFGR_NCS (`OR1200_ICTAG)	// Num cache sets
`define OR1200_ICCFGR_CBS (`OR1200_ICLS-4)	// 16 byte cache block
`define OR1200_ICCFGR_CWS		1'b0	// Irrelevant
`define OR1200_ICCFGR_CCRI		1'b1	// Cache control reg impl.
`define OR1200_ICCFGR_CBIRI		1'b1	// Cache block inv reg impl.
`define OR1200_ICCFGR_CBPRI		1'b0	// Cache block prefetch reg not impl.
`define OR1200_ICCFGR_CBLRI		1'b0	// Cache block lock reg not impl.
`define OR1200_ICCFGR_CBFRI		1'b1	// Cache block flush reg impl.
`define OR1200_ICCFGR_CBWBRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_RES1		17'h00000
`endif

// DCFGR fields
`define OR1200_DCFGR_NDP_BITS		2:0
`define OR1200_DCFGR_WPCI_BITS		3
`define OR1200_DCFGR_RES1_BITS		31:4

// DCFGR values
`ifdef OR1200_DU_HWBKPTS
`define OR1200_DCFGR_NDP	3'h`OR1200_DU_DVRDCR_PAIRS // # of DVR/DCR pairs
`ifdef OR1200_DU_DWCR0
`define OR1200_DCFGR_WPCI		1'b1
`else
`define OR1200_DCFGR_WPCI		1'b0	// WP counters not impl.
`endif
`else
`define OR1200_DCFGR_NDP		3'h0	// Zero DVR/DCR pairs
`define OR1200_DCFGR_WPCI		1'b0	// WP counters not impl.
`endif
`define OR1200_DCFGR_RES1		28'h0000000
 