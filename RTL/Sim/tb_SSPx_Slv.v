///////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////`timescale 1ns / 1ps

`timescale 1ns / 1ps

///////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates
// Engineer:        Michael A. Morris
//
// Create Date:     09:03:15 05/10/2008
// Design Name:     LTAS 
// Module Name:     C:/XProjects/ISE10.1i/LTAS/tb_SSPx_Slv.v
// Project Name:    LTAS 
// Target Devices:  XC3S700AN-5FFG484I 
// Tool versions:   ISE 10.1i SP3 
//
// Description: This test bench is intended to test the SSP Slave interface
//              that will be used with the LPC2148 ARM microcomputer.
//
// Verilog Test Fixture created by ISE for module: SSPx_Slv
//
// Dependencies:
// 
// Revision History:
//
//  0.01    08E10   MAM     File Created
//
// Additional Comments: 
//
///////////////////////////////////////////////////////////////////////////////

module tb_SSPx_Slv_v;

// UUT Ports

reg     Rst;
reg     SSEL;
reg     SCK;
reg     MOSI;
wire    MISO;

wire    [2:0] RA;
wire    WnR;
wire    En;
wire    EOC;
wire    [11:0] DI;
reg     [11:0] DO;

wire    [3:0] BC;

// Instantiate the Unit Under Test (UUT)

SSPx_Slv    uut (
                .Rst(Rst),
                
                .SSEL(SSEL), 
                .SCK(SCK), 
                .MOSI(MOSI), 
                .MISO(MISO),
                
                .RA(RA),
                .WnR(WnR),
                .En(En), 
                .EOC(EOC),
                .DI(DI), 
                .DO(DO),
                
                .BC(BC) 
            );

initial begin
    // Initialize Inputs
    Rst  = 1;
    SSEL = 0;
    SCK  = 0;
    MOSI = 0;
    DO   = 16'b0;

    // Wait 100 ns for global reset to finish
    #100 Rst = 0;
   
    // Add stimulus here

    #100;
    
    SSP(3'h7, 1'b1, 12'h556, 12'hAA9);
    
end
  
//  Task SSP Write

task SSP;
    input   [2:0] RAIn;
    input   Cmd;
    input   [11:0] DIn;
    input   [11:0] DOut;
    
    begin
           SSEL = 1; MOSI = RAIn[2]; DO = DOut;
        #5 SCK  = 1; 
        #5 SCK  = 0; MOSI = RAIn[1];
        #5 SCK  = 1;
        #5 SCK  = 0; MOSI = RAIn[0];
        #5 SCK  = 1;
        #5 SCK  = 0; MOSI = Cmd;
        #5 SCK  = 1;
        #5 SCK  = 0; MOSI = DIn[11];
        #5 SCK  = 1;
        #5 SCK  = 0; MOSI = DIn[10];
        #5 SCK  = 1;
        #5 SCK  = 0; MOSI = DIn[ 9];
        #5 SCK  = 1;
        #5 SCK  = 0; MOSI = DIn[ 8];
        #5 SCK  = 1;
        #5 SCK  = 0; MOSI = DIn[ 7];
        #5 SCK  = 1;
        #5 SCK  = 0; MOSI = DIn[ 6];
        #5 SCK  = 1;
        #5 SCK  = 0; MOSI = DIn[ 5];
        #5 SCK  = 1;
        #5 SCK  = 0; MOSI = DIn[ 4];
        #5 SCK  = 1;
        #5 SCK  = 0; MOSI = DIn[ 3];
        #5 SCK  = 1;
        #5 SCK  = 0; MOSI = DIn[ 2];
        #5 SCK  = 1;
        #5 SCK  = 0; MOSI = DIn[ 1];
        #5 SCK  = 1;
        #5 SCK  = 0; MOSI = DIn[ 0];
        #5 SCK  = 1;
        #5 SCK  = 0; SSEL = 0;
        #10;
    end
endtask

endmodule

