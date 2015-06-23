////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2009-2013 by Michael A. Morris, dba M. A. Morris & Associates
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
// Create Date:     08:02:40 03/01/2013 
// Design Name:     Microprogram Controller (Version 4)
// Module Name:     MPCv4.v
// Project Name:    C:\XProjects\VerilogComponents\MPCv4
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
// and (3) conditional branches. The fetch instruction class, consisting of a 
// single instruction class, simply increments the program counter and outputs
// the current value of the program counter on the next address bus. The uncon-
// ditional branch instruction class provides instructions to select the next
// instruction using the Via[1:0] outputs and output that value on the next
// address bus and simultaneously load the program counter. The unconditional
// branch instruction class also provides for 8-way multiway branching using an
// external (priority) encoder/branch selector, and microprogram subroutine call
// and return instructions.
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
//  0.01    12J28   MAM     File Created
//
//  1.00    12K12   MAM     Modified MA multiplexer to either present next
//                          address or hold current address. This is required
//                          when the next microcycle has a length greater than
//                          one. To perform this adjustment/extension of the
//                          microcycle, two signals track the current and next
//                          microcycle length: CurLenZ, and NxtLenZ. Also, added
//                          register MPC_En to control the MPC registers and
//                          MA multiplexer. Removed non-pipelined mode control
//                          input because the typical usage of the MPC is with
//                          Block RAM, which will only work with the pipelined
//                          mode.
//
//  1.10    12K20   MAM     Changed reset for the microcycle length controller
//                          portion from MPC_Rst to Rst, which releases the
//                          microcycle length controller one cycle ahead of the
//                          MPC logic of the module. This is required to ensure
//                          that MPC_En and the microcycle length controller SM
//                          are properly conditioned before the start of micro-
//                          program execution. Removed the multiplexer on MA.
//                          The multiplexer was used to hold the address of the
//                          MPC when a delay cycle was required. It was put into
//                          implementation to correct an issue with BCD instruc-
//                          tions during testing with single cycle memory. The
//                          same issue reappeared when multi-cycle microcycles
//                          were tested. The issue was corrected by removing the
//                          MA multiplexer, and properly conditioning the PSW,
//                          interrupt handler update and the microprogram ROMs
//                          with the Rdy signal. The original fix, adding the MA
//                          multiplexer, fixed the issue because the PSW ISR
//                          update logic and microprogram ROMs were not condi-
//                          tioned with Rdy. The multiplexer added a microcycle
//                          delay which couldn't be sustained for multi-cycle
//                          microcycles; the required microprogram address delay
//                          could only be sustained for one cycle without adding
//                          the enable, i.e. Rdy, to the microprogram ROM.
//
//  1.20    13C01   MAM     Changed microcycle length controller to fixed length
//                          controller of 4 clocks per microcycle. However, add-
//                          ed two states to support synchronous wait state in-
//                          sertion. If Rdy not asserted during C3 (MC==1), then
//                          a wait state of 4 clock cycles is added by inserting
//                          two states which return to C2 (MC==3). In these two
//                          new cycles, Phi1O should be asserted, and then when
//                          the cycle returns to C2 and C3 again, Phi2O is re-
//                          asserted high. If on C3, Rdy is not asserted, the
//                          wait state cycles resume. If on C3, Rdy is asserted,
//                          the the memory cycle terminates, input data is cap-
//                          tured, and the microcyle moves to C4 to complete.
//
// Additional Comments: 
//
//  The Version 4 Microprogram Controller (MPCv4) is based on the Fairchild
//  F9408 MPC. It extends that microprogram controller by incorporating a micro-
//  cycle controller and wait state generator directly into the module. The
//  microcycle controller sets the length of the microcycle to 4 clock cycles.
//  Although the MPC is able to execute a microprogram in single cycle mode, the
//  version 4 MPC is intended to ease the implementation of processors which use
//  an external memory interface. A four cycle microcycle is about as short an
//  external memory cycle can be implemented to allow reasonably priced devices
//  to be used.
//
//  The wait state generator function has been built into the microcycle length
//  controller. The typical 4 cycle microcycle will expect that external memory
//  has completed the requested read or write cycle at the end of cycle 3. The
//  expectation is that the address, data, and control signals (A, DB, nOE, and
//  nWr) are asserted as required during cycle 2. The remainder of cycle 2, and
//  cycle 3 are used to read or write external memory. The bus control signals
//  will be deasserted, along with the data bus if a write operation is being
//  performed, at the end of cycle 3/start of cycle 4. This means that read data
//  from memory is registered at the start of cycle 4. 
//
//  If the external address decode logic, after decoding the address, determines
//  that a delay is required, then it must assert the Wait request such that the
//  microcycle controller detects it as asserted at the end of cycle 3 Istart of
//  cycle 4). If Wait is asserted in cycle 3, then the microcycle controller in-
//  serts a 4 cycle wait state cycle. The Wait signal is resampled during the
//  3rd wait state cycle, and if not asserted, the normal microcycle continues.
//  Otherwise, another 4 cycle wait state is inserted, and this process conti-
//  nues until Wait is not asserted during the 3rd cycle of the wait state se-
//  quence.
//
////////////////////////////////////////////////////////////////////////////////

module M65C02_MPCv4 #(
    parameter pAddrWidth = 10,          // Original F9408 => 10-bit Address
    parameter pRst_Addrs = 0            // Reset Address
)(
    input   Rst,                        // Module Reset (Synchronous)
    input   Clk,                        // Module Clock

    input   Wait,                       // Microcycle Wait State Request Input

    output  reg [2:0] MC,               // Microcycle State outputs

    input   [3:0] I,                    // Instruction (see description)
    input   [3:0] T,                    // Conditional Test Inputs
    input   [2:0] MW,                   // Multi-way Branch Address Select
    input   [(pAddrWidth-1):0] BA,      // Microprogram Branch Address Field
    output  [1:0] Via,                  // Unconditional Branch Address Select


    output  [(pAddrWidth-1):0] MA       // Microprogram Address
);

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Local Parameters
//

localparam pRTS  =  0;  // Return from Subroutine
localparam pBSR  =  1;  // Branch to Subroutine
localparam pFTCH =  2;  // Fetch Next Instruction
localparam pBMW  =  3;  // Multi-way Branch
localparam pBRV0 =  4;  // Branch Via External Branch Address Source #0
localparam pBRV1 =  5;  // Branch Via External Branch Address Source #1
localparam pBRV2 =  6;  // Branch Via External Branch Address Source #2
localparam pBRV3 =  7;  // Branch Via External Branch Address Source #3
localparam pBTH0 =  8;  // Branch if T[0] is Logic 1, else fetch next instr.
localparam pBTH1 =  9;  // Branch if T[1] is Logic 1, else fetch next instr.
localparam pBTH2 = 10;  // Branch if T[2] is Logic 1, else fetch next instr.
localparam pBTH3 = 11;  // Branch if T[3] is Logic 1, else fetch next instr.
localparam pBTL0 = 12;  // Branch if T[0] is Logic 0, else fetch next instr.
localparam pBTL1 = 13;  // Branch if T[1] is Logic 0, else fetch next instr.
localparam pBTL2 = 14;  // Branch if T[2] is Logic 0, else fetch next instr.
localparam pBTL3 = 15;  // Branch if T[3] is Logic 0, else fetch next instr.

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
//  Declarations
//

reg     MPC_En;                             // MPC register enable

wire    [(pAddrWidth - 1):0] Next;          // Output Program Counter Increm.
reg     [(pAddrWidth - 1):0] PC_In;         // Input to Program Counter
reg     [(pAddrWidth - 1):0] PC;            // Program Counter

//reg     [(pAddrWidth - 1):0] A, B, C, D;    // LIFO Stack Registers
reg     [(pAddrWidth - 1):0] A;             // LIFO Stack Registers

reg     dRst;                               // Reset stretcher
wire    MPC_Rst;                            // Internal MPC Reset signal

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

//  Implement module reset generator

always @(posedge Clk)
begin
    if(Rst)
        dRst <= #1 1;
    else
        dRst <= #1 0;
end

assign MPC_Rst = (Rst | dRst);

//
//  Embedded Microcycle Controller and Wait State Generator 
//
//  The microcycle length is fixed to 4 clock cycles in length when Wait is not
//  asserted in C3. If Wait is asserted in C3, then a 4 cycle wait sequence is
//  inserted. This behavior allows external logic to extend the microcycle
//  length in multiples of 4 clock cycles.

always @(posedge Clk)
begin
    if(Rst)
        MC <= #1 6;
    else
        case(MC)
            // Normal Operation
            4 : MC <= #1 6;                 // 4th cycle of microcycle (Phi1O)
            6 : MC <= #1 7;                 // 1st cycle of microcycle (Phi1O)
            7 : MC <= #1 5;                 // 2nd cycle of microcycle (Phi2O)
            5 : MC <= #1 ((Wait) ? 0 : 4);  // 3rd cycle of microcycle (Phi2O) 
            //  Wait State Operation
            0 : MC <= #1 2;                 // 4th cycle of microcycle (Phi1O)
            2 : MC <= #1 3;                 // 1st cycle of microcycle (Phi1O)
            3 : MC <= #1 1;                 // 2nd cycle of microcycle (Phi2O)
            1 : MC <= #1 ((Wait) ? 0 : 4);  // 3rd cycle of microcycle (Phi2O)
        endcase
end

//  Determine the MPC Enable signal

always @(posedge Clk) MPC_En <= #1 ((Rst) ? 0 : (~Wait & (MC[1:0] == 1)));

////  Implement 4-Level LIFO Stack
//
//always @(posedge Clk)
//begin
//    if(MPC_Rst)
//        {A, B, C, D} <= #1 0;
//    else if(MPC_En)
//        if(I == BSR)
//            {A, B, C, D} <= #1 {Next, A, B, C};
//        else if(I == RTS)
//            {A, B, C, D} <= #1 {B, C, D, {pAddrWidth{1'b0}}};
//end

//  Implement 1-Level LIFO Stack

always @(posedge Clk)
begin
    if(MPC_Rst)
        A <= #1 0;
    else if(MPC_En)
        if(I == pBSR)
            A <= #1 Next;
        else if(I == pRTS)
            A <= #1 {pAddrWidth{1'b0}};
end

//  Program Counter Incrementer

assign Next = PC + 1;

//  Generate Unconditional Branch Address Select

assign Via = {((I == pBRV2) | (I == pBRV3)), ((I == pBRV3) | (I == pBRV1))};       

//  Generate Program Counter Input Signal

always @(*)
begin
    case({MPC_Rst, I})
        pRTS    : PC_In <=  A;
        pBSR    : PC_In <=  BA;
        pFTCH   : PC_In <=  Next;
        pBMW    : PC_In <=  {BA[(pAddrWidth - 1):3], MW};
        //
        pBRV0   : PC_In <=  BA;
        pBRV1   : PC_In <=  BA;
        pBRV2   : PC_In <=  BA;
        pBRV3   : PC_In <=  BA;
        //
        pBTH0   : PC_In <=  (T[0] ? BA   : Next);
        pBTH1   : PC_In <=  (T[1] ? BA   : Next);
        pBTH2   : PC_In <=  (T[2] ? BA   : Next);
        pBTH3   : PC_In <=  (T[3] ? BA   : Next);
        //
        pBTL0   : PC_In <=  (T[0] ? Next : BA  );
        pBTL1   : PC_In <=  (T[1] ? Next : BA  );
        pBTL2   : PC_In <=  (T[2] ? Next : BA  );
        pBTL3   : PC_In <=  (T[3] ? Next : BA  );
        default : PC_In <=  pRst_Addrs;
    endcase
end

//  Generate Microprogram Address (Program Counter)

always @(posedge Clk)
begin
    if(MPC_Rst)
        PC <= #1 pRst_Addrs;
    else if(MPC_En)
        PC <= #1 PC_In;
end

//  Assign Memory Address Bus

assign MA = PC_In;

endmodule
