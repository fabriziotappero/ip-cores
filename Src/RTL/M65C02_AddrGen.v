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
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates 
// Engineer:        Michael A. Morris 
// 
// Create Date:     09:15:23 11/03/2012 
// Design Name:     WDC W65C02 Microprocessor Re-Implementation
// Module Name:     M65C02_AddrGen.v
// Project Name:    C:\XProjects\ISE10.1i\MAM65C02 
// Target Devices:  Generic SRAM-based FPGA 
// Tool versions:   Xilinx ISE10.1i SP3
//
// Description:
//
//  This file provides the M65C02_Core module's address generator function. This
//  module is taken from the address generator originally included in the
//  M65C02_Core module. The only difference is the addition of an explicit sig-
//  nal which generates relative offset for conditional branches, Rel.
//
// Dependencies:    none 
//
// Revision: 
//
//  0.00    12K03   MAM     Initial File Creation
//
//  1.00    12K03   MAM     Added Mod256 input to control Zero Page addressing.
//                          Reconfigured the stack pointer logic to reduce the
//                          number of adders used in its implementation. Opti-
//                          mized the PC logic using the approach used for the
//                          next address logic, NA.
//
//  1.10    12K12   MAM     Changed name of input signal Mod256 to ZP. When ZP
//                          is asserted, AO is computed modulo 256.
//
//  2.00    13H04   MAM     Modified operand multiplexers into one-hot decoded
//                          OR busses. Changed adder structures slightly so a
//                          16-bit, two operand adder with carry input was syn-
//                          thesized. Changed zero page % 256 logic to use an
//                          AND gate with either 0x00FF or 0xFFFF as the mask.
//
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////

module M65C02_AddrGen(
    input   Rst,                    // System Reset
    input   Clk,                    // System Clock

    input   [15:0] Vector,          // Interrupt/Trap Vector

    input   [3:0] NA_Op,            // Next Address Operation
    input   [1:0] PC_Op,            // Program Counter Operation
    input   [1:0] Stk_Op,           // Stack Pointer Operation
    
    input   ZP,                     // Modulo 256 Control Input
    
    input   CC,                     // Conditional Branch Input Flag
    input   BRV3,                   // Interrupt or Next Instruction Select
    input   Int,                    // Unmasked Interrupt Request Input

    input   Rdy,                    // Ready Input
    
    input   [7:0] DI,               // Memory Data Input
    input   [7:0] OP1,              // Operand Register 1 Input
    input   [7:0] OP2,              // Operand Register 2 Input
    input   [7:0] StkPtr,           // Stack Pointer Input
    
    input   [7:0] X,                // X Index Register Input
    input   [7:0] Y,                // Y Index Register Input

    output  reg [15:0] AO,          // Address Output

    output  reg [15:0] AL,          // Address Generator Left Operand
    output  reg [15:0] AR,          // Address Generator Right Operand
    output  reg [15:0] NA,          // Address Generator Output - Next Address
    output  reg [15:0] MAR,         // Memory Address Register
    output  reg [15:0] PC,          // Program Counter
    output  reg [15:0] dPC          // Delayed Program Counter - Interrupt Adr
);

////////////////////////////////////////////////////////////////////////////////
//
//  Local Parameters
//

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

////////////////////////////////////////////////////////////////////////////////
//
//  Module Declarations
//

reg     [ 6:0] Op_Sel;          // ROM Decoder for Next Address Operation
wire    CE_MAR;                 // Memory Address Register Clock Enable

reg     [ 4:0] PC_Sel;          // ROM Decoder for Program Counter Updates
wire    [15:0] Rel;             // Branch Address Sign-Extended Offset
reg     [15:0] PCL, PCR;        // Program Counter Left and Right Operands
wire    CE_PC;                  // Program Counter Clock Enable

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

//  Next Address Generator

always @(*)                 // PMSO XY C
begin                       // CAtP    0
    case(NA_Op)             //  Rk
        4'b0000 : Op_Sel <= 7'b1000_00_0;   // NA <= PC                  + 0
        4'b0001 : Op_Sel <= 7'b1000_00_1;   // NA <= PC                  + 1
        4'b0010 : Op_Sel <= 7'b0100_00_0;   // NA <= MAR                 + 0
        4'b0011 : Op_Sel <= 7'b0100_00_1;   // NA <= MAR                 + 1
        4'b0100 : Op_Sel <= 7'b0010_00_0;   // NA <= {  1, SP }          + 0
        4'b0101 : Op_Sel <= 7'b0001_00_0;   // NA <= {  0, OP1}          + 0
        4'b0110 : Op_Sel <= 7'b0001_10_0;   // NA <= {  0, OP1} + {0, X} + 0
        4'b0111 : Op_Sel <= 7'b0001_01_0;   // NA <= {  0, OP1} + {0, Y} + 0
        4'b1000 : Op_Sel <= 7'b0001_00_0;   // NA <= {OP2, OP1}          + 0
        4'b1001 : Op_Sel <= 7'b0001_00_0;   // NA <= {OP2, OP1}          + 0
        4'b1010 : Op_Sel <= 7'b0001_00_0;   // NA <= {OP2, OP1}          + 0
        4'b1011 : Op_Sel <= 7'b0001_00_0;   // NA <= {OP2, OP1}          + 0
        4'b1100 : Op_Sel <= 7'b0001_00_0;   // NA <= {OP2, OP1}          + 0
        4'b1101 : Op_Sel <= 7'b0001_00_0;   // NA <= {OP2, OP1}          + 0
        4'b1110 : Op_Sel <= 7'b0001_10_0;   // NA <= {OP2, OP1} + {0, X} + 0
        4'b1111 : Op_Sel <= 7'b0001_01_0;   // NA <= {OP2, OP1} + {0, Y} + 0
    endcase
end

//  Generate Left Address Operand

always @(*) AL <= (  ((Op_Sel[ 6]) ? PC              : 0)
                   | ((Op_Sel[ 5]) ? MAR             : 0)
                   | ((Op_Sel[ 4]) ? {8'h01, StkPtr} : 0)
                   | ((Op_Sel[ 3]) ? {OP2  , OP1   } : 0));
                   
//  Generate Right Address Operand

always @(*) AR <= (  ((Op_Sel[ 2]) ? {8'h00, X}      : 0)
                   | ((Op_Sel[ 1]) ? {8'h00, Y}      : 0));

//  Compute Next Address

always @(*) NA <= (AL + AR + Op_Sel[0]);

//  Generate Address Output - Truncate Next Address when ZP asserted

always @(*) AO <= NA & ((ZP) ? 16'h00FF : 16'hFFFF);

//  Memory Address Register

assign CE_MAR = (|NA_Op) & Rdy;

always @(posedge Clk)
begin
    if(Rst)
        MAR <= #1 Vector;
    else if(CE_MAR)
        MAR <= #1 AO;
end

//  Program Counter

assign CE_PC = ((BRV3) ? ((|PC_Op) & ~Int) : (|PC_Op)) & Rdy;

//  Generate Relative Address

assign Rel = ((CC) ? {{8{DI[7]}}, DI} : 0);

//  Determine the operands for Program Counter updates

always @(*)                 // PDO R C
begin                       // PIP e 0
    case({PC_Op, Stk_Op})   //   2 l
        4'b0000 : PC_Sel <= 5'b100_0_0; // NOP: PC      PC <= PC         + 0
        4'b0001 : PC_Sel <= 5'b100_0_0; // NOP: PC      PC <= PC         + 0
        4'b0010 : PC_Sel <= 5'b100_0_0; // NOP: PC      PC <= PC         + 0
        4'b0011 : PC_Sel <= 5'b100_0_0; // NOP: PC      PC <= PC         + 0
        4'b0100 : PC_Sel <= 5'b100_0_1; // Pls: PC + 1  PC <= PC         + 1
        4'b0101 : PC_Sel <= 5'b100_0_1; // Pls: PC + 1  PC <= PC         + 1
        4'b0110 : PC_Sel <= 5'b100_0_1; // Pls: PC + 1  PC <= PC         + 1
        4'b0111 : PC_Sel <= 5'b100_0_1; // Pls: PC + 1  PC <= PC         + 1
        4'b1000 : PC_Sel <= 5'b010_0_0; // Jmp: JMP     PC <= { DI, OP1} + 0
        4'b1001 : PC_Sel <= 5'b010_0_0; // Jmp: JMP     PC <= { DI, OP1} + 0
        4'b1010 : PC_Sel <= 5'b001_0_0; // Jmp: JSR     PC <= {OP2, OP1} + 0
        4'b1011 : PC_Sel <= 5'b010_0_1; // Jmp: RTS/RTI PC <= { DI, OP1} + 1
        4'b1100 : PC_Sel <= 5'b100_1_1; // Rel: Bcc     PC <= PC + Rel   + 1
        4'b1101 : PC_Sel <= 5'b100_1_1; // Rel: Bcc     PC <= PC + Rel   + 1
        4'b1110 : PC_Sel <= 5'b100_1_1; // Rel: Bcc     PC <= PC + Rel   + 1
        4'b1111 : PC_Sel <= 5'b100_1_1; // Rel: Bcc     PC <= PC + Rel   + 1
    endcase
end

always @(*) PCL <= (  ((PC_Sel[4]) ? PC         : 0)
                    | ((PC_Sel[3]) ? { DI, OP1} : 0)
                    | ((PC_Sel[2]) ? {OP2, OP1} : 0));

always @(*) PCR <=    ((PC_Sel[1]) ? Rel        : 0);

//  Implement Program Counter

always @(posedge Clk)
begin
    if(Rst)
        PC <= #1 Vector;
    else if(CE_PC)
        PC <= #1 (PCL + PCR + PC_Sel[0]);
end

//  Track past values of the PC for interrupt handling
//      past value of PC required to correctly determine the address of the
//      instruction at which the interrupt trap was taken. The automatic incre-
//      ment of the return address following RTS/RTI will advance the address 
//      so that it points to the correct instruction.

always @(posedge Clk)
begin
    if(Rst)
        dPC <= #1 Vector;
    else if(CE_PC)
        dPC <= #1 PC;
end

endmodule
