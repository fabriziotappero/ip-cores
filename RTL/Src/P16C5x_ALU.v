////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2013 by Michael A. Morris, dba M. A. Morris & Associates
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

//////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates 
// Engineer:        Michael A. Morris
// 
// Create Date:     14:53:13 06/15/2013 
// Design Name:     P16C5x-compatible Synthesizable Processor Core
// Module Name:     P16C5x_ALU 
// Project Name:    C:\XProjects\ISE10.1i\M16C5x 
// Target Devices:  RAM-based FPGAs: XC3S50A-xVQ100, XC3S200A-xVQ100 
// Tool versions:   Xilinx ISE 10.1i SP3
//
// Description:
//
//  Module implements the ALU of the P16C5x synthesizable processor core. It has
//  been taken out of the PIC16C5x synthesizable processor core and made into a 
//  separate module. No changes have been made to the ALU code in the process.
//
// Dependencies: 
//
// Revision:
// 
//  1.00    13F15   MAM     Original file creation date.
//
//  1.10    13F23   MAM     Changed order of ALU_Op[10] and ALU_Op[9]. Now the
//                          modules uses ALU_Op[9:0] internally instead of 
//                          {ALU_Op[10], ALU_Op[8:0]} as originally constructed.
//
//  1.20    13J19   MAM     Changed Write Enable/Clock Enable logic to remove
//                          multiplexers and make better use of the built-in
//                          functionality of the logic blocks in the FPGA.
//
//  1.30    13J20   MAM     Removed the internal bit mask ROM, and added an bit
//                          mask input port. Reconfigured Bit Unit to use the
//                          bit mask input port.
// 
// Additional Comments:
//
//  The ALU data output, DO, has been registered to support a higher operating
//  speed when a multi-cycle instruction cycle is used. Parameterization of this
//  may be added in the future, but the current module must be edited to remove
//  the DO register and the un-registered multiplexer, which has been commented
//  out, added back in when single cycle operation is desired.
//
////////////////////////////////////////////////////////////////////////////////

module P16C5x_ALU (
    input   Rst,
    input   Clk,
    input   CE,
    
    input   [9:0] ALU_Op,               // ALU Control Word
    input   WE_PSW,                     // Write Enable for {Z, DC, C} from DI

    input   [7:0] DI,                   // Data Input
    input   [7:0] KI,                   // Literal Input
    input   [7:0] Msk,                  // Bit Mask Input
    
    output  reg [7:0] DO,               // ALU Output
    output  Z_Tst,                      // ALU Zero Test Output
    output  g,                          // Bit Test Condition
    
    output  reg [7:0] W,                // Working Register 
    
    output  reg Z,                      // Z(ero) ALU Status Output
    output  reg DC,                     // Digit Carry ALU Status Output
    output  reg C                       // Carry Flag ALU Status Output
);

////////////////////////////////////////////////////////////////////////////////
//
//  Declarations
//

wire    [7:0] A, B, Y;

wire    [7:0] X;
wire    C3, C7;

wire    [1:0] LU_Op;
reg     [7:0] V;

wire    [1:0] S_Sel;
reg     [7:0] S;

wire    [7:0] U;
wire    [7:0] T;

wire    [1:0] D_Sel;

////////////////////////////////////////////////////////////////////////////////
//
//  ALU Implementation - ALU[3:0] are overloaded for the four ALU elements:
//                          Arithmetic Unit, Logic Unit, Shift Unit, and Bit
//                          Processor.
//
//  ALU Operations - Arithmetic, Logic, and Shift Units
//
//  ALU_Op[1:0] = ALU Unit Operation Code
//
//      Arithmetic Unit (AU): 00 => Y = A +  B;
//                            01 => Y = A +  B + 1;
//                            10 => Y = A + ~B     = A - B - 1;
//                            11 => Y = A + ~B + 1 = A - B;
//
//      Logic Unit (LU):      00 => V = ~A;
//                            01 => V =  A & B;
//                            10 => V =  A | B;
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

assign C_In  = ALU_Op[0];  // Adder Carry input
assign B_Inv = ALU_Op[1];  // B Bus input invert
assign B_Sel = ALU_Op[2];  // B Bus select
assign A_Sel = ALU_Op[3];  // A Bus select

//  AU Input Bus Multiplexers

assign A = ((A_Sel) ? KI : DI);
assign B = ((B_Sel) ?  W : 0 );
assign Y = ((B_Inv) ? ~B : B );

//  AU Adder

assign {C3, X[3:0]} = A[3:0] + Y[3:0] + C_In;
assign {C7, X[7:4]} = A[7:4] + Y[7:4] + C3;

//  Logic Unit (LU)

assign LU_Op = ALU_Op[1:0];

always @(*)
begin
    case (LU_Op)
        2'b00 : V <= ~A;
        2'b01 : V <=  A | B;
        2'b10 : V <=  A & B;
        2'b11 : V <=  A ^ B;
    endcase
end

//  Shifter and W Multiplexer

assign S_Sel = ALU_Op[1:0];

always @(*)
begin
    case (S_Sel)
        2'b00 : S <= B;                  // Pass Working Register (MOVWF)
        2'b01 : S <= {A[3:0], A[7:4]};   // Swap Nibbles (SWAPF)
        2'b10 : S <= {C, A[7:1]};        // Shift Right (RRF)
        2'b11 : S <= {A[6:0], C};        // Shift Left (RLF)
    endcase
end

//  Bit Processor

assign Set = ALU_Op[3];
assign Tst = ALU_Op[8];

assign U = ((Set) ? (DI | Msk) : (DI & ~Msk));

assign T = (DI & Msk);
assign g = ((Tst) ? ((Set) ? |T : ~|T) 
                  : 1'b0              );

//  Output Data Mux

assign D_Sel = ALU_Op[7:6];

always @(*)
begin
    case (D_Sel)
        2'b00 : DO <= X;     // Arithmetic Unit Output
        2'b01 : DO <= V;     // Logic Unit Output
        2'b10 : DO <= S;     // Shifter Output
        2'b11 : DO <= U;     // Bit Processor Output
    endcase
end

//  Working Register

assign WE_W = CE & ALU_Op[9];

always @(posedge Clk)
begin
    if(Rst)
        W <= #1 8'b0;
    else if(WE_W)
        W <= #1 DO;
end

//  Z Register

assign Z_Sel = ALU_Op[5];
assign Z_Tst = ~|DO;

assign CE_Z  = CE & (WE_PSW | Z_Sel);

always @(posedge Clk)
begin
    if(Rst)
        Z <= #1 1'b0;
    else if(CE_Z)
        Z <= #1 ((WE_PSW) ? DO[2] : Z_Tst); 
end

//  Digit Carry (DC) Register

assign DC_Sel = ALU_Op[5] & ALU_Op[4];
assign CE_DC  = CE & (WE_PSW | DC_Sel);

always @(posedge Clk)
begin
    if(Rst)
        DC <= #1 1'b0;
    else if(CE_DC)
        DC <= #1 ((WE_PSW) ? DO[1] : C3);
end

//  Carry (C) Register

assign C_Sel = ALU_Op[4];
assign S_Dir = ALU_Op[1] & ALU_Op[0];
assign C_Drv = ((~ALU_Op[7] & ~ALU_Op[6]) ? C7 : ((S_Dir) ? A[7] : A[0]));

assign CE_C  = CE & (WE_PSW | C_Sel);

always @(posedge Clk)
begin
    if(Rst)
        C <= #1 1'b0;
    else if(CE_C)
        C <= #1 ((WE_PSW) ? DO[0] : C_Drv);
end

endmodule
