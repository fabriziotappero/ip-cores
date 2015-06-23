///////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

///////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates 
// Engineer:        Michael A. Morris
// 
// Create Date:     02/14/2012 
// Design Name:     WDC W65C02 Microprocessor Re-Implementation
// Module Name:     M65C02_BIN
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
//  1.00    12B14   MAM     Initial coding. Modified W65C02_Adder.v for binary-
//                          only operation. MAM6502_BCD performs the same ops.
//                          as a BCD-only add/sub. Removed Mode input. Deleted
//                          second stage of the W6502_Adder module used for
//                          BCD adjustment.
//
//  1.01    12B19   MAM     Renamed module: MAM6502_BIN => M65C02_BIN.
//
//  1.10    13H04   MAM     Made the output a 0 when enable not asserted. Makes
//                          the module compatible with an OR bus.
//
// Additional Comments: 
//
///////////////////////////////////////////////////////////////////////////////

module M65C02_BIN(
    input   En,                 // ALU Enable

    input   [7:0] A,            // Adder Input A
    input   [7:0] B,            // Adder Input B
    input   Ci,                 // Adder Carry In
    
    output  reg [8:0] Out,      // Adder Sum <= A + B + Ci
    output  reg OV,             // Adder Overflow
    output  reg Valid           // Adder Outputs Valid
);

///////////////////////////////////////////////////////////////////////////////
//
//  Declarations
//

reg     [7:0] S;        // Intermediate Binary Sum: S <= A + B + Ci
reg     C6, C7;         // Sum Carry Out from Bitx 

///////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

//  Adder First Stage - Combinatorial; Binary Sums and Carries

always @(*)
begin
    // Binary Addition and Generate C6 and C7 Carries
    {C6, S[6:0]} <= ({1'b0, A[6:0]} + {1'b0, B[6:0]} + {7'b0, Ci});
    {C7,   S[7]} <= ({1'b0,   A[7]} + {1'b0,   B[7]} + {1'b0, C6});
end

always @(*)
begin
    Out   <= ((En) ? {C7, S}   : 0);
    OV    <= ((En) ? (C7 ^ C6) : 0);
    Valid <= En;
end

endmodule
