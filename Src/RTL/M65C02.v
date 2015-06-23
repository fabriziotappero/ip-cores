////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Assoc.
// Engineer:        Michael A. Morris
// 
// Create Date:     12:49:16 11/18/2012 
// Design Name:     WDC W65C02 Microprocessor Re-Implementation
// Module Name:     M65C02.v 
// Project Name:    C:\XProjects\ISE10.1i\M65C02 
// Target Devices:  Generic SRAM-based FPGA 
// Tool versions:   Xilinx ISE10.1i SP3
//
// Description:
//
//  This module provides a synthesizable implementation of a 65C02 micropro-
//  cessor similar to the WDC W65C02S. The original W65C02 implemented a set of
//  enhancements to the MOS6502 microprocessor. Two new addressing modes were
//  added, several existing instructions were rounded out using the new address-
//  ing modes, and some additional instructions were added to fill in holes pre-
//  in the instruction set of the MOS6502. Rockwell second sourced the W65C02, 
//  and in the process added 4 bit-oriented instructions using 32 opcodes. WDC
//  released the W65816/W65802 16-bit enhancements to the W65C02. Two of the new
//  instructions in these processors, WAI and STP, were combined with the four
//  Rockwell instructions, RMBx/SMBx and BBRx/BBSx, along with the original
//  W65C02's instruction set to realize the W65C02S.
//
//  The M65C02 core is a realization of the W65C02S instruction set. It is not a
//  cycle accurate implementation, and it does not attempt to match the idiosyn-
//  cratic behavior of the W65C02 or the W65C02S with respect to unused opcodes.
//  In the M65C02 core, all unused opcodes are realized as single byte, single
//  cycle NOPs.
//
//  This module demonstrates how to incorporate the M65C02_Core.v logic module
//  into an application-specific implementation. The core logic incorporates
//  most of the logic required for a microprocessor implementation: ALU, regis-
//  ters, address generator, and instruction decode and sequencing. Not included
//  in the core logic are the memory interface, the interrupt handler, the clock
//  generator, and any peripherals.
//
//  This module integrates the M65C02_Core.v module, an external memory inter-
//  face, a simple vectored interrupt controller, and a clock generator. The ob-
//  jective is a module that emulates the external interfaces of a 5C02 proces-
//  sor. The intent is not to develop a W65C02S replacement; an FPGA-based emu-
//  lation of a processor still in production and readily available is not eco-
//  nomically viable, or an objective of this project. (To be economically
//  viable, an FPGA-based implementation of a 65C02 system using the M65C02
//  (or WDC's synthesizable W65C02S) must be more than just a drop-in replace-
//  ment of the microprocessor; it must include on-chip peripherals and addi-
//  tional I/O interfaces, provide extended addressing, higher performance, etc.
//  In other words, it must be more than just a replacement of the inexpensive
//  40-pin/44-pin W65C02S microprocessor.)
//
//  The 6502 memory interface is not particularly well suited for an FPGA-based
//  implementation. FPGA-based implementations prefer to use a single clock, and
//  the 6502 memory interface uses a two phase clocking scheme. Further, for
//  6502-family peripherals which require a clock, the clock needs to be conti-
//  nuous and symmetric. The M65C02 core logic will be overclocked relative to
//  the 6502 memory interface. Thus, the memory interface controller can ensure
//  that the core logic and the output clocks are synchronized and continuous
//  and symmetric. However, this requires that any wait states needed by the ex-
//  ternal memory or peripherals must be inserted as integer multiples of the
//  external memory cycle length. This means that if there are four micro-cycles
//  per external memory cycle, then every requested wait state will add an addi-
//  tional 4 cycles to each microcycle.
//
//  With this configuration, the external memory's access time determines the
//  overall performance of the M65C02. Asynchronous memories are probably the
//  least expensive of any of the high-speed static RAMs currently available.
//  Therefore, the external memory interface provided with the M65C02 will pro-
//  vide support for high-speed asynchronous SRAMs and Flash EPROMs. To provide
//  reasonable price vs. performance, a 25ns access time will be used as the
//  target device speed for RAM. 
//
//  A common interface provided by embedded computers is the asynchronous serial
//  port. To make the interface reliable, the expectation is that the external
//  clock input of the M65C02 will be a provided by a "baud rate" crystal oscil-
//  lator. The frequency expected is the commonly available 18.432 MHz.
//
//  The Tiockp, clock to output time, of a typical FPGA capable of 100 MHz
//  internal operation is: 3.4ns for -5 Spartan-3AN with the IOBs configured for
//  LVTTL operation, 12mA drive, and fast slew rate. The input setup time with
//  input delay, Tiopickd, is: 3.73ns with IOB-DELAY=3. These delays, which sum
//  to 7.13ns, must be added to the RAM's access time to determine the external
//  memory cycle time: 42.13ns for a 35ns access time device.
//
//  If the external 18.432 MHz clock is multiplied by 4 and divided by 4 to set
//  the external memory cycle period, the resulting period would be 54.253ns,
//  which satisfies the 42.13ns requirement with some margin. Therefore, the
//  module will use a DCM whose input frequency is provided by a 18.432 MHz
//  oscillator. The internally the M65C02 will operate at 73.728 MHz in a
//  4 clock per microcycle configuration; the memory controller controls the
//  microcycle length of the M65C02.
//
// Dependencies:    M65C02_Core.v
//                      M65C02_MPCv4.v
//                          M65C02_uPgm_V3a.coe (M65C02_uPgm_V3a.txt)
//                          M65C02_Decoder_ROM.coe (M65C02_Decoder_ROM.txt)
//                      M65C02_AddrGen.v
//                      M65C02_ALU.v
//                          M65C02_Bin.v
//                          M65C02_BCD.v 
//
// Revision: 
//
//  0.00    12B18   MAM     Initial File Creation
//
//  0.01    13B16   MAM     Added DCM/DFS clock generator, refined port list,
//                          and refined internal reset signal generation.
//
//  1.00    13B23   MAM     Completed the integration and testing of the M65C02
//                          implementation as a standalone microprocessor.
//
//  2.00    13B25   MAM     Pulled into the M65C02 module the Boot ROM/RAM used
//                          for testing. The test program will be used during
//                          testing. For a final product, the ROM/RAM can be
//                          loaded with a Monitor or other boot program. In this
//                          manner, all of the block RAM of the target FPGA is
//                          used, but maximum performance can be achieved. i.e.
//                          no clock stretching is required when running from
//                          block RAM. To perform the internal multiplexing of
//                          input data bus, added a dedicated chip enable for
//                          this device, BootROM, that controls the multiplexer.
//                          Modified the clock multiplexer, now that internal
//                          block RAM is used for the Boot/Monitor program, so
//                          that SYS and ROM chip enables are used for the dy-
//                          namic clock stretching circuit. Added a nWP input to
//                          inhibit writes to the Boot/Monitor Block RAM.
//
//  2.10    13B27   MAM     Removed all unused logic, or RTL commented out.
//
//  2.20    12C02   MAM     Incorporated M65C02_Core with M65C02_MPCv4 which in-
//                          cludes built-in microcycle length control and 6502-
//                          compatible wait state generator: Phi1O and Phi2O are
//                          are maintained as symmetrical signals. Removed clock
//                          stretch logic, BUFGMUX, and added four more micro-
//                          cycle state decode signals: C4-C8. This required in-
//                          creasing the MC vector size from 2 to 3 bits.
//
//  2.21    12C03   MAM     Added C7 to the CE for the external memory data in-
//                          put. Also qualified DI_IFD CEwith the Rdy input sig-
//                          nal.
//
//  2.30    13F08   MAM     Modified for Enso's Spartan 3A board with its 60 MHz
//                          oscillator. Added an input for that clock, divided
//                          the 60 MHz input by 4, and output the 15 MHz signal.
//                          Expect Enso to connect the output of the divider to
//                          the input clock pin of the M65C02 DCM. This mini-
//                          mizes the amount of work needed to port the M65C02
//                          to his project. An accompanying change is needed to
//                          UCF file.
//
//  2.40    13F17   MAM     Reworked address decode to match the implementation
//                          of the 1004-0001 M65C02 Demo Card: two 32kB RAMs,
//                          one 512kB Flash, IO, and Boot ROM (internal Block
//                          RAM). RAM[0] is fully mapped. Only the first 16kB of
//                          RAM[1] is mapped. For the ROM, 12kB is mapped. The
//                          external IO is mapped to 2kB. The last 2kB are
//                          mapped to a Block RAM that serves to hold the Boot
//                          Program.
//
//  2.71    13F20   MAM     Corrected error in the generation of the Rst_M65C02
//                          internal reset signal. The reduction of the reset
//                          signal shift register was previously done as an AND.
//                          That reduction has been changed to an OR, which is
//                          the correct vector reduction operator to generate
//                          internal reset signal from the external nRst and the
//                          DCM_Locked signal.
//
//  2.72    13H04   MAM     Removed unused code. Changed the DI multiplexer into
//                          simple OR gate. The FFs feeding into the OR gate are
//                          forced to 0 if not selected. Changed to reset signal
//                          for several output strobes and input registers. On
//                          outputs, the RnW signal terminates synchronously
//                          with the rising edge of the Wr strobe. DI_IFD is rst
//                          if an internal data source is selected. BootIFD is
//                          reset if an external data source is selected.
//
//  2.73    13H17   MAM     Adapted the M16C5x Clock Generator module for use
//                          with M65C02. Also encapsulated the interrupt handler
//                          function in another module.  
//
// Additional Comments:
//
//  With regard to the W65C02S, the M65C02 microprocessor implementation differs
//  in a number of ways:
//
//      1)  The instruction set is emulated, but cycle accuracy was not an
//          objective, and the implementation provided here makes no attempt to
//          to provide instruction cycles times which match those of the W65C02S
//          microprocessor.
//
//          The M65C02 core provides pipelined execution and fetch operations.
//          This feature allows the M65C02 to reduce the number of memory cycles
//          required per instruction. In addition, additional address generation
//          logic for sequential operand fetch, program counter updates, and
//          stack pointer updates allows some complex instructions to reduce the
//          number of memory cycles required by one or two cycles. (Branches all
//          execute in two cycles regardless of whether the branch is taken or
//          not taken.)
//
//      2)  The W65C02S provides capabilities for wait state insertion, external
//          DMA control, and external falling edge-edge setting of the V flag in
//          the processor status word.
//
//          The M65C02 implementation provided here does not support the inser-
//          tion of wait states by external logic. The implementation does sup-
//          port the BE input signal to tri-state the signals of the processor
//          connecting to the bus. The BE_In input port will tri-state all of
//          the M65C02 processor bus signals. Since wait state insertion is not
//          supported, external DMA logic can not stop the M65C02 processor and
//          take control of the bus. The nSO port is provided to reserve a pin
//          for a potential future upgrade of the M65C02 to support the Set
//          Overflow feature found in the W65C02S. The current implementation of
//          the M65C02 core will have to be modified to support this function.
//
//      3)  Like the W65C02S, the M65C02 provides a Vector Pull output pin. The
//          pin, nVP, is asserted by the M65C02 during the two memory cycles in
//          which the IRQ/NMI/BRK/RST vectors are read from ROM/RAM/Registers.
//
//      4)  Unlike the W65C02S, the M65C02 provides four chip enable outputs to
//          simplify the selection of RAM, ROM, SYStem ROM, and I/O devices.
//
//          The current implementation provides a four chip enables: CE[3:0].
//
//          CE[0], RAM chip enable, asserts for a 48kB range: 0x0000-0xBFFF.
//          CE[1], ROM chip enable, asserts for a  8kB range: 0xC000-0xDFFF.
//          CE[2], SYS chip enable, asserts for a  4kB range: 0xE000-0xEFFF.
//          CE[3], IO  chip enable, asserts for a  4kB range: 0xF000-0xFFFF.
//          
//          The M65C02 also makes provisions for extended address outputs,
//          XA[3:0], which are intended to be used with a simple internal MMU to
//          allow mapping of 8kB blocks in a total address space of 4MB.
//
//      5)  The M65C02 implements a bus interface that is not exactly a standard
//          implementation of the two phase 6502 memory interface.
//
//          To address generation logic used to reduce the number of memory
//          cycles required per instruction is combinatorial and in series with
//          the output address lines. The M65C02 registers all I/O signals. The
//          consequence of this implementation detail is that the M65C02's
//          address output is delayed from its internal clock's rising edge by a
//          significant portion of the clock period. A synchronous output is
//          very much desired because it provides consistent clock to output 
//          delay times, and it eliminates the skew in the combinatorial signal
//          paths of the M65C02 core's address generator. Thus, the memory
//          address, which in a typical 6502 is output during Phi1O, is not out-
//          put by the M65C02 until the start of Phi2O.
//
//          The control signals and the output data are are similarly registered
//          and delayed to coincide with the delay in the address. This means
//          that the external memory and I/O devices must be able to operate
//          with signals which are only asserted during Phi2O. The reduced
//          operating margins means that RAMs and IO devices must be able to
//          reliably operate in a window of approximately 20ns.
//
//          To use the M65C02 core in this environment, the M65C02 processor
//          implementation effectively shews the 6502 memory cycle by a quarter
//          of the cycle. There are four states in the M65C02 core's microcycle.
//
//              C1 - Address computation cycle
//              C2 - Output address, data, and control signals
//              C3 - Deassert control, and capture input data
//              C4 - Execute current instruction and decode next instruction 
//
//          In this four cycle process, Phi1O is asserted during C4 and C1, and
//          Phi2O is asserted during C2 and C3. 
//          
//          For SRAMs, it is not difficult to meet the timing requirements im-
//          posed by this modified 6502 memory cycle with an inexpensive device.
//          For ROMs, the modified 6502 memory cycle is difficult to satisfy 
//          with devices suitable for use with a 6502, i.e. NOR Flash devices.
//          The minimum access times that NOR Flash devices provide is 45ns, and
//          the typical device requires access times of 55ns and/or 70ns.
//
//          One objective of the M65C02 is to provide a memory interface solu-
//          tion to which it is easy to connect readily available memory. It is
//          for this reason that the CE logic is included in the implementation.
//          In addition, two control signals, nOE and nWr, are provided so that
//          external logic is not required to combine Phi2O and RnW into output
//          and write enable signals.
//
//          Without implementing a wait state generator, the M65C02 requires
//          some means to support a slow NOR Flash memory devices. To accomplish
//          this without requiring external logic or extremely fast NOR Flash
//          devices, means that some type of internally generated clock stretch
//          logic is required. The M65C02 provides automatic clock stretching
//          logic for the IO chip enable address range. 
//
//          The FPGA clocking resources provide a glitchless clock multiplexer.
//          Using one of these multiplexers, the M65C02 multiplexes the internal
//          system clock between 73.728 MHz ClkFX clock and the 36.864 MHz Clk2X
//          clock. (ClkFX and Clk2X are directly related and generated in phase
//          from the input clock. Clk2X is used as the feedback source for the
//          DCM, and is in phase with ClkFX which is generated by the DFS.)
//
//          These clock changes will be glitch free, and will demonstrate the
//          operation of a clocking resource of the FPGA that is seldom used.
//          But when accessing the 4kB of IO, the frequency and duty cycle of
//          the Phi1O/Phi2O two phase clock will not be held at 18.432 MHz or
//          50%. The clock multiplexer logic stretches the clocks from a nominal
//          period equal to the period of the input clock, or 54.253ns, to a
//          period equal to 1.5x the period of the input clock, or 81.830ns. In
//          the clock multiplexer implemented, the Phi1O pulse width is un-
//          changed, 27.127ns, and the Phi2O pulse width is doubled, 54.253ns.
//
////////////////////////////////////////////////////////////////////////////////

module M65C02 #(
    parameter pStkPtr_Rst  = 8'hFF,         // SP Value after Rst

    parameter pIRQ_Vector = 16'hFFFE,       // IRQ Vector Addrs
    parameter pBRK_Vector = 16'hFFFE,       // Brk Vector Addrs
    parameter pRST_Vector = 16'hFFFC,       // Reset Vector Addrs
    parameter pNMI_Vector = 16'hFFFA,       // NMI Vector Addrs
    
    parameter pInt_Hndlr  = 9'h021,         // Microprogram Interrupt Handler

    parameter pBRK        = 3'b010,         // BRK #imm instruction
    parameter pWAI        = 3'b111,         // WAI Mode

    parameter pNOP        = 8'hEA,          // M65C02 Core NOP instruction

    parameter pROM_AddrWidth = 11,          // Boot/Monitor ROM Addres Width

    parameter pM65C02_uPgm  = "Src/M65C02_uPgm_V3a.coe",
    parameter pM65C02_IDec  = "Src/M65C02_Decoder_ROM.coe",
    parameter pBootROM_File = "Src/M65C02_Tst5.txt"
)(
    input   nRst,               // System Reset Input
    output  nRstO,              // Internal System Reset Output (OC w/ PU)
    input   ClkIn,              // System Clk Input

    output  reg Phi2O,          // Clock Phase 2 Output
    output  reg Phi1O,          // Clock Phase 1 Output - complement of Phi2O
    
    input   nSO,                // Set oVerflow: currently unimplemented

    input   nNMI,               // Non-Maskable Interrupt Request: edge sense
    input   nIRQ,               // Maskable Interrupt Request: level sense
    output  nVP,                // Vector Pull: asserted to indicate ISR taken

    input   BE_In,              // Bus Enable: tri-states address, data, control
    output  Sync,               // Synchronize: asserted during opcode fetch
    output  nML,                // Memory Lock: asserted during RMW instructions

    output  [3:0] nCE,          // Chip Enable for External RAM/ROM Memory
    output  RnW,                // Read/nWrite cycle control output signal
    output  nWr,                // External Asynchronous Bus Write Strobe
    output  nOE,                // External Asynchronous Bus
    inout   Rdy,                // Bus cycle Ready, drive low to extend cycle
    output  [ 3:0] XA,          // Extended Address Output for External Memory
    output  [15:0] A,           // External Memory Address Bus
    inout   [ 7:0] DB,          // External, Bidirectional Data Bus
    
    input   nWP_In,             // Internal Boot/Monitor RAM write protect

    output  reg nWait,          // Driven low by Wait instruction (ASIC-only)
    
    output  reg [4:0] LED,      // LED Test Register
    
    output  nSel,               // SPI I/F Chip Select
    output  SCk,                // SPI I/F Serial Clock
    output  MOSI,               // SPI I/F Master Out/Slave In Serial Data
    input   MISO                // SPI I/F Master In/Slave Out Serial Data
);

///////////////////////////////////////////////////////////////////////////////
//
//  Declarations
//

wire    Rst;                    // Internal reset (Clk)
reg     OE_nRstO;               // Internal reset output (Buf_ClkIn)

//wire    RE_NMI;                 // Output pulse signal from nNMI edge detector
//wire    CE_NMI;                 // NMI latch/register clock enable
//reg     NMI;                    // NMI latch/register to hold NMI until serviced
wire    NMI;                    // NMI latch/register to hold NMI until serviced

//reg     nIRQ_IFD, IRQ;          // External maskable interrupt request inputs
wire    IRQ;                    // External maskable interrupt request input

wire    Int;                    // Interrupt handler interrupt signal to M65C02
wire    [15:0] Vector;          // Interrupt handler interrupt vector to M65C02

wire    Brk;                    // Decoded M65C02 core instruction mode - BRK

reg     BE_IFD;                 // External Bus Enable input register (IOB)
wire    BE;                     // Internal Bus Enable signal

wire    IRQ_Msk;                // M65C02 core interrupt mask
wire    IntSvc;                 // M65C02 core interrupt service indicator
wire    ISR;                    // M65C02 core signal for signaling vector read
wire    Done;                   // M65C02 core instruction complete/fetch
wire    [2:0] Mode;             // M65C02 core instruction mode
wire    RMW;                    // M65C02 core Read-Modify-Write indicator
wire    [2:0] MC;               // M65C02 core microcycle 
wire    [1:0] IO_Op;            // M65C02 core I/O cycle type
wire    [15:0] AO;              // M65C02 core Address Output
wire    [ 7:0] DI;              // M65C02 core Data Input
wire    [ 7:0] DO;              // M65C02 core Data Output

wire    C1, C2, C3, C4;         // Decoded microcycle states
wire    C5, C6, C7, C8;         // Decoded microcycle states

reg     [1:0] VP;               // Vector read/pull pulse stretcher

reg     Sync_OFD;
reg     nML_OFD;
reg     RnW_OFD;

wire    BootROM;                // Internal Block RAM/ROM for Boot/Monitor
wire    IO, ROM;                // Address decode signals: CE[3], CE[2]
wire    [1:0] RAM;              // Address decode signals: CE[1], CE[0]

reg     [ 3:0] nCE_OFD;         // Decoded Chip Enable output (IOB registers)
reg     [ 3:0] XA_OFD;          // Extended Address output (IOB registers)
reg     [15:0] AO_OFD;          // Address Output (IOB registers)

reg     nOE_OFD, nWr_OFD;

reg     [7:0] DO_OFD;
reg     [7:0] DI_IFD;

reg     nWP;                        // Boot/Monitor RAM write protect
reg     WE_Boot;                    // Write Enable for the Boot/Monitor ROM
reg     [(pROM_AddrWidth-1):0] iAO; // Internal address pipeline register
reg     [7:0] iDO;                  // Internal output data pipeline register
reg     [7:0] Boot [((2**pROM_AddrWidth)-1):0];  // Boot ROM/RAM (2k x 8)
reg     [7:0] Boot_DO;              // Boot/Monitor ROM output data (absorbed)
reg     [7:0] Boot_IFD;             // Boot/Monitor ROM output pipeline register

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

// Instantiate the Clk and Reset Generator Module

M65C02_ClkGen   ClkGen (
                    .nRst(nRst), 
                    .ClkIn(ClkIn),
                    
                    .Clk(Clk),              // Clk      <= (M/D) x ClkIn
                    .Clk_UART(),            // Clk_UART <= 2x ClkIn 
                    .Buf_ClkIn(Buf_ClkIn),  // RefClk   <= Buffered ClkIn

                    .Rst(Rst)
                );

//  Generate Reset output for use by external circuits

always @(posedge Buf_ClkIn or posedge Rst)
begin
    if(Rst)
        OE_nRstO <= #1 1;
    else
        OE_nRstO <= #1 0;
end

assign nRstO = ((OE_nRstO) ? 0 : 1'bZ);

//
//  Process External NMI and maskable IRQ Interrupts
//

M65C02_IntHndlr #(
                    .pRST_Vector(pRST_Vector),
                    .pIRQ_Vector(pIRQ_Vector),
                    .pBRK_Vector(pBRK_Vector),
                    .pNMI_Vector(pNMI_Vector)
                ) IntHndlr (
                    .Rst(Rst), 
                    .Clk(Clk),
                    
                    .nNMI(nNMI), 
                    .nIRQ(nIRQ), 
                    .Mode(Mode), 

                    .IRQ_Msk(IRQ_Msk),
                    .IntSvc(IntSvc),
                    
                    .Int(Int), 
                    .Vector(Vector), 

                    .NMI(NMI), 
                    .IRQ(IRQ), 
                    .Brk(Brk)
                );

//  Synchronize BE input to Clk

always @(posedge Clk or posedge Rst) BE_IFD <= #1 ((Rst) ? 0 : BE_In);

assign BE = BE_IFD;

//  Instantiate M65C02 Core

M65C02_Core #(
                .pStkPtr_Rst(pStkPtr_Rst),
                .pInt_Hndlr(pInt_Hndlr),
                .pM65C02_uPgm(pM65C02_uPgm),
                .pM65C02_IDec(pM65C02_IDec)
            ) uP (
                .Rst(Rst), 
                .Clk(Clk),
                
                .IRQ_Msk(IRQ_Msk),
                .xIRQ(IRQ),                
                .Int(Int), 
                .Vector(Vector), 
                .IntSvc(IntSvc),
                .ISR(ISR),

                .Done(Done), 
                .SC(), 
                .Mode(Mode), 
                .RMW(RMW), 
                
                .MC(MC), 
                .MemTyp(),
                .Wait(~Rdy),
                .Rdy(),
                
                .IO_Op(IO_Op), 
                .AO(AO), 
                .DI(DI),
                .DO(DO),
                
                .A(), 
                .X(), 
                .Y(), 
                .S(), 
                .P(), 
                .PC(),
                
                .IR(),
                .OP1(), 
                .OP2()
            );
            
//  Define the Memory Cycle Strobes (1 cycle in width)

assign C1 = (MC == 6);      // 1st cycle of microcycle
assign C2 = (MC == 7);      // 2nd cycle of microcycle
assign C3 = (MC == 5);      // 3rd cycle of microcycle
assign C4 = (MC == 4);      // 4th cycle of microcycle
//
assign C5 = (MC == 2);      // 5th cycle of microcycle (Wait State Sequence)
assign C6 = (MC == 3);      // 6th cycle of microcycle (Wait State Sequence)
assign C7 = (MC == 1);      // 7th cycle of microcycle (Wait State Sequence)
assign C8 = (MC == 0);      // 8th cycle of microcycle (Wait State Sequence)

//  Assign Phi1O and Phi2O

always @(posedge Clk or posedge Rst)
begin
    if(Rst)
        {Phi1O, Phi2O} <= #1 2'b01;
    else begin
        Phi1O <= #1 (C3 | C4 | C7 | C8);
        Phi2O <= #1 (C1 | C2 | C5 | C6);
    end
end

//  Generate Chip Enables

assign BootROM = (&AO[15:12] &  AO[11]);        // 0xF800 - 0xFFFF =  2kB (Int)
assign IO      = (&AO[15:12] & ~AO[11]);        // 0xF000 - 0xF7FF =  2kB (Ext)
assign ROM     = (&AO[15:14] & ~&AO[13:12]);    // 0xC000 - 0xEFFF = 12kB (Ext)
assign RAM[1]  = (AO[15] & ~AO[14]);            // 0x8000 - 0xBFFF = 16kB (Ext)
assign RAM[0]  = ~AO[15];                       // 0x0000 - 0x7FFF = 32kB (Ext)

always @(posedge Clk)
begin
    if(Rst)
        nCE_OFD <= #1 ~0;
    else if(C1)
        nCE_OFD <= #1 {~IO, ~ROM, ~RAM[1], ~RAM[0]};
end

assign nCE = ((BE) ? nCE_OFD : {4{1'bZ}});

//  Generate Address Output

always @(posedge Clk)
begin
    if(Rst)
        {XA_OFD, AO_OFD} <= #1 {{4{1'b1}}, pRST_Vector};
    else
        {XA_OFD, AO_OFD} <= #1 {{4{AO[15]}}, AO};
end

assign {XA, A} = ((BE) ? {XA_OFD, AO_OFD} : {{4{1'bZ}}, {16{1'bZ}}});

//  Generate Vector Pull Output

always @(posedge Clk)
begin
    if(Rst)
        VP <= #1 0;
    else if(C4)
        VP <= #1 ((ISR) ? 2'b11 : {1'b0, VP[1]});
end

assign nVP = ((BE) ? ~VP[0] : 1'bZ);

//  Generate nWait output; assert nRdy input when nWait asserted

always @(posedge Clk or posedge Rst)
begin
    if(Rst)
        nWait <= #1 1;
    else if(C1)
        nWait <= #1 ~(Mode == pWAI);
end

//  Generate M65C02 Memory Lock Signal

always @(posedge Clk)
begin
    if(Rst)
        nML_OFD <= #1 1;
    else if(C1)
        nML_OFD <= #1 ~RMW;
end

assign nML = ((BE) ? nML_OFD : 1'bZ);

//  Generate Sync Output

always @(posedge Clk)
begin
    if(Rst)
        Sync_OFD <= #1 1;
    else if(C1)
        Sync_OFD <= #1 Done;
end

assign Sync = ((BE) ? Sync_OFD : 1'bZ);

//  Generate M65C02 RnW output

always @(posedge Clk)
begin
    if(Rst | ((C3 | C7) & Rdy))
        RnW_OFD <= #1 1;
    else if(C1)
        RnW_OFD <= #1 ~(IO_Op == 1);
end

assign RnW = ((BE) ? RnW_OFD : 1'bZ);

//  Generate Asynchronous SRAM Read Strobe

always @(posedge Clk)
begin
    if(Rst | ((C3 | C7) & Rdy))
        nOE_OFD <= #1 1;
    else if(C1)
        nOE_OFD <= #1 (~IO_Op[1] | BootROM);
end

assign nOE = ((BE) ? nOE_OFD : 1'bZ);

//  Generate Asynchronous SRAM Write Strobe 

always @(posedge Clk)
begin
    if(Rst | ((C3 | C7) & Rdy))
        nWr_OFD <= #1 1;
    else if(C1)
        nWr_OFD <= #1 ~(IO_Op == 1);
end

assign nWr = ((BE) ? nWr_OFD : 1'bZ);

//  Drive DO out of M65C02 module
//      Feed nWR strobe back in as second output enable. Coupled with half cycle
//      shift in the nOE signal, these delays should make it easy to satisfy 
//      bus disable times when write operations follow reads and vice-versa.


always @(posedge Clk or posedge Rst)
begin
    if(Rst)
        DO_OFD <= #1 0;
    else if(C1)
        DO_OFD <= #1 DO;
end

assign DB = ((BE & ~nWr) ? DO_OFD : 8'bZ);

//  Capture Input Data from External Memory
//      Half cycle shift allows more time for RAM/peripheral device to output
//      data. Internal signal paths in the FPGA will operate on the data within
//      half a cycle of Clk. This requires tighter path controls by the map and
//      route tools. DI is distributed to IR, OP1, OP2, uPgm_ROM, and IDec_ROM.

assign CE_DI_FFs  = ((C3 | C7) & Rdy);
assign Rst_DI_IFD = (Rst | BootROM);

always @(posedge Clk)
begin
    if(Rst_DI_IFD)
        DI_IFD <= #1 0;
    else if(CE_DI_FFs)
        DI_IFD <= #1 DB;
end

//  Implement 2k x 8 internal Boot/Monitor ROM in Block RAM
//      Allow writes so that the NMI, RST, and IRQ vectors can be changed.
//      External active low write protect signal allows the writing to this RAM
//      to be inhibited.

//  Synchronize external Boot/Monitor ROM write protect

always @(posedge Clk or posedge Rst) nWP <= #1 ((Rst) ? 0 : nWP_In);

//  Generate a synchronous Boot/Monitor ROM write enable 

always @(posedge Clk or posedge Rst)
begin
    if(Rst)
        WE_Boot <= #1 0;
    else
        WE_Boot <= #1 (BootROM & (IO_Op == 1) & nWP & C1);
end

//  Capture the output address to break long delay path like done for output
//      address

always @(posedge Clk)
begin
    if(Rst) begin
        iAO <= #1 pRST_Vector;
        iDO <= #1 0;
    end else if(C1) begin
        iAO <= #1 AO;
        iDO <= #1 DO;
    end
end

initial
  $readmemh(pBootROM_File, Boot, 0, ((2**pROM_AddrWidth)-1));
  
always @(posedge Clk)
begin
    if(WE_Boot)
        Boot[iAO] <= #1 iDO;
        
    Boot_DO <= #1 Boot[iAO];
end

//  Add pipeline register to break circular path through Address Generator

always @(posedge Clk or posedge Rst)
begin
    if(Rst)
        Boot_IFD <= #1 0;
    else if(CE_DI_FFs)
        Boot_IFD <= #1 ((BootROM) ? Boot_DO : 0);
end

//  Multiplex the External and Internal Data sources

assign DI = Boot_IFD | DI_IFD;

//  LED Test Register

assign WE_LED = (IO & (iAO[10:3] == 8'hFF) & (IO_Op == 1));

always @(posedge Clk)
begin
    if(Rst)
        LED <= #1 0;
    else if(C3)
        LED <= #1 ((WE_LED) ? iDO[7:3] : LED);
end

endmodule
