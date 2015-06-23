////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2008-2013 by Michael A. Morris, dba M. A. Morris & Associates
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
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates
// Engineer:        Michael A. Morris
//
// Create Date:     11:30:15 01/13/2008
// Design Name:     PIC16C5x
// Module Name:     C:/ISEProjects/ISE10.1i/P16C5x/PIC16C5x_Top.v
// Project Name:    PIC16C5x
// Target Devices:  N/A
// Tool versions:   ISEWebPACK 10.1i SP3
//
// Description:
//
//  Module implements a pipelined PIC16C5x processor. The processor implements
//  all PIC16C5x instructions. The module is derived from the PIC16C5x.v module
//  and removes the tristate control, output, and input registers associated
//  with Ports A...C. These ports are replaced by decoded 6 WE and 3 RE and an
//  I/O data bus. Three WEs assert when the TRIS A, TRIS B, or TRIS C instruc-
//  tions are exectued. The remaining three WEs assert when a register file
//  operation writes to addresses 0x05-0x07, which represent writes to the out-
//  put registers of Ports A...C, respectively. The three REs assert when regis-
//  ter file operations read addresses 0x05-0x07, which represent reads from the
//  input registers of Ports A...C, respectively.
//
//  Note:   Read-Modify-Write operations to register file addresses 0x05-0x07
//          only assert the corresponding WEs. The external logic is expected to
//          multiplex the input registers onto the I/O Data Input (IO_DI) bus on
//          the basis of the addresses. The core reads IO_DI and writes out the
//          modified data on the I/O Data Output (IO_DO) bus. In the event that
//          the input registers are implemented as FIFOs, this approach prevents
//          the assertion of a read strobe to the FIFO, which would advance the
//          pointers and cause the loss of the data at the head of the FIFO.
//
// Dependencies:    None
//
// Revision:
//
//  1.00    13F15   MAM     Converted PIC16C5x.v. The conversion entails remov-
//                          ing I/O ports and adding external DI/DO data bus, 
//                          write and read enables for I/O port registers and
//                          input buffers. This will demonstrate how PIC16C5x
//                          can be modified to support more sophisticated I/O.
//
//  1.10    13F15   MAM     Pulled in the optimized instruction decoder from
//                          F16C5x.v. Also converted the ALU section into a
//                          separate module.
//
//  1.30    13F20   MAM     Added parameter to determine reset vector. Although
//                          a full 4k x 12 program memory is available, no stan-
//                          dard 12-bit instruction length PIC supports that
//                          amount of program memory. To use free PIC-compatible
//                          tools, the parameter can be set to a value in the
//                          range of the supported devices.
//
//  1.40    13G07   MAM     Corrected error with the test conditional pertaining
//                          to BTFSC/BTFSS instructions. Qualifier was using
//                          ALU_Op[1:0] instead of ALU_Op[7:6]. Under certain
//                          combinations, results were correct.
//
//  1.50    13J19   MAM     Modified various register Write Enable/Clock Enable
//                          implementation to minimize logic/multiplexers and
//                          make better use of built-in FF CE functionality.
//
//  1.51    13J20   MAM     Added Msk port to CPU, made minor updates to
//                          comments, and removed all unused code.
//
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module P16C5x #(
    parameter pRstVector = 12'h7FF,         // Reset Vector Location (PIC16F59)
    parameter pWDT_Size  = 20,              // Use 20 for synth. and 10 for Sim.
    parameter pRAMA_Init = "Src/RAMA.coe",  // RAM A initial value file ( 8x8)
    parameter pRAMB_Init = "Src/RAMB.coe"   // RAM B initial value file (64x8)
)(
    input   POR,                // In  - System Power-On Reset

    input   Clk,                // In  - System Clock
    input   ClkEn,              // In  - Processor Clock Enable

    input   MCLR,               // In  - Master Clear Input
    input   T0CKI,              // In  - Timer 0 Clock Input

    input   WDTE,               // In  - Watchdog Timer Enable

    output  reg [11:0] PC,      // Out - Program Counter
    input   [11:0] ROM,         // In  - Instruction Data Input
    
    output  WE_TRISA, WE_TRISB, WE_TRISC,   // Out - Tristate Register X WE
    output  WE_PORTA, WE_PORTB, WE_PORTC,   // Out - Port X Output Register
    output  RE_PORTA, RE_PORTB, RE_PORTC,   // In  - Port X Input Register

    output  [7:0] IO_DO,        // Out - I/O Bus Data Output
    input   [7:0] IO_DI,        // In  - I/O Bus Data Input

//
//  Debug Outputs
//

    output  reg Rst,            // Out - Internal Core Reset

    output  reg [5:0] OPTION,   // Out - Processor Configuration Register Output
    
    output  reg [11:0] IR,      // Out - Internal Instruction Register
    output  [ 9:0] dIR,         // Out - Pipeline Register (Non-ALU Instruct.)
    output  [11:0] ALU_Op,      // Out - Pipeline Register (ALU Instructions)
    output  [ 8:0] KI,          // Out - Pipeline Register (Literal)
    output  [ 7:0] Msk,         // Out - Pipeline Register Bit Mask
    output  Err,                // Out - Instruction Decode Error Output

    output  reg Skip,           // Out - Skip Next Instruction

    output  reg [11:0] TOS,     // Out - Top-Of-Stack Register Output
    output  reg [11:0] NOS,     // Out - Next-On-Stack Register Output

    output  [7:0] W,            // Out - Working Register Output

    output  [7:0] FA,           // Out - File Address Output
    output  [7:0] DO,           // Out - File Data Input/ALU Data Output
    output  [7:0] DI,           // Out - File Data Output/ALU Data Input

    output  reg [7:0] TMR0,     // Out - Timer 0 Timer/Counter Output
    output  reg [7:0] FSR,      // Out - File Select Register Output
    output  [7:0] STATUS,       // Out - Processor Status Register Output

    output  T0CKI_Pls,          // Out - Timer 0 Clock Edge Pulse Output

    output  reg WDTClr,         // Out - Watchdog Timer Clear Output
    output  reg [pWDT_Size-1:0] WDT, // Out - Watchdog Timer
    output  reg WDT_TC,
    output  WDT_TO,             // Out - Watchdog Timer Timeout Output

    output  reg [7:0] PSCntr,   // Out - Prescaler Counter Output
    output  PSC_Pls             // Out - Prescaler Count Pulse Output
);

////////////////////////////////////////////////////////////////////////////////
//
//  Local Parameter Declarations
//

//  Special Function Register Addresses

localparam pINDF   = 5'b0_0000;     // Indirect Rd/Wr -- Address in FSR (0x04)
localparam pTMR0   = 5'b0_0001;     // Timer 0
localparam pPCL    = 5'b0_0010;     // Lower 8-bits of PC
localparam pSTATUS = 5'b0_0011;     // Status Register
localparam pFSR    = 5'b0_0100;     // File Select Register - Extended RAM ptr
localparam pPORTA  = 5'b0_0101;     // Port A: Tristate, Output, Input Registers
localparam pPORTB  = 5'b0_0110;     // Port B: Tristate, Output, Input Registers
localparam pPORTC  = 5'b0_0111;     // Port C: Tristate, Output, Input Registers

////////////////////////////////////////////////////////////////////////////////
//
//  Module Level Declarations
//

wire    Rst_M16C5x;         // Internal Core Reset (asynchronous)

wire    CE;                 // Internal Clock Enable: CE <= ClkEn & ~PD;

reg     [2:0] PA;           // PC Load Register PC[11:9] = PA[2:0]
wor     [7:0] SFR;          // Special Function Registers Data Output

wire    Rst_TO;             // Rst TO FF signal
reg     TO;                 // Time Out FF (STATUS Register)
wire    Rst_PD;             // Rst Power Down FF signal
reg     PD;                 // Power Down FF (STATUS Register)
reg     PwrDn;              // Power Down FF

// RAM Address: FA[4] ? {2'b0, FA[3:0]} : {FSR[6:5], FA[3:0]}

wire    [5:0] Addrs;
reg     [7:0] RAMA[ 7:0];   // RAM Block 0    = 0x08 - 0x0F      (Non-Banked)
reg     [7:0] RAMB[63:0];   // RAM Block 1..8 = @{FSR[6:5],FSR[3:0]} (Banked)

wire    T0CS;               // Timer 0 Clock Source Select
wire    T0SE;               // Timer 0 Source Edge
wire    PSA;                // Prescaler Assignment
wire    [2:0] PS;           // Prescaler Counter Output Bit Select

reg     [2:0] dT0CKI;       // Ext T0CKI Synchronized RE/RE FF chain
reg     PSC_Out;            // Synchronous Prescaler TC register
reg     [1:0] dPSC_Out;     // Rising Edge Detector for Prescaler output

wire    GOTO, CALL, RETLW;  // Signals for Decoded Instruction Register
wire    WE_SLEEP, WE_WDTCLR;
wire    WE_OPTION;

wire    WE_TMR0;            // Write Enable Signals Decoded from FA[4:0]
wire    WE_PCL;
wire    WE_STATUS;
wire    WE_FSR;

wire    WE_PSW;             // Write Enable for STATUS[2:0]: {Z, DC, C}

////////////////////////////////////////////////////////////////////////////////
//
//  ALU Declarations
//

wire    C, DC, Z;       // ALU Status Outputs
wire    Z_Tst, g;       // Zero and Bit Test Condition Code 

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Top Level Implementation
//

assign CE = ClkEn & ~PwrDn;         // Internal Clock Enable, refer to comments

assign Rst_M16C5x = (POR | MCLR | WDT_TO);      // Internal Processor Reset

always @(posedge Clk or posedge Rst_M16C5x)
begin
    if(Rst_M16C5x)
        Rst <= #1 ~0;
    else if(CE)
        Rst <= #1  0;
end

//  Capture Program ROM input into Instruction Register (IR)

always @(posedge Clk)
begin
    if(Rst)
        IR <= #1 0;
    else if(CE)
        IR <= #1 ROM;
end

//  Instantiate Optimized Instruction Decoder - ROMs used to speed decode

P16C5x_IDec IDEC (
                .Rst(Rst),
                .Clk(Clk),
                .CE(CE),
                
                .DI(ROM),
                .Skip(Skip),

                .dIR(dIR),
                .ALU_Op(ALU_Op),
                .KI(KI),
                .Msk(Msk),

                .Err(Err)
            );

//  Instantiate ALU module

P16C5x_ALU  ALU (
                .Rst(Rst),
                .Clk(Clk),
                .CE(CE),
                
                .ALU_Op(ALU_Op[9:0]),
                
                .DI(DI),
                .KI(KI[7:0]),
                .Msk(Msk),
                
                .WE_PSW(WE_PSW),

                .DO(DO),
                .Z_Tst(Z_Tst),
                .g(g),
                
                .W(W),
                
                .Z(Z),
                .DC(DC),
                .C(C)
            );

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Microprocessor Core Implementation
//
//  Pipeline Instruction Register Assignments

assign GOTO      = dIR[0];
assign CALL      = dIR[1];
assign RETLW     = dIR[2];
assign WE_SLEEP  = dIR[3];
assign WE_WDTCLR = dIR[4];
assign WE_TRISA  = dIR[5];
assign WE_TRISB  = dIR[6];
assign WE_TRISC  = dIR[7];
assign WE_OPTION = dIR[8];
assign LITERAL   = dIR[9];      // Added to support WE/RE PortX external I/F

//  Skip Logic

assign Tst = ALU_Op[8];

always @(*)
begin
    Skip <= WE_SLEEP | WE_PCL
            | ((Tst) ? ((ALU_Op[7] & ALU_Op[6]) ? g    : Z_Tst)
                     : ((GOTO | CALL | RETLW)   ? 1'b1 : 1'b0 ));
end

//  File Register Address Multiplexer

assign INDF = ALU_Op[10];
assign FA   = ((INDF) ? FSR
                      : ((KI[4]) ? {FSR[6:5], KI[4:0]}
                                 : {    2'b0, KI[4:0]}));

//  File Register Write Enable

assign WE_F = ALU_Op[11];

//  Special Function Register Write Enables

assign WE_TMR0   =  WE_F & (FA[4:0] == pTMR0);
assign WE_PCL    =  WE_F & (FA[4:0] == pPCL);
assign WE_STATUS =  WE_F & (FA[4:0] == pSTATUS);
assign WE_FSR    =  WE_F & (FA[4:0] == pFSR);

//  I/O Ports moved to an external implementation
//      WE_PortX asserts for an FA address match when LITERAL not asserted and a
//          WE_F is asserted.
//      RE_PortX asserts for an FA address match whn LITERAL not asserted, WE_F
//          is not asserted, and WE_TrisX not asserted. Tris X has the same FA
//          field. Tristate control for port A is instruction 0x005, and FA is
//          the least significant 5 bits of the instruction. FA of 0x05 is the
//          file address of Port A. (The same applies for Tris B and Tris C.)

assign WE_PORTA  =  WE_F & (FA[4:0] == pPORTA) & ~LITERAL;
assign WE_PORTB  =  WE_F & (FA[4:0] == pPORTB) & ~LITERAL;
assign WE_PORTC  =  WE_F & (FA[4:0] == pPORTC) & ~LITERAL;
//
assign RE_PORTA  = ~WE_F & (FA[4:0] == pPORTA) & ~LITERAL & ~WE_TRISA;
assign RE_PORTB  = ~WE_F & (FA[4:0] == pPORTB) & ~LITERAL & ~WE_TRISB;
assign RE_PORTC  = ~WE_F & (FA[4:0] == pPORTC) & ~LITERAL & ~WE_TRISC;

//  Assign Write Enable for STATUS register Processor Status Word (PSW) bits
//      Allow write to the STATUS[2:0] bits, {Z, DC, C}, only for instructions
//      MOVWF, BCF, BSF, and SWAPF. Exclude instructions DECFSZ and INCFSZ.

assign WE_PSW = WE_STATUS & (ALU_Op[5:4] == 2'b00) & (ALU_Op[8] == 1'b0);

////////////////////////////////////////////////////////////////////////////////
//
// Program Counter Implementation
//
//  On CALL or MOVWF PCL (direct or indirect), load PCL from the ALU output
//  and the upper bits with {PA, 0}, i.e. PC[8] = 0.
//

assign Ld_PCL = CALL | WE_PCL;

always @(posedge Clk)
begin
    if(Rst)
        PC <= #1 pRstVector;    // Set PC to Reset Vector on Rst or WDT Timeout
    else if(CE)
        PC <= #1 (GOTO ? {PA, KI}
                       : (Ld_PCL ? {PA, 1'b0, DO}
                                 : (RETLW ? TOS : PC + 1)));
end

//  Stack Implementation (2 Level Stack)

assign CE_TOS = CE & (CALL | RETLW);

always @(posedge Clk)
begin
    if(POR)
        TOS <= #1 pRstVector;       // Set TOS on Rst or WDT Timeout
    else if(CE_TOS)
        TOS <= #1 ((CALL) ? PC : NOS);
end

assign CE_NOS = CE & CALL;

always @(posedge Clk)
begin
    if(POR)
        NOS <= #1 pRstVector;       // Set NOS on Rst or WDT Timeout
    else if(CE_NOS)
        NOS <= #1 TOS;
end

////////////////////////////////////////////////////////////////////////////////
//
//  Port Configuration and Option Registers

assign CE_OPTION = CE & WE_OPTION;

always @(posedge Clk)
begin
    if(POR)
        OPTION <= #1 8'b0011_1111;
    else if(CE_OPTION)
        OPTION <= #1 W;
end

////////////////////////////////////////////////////////////////////////////////
//
//  CLRWDT Strobe Pulse Generator

always @(posedge Clk)
begin
    if(Rst)
        WDTClr <= #1 0;
    else
        WDTClr <= #1 (WE_WDTCLR | WE_SLEEP) & ~PwrDn;
end

////////////////////////////////////////////////////////////////////////////////
//
//  TO (Time Out) STATUS Register Bit

assign Rst_TO = (POR | (MCLR & PD) | WE_WDTCLR);

always @(posedge Clk)
begin
    if(Rst_TO)
        TO <= #1  0;
    else if(WDT_TO)
        TO <= #1 ~0;
end

////////////////////////////////////////////////////////////////////////////////
//
//  PD (Power Down) STATUS Register Bit - Sleep Mode

assign Rst_PD = POR | (WE_WDTCLR & ~PwrDn);

assign CE_PD = CE & WE_SLEEP;

always @(posedge Clk)
begin
    if(Rst_PD)
        PD <= #1 0;
    else if(CE_PD)
        PD <= #1 1;
end

//  PwrDn - Sleep Mode Control FF: Set by SLEEP instruction, cleared by Rst
//          Differs from PD in that it is not readable and does not maintain
//          its state through Reset. Gates CE to rest of the processor.

assign CE_PwrDn = ClkEn & WE_SLEEP;

always @(posedge Clk)
begin
    if(Rst)
        PwrDn <= #1 0;
    else if(CE_PwrDn)
        PwrDn <= #1 1;
end

////////////////////////////////////////////////////////////////////////////////
//
//  File Register RAM

assign Addrs = {FA[6:5], FA[3:0]};

//  RAM A - 16 Word Distributed RAM

assign WE_RAMA = WE_F & ~FA[4] & FA[3];

initial
  $readmemh(pRAMA_Init, RAMA, 0, 7);

always @(posedge Clk)
begin
    if(CE)
        if(WE_RAMA)
            RAMA[Addrs[2:0]] <= #1 DO;
end

//  RAM B - 64 Word Distributed RAM

assign WE_RAMB = WE_F & FA[4];

initial
  $readmemh(pRAMB_Init, RAMB, 0, 63);

always @(posedge Clk)
begin
    if(CE)
        if(WE_RAMB)
            RAMB[Addrs] <= #1 DO;
end

////////////////////////////////////////////////////////////////////////////////
//
// Special Function Registers
//

assign CE_PA = CE & WE_STATUS;

always @(posedge Clk)
begin
    if(POR)
        PA  <= #1 0;
    else if(CE_PA)
        PA  <= #1 DO[7:5];
end

assign CE_FSR = CE & WE_FSR;

always @(posedge Clk)
begin
    if(POR)
        FSR <= #1 0;
    else if(CE_FSR)
        FSR <= #1 DO;
end

//  Generate STATUS Register

assign STATUS = {PA, ~TO, ~PD, Z, DC, C};

//  Special Function Register (SFR) Multiplexers

assign SFR = ((FA[2:0] == 3'b001) ? TMR0    : 0);
assign SFR = ((FA[2:0] == 3'b010) ? PC[7:0] : 0);
assign SFR = ((FA[2:0] == 3'b011) ? STATUS  : 0);
assign SFR = ((FA[2:0] == 3'b100) ? FSR     : 0);
assign SFR = ((FA[2:0] == 3'b101) ? IO_DI   : 0);
assign SFR = ((FA[2:0] == 3'b110) ? IO_DI   : 0);
assign SFR = ((FA[2:0] == 3'b111) ? IO_DI   : 0);

//  File Data Output Multiplexer

assign DI = (FA[4] ? RAMB[Addrs] : (FA[3] ? RAMA[Addrs[2:0]] : SFR));

//  IO Data Output Multiplexer

assign IO_DO = ((|{WE_TRISA, WE_TRISB, WE_TRISC}) ? W : DO);

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Watchdog Timer and Timer0 Implementation- see Figure 8-6
//
//  OPTION Register Assignments
//

assign T0CS = OPTION[5];     // Timer0 Clock Source:   1 - T0CKI,  0 - Clk
assign T0SE = OPTION[4];     // Timer0 Source Edge:    1 - FE,     0 - RE
assign PSA  = OPTION[3];     // Pre-Scaler Assignment: 1 - WDT,    0 - Timer0
assign PS   = OPTION[2:0];   // Pre-Scaler Count: Timer0 - 2^(PS+1), WDT - 2^PS

// WDT - Watchdog Timer

assign WDT_Rst = Rst | WDTClr;

always @(posedge Clk)
begin
    if(WDT_Rst)
        WDT <= #1 0;
    else if(WDTE)
        WDT <= #1 WDT + 1;
end

//  WDT synchronous TC FF

always @(posedge Clk)
begin
    if(WDT_Rst)
        WDT_TC <= #1 0;
    else
        WDT_TC <= #1 &WDT;
end

// WDT Timeout multiplexer

assign WDT_TO = (PSA ? PSC_Pls : WDT_TC);

////////////////////////////////////////////////////////////////////////////////
//
//  T0CKI RE/FE Pulse Generator (on Input rather than after PSCntr)
//
//      Device implements an XOR on T0CKI and a clock multiplexer for the
//      Prescaler since it has two clock asynchronous clock sources: the WDT
//      or the external T0CKI (Timer0 Clock Input). Instead of this type of
//      gated clock ripple counter implementation of the Prescaler, a fully
//      synchronous implementation has been selected. Thus, the T0CKI must be
//      synchronized and the falling or rising edge detected as determined by
//      the T0CS bit in the OPTION register. Similarly, the WDT is implemented
//      using the processor clock, which means that the WDT TC pulse is in the
//      same clock domain as the rest of the logic.
//

always @(posedge Clk)
begin
    if(Rst)
        dT0CKI <= #1 0;
    else begin
        dT0CKI[0] <= #1 T0CKI;                              // Synch FF #1
        dT0CKI[1] <= #1 dT0CKI[0];                          // Synch FF #2
        dT0CKI[2] <= #1 (T0SE ? (dT0CKI[1] & ~dT0CKI[0])    // Falling Edge
                              : (dT0CKI[0] & ~dT0CKI[1]));  // Rising Edge
    end
end

assign T0CKI_Pls = dT0CKI[2]; // T0CKI Pulse out, either FE/RE

//  Tmr0 Clock Source Multiplexer

assign Tmr0_CS = (T0CS ? T0CKI_Pls : CE);

////////////////////////////////////////////////////////////////////////////////
//
// Pre-Scaler Counter

assign Rst_PSC   = (PSA ? WDTClr : WE_TMR0) | Rst;
assign CE_PSCntr = (PSA ? WDT_TC : Tmr0_CS);

always @(posedge Clk)
begin
    if(Rst_PSC)
        PSCntr <= #1 0;
    else if(CE_PSCntr)
        PSCntr <= #1 PSCntr + 1;
end

//  Prescaler Counter Output Multiplexer

always @(*)
begin
    case (PS)
        3'b000 : PSC_Out <= PSCntr[0];
        3'b001 : PSC_Out <= PSCntr[1];
        3'b010 : PSC_Out <= PSCntr[2];
        3'b011 : PSC_Out <= PSCntr[3];
        3'b100 : PSC_Out <= PSCntr[4];
        3'b101 : PSC_Out <= PSCntr[5];
        3'b110 : PSC_Out <= PSCntr[6];
        3'b111 : PSC_Out <= PSCntr[7];
    endcase
end

// Prescaler Counter Rising Edge Detector

always @(posedge Clk)
begin
    if(POR)
        dPSC_Out <= #1 0;
    else begin
        dPSC_Out[0] <= #1 PSC_Out;
        dPSC_Out[1] <= #1 PSC_Out & ~dPSC_Out[0];
    end
end

assign PSC_Pls = dPSC_Out[1];

////////////////////////////////////////////////////////////////////////////////
//
// Tmr0 Counter/Timer

assign CE_Tmr0 = (PSA ? Tmr0_CS : PSC_Pls);

always @(posedge Clk)
begin
    if(POR)
        TMR0 <= #1 0;
    else if(WE_TMR0)
        TMR0 <= #1 DO;
    else if(CE_Tmr0)
        TMR0 <= #1 TMR0 + 1;
end

endmodule
