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
//  The souce code contained herein is free; it may be redistributed and/or 
//  modified in accordance with the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either version 2.1 of
//  the GNU Lesser General Public License, or any later version.
//
//  The souce code contained herein is freely released WITHOUT ANY WARRANTY;
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
// Create Date:     11:24:10 04/28/2012
// Design Name:     M65C02_AddrGen
// Module Name:     C:/XProjects/ISE10.1i/M65C02/tb_M65C02_AddrGen.v
// Project Name:    M65C02
// Target Devices:  Generic SRAM-based FPGA 
// Tool versions:   Xilinx ISE10.1i SP3
//
// Description:
//
// Verilog Test Fixture created by ISE for module: M65C02_AddrGen.v
//
// Revision: 
//
//  0.00    12D28   MAM     Initial File Creation
//
// Additional Comments: 
//
///////////////////////////////////////////////////////////////////////////////

module tb_M65C02_AddrGen;

///////////////////////////////////////////////////////////////////////////////
//
//  Local Parameters
//

localparam  pNA_MAR  = 4'h0;    // NA <= MAR
localparam  pNA_PC   = 4'h1;    // NA <= PC
localparam  pNA_Stk  = 4'h2;    // NA <= {8'b1, StkPtr}
localparam  pNA_Jsr  = 4'h3;    // NA <= {OP2, OP1}
//
localparam  pNA_Bcc  = 4'h4;    // NA <= ((CC)?((Next)+{{8{DI[7]}},DI}):Next)
localparam  pNA_Pls  = 4'h5;    // NA <= Next = MAR + 1
localparam  pNA_Inc  = 4'h6;    // NA <= Next = MAR + 1
localparam  pNA_Dec  = 4'h7;    // NA <= Next = MAR - 1
//
localparam  pNA_DPN  = 4'h8;    // NA <= {8'b0, DI} + 0
localparam  pNA_Jmp  = 4'h9;    // NA <= { DI, OP1} + 0
localparam  pNA_LDA  = 4'hA;    // NA <= { DI, OP1} + 0
localparam  pNA_Rtn  = 4'hB;    // NA <= { DI, OP1} + 1
//
localparam  pNA_DPX  = 4'hC;    // NA <= {8'b0, DI} + {0, X}
localparam  pNA_LDAX = 4'hD;    // NA <= { DI, OP1} + {0, X}
localparam  pNA_DPY  = 4'hE;    // NA <= {8'b0, DI} + {0, Y}
localparam  pNA_LDAY = 4'hF;    // NA <= { DI, OP1} + {0, Y}

localparam  pRst_Vec = 16'hFFFC;
localparam  pIRQ_Vec = 16'hFFFE;
localparam  pNMI_Vec = 16'hFFFA;

///////////////////////////////////////////////////////////////////////////////

// Inputs

reg     Rst;
reg     Clk;

reg     [15:0] Vector;
reg     BRV3;
reg     Int;

reg     Rdy_In;

reg     [3:0] NA_Op;

reg     CC;
reg     [7:0] DI;
reg     [7:0] OP1;
reg     [7:0] OP2;
reg     [7:0] StkPtr;
reg     [7:0] X;
reg     [7:0] Y;

// Outputs

wire    [15:0] AO;
wire    Rdy_Out;

wire    [15:0] NA;
wire    [15:0] MAR;
wire    [15:0] PC;
wire    [15:0] dPC;

// Simulation Variables

reg     [15:0] Rel     = 0;
reg     [15:0] Next    = 0;
reg     [15:0] Old_PC  = 0;
reg     [15:0] Old_dPC = 0;

// Instantiate the Unit Under Test (UUT)

M65C02_AddrGen  uut (
                    .Rst(Rst), 
                    .Clk(Clk),
                    
                    .Vector(Vector), 
                    .BRV3(BRV3), 
                    .Int(Int), 
                    
                    .Rdy_In(Rdy_In), 
                    
                    .NA_Op(NA_Op), 
                    
                    .CC(CC), 
                    .DI(DI), 
                    .OP1(OP1), 
                    .OP2(OP2), 
                    .StkPtr(StkPtr), 
                    .X(X), 
                    .Y(Y), 
                    
                    .AO(AO), 
                    .Rdy_Out(Rdy_Out), 
                    
                    .NA(NA), 
                    .MAR(MAR), 
                    .PC(PC), 
                    .dPC(dPC)
                );

initial begin
    // Initialize Inputs
    Rst     = 1;
    Clk     = 1;
    
    Vector      = pRst_Vec;
    BRV3        = 0;
    Int         = 0;
    
    Rdy_In      = 1;
    
    NA_Op       = 0;
    
    CC          = 0;
    DI          = 8'h96;
    {OP2, OP1}  = 16'hA55A;
    StkPtr      = 8'hFF;
    X           = ~DI;
    Y           = ~DI + 1;

    // Wait 100 ns for global reset to finish
    
    #101 Rst = 0;
    
    // Add stimulus here
    
    $display("Begin M65C02_AddrGen Tests\n");
    
    @(posedge Clk);
    if(   (AO  != pRst_Vec)
       || (MAR != pRst_Vec)
       || (PC  != pRst_Vec)
       || (dPC != pRst_Vec)) begin
        $display("    Error: M65C02_AddrGen not Reset Properly\n");
        $display("    Vector: %h, AO: %h, MAR: %d, PC: %h, dPC: %h\n",
                  pRst_Vec, AO, MAR, PC, dPC);
        $stop;
    end
    if(Rdy_Out) begin
        $display("    Error: M65C02_AddrGen not Reset Properly\n");
        $display("    Rdy_Out: %b; Expected 0\n", Rdy_Out);
        $stop;
    end
    
    @(posedge Clk);
    if((MAR != pRst_Vec)) begin
        $display("    Error: M65C02_AddrGen MAR Incremented Unexpectedly\n");
        $display("    MAR: %h; Expected: %d\n", MAR, pRst_Vec);
        $stop;
    end
    if(!Rdy_Out) begin
        $display("    Error: Rdy_Out not asserted\n");
        $stop;
    end
    if((PC != pRst_Vec) || (dPC != pRst_Vec)) begin
        $display("    Error: M65C02_AddrGen PC/dPC Unexpectedly Changed\n");
        $display("    PC: %h, dPC: %h; Expected: %h\n", PC, dPC, pRst_Vec);
        $stop;
    end
    
    $display("Initialization Test Complete: PASS\n");
    
    $display("Testing Sequential Increment/Decrement Operations\n");
    
    #1 NA_Op = pNA_Inc;
    @(posedge Clk) #1 NA_Op = pNA_Dec;
    #1;
    if((MAR != (pRst_Vec + 1))) begin
        $display("    Error: M65C02_AddrGen MAR did not increment as expected\n");
        $display("    MAR: %h; Expected: %h\n", MAR, (pRst_Vec + 1));
        $stop;
    end
    if(!Rdy_Out) begin
        $display("    Error: Rdy_Out not asserted as expected\n");
        $stop;
    end
    if((PC != pRst_Vec) || (dPC != pRst_Vec)) begin
        $display("    Error: M65C02_AddrGen PC/dPC Unexpectedly Changed\n");
        $display("    PC: %h, dPC: %h; Expected: %h\n", PC, dPC, pRst_Vec);
        $stop;
    end
    
    @(posedge Clk) #1 NA_Op = pNA_MAR;
    #1;
    if((MAR != (pRst_Vec))) begin
        $display("    Error: M65C02_AddrGen MAR did not decrement as expected\n");
        $display("    MAR: %h; Expected: %h\n", MAR, (pRst_Vec));
        $stop;
    end
    if(!Rdy_Out) begin
        $display("    Error: Rdy_Out not asserted as expected\n");
        $stop;
    end
    if((PC != pRst_Vec) || (dPC != pRst_Vec)) begin
        $display("    Error: M65C02_AddrGen PC/dPC Unexpectedly Changed\n");
        $display("    PC: %h, dPC: %h; Expected: %h\n", PC, dPC, pRst_Vec);
        $stop;
    end

    $display("    Sequential Increment/Decrement Operations: PASS\n");


    $display("Testing MAR <= PC Operation\n");
    
    @(posedge Clk) #1 NA_Op = pNA_Inc;
    @(posedge Clk) #1 NA_Op = pNA_PC;
    @(posedge Clk) #1 NA_Op = pNA_MAR;
    #1;
    if((MAR != PC)) begin
        $display("    Error: M65C02_AddrGen PC not loaded into MAR\n");
        $display("    MAR: %h; Expected: %h\n", MAR, PC);
        $stop;
    end
    if(Rdy_Out) begin
        $display("Error: Rdy_Out asserted\n");
        $stop;
    end
    if((PC != pRst_Vec) || (dPC != pRst_Vec)) begin
        $display("    Error: M65C02_AddrGen PC/dPC Unexpectedly Changed\n");
        $display("    PC: %h, dPC: %h; Expected: %h\n", PC, dPC, pRst_Vec);
        $stop;
    end
    @(posedge Rdy_Out);

    $display("    Testing MAR <= PC Operation: PASS\n");

    $display("Testing MAR <= StkPtr Operation\n");
    
    @(posedge Clk) #1 NA_Op = pNA_Stk;
    @(posedge Clk) #1 NA_Op = pNA_MAR;
    #1;
    if((MAR != {8'b1, StkPtr})) begin
        $display("    Error: M65C02_AddrGen Stk_Ptr not loaded into MAR\n");
        $display("    MAR: %h; Expected: %h\n", MAR, {8'b1, StkPtr});
        $stop;
    end
    if(Rdy_Out) begin
        $display("Error: Rdy_Out asserted\n");
        $stop;
    end
    if((PC != pRst_Vec) || (dPC != pRst_Vec)) begin
        $display("    Error: M65C02_AddrGen PC/dPC Unexpectedly Changed\n");
        $display("    PC: %h, dPC: %h; Expected: %h\n", PC, dPC, pRst_Vec);
        $stop;
    end
    @(posedge Rdy_Out);

    $display("    Testing MAR/PC <= StkPtr Operation: PASS\n");

    $display("Testing MAR <= {OP2, OP1} Operation\n");
    
    @(posedge Clk) #1 NA_Op = pNA_Jsr;
    @(posedge Clk) #1 NA_Op = pNA_MAR;
    #1;
    if((MAR != {OP2, OP1})) begin
        $display("    Error: M65C02_AddrGen {OP2, OP1} not loaded into MAR\n");
        $display("    MAR: %h; Expected: %h\n", MAR, {OP2, OP1});
        $stop;
    end
    if(Rdy_Out) begin
        $display("    Error: Rdy_Out asserted\n");
        $stop;
    end
    if((PC != {OP2, OP1})) begin
        $display("    Error: M65C02_AddrGen {OP2, OP1} not loaded into PC\n");
        $display("    PC: %h; Expected: %h\n", PC, {OP2, OP1});
        $stop;
    end
    if((dPC != pRst_Vec)) begin
        $display("    Error: M65C02_AddrGen dPC Unexpectedly Changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, pRst_Vec);
        $stop;
    end
    @(posedge Rdy_Out);

    $display("    Testing MAR/PC <= {OP2, OP1} Operation: PASS\n");

    $display("Testing MAR/PC <= Bcc Operation\n");
    
    {OP2, OP1} = PC;

    @(posedge Clk) #1 NA_Op = pNA_Bcc; CC = 1;
    @(posedge Clk) #1 NA_Op = pNA_MAR; CC = 0;
    #1;
    if((MAR != Rel)) begin
        $display("    Error: M65C02_AddrGen (MAR + 1 + rel) not loaded into MAR\n");
        $display("    MAR: %h; Expected: %h\n", MAR, Rel);
        $stop;
    end
    if(Rdy_Out) begin
        $display("    Error: Rdy_Out asserted\n");
        $stop;
    end
    if((PC != Rel)) begin
        $display("    Error: M65C02_AddrGen (MAR + 1 + rel) not loaded into PC\n");
        $display("    PC: %h; Expected: %h\n", PC, Rel);
        $stop;
    end
    if((dPC != {OP2, OP1})) begin
        $display("    Error: M65C02_AddrGen dPC incorrectly changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, {OP2, OP1});
        $stop;
    end
    @(posedge Rdy_Out);
    
    {OP2, OP1} = PC;

    @(posedge Clk) #1 NA_Op = pNA_Bcc;
    @(posedge Clk) #1 NA_Op = pNA_MAR;
    #1;
    if((MAR != Rel)) begin
        $display("    Error: M65C02_AddrGen (MAR + 1) not loaded into MAR\n");
        $display("    MAR: %h; Expected: %h\n", MAR, Rel);
        $stop;
    end
    if(!Rdy_Out) begin
        $display("    Error: Rdy_Out not asserted\n");
        $stop;
    end
    if((PC != Rel)) begin
        $display("    Error: M65C02_AddrGen (MAR + 1) not loaded into PC\n");
        $display("    PC: %h; Expected: %h\n", PC, Rel);
        $stop;
    end
    if((dPC != {OP2, OP1})) begin
        $display("    Error: M65C02_AddrGen dPC incorrectly changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, {OP2, OP1});
        $stop;
    end
    @(posedge Clk) #1;

    $display("    Testing MAR/PC <= Bcc Operation: PASS\n");

    $display("Testing MAR/PC <= (PC + 1) Operation\n");
    
    {OP2, OP1} = PC;
    Next       = PC + 1;
    
    @(posedge Clk) #1 NA_Op = pNA_Pls;
    @(posedge Clk) #1 NA_Op = pNA_MAR;
    #1;
    if((MAR != Next)) begin
        $display("    Error: M65C02_AddrGen (MAR + 1) not loaded into MAR\n");
        $display("    MAR: %h; Expected: %h\n", MAR, Next);
        $stop;
    end
    if(!Rdy_Out) begin
        $display("    Error: Rdy_Out not asserted\n");
        $stop;
    end
    if((PC != Next)) begin
        $display("    Error: M65C02_AddrGen (MAR + 1) not loaded into PC\n");
        $display("    PC: %h; Expected: %h\n", PC, Next);
        $stop;
    end
    if((dPC != {OP2, OP1})) begin
        $display("    Error: M65C02_AddrGen dPC incorrectly changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, {OP2, OP1});
        $stop;
    end
    
    $display("    Testing MAR/PC <= (PC + 1) Operation: PASS\n");

    $display("Testing MAR/PC <= Jmp Operation\n");
    
    {OP2, OP1} = PC;
    Next       = {DI, OP1};
    
    @(posedge Clk) #1 NA_Op = pNA_Jmp;
    @(posedge Clk) #1 NA_Op = pNA_MAR;
    #1;
    if((MAR != Next)) begin
        $display("    Error: M65C02_AddrGen {DI, OP1} not loaded into MAR\n");
        $display("    MAR: %h; Expected: %h\n", MAR, Next);
        $stop;
    end
    if(Rdy_Out) begin
        $display("    Error: Rdy_Out asserted\n");
        $stop;
    end
    if((PC != Next)) begin
        $display("    Error: M65C02_AddrGen {DI, OP1} not loaded into PC\n");
        $display("    PC: %h; Expected: %h\n", PC, Next);
        $stop;
    end
    if((dPC != {OP2, OP1})) begin
        $display("    Error: M65C02_AddrGen dPC incorrectly changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, {OP2, OP1});
        $stop;
    end
    @(posedge Rdy_Out);
    
    $display("    Testing MAR/PC <= Jmp Operation: PASS\n");

    $display("Testing MAR/PC <= RTS/RTI Operation\n");
    
    {OP2, OP1} = PC;
    Next       = {DI, OP1} + 1;
    
    @(posedge Clk) #1 NA_Op = pNA_Rtn;
    @(posedge Clk) #1 NA_Op = pNA_MAR;
    #1;
    if((MAR != Next)) begin
        $display("    Error: M65C02_AddrGen {DI, OP1} + 1 not loaded into MAR\n");
        $display("    MAR: %h; Expected: %h\n", MAR, Next);
        $stop;
    end
    if(Rdy_Out) begin
        $display("    Error: Rdy_Out asserted\n");
        $stop;
    end
    if((PC != Next)) begin
        $display("    Error: M65C02_AddrGen {DI, OP1} + 1 not loaded into PC\n");
        $display("    PC: %h; Expected: %h\n", PC, Next);
        $stop;
    end
    if((dPC != {OP2, OP1})) begin
        $display("    Error: M65C02_AddrGen dPC incorrectly changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, {OP2, OP1});
        $stop;
    end
    @(posedge Rdy_Out);
    
    $display("    Testing MAR/PC <= RTS/RTI Operation: PASS\n");

    $display("Testing MAR <= DP Operation\n");
    
    Old_PC  = PC;
    Old_dPC = dPC;
    Next    = {8'b0, DI};
    
    @(posedge Clk) #1 NA_Op = pNA_DPN;
    @(posedge Clk) #1 NA_Op = pNA_MAR;
    #1;
    if((MAR != Next)) begin
        $display("    Error: M65C02_AddrGen {8'b0, DI} not loaded into MAR\n");
        $display("    MAR: %h; Expected: %h\n", MAR, Next);
        $stop;
    end
    if(Rdy_Out) begin
        $display("    Error: Rdy_Out asserted\n");
        $stop;
    end
    if((PC != Old_PC)) begin
        $display("    Error: M65C02_AddrGen PC incorrectly changed\n");
        $display("    PC: %h; Expected: %h\n", PC, Old_PC);
        $stop;
    end
    if((dPC != Old_dPC)) begin
        $display("    Error: M65C02_AddrGen dPC incorrectly changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, Old_dPC);
        $stop;
    end
    @(posedge Rdy_Out);
    
    $display("    Testing MAR <= DP Operation: PASS\n");

    $display("Testing MAR <= Abs Operation\n");
    
    Old_PC  = PC;
    Old_dPC = dPC;
    Next    = {DI, OP1};
    
    @(posedge Clk) #1 NA_Op = pNA_LDA;
    @(posedge Clk) #1 NA_Op = pNA_MAR;
    #1;
    if((MAR != Next)) begin
        $display("    Error: M65C02_AddrGen {DI, OP1} not loaded into MAR\n");
        $display("    MAR: %h; Expected: %h\n", MAR, Next);
        $stop;
    end
    if(Rdy_Out) begin
        $display("    Error: Rdy_Out asserted\n");
        $stop;
    end
    if((PC != Old_PC)) begin
        $display("    Error: M65C02_AddrGen PC incorrectly changed\n");
        $display("    PC: %h; Expected: %h\n", PC, Old_PC);
        $stop;
    end
    if((dPC != Old_dPC)) begin
        $display("    Error: M65C02_AddrGen dPC incorrectly changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, Old_dPC);
        $stop;
    end
    @(posedge Rdy_Out);
    
    $display("    Testing MAR <= Abs Operation: PASS\n");

    $display("Testing MAR <= DP,X Operation\n");
    
    Old_PC  = PC;
    Old_dPC = dPC;
    Next    = {8'b0, (DI + X) & 8'hFF};
    
    @(posedge Clk) #1 NA_Op = pNA_DPX;
    @(posedge Clk) #1 NA_Op = pNA_MAR;
    #1;
    if((MAR != Next)) begin
        $display("    Error: M65C02_AddrGen {8'b0, (DI + X) mod 256} not loaded into MAR\n");
        $display("    MAR: %h; Expected: %h\n", MAR, Next);
        $stop;
    end
    if(Rdy_Out) begin
        $display("    Error: Rdy_Out asserted\n");
        $stop;
    end
    if((PC != Old_PC)) begin
        $display("    Error: M65C02_AddrGen PC incorrectly changed\n");
        $display("    PC: %h; Expected: %h\n", PC, Old_PC);
        $stop;
    end
    if((dPC != Old_dPC)) begin
        $display("    Error: M65C02_AddrGen dPC incorrectly changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, Old_dPC);
        $stop;
    end
    @(posedge Rdy_Out);
    
    $display("    Testing MAR <= DP,X Operation: PASS\n");

    $display("Testing MAR <= DP,Y Operation\n");
    
    Old_PC  = PC;
    Old_dPC = dPC;
    Next    = {8'b0, (DI + Y) & 8'hFF};
    
    @(posedge Clk) #1 NA_Op = pNA_DPY;
    @(posedge Clk) #1 NA_Op = pNA_MAR;
    #1;
    if((MAR != Next)) begin
        $display("    Error: M65C02_AddrGen {8'b0, (DI + Y) mod 256} not loaded into MAR\n");
        $display("    MAR: %h; Expected: %h\n", MAR, Next);
        $stop;
    end
    if(Rdy_Out) begin
        $display("    Error: Rdy_Out asserted\n");
        $stop;
    end
    if((PC != Old_PC)) begin
        $display("    Error: M65C02_AddrGen PC incorrectly changed\n");
        $display("    PC: %h; Expected: %h\n", PC, Old_PC);
        $stop;
    end
    if((dPC != Old_dPC)) begin
        $display("    Error: M65C02_AddrGen dPC incorrectly changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, Old_dPC);
        $stop;
    end
    @(posedge Rdy_Out);
    
    $display("    Testing MAR <= DP,Y Operation: PASS\n");

    $display("Testing MAR <= Abs,X Operation\n");
    
    Old_PC  = PC;
    Old_dPC = dPC;
    Next    = {DI, OP1} + {8'b0, X};
    
    @(posedge Clk) #1 NA_Op = pNA_LDAX;
    @(posedge Clk) #1 NA_Op = pNA_MAR;
    #1;
    if((MAR != Next)) begin
        $display("    Error: M65C02_AddrGen (Abs + X) not loaded into MAR\n");
        $display("    MAR: %h; Expected: %h\n", MAR, Next);
        $stop;
    end
    if(Rdy_Out) begin
        $display("    Error: Rdy_Out asserted\n");
        $stop;
    end
    if((PC != Old_PC)) begin
        $display("    Error: M65C02_AddrGen PC incorrectly changed\n");
        $display("    PC: %h; Expected: %h\n", PC, Old_PC);
        $stop;
    end
    if((dPC != Old_dPC)) begin
        $display("    Error: M65C02_AddrGen dPC incorrectly changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, Old_dPC);
        $stop;
    end
    @(posedge Rdy_Out);
    
    $display("    Testing MAR <= Abs,X Operation: PASS\n");

    $display("Testing MAR <= Abs,Y Operation\n");
    
    Old_PC  = PC;
    Old_dPC = dPC;
    Next    = {DI, OP1} + {8'b0, Y};
    
    @(posedge Clk) #1 NA_Op = pNA_LDAY;
    @(posedge Clk) #1 NA_Op = pNA_MAR;
    #1;
    if((MAR != Next)) begin
        $display("    Error: M65C02_AddrGen (Abs + Y) not loaded into MAR\n");
        $display("    MAR: %h; Expected: %h\n", MAR, Next);
        $stop;
    end
    if(Rdy_Out) begin
        $display("    Error: Rdy_Out asserted\n");
        $stop;
    end
    if((PC != Old_PC)) begin
        $display("    Error: M65C02_AddrGen PC incorrectly changed\n");
        $display("    PC: %h; Expected: %h\n", PC, Old_PC);
        $stop;
    end
    if((dPC != Old_dPC)) begin
        $display("    Error: M65C02_AddrGen dPC incorrectly changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, Old_dPC);
        $stop;
    end
    @(posedge Rdy_Out);
    
    $display("    Testing MAR <= Abs,Y Operation: PASS\n");
    

    $display("Testing PC Interrupt Behavior\n");

    Old_PC  = PC;
    Old_dPC = dPC;
    Next    = PC;
    
    BRV3 = 0; Int = 1;
    
    @(posedge Clk) #1 NA_Op = pNA_PC;
    @(posedge Clk) #1 NA_Op = pNA_Pls;
    #1;
    if((MAR != Next)) begin
        $display("    Error: MAR != PC\n");
        $display("    MAR: %h; Expected: %h\n", MAR, Next);
        $stop;
    end
    if(Rdy_Out) begin
        $display("    Error: Rdy_Out asserted\n");
        $stop;
    end
    if((PC != Old_PC)) begin
        $display("    Error: M65C02_AddrGen PC incorrectly changed\n");
        $display("    PC: %h; Expected: %h\n", PC, Old_PC);
        $stop;
    end
    if((dPC != Old_dPC)) begin
        $display("    Error: M65C02_AddrGen dPC incorrectly changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, Old_dPC);
        $stop;
    end
    @(posedge Rdy_Out);
    
    $display("    BRV3 not asserted, Int asserted, MAR loaded with PC as expected\n");
    
    Old_PC  = PC + 1;
    Old_dPC = PC;
    Next    = PC + 1;
    
    BRV3 = 0; Int = 1;
    
    @(posedge Clk) #1 NA_Op = pNA_Pls;
    #1;
    if((MAR != Next)) begin
        $display("    Error: MAR != PC\n");
        $display("    MAR: %h; Expected: %h\n", MAR, Next);
        $stop;
    end
    if(!Rdy_Out) begin
        $display("    Error: Rdy_Out not asserted\n");
        $stop;
    end
    if((PC != Old_PC)) begin
        $display("    Error: M65C02_AddrGen PC incorrectly changed\n");
        $display("    PC: %h; Expected: %h\n", PC, Old_PC);
        $stop;
    end
    if((dPC != Old_dPC)) begin
        $display("    Error: M65C02_AddrGen dPC incorrectly changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, Old_dPC);
        $stop;
    end
    @(posedge Clk) #1 NA_Op = pNA_Pls;
    #1;
    
    $display("    BRV3 not asserted, Int asserted, PC increments as expected\n");
    
    Old_PC  = PC + 1;
    Old_dPC = PC;
    Next    = PC + 1;
    
    BRV3 = 0; Int = 1;
    
    @(posedge Clk) #1 NA_Op = pNA_MAR;
    #1;
    if((MAR != Next)) begin
        $display("    Error: MAR != PC\n");
        $display("    MAR: %h; Expected: %h\n", MAR, Next);
        $stop;
    end
    if(!Rdy_Out) begin
        $display("    Error: Rdy_Out not asserted\n");
        $stop;
    end
    if((PC != Old_PC)) begin
        $display("    Error: M65C02_AddrGen PC incorrectly changed\n");
        $display("    PC: %h; Expected: %h\n", PC, Old_PC);
        $stop;
    end
    if((dPC != Old_dPC)) begin
        $display("    Error: M65C02_AddrGen dPC incorrectly changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, Old_dPC);
        $stop;
    end
    @(posedge Clk) #1 NA_Op = pNA_Pls;
    
    $display("    BRV3 not asserted, Int asserted, PC increments as expected\n");
    
    BRV3 = 1; Int = 0;

    #1;
    Old_PC  = PC + 1;
    Old_dPC = PC;
    Next    = PC + 1;
    
    @(posedge Clk) #1 NA_Op = pNA_Pls;
    #1;
    if((MAR != Next)) begin
        $display("    Error: MAR != PC\n");
        $display("    MAR: %h; Expected: %h\n", MAR, Next);
        $stop;
    end
    if(!Rdy_Out) begin
        $display("    Error: Rdy_Out not asserted\n");
        $stop;
    end
    if((PC != Old_PC)) begin
        $display("    Error: M65C02_AddrGen PC incorrectly changed\n");
        $display("    PC: %h; Expected: %h\n", PC, Old_PC);
        $stop;
    end
    if((dPC != Old_dPC)) begin
        $display("    Error: M65C02_AddrGen dPC incorrectly changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, Old_dPC);
        $stop;
    end
    @(posedge Clk) #1 NA_Op = pNA_Pls;
    
    $display("    BRV3 asserted, Int not asserted, PC increments as expected\n");
   
    BRV3 = 1; Int = 1;

    #1;
    Old_PC  = PC;
    Old_dPC = dPC;
    Next    = PC;
    
    @(posedge Clk) #1 NA_Op = pNA_Pls;
    #1;
    if((MAR != Next)) begin
        $display("    Error: MAR != PC\n");
        $display("    MAR: %h; Expected: %h\n", MAR, Next);
        $stop;
    end
    if(!Rdy_Out) begin
        $display("    Error: Rdy_Out not asserted\n");
        $stop;
    end
    if((PC != Old_PC)) begin
        $display("    Error: M65C02_AddrGen PC incorrectly changed\n");
        $display("    PC: %h; Expected: %h\n", PC, Old_PC);
        $stop;
    end
    if((dPC != Old_dPC)) begin
        $display("    Error: M65C02_AddrGen dPC incorrectly changed\n");
        $display("    dPC: %h; Expected: %h\n", dPC, Old_dPC);
        $stop;
    end
    @(posedge Clk) #1 NA_Op = pNA_MAR;
    
    $display("    BRV3 and Int asserted, as expected, MAR/PC does not increment\n");

    BRV3 = 0; Int = 0;

    $display("    PC operation with interrupts: PASS\n");

    /////////////////////////////////////////////

    $display("End M65C02_AddrGen Tests: PASS\n");

    NA_Op = pNA_MAR;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    $stop;
end

///////////////////////////////////////////////////////////////////////////////
//
//  System Clock
//

always #5 Clk = ~Clk;

///////////////////////////////////////////////////////////////////////////////
//
//
//

always @(posedge Clk) Rel = #1 (MAR + 1 + ((CC) ? {{8{DI[7]}}, DI} : 0));

always @(*) Rdy_In = Rdy_Out;
      
endmodule

