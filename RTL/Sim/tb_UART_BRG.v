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

///////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates
// Engineer:        Michael A. Morris
//
// Create Date:     19:16:35 05/10/2008
// Design Name:     Synchronous Serial Peripheral (SSP) Interface UART 
// Module Name:     ../VerilogCoponentsLib/SSP_UART/tb_UART_BRG.v
// Project Name:    Verilog Components Library
// Target Devices:  XC3S50A-4VQG100I, XC3S20A-4VQG100I, XC3S700AN-4FFG484I 
// Tool versions:   ISE 10.1i SP3 
//
// Description: This test bench is intended to test the BRG module for the SSP 
//              UART.
//
// Verilog Test Fixture created by ISE for module: UART_BRG
//
// Dependencies:
// 
// Revision History:
//
//  0.01    08E10   MAM     File Created
//
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////

module tb_UART_BRG_v;

// Inputs
reg     Rst;
reg     Clk;
reg     [3:0] PS;
reg     [7:0] Div;

reg     [3:0] Baud;

// Outputs
wire    CE_16x;

// Instantiate the Unit Under Test (UUT)

UART_BRG    uut (
                .Rst(Rst), 
                .Clk(Clk),
                
                .PS(PS),
                .Div(Div),
                
                .CE_16x(CE_16x)
            );

initial begin
    // Initialize Inputs
    Rst  = 1;
    Clk  = 0;
    Baud = 0;

    // Wait 100 ns for global reset to finish
    #101;
 
    Rst = 0;
    
    // Add stimulus here
    
    
    @(posedge Clk);
    @(posedge Clk);
    @(posedge Clk);
    @(posedge Clk);
    @(posedge Clk);
    @(posedge Clk);
    @(posedge Clk);
    @(posedge Clk);
    
    @(posedge Clk)    #1 Baud = 1;
    @(negedge CE_16x) #1 Baud = 2;
    @(negedge CE_16x) #1 Baud = 3;
    @(negedge CE_16x);
    
    @(negedge CE_16x) #1 Baud = 4;
    @(negedge CE_16x) #1 Baud = 5;
    @(negedge CE_16x) #1 Baud = 6;
    @(negedge CE_16x) #1 Baud = 7;
    @(negedge CE_16x) #1 Baud = 8;
    @(negedge CE_16x) #1 Baud = 9;
    @(negedge CE_16x) #1 Baud = 10;
    @(negedge CE_16x) #1 Baud = 11;
    @(negedge CE_16x) #1 Baud = 12;
    @(negedge CE_16x) #1 Baud = 13;
    @(negedge CE_16x) #1 Baud = 14;
    @(negedge CE_16x) #1 Baud = 15;
    @(negedge CE_16x)
    
    @(negedge CE_16x) Baud = 0;

end

///////////////////////////////////////////////////////////////////////////////
//
//  Clocks
//

always #10.416 Clk = ~Clk;
  
///////////////////////////////////////////////////////////////////////////////
//
//  Simulation Drivers/Models
//

//  Baud Rate Generator's PS and Div for defined Baud Rates (48 MHz Oscillator)

always @(Baud)
begin
    case(Baud)
        4'b0000 : {Div, PS} <= 12'b0000_0000_0000; // Div =   1; PS =  1
        4'b0001 : {Div, PS} <= 12'b0000_0001_0000; // Div =   2; PS =  1
        4'b0010 : {Div, PS} <= 12'b0000_0101_0000; // Div =   6; PS =  1
        4'b0011 : {Div, PS} <= 12'b0000_1111_0000; // Div =  16; PS =  1
        4'b0100 : {Div, PS} <= 12'b0000_0000_1100; // Div =   1; PS = 13
        4'b0101 : {Div, PS} <= 12'b0000_0001_1100; // Div =   2; PS = 13
        4'b0110 : {Div, PS} <= 12'b0000_0010_1100; // Div =   3; PS = 13
        4'b0111 : {Div, PS} <= 12'b0000_0011_1100; // Div =   4; PS = 13
        4'b1000 : {Div, PS} <= 12'b0000_0101_1100; // Div =   6; PS = 13
        4'b1001 : {Div, PS} <= 12'b0000_1011_1100; // Div =  12; PS = 13
        4'b1010 : {Div, PS} <= 12'b0001_0111_1100; // Div =  24; PS = 13
        4'b1011 : {Div, PS} <= 12'b0010_1111_1100; // Div =  48; PS = 13
        4'b1100 : {Div, PS} <= 12'b0101_1111_1100; // Div =  96; PS = 13
        4'b1101 : {Div, PS} <= 12'b1011_1111_1100; // Div = 192; PS = 13
        4'b1110 : {Div, PS} <= 12'b0111_1111_1100; // Div = 128; PS = 13
        4'b1111 : {Div, PS} <= 12'b1111_1111_1100; // Div = 256; PS = 13
    endcase
end

endmodule

