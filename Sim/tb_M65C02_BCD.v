///////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2009-2012 by Michael A. Morris, dba M. A. Morris & Associates
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
// Create Date:     12/06/2009 
// Design Name:     WDC W65C02 Microprocessor Re-Implementation
// Module Name:     M65C02_BCD 
// Project Name:    C:\XProjects\ISE10.1i\MAM6502 
// Target Devices:  Generic SRAM-based FPGA
// Tool versions:   Xilinx ISE10.1i SP3
//
// Description: 
//
// Verilog Test Fixture created by ISE for module: M65C02_BCD.v
//
// Revision:
// 
//  0.01    09L06   MAM     Initial coding
//
//  1.00    12D28   MAM     Modified to support release version of the BCD
//                          adder module, which is separate from the binary
//                          adder module.
//
// Additional Comments:
// 
///////////////////////////////////////////////////////////////////////////////

module tb_W65C02_BCD;

// System Interface

reg     Rst;
reg     Clk;

// Inputs

reg     En;
reg     Sub;

reg     [7:0] A;
reg     [7:0] B;
reg     Ci;

// Outputs

wire    [7:0] Sum;
wire    Co;
wire    OV;
wire    Valid;

//  Simulation Variables

integer i, j, k;

reg     [4:0] LSN, MSN;
reg     C3, C7;
reg     [7:0] ALU;
reg     N, V, Z, C;

// Instantiate the Unit Under Test (UUT)

M65C02_BCD  uut (
                .Rst(Rst),
                .Clk(Clk),
                .En(En),
                
                .Op(Sub),
                
                .A(A),
                .B(B), 
                .Ci(Ci), 
                .Out({Co, Sum}),
                .OV(OV),
                .Valid(Valid)
            );

initial begin
    Rst  = 1;
    Clk  = 1;
    
    En   = 0;
    Sub  = 0;
    A    = 0;
    B    = 0;
    Ci   = 0;
    
    i = 0; j = 0; k = 0;
    LSN = 0; MSN = 0; C3 = 0; C7 = 0; ALU = 0; {N,V,Z,C} = 0;

    // Wait 100 ns for global reset to finish
    
    #101 Rst = 0;
    
    $display("Begin Adder Tests");

    // BCD Tests
    
    $display("Start Decimal Mode Addition Test");
    
    Sub = 0;              // ADC Test

    for(i = 0; i < 100; i = i + 1) begin
        k = (i / 10);
        A = (k * 16) + (i - (k * 10));
        for(j = 0; j < 100; j = j + 1) begin
            k  = (j / 10);
            B  = (k * 16) + (j - (k * 10));
            Ci = 0;
            En = 1;
            @(posedge Clk) #0.9 En = 0;
            @(posedge Valid) #0.1;
            if((Sum != ALU) || (Co != C) || (OV != V)) begin
                $display("Error: Incorrect Result");
                $display("\tA: 0x%2h, B: 0x%2h, Ci: %b", A, B, Ci);
                $display("\t\t{NVZC, ALU}: %b%b%b%b, 0x%2h", N, V, Z, C, ALU);
                $display("\t\t{-V-C, Sum}: -%b-%b, 0x%2h", OV, Co, Sum);
                $display("End Decimal Mode Addition Test: Fail");
                $stop;
            end
            @(posedge Clk) #1;
            Ci = 1;
            En = 1;
            @(posedge Clk) #0.9 En = 0;
            @(posedge Valid) #0.1;
            if((Sum != ALU) || (Co != C) || (OV != V)) begin
                $display("Error: Incorrect Result");
                $display("\tA: 0x%2h, B: 0x%2h, Ci: %b", A, B, Ci);
                $display("\t\t{NVZC, ALU}: %b%b%b%b, 0x%2h", N, V, Z, C, ALU);
                $display("\t\t{-V-C, Sum}: -%b-%b, 0x%2h", OV, Co, Sum);
                $display("End Decimal Mode Addition Test: Fail");
                $stop;
            end
            @(posedge Clk) #1;
        end
    end

    $display("End Decimal Mode Addition Test: Pass");
    
    // SBC Test
    
    $display("Start Decimal Mode Subtraction Test");
    
    Sub = 1;         // SBC Test

    for(i = 0; i < 100; i = i + 1) begin
        k = (i / 10);
        A = (k * 16) + (i - (k * 10));
        for(j = 0; j < 100; j = j + 1) begin
            k  = (j / 10);
            B  = ~((k * 16) + (j - (k * 10)));
            Ci = 1;
            En = 1;
            @(posedge Clk) #0.9 En = 0;
            @(posedge Valid) #0.1;
            if((Sum != ALU) || (Co != C) || (OV != V)) begin
                $display("Error: Incorrect Result");
                $display("\tA: 0x%2h, B: 0x%2h, Ci: %b", A, B, Ci);
                $display("\t\t{NVZC, ALU}: %b%b%b%b, 0x%2h", N, V, Z, C, ALU);
                $display("\t\t{-V-C, Sum}: -%b-%b, 0x%2h", OV, Co, Sum);
                $display("End Decimal Mode Subtraction Test: Fail");
                $stop;
            end
            @(posedge Clk) #1;
            Ci = 0;
            En = 1;
            @(posedge Clk) #0.9 En = 0;
            @(posedge Valid) #0.1;
            if((Sum != ALU) || (Co != C) || (OV != V)) begin
                $display("Error: Incorrect Result");
                $display("\tA: 0x%2h, B: 0x%2h, Ci: %b", A, B, Ci);
                $display("\t\t{NVZC, ALU}: %b%b%b%b, 0x%2h", N, V, Z, C, ALU);
                $display("\t\t{-V-C, Sum}: -%b-%b, 0x%2h", OV, Co, Sum);
                $display("End Decimal Mode Subtraction Test: Fail");
                $stop;
            end
            @(posedge Clk) #1;
        end
    end

    $display("End Decimal Mode Subtraction Test: Pass");
    
//    // Binary Tests
//
//    $display("Start Binary Mode Addition Test");
//    
//    En = 0; Op = 0;         // ADC Test
//    
//    for(i = 0; i < 256; i = i + 1) begin
//        A = i;
//        for(j = 0; j < 256; j = j + 1) begin
//            B  = j;
//            Ci = 0;
//            #5; 
//            if((Sum != ALU) || (Co != C) || (OV != V)) begin
//                $display("Error: Incorrect Result");
//                $display("\tQ: 0x%2h, R: 0x%2h, Ci: %b", Q, R, Ci);
//                $display("\t\t{NVZC, ALU}: %b%b%b%b, 0x%2h", N, V, Z, C, ALU);
//                $display("\t\t{-V-C, Sum}: -%b-%b, 0x%2h", OV, Co, Sum);
//                $display("End Binary Mode Addition Test: Fail");
//                $stop;
//            end
//            #5;
//            Ci = 1;
//            #5; 
//            if((Sum != ALU) || (Co != C) || (OV != V)) begin
//                $display("Error: Incorrect Result");
//                $display("\tQ: 0x%2h, R: 0x%2h, Ci: %b", Q, R, Ci);
//                $display("\t\t{NVZC, ALU}: %b%b%b%b, 0x%2h", N, V, Z, C, ALU);
//                $display("\t\t{-V-C, Sum}: -%b-%b, 0x%2h", OV, Co, Sum);
//                $display("End Decimal Mode Addition Test: Fail");
//                $stop;
//            end
//            #5;
//        end
//    end
//
//    $display("End Binary Mode Addition Test: Pass");
//    
//    //  Binary Mode
//    
//    $display("Start Binary Mode Subtraction Test");
//    
//    En = 0; Op = 1;         // SBC Test
//
//    for(i = 0; i < 256; i = i + 1) begin
//        A = i;
//        for(j = 0; j < 256; j = j + 1) begin
//            B  = ~j;
//            Ci = 1;
//            #5; 
//            if((Sum != ALU) || (Co != C) || (OV != V)) begin
//                $display("Error: Incorrect Result");
//                $display("\tQ: 0x%2h, R: 0x%2h, Ci: %b", Q, R, Ci);
//                $display("\t\t{NVZC, ALU}: %b%b%b%b, 0x%2h", N, V, Z, C, ALU);
//                $display("\t\t{-V-C, Sum}: -%b-%b, 0x%2h", OV, Co, Sum);
//                $display("End Binary Mode Subtraction Test: Fail");
//                $stop;
//            end
//            #5;
//            Ci = 0;
//            #5; 
//            if((Sum != ALU) || (Co != C) || (OV != V)) begin
//                $display("Error: Incorrect Result");
//                $display("\tQ: 0x%2h, R: 0x%2h, Ci: %b", Q, R, Ci);
//                $display("\t\t{NVZC, ALU}: %b%b%b%b, 0x%2h", N, V, Z, C, ALU);
//                $display("\t\t{-V-C, Sum}: -%b-%b, 0x%2h", OV, Co, Sum);
//                $display("End Decimal Mode Subtraction Test: Fail");
//                $stop;
//            end
//            #5;
//        end
//    end
//    
//    $display("End Binary Mode Subtraction Test: Pass");
//    
//    $display("End Adder Tests: Pass");

    $stop;
   
end

///////////////////////////////////////////////////////////////////////////////
//
//  System Clk

always #5 Clk = ~Clk;

///////////////////////////////////////////////////////////////////////////////
//
//  BCD Mode Adder Model
//

always @(*)
begin
//    if(D) begin
        if(Sub) begin
            LSN[4:0] <= {1'b0, A[3:0]} + {1'b0, B[3:0]} + {4'b0, Ci};
            C3       <= LSN[4] & ~(LSN[3] & (LSN[2] | LSN[1]));
            ALU[3:0] <= ((C3) ? (LSN[3:0] + 0) : (LSN[3:0] + 10));

            MSN[4:0] <= {1'b0, A[7:4]} + {1'b0, B[7:4]} + {4'b0, C3};
            C7       <= MSN[4] & ~(MSN[3] & (MSN[2] | MSN[1]));
            ALU[7:4] <= ((C7) ? (MSN[3:0] + 0) : (MSN[3:0] + 10));        
        end else begin
            LSN[4:0] <= {1'b0, A[3:0]} + {1'b0, B[3:0]} + {4'b0, Ci};
            C3       <= LSN[4] | (LSN[3] & (LSN[2] | LSN[1]));
            ALU[3:0] <= ((C3) ? (LSN[3:0] + 6) : (LSN[3:0] + 0));

            MSN[4:0] <= {1'b0, A[7:4]} + {1'b0, B[7:4]} + {4'b0, C3};
            C7       <= MSN[4] | (MSN[3] & (MSN[2] | MSN[1]));
            ALU[7:4] <= ((C7) ? (MSN[3:0] + 6) : (MSN[3:0] + 0));
        end
        
        N <= ALU[7]; V <= ((Sub) ? ~C7 : C7); Z <= ~|ALU; C <= C7;
//    end else begin
//        LSN[4:0] <= {1'b0, A[3:0]} + {1'b0, B[3:0]} + {4'b0, Ci};
//        C3       <= LSN[4];
//        ALU[3:0] <= LSN[3:0];
//
//        MSN[3:0] <= {1'b0, A[6:4]} + {1'b0, B[6:4]} + {4'b0, C3};
//        MSN[4]   <= (MSN[3] & (A[7] ^ B[7]) | (A[7] & B[7]));
//        C7       <= MSN[4];
//        ALU[7:4] <= {A[7] ^ B[7] ^ MSN[3], MSN[2:0]};        
//
//        N <= ALU[7]; V <= (MSN[4] ^ MSN[3]); Z <= ~|ALU; C <=  C7;
//    end
end
      
endmodule

