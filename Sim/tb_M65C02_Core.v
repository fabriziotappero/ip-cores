///////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 by Michael A. Morris, dba M. A. Morris & Associates
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
// Create Date:     21:38:27 02/04/2012
// Design Name:     M65C02_Core - WDC W65C02 Microprocessor Re-Implementation
// Module Name:     tb_MAM65C02_Core.v
// Project Name:    C:/XProjects/ISE10.1i/MAM6502
// Target Device:   XC3S200AN-4FT256I 
// Tool versions:   Xilinx ISE 10.1i SP3
//  
// Description: 
//
// Verilog Test Fixture created by ISE for module: M65C02_Core
//
// Dependencies:
// 
// Revision:
// 
//  0.01    12B04   MAM     Initial coding. 
//
// Additional Comments:
// 
///////////////////////////////////////////////////////////////////////////////

module tb_M65C02_Core;

//    parameter pRst_Vector = 16'hF800;
//    parameter pIRQ_Vector = 16'hF808;
//    parameter pBrk_Vector = 16'hF808;
    parameter pRst_Vector = 16'hFFFC;
    parameter pIRQ_Vector = 16'hFFFE;
    parameter pBrk_Vector = 16'hFFFE;
    
    parameter pInt_Hndlr  = 9'h021;
    
    parameter pIRQ_On     = 16'hFFF8;
    parameter pIRQ_Off    = 16'hFFF9;
    
    parameter pIO_WR      = 2'b01;
    
    parameter pRAM_AddrWidth = 11;

    // System

    reg  Rst;                   // System Reset
    reg  Clk;                   // System Clock

    //  Processor

    wire IRQ_Msk;               // Interrupt Mask Bit from P
    reg  Int;                   // Interrupt Request
    reg  xIRQ;                  // Maskable Interrupt Request
    reg  [15:0] Vector;         // Interrupt Vector

    wire Done;                  // Instruction Complete
    wire SC;                    // Single Cycle Instruction
    wire [2:0] Mode;            // Instruction Type/Mode
    wire RMW;                   // Read-Modify-Write Operation
    wire IntSvc;                // Interrupt Service Start
    wire ISR;                   // Interrupt Vector Pull Start
    
    wire [1:0] MC;              // Microcycle State
    wire [1:0] MemTyp;          // Memory Access Type
    reg  Wait;                  // Microcycle Wait State Request
    wire Rdy;                   // Internal Ready

    wire [1:0] IO_Op;           // Bus Operation: 1 - WR; 2 - RD; 3 - IF

    wire [15:0] AO;             // Address Output Bus
    wire [ 7:0] DI;             // Data Input Bus
    wire [ 7:0] DO;             // Data Output Bus

	wire [ 7:0] A;              // Internal Register - Accumulator
	wire [ 7:0] X;              // Internal Register - Pre-Index Register X
	wire [ 7:0] Y;              // Internal Register - Post-Index Register Y
	wire [ 7:0] S;              // Internal Register - Stack Pointer
	wire [ 7:0] P;              // Internal Register - Program Status Word
	wire [15:0] PC;             // Internal Register - Program Counter
        
	wire [7:0] IR;              // Internal Register - Instruction Register
	wire [7:0] OP1;             // Internal Register - Operand Register 1
	wire [7:0] OP2;             // Internal Register - Operand Register 2
    
    // Simulation Variables
    
    wire    Phi1O, Phi2O;           // M65C02 Clock Outputs
    reg     [1:0] VP, Ref_VP;       // Vector Pull FFs
    wire    nVP;
    
    reg     nWr;
    
    reg     Sim_Int    = 0;

    integer cycle_cnt  = 0;
    integer instr_cnt  = 0;
    
    integer Loop_Start = 0;         // Flags the first loop
    
    integer Hist_File  = 0;         // File handle for instruction histogram
    integer SV_Output  = 0;         // File handle for State Vector Outputs
    
    reg     [15:0] Hist [255:0];    // Instruction Histogram array
    reg     [15:0] val;             // Instruction Histogram variable
    reg     [ 7:0] i, j;            // loop counters
    
    reg     [((5*8) - 1):0] Op;     // Processor Mode Mnemonics String
    reg     [((6*8) - 1):0] Opcode; // Opcode Mnemonics String
    reg     [((9*8) - 1):0] AddrMd; // Addressing Mode Mnemonics String

// Instantiate the Unit Under Test (UUT)

M65C02_Core #(
                .pInt_Hndlr(pInt_Hndlr),
                .pM65C02_uPgm("M65C02_uPgm_V3a.coe"),
                .pM65C02_IDec("M65C02_Decoder_ROM.coe")
            ) uut (
            .Rst(Rst), 
            .Clk(Clk), 
            
            .IRQ_Msk(IRQ_Msk), 
            .Int(Int),
            .xIRQ(xIRQ),            
            .Vector(Vector), 
            
            .Done(Done),
            .SC(SC),
            .Mode(Mode), 
            .RMW(RMW),
            .IntSvc(IntSvc),
            .ISR(ISR),

            .MC(MC), 
            .MemTyp(MemTyp),
            .uLen(2'b11),     // Len 4 Cycle 
//            .uLen(2'b1),      // Len 2 Cycle 
//            .uLen(2'b0),      // Len 1 Cycle
            .Wait(Wait), 
            .Rdy(Rdy),
            
            .IO_Op(IO_Op), 
            .AO(AO), 
            .DI(DI), 
            .DO(DO), 
            
            .A(A), 
            .X(X), 
            .Y(Y), 
            .S(S), 
            .P(P), 
            .PC(PC), 
            
            .IR(IR), 
            .OP1(OP1), 
            .OP2(OP2)
        );
            
// Instantiate the Reference Unit for Unit Under Test

    //  Processor

    wire Ref_IRQ_Msk;           // Interrupt Mask Bit from P

    wire Ref_Done;              // Instruction Complete
    wire Ref_SC;                // Single Cycle Instruction
    wire [2:0] Ref_Mode;        // Instruction Type/Mode
    wire Ref_RMW;               // Read-Modify-Write Operation
    wire Ref_IntSvc;            // Interrupt Service Start
    wire Ref_ISR;               // Interrupt Pull Start Flag
    
    wire Ref_Rdy;               // Internal Ready

    wire [1:0] Ref_IO_Op;       // Bus Operation: 1 - WR; 2 - RD; 3 - IF
    reg  Ref_Ack;               // External Transfer Acknowledge
    
    wire [15:0] Ref_AO;         // Address Output Bus
    wire [ 7:0] Ref_DO;         // Data Output Bus

	wire [ 7:0] Ref_A;          // Internal Register - Accumulator
	wire [ 7:0] Ref_X;          // Internal Register - Pre-Index Register X
	wire [ 7:0] Ref_Y;          // Internal Register - Post-Index Register Y
	wire [ 7:0] Ref_S;          // Internal Register - Stack Pointer
	wire [ 7:0] Ref_P;          // Internal Register - Program Status Word
	wire [15:0] Ref_PC;         // Internal Register - Program Counter
        
	wire [7:0] Ref_IR;          // Internal Register - Instruction Register
	wire [7:0] Ref_OP1;         // Internal Register - Operand Register 1
	wire [7:0] Ref_OP2;         // Internal Register - Operand Register 2

M65C02_Base #(
                .pInt_Hndlr(pInt_Hndlr),
                .pM65C02_uPgm("M65C02_uPgm_V3.coe"),
                .pM65C02_IDec("M65C02_Decoder_ROM.coe")
            ) ref (
            .Rst(Rst), 
            .Clk(Clk), 
            
            .IRQ_Msk(Ref_IRQ_Msk), 
            .Int(Int), 
            .xIRQ(xIRQ),            
            .Vector(Vector), 
            
            .Done(Ref_Done),
            .SC(Ref_SC),
            .Mode(Ref_Mode), 
            .RMW(Ref_RMW),
            .IntSvc(Ref_IntSvc),
            .ISR(Ref_ISR),

            .Rdy(Ref_Rdy),
            
            .IO_Op(Ref_IO_Op), 
            .Ack_In(Ref_Ack), 
            
            .AO(Ref_AO), 
            .DI(DI), 
            .DO(Ref_DO), 
            
            .A(Ref_A), 
            .X(Ref_X), 
            .Y(Ref_Y), 
            .S(Ref_S), 
            .P(Ref_P), 
            .PC(Ref_PC), 
            
            .IR(Ref_IR), 
            .OP1(Ref_OP1), 
            .OP2(Ref_OP2)
        );
            
//  Instantiate RAM Module

wire    [7:0] ROM_DO;
reg     ROM_WE;

M65C02_RAM  #(
                .pAddrSize(pRAM_AddrWidth),
                .pDataSize(8),
                .pFileName("M65C02_Tst3.txt")
            ) ROM (
                .Clk(Clk),
                .Ext(1'b1),     // 4 cycle memory
                .ZP(1'b0),
//                .Ext(1'b0),     // 2 cycle memory
//                .ZP(1'b0),
//                .Ext(1'b0),     // 1 cycle memory
//                .ZP(1'b1),
                .WE(ROM_WE),
                .AI(AO[(pRAM_AddrWidth - 1):0]),
                .DI(DO),
                .DO(ROM_DO)
            );

//  Instantiate RAM Module

wire    [7:0] RAM_DO;
reg     RAM_WE;

M65C02_RAM  #(
                .pAddrSize(pRAM_AddrWidth),
                .pDataSize(8),
                .pFileName("M65C02_RAM.txt")
            ) RAM (
                .Clk(Clk),
                .Ext(1'b1),     // 4 cycle memory
                .ZP(1'b0),
//                .Ext(1'b0),     // 2 cycle memory
//                .ZP(1'b0),
//                .Ext(1'b0),     // 1 cycle memory
//                .ZP(1'b1),
                .WE(RAM_WE),
                .AI(AO[(pRAM_AddrWidth - 1):0]),
                .DI(DO),
                .DO(RAM_DO)
            );

initial begin
    // Initialize Inputs
    Rst    = 1;
    Clk    = 1;
    Int    = 0;
    Wait   = 0;
    Vector = pRst_Vector;
    
    // Intialize Simulation Time Format
    
    $timeformat (-9, 3, " ns", 12);
    
    //  Initialize Instruction Execution Histogram array
    
    for(cycle_cnt = 0; cycle_cnt < 256; cycle_cnt = cycle_cnt + 1)
        Hist[cycle_cnt] = 0;
    cycle_cnt = 0;
    
    Hist_File = $fopen("M65C02_Hist_File.txt", "w");
    SV_Output = $fopen("M65C02_SV_Output.txt", "w");

    // Wait 100 ns for global reset to finish
    
    #101 Rst = 0;
    
    // Add stimulus here
    
end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Clocks
//

always #5 Clk = ~Clk;

assign Phi1O =  MC[1];
assign Phi2O = ~MC[1];

////////////////////////////////////////////////////////////////////////////////
//
//  Generate Bus Control Signals
//

assign C1 =  (MC == 2);
assign C2 =   MC[1];
assign C3 =  |MC;
assign C4 = ~|MC;

assign WE = ~IO_Op[1] & IO_Op[0] & ~C4;
assign RE =  IO_Op[1];

always @(negedge Clk) nWr <= #1 ((Rst) ? 1 : ~WE);

////////////////////////////////////////////////////////////////////////////////
//
//  Generate Vector Pull signals
//

always @(posedge Clk)
begin
    if(Rst)
        VP <= #1 0;
    else if(Rdy)
        VP <= #1 ((ISR) ? 2'b11 : {VP[0], 1'b0});
end

assign nVP = ~VP[1];

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Generate Write Enables for "ROM" and "RAM" modules and multiplex DO onto DI
//

always @(*) ROM_WE = (IO_Op == 1) & ( &AO[15:pRAM_AddrWidth]);
always @(*) RAM_WE = (IO_Op == 1) & (~|AO[15:pRAM_AddrWidth]);

assign DI = ((&AO[15:pRAM_AddrWidth]) ? ROM_DO : RAM_DO);

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
//  Generate Ack for Reference Core - M65C02_Base
//

always @(*) Ref_Ack = (MC == 0);

///////////////////////////////////////////////////////////////////////////////
//
//  Reset/NMI/Brk/IRQ Vector Generator
//

always @(*)
begin
    Vector = ((Mode == 3'b010) ? pBrk_Vector
                               : ((Int) ? pIRQ_Vector
                                        : pRst_Vector));
end

// Simulate Interrupts

always @(*)
begin
    if((AO == pIRQ_On) && (IO_Op == pIO_WR))
        Sim_Int = 1;
    else if((AO == pIRQ_Off) && (IO_Op == pIO_WR))
        Sim_Int = 0;
end

always @(*)
begin
    Int  = ((IRQ_Msk) ? 0 : (Sim_Int | (Mode == 3'b111)));
    xIRQ = (Mode == 3'b111);
end

//  Count number of cycles and the number of instructions between between
//      0x0210 and the repeat at 0x0210 

always @(posedge Clk)
begin
    if(Rst)
        cycle_cnt = 0;
    else
        cycle_cnt = ((Done & (AO == 16'h0210)) ? 1 : (cycle_cnt + 1));
end

always @(posedge Clk)
begin
    if(Rst)
        instr_cnt = 0;
    else if(Done & Rdy)
        instr_cnt = ((AO == 16'h0210) ? 1 : (instr_cnt + 1));
end

//  Perform Instruction Histogramming for coverage puposes

always @(posedge Clk)
begin
    $fstrobe(SV_Output, "%b, %b, %b, %h, %b, %b, %h, %b, %b, %b, %h, %b, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h",
             IRQ_Msk, Sim_Int, Int, Vector, Done, SC, Mode, RMW, IntSvc, Rdy, IO_Op, Ref_Ack, AO, DI, DO, A, X, Y, S, P, PC, IR, OP1, OP2);

    if(Done & Rdy) begin
        if((AO == 16'hF800)) begin
            if((Loop_Start == 1)) begin
                for(i = 0; i < 16; i = i + 1)
                    for(j = 0; j < 16; j = j + 1) begin
                        val = Hist[(j * 16) + i];
                        Hist[(j * 16) + i] = 0;
                        if((j == 0))
                            $fwrite(Hist_File, "\n%h : %h", ((j * 16) + i), val);
                        else
                            $fwrite(Hist_File, " %h", val);
                    end
                $fclose(Hist_File);
                $fclose(SV_Output);

                $display("\nTest Loop Complete\n");

                $stop;
            end else begin
                Loop_Start = 1;
            end
        end
        val = Hist[IR];
        Hist[IR] = val + 1;
    end
end

//  Test Monitor System Function

always @(*)
begin
    $monitor("%b, %b, %b, %h, %b, %b, %h, %b, %b, %b, %h, %b, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h",
             IRQ_Msk, Sim_Int, Int, Vector, Done, SC, Mode, RMW, IntSvc, Rdy, IO_Op, Ref_Ack, AO, DI, DO, A, X, Y, S, P, PC, IR, OP1, OP2);
end

//  Compare UUT to REF, and pause simulation when differences encountered

always @(posedge Clk)
begin
    #1.1;
    if(Ref_IRQ_Msk != IRQ_Msk) begin
        $display("\tError(%t): IRQ_Msk incorrect - found %b; expected %b\n", $realtime, IRQ_Msk, Ref_IRQ_Msk);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_Done != Done) begin
        $display("\tError(%t): Done incorrect - found %b; expected %b\n", $realtime, Done, Ref_Done);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_SC != SC) begin
        $display("\tError(%t): SC incorrect - found %b; expected %b\n", $realtime, SC, Ref_SC);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_Mode != Mode) begin
        $display("\tError(%t): Mode incorrect - found %h; expected %h\n", $realtime, Mode, Ref_Mode);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_RMW != RMW) begin
        $display("\tError(%t): RMW incorrect - found %b; expected %b\n", $realtime, RMW, Ref_RMW);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_IntSvc != IntSvc) begin
        $display("\tError(%t): IntSvc incorrect - found %b; expected %b\n", $realtime, IntSvc, Ref_IntSvc);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_Rdy != Rdy) begin
        $display("\tError(%t): Rdy incorrect - found %b; expected %b\n", $realtime, Rdy, Ref_Rdy);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_IO_Op != IO_Op) begin
        $display("\tError(%t): IO_Op incorrect - found %d; expected %d\n", $realtime, IO_Op, Ref_IO_Op);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_AO != AO) begin
        $display("\tError(%t): AO incorrect - found %h; expected %h\n", $realtime, AO, Ref_AO);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_DO != DO) begin
        $display("\tError(%t): DO incorrect - found %h; expected %h\n", $realtime, DO, Ref_DO);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_A != A) begin
        $display("\tError(%t): A incorrect - found %h; expected %h\n", $realtime, A, Ref_A);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_X != X) begin
        $display("\tError(%t): X incorrect - found %h; expected %h\n", $realtime, X, Ref_X);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_Y != Y) begin
        $display("\tError(%t): Y incorrect - found %h; expected %h\n", $realtime, Y, Ref_Y);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_S != S) begin
        $display("\tError(%t): S incorrect - found %h; expected %h\n", $realtime, S, Ref_S);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_P != P) begin
        $display("\tError(%t): P incorrect - found %h; expected %h\n", $realtime, P, Ref_P);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_PC != PC) begin
        $display("\tError(%t): PC incorrect - found %h; expected %h\n", $realtime, PC, Ref_PC);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_IR != IR) begin
        $display("\tError(%t): IR incorrect - found %h; expected %h\n", $realtime, IR, Ref_IR);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_OP1 != OP1) begin
        $display("\tError(%t): OP1 incorrect - found %h; expected %h\n", $realtime, OP1, Ref_OP1);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end else if(Ref_OP2 != OP2) begin
        $display("\tError(%t): OP2 incorrect - found %h; expected %h\n", $realtime, OP2, Ref_OP2);
        @(posedge Clk); @(posedge Clk); @(posedge Clk); @(posedge Clk);
        $stop;
    end
end

////////////////////////////////////////////////////////////////////////////////

`include "M65C02_Mnemonics.txt"

endmodule
