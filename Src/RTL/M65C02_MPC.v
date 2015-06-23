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
// Create Date:     10/30/2009 
// Design Name:     WDC W65C02 Microprocessor Re-Implementation
// Module Name:     M65C02_MPC
// Project Name:    C:\XProjects\ISE10.1i\MAM6502
// Target Devices:  Generic SRAM-based FPGA
// Tool versions:   Xilinx ISE 10.1i SP3
// 
// Description:
//
// This module implements a simple microprogram sequencer based on the Fair-
// child F9408. The sequencer provides:
//
//          (1) 4-bit instruction input
//          (2) four-level LIFO stack;
//          (3) program counter and incrementer;
//          (4) 4-bit registered test input;
//          (5) 8-way multi-way branch control input;
//          (6) branch address input;
//          (7) 4-way branch address select output;
//          (8) next address output.
//
// These elements provide a relatively flexible general purpose microprogram
// controller without a complex instruction set. The sixteen instructions can
// be categorized into three classes: (1) fetch, (2) unconditional branches,
// and (3) conditional branches. The fetch instruction class, a single instruc-
// tion class, simply increments the program counter and outputs the current
// value of the program counter on the next address bus. The unconditional 
// branch instruction class provides instructions to select the next instruc-
// tion using the Via[1:0] outputs and output that value on the next address
// bus and simultaneously load the program counter. The unconditional branch
// instruction class also provides for 8-way multiway branching using an exter-
// nal (priority) encoder/branch selector, and microprogram subroutine call and 
// return instructions.
//
// The instruction encodings of the F9408, as provided in "Principles of Firm-
// ware Engineering in Microprogram Control" by Michael Andrews. The instruc-
// tion set and operation map for the implementation is given below:
//
//  I[3:0] MNEM Definition       T[3:0]      MA[m:0]      Via Inh  Operation
//   0000  RTS  Return            xxxx      TOS[m:0]       00  0  PC<=MA;Pop
//   0001  BSR  Call Subroutine   xxxx       BA[m:0]       00  1  PC<=MA;Push
//   0010  FTCH Next Instruction  xxxx        PC+1         00  0  PC<=MA[m:0]
//   0011  BMW  Multi-way Branch  xxxx  {BA[m:3],MW[2:0]}  00  1  PC<=MA[m:0]
//   0100  BRV0 Branch Via 0      xxxx       BA[m:0]       00  1  PC<=MA[m:0]
//   0101  BRV1 Branch Via 1      xxxx       BA[m:0]       01  1  PC<=MA[m:0]
//   0110  BRV2 Branch Via 2      xxxx       BA[m:0]       10  1  PC<=MA[m:0]
//   0111  BRV3 Branch Via 3      xxxx       BA[m:0]       11  1  PC<=MA[m:0]
//   1000  BTH0 Branch T0 High    xxx1  {T0?BA[m:0]:PC+1}  00  1  PC<=MA[m:0]
//   1001  BTH1 Branch T1 High    xx1x  {T1?BA[m:0]:PC+1}  00  1  PC<=MA[m:0]
//   1010  BTH2 Branch T2 High    x1xx  {T2?BA[m:0]:PC+1}  00  1  PC<=MA[m:0]
//   1011  BTH3 Branch T3 High    1xxx  {T2?BA[m:0]:PC+1}  00  1  PC<=MA[m:0]
//   1100  BTL0 Branch T0 Low     xxx0  {T0?PC+1:BA[m:0]}  00  1  PC<=MA[m:0]
//   1101  BTL1 Branch T1 Low     xx0x  {T1?PC+1:BA[m:0]}  00  1  PC<=MA[m:0]
//   1110  BTL2 Branch T2 Low     x0xx  {T2?PC+1:BA[m:0]}  00  1  PC<=MA[m:0]
//   1111  BTL3 Branch T3 Low     0xxx  {T3?PC+1:BA[m:0]}  00  1  PC<=MA[m:0]
//
// Dependencies:    none.
//
// Revision: 
//
//  0.01    09J30   MAM     File Created
//
//  1.00    10G10   MAM     Stack Pop operation modified to load StkD register
//                          with 0 during subroutine returns. This will force
//                          the microprogram to restart at 0 if the stack is
//                          underflowed, or POPed, more the 4 times. Also made
//                          a change to the Stack Push operation so that Next
//                          is pushed instead of MA.
//
//  1.01    10G24   MAM     Corrected typos in the instruction table.
//
//  1.02    10G25   MAM     Removed Test Input Register, Strb input, and Inh
//                          output. External logic required to provide synchro-
//                          nized inputs for testing.
//
//  2.00    10H28   MAM     Converted the BRV3 instruction into a conditional
//                          branch to subroutine instruction. In this way the
//                          BRV3, or CBSR, instruction can be used to take a
//                          branch to an interrupt subroutine. The conditional
//                          subroutine call is taken if T[3] is a logic 1. Like
//                          the BSR instruction, the address of the subroutine
//                          is provided by BA field.
//
//  2.10    11C05           Simplified return stack implementation. Removed
//                          unused code, but retained code commented out that
//                          reflects original implementation of BRV3 instruc-
//                          tion.
//
//  2.11    11C20           Removed CBSR modification
//
//  3.00    11C21           Changed module and added support for pipelined op-
//                          eration per the connections of the original F9408.
//                          Included an internal Reset FF stretcher to insure
//                          that an external registered PROM has time to fetch
//                          the first microprogram word. Removed the MA_Sel
//                          input because really should have been module reset.
//                          Without tying MA to 0 with the internal reset, the
//                          module in pipelined mode was not executing the same
//                          microprogram as non-pipelined mode module and that
//                          was unexpected. With these changes, the module per-
//                          forms identically to the original F9408 MPC.
//
//  4.00    12A29   MAM     Changing the behavior of BRV0, BRV1, BRV2, and BMW
//                          so that they are all conditional on T0. If T0 is
//                          not asserted, these instructions will wait at the
//                          current location until T0 is asserted. Renamed the
//                          module from F9408A_MPC.v to MAM6502_MPC.v. Para-
//                          meterized the reset address.
//
//  4.10    12B03   MAM     Restored the operation of the BRVx and BMW instruc-
//                          tions, but added two inputs to allow the module to
//                          respond to an external ready signal. In this manner
//                          the module will operate as a single or multi-cycle
//                          microprogram controller as determined by external
//                          logic, or the microprogram.
//
//  4.11    12B19   MAM     Renamed module: MAM6502_MPC => M65C02_MPC.
//
// Additional Comments: 
//
//  Since this component is expected to be used in a fully synchronous design,
//  the registering of the Test inputs with an external Strb signal and the Inh
//  signal is not desirable since it puts another delay in the signal path. The
//  effect will be to decrease the responsiveness of the system, and possibly
//  require that the test inputs be stretched so that pulsed signals are not
//  missed by the conditional tests in the microprogram. In the partially
//  synchronous design environment in which the original F9408 was used, incor-
//  porating a register internal to the device for the test inputs was very 
//  much a requirement to reduce the risk of metastable behaviour of the micro-
//  program. To fully support the test inputs, the microprogram should include
//  an explicit enable for the test input logic in order to control the chang-
//  ing of the test inputs relative to the microroutines.
//
///////////////////////////////////////////////////////////////////////////////

module M65C02_MPC #(
    parameter pAddrWidth = 10,          // Original F9408 => 10-bit Address
    parameter pRst_Addrs = 0            // Reset Address
)(
    input   Rst,                        // Module Reset (Synchronous)
    input   Clk,                        // Module Clock
    input   [3:0] I,                    // Instruction (see description)
    input   [3:0] T,                    // Conditional Test Inputs
    input   [2:0] MW,                   // Multi-way Branch Address Select
    input   [(pAddrWidth-1):0] BA,      // Microprogram Branch Address Field
    output  [1:0] Via,                  // Unconditional Branch Address Select
    input   En,                         // Enable Ready
    input   Rdy,                        // Ready
    input   PLS,                        // Pipeline Mode Select
    output  reg [(pAddrWidth-1):0] MA   // Microprogram Address
);

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
//  Local Parameters
//

localparam RTS  =  0;   // Return from Subroutine
localparam BSR  =  1;   // Branch to Subroutine
localparam FTCH =  2;   // Fetch Next Instruction
localparam BMW  =  3;   // Multi-way Branch
localparam BRV0 =  4;   // Branch Via External Branch Address Source #0
localparam BRV1 =  5;   // Branch Via External Branch Address Source #1
localparam BRV2 =  6;   // Branch Via External Branch Address Source #2
localparam BRV3 =  7;   // Branch Via External Branch Address Source #3
localparam BTH0 =  8;   // Branch if T[0] is Logic 1, else fetch next instr.
localparam BTH1 =  9;   // Branch if T[1] is Logic 1, else fetch next instr.
localparam BTH2 = 10;   // Branch if T[2] is Logic 1, else fetch next instr.
localparam BTH3 = 11;   // Branch if T[3] is Logic 1, else fetch next instr.
localparam BTL0 = 12;   // Branch if T[0] is Logic 0, else fetch next instr.
localparam BTL1 = 13;   // Branch if T[1] is Logic 0, else fetch next instr.
localparam BTL2 = 14;   // Branch if T[2] is Logic 0, else fetch next instr.
localparam BTL3 = 15;   // Branch if T[3] is Logic 0, else fetch next instr.

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
//  Declarations
//

wire    [(pAddrWidth - 1):0] Next;        // Output Program Counter Incrementer
reg     [(pAddrWidth - 1):0] PC_In;       // Input to Program Counter
reg     [(pAddrWidth - 1):0] PC;          // Program Counter

reg     [(pAddrWidth - 1):0] A, B, C, D;  // LIFO Stack Registers

reg     dRst;                             // Reset stretcher
wire    MPC_Rst;                          // Internal MPC Reset signal

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

always @(posedge Clk)
begin
    if(Rst)
        dRst <= #1 1;
    else
        dRst <= #1 0;
end

assign MPC_Rst = ((PLS) ? (Rst | dRst) : Rst);

//  Implement 4-Level LIFO Stack

always @(posedge Clk)
begin
    if(MPC_Rst)
        {D, C, B, A} <= #1 0;
    else if(I == BSR)
        {D, C, B, A} <= #1 {C, B, A, Next};
    else if(I == RTS)
        {D, C, B, A} <= #1 {{pAddrWidth{1'b0}}, D, C, B};
end

//  Program Counter Incrementer

assign Next = PC + 1;

//  Generate Unconditional Branch Address Select

assign Via = {((I == BRV2) | (I == BRV3)), ((I == BRV3) | (I == BRV1))};       

//  Generate Program Counter Input Signal

always @(*)
begin
    case({MPC_Rst, I})
        RTS     : PC_In <=  A;
        BSR     : PC_In <=  BA;
        FTCH    : PC_In <=  Next;
        BMW     : PC_In <=  {BA[(pAddrWidth - 1):3], MW};
        //
        BRV0    : PC_In <=  BA;
        BRV1    : PC_In <=  BA;
        BRV2    : PC_In <=  BA;
        BRV3    : PC_In <=  BA;
        //
        BTH0    : PC_In <=  (T[0] ? BA   : Next);
        BTH1    : PC_In <=  (T[1] ? BA   : Next);
        BTH2    : PC_In <=  (T[2] ? BA   : Next);
        BTH3    : PC_In <=  (T[3] ? BA   : Next);
        //
        BTL0    : PC_In <=  (T[0] ? Next : BA  );
        BTL1    : PC_In <=  (T[1] ? Next : BA  );
        BTL2    : PC_In <=  (T[2] ? Next : BA  );
        BTL3    : PC_In <=  (T[3] ? Next : BA  );
        default : PC_In <=  pRst_Addrs;
    endcase
end

//  Generate Microprogram Address (Program Counter)

always @(posedge Clk)
begin
    if(MPC_Rst)
        PC <= #1 pRst_Addrs;
    else
        PC <= #1 ((En) ? ((Rdy) ? PC_In : PC) : PC_In);
end

//  Assign Memory Address Bus

always @(*)
begin
    MA <= ((PLS) ? ((En) ? ((Rdy) ? PC_In : PC) : PC_In) : PC);
end

endmodule
