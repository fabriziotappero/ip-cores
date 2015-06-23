///////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012-2013 by Michael A. Morris, dba M. A. Morris & Associates
//
//  All rights reserved. The source code contained herein is publicly released
//  under the terms and conditions of the GNU Lesser Public License. No part of
//  this source code may be reproduced or transmitted in any form or by any
//  means, electronic or mechanical, including photocopying, recording, or any
//  information storage and retrieval system in violation of the license under
//  which the source code is released.
//
//  The source code contained herein is free; it may be redistributed and/or 
//  modified in accordance with the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either version 2.1 of
//  the GNU Lesser General Public License, or any later version.
//
//  The source code contained herein is freely released WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
//  PARTICULAR PURPOSE. (Refer to the GNU Lesser General Public License for
//  more details.)
//
//  A copy of the GNU Lesser General Public License should have been received
//  along with the source code contained herein; if not, a copy can be obtained
//  by writing to:
//
//  Free Software Foundation, Inc.
//  51 Franklin Street, Fifth Floor
//  Boston, MA  02110-1301 USA
//
//  Further, no use of this source code is permitted in any form or means
//  without inclusion of this banner prominently in any derived works. 
//
//  Michael A. Morris
//  Huntsville, AL
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

///////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates 
// Engineer:        Michael A. Morris 
// 
// Create Date:     06:49:56 02/03/2012 
// Design Name:     WDC W65C02 Microprocessor Re-Implementation
// Module Name:     M65C02_Core
// Project Name:    C:\XProjects\ISE10.1i\M65C02 
// Target Devices:  Generic SRAM-based FPGA 
// Tool versions:   Xilinx ISE10.1i SP3
//
// Description:     (See additional comments section below)
//
// Dependencies:    M65C02_MPCv3.v
//                      M65C02_uPgm_V3a.coe (M65C02_uPgm_V3a.txt)
//                      M65C02_Decoder_ROM.coe (M65C02_Decoder_ROM.txt)
//                  M65C02_ALU.v
//                      M65C02_Bin.v
//                      M65C02_BCD.v 
//
// Revision: 
//
//  0.00    12B03   MAM     Initial File Creation
//
//  0.10    12B04   MAM     Synthesized. All synthesis errors removed. All un-
//                          used signals, except those related to the uPgm and
//                          Instruction Decode ROMs, removed. Next Address and
//                          Program Counter functions optimized.
//
//  1.00    12B05   MAM     Completed changes to the control structure to in-
//                          clude an instruction in the IDEC ROM. Changed basic
//                          operation to deal with a RAM, using LUT RAM, having
//                          single cycle read/write operations.
//
//  1.10    12B18   MAM     Added ISR input to ALU and connected to unused bits
//                          in the MPC microword. Used to clear D and set I in
//                          the PSW after it is pushed onto the stack when an
//                          NMI or unmasked IRQ interrupts are being processed.
//
//  1.11    12B19   MAM     Renamed all source files in a consistent manner.
//                          Corrected the equation for interrupt mask output.
//                          All modules and parameter files renamed M65C02_xxx.
//                          Module renamed: MAM6502_Core => M65C02_Core.
//
//  1.20    12B19   MAM     Decoded BRV2 MPC instuction. BRV2 added as a load
//                          signal to {OP2, OP1} to capture Vector[15:0] during
//                          NMI/IRQ interrupt and BRK trap handling.
//
//  1.30    12B19   MAM     Significantly changed the PSW implementation. Chan-
//                          ges implemented to allow the implementation of a
//                          better register write mechanism. Microword organi-
//                          zation changed to delete separate fields for DI and
//                          DO. Fields reorganized and the two bits from DO_Op
//                          combined with a third bit to form a 3-bit Reg_WE
//                          field. A single bit ISR field was retained. The 
//                          field width remains 32, but explicit control of the
//                          register write enable allows solution to be imple-
//                          mented for separately controlling updates to P and
//                          capturing the return address in the same temporary
//                          working register, OP1. BRK and RTI now operate as
//                          expected, and the common register numbering between
//                          the various register control field in the microcode
//                          and the fixed control word, allow a ROM-like struc-
//                          ture to be used for explicitly controlling writes 
//                          to the various registers (especially P). The new
//                          scheme improves the decode speed, and the new form
//                          of the P (PSW) provides a cleaner structure for
//                          future updates/changes. Also requires WSel field
//                          in the fixed control word to be updated so that all
//                          instructions, which modify memory (and not A, X, or
//                          Y) and require a change in a PSW bit, include P as
//                          as a write destination. Writes to A, X, or Y are
//                          also set to automatically generate a write enable 
//                          for P. (See M65C02_ALU for explicit changes to de-
//                          code logic for register write enables and PSW chan-
//                          ges.)
//
//                          Also changed the PC multiplexer and next PC adder
//                          logic so that a case statement is used to better
//                          define the next PC. This changed was required by a
//                          problem detected during the BRK instruction testing
//                          which indicated that the pipeline delay in the jmp
//                          address path was causing the next PC computation to
//                          operate on an invalid PCH value. Thus, the PCH of
//                          the RTI return address was wrong because it was 
//                          delayed one cycle. These two changes result in the
//                          100 MHz target clock speed being maitained.
//
//                          Synthesis indicated that SC (Single Cycle) and Done
//                          were being trimmed. Thus added Done and SC to the
//                          module port list to avoid the reported trimming of
//                          these two signals from the module after the modifi-
//                          cations to P and register write enable logic were
//                          completed.
//
//  1.31    12B22   MAM     Modified BA multiplexer to support unconditional
//                          instruction decode using BRV1, or conditional
//                          decode using BRV3. BRV3 is used by the microprogram
//                          to decode the next instruction after a single cycle
//                          instruction, or to branch to the interrupt handler.
//                          Modified the test inputs to connect Valid to T1,
//                          and PSW Decimal mode flag, P.3, to T0. Expect to
//                          use this test input, T0, for ADC/SBC instructions
//                          to use different microroutines (for all addressing
//                          modes) ((problem may arise for ADC/SBC #imm)).
//
//  1.32    12B23   MAM     Backed out changed to T[3:0] implemented in 1.31.
//                          A different method will be used.
//
//  1.40    12B24   MAM     Solved issue regarding cycle stretch required to
//                          perform BCD arithmetic (ADC and SBC only) during an
//                          instruction fetch. Normally, all ALU operations 
//                          complete during the instruction fetch cycle, thus
//                          the registers and PSW are appropriately updated so
//                          that a branch instruction can immediately perform a
//                          condition code test. The solution is to provide a
//                          separate ready signal to the ALU, which then uses
//                          the ready signal to gate the register write enables
//                          separately from the ALU function enable which acti-
//                          vates the various functional units in the ALU. At
//                          the core level, the external ready is gated by Wait
//                          and an internal ready signal is generated that will
//                          stretch the ALU execution cycle only when a BCD add
//                          or subtract is performed. Since the only BCD opera-
//                          tions to be concerned about are the ADC/SBC opera-
//                          tions, only the Accumulator and the PSW are affect-
//                          ed. This means that only the RO_?? addressing modes
//                          microroutines are involved in these operations. All
//                          of the other addressing modes, WO_?? and RMW_??, do
//                          not have any BCD mode instructions with which to be
//                          concerned.
//
//                          To implement the solution, a RDY port was added to
//                          ALU, all of the core level registers (PC, MAR, OP1,
//                          and OP2) write enable instructions were modified to
//                          use only Rdy instead of the previous multiplexed 
//                          signal. That multiplexer was moved to the begining
//                          of the module, and then combined with a ROM-based
//                          decoder to form the core-level Rdy signal that is
//                          distributed to all registers and modules. The ex-
//                          ternal Rdy port on the core was renamed to Ack_In
//                          in order to maintain Rdy as the signal name within
//                          the core.
//
//  1.41    12B24   MAM     Simple cleanup of comments and conversion of con-
//                          stants used for DO multiplexer control into the
//                          local parameters specifically defined for the pur-
//                          pose of decoding that microprogram control field.
//
//  1.50    12B25   MAM     Completed support for interrupt handling. Added a
//                          register to capture the last value of the PC of an
//                          instruction being interrupted. The automatic adjust
//                          provided by RTS/RTI of the return address means
//                          the PC pushed on the stack is not the address of
//                          the next instruction, but the last byte of the in-
//                          struction being completed before vectoring to the
//                          interrupt service routine. Added a FF to that is
//                          set when an interrupt has been accepted and clear-
//                          ed as the first instruction of the interrupt ser-
//                          vice routine is fetched. It is used to multiplex
//                          {PCH, PCL} or {dPCH, dPCL} onto the output bus. The
//                          delayed PC values are pushed onto the stack for in-
//                          terrupts, the the normal PC is pushed onto the
//                          stack for subroutine calls. Thus, the output data
//                          multiplexer was modified to include an additional
//                          multiplexer for the delayed or the non-delayed PC.
//
//                          Also modified the write enables for the IR, OP1,
//                          and OP2 registers. As an interrupt is being taken,
//                          the instruction being fetched should not loaded 
//                          into the IR. As a consequence, BRV1 and BRV3 are 
//                          used to update the IR, but only if Int is not
//                          asserted during a BRV3 MPC operation.
//
//  1.60    12C04   MAM     Made change to the internal Rdy signal equations.
//                          Added |Reg_WE term to the |Op term. This corrects
//                          an issue with RMW instructions where the cycle is
//                          complete and ALU Valid deasserts during the fetch
//                          of the next instruction. Rdy deasserts as a result
//                          and the microprogram stops. Not an issue for all
//                          other instructions since the fetch and execute
//                          cycles are overlapped. With RMW instructions this
//                          is not the case because Reg_WE is asserted one cy-
//                          cle before the fetch of the next instruction.
//
//  1.61    12C06   MAM     Added internal ready, Rdy, to the port list for
//                          easier access to the signal by the testbench.
//
//  2.0     12C30   MAM     Replaced the address generator functions, including
//                          the MAR and PC registers and associated logic with
//                          a single module that captures all of the address
//                          generation. This is done in preparation of changing
//                          the address generation to support synchronous Block
//                          RAM for use with the M65C02_Core instead of asyn-
//                          chronous LUT-based RAM presently used.
//
//  2.10    12D29   MAM     Per Windfall@forum.6502.org, the DP,X and DP,Y
//                          address modes did not wrap at the zero page bounda-
//                          ry. Adjusted the AO equation to wrap the address as
//                          required.
//              
//  2.20    12K03   MAM     Cut out the address generator section and created a
//                          module, M65C02_AddrGen.
//
//  2.30    12K03   MAM     Integrated version 3 of the MPC which includes a
//                          built-in microcycle length controller.
//
//  2.40    12K12   MAM     Cleaned up, and replaced Wait signal in variable
//                          microcode with a ZP control signal. When asserted,
//                          ZP forces a % 256 address calculation. Applies to
//                          zp,X; zp,Y; (zp,X); and (zp),Y addressing modes. In
//                          zp,X and zp,Y addressing modes, the indexed zp value
//                          must wrap araund the 256 boundary. In (zp,X), both
//                          the low and the high byte of the 16-bit pointer are
//                          in page 0. The 8-bit index operation must be wrapp-
//                          ed on page 0, and so must the second, the high byte
//                          of the address. In (zp),Y, the index operation is
//                          allowed to cross a page boundary, i.e. not % 256.
//                          But both bytes of the pointer must be fetched from
//                          page 0. Therefore, the increment operation to get
//                          the second byte must be wrapped to page 0.
//
//  3.00    12K20   MAM     Renamed signal Last to Rdy. Rdy is asserted
//                          on the last cycle of a multi-cycle microcycle. Added
//                          (Rdy | Rst) as a ROM enable for the microprogram
//                          ROM to ensure that the microprogram word is constant
//                          during a multi-cycle microcycle. Rst is included to
//                          allow the first microword to be fetched during Rst
//                          in support of the MPC's pipelined operation. (For
//                          additional clarification refer to comment 1.6 of the
//                          M65C02_ALU module.)
//
//  3.10    12L09   MAM     Added capability to support WAI instruction. Needed
//                          signal, xIRQ, that indicates an active low external
//                          interrupt request is asserted but the interrupt mask
//                          is set so the processor will not take the interrupt.
//                          Under these conditions, the WAI continues with the
//                          next sequential instruction. In addition to adding
//                          xIRQ to the input ports of the core, the multi-way
//                          branch multiplexer required a change to support a 
//                          4-way branch table when WAI is executing, and a
//                          2-way for all other instructions. To support the
//                          detection of the WAI instruction, changed the Mode
//                          vector to identify the WAI and STP instructions.
//
//  3.20    12L13   MAM     Renamed, previously unused and reserved fixed micro-
//                          word Opcode field to Msk, and ported into the ALU.
//                          The new field provides the bit mask needed for the
//                          implementation of the Rockwell instructions.
//
//  3.21    13B16   MAM     Added ISR signal to port list to easily allow the
//                          external logic to generate the vector pull signal.
//
//  3.30    13C02   MAM     Changed MPC from M65C02_MPCv3 to M65C02_MPCv4. V4
//                          includes a wait state generator to maintain a cons-
//                          tant external Phi1O/Phi2O duty cycle. Because of new
//                          wait state generator, the BUFGMUX instantiated and
//                          used for clock stretching is removed.
//
//  3.40    13H04   MAM     Removed unused code. Changed DO bus to simple OR
//                          gate instead of multiplxer. Added decode ROM to sup-
//                          port one-hot select of various DO bus sources. Used
//                          microcycle control signal in place of internal Rdy
//                          signal. Changed MPC_En to Rdy, and deleted internal
//                          ready 16:1 decoder.
//
// Additional Comments:
//
//  This module is derived from the first implementation which assummed it was
//  the top level implementation, i.e. its ports would be connected to IO pins.
//  The pipelining of the control signals, instruction and operand addresses,
//  and the data proved a bit cumbersome to deal with. The intention was to al-
//  ways have that first implementation function as a core around which other
//  components and capabilities could be added. With the incorporation of the
//  memory interface directly in the core, interactions between the memory in-
//  terface and the core logic hindered the development of the microprogram.
//
//  Thus, the decision was made to sever the core functions from that of the
//  memory interface. A single signal, Ack, would force the core logic to wait
//  in the event that the required read data was unavailable or the write
//  buffers were full. This design decision allows the memory interface and its
//  interaction with the core logic to be separated at a clean boundary. The
//  result is that timing on the core's external address and data busses can be
//  treated as single cycle operations. That is, memory read and memory write
//  transactions are completed in the same cycle, i.e no (pipeline) delays.
//
//  This simplified core architecture must be coupled to an external memory
//  controller at the next higher level that implements the required memory
//  transactions and provides the Ack signal to control the execution of the 
//  core logic state machine. With the core's memory interface, it would be
//  easy to add a simple cache memory module to provide data at a rate high to
//  the core to achieve as high a clocks per instruction (CPI) metric as possi-
//  ble for the complex addressing of the 6502 core.
//
//  Furthermore, the core must be coupled to logic to handle the edge-sensitive
//  NMI, and level sensitive IRQ interrupts. The core, as currently iplemented,
//  accepts a vector from this external module for Rst, NMI, IRQ, and/or BRK.
//  (In some implementations of the 6502, notably the WDC W65C802, the IRQ vec-
//  tor is not shared with the BRK interrupt. In that implementation, a sepa-
//  rate BRK vector is allowed. This core indicates to external logic that a
//  BRK instruction is being processed, so it is possible for the BRK vector to
//  be separated from the IRQ vector. In addition, the vector supplied is not
//  the vector address through which the W65C02 perform an indirect jump. In-
//  stead, the vector supplied is the content of the indirect jump address.)
//
///////////////////////////////////////////////////////////////////////////////

module M65C02_Core #(
    parameter pStkPtr_Rst  = 8'hFF, // Stk Ptr Value after Reset
    parameter pInt_Hndlr   = 0,     // _Int microroutine address, Reset default
    parameter pM65C02_uPgm = "M65C02_uPgm_V3a.coe",
    parameter pM65C02_IDec = "M65C02_Decoder_ROM.coe"
)(
    input   Rst,            // System Reset Input
    input   Clk,            // System Clock Input
    
    //  Processor Core Interrupt Interface
    
    output  IRQ_Msk,        // Interrupt mask from P to Interrupt Handler
    input   xIRQ,           // External Maskable Interrupt Request Input
    input   Int,            // Interrupt input from Interrupt Handler
    input   [15:0] Vector,  // ISR Vector from Interrupt Handler
    
    //  Processor Core Status Interface
    
    output  Done,           // Instruction Complete/Fetch Strobe
    output  SC,             // Single Cycle Instruction
    output  [2:0] Mode,     // Mode - Instruction Type/Mode
    output  RMW,            // Read-Modify-Write Operation
    output  reg IntSvc,     // Interrupt Service Start Indicator
    output  ISR,            // Interrupt Vector Pull Start Flag
    
    //  Processor Core Memory Controller Interface
    
    output  [2:0] MC,       // Microcycle state:   2-C1; 3-C4; 1-C3; 0-C4;
    output  [1:0] MemTyp,   // Memory access Type: 0-Pgm Memory; 1-Page 0;
                            //                     2-Page 1;     3-Data Memory;
    input   Wait,           // Wait Input (in C3, adds wait state sequence)
    output  Rdy,            // Internal Ready
    
    //  Processor Core Memory Cycle Interface    
    
    output  [ 1:0] IO_Op,   // Instruction Fetch Strobe
    output  [15:0] AO,      // External Address
    input   [ 7:0] DI,      // External Data In
    output  reg [7:0] DO,   // External Data Out

    // Processor Core Internal Registers

    output  [ 7:0] A,       // Accumulator
    output  [ 7:0] X,       // Index Register X
    output  [ 7:0] Y,       // Index Register Y
    output  [ 7:0] S,       // Stack Pointer
    output  [ 7:0] P,       // Processor Status Word
    output  [15:0] PC,      // Program Counter
    
    output  reg [7:0] IR,   // Instruction Register
    output  reg [7:0] OP1,  // Operand Register 1
    output  reg [7:0] OP2   // Operand Register 2
);

///////////////////////////////////////////////////////////////////////////////
//
// Local Parameter Declarations
//

localparam  pROM_AddrWidth = 8'd9;
localparam  pROM_Width     = 8'd32;
localparam  pROM_Depth     = (2**pROM_AddrWidth);

localparam  pDEC_AddrWidth = 8'd8;
localparam  pDEC_Width     = 8'd32;
localparam  pDEC_Depth     = (2**pDEC_AddrWidth);

//

localparam  pBA_Fill = (pROM_AddrWidth - pDEC_AddrWidth);

localparam  pBRV1    = 2'b01;   // MPC Via[1:0] code for BRV1 instruction
localparam  pBRV2    = 2'b10;   // MPC Via[1:0] code for BRV2 instruction
localparam  pBRV3    = 2'b11;   // MPC Via[1:0] code for BRV3 instruction
localparam  pBMW     = 4'b0011; // MPC I[3:0] code for BMW instruction

localparam  pNOP     = 8'hEA;   // NOP opcode

localparam  pPC_Pls  = 2'b01;   // PC Increment
localparam  pPC_Jmp  = 2'b10;   // PC Absolute Jump
localparam  pPC_Rel  = 2'b11;   // PC Conditional Branch

localparam  pIO_IF   = 2'b11;   // Instruction Fetch
localparam  pIO_RD   = 2'b10;   // Memory Read
localparam  pIO_WR   = 2'b01;   // Memory Write

localparam  pDO_ALU  = 2'b00;   // DO    <= ALU_Out
localparam  pDO_PCH  = 2'b01;   // DO    <= PC[15:8]
localparam  pDO_PCL  = 2'b10;   // DO    <= PC[ 7:0]
localparam  pDO_PSW  = 2'b11;   // DO    <= P (also available on ALU_Out)
//
localparam  pDI_Mem  = 2'b00;   // ALU_M <= DI
localparam  pDI_OP2  = 2'b01;   // OP2   <= DI
localparam  pDI_OP1  = 2'b10;   // OP1   <= DI
localparam  pDI_IR   = 2'b11;   // IR    <= DI

localparam  pStk_Psh = 2'b10;   // StkPtr <= S;
localparam  pStk_Pop = 2'b11;   // StkPtr <= S + 1;

localparam  pNA_Inc  = 4'h1;    // NA <= PC + 1
localparam  pNA_MAR  = 4'h2;    // NA <= MAR + 0
localparam  pNA_Nxt  = 4'h3;    // NA <= MAR + 1
localparam  pNA_Stk  = 4'h4;    // NA <= SP + 0
localparam  pNA_DPN  = 4'h5;    // NA <= {0, OP1} + 0
localparam  pNA_DPX  = 4'h6;    // NA <= {0, OP1} + {0, X}
localparam  pNA_DPY  = 4'h7;    // NA <= {0, OP1} + {0, Y}
localparam  pNA_LDA  = 4'h8;    // NA <= {OP2, OP1} + 0
//
//
//
//
//
localparam  pNA_LDAX = 4'hE;    // NA <= {OP2, OP1} + {0, X}
localparam  pNA_LDAY = 4'hF;    // NA <= {OP2, OP1} + {0, Y}

localparam  pBCD     = 3;       // Bit number of BCD Mode bit in P
localparam  pIntMsk  = 2;       // Bit number of Interrupt mask bit in P

localparam  pADC     = 4;       // ALU Operation Add w/ Carry
localparam  pSBC     = 5;       // ALU Operation Subtract w/ Carry

///////////////////////////////////////////////////////////////////////////////
//
// Local Signal Declarations
//

wire    WAI;                            // Instruction Mode Decode for WAI

wire    BRV1;                           // MPC BRV1 Instruction Decode
wire    BRV2;                           // MPC BRV2 Instruction Decode
wire    BRV3;                           // MPC BRV3 Instruction Decode
wire    BMW;                            // MPC BMW Instruction Decode

reg     [(pROM_Width - 1):0] uP_ROM [(pROM_Depth - 1):0]; // Microprogram ROM

wire    [3:0] I;                        // MPC Instruction Input
wire    [3:0] T;                        // MPC Test Inputs
wire    [2:0] MW;                       // MPC Multi-way Branch Select
reg     [(pROM_AddrWidth - 1):0] BA;    // MPC Branch Address Input
wire    [1:0] Via;                      // MPC Via Mux Control Output
wire    [(pROM_AddrWidth - 1):0] MA;    // MPC uP ROM Address Output
//
reg     [(pROM_Width - 1):0] uPL;       // MPC uP ROM Pipeline Register
//
wire    [(pROM_AddrWidth - 1):0] uP_BA; // uP Branch Address Field
wire    ZP;                             // Zero Page Addressing Control Field
wire    [3:0] NA_Op;                    // Memory Address Register Control Fld
wire    [1:0] PC_Op;                    // Program Counter Control Field
wire    [1:0] DI_Op;                    // Memory Data Input Control Field
wire    [1:0] DO_Op;                    // Memory Data Output Control Field
wire    [1:0] Stk_Op;                   // Stack Pointer Control Field
wire    [2:0] Reg_WE;                   // Register Write Enable Control Field

reg     En;                             // ALU Enable Control Field

//  Instruction Decoder ROM

reg     [(pDEC_Width - 1):0] ID_ROM [(pDEC_Depth - 1):0]; // Inst. Decode ROM

//  Instruction Decoder Pipeline Register (Asynchronous Distributed ROM)

reg     [(pDEC_Width - 1):0] IDEC;  // Instruction Decode ROM Pipeline Reg.

//  Instruction Decoder (Fixed) Output

wire    [3:0] Op;                   // M65C02 ALU Operation Select Field
wire    [1:0] QSel;                 // M65C02 ALU Q Operand Select Field
wire    RSel;                       // M65C02 ALU R Operand Select Field
wire    Sub;                        // M65C02 ALU Adder Control Field
wire    CSel;                       // M65C02 ALU Adder Carry In Select Field
wire    [2:0] WSel;                 // M65C02 ALU Register Write Select Field
wire    [2:0] OSel;                 // M65C02 ALU Output Select Field
wire    [4:0] CCSel;                // M65C02 ALU Condition Code Control Field
wire    [7:0] Msk;                  // M65C02 Rockwell Instruction Mask Field
  
wire    [7:0] Out;                  // M65C02 ALU Data Output Bus
wire    Valid;                      // M65C02 ALU Output Valid Signal
wire    [7:0] StkPtr;               // M65C02 ALU Stack Pointer Logic Output
wire    CC;                         // ALU Condition Code Output

wire    [15:0] dPC;                 // Pipeline Compensation Register for PC

wire    CE_IR, CE_OP1, CE_OP2;      // Clock Enables: IR, OP1, and OP2

reg     [5:0] DO_Sel;               // Data Output Multiplexer Decode ROM

///////////////////////////////////////////////////////////////////////////////
//
//  Start Implementation
//
///////////////////////////////////////////////////////////////////////////////

//  Define Microcycle and Instruction Cycle Status Signals

assign Done = (|Via);         // Instruction Complete (1)     - ~BRV0
assign SC   = (&Via);         // Single Cycle Instruction (1) -  BRV3             
assign Rdy  = (MC == 4);      // Microcycle Complete Signal

///////////////////////////////////////////////////////////////////////////////
//
//  Microprogram Controller Interface
//
//  Decode MPC Instructions being used for strobes

assign BRV1 = (Via == pBRV1);
assign BRV2 = (Via == pBRV2);
assign BRV3 = (Via == pBRV3);
assign BMW  = (I   == pBMW ); 

//  Define the Multi-Way Input Signals
//      Implement a 4-way branch when executing WAI, and a 2-way otherwise

assign MW = ((WAI) ? {uP_BA[2], xIRQ, Int} : {uP_BA[2:1], Int});

//  Implement the Branch Address Field Multiplexer for Instruction Decode

always @(*)
begin
    case(Via)
        pBRV1   : BA <= {{pBA_Fill{1'b1}}, DI[3:0], DI[7:4]};
        pBRV3   : BA <= ((Int) ? pInt_Hndlr
                               : {{pBA_Fill{1'b1}}, DI[3:0], DI[7:4]});
        default : BA <= uP_BA;
    endcase
end

//  Assign Test Input Signals

assign T = {3'b000, Valid};

//  Instantiate Microprogram Controller/Sequencer - modified F9408A MPC

M65C02_MPCv4    #(
                    .pAddrWidth(pROM_AddrWidth)
                ) MPCv4 (
                    .Rst(Rst), 
                    .Clk(Clk),
                    
                    .Wait(Wait),            // Microcycle Wait state request
                    .MC(MC),                // Microcycle State

                    .I(I),                  // Instruction 
                    .T(T),                  // Test signal input
                    .MW(MW),                // Multi-way branch inputs
                    .BA(BA),                // Branch address input
                    .Via(Via),              // BRVx multiplexer control output

                    .MA(MA)                 // Microprogram ROM address output
                );

//  Infer Microprogram ROM and initialize with file created by MCP_Tool

initial
    $readmemb(pM65C02_uPgm, uP_ROM, 0, (pROM_Depth - 1));
    
always @(posedge Clk)
begin
    if(Rdy | Rst)
        uPL <= #1 uP_ROM[MA];
end

//  Assign uPL fields

assign I      = uPL[31:28];     // MPC Instruction Field (4)
assign uP_BA  = uPL[27:19];     // MPC Branch Address Field (9)
assign ZP     = uPL[18];        // When Set, ZP % 256 addressing required (1)
assign MemTyp = uPL[17:16];     // Memory Type (2)
assign NA_Op  = uPL[15:12];     // Next Address Operation (4)
assign PC_Op  = uPL[11:10];     // Program Counter Control (2)
assign IO_Op  = uPL[9:8];       // IO Operation Control (2)
assign DI_Op  = uPL[7:6];       // DI Demultiplexer Control (2)
assign DO_Op  = uPL[7:6];       // DO Multiplexer Control (2) (same as DI_Op)
assign Stk_Op = uPL[5:4];       // Stack Pointer Control Field (2)
assign Reg_WE = uPL[3:1];       // Register Write Enable Field (3)
assign ISR    = uPL[0];         // Set to clear D and set I on interrupts (1)

//  Decode DI_Op Control Field

assign Ld_OP2 = IO_Op[1] & (DI_Op == pDI_OP2);
assign Ld_OP1 = IO_Op[1] & (DI_Op == pDI_OP1);

//  Operand Register 2

assign CE_OP2 = Ld_OP2 & Rdy & ~CE_IR;   

always @(posedge Clk)
begin
    if(Rst)
        OP2 <= #1 0;
    else if(BRV2)
        OP2 <= #1 Vector[15:8];
    else if(CE_OP2)
        OP2 <= #1 DI;   // Load OP2 from DI
end

//  Operand Register 1

assign CE_OP1 = Ld_OP1 & Rdy & ~CE_IR;

always @(posedge Clk)
begin
    if(Rst)
        OP1 <= #1 0;
    else if(BRV2)
        OP1 <= #1 Vector[7:0];
    else if(CE_OP1)
        OP1 <= #1 DI;   // Load OP1 from DI
end

//  Instruction Register

assign CE_IR = (BRV1 | (BRV3 & ~Int)) & Rdy;  // Load IR from DI

always @(posedge Clk)
begin
    if(Rst)
        IR <= #1 pNOP;
    else if(CE_IR)
        IR <= #1 DI;
end

//  Infer Instruction Decode ROM and initialize with file created by MCP_Tool

initial
    $readmemb(pM65C02_IDec, ID_ROM, 0, (pDEC_Depth - 1));

always @(posedge Clk)
begin
    if(Rst)
        IDEC <= #1 ID_ROM[pNOP];
    else if(CE_IR)
        IDEC <= #1 ID_ROM[DI];
end

//  Decode Fixed Microcode Word

assign  Mode  = IDEC[31:29];       // M65C02 Instruction Type/Mode
assign  RMW   = IDEC[28];          // M65C02 Read-Modify-Write Instruction
assign  Op    = IDEC[27:24];       // M65C02 ALU Operation Select Field
assign  QSel  = IDEC[23:22];       // M65C02 ALU AU Q Bus Mux Select Field
assign  RSel  = IDEC[21];          // M65C02 ALU AU/SU R Bus Mux Select Field
assign  Sub   = IDEC[20];          // M65C02 ALU AU Mode Select Field
assign  CSel  = IDEC[19];          // M65C02 ALU AU/SU Carry Mux Select Field
assign  WSel  = IDEC[18:16];       // M65C02 ALU Register Write Select Field
assign  OSel  = IDEC[15:13];       // M65C02 ALU Register Output Select Field
assign  CCSel = IDEC[12: 8];       // M65C02 ALU Condition Code Control Field
assign  Msk   = IDEC[ 7: 0];       // M65C02 Rockwell Instruction Mask Field

// Decode Mode for internal signals

assign  WAI =  &Mode;               // Current Instruction is WAI

//  Next Address Generator

M65C02_AddrGen  AddrGen (
                    .Rst(Rst), 
                    .Clk(Clk),
                    
                    .Vector(Vector), 

                    .NA_Op(NA_Op),
                    .PC_Op(PC_Op),
                    .Stk_Op(Stk_Op),
                    
                    .ZP(ZP),

                    .CC(CC), 
                    .BRV3(BRV3), 
                    .Int(Int), 

                    .Rdy(Rdy), 

                    .DI(DI), 
                    .OP1(OP1), 
                    .OP2(OP2), 
                    .StkPtr(StkPtr), 
                    .X(X), 
                    .Y(Y), 

                    .AO(AO), 

                    .AL(),
                    .AR(),
                    .NA(), 
                    .MAR(), 

                    .PC(PC), 
                    .dPC(dPC)
                );

//  Interrupt Service Flag

assign CE_IntSvc = (  (Int & (BRV3 | BMW))
                    | ((IO_Op == pIO_WR) & (DO_Op == pDO_PSW)));

always @(posedge Clk)
begin
    if(Rst)
        IntSvc <= #1 0;
    else if(CE_IntSvc)
        IntSvc <= #1 (Int & (BRV3 | BMW));
end

//  Instantiate the M65C02 ALU Module

always @(*) En <= (|Reg_WE);

M65C02_ALU  #(
                .pStkPtr_Rst(pStkPtr_Rst)
            ) ALU (
                .Rst(Rst),          // System Reset
                .Clk(Clk),          // System Clock

                .Rdy(Rdy),          // Ready

                .En(En),            // M65C02 ALU Enable Strobe Input
                .Reg_WE(Reg_WE),    // M65C02 ALU Register Write Enable
                .ISR(ISR),          // M65C02 ALU Interrupt Service Rtn Strb
                
                .Op(Op),            // M65C02 ALU Operation Select Input
                .QSel(QSel),        // M65C02 ALU Q Data Mux Select Input
                .RSel(RSel),        // M65C02 ALU R Data Mux Select Input
                .Sub(Sub),          // M65C02 ALU Adder Function Select Input
                .CSel(CSel),        // M65C02 ALU Adder Carry Select Input
                .WSel(WSel),        // M65C02 ALU Register Write Select Input
                .OSel(OSel),        // M65C02 ALU Output Register Select Input
                .CCSel(CCSel),      // M65C02 ALU Condition Code Select Input
                .Msk(Msk),          // M65C02 ALU Rockwell Instructions Mask

                .M(OP1),            // M65C02 ALU Memory Operand Input
                .Out(Out),          // M65C02 ALU Output Multiplexer
                .Valid(Valid),      // M65C02 ALU Output Valid Strobe

                .CC_Out(CC),        // M65C02 ALU Condition Code Mux Output

                .StkOp(Stk_Op),     // M65C02 ALU Stack Pointer Operation
                .StkPtr(StkPtr),    // M65C02 ALU Stack Pointer Multiplexer

                .A(A),              // M65C02 ALU Accumulator Register
                .X(X),              // M65C02 ALU Pre-Index Register
                .Y(Y),              // M65C02 ALU Post-Index Register
                .S(S),              // M65C02 ALU Stack Pointer Register
                
                .P(P)               // M65C02 Processor Status Word Register
            );

//  Decode P

assign IRQ_Msk = P[pIntMsk];        // Interrupt Mask Bit

//  External Bus Data Output

always @(*)                // P ddPP O
begin                      // S PPCC u
    case({IntSvc, DO_Op})  // W HLHL t
        3'b000 : DO_Sel <= 6'b0_0000_1;
        3'b001 : DO_Sel <= 6'b0_0010_0;
        3'b010 : DO_Sel <= 6'b0_0001_0;
        3'b011 : DO_Sel <= 6'b1_0000_0;
        3'b100 : DO_Sel <= 6'b0_0000_1;
        3'b101 : DO_Sel <= 6'b0_1000_0;
        3'b110 : DO_Sel <= 6'b0_0100_0;
        3'b111 : DO_Sel <= 6'b1_0000_0;
    endcase
end

always @(*) DO <= (  ((DO_Sel[5]) ? P         : 0)
                   | ((DO_Sel[4]) ? dPC[15:8] : 0)
                   | ((DO_Sel[3]) ? dPC[ 7:0] : 0)
                   | ((DO_Sel[2]) ?  PC[15:8] : 0)
                   | ((DO_Sel[1]) ?  PC[ 7:0] : 0)
                   | ((DO_Sel[0]) ? Out       : 0));

///////////////////////////////////////////////////////////////////////////////
//
//  End Implementation
//
///////////////////////////////////////////////////////////////////////////////

endmodule
