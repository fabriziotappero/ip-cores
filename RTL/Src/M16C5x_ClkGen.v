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

////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates 
// Engineer:        Michael A. Morris 
// 
// Create Date:     20:32:33 06/15/2013 
// Design Name:     M16C5x - PIC-compatible Extensible Processor Core 
// Module Name:     M16C5x_ClkGen 
// Project Name:    C:\XProjects\ISE10.1i\M16C5x
// Target Devices:  RAM-based FPGAs: XC3S50A-xVQ100; XC3S200A-xVQ100
// Tool versions:   Xilinx ISE 10.1i SP3
// 
// Description: 
//
//  This module combines an Architecture Wizard IP instatiation of a DCM_SP to 
//  generate a 4x clock from an external crystal oscillator. It also generates
//  a reset signal to external logic, and a reset signal for internal logic and
//  the DCM. An external reset input is accepted, but buffered using a synchro-
//  nizer.
//  
// Dependencies: ClkGen.xaw
//
// Revision:
//
//  0.01    13F15   MAM     Creation Date
//
//  1.00    13F21   MAM     Corrected error in the reset generation logic. An
//                          AND reduction operator was applied to external reset
//                          shift register. An OR reduction is necessary, and
//                          is not applied. Asserting the external reset now
//                          generates a reset pulse several clock cycles in
//                          width to the internal logic. Added Clk_UART as an
//                          output taken from the Clk2X output of DCM. Clk_UART
//                          can noew be fixed at 2x ClkIn.
//
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////

module M16C5x_ClkGen(
    input   nRst,                       // External Reset Input (active low)
    input   ClkIn,                      // Reference Input Clk
    
    output  Clk,                        // Internal Clk - (M/D) x ClkIn
    output  Clk_UART,                   // 2x ClkIn
    output  BufClkIn,                   // Buffered ClkIn
    
    output  reg Rst                     // Internal Reset
);

////////////////////////////////////////////////////////////////////////////////
//
//  Declarations
//

wire    DCM_Locked;             // DCM Locked Status Signal

reg     [3:0] DCM_Rst;          // Stretched DCM Reset (see Table 3-6 UG331)
reg     nRst_IFD;               // Input FF for external Reset signal
reg     [3:0] xRst;             // Stretched external reset (BufClkIn)
wire    Rst_M16C5x;             // Combination of DCM_Rst and xRst
reg     [3:0] Rst_Dly;          // Stretched internal reset (BufClkIn)
wire    FE_Rst_Dly;             // Falling edge of Rst_Dly (Clk)

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

//  Implement internal clock generator using DCM and DFS. DCM/DFS multiplies
//  external clock reference by 4.

ClkGen  ClkGen (
            .USER_RST_IN(DCM_Rst[0]),           // DCM Rst generated on FE Lock 

            .CLKIN_IN(ClkIn),                   // ClkIn          = 14.7456 MHz
            .CLKIN_IBUFG_OUT(BufClkIn),         // Buffered ClkIn = 14.7456 MHz

            .CLKFX_OUT(Clk),                    // DCM ClkFX_Out  = 58.9824 MHz 

            .CLK0_OUT(),                        // Clk0_Out unused 
            .CLK2X_OUT(Clk_UART),               // Clk2x_Out (FB) = 29.4912 MHz 
            
            .LOCKED_OUT(DCM_Locked)             // When 1, DCM Locked 
        );
      
//  Detect falling edge of DCM_Locked, and generate DCM reset pulse at least 4
//  ClkIn periods wide if a falling edge is detected. (see Table 3-6 UG331)
        
fedet   FE1 (
            .rst(1'b0),             // No reset required for this circuit 
            .clk(BufClkIn),         // Buffered DCM input Clock
            .din(DCM_Locked),       // DCM Locked signal
            .pls(FE_DCM_Locked)     // Falling Edge of DCM_Locked signal
        );
        
always @(posedge BufClkIn or posedge FE_DCM_Locked)
begin
    if(FE_DCM_Locked)
        DCM_Rst <= #1 4'b1111;
    else
        DCM_Rst <= #1 {1'b0, DCM_Rst[3:1]};
end

//  Synchronize asynchronous external reset, nRst, to internal clock and
//      stretch (extend) by 16 clock cycles after external reset deasserted
//
//  With Spartan 3A(N) FPGA family use synchronous reset for reset operations
//  per synthesis recommendations. so only these FFs will use asynchronous
//  reset, and the remainder of the design will use synchronous reset.

always @(posedge BufClkIn or negedge DCM_Locked)
begin
    if(~DCM_Locked)
        nRst_IFD <= #1 0;
    else
        nRst_IFD <= #1 nRst;
end

always @(posedge BufClkIn or negedge DCM_Locked)
begin
    if(~DCM_Locked)
        xRst <= #1 ~0;
    else
        xRst <= #1 {~nRst_IFD, xRst[2:1]};
end        

assign Rst_M16C5x = ((|{~nRst_IFD, xRst}) | ~DCM_Locked);

always @(posedge BufClkIn or posedge Rst_M16C5x)
begin
    if (Rst_M16C5x)
        Rst_Dly <= #1 ~0;
    else
        Rst_Dly <= #1 {1'b0, Rst_Dly[3:1]};
end

//  synchronize Rst to DCM/DFS output clock (if DCM Locked)

fedet   FE2 (
            .rst(Rst_M16C5x),       
            .clk(Clk),              // System Clock
            .din(|Rst_Dly),         // System Reset Delay
            .pls(FE_Rst_Dly)        // Falling Edge of Rst_Dly
        );

always @(posedge Clk or posedge Rst_M16C5x)
begin
    if(Rst_M16C5x)
        Rst <= #1 1;
    else if(FE_Rst_Dly)
        Rst <= #1 0;
end

endmodule
