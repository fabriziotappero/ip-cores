///////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

///////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates 
// Engineer:        Michael A. Morris
// 
// Create Date:     07:00:31 11/25/2009 
// Design Name:     WDC W65C02 Microprocessor Re-Implementation
// Module Name:     M65C02_ALU 
// Project Name:    C:\XProjects\ISE10.1i\MAM6502 
// Target Devices:  Generic SRAM-based FPGA 
// Tool versions:   Xilinx ISE10.1i SP3
// 
// Description:
//
//  This module implements the ALU for the M65C02 microprocessor. Included in
//  the ALU are the accumulator (A), pre/post-index registers (X and Y), stack
//  pointer (S), and processor status word (P). The microcode, composed of a
//  fixed part from the instruction decoder (IDEC) and a variable portion from
//  the execution engine, are used to control a binary adder unit (AU), a BCD
//  adder unit (DU), a shift unit (SU), a logic unit (LU) and a bit unit (BU).
//  The AU performs binary two's complement addition, and the DU performs un-
//  signed BCD addition on two operands. These units also handle subtraction,
//  but the operand multiplexers feeding data into these units must perform the
//  required complement of the operand to subtract from the accumulator. The SU
//  performs arithmetic and logical shifts and rotate operations on an operand.
//  The LU performs bit-wise operations (OR, AND, and XOR) on one operand. The
//  BU performs bit masking and testing on one operand.
//
//  The ALU requires an En input to be asserted to initiate the operation that
//  the fixed IDEC microword requires. The SC and Done fields in the variable
//  microwords from the execution engine controls the En input to the ALU. The
//  En input is a registered signal which when asserted indicates that the ope-
//  rands required to complete an operation have been read from memory. The
//  addressing mode of the instruction will determine when En is asserted. In
//  the case of program flow control instructions, En and the StkOp field will
//  control the updates to the stack pointer, S. In the case of non-program
//  flow control instructions, En alone controls the updates to these regis-
//  ters: A, X, Y, P. For implicit or accumulator mode instructions, En is ge-
//  nerally asserted when the opcode is loaded into the Instruction Register
//  (IR). Otherwise, it is asserted when the memory operand is loaded into the
//  OP1 register, and the operation defined by IDEC should be completed with
//  the available data. 
//
//  The Op input selects the operation to be performed by the AU, SU, or LU.
//      Note: Q = {Y, X, M, A}, R = {8'h01, M}, Ci = (CSel ? Sub : C).
//  
//   Op   Mnemonic     Operation              Condition Code
//  0000     XFR     ALU <= {OSel: 0, A, X, Y, P, S, M}
//  0001     OR      ALU <= A | M;      N <= ALU[7]; Z <= ~|ALU;
//  0010     AND     ALU <= A & M;      N <= ALU[7]; Z <= ~|ALU;
//  0011     EOR     ALU <= A ^ M;      N <= ALU[7]; Z <= ~|ALU;
//  0100     ADC     ALU <= Q +  M + C; N <= ALU[7]; Z <= ~|ALU;
//                                      V <= OVF;    C <= COut;
//  0101     SBC     ALU <= Q + ~M + C; N <= ALU[7]; Z <= ~|ALU;
//                                      V <= OVF;    C <= COut;
//  0110     INC     ALU <= Q +  1 + 0; N <= ALU[7]; Z <= ~|ALU;
//  0111     DEC     ALU <= Q + ~1 + 1; N <= ALU[7]; Z <= ~|ALU;
//  1000     ASL     ALU <= R << 1;     N <= ALU[7]; Z <= ~|ALU; C <= R[7];
//  1001     LSR     ALU <= R >> 1;     N <= ALU[7]; Z <= ~|ALU; C <= R[0];
//  1010     ROL     ALU <= {R[6:0], C} N <= ALU[7]; Z <= ~|ALU; C <= R[7];
//  1011     ROR     ALU <= {C, R[7:1]} N <= ALU[7]; Z <= ~|ALU; C <= R[0];
//  1100     BIT     ALU <= (A & M);    N <= M[7];   Z <= ~|(A & M);
//                                      V <= M[6];
//  1101     TRB     ALU <= M & ~A;                  Z <= ~|(A & M);
//  1110     TSB     ALU <= M |  A;                  Z <= ~|(A & M);
//  1111     CMP     ALU <= Q + ~M + 1  N <= ALU[7]; Z <= ~|ALU; C <= COut;
//
//  Although the condition codes modified by the ALU are shown above, the CC
//  input field will actually control loading condition codes into P register.
//  This is especially true for the N and V condition codes with respect to the
//  BIT instruction. N and V are modified by BIT as indicated above, except for
//  for the BIT #imm instruction which only modifies Z, and leaves N and V un-
//  changed like the TRB and TSB instructions.
//
//  The coding for the WSel and OSel fields follows:
//        3     3
//  Sel  WSel  OSel
//  000  none   M
//  001   A     A
//  010   X     X
//  011   Y     Y
//  100   -     0
//  101   S     S
//  110   P     P
//  111   M     M
//
//  The WSel field provides the register enable for writing into a register,
//  and the OSel field determines the value of the ALU result bus. Typically
//  the ALU result bus is the ALU. But on the occasion of a load, store, xfer,
//  push, and pull instructions, the ALU bus is driven by 0, A, X, Y, S, P, and
//  M. In this manner, the ALU result can be either loaded into the register
//  designated by the WSel field, or it can be written to memory.
//
//  The stack pointer, S, is also controlled directly by the execution SM. The
//  execution engine provides the operation of the stack pointer for push and
//  pop operations. The stack pointer and the two index registers are provided
//  to the Memory Address Register address generator. The value of the stack
//  output to the address generator is controlled by StkOp input field.
//
//  The coding of these control fields and the ALU field is designed to yield a
//  0 at the output of the module if all the input control fields are logical
//  0. This means that a NOP is simply a zero for all ALU control fields.
//
//  The CC_Sel field controls the CC_Out condition code test signal and the 
//  updating of the individual bits in P in response to specific instructions:
//
//  00_xxx: NOP/TRUE    - CC_Out =  1 unless (CCSel[4:3] != 2'b01)
//  01_000: CC          - CC_Out = ~C;
//  01_001: CS          - CC_Out =  C;
//  01_010: NE          - CC_Out = ~Z;
//  01_011: EQ          - CC_Out =  Z;
//  01_100: VC          - CC_Out = ~V;
//  01_101: VS          - CC_Out =  V;
//  01_110: PL          - CC_OUT = ~N;
//  01_111: MI          - CC_Out =  N;
//  10_000: CLC         - C <= 0;
//  10_001: SEC         - C <= 1;
//  10_010: CLI         - I <= 0;
//  10_011: SEI         - I <= 1;
//  10_100: CLD         - D <= 0;
//  10_101: SED         - D <= 1;
//  10_110: CLV         - V <= 0;
//  10_111: BRK         - B <= 1;
//  11_000: Z           - Z <= ~|(A & M);
//  11_001: NZ          - N <= ALU[7]; Z <= ~|ALU;
//  11_010: NZC         - N <= ALU[7]; Z <= ~|ALU; C <= COut
//  11_011: NVZ         - N <= M[7];   Z <= ~|(A & M); V <= M[6]; 
//  11_100: NVZC        - N <= ALU[7]; Z <= ~|ALU; V <= OVF;  C <= COut;
//  11_101: Rsvd
//  11_110: Rsvd
//  11_111: Rsvd        - P <= M;
//
//  The stack operations supported are: hold, rsvd, ++S, and S--. The stack
//  pointer can only be loaded from the X index register. Similarly, the stack
//  pointer can only be transfered to the X index register. The stack pointer
//  points to an open location on the stack. Thus, push operations write the
//  value at the location pointed to by S, and post-decrements S, S--. Stack 
//  pull operations require the value to be incremented by one, ++S, before
//  that location can be read into OP1 and subsequently written to one of four 
//  registers: P, A, X, or Y.
//
//  The stack pointer control, StkOp, field is generated by the execution
//  engine:
//
//  00  :   Hold;
//  01  :   Rsvd;
//  10  :   S--;
//  11  :   ++S;
//
// Dependencies:    M65C02_Bin.v, M65C02_BCD.v
//
// Revision:
// 
//  0.01    09K25   MAM     Initial coding
//
//  0.02    09K30   MAM     Corrected coding for zero detection from ~|ALU to
//                          ~|ALU[7:0]. ALU[8] is Carry Out, and first formu-
//                          lation only correct for non-arithmetic, non-shift
//                          operations. Corrected binary mode OVF equation.
//                          Changed priority of write enables for the PSW bits
//                          making the register write the highest priority,
//                          followed by the SEx and CLx instructions, respec-
//                          tively, followed by any special modes, and at the
//                          lowest priority any CC updates of ALU instructions.
//
//  0.03    09K30   MAM     Modified ALU structure to explicitly define the
//                          width of all operations. All operations explicitly
//                          set at 9 bits. Apparently, the synthesizer is able
//                          to better resolve the specified operations into 
//                          FPGA primitives. Nearly 11% improvement in the 
//                          reported speed of the synthesized ckts as a result.
//                          Also reported significant reduction in the reported
//                          area of the ckts. From an area of 35 to an area of
//                          23, which is a 33% reduction in the area of the
//                          synthesized ckts.
//
//  0.04    09L01   MAM     Broke the ADC/SBC adders into an 8-bit segment and
//                          a 1-bit segment in order to determine the carries
//                          out of bit 6 and out of bit 7 independently. This
//                          allows 2's Complement Overflow to be determined as
//                          exclusive OR of these two carries: V <= ^{C[7:6]}.
//                          Setting V with the sign of the two inputs and Sum,
//                          V = (A[7] & M[7] & ~S[7]) | (~A[7] & ~M[7] & S[7]),
//                          was proving to be wrong for the three operand ADDs
//                          that these two instructions actually represent. The
//                          overflow detection mechanism is independent of the
//                          number of operands into the adder tree. There was 
//                          an additional 10% improvement in speed as a result
//                          of this approach to ADC/SBC.
//
//  0.05    09L25   MAM     Modified the input parameter list to include select
//                          signals for the input of the adder. Two ports were
//                          defined for the Binary/BCD adder: Q and R. Selects
//                          were added to select the Q and R operands for the
//                          various instructions that utilize the adder: ADC,
//                          SBC, INC, DEC, and CMP. Also included BCD mode for
//                          this adder. Including the BCD mode slows down the
//                          ALU.
//
//  0.06    09L31   MAM     Modified the module to separate the multiplexer and
//                          the various computational units comprising the ALU.
//                          Registered versions of the Logic Unit (LU) (ORA, 
//                          AND, EOR), the Arithmetic Unit (AU) (ADC, SBC, INC,
//                          DEC, CMP), the Shift Unit (SU) (ASL, LSR, ROL, ROR)
//                          and the Bit Unit (BU) (BIT, TSB, TRB) were created.
//                          The multiplexer was modified as a registered device
//                          and implements the computation unit result multi-
//                          plexer and the ALU register multiplexer. Implemen-
//                          ted a Register Write Enable and global Valid signal
//                          generator to deal with the apropriate register up-
//                          dates. Modified the stack address generation logic
//                          to accomodate the registered nature of the ALU.
//
//  1.00    11D09   MAM     Removed unused code previously commented out.
//
//  1.01    11E14   MAM     Corrected the comments regarding Q and R operand
//                          multiplexer encoding.
//
//  1.02    12A28   MAM     Added parameter to set default value of Stack Ptr
//                          after reset.
//
//  1.10    12B04   MAM     Removed pipeline registers from the ALU Valid and
//                          StkPtr signals. Also, separated the LST (Load/Store
//                          /Transfer) mux from the ALU mux for readability.
//
//  1.11    12B11   MAM     Adjusted the Shift Unit's implementation to use a
//                          common structure that clearly shows the bit being
//                          being moved into the C, and similarly, the bit vec-
//                          tor being assigned to the ALU bus. Corrected com-
//                          ment on U multiplexer of the Q bus. The X and Y 
//                          register operations listed were swapped.
//
//  1.20    12B18   MAM     Added FF to delay SetB by one cycle. This delayed
//                          signal clears the D flag and sets the I flag on the
//                          cycle after the PSW is pushed onto the stack during
//                          a BRK instruction. Also added an input, ISR, that
//                          is asserted by the interrupt processing logic after
//                          pushing the PSW so that D is cleared and I is set.
//                          In both cases, the interrupt service routines will
//                          operate in binary mode and with external maskable
//                          interrupts disabled.
//
//  1.21    12B19   MAM     Renamed module: MAM6502_ALU => M65C02_ALU.
//
//  1.30    12B20   MAM     Removed FF added by 1.20. Decided that ISR strobe,
//                          controlled by the microcode, was a better control
//                          signal for this purpose. ISR expected to be assert-
//                          ed by interrupt and break microroutines at the cor-
//                          rect time before the start of the first instruction
//                          of the interrupt/trap service routine. Since the
//                          first instruction after accepting the interrupt or
//                          executing BRK is always executed, the D and I flags
//                          do not need to be modified until the end of that
//                          instruction.
//
//                          Substantially changed the Reg_WE logic and PSW im-
//                          plementation. During RTI testing, two problems were
//                          found and corrected: (1) control of register write
//                          enables was not possible, and (2) updates to the P
//                          were occuring unexpectedly in some situations. To
//                          correct the first, the microcode was changed and a
//                          port was added that provided a 3-bit register write
//                          enable input. This 3-bit input is combined with the
//                          3-bit WSel field from the fixed microword, to gene-
//                          rate register write enables for A, X, Y, S, and P.
//                          This new structure appears to retain the desired
//                          speed, and it is easier to control the desired ac-
//                          tions using the microprogram.
//
//                          To correct the second required modifications to P
//                          register. In putting in those changes, it was appa-
//                          rent that the use of individual registers and muxes
//                          for the various input signals, was a major contri-
//                          butor to poor implementation. Thus, a single 7-bit
//                          register was implemented, with an input multiplexer
//                          the more clearly defines the input signals and data
//                          sources for each type of operation that changes the
//                          PSW at an idividual bit level or as whole.
//
//                          The changes made in these two areas allow PAR to
//                          satisfy the 100 MHz operating speed objective.
//
//  1.31    12B23   MAM     Delete commented out code. Changed WE_x equation to
//                          use Valid instead of En. Valid will be delayed by 
//                          one cycle for BDC mode ADC/SBC instructions. This
//                          is expected to correctly write the BCD result into
//                          A and the flags into P. Without switching to Valid,
//                          the BCD result would not be captured correctly into
//                          A or P. Kept En as part of the WE_S equation, the
//                          component of the equation used for inc/dec of the
//                          stack pointer during stack operations.
//
//  1.32    12B24   MAM     Modified the port list to add a ready port, Rdy.
//                          Previosly the core-level signal was applied to the
//                          ALU through the En input. Separating out Rdy allows
//                          a combinatorial logic loop to be broken. Rdy is now
//                          applied to the write enable signals. The En input
//                          drives the ALU functional units, which drive Valid
//                          in the same cycle, or in the following cycle. In
//                          the case that Valid is delayed one cycle, Rdy will
//                          be deasserted by the core-level circuit, and the
//                          cycle will be stretched. When Valid asserts, Rdy 
//                          will also assert, the registers will be written,
//                          and the cycle will continue. This cycle stretch
//                          will only occur for BCD mode ADC/SBC instructions.
//
//  1.40    12B25   MAM     Made a correction to the PSW. Further research into
//                          the operation of the PSW indicates that there are
//                          only 6 physical bits in the register itself. Bit 4
//                          in P, the programmer visible status word, is gener-
//                          ally described as the B, or Break flag. Research 
//                          indicates that this bit is not implemented as a
//                          FF. Instead, the BRK instruction forces this bit to
//                          logic 1 during the push of P to the stack. It only
//                          exists in the copy of the PSW on the stack. It is
//                          this behavior that requires a shared vector inter-
//                          rupt service routine to examine the stack version
//                          of the PSW to determine if the interrupt is a re-
//                          sult of an external IRQ or a BRK instruction. Also
//                          applied this behavior of the B bit to PHP instruc-
//                          tion. The number of FFs used to implement PSW has
//                          been decreased by 1, and the declaration of B has
//                          been removed from the source.
//
//  1.50    12K12   MAM     Modified the stack pointer logic to eliminate extra
//                          adder.
//
//  1.60    12K20   MAM     During multi-cycle microcycle, the interrupt handler
//                          was found to be modifying the PSW early. This means
//                          that the D and I flags were not properly pushed onto
//                          the stack. The modified versions of the two flags
//                          were pushed onto the stack instead of the values in
//                          the PSW at the start of the interrupt handler. Fixed
//                          by qaulifying the PSW modification with the Rdy sig-
//                          nal which signifies the end of a microcycle. Worked
//                          with single cycle microcycles, including BCD ops,
//                          because Rdy is asserted and/or the BCD op completes
//                          during the push PCH cycle. With a multi-cycle micro-
//                          cycle, the modification occurred one cycle after the
//                          push PSW microcycle, but before the data was written
//                          to the stack. Hence, qualifying it with Rdy, delays
//                          the modification until the first cycle of the next
//                          microcycle; the original intent.
//
//  2.00    12L11   MAM     Added the Rockwell instructions (RMBx, SMBx, BBRx,
//                          and BBSx) to the ALU. Modified the Bit Logical Unit
//                          to accept a new command and bit mask input. The new
//                          commands use four unused CCSel codes, and a mask
//                          provided by a new input port connected to the Decode
//                          ROM. All other changes expected to be made in the 
//                          microprogram. RMBx/SMBx can use the RMW_DP micro-
//                          routine, but BBRx/BBSx require a new microroutine.
//
//  3.00    13H04           Made the internal bus multiplexers into a one-hot
//                          decoded OR bus. Had to make some minor adjustments
//                          to the LST_En and En_RU signals to accomodate the
//                          changes in the bus multiplexer implementation.
//
// Additional Comments:
//
///////////////////////////////////////////////////////////////////////////////

module M65C02_ALU #(
    parameter pStkPtr_Rst = 0  // Stack Pointer Value after Reset
)(
    input   Rst,            // System Reset - synchronous reset 
    input   Clk,            // System Clock
    
    input   Rdy,            // Ready
    
    input   En,             // Enable - ALU functions
    input   [2:0] Reg_WE,   // Register Write Enable 
    input   ISR,            // Asserted on entry to Interrupt Service Routine 
    
    //  ALU Ports
   
    input   [3:0] Op,       // ALU Operation Select
    input   [1:0] QSel,     // ALU Q Bus Multiplexer Select
    input   RSel,           // ALU R Bus Multiplexer Select
    input   Sub,            // ALU Adder Operation Select
    input   CSel,           // ALU Carry In Multiplexer Select
    input   [2:0] WSel,     // ALU Register WE Select
    input   [2:0] OSel,     // ALU Output Multiplexer Select
    input   [4:0] CCSel,    // ALU Condition Code Operation Select
    input   [7:0] Msk,      // ALU Mask for Rockwell Instructions
    
    input   [7:0] M,        // ALU Memory Operand Input
    output  reg [7:0] Out,  // ALU Output(asynchronous)
    output  Valid,          // ALU Output Valid

    output  reg CC_Out,     // Condition Code Test Output
    
    //  Stack Pointer Output
    
    input   [1:0] StkOp,    // Stack Pointer Operation Select
    
    output  [7:0] StkPtr,   // Stack Pointer Output: {S, S+1}
    
    //  Internal Processor Registers
    
    output  reg [7:0] A,    // Accumulator
    output  reg [7:0] X,    // X Index Register
    output  reg [7:0] Y,    // Y Index Register
    output  reg [7:0] S,    // Stack Pointer

    output  [7:0] P         // Processor Status Word
);

///////////////////////////////////////////////////////////////////////////////
//
//  Local Parameter Decalarations
//

//  Op[3:0] Encodings

//  Logic Unit
localparam pALU_NOP = 0;    // NOP - No Operation: ALU<={OSel: M,A,X,Y,Z,P,S,M}
localparam pALU_AND = 1;    // AND - bitwise AND Accumulator with Memory
localparam pALU_ORA = 2;    // ORA - bitwise OR Accumulator with Memory
localparam pALU_EOR = 3;    // EOR - bitwise XOR Accumulator with Memory
//  Arithmetic Unit
localparam pALU_ADC = 4;    // ADC - Add  Memory to Accumulator + Carry
localparam pALU_SBC = 5;    // SBC - Add ~Memory to Accumulator + Carry (Sub)
localparam pALU_INC = 6;    // INC - Increment {A, X, Y, or M} (binary-only)
localparam pALU_DEC = 7;    // DEC - Decrement {A, X, Y, or M} (binary-only)
//  Shift Unit
localparam pALU_ASL = 8;    // ASL - Arithmetic Shift Left {A, or M}
localparam pALU_LSR = 9;    // LSR - Logical Shift Right {A, or M}
localparam pALU_ROL = 10;   // ROL - Rotate Left through Carry {A, or M}
localparam pALU_ROR = 11;   // ROR - Rotate Right through Carry {A, or M}
//  Bit Unit
localparam pALU_BIT = 12;   // BIT - Test Memory with Bit Mask in Accumulator
localparam pALU_TRB = 13;   // TRB - Test and Reset Memory with Bit Mask in A
localparam pALU_TSB = 14;   // TSB - Test and Set Memory with Bit Mask in A
//  Compare Unit
localparam pALU_CMP = 15;   // CMP - Compare Memory to Accumulator (binary-only)

//  WSel/OSel Register Select Field Codes

localparam pSel_A   = 1;    // Select Accumulator
localparam pSel_X   = 2;    // Select X Index
localparam pSel_Y   = 3;    // Select Y Index
localparam pSel_Z   = 4;    // Select Zero
localparam pSel_S   = 5;    // Select Stack Pointer
localparam pSel_P   = 6;    // Select PSW
localparam pSel_M   = 7;    // Select Memory Operand

//  Condition Code Select

localparam pSMB  = 4;       // Set Memory Bit
localparam pRMB  = 5;       // Reset Memory Bit
localparam pBBS  = 6;       // Branch if Memory Bit Set
localparam pBBR  = 7;       // Branch if Mmemory Bit Reset
//
localparam pCC   = 8;       // Carry Clear
localparam pCS   = 9;       // Carry Set
localparam pNE   = 10;      // Not Equal to Zero
localparam pEQ   = 11;      // Equal to Zero
localparam pVC   = 12;      // Overflow Clear
localparam pVS   = 13;      // Overflow Set
localparam pPL   = 14;      // Plus (Not Negative)
localparam pMI   = 15;      // Negative
localparam pCLC  = 16;      // Clear C
localparam pSEC  = 17;      // Set Carry
localparam pCLI  = 18;      // Clear Interrupt mask
localparam pSEI  = 19;      // Set Interrupt mask
localparam pCLD  = 20;      // Clear Decimal mode
localparam pSED  = 21;      // Set Decimal mode
localparam pCLV  = 22;      // Clear Overflow
localparam pBRK  = 23;      // Set BRK flag
localparam pZ    = 24;      // Set Z = ~|(A & M)
localparam pNZ   = 25;      // Set N and Z flags from ALU
localparam pNZC  = 26;      // Set N, Z, and C flags from ALU
localparam pNVZ  = 27;      // Set N and V flags from M[7:6], and Z = ~|(A & M)
localparam pNVZC = 28;      // Set N, V, Z, and C from ALU
//
//
localparam pPSW  = 31;      // Set P from ALU

///////////////////////////////////////////////////////////////////////////////
//
//  Declarations
//

reg     COut;                   // Carry Out -> input to C
reg     [5:0] PSW;              // Processor Status Word (Register)
wire    N, V, D, I, Z, C;       // Individual, Registered Bits in PSW

wire    [7:0] W, U, Q;          // Adder Input Busses
wire    [7:0] T, R;
wire    Ci;                     // Adder Carry In signal

//  ALU Component Output Busses

reg     [8:0] LU;               // Logic Unit Output
reg     LU_Valid;               // LU Output Valid
wire    [8:0] AU;               // Adder Unit Output
wire    AU_Valid;               // AU Output Valid
wire    [8:0] DU;               // Decimal (BCD) Unit Output
wire    DU_Valid;               // DU Output Valid
reg     [8:0] SU;               // Shift/Rotate Unit Output
reg     SU_Valid;               // SU Output Valid
reg     [8:0] BU;               // Bit Unit Output
reg     BU_Valid;               // BU Output Valid

reg     [8:0] RU;               // Rockwell Unit Output
reg     RU_Valid;               // RU Output Valid

wire    LST_En;                 // Load/Store/Transfer Enable
reg     [5:0] LST_Sel;          // Load/Store/Transfer Select ROM
reg     [8:0] LST;              // Load/Store/Transfer Output Multiplexer

reg     SelA, SelX, SelY, SelS, SelP;   // Decoded Register Write Selects

wire    OV;                     // Arithmetic Unit Overflow Flag

///////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

// Q Multiplexer

assign W = ((QSel[0]) ? M : A);     // ? INC M/DEC M : Default
assign U = ((QSel[0]) ? Y : X);     // ? INY/DEY/CPY : INX/DEX/CPX
assign Q = ((QSel[1]) ? U : W);

// R Multiplexer

assign T = ((RSel) ? 8'h01 : M);    // ? INC/DEC     : ADC/SBC/CMP (default)
assign R = ((Sub)  ? ~T    : T);    // ? SBC/DEC/CMP : ADC/INC (default)

// Carry In Multiplexer

assign Ci = ((CSel) ? Sub : C);     // ? INC/DEC/CMP : ADC/SBC (default)

//  M65C02 Logic, Arithmetic, Shift, and Bit Unit Implementations

// Logic Unit Implementation

assign En_LU = (En & (Op[3:2] == 2'b00) & |Op[1:0]);

always @(*)
begin
    if(En_LU)
        case(Op[1:0])
            2'b01   : LU <= {1'b0, A & M};           // AND
            2'b10   : LU <= {1'b0, A | M};           // ORA
            default : LU <= {1'b0, A ^ M};           // EOR
        endcase
    else
        LU <= 0;
end

always @(*)
begin
    LU_Valid <= En_LU;
end

//  Binary Adder Unit Implementation (INC/INX/INY/DEC/DEX/DEY/CMP, ADC/SBC)

assign En_AU = (  (En & (  (Op == pALU_ADC) | (Op == pALU_SBC)) & ~D)
                | (En & (  (Op == pALU_INC)
                         | (Op == pALU_DEC)
                         | (Op == pALU_CMP))));

M65C02_BIN  BIN (
                .En(En_AU),
                .A(Q),
                .B(R),
                .Ci(Ci),
                .Out(AU),
                .OV(OV_AU),
                .Valid(AU_Valid)
            );

//  Decimal (BCD) Adder Unit Implementation (ADC/SBC (Decimal-Only))

assign En_DU = (En & ((Op == pALU_ADC) | (Op == pALU_SBC)) & D);

M65C02_BCD  BCD (
                .Rst(Rst),
                .Clk(Clk),
                .En(En_DU),
                .Op(Sub),
                .A(Q),
                .B(R),
                .Ci(Ci),
                .Out(DU),
                .OV(OV_DU),
                .Valid(DU_Valid)
            );

//  Multiplex Overflow based on the Adder used

assign OV = ((AU_Valid) ? OV_AU : OV_DU);

//  Shift Unit Implementation

assign En_SU = (En & (Op[3:2] == 2'b10));

always @(*)
begin
    if(En_SU)
        case(Op[1:0])
            2'b00 : SU <= {W[7], {W[6:0], 1'b0}};   // ASL
            2'b01 : SU <= {W[0], {1'b0, W[7:1]}};   // LSR
            2'b10 : SU <= {W[7], {W[6:0], C}};      // ROL
            2'b11 : SU <= {W[0], {C, W[7:1]}};      // ROR
        endcase
    else
        SU <= 0;
end

always @(*)
begin
    SU_Valid <= En_SU;
end

// Bit Unit Implementation

assign En_BU = (En & ((Op[3:2] == 2'b11) & ~(Op == pALU_CMP)));

always @(*)
begin
    if(En_BU)
        case(Op[1:0])
            2'b01   : BU <= {1'b0,  ~A & M};    // TRB
            2'b10   : BU <= {1'b0,   A | M};    // TSB
            default : BU <= {1'b0,   A & M};    // BIT
        endcase
    else
        BU <= 0;
end

always @(*)
begin
    BU_Valid <= En_BU;
end

//  Rockwell Unit 
//  Capabilities expanded to execute the Rockwell RSBx, SMBx, BBRx, and BBSx
//  instructions. The CCSel field is used to select the operation:
//      4 - SMBx; 4 - RMBx; 6 = BBSx; 7 - BBRx;
//  if(CCSel[4:2] == 1) one of the Rockwell instructions is being executed;
//  else a normal 65C02 instruction is being executed;
//
//  For the Rockwell instructions, the mask is not provided by the accumulator.
//  Instead, the mask is provided by least significant 8 bits of the fixed
//  microword, which was added as an additional input to the module.

assign En_RU = (CCSel[4:2] == 4'b001);

always @(*)
begin
    if(En_RU)
        case(CCSel[1:0])
            2'b00 : RU <= {1'b0, Msk |  M};    // SMBx
            2'b01 : RU <= {1'b0, Msk &  M};    // RMBx
            2'b10 : RU <= {1'b0, Msk &  M};    // BBSx
            2'b11 : RU <= {1'b0, Msk & ~M};    // BBRx
        endcase
    else
        RU <= 0;
end

always @(*) RU_Valid <= En_RU;

//  Load/Store/Transfer Enable

assign LST_En = ((Op == pALU_NOP) & ~(CCSel[4:2] == 4'b001));

//  Load/Store/Transfer Multiplexer

always @(*)
begin
    case(OSel)
        3'b000 : LST_Sel <= 6'b000_00_1;          // LDA/PLA/LDX/PLX/LDY/PLY/PLP
        3'b001 : LST_Sel <= 6'b100_00_0;          // STA/TAX/TAY/PHA
        3'b010 : LST_Sel <= 6'b010_00_0;          // STX/TXA/TXS/PHX
        3'b011 : LST_Sel <= 6'b001_00_0;          // STY/TYA/PHY
        3'b100 : LST_Sel <= 6'b000_00_0;          // STZ
        3'b101 : LST_Sel <= 6'b000_10_0;          // TSX
        3'b110 : LST_Sel <= 6'b000_01_0;          // PHP
        3'b111 : LST_Sel <= 6'b000_00_1;          // LDA/PLA/LDX/PLX/LDY/PLY/PLP
    endcase
end

always @(*)
begin
    if(LST_En)
        LST <= (  ((LST_Sel[5]) ? {1'b0, A} : 0)  // STA/TAX/TAY/PHA 
                | ((LST_Sel[4]) ? {1'b0, X} : 0)  // STX/TXA/TXS/PHX 
                | ((LST_Sel[3]) ? {1'b0, Y} : 0)  // STY/TYA/PHY
                | ((LST_Sel[2]) ? {1'b0, S} : 0)  // TSX 
                | ((LST_Sel[1]) ? {1'b0, P} : 0)  // PHP
                | ((LST_Sel[0]) ? {1'b0, M} : 0));// LDA/PLA/LDX/PLX/LDY/PLY/PLP
    else
        LST <= 0;                                 // STZ
end

always @(*) {COut, Out} <= LU | AU | DU | SU | BU | RU | LST;

//  Assign ALU (Result) Valid Output (removed pipeline register 12B04, mam)

assign Valid = |{LU_Valid, 
                 AU_Valid,
                 DU_Valid,
                 SU_Valid,
                 BU_Valid,
                 RU_Valid,
                 LST_En   };

//  Condition Code Output

always @(*)
begin
    case(CCSel)
        pBBR    : CC_Out <= |RU;    // Added for Rockwell instructions
        pBBS    : CC_Out <= |RU;    // Added for Rockwell instructions
        //
        pCC     : CC_Out <= ~C;
        pCS     : CC_Out <=  C;
        pNE     : CC_Out <= ~Z;
        pEQ     : CC_Out <=  Z;
        pVC     : CC_Out <= ~V;
        pVS     : CC_Out <=  V;
        pPL     : CC_Out <= ~N;
        pMI     : CC_Out <=  N;
        default : CC_Out <=  1;
    endcase 
end

///////////////////////////////////////////////////////////////////////////////
//  Internal ALU Registers
//

//  Decode Register Write Enables

always @(*)
begin
    casex({Reg_WE, WSel})
        6'b001xxx   : {SelA, SelX, SelY, SelS, SelP} <= 5'b1000_1;
        6'b100001   : {SelA, SelX, SelY, SelS, SelP} <= 5'b1000_1;
        6'b010xxx   : {SelA, SelX, SelY, SelS, SelP} <= 5'b0100_1;
        6'b100010   : {SelA, SelX, SelY, SelS, SelP} <= 5'b0100_1;
        6'b011xxx   : {SelA, SelX, SelY, SelS, SelP} <= 5'b0010_1;
        6'b100011   : {SelA, SelX, SelY, SelS, SelP} <= 5'b0010_1;
        6'b101xxx   : {SelA, SelX, SelY, SelS, SelP} <= 5'b0001_0;
        6'b100101   : {SelA, SelX, SelY, SelS, SelP} <= 5'b0001_0;
        6'b110xxx   : {SelA, SelX, SelY, SelS, SelP} <= 5'b0000_1;
        6'b100110   : {SelA, SelX, SelY, SelS, SelP} <= 5'b0000_1;
        6'b111xxx   : {SelA, SelX, SelY, SelS, SelP} <= 5'b0000_1;
        6'b100111   : {SelA, SelX, SelY, SelS, SelP} <= 5'b0000_1;
        default     : {SelA, SelX, SelY, SelS, SelP} <= 5'b0000_0;
    endcase
end

///////////////////////////////////////////////////////////////////////////////
//
//  A - Accumulator
//

assign WE_A = SelA & Valid & Rdy;

always @(posedge Clk)
begin
    if(Rst)
        A <= #1 0;
    else if(WE_A)
        A <= #1 Out;
end

///////////////////////////////////////////////////////////////////////////////
//
//  X - Pre-Index Register
//

assign WE_X = SelX & Valid & Rdy;

always @(posedge Clk)
begin
    if(Rst)
        X <= #1 0;
    else if(WE_X)
        X <= #1 Out;
end

///////////////////////////////////////////////////////////////////////////////
//
//  Y - Post-Index Register
//

assign WE_Y = SelY & Valid & Rdy;

always @(posedge Clk)
begin
    if(Rst)
        Y <= #1 0;
    else if(WE_Y)
        Y <= #1 Out;
end

///////////////////////////////////////////////////////////////////////////////
//
//  P - Processor Status Word: {N, V, 1, B, D, I, Z, C}
//

assign WE_P = SelP & Valid & Rdy;

always @(posedge Clk)
begin
    if(Rst)
        PSW <= #1 6'b00_0100;       // I set by default on Rst
    else if(ISR & Rdy)
        PSW <= #1 {N, V, 1'b0, 1'b1, Z, C};
    else if(WE_P) 
        case(CCSel)
            pCLC    : PSW <= #1 {     N,   V,   D,   I,        Z,1'b0};
            pSEC    : PSW <= #1 {     N,   V,   D,   I,        Z,1'b1};
            pCLI    : PSW <= #1 {     N,   V,   D,1'b0,        Z,   C};
            pSEI    : PSW <= #1 {     N,   V,   D,1'b1,        Z,   C};
            pCLD    : PSW <= #1 {     N,   V,1'b0,   I,        Z,   C};
            pSED    : PSW <= #1 {     N,   V,1'b1,   I,        Z,   C};
            pCLV    : PSW <= #1 {     N,1'b0,   D,   I,        Z,   C};
            //
            pZ      : PSW <= #1 {     N,   V,   D,   I,~|(A & M),   C};
            pNZ     : PSW <= #1 {Out[7],   V,   D,   I,    ~|Out,   C};
            pNZC    : PSW <= #1 {Out[7],   V,   D,   I,    ~|Out,COut};
            pNVZ    : PSW <= #1 {  M[7],M[6],   D,   I,~|(A & M),   C};
            pNVZC   : PSW <= #1 {Out[7],  OV,   D,   I,    ~|Out,COut};
            pPSW    : PSW <= #1 {Out[7:6], Out[3:0]};
            default : PSW <= #1 PSW;
        endcase
end

//  Decode PSW bits

assign N = PSW[5];  // Negative, nominally Out[7], but M[7] if BIT/TRB/TSB
assign V = PSW[4];  // oVerflow, nominally OV,     but M[6] if BIT/TRB/TSB
assign D = PSW[3];  // Decimal, set/cleared by SED/CLD, cleared on ISR entry
assign I = PSW[2];  // Interrupt Mask, set/cleared by SEI/CLI, set on ISR entry
assign Z = PSW[1];  // Zero, nominally ~|Out, but ~|(A&M) if BIT/TRB/TSB
assign C = PSW[0];  // Carry, set by ADC/SBC, and ASL/ROL/LSR/ROR instructions

//  Assign PSW bits to P (PSW output port)

assign P = {N, V, 1'b1, ((CCSel == pBRK) | (OSel == pSel_P)), D, I, Z, C};

///////////////////////////////////////////////////////////////////////////////
//
//  Stack Pointer
//

assign Ld_S = Rdy & (SelS & Valid);
assign CE_S = Rdy & StkOp[1];

always @(posedge Clk)
begin
    if(Rst)
        S <= #1 pStkPtr_Rst;
    else if(Ld_S)
        S <= #1 X;                          // TXS
    else if(CE_S)
        S <= #1 ((StkOp[0]) ? (S + 1)       // Pop
                            : (S - 1));     // Push
end

//  Assign StkPtr Multiplexer for Push (0) and Pop (1) operation
//      Synchronous operation removed, 12B04, mam

assign StkPtr = ((&StkOp) ? (S + 1) : S);   // Stack Addrs to MAR

endmodule
