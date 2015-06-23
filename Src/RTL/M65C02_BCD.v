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
// Create Date:     02/14/2012 
// Design Name:     WDC W65C02 Microprocessor Re-Implementation
// Module Name:     M65C02_BCD 
// Project Name:    C:\XProjects\ISE10.1i\MAM6502 
// Target Devices:  Generic SRAM-based FPGA
// Tool versions:   Xilinx ISE10.1i SP3
// 
// Description:
//
// Dependencies:    None.
//
// Revision:
// 
//  1.00    12B14   MAM     Initial coding. Modified W65C02_Adder.v for BCD 
//                          only operation. Removed Mode input. No other
//                          changes.
//
//  1.01    12B15   MAM     Cleaned up the second digit adder. Removed the C6
//                          signal and combined the 4-bit and 2-bit adders into
//                          a single 5-bit adder to match the one used for the
//                          least significant digit.
//
//  1.02    12B19   MAM     Renamed module: MAM6502 => M6502_BCD.
//
//  1.10    12K17   MAM     Converted MSN_GT9, MSN_GT8, and LSN_GT9 to ROMs
//
//  1.20    13H04   MAM     Converted output so it generates a 0 until En signal
//                          is asserted. Makes module compatible with an OR bus.
//
//  1.30    13H16   MAM     Modified rEn FF to have an asynchronous reset. This
//                          drives the module output to zero before the start of
//                          the next microcycle and prevent contention on the
//                          ALU output data bus.
//
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////

module M65C02_BCD(
    input   Rst,                // Module Reset
    input   Clk,                // System Clock
    input   En,                 // Enable

    input   Op,                 // Adder Operation: 0 - Addition; 1 - Subtract
    
    input   [7:0] A,            // Adder Input A
    input   [7:0] B,            // Adder Input B
    input   Ci,                 // Adder Carry In
    
    output  reg [8:0] Out,      // Adder Sum <= A + B + Ci
    output  reg OV,             // Adder Overflow
    output  reg Valid           // Adder Outputs Valid
);

////////////////////////////////////////////////////////////////////////////////
//
//  Declarations
//

reg     [7:0] S;        // Intermediate Binary Sum: S <= A + B + Ci
reg     [1:0] DA;       // Decimal Adjust Controls
reg     C3, C7;         // Sum Carry Out from Bitx 
reg     [7:0] Adj;

reg     rEn, rOp;
reg     [7:0] rS;
reg     rC3, rC7;

reg     MSN_GT9, MSN_GT8, LSN_GT9;  // Digit value comparator signals

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

//  Capture Input Control Signals

assign Rst_BCD = (Rst | ~En);               

always @(posedge Clk or posedge Rst_BCD)    
begin
    if(Rst_BCD)
        {rEn, rOp} <= #1 0;
    else
        {rEn, rOp} <= #1 {En, Op};
end        

//  Adder First Stage - Combinatorial; Binary Sums and Carries

always @(*)
begin
    // Binary Addition and Generate C3 and C7 Carries
    
    {C3, S[3:0]} <= ({1'b0, A[3:0]} + {1'b0, B[3:0]} + {4'b0, Ci});
    {C7, S[7:4]} <= ({1'b0, A[7:4]} + {1'b0, B[7:4]} + {4'b0, C3});
end

//  Adder First Stage - Registered; Binary Sums and Carrys

always @(posedge Clk)
begin
    if(Rst)
        {rC7, rC3, rS} <= #1 0;
    else if(En)
        {rC7, rC3, rS} <= #1 {C7, C3, S};
end

//  Generate Digit/Nibble Value Comparators

//always @(*) MSN_GT9 <= (rS[7:4] > 9);

always @(*)
begin
    case(rS[7:4])
        4'b0000 : MSN_GT9 <= 0;
        4'b0001 : MSN_GT9 <= 0;
        4'b0010 : MSN_GT9 <= 0;
        4'b0011 : MSN_GT9 <= 0;
        4'b0100 : MSN_GT9 <= 0;
        4'b0101 : MSN_GT9 <= 0;
        4'b0110 : MSN_GT9 <= 0;
        4'b0111 : MSN_GT9 <= 0;
        4'b1000 : MSN_GT9 <= 0;
        4'b1001 : MSN_GT9 <= 0;
        4'b1010 : MSN_GT9 <= 1;
        4'b1011 : MSN_GT9 <= 1;
        4'b1100 : MSN_GT9 <= 1;
        4'b1101 : MSN_GT9 <= 1;
        4'b1110 : MSN_GT9 <= 1;
        4'b1111 : MSN_GT9 <= 1;
    endcase
end

//always @(*) MSN_GT8 <= (rS[7:4] > 8);

always @(*)
begin
    case(rS[7:4])
        4'b0000 : MSN_GT8 <= 0;
        4'b0001 : MSN_GT8 <= 0;
        4'b0010 : MSN_GT8 <= 0;
        4'b0011 : MSN_GT8 <= 0;
        4'b0100 : MSN_GT8 <= 0;
        4'b0101 : MSN_GT8 <= 0;
        4'b0110 : MSN_GT8 <= 0;
        4'b0111 : MSN_GT8 <= 0;
        4'b1000 : MSN_GT8 <= 0;
        4'b1001 : MSN_GT8 <= 1;
        4'b1010 : MSN_GT8 <= 1;
        4'b1011 : MSN_GT8 <= 1;
        4'b1100 : MSN_GT8 <= 1;
        4'b1101 : MSN_GT8 <= 1;
        4'b1110 : MSN_GT8 <= 1;
        4'b1111 : MSN_GT8 <= 1;
    endcase
end

//always @(*) LSN_GT9 <= (rS[3:0] > 9);

always @(*)
begin
    case(rS[3:0])
        4'b0000 : LSN_GT9 <= 0;
        4'b0001 : LSN_GT9 <= 0;
        4'b0010 : LSN_GT9 <= 0;
        4'b0011 : LSN_GT9 <= 0;
        4'b0100 : LSN_GT9 <= 0;
        4'b0101 : LSN_GT9 <= 0;
        4'b0110 : LSN_GT9 <= 0;
        4'b0111 : LSN_GT9 <= 0;
        4'b1000 : LSN_GT9 <= 0;
        4'b1001 : LSN_GT9 <= 0;
        4'b1010 : LSN_GT9 <= 1;
        4'b1011 : LSN_GT9 <= 1;
        4'b1100 : LSN_GT9 <= 1;
        4'b1101 : LSN_GT9 <= 1;
        4'b1110 : LSN_GT9 <= 1;
        4'b1111 : LSN_GT9 <= 1;
    endcase
end

//  Adder Second Stage - Combinatorial; BCD Digit Adjustment

always @(*)
begin
    // Generate Decimal Mode Digit Adjust Signals

    DA[1] <= ((rOp) ? ~rC7 | (DA[0] & MSN_GT9)
                    :  rC7 | MSN_GT9 | (DA[0] & ~rC3 & MSN_GT8));
    DA[0] <= ((rOp) ? ~rC3
                    :  rC3 | LSN_GT9);

    case(DA)
        2'b01   : Adj <= (rS + ((rOp) ? 8'hFA : 8'h06)); // ±06 BCD
        2'b10   : Adj <= (rS + ((rOp) ? 8'hA0 : 8'h60)); // ±60 BCD
        2'b11   : Adj <= (rS + ((rOp) ? 8'h9A : 8'h66)); // ±66 BCD
        default : Adj <= (rS + 8'h00);                   // 0
    endcase
end
    
//  Adder Second Stage - Combinatorial; BCD Digit Adjustment

always @(*)
begin
    Out   <= ((rEn) ? {(rOp ^ DA[1]), Adj} : 0);
    OV    <= ((rEn) ? DA[1]                : 0);
    Valid <= rEn;
end

endmodule
