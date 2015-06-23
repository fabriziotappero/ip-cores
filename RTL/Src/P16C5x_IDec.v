////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2009-2013 by Michael A. Morris, dba M. A. Morris & Associates
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

///////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates
// Engineer:        Michael A. Morris
// 
// Create Date:     18:05:57 08/18/2009 
// Design Name:     PIC16C5x Verilog Processor Model
// Module Name:     C:/ISEProjects/ISE10.1i/F16C5x/PIC16C5x_IDecode 
// Project Name:    C:/ISEProjects/ISE10.1i/F16C5x.ise
// Target Devices:  N/A 
// Tool versions:   ISE 10.1i SP3 
//
// Description:
//
//  Module implements a pipelined instruction decoder for the PIC16C5x family
//  of processors. The decoder utilizes three decode ROMs to reduce the number 
//  of logic levels in the decode path. All PIC16C5x instructions are decoded, 
//  and registered decoded instruction outputs for certain instructions and a
//  registered ALU Operation output is also provided. A decode error output is
//  also provided. The inputs required are the Instruction Register, IR, and a
//  instruction skip, i.e. pipeline flush/delay, signal.
//
//  ROM1 is used to decode instructions in the range of 0x000-0x007 and 0x800-
//  0xFFF. ROM1 outputs data that is multiplexed into the dIR, decoded IR FFs,
//  based on whether the instruction actually fits into this range. A 4-bit
//  address is used to access the ROM. Thus, DI[11] is the most significant 
//  address bit, and either DI[10:8] or DI[2:0] is used for the lower three
//  bits of the ROM1 address. DI[11] is used to select which set of the lower
//  three addresses are used. In the event that DI[11] is a logic 0, DI[2:0] is
//  decoded by ROM1, but the decode is incomplete. Thus, if DI[11] == 0, then
//  ROM1's output is valid only if DI[10:3] == 0 as well. This comparison and 
//  DI[10:3] <> 0 is used to select the value registered by dDI[8:0].
//
//  ROM2 is also used to decode the same range of instructions as ROM1. Its 
//  12-bit output is multiplexed with the 12-bit output of ROM3. ROM2 is a 16
//  location ROM with a 12-bit output used to drive ALU_Op[11:0], and it shares
//  its address generator with ROM1. Instead of using a single 22-bit wide ROM,
//  two ROMs were used with a common address generator in order to avoid the
//  assignment of the two fields to two different multiplexers for dIR and 
//  ALU_Op. ROM2 provides the registered ALU operation for the instruction for
//  instructions that deal primarily with special processor functions and
//  registers, 0x000-0x007, and for instructions that deal with literal opera-
//  tions, 0x800-0xFFF. As such, ROM2's ALU_Op outputs are fairly sparse.
//
//  ROM3 is used to decode a significantly larger number of IR bits. It decodes
//  DI[10:5] so it covers the remaining instructions not decoded by ROM2/ROM1.
//  ROM3's output drives the ALU_Op multiplexer like ROM2. The instructions
//  decoded by ROM3 support indirect access of the register file through the
//  Indirect File, INDF, access register. The address of INDF is 0, and if
//  DI[4:0] refers to INDF, then the address provided to the register file 
//  address bus should come from the FSR, File Select Register. To achieve a
//  compact decode of the instructions in this region, a 64 x 12 ROM is used,
//  but the indirect addressing function requires a combinatorial signal to 
//  be generated between the ROM and the ALU_Op multiplexer.
//
//  Where possible, a full decode of the instruction set is performed. Err is
//  is generated to properly indicate that the IR contains a reserved op code.
//  If dErr is asserted, a NOP operation is loaded into the ALU_Op, dIR, and
//  the Err output is asserted.
//
// Dependencies:    None 
//
// Revision: 
//
//  0.00    09H18   MAM     File Created
//
//  1.00    13F23   MAM     Changed input data port from IR to DI. When com-
//                          bined with the resulting changes to the upper level
//                          module, the result is to advance the decoding of the
//                          instruction being read from a synchronous ROM to the
//                          point in time when the data out of the ROM is valid
//                          as indicated by CE, i.e. Clock Enable.
//
//  1.10    13F23   MAM     Determined that WE_F bit, ALU_Op[11], was being set
//                          during BTFSC and BTFSS instructions. Changed ROM3 to
//                          clear ROM3[11] (loaded into ALU_Op[11]) when these
//                          instructions are found.
//
//  1.20    13F23   MAM     Added an additional bit to ROM1. New bit defines 
//                          when literal operations are being performed. This is
//                          to be used to create the WE and RE signals for the
//                          various I/O ports supported by the core. Realigned
//                          ROM2 and ROM3 such the ROM2/ROM3 bit 9 and bit 10
//                          are swapped. These two bits are not used within the
//                          ALU, but are used in the P16C5x module. Change is
//                          cosmetic.
//
//  1.30    13J20   MAM     Added direct decode of instruction into a bit maks.
//                          Bit mask is registered along with other instruction
//                          decode components.
//
// Additional Comments:
//
//  This instruction decoder is based on the combinatorial instruction decoder
//  developed for the original implementation of this processor. That decoder
//  is included as comments in this module as a reference for the correct
//  implementation of this module using ROMs and multiplexers.
//
//  ALU_Op[11:0] Mapping
//
//  ALU_Op[1:0] = ALU Unit Operation Code
//
//      Arithmetic Unit (AU): 00 => Y = A +  B; 
//                            01 => Y = A +  B + 1;
//                            10 => Y = A + ~B     = A - B - 1;
//                            11 => Y = A + ~B + 1 = A - B;
//
//      Logic Unit (LU):      00 => V = ~A; 
//                            01 => V =  A | B;
//                            10 => V =  A & B;
//                            11 => V =  A ^ B;
//
//      Shift Unit (SU):      00 => S = W;                // MOVWF
//                            01 => S = {A[3:0], A[7:4]}; // SWAPF
//                            10 => S = {C, A[7:1]};      // RRF
//                            11 => S = {A[6:0], C};      // RLF
//
//  ALU_Op[3:2] = ALU Operand: 
//                  A      B
//          00 =>  File    0 
//          01 =>  File    W
//          10 => Literal  0
//          11 => Literal  W;
//
//  ALU Operations - Bit Processor (BP)
//
//  ALU_Op[2:0] = Bit Select: 000 => Bit 0; 
//                            001 => Bit 1;
//                            010 => Bit 2;
//                            011 => Bit 3;
//                            100 => Bit 4; 
//                            101 => Bit 5;
//                            110 => Bit 6;
//                            111 => Bit 7;
//
//  ALU_Op[3] = Set: 0 - Clr Selected Bit;
//                   1 - Set Selected Bit;
//
//  ALU_Op[5:4] = Status Flag Update Select
//          
//          00 => None
//          01 => C
//          10 => Z
//          11 => Z,DC,C
//
//  ALU_Op[7:6] = ALU Output Data Multiplexer
//
//          00 => AU
//          01 => LU
//          10 => SU
//          11 => BP
//
//  ALU_Op[8]  = Tst: 0 - Normal Operation
//                    1 - Test: INCFSZ/DECFSZ/BTFSC/BTFSS
//
//  ALU_Op[9]  = Write Enable Working Register (W)
//
//  ALU_Op[10] = Indirect Register, INDF, Selected
//
//  ALU_Op[11] = Write Enable File {RAM | Special Function Registers}
//
///////////////////////////////////////////////////////////////////////////////

module P16C5x_IDec(
    input   Rst,
    input   Clk,
    input   CE,
    
    input   [11:0] DI,
    input   Skip,

    output  reg [ 9:0] dIR,
    output  reg [11:0] ALU_Op,
    output  reg [ 8:0] KI,
    output  reg [ 7:0] Msk,

    output  reg Err
);

//
///////////////////////////////////////////////////////////////////////////////
//
//  Unused Opcodes - PIC16C5x Family
//
//localparam pOP_RSVD01 = 12'b0000_0000_0001;   // Reserved - Unused Opcode
//
//localparam pOP_RSVD08 = 12'b0000_0000_1000;   // Reserved - Unused Opcode
//localparam pOP_RSVD09 = 12'b0000_0000_1001;   // Reserved - Unused Opcode
//localparam pOP_RSVD10 = 12'b0000_0000_1010;   // Reserved - Unused Opcode
//localparam pOP_RSVD11 = 12'b0000_0000_1011;   // Reserved - Unused Opcode
//localparam pOP_RSVD12 = 12'b0000_0000_1100;   // Reserved - Unused Opcode
//localparam pOP_RSVD13 = 12'b0000_0000_1101;   // Reserved - Unused Opcode
//localparam pOP_RSVD14 = 12'b0000_0000_1110;   // Reserved - Unused Opcode
//localparam pOP_RSVD15 = 12'b0000_0000_1111;   // Reserved - Unused Opcode
//
//localparam pOP_RSVD16 = 12'b0000_0001_0000;   // Reserved - Unused Opcode
//localparam pOP_RSVD17 = 12'b0000_0001_0001;   // Reserved - Unused Opcode
//localparam pOP_RSVD18 = 12'b0000_0001_0010;   // Reserved - Unused Opcode
//localparam pOP_RSVD19 = 12'b0000_0001_0011;   // Reserved - Unused Opcode
//localparam pOP_RSVD20 = 12'b0000_0001_0100;   // Reserved - Unused Opcode
//localparam pOP_RSVD21 = 12'b0000_0001_0101;   // Reserved - Unused Opcode
//localparam pOP_RSVD22 = 12'b0000_0001_0110;   // Reserved - Unused Opcode
//localparam pOP_RSVD23 = 12'b0000_0001_0111;   // Reserved - Unused Opcode
//localparam pOP_RSVD24 = 12'b0000_0001_1000;   // Reserved - Unused Opcode
//localparam pOP_RSVD25 = 12'b0000_0001_1001;   // Reserved - Unused Opcode
//localparam pOP_RSVD26 = 12'b0000_0001_1010;   // Reserved - Unused Opcode
//localparam pOP_RSVD27 = 12'b0000_0001_1011;   // Reserved - Unused Opcode
//localparam pOP_RSVD28 = 12'b0000_0001_1100;   // Reserved - Unused Opcode
//localparam pOP_RSVD29 = 12'b0000_0001_1101;   // Reserved - Unused Opcode
//localparam pOP_RSVD30 = 12'b0000_0001_1110;   // Reserved - Unused Opcode
//localparam pOP_RSVD31 = 12'b0000_0001_1111;   // Reserved - Unused Opcode
//
//localparam pOP_RSVD65 = 12'b0000_0100_0001;   // Reserved - Unused Opcode
//localparam pOP_RSVD66 = 12'b0000_0100_0010;   // Reserved - Unused Opcode
//localparam pOP_RSVD67 = 12'b0000_0100_0011;   // Reserved - Unused Opcode
//localparam pOP_RSVD68 = 12'b0000_0100_0100;   // Reserved - Unused Opcode
//localparam pOP_RSVD69 = 12'b0000_0100_0101;   // Reserved - Unused Opcode
//localparam pOP_RSVD70 = 12'b0000_0100_0110;   // Reserved - Unused Opcode
//localparam pOP_RSVD71 = 12'b0000_0100_0111;   // Reserved - Unused Opcode
//localparam pOP_RSVD72 = 12'b0000_0100_1000;   // Reserved - Unused Opcode
//localparam pOP_RSVD73 = 12'b0000_0100_1001;   // Reserved - Unused Opcode
//localparam pOP_RSVD74 = 12'b0000_0100_1010;   // Reserved - Unused Opcode
//localparam pOP_RSVD75 = 12'b0000_0100_1011;   // Reserved - Unused Opcode
//localparam pOP_RSVD76 = 12'b0000_0100_1100;   // Reserved - Unused Opcode
//localparam pOP_RSVD77 = 12'b0000_0100_1101;   // Reserved - Unused Opcode
//localparam pOP_RSVD78 = 12'b0000_0100_1110;   // Reserved - Unused Opcode
//localparam pOP_RSVD79 = 12'b0000_0100_1111;   // Reserved - Unused Opcode
//
//localparam pOP_RSVD80 = 12'b0000_0101_0000;   // Reserved - Unused Opcode
//localparam pOP_RSVD81 = 12'b0000_0101_0001;   // Reserved - Unused Opcode
//localparam pOP_RSVD82 = 12'b0000_0101_0010;   // Reserved - Unused Opcode
//localparam pOP_RSVD83 = 12'b0000_0101_0011;   // Reserved - Unused Opcode
//localparam pOP_RSVD84 = 12'b0000_0101_0100;   // Reserved - Unused Opcode
//localparam pOP_RSVD85 = 12'b0000_0101_0101;   // Reserved - Unused Opcode
//localparam pOP_RSVD86 = 12'b0000_0101_0110;   // Reserved - Unused Opcode
//localparam pOP_RSVD87 = 12'b0000_0101_0111;   // Reserved - Unused Opcode
//localparam pOP_RSVD88 = 12'b0000_0101_1000;   // Reserved - Unused Opcode
//localparam pOP_RSVD89 = 12'b0000_0101_1001;   // Reserved - Unused Opcode
//localparam pOP_RSVD90 = 12'b0000_0101_1010;   // Reserved - Unused Opcode
//localparam pOP_RSVD91 = 12'b0000_0101_1011;   // Reserved - Unused Opcode
//localparam pOP_RSVD92 = 12'b0000_0101_1100;   // Reserved - Unused Opcode
//localparam pOP_RSVD93 = 12'b0000_0101_1101;   // Reserved - Unused Opcode
//localparam pOP_RSVD94 = 12'b0000_0101_1110;   // Reserved - Unused Opcode
//localparam pOP_RSVD95 = 12'b0000_0101_1111;   // Reserved - Unused Opcode
//
///////////////////////////////////////////////////////////////////////////////
//
//  PIC16C5x Family Opcodes
//
//localparam pOP_NOP    = 12'b0000_0000_0000;   // No Operation 
//localparam pOP_OPTION = 12'b0000_0000_0010;   // Set Option Register
//localparam pOP_SLEEP  = 12'b0000_0000_0011;   // Set Sleep Register
//localparam pOP_CLRWDT = 12'b0000_0000_0100;   // Clear Watchdog Timer
//localparam pOP_TRISA  = 12'b0000_0000_0101;   // Set Port A Tristate Ctrl Reg
//localparam pOP_TRISB  = 12'b0000_0000_0110;   // Set Port B Tristate Ctrl Reg
//localparam pOP_TRISC  = 12'b0000_0000_0111;   // Set Port C Tristate Ctrl Reg
//localparam pOP_MOVWF  =  7'b0000_001;         // F = W;
//localparam pOP_CLRW   = 12'b0000_0100_0000;   // W = 0; Z;
//localparam pOP_CLRF   =  7'b0000_011; // F = 0; Z;
//localparam pOP_SUBWF  =  6'b0000_10;  // D ? F = F - W : W = F - W; Z, C, DC;
//localparam pOP_DECF   =  6'b0000_11;  // D ? F = F - 1 : W = F - 1; Z;
////
//localparam pOP_IORWF  =  6'b0001_00;  // D ? F = F | W : W = F | W; Z; 
//localparam pOP_ANDWF  =  6'b0001_01;  // D ? F = F & W : W = F & W; Z;
//localparam pOP_XORWF  =  6'b0001_10;  // D ? F = F ^ W : W = F ^ W; Z;
//localparam pOP_ADDWF  =  6'b0001_11;  // D ? F = F + W : W = F + W; Z, C, DC;
////
//localparam pOP_MOVF   =  6'b0010_00;  // D ? F = F     : W = F    ; Z;
//localparam pOP_COMF   =  6'b0010_01;  // D ? F = ~F    : W = ~F   ; Z;
//localparam pOP_INCF   =  6'b0010_10;  // D ? F = F + 1 : W = F + 1; Z;
//localparam pOP_DECFSZ =  6'b0010_11;  // D ? F = F - 1 : W = F - 1; skip if Z
////
//localparam pOP_RRF    =  6'b0011_00;  // D ? F = {C, F[7:1]}
////                                         : W = {C, F[7:1]}; C = F[0]; 
//localparam pOP_RLF    =  6'b0011_01;  // D ? F = {F[6:0], C}
////                                         : W = {F[6:0], C}; C = F[7];
//localparam pOP_SWAPF  =  6'b0011_10;  // D ? F = t
////                                         : W = t; t = {F[3:0], F[7:4]}; 
//localparam pOP_INCFSZ =  6'b0011_11;  // D ? F = F - 1 : W = F - 1; skip if Z
////
//localparam pOP_BCF    =  4'b0100;     // F = F & ~(1 << bit);
//localparam pOP_BSF    =  4'b0101;     // F = F |  (1 << bit);
//localparam pOP_BTFSC  =  4'b0110;     // skip if F[bit] == 0;
//localparam pOP_BTFSS  =  4'b0111;     // skip if F[bit] == 1;
////
//localparam pOP_RETLW  =  4'b1000;     // W = L; Pop(PC = TOS, TOS = NOS);
//localparam pOP_CALL   =  4'b1001;     // Push(TOS = PC + 1);
////                                       PC = {PA[2:0], 0, L[7:0]};
//localparam pOP_GOTO   =  3'b101;      // PC = {PA[2:0], L[8:0]};
//localparam pOP_MOVLW  =  4'b1100;     // W = L[7:0];
//localparam pOP_IORLW  =  4'b1101;     // W = L[7:0] | W; Z;
//localparam pOP_ANDLW  =  4'b1110;     // W = L[7:0] & W; Z;
//localparam pOP_XORLW  =  4'b1111;     // W = L[7:0] ^ W; Z;
//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
//  Variable Declarations
//

reg     [ 9:0] ROM1;            // Decode ROM1: 16x10
wire    [ 3:0] ROM1_Addr;       // ROM1 Address
reg     [11:0] ROM2;            // Decode ROM2: 16x12
wire    [ 3:0] ROM2_Addr;       // ROM2 Address (equals ROM1_Addr)
reg     [11:0] ROM3;            // Decode ROM3: 64x12
wire    [ 5:0] ROM3_Addr;       // ROM3 Address

wire    ROM1_Valid;             // ROM1 Output Valid: 1 - if ROM1 decode valid

wire    dErr;                   // Invalid/Reserved Instruction Decode Signal
wire    [11:0] dALU_Op;         // Combined ROM2, ROM3 ALU Pipeline Vector

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
//  Instruction Decoder Implementation
//
//  ROM1 => dIR, decoded Instruction Register, is used to flag instructions
//          that require special processing in the execution stage.

assign ROM1_Addr = {DI[11], (DI[11] ? DI[10:8] : DI[2:0])};

always @(*)
begin
    case(ROM1_Addr)
        4'b0000 : ROM1 <= 10'b0_0_0000_0000;   // NOP
        4'b0001 : ROM1 <= 10'b0_0_0000_0000;   // Reserved
        4'b0010 : ROM1 <= 10'b0_1_0000_0000;   // OPTION
        4'b0011 : ROM1 <= 10'b0_0_0000_1000;   // SLEEP
        4'b0100 : ROM1 <= 10'b0_0_0001_0000;   // CLRWDT
        4'b0101 : ROM1 <= 10'b0_0_0010_0000;   // TRISA
        4'b0110 : ROM1 <= 10'b0_0_0100_0000;   // TRISB
        4'b0111 : ROM1 <= 10'b0_0_1000_0000;   // TRISC
        4'b1000 : ROM1 <= 10'b1_0_0000_0100;   // RETLW
        4'b1001 : ROM1 <= 10'b1_0_0000_0010;   // CALL
        4'b1010 : ROM1 <= 10'b1_0_0000_0001;   // GOTO
        4'b1011 : ROM1 <= 10'b1_0_0000_0001;   // GOTO
        4'b1100 : ROM1 <= 10'b1_0_0000_0000;   // MOVLW
        4'b1101 : ROM1 <= 10'b1_0_0000_0000;   // IORLW
        4'b1110 : ROM1 <= 10'b1_0_0000_0000;   // ANDLW
        4'b1111 : ROM1 <= 10'b1_0_0000_0000;   // XORLW
    endcase
end

assign ROM1_Valid = (DI[11] ? DI[11] : ~|DI[10:3]);

//  ROM2 => Input to ALU_Op for instructions decoded using ROM1_Addr

assign ROM2_Addr = {DI[11], (DI[11] ? DI[10:8] : DI[2:0])};

always @(*)
begin
    case(ROM2_Addr)
        4'b0000 : ROM2 <= 12'b0000_00_00_00_00;   // NOP
        4'b0001 : ROM2 <= 12'b0000_00_00_00_00;   // Reserved
        4'b0010 : ROM2 <= 12'b0000_00_00_00_00;   // OPTION
        4'b0011 : ROM2 <= 12'b0000_00_00_00_00;   // SLEEP
        4'b0100 : ROM2 <= 12'b0000_00_00_00_00;   // CLRWDT
        4'b0101 : ROM2 <= 12'b0000_00_00_00_00;   // TRISA
        4'b0110 : ROM2 <= 12'b0000_00_00_00_00;   // TRISB
        4'b0111 : ROM2 <= 12'b0000_00_00_00_00;   // TRISC
        4'b1000 : ROM2 <= 12'b0010_00_00_10_00;   // RETLW
        4'b1001 : ROM2 <= 12'b0000_00_00_10_00;   // CALL
        4'b1010 : ROM2 <= 12'b0000_00_00_00_00;   // GOTO
        4'b1011 : ROM2 <= 12'b0000_00_00_00_00;   // GOTO
        4'b1100 : ROM2 <= 12'b0010_00_00_10_00;   // MOVLW
        4'b1101 : ROM2 <= 12'b0010_01_10_11_01;   // IORLW
        4'b1110 : ROM2 <= 12'b0010_01_10_11_10;   // ANDLW
        4'b1111 : ROM2 <= 12'b0010_01_10_11_11;   // XORLW
    endcase
end

//  ROM3 - decode for remaining instructions

assign ROM3_Addr = DI[10:5];

always @(*)
begin
    case(ROM3_Addr)
        6'b000000 : ROM3 <= 12'b0000_00_00_00_00;   // Reserved
                                   
        6'b000001 : ROM3 <= 12'b1100_10_00_01_00;   // MOVWF
        6'b000010 : ROM3 <= 12'b0010_10_00_00_00;   // CLRW
        6'b000011 : ROM3 <= 12'b1100_10_00_00_00;   // CLRF
                                   
        6'b000100 : ROM3 <= 12'b0110_00_11_01_11;   // SUBWF  F,0
        6'b000101 : ROM3 <= 12'b1100_00_11_01_11;   // SUBWF  F,1
        6'b000110 : ROM3 <= 12'b0110_00_10_00_10;   // DECF   F,0
        6'b000111 : ROM3 <= 12'b1100_00_10_00_10;   // DECF   F,1
                                   
        6'b001000 : ROM3 <= 12'b0110_01_10_01_01;   // IORWF  F,0
        6'b001001 : ROM3 <= 12'b1100_01_10_01_01;   // IORWF  F,1
        6'b001010 : ROM3 <= 12'b0110_01_10_01_10;   // ANDWF  F,0
        6'b001011 : ROM3 <= 12'b1100_01_10_01_10;   // ANDWF  F,1
        6'b001100 : ROM3 <= 12'b0110_01_10_01_11;   // XORWF  F,0
        6'b001101 : ROM3 <= 12'b1100_01_10_01_11;   // XORWF  F,1
        6'b001110 : ROM3 <= 12'b0110_00_11_01_00;   // ADDWF  F,0
        6'b001111 : ROM3 <= 12'b1100_00_11_01_00;   // ADDWF  F,1
                                   
        6'b010000 : ROM3 <= 12'b0110_00_10_00_00;   // MOVF   F,0
        6'b010001 : ROM3 <= 12'b1100_00_10_00_00;   // MOVF   F,1
        6'b010010 : ROM3 <= 12'b0110_01_00_00_00;   // COMF   F,0
        6'b010011 : ROM3 <= 12'b1100_01_00_00_00;   // COMF   F,1
        6'b010100 : ROM3 <= 12'b0110_00_10_00_01;   // INCF   F,0
        6'b010101 : ROM3 <= 12'b1100_00_10_00_01;   // INCF   F,1
        6'b010110 : ROM3 <= 12'b0111_00_00_00_10;   // DECFSZ F,0
        6'b010111 : ROM3 <= 12'b1101_00_00_00_10;   // DECFSZ F,1
                                   
        6'b011000 : ROM3 <= 12'b0110_10_01_00_10;   // RRF    F,0
        6'b011001 : ROM3 <= 12'b1100_10_01_00_10;   // RRF    F,1
        6'b011010 : ROM3 <= 12'b0110_10_01_00_11;   // RLF    F,0
        6'b011011 : ROM3 <= 12'b1001_10_01_00_11;   // RLF    F,1
        6'b011100 : ROM3 <= 12'b0110_10_00_00_01;   // SWAPF  F,0
        6'b011101 : ROM3 <= 12'b1100_10_00_00_01;   // SWAPF  F,1
        6'b011110 : ROM3 <= 12'b0111_00_00_00_01;   // INCFSZ F,0
        6'b011111 : ROM3 <= 12'b1101_00_00_00_01;   // INCFSZ F,1
                                   
        6'b100000 : ROM3 <= 12'b1100_11_00_0_000;   // BCF    F,0
        6'b100001 : ROM3 <= 12'b1100_11_00_0_001;   // BCF    F,1
        6'b100010 : ROM3 <= 12'b1100_11_00_0_010;   // BCF    F,2
        6'b100011 : ROM3 <= 12'b1100_11_00_0_011;   // BCF    F,3
        6'b100100 : ROM3 <= 12'b1100_11_00_0_100;   // BCF    F,4
        6'b100101 : ROM3 <= 12'b1100_11_00_0_101;   // BCF    F,5
        6'b100110 : ROM3 <= 12'b1100_11_00_0_110;   // BCF    F,6
        6'b100111 : ROM3 <= 12'b1100_11_00_0_111;   // BCF    F,7
                                   
        6'b101000 : ROM3 <= 12'b1100_11_00_1_000;   // BSF    F,0
        6'b101001 : ROM3 <= 12'b1100_11_00_1_001;   // BSF    F,1
        6'b101010 : ROM3 <= 12'b1100_11_00_1_010;   // BSF    F,2
        6'b101011 : ROM3 <= 12'b1100_11_00_1_011;   // BSF    F,3
        6'b101100 : ROM3 <= 12'b1100_11_00_1_100;   // BSF    F,4
        6'b101101 : ROM3 <= 12'b1100_11_00_1_101;   // BSF    F,5
        6'b101110 : ROM3 <= 12'b1100_11_00_1_110;   // BSF    F,6
        6'b101111 : ROM3 <= 12'b1100_11_00_1_111;   // BSF    F,7
                                   
        6'b110000 : ROM3 <= 12'b0101_11_00_0_000;   // BTFSC  F,0
        6'b110001 : ROM3 <= 12'b0101_11_00_0_001;   // BTFSC  F,1
        6'b110010 : ROM3 <= 12'b0101_11_00_0_010;   // BTFSC  F,2
        6'b110011 : ROM3 <= 12'b0101_11_00_0_011;   // BTFSC  F,3
        6'b110100 : ROM3 <= 12'b0101_11_00_0_100;   // BTFSC  F,4
        6'b110101 : ROM3 <= 12'b0101_11_00_0_101;   // BTFSC  F,5
        6'b110110 : ROM3 <= 12'b0101_11_00_0_110;   // BTFSC  F,6
        6'b110111 : ROM3 <= 12'b0101_11_00_0_111;   // BTFSC  F,7
                                   
        6'b111000 : ROM3 <= 12'b0101_11_00_1_000;   // BTFSS  F,0
        6'b111001 : ROM3 <= 12'b0101_11_00_1_001;   // BTFSS  F,1
        6'b111010 : ROM3 <= 12'b0101_11_00_1_010;   // BTFSS  F,2
        6'b111011 : ROM3 <= 12'b0101_11_00_1_011;   // BTFSS  F,3
        6'b111100 : ROM3 <= 12'b0101_11_00_1_100;   // BTFSS  F,4
        6'b111101 : ROM3 <= 12'b0101_11_00_1_101;   // BTFSS  F,5
        6'b111110 : ROM3 <= 12'b0101_11_00_1_110;   // BTFSS  F,6
        6'b111111 : ROM3 <= 12'b0101_11_00_1_111;   // BTFSS  F,7
    endcase
end

//  Invalid/Reserved Instruction Decode

assign dErr =   (~|DI[11:1] & DI[0])                        // (IR == 1)
              | (~|DI[11:4] & DI[3])                        // ( 8 <= IR <= 16)
              | (~|DI[11:5] & DI[4])                        // (16 <= IR <= 31)
              | (~|DI[11:7] & DI[6] & ~|DI[5:4] & |DI[3:0]) // (65 <= IR <= 79)
              | (~|DI[11:7] & DI[6] & ~DI[5] & DI[4]);      // (80 <= IR <= 95)

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
//  Instruction Pipeline Registers
//
//  Decoded Instruction Register

always @(posedge Clk)
begin
    if(Rst)
        dIR <= #1 0;
    else if(CE)
        dIR <= #1 ((Skip) ? 0
                          : ((ROM1_Valid) ? ROM1 : 0));
end

//  ALU Operation Pipeline Register

assign dALU_Op = (ROM1_Valid ? ROM2
                             : {ROM3[11],(ROM3[10] & ~|DI[4:0]), ROM3[9:0]});

always @(posedge Clk)
begin
    if(Rst)
        ALU_Op <= #1 0;
    else if(CE)
        ALU_Op <= #1 ((Skip | dErr) ? 0 : dALU_Op);
end

//  Literal Operand Pipeline Register

always @(posedge Clk)
begin
    if(Rst)
        KI <= #1 0;
    else if(CE)
        KI <= #1 ((Skip) ? KI : DI[8:0]);
end

//  Bit Mask

always @(posedge Clk)
begin
    if(Rst)
        Msk <= #1 8'hFF;
    else
        case(DI[7:5])
            3'b000 : Msk <= #1 8'b00000001;
            3'b001 : Msk <= #1 8'b00000010;
            3'b010 : Msk <= #1 8'b00000100;
            3'b011 : Msk <= #1 8'b00001000;
            3'b100 : Msk <= #1 8'b00010000;
            3'b101 : Msk <= #1 8'b00100000;
            3'b110 : Msk <= #1 8'b01000000;
            3'b111 : Msk <= #1 8'b10000000;
        endcase
end

//  Unimplemented Instruction Error Register

always @(posedge Clk)
begin
    if(Rst)
        Err <= #1 0;
    else if(CE)
        Err <= #1 dErr;
end

endmodule
