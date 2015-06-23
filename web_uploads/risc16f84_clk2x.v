//---------------------------------------------------------------------------
// RISC 16F84 "clk2x" core
//
// This file is part of the "risc_16F84" project.
// http://www.opencores.org/cores/risc_16F84
// 
//
// Description: See description below (which suffices for IP core
//                                     specification document.)
//
// Copyright (C) 1999 Sumio Morioka (original VHDL design version)
// Copyright (C) 2001 John Clayton and OPENCORES.ORG (this Verilog version)
//
// NOTE: This source code is free for educational/hobby use only.  It cannot
// be used for commercial purposes without the consent of Microchip
// Technology incorporated.
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation;  either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source.
// If not, download it from http://www.opencores.org/lgpl.shtml
//
//---------------------------------------------------------------------------
//
// Author: John Clayton
// Date  : January 29, 2002
//
// (NOTE: Date formatted as day/month/year.)
// Update: 29/01/02 copied this file from memory_sizer.v (pared down).
//                  Translated the module and signal declarations.
//                  Transformed the instruction wires to lowercase.
//                  Transformed the addressing wires to lowercase.
// Update: 31/01/02 Translated the instruction decoder.
// Update:  5/02/02 Determined that stack is simply a circular buffer of
//                  8 locations, 13 bits per location.  Started translating
//                  "main_efsm" process.  Added all code from piccore.vhd
//                  into this file for eventual translation.  Concluded that
//                  "stack_full_node" is not needed.
// Update:  6/02/02 Translated the "ram_i_node" if/else precedural assignment.
// Update:  7/02/02 Changed all := to <=, changed all '0' to 0 and '1' to 1.
//                  Replaced all " downto " with ":".
//                  Finished translating QRESET state.
// Update: 20/02/02 Replaced all instances of Qreset with QRESET_PP.  Also
//                  replaced other state designations with their new names.
//                  Finished translating Q1, Q2 states.
// Update: 22/02/02 Translated section 2-4-1-1 (aluout register)
// Update: 27/02/02 Replaced all "or" with "||" in if statements
//                  Replaced all "and" with "&&" in if statements.
//                  Replaced all "not" with "~" in if statements.
//                  Finished translating Q3,Q4 states.
//                  Translated output signal assignments at end of code.
//                  Translated interrupt trigger processes.
// Update: 28/02/02 Finished translation of WDT and TMR0 prescaler.
//                  Trimmed line length to 80 characters throughout.
//                  Prepared to attempt initial syntax checking.
//                  Cleaned up some naming conventions, and verified that
//                  all I/O pins have _i or _o appended in the body of the
//                  code.
// Update: 03/04/02 Changed "progdata_i" to "prog_dat_i" Also changed
//                  "progadr_o" to "prog_adr_o"
// Update: 04/04/02 Created new file "risc16f84_lite.v"  This file is reduced
//                  and simplified from the original "risc16f84.v" file.
//                  Specifically, I am removing EEPROM support, and 
//                  consolidating porta and portb I/O pins so that they
//                  are bidirectional.
// Update: 04/04/02 Created a new file "risc16f84_small.v"  This file is
//                  further reduced and simplified from "risc16f84_lite.v"
//                  Specifically, I am removing the prescaler, TMR0 and WDT.
//                  Also, I am removing support for portb interrupts, leaving
//                  only rb0/int as an interrupt source.  This pin will be
//                  the only way to wake up from the SLEEP instruction...
//                  Obviously, the CLEARWDT instruction will no longer do
//                  anything.
// Update: 05/04/02 Removed the "powerdown_o", "startclk_o" and "clk_o" pins
//                  from the small design.  Also removed "rbpu_o", so if you
//                  want pullups, you have to add them explicitly in the
//                  constraints file, and option_reg[7] doesn't control them.
// Update: 08/04/02 Decided to modify "risc16f84_small.v" in order to try for
//                  more performance (only 2 states per instruction!)
//                  The new file is called "risc16f84_clk2x.v"  The resulting
//                  code was synthesized, but not tested yet.
// Update: 11/04/02 Decided to remove porta and portb from this unit, and add
//                  instead an auxiliary bus, which is intended to allow I/O
//                  using an indirect approach, similar to using the FSR.
//                  However, the aux_adr_o is 16 bits wide, so that larger
//                  RAM may be accessed indirectly by the processor... The use
//                  of FSR for this purpose proved undesirable, since any new
//                  page of RAM contains "holes" to accomodate the registers
//                  in the first 12 locations (including FSR!) so that large
//                  contiguous blocks of memory could not be accessed in an
//                  effective way.  This auxiliary bus solves that problem.
//                  Since this processor is implemented inside of an FPGA,
//                  and it is not a goal to maintain compatibility with
//                  existing libraries of code, there is no need to maintain
//                  porta and portb in the hardware.
//                  The aux_adr_lo and aux_adr_hi registers are located at
//                  88h and 89h, and the aux_dat_io location is decoded at
//                  08h.
//                  Also, changed to using "ram_we_o" instead of "readram_o"
//                  and "writeram_o"
// Update: 16/04/02 Added clock enable signal, for processor single stepping.
//                  "aux_dat_io" is only driven when "clk_en_i" is high...
// Update: 17/04/02 Removed "reset_condition" and moved "inc_pc_node" out of
//                  the clocking area, making it non-registered.  In fact, I
//                  moved everything other than the state machine out of the
//                  clocked logic section.  Changed "aluout_reg" to "aluout"
//                  since it is no longer registered.
// Update: 26/04/02 Fixed bug in aluout logic.  The AND and OR functions were
//                  coded with logical AND/OR instead of bitwise AND/OR!
// Update: 26/04/02 Changed location of aux_adr_lo and aux_adr_hi registers
//                  to 05h and 06h, respectively.  This was done to save
//                  code space because when using the aux data bus, no bank
//                  switching is necessary since they will now reside in the
//                  same bank.
// Update: 01/05/02 Fixed another bug -- the rrf and rlf instructions were
//                  coded incorrectly.
// Update: 03/05/02 Fixed another bug -- the carry bit was incorrect (the
//                  problem was discovered while performing SUBWF X,W where
//                  W contained 0 and X contained 1. (1-0).  The logic for
//                  the carry bit appears to have been incorrect even in
//                  the original VHDL code by Sumio Morioka.
// Update: 11/18/02 Fixed bug in PCL addressing mode (near line 791)
//                  Removed parameters associated with WDT.
// Update: 11/25/02 Re-wrote much of the main FSM.  Attempted to generate logic
//                  to recognize the falling edge of an interrupt, and was
//                  unsuccessful (not simulation, actual hardware tests.)
//                  Realized that falling edge interrupt can be equivalent to
//                  rising edge interrupt with a NOT gate on the signal.  Since
//                  NOTs are practically free inside of an FPGA, decided to
//                  abandon the negative edge aspect of recognizing interrupts.
//                  Therefore, removed the "option_reg" since it is no longer
//                  needed in this design.
// Update: 08/08/03 Fixed a mathematical error, which was introduced by the bug
//                  fix of 03/05/02.  The fix of 03/05/02 correctly generated the
//                  C bit for subtraction of zero, but unfortunately it introduced
//                  an error such that all subtraction results were off by 1.
//                  Obviously, this was unacceptable, and I think it has been fixed
//                  by the new signals "c_subtract_zero" and "c_dig_subtract_zero"
//
// Description
//---------------------------------------------------------------------------
// This logic module implements a small RISC microcontroller, with functions
// and instruction set very similar to those of the Microchip 16F84 chip.
// This work is a translation (from VHDL to Verilog) of the "CQPIC" design
// published in 1999 by Sumio Morioka of Japan, and published in the December
// 1999 issue of "Transistor Gijutsu Magazine."  The translation was performed
// by John Clayton, without the use of any translation tools.
//
// Original version used as basis for translation:  CQPIC version 1.00b
//                                                  (December 10, 2000)
//
// Further revisions and re-writing have been completed on this code by John
// Clayton.  The interrupt mechanism has been completely re-done, and the
// way in which the program counter is generated is expressed in a new way.
//
// In the comments, a "cycle" is defined as a processor cycle of 2 states.
// Thus, passing through states Q2_PP and Q4_PP completes one cycle.
// The numbers "1-3" and so forth are left from the comments in the original
// source code used as the basis of the translation.
//---------------------------------------------------------------------------

`define STATEBIT_SIZE 2      // Size of state machine register (bits)


module risc16f84_clk2x (
  prog_dat_i,           // [13:0] ROM read data
  prog_adr_o,           // [12:0] ROM address
  ram_dat_i,            // [7:0] RAM read data
  ram_dat_o,            // [7:0] RAM write data
  ram_adr_o,            // [8:0] RAM address; ram_adr[8:7] indicates RAM-BANK
  ram_we_o,             // RAM write strobe (H active)
  aux_adr_o,            // [15:0] Auxiliary address bus
  aux_dat_io,           // [7:0] Auxiliary data bus (tri-state bidirectional)
  aux_we_o,             // Auxiliary write strobe (H active)
  int0_i,               // PORT-B(0) INT
  reset_i,              // Power-on reset (H active)
  clk_en_i,             // Clock enable for all clocked logic
  clk_i                 // Clock input
);


// You can change the following parameters as you would like
parameter STACK_SIZE_PP      = 8;   // Size of PC stack
parameter LOG2_STACK_SIZE_PP = 3;   // Log_2(stack_size)

// State definitions for state machine, provided as parameters to allow
// for redefinition of state values by the instantiator if desired.
parameter Q2_PP     = 2'b00;  // state Q2
parameter Q4_PP     = 2'b01;  // state Q4
parameter QINT_PP   = 2'b10;  // interrupt state (substitute for Q4)
parameter QSLEEP_PP = 2'b11;  // sleep state


// I/O declarations

       // program ROM data bus/address bus
input  [13:0] prog_dat_i;   // ROM read data
output [12:0] prog_adr_o;   // ROM address

       // data RAM data bus/address bus/control signals
input  [7:0] ram_dat_i;     // RAM read data
output [7:0] ram_dat_o;     // RAM write data
output [8:0] ram_adr_o;     // RAM address; ram_adr[8:7] indicates RAM-BANK
output ram_we_o;            // RAM write strobe (H active)

       // auxiliary data bus/address bus/control signals
output [15:0] aux_adr_o;    // AUX address bus
inout  [7:0]  aux_dat_io;   // AUX data bus
output aux_we_o;            // AUX write strobe (H active)

       // interrupt input
input  int0_i;              // INT

       // CPU reset
input  reset_i;             // Power-on reset (H active)

       // CPU clock
input  clk_en_i;            // Clock enable input
input  clk_i;               // Clock input


// Internal signal declarations

     // User registers
reg  [7:0] w_reg;            // W
reg  [12:0] pc_reg;          // PCH/PCL -- Address currently being fetched
reg  [12:0] old_pc_reg;      // Address fetched previous to this one.
reg  [7:0] status_reg;       // STATUS
reg  [7:0] fsr_reg;          // FSR
reg  [4:0] pclath_reg;       // PCLATH
reg  [7:0] intcon_reg;       // INTCON
reg  [7:0] aux_adr_hi_reg;   // AUX address high byte
reg  [7:0] aux_adr_lo_reg;   // AUX address low byte

     // Internal registers for controlling instruction execution
reg  [13:0] inst_reg;        // Holds fetched op-code/operand
reg  [7:0]  aluinp1_reg;     // data source (1 of 2)
reg  [7:0]  aluinp2_reg;     // data source (2 of 2)
reg  exec_stall_reg;         // if H (i.e. after GOTO etc), stall execution.

     // Stack
                             // stack (array of data-registers)
reg  [12:0] stack_reg [STACK_SIZE_PP-1:0];
                             // stack pointer
reg  [LOG2_STACK_SIZE_PP-1:0] stack_pnt_reg;
wire [12:0] stack_top;       // More compatible with sensitivity list than
                             // "stack_reg[stack_pnt_reg]"

     // Interrupt registers/nodes
wire int_condition;          // Indicates that an interrupt should be recognized
wire intrise;                // High indicates edge was detected
reg  intrise_reg;            // detect positive edge of PORT-B inputs
     // Synchronizer for interrupt
reg  inte_sync_reg;

     // State register
reg  [`STATEBIT_SIZE-1:0] state_reg;
reg  [`STATEBIT_SIZE-1:0] next_state_node;

     // Result of decoding instruction -- only 1 is active at a time
wire inst_addlw;
wire inst_addwf;
wire inst_andlw;
wire inst_andwf;
wire inst_bcf;
wire inst_bsf;
wire inst_btfsc;
wire inst_btfss;
wire inst_call;
wire inst_clrf;
wire inst_clrw;
wire inst_comf;
wire inst_decf;
wire inst_decfsz;
wire inst_goto;
wire inst_incf;
wire inst_incfsz;
wire inst_iorlw;
wire inst_iorwf;
wire inst_movlw;
wire inst_movf;
wire inst_movwf;
wire inst_retfie;
wire inst_retlw;
wire inst_ret;
wire inst_rlf;
wire inst_rrf;
wire inst_sleep;
wire inst_sublw;
wire inst_subwf;
wire inst_swapf;
wire inst_xorlw;
wire inst_xorwf;

     // Result of calculating RAM access address
wire [8:0] ram_adr_node;      // RAM access address

     // These wires indicate accesses to special registers... 
     // Only 1 is active at a time.
wire addr_pcl;
wire addr_stat;
wire addr_fsr;
wire addr_pclath;
wire addr_intcon;
wire addr_aux_adr_lo;
wire addr_aux_adr_hi;
wire addr_aux_dat;
wire addr_sram;

     // Other output registers (for removing hazards)
reg  ram_we_reg;          // data-sram write strobe
reg  aux_we_reg;          // AUX write strobe


     // Signals used in "main_efsm" procedure
     // (Intermediate nodes used for resource sharing.)
wire [7:0]  ram_i_node;    // result of reading RAM/Special registers
wire [7:0]  mask_node;     // bit mask for logical operations
wire [8:0]  add_node;      // result of 8bit addition
wire [4:0]  addlow_node;   // result of low-4bit addition
wire aluout_zero_node;    // H if ALUOUT = 0

reg  [12:0] next_pc_node;  // value of next PC
reg  [7:0] aluout;        // result of calculation
reg  writew_node;         // H if destination is W register
reg  writeram_node;       // H if destination is RAM/Special registers
reg  c_subtract_zero;     // High for special case of C bit, when subtracting zero
reg  c_dig_subtract_zero; // High for special case of C bit, when subtracting zero

wire next_exec_stall;

//--------------------------------------------------------------------------
// Instantiations
//--------------------------------------------------------------------------


//--------------------------------------------------------------------------
// Functions & Tasks
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Module code
//--------------------------------------------------------------------------

// This represents the instruction fetch from program memory.
// inst_reg[13:0] stores the instruction.  This happens at the end of Q4.
// So the memory access time is one processor cycle (2 clocks!) minus
// the setup-time of this register, and minus the delay to drive the 
// address out onto the prog_adr_o bus.
always @(posedge clk_i)
begin
  if (reset_i) inst_reg <= 0;
  else if (clk_en_i && (state_reg == Q4_PP)) inst_reg <= prog_dat_i;
end

// NOTE: There is an extra "15th" bit of inst_reg, which represents an
// interrupt execution cycle.  This is included in inst_reg so that when
// an interrupt instruction is executing, it effectively "pre-empts" the
// other instructions.
// The fifteenth bit, inst_reg[14], is set by the interrupt logic.

// Decode OPcode    (see pp.54 of PIC16F84 data sheet)
// only 1 signal of the following signals will be '1'
assign inst_call    = (inst_reg[13:11] ==  3'b100           );
assign inst_goto    = (inst_reg[13:11] ==  3'b101           );
assign inst_bcf     = (inst_reg[13:10] ==  4'b0100          );
assign inst_bsf     = (inst_reg[13:10] ==  4'b0101          );
assign inst_btfsc   = (inst_reg[13:10] ==  4'b0110          );
assign inst_btfss   = (inst_reg[13:10] ==  4'b0111          );
assign inst_movlw   = (inst_reg[13:10] ==  4'b1100          );
assign inst_retlw   = (inst_reg[13:10] ==  4'b1101          );
assign inst_sublw   = (inst_reg[13:9]  ==  5'b11110         );
assign inst_addlw   = (inst_reg[13:9]  ==  5'b11111         );
assign inst_iorlw   = (inst_reg[13:8]  ==  6'b111000        );
assign inst_andlw   = (inst_reg[13:8]  ==  6'b111001        );
assign inst_xorlw   = (inst_reg[13:8]  ==  6'b111010        );
assign inst_subwf   = (inst_reg[13:8]  ==  6'b000010        );
assign inst_decf    = (inst_reg[13:8]  ==  6'b000011        );
assign inst_iorwf   = (inst_reg[13:8]  ==  6'b000100        );
assign inst_andwf   = (inst_reg[13:8]  ==  6'b000101        );
assign inst_xorwf   = (inst_reg[13:8]  ==  6'b000110        );
assign inst_addwf   = (inst_reg[13:8]  ==  6'b000111        );
assign inst_movf    = (inst_reg[13:8]  ==  6'b001000        );
assign inst_comf    = (inst_reg[13:8]  ==  6'b001001        );
assign inst_incf    = (inst_reg[13:8]  ==  6'b001010        );
assign inst_decfsz  = (inst_reg[13:8]  ==  6'b001011        );
assign inst_rrf     = (inst_reg[13:8]  ==  6'b001100        );
assign inst_rlf     = (inst_reg[13:8]  ==  6'b001101        );
assign inst_swapf   = (inst_reg[13:8]  ==  6'b001110        );
assign inst_incfsz  = (inst_reg[13:8]  ==  6'b001111        );
assign inst_movwf   = (inst_reg[13:7]  ==  7'b0000001       );
assign inst_clrw    = (inst_reg[13:7]  ==  7'b0000010       );
assign inst_clrf    = (inst_reg[13:7]  ==  7'b0000011       );
assign inst_ret     = (inst_reg[13:0]  == 14'b00000000001000);
assign inst_retfie  = (inst_reg[13:0]  == 14'b00000000001001);
assign inst_sleep   = (inst_reg[13:0]  == 14'b00000001100011);


// Calculate RAM access address (see pp.19 of PIC16F84 data sheet)

    // if "d"=0, indirect addressing is used, so RAM address is BANK+FSR
    // otherwise, RAM address is BANK+"d"
    // (see pp.19 of PIC16F84 data sheet)
assign ram_adr_node = (inst_reg[6:0]==0)?{status_reg[7],fsr_reg[7:0]}:
                               {status_reg[6:5],inst_reg[6:0]};

    // check if this is an access to external RAM or not
assign addr_sram   = (ram_adr_node[6:0] > 7'b0001011); //0CH-7FH,8CH-FFH

    // check if this is an access to special register or not
    // only 1 signal of the following signals will be '1'
assign addr_pcl     = (ram_adr_node[6:0] ==  7'b0000010);    // 02H, 82H
assign addr_stat    = (ram_adr_node[6:0] ==  7'b0000011);    // 03H, 83H
assign addr_fsr     = (ram_adr_node[6:0] ==  7'b0000100);    // 04H, 84H
assign addr_aux_dat = (ram_adr_node[7:0] == 8'b00001000);    // 08H
assign addr_pclath  = (ram_adr_node[6:0] ==  7'b0001010);    // 0AH, 8AH
assign addr_intcon  = (ram_adr_node[6:0] ==  7'b0001011);    // 0BH, 8BH
assign addr_aux_adr_lo = (ram_adr_node[7:0] == 8'b00000101); // 05H
assign addr_aux_adr_hi = (ram_adr_node[7:0] == 8'b00000110); // 06H

// construct bit-mask for logical operations and bit tests
assign mask_node = 1 << inst_reg[9:7];

// Create the exec_stall signal, based on the contents of the currently
// executing instruction (inst_reg).  next_exec_stall reflects the state
// to assign to exec_stall following the conclusion of the next Q4 state.
// All of these instructions cause an execution stall in the next cycle
// because they modify the program counter, and a new value is presented
// for fetching during the stall cycle, during which time no instruction
// should be executed.
//
// The conditional instructions are given along with their conditions for
// execution.  If the conditions are not met, there is no stall and nothing
// to execute.
assign next_exec_stall = (
                             inst_goto
                          || inst_call
                          || inst_ret
                          || inst_retlw
                          || inst_retfie
                          || (
                              (inst_btfsc || inst_decfsz || inst_incfsz) 
                              && aluout_zero_node
                              )
                          || (inst_btfss && ~aluout_zero_node)
                          || (addr_pcl && writeram_node)
                          );
always @(posedge clk_i)
begin
  if (reset_i) exec_stall_reg <= 0;
  else if (clk_en_i && (state_reg == QINT_PP)) exec_stall_reg <= 1;
  else if (clk_en_i && (state_reg == Q4_PP))
    exec_stall_reg <= (next_exec_stall && ~exec_stall_reg);
    // exec stall should never be generated during a stall cycle, because
    // a stall cycle doesn't execute anything...
end

assign stack_top = stack_reg[stack_pnt_reg];
// Formulate the next pc_reg value (the program counter.)
// During stall cycles, the pc is simply incremented...
always @(
            pc_reg
         or pclath_reg
         or aluout
         or stack_pnt_reg
         or stack_top
         or inst_ret
         or inst_retlw
         or inst_retfie
         or inst_goto
         or inst_call
         or inst_reg
         or writeram_node
         or addr_pcl
         or exec_stall_reg
         )
begin
  if (~exec_stall_reg &&(inst_ret || inst_retlw || inst_retfie))
    next_pc_node <= stack_top;
  else if (~exec_stall_reg &&(inst_goto || inst_call))
    next_pc_node <= {pclath_reg[4:3],inst_reg[10:0]};
  else if (~exec_stall_reg && (writeram_node && addr_pcl))
    // PCL is data-destination, but update the entire PC.
    next_pc_node <= {pclath_reg[4:0],aluout};
  else
    next_pc_node <= pc_reg + 1;
end

// Set the program counter
// If the sleep instruction is executing, then the PC is not allowed to be
// updated, since the processor will "freeze" and the instruction being fetched
// during the sleep instruction must be executed upon wakeup interrupt.
// Obviously, if the PC were to change at the end of the sleep instruction, then
// a different (incorrect) address would be fetched during the sleep time.
always @(posedge clk_i)
begin
  if (reset_i) begin
    pc_reg <= 0;
    old_pc_reg <= 0;
  end
  else if (clk_en_i && (state_reg == QINT_PP))
  begin
    old_pc_reg <= pc_reg;
    pc_reg <= 4;
  end
  else if (clk_en_i && ~inst_sleep && (state_reg == Q4_PP))
  begin
    old_pc_reg <= pc_reg;
    pc_reg <= next_pc_node;
  end
end

// 1. Intermediate nodes for resource sharing

// Tri-state drivers instead of a huge selector...  It produces smaller
// results, and runs faster.
assign ram_i_node = (addr_sram)       ?ram_dat_i:8'bZ;
assign ram_i_node = (addr_pcl)        ?pc_reg[7:0]:8'bZ;
assign ram_i_node = (addr_stat)       ?status_reg:8'bZ;
assign ram_i_node = (addr_fsr)        ?fsr_reg:8'bZ;
assign ram_i_node = (addr_aux_dat)    ?aux_dat_io:8'bZ;
assign ram_i_node = (addr_pclath)     ?{3'b0,pclath_reg}:8'bZ;
assign ram_i_node = (addr_intcon)     ?intcon_reg:8'bZ;
assign ram_i_node = (addr_aux_adr_lo) ?aux_adr_lo_reg:8'bZ;
assign ram_i_node = (addr_aux_adr_hi) ?aux_adr_hi_reg:8'bZ;

// 1-3. Adder (ALU)
// full 8bit-addition, with carry in/out.
// Note that "temp" and "dtemp" are intended to be thrown away.
// Also, addlow_node[3:0] are thrown away.
// Even though they are assigned, they should never be used.
assign add_node     =    {1'b0,aluinp1_reg} 
                       + {1'b0,aluinp2_reg};
// lower 4bit-addition
assign addlow_node =    {1'b0,aluinp1_reg[3:0]} 
                      + {1'b0,aluinp2_reg[3:0]};

// 1-4. Test if aluout = 0
assign aluout_zero_node = (aluout == 0)?1:0;

// 1-5. Determine destination
always @(
            inst_reg
         or inst_movwf
         or inst_bcf
         or inst_bsf
         or inst_clrf
         or inst_movlw
         or inst_addlw
         or inst_sublw
         or inst_andlw
         or inst_iorlw
         or inst_xorlw
         or inst_retlw
         or inst_clrw
         or inst_movf
         or inst_swapf
         or inst_addwf
         or inst_subwf
         or inst_andwf
         or inst_iorwf
         or inst_xorwf
         or inst_decf
         or inst_incf
         or inst_rlf
         or inst_rrf
         or inst_decfsz
         or inst_incfsz
         or inst_comf
         )
begin
  if (inst_movwf || inst_bcf || inst_bsf || inst_clrf)
  begin
    writew_node     <= 0;
    writeram_node   <= 1;
  end
  else if (   inst_movlw || inst_addlw || inst_sublw || inst_andlw 
           || inst_iorlw || inst_xorlw || inst_retlw || inst_clrw)
  begin
    writew_node     <= 1;
    writeram_node   <= 0;
  end
  else if (   inst_movf   || inst_swapf || inst_addwf || inst_subwf
           || inst_andwf  || inst_iorwf || inst_xorwf || inst_decf 
           || inst_incf   || inst_rlf   || inst_rrf   || inst_decfsz 
           || inst_incfsz || inst_comf)
  begin
    writew_node     <= ~inst_reg[7];  // ("d" field of fetched instruction)
    writeram_node   <=  inst_reg[7];  // ("d" field of fetched instruction)
  end
  else
  begin
    writew_node     <= 0;
    writeram_node   <= 0;
  end
end // End of determine destination logic




// 2-4-1. Calculation and store result into alu-output register

always @(
            add_node
         or aluinp1_reg
         or aluinp2_reg
         or status_reg
         or inst_reg
         or inst_movwf
         or inst_bcf
         or inst_bsf
         or inst_btfsc
         or inst_btfss
         or inst_clrf
         or inst_addlw
         or inst_sublw
         or inst_andlw
         or inst_iorlw
         or inst_xorlw
         or inst_retlw
         or inst_clrw
         or inst_swapf
         or inst_addwf
         or inst_subwf
         or inst_andwf
         or inst_iorwf
         or inst_xorwf
         or inst_decf
         or inst_incf
         or inst_rlf
         or inst_rrf
         or inst_decfsz
         or inst_incfsz
         or inst_comf
         )
begin
  // 2-4-1-1. Set aluout register
          // Rotate left
  if      (inst_rlf) 
          aluout <= {aluinp1_reg[6:0],status_reg[0]};
          // Rotate right
  else if (inst_rrf) 
          aluout  <= {status_reg[0],aluinp1_reg[7:1]};
          // Swap nibbles
  else if (inst_swapf)
          aluout <= {aluinp1_reg[3:0],aluinp1_reg[7:4]};
          // Logical inversion
  else if (inst_comf)
          aluout  <= ~aluinp1_reg;
          // Logical AND, bit clear/bit test
  else if (   inst_andlw || inst_andwf || inst_bcf || inst_btfsc
           || inst_btfss) 
          aluout  <= (aluinp1_reg & aluinp2_reg);
          // Logical OR, bit set
  else if (inst_bsf || inst_iorlw || inst_iorwf)
          aluout  <= (aluinp1_reg | aluinp2_reg);
          // Logical XOR
  else if (inst_xorlw || inst_xorwf)
          aluout  <= (aluinp1_reg ^ aluinp2_reg);
          // Addition, Subtraction, Increment, Decrement
  else if (  inst_addlw || inst_addwf  || inst_sublw || inst_subwf
           || inst_decf || inst_decfsz || inst_incf  || inst_incfsz)
          aluout  <= add_node[7:0];
          // Pass through
  else aluout  <= aluinp1_reg;
end


// MAIN EFSM: description of register value changes in each clock cycle
always @(posedge clk_i)
begin
  // Assign reset (default) values of registers
  if (reset_i)
  begin
    status_reg[7:5] <= 3'b0;
    pclath_reg      <= 0;     // 0
    intcon_reg[7:1] <= 7'b0;
    aux_adr_lo_reg  <= 0;
    aux_adr_hi_reg  <= 0;
    ram_we_reg      <= 0;
    status_reg[4]   <= 1;     // /T0 = 1
    status_reg[3]   <= 1;     // /PD = 1
    stack_pnt_reg   <= 0;     // Reset stack pointer
  end  // End of reset assignments
  else if (~exec_stall_reg && clk_en_i) 
  begin   // Execution ceases during a stall cycle.
    if (state_reg == Q2_PP) // 2-3. Q2 cycle
    begin
      // 2-3-1. Read data-RAM and store values to alu-input regs
      // 2-3-1-1. Set aluinp1 register (source #1)
      if (   inst_movf   || inst_swapf || inst_addwf || inst_subwf
          || inst_andwf  || inst_iorwf || inst_xorwf || inst_decf
          || inst_incf   || inst_rlf   || inst_rrf   || inst_bcf
          || inst_bsf    || inst_btfsc || inst_btfss || inst_decfsz
          || inst_incfsz || inst_comf)

          aluinp1_reg <= ram_i_node;       // RAM/Special registers
      else
      if (   inst_movlw || inst_addlw || inst_sublw || inst_andlw
          || inst_iorlw || inst_xorlw || inst_retlw)
          aluinp1_reg <= inst_reg[7:0];    // Immediate value ("k")
      else
      if (   inst_clrf  || inst_clrw) aluinp1_reg <= 0; // 0
      else aluinp1_reg <= w_reg;                        // W register

      // 2-3-1-2. Set aluinp2 register (source #2)
      c_subtract_zero <= 0;       // default to non-special case
      c_dig_subtract_zero <= 0;   // default to non-special case
      if      (inst_decf || inst_decfsz) aluinp2_reg <= -1; // for decr.
      else if (inst_incf || inst_incfsz) aluinp2_reg <=  1; // for incr.
              // -1 * W register (for subtract)
      else if (inst_sublw || inst_subwf) 
      begin
        aluinp2_reg <= ~w_reg + 1;
        c_subtract_zero <= (w_reg == 0);            // Indicate special case
        c_dig_subtract_zero <= (w_reg[3:0] == 0);   // Indicate special case
      end
            // operation of BCF: AND with inverted mask ("1..101..1")
            // mask for BCF: value of only one position is 0
      else if (inst_bcf) aluinp2_reg <= ~mask_node; 
            // operation of BSF: OR with mask_node ("0..010..0")
            // operation of FSC and FSS: AND with mask_node, compare to 0
      else if (inst_btfsc || inst_btfss || inst_bsf)
                                  aluinp2_reg <= mask_node;
      else aluinp2_reg <= w_reg; // W register

      // 2-3-1-3. Set stack pointer register (pop stack)
      if (inst_ret || inst_retlw || inst_retfie)
           stack_pnt_reg   <= stack_pnt_reg - 1; // cycles 3,2,1,0,7,6...

      // 2-4-1-3. Set data-SRAM write enable (hazard-free)
      // Set the write enables depending on the destination.
      // (These have been implemented as registers to avoid glitches?
      // It is not known to me (John Clayton) whether any glitches would
      // really occur.  It might be possible to generate these signals
      // using combinational logic only, without using registers!
      ram_we_reg <= (writeram_node && addr_sram);
      aux_we_reg <= (writeram_node && addr_aux_dat);
    end   // End of Q2 state
    
    //---------------------------------------------------------------------
    
    else if (state_reg == QINT_PP) // Interrupt execution (instead of Q4_PP)
    begin
        // PORT-B0 INT
        intcon_reg[1] <= 1;                     // set INTF
        intcon_reg[7] <= 0;                     // clear GIE
        stack_reg[stack_pnt_reg] <= old_pc_reg; // Push old PC
        stack_pnt_reg <= stack_pnt_reg + 1;     // increment stack pointer
        // The old PC is pushed, so that the pre-empted instruction can be
        // restarted later, when the retfie is executed.
    end

    //---------------------------------------------------------------------

    else if (state_reg == Q4_PP)   // Execution & writing of results.
    begin

      if (inst_call)
      begin
        stack_reg[stack_pnt_reg] <= pc_reg;     // Push current PC
        stack_pnt_reg <= stack_pnt_reg + 1;     // increment stack pointer
      end

      if (inst_retfie) // "return from interrupt" instruction
      begin
        intcon_reg[7] <= 1;                     // Set GIE
      end

      // 2-4-1-2. Set C flag and DC flag
      if (inst_addlw || inst_addwf || inst_sublw || inst_subwf)
      begin
        // c_dig_subtract_zero and c_subtract_zero are used to take care of the
        // special case when subtracting zero, where the carry bit should be 1
        // (meaning no borrow).  It is explicitly set by these signals during
        // that condition.  See 16F84 datasheet, page 8 for further information
        // about the C bit.
        status_reg[1]   <= addlow_node[4] || c_dig_subtract_zero;  // DC flag
        status_reg[0]   <= add_node[8] || c_subtract_zero;         // C flag
      end
      else if (inst_rlf) status_reg[0] <= aluinp1_reg[7];  // C flag
      else if (inst_rrf) status_reg[0] <= aluinp1_reg[0];  // C flag

      // 2-5-2. Store calculation result into destination, 
      // 2-5-2-1. Set W register

      if (writew_node) w_reg   <= aluout;    // write W reg

      // 2-5-2-2. Set data RAM/special registers,
      if (writeram_node)
      begin
        if (addr_stat)
        begin
          status_reg[7:5] <= aluout[7:5];      // write IRP,RP1,RP0
          // status(4),status(3)...unwritable, see below (/PD,/T0 part)
          status_reg[1:0] <= aluout[1:0];      // write DC,C
        end
        if (addr_fsr)         fsr_reg <= aluout;       // write FSR
        if (addr_pclath)   pclath_reg <= aluout[4:0];  // write PCLATH
        if (addr_intcon) intcon_reg <= aluout;         // write INTCON
        if (addr_aux_adr_lo) aux_adr_lo_reg <= aluout; // write AUX low
        if (addr_aux_adr_hi) aux_adr_hi_reg <= aluout; // write AUX high
      end

      // 2-5-2-3. Set/clear Z flag.
      if (addr_stat) status_reg[2] <= aluout[2]; // (dest. is Z flag)
      else if (   inst_addlw || inst_addwf || inst_andlw || inst_andwf
               || inst_clrf  || inst_clrw  || inst_comf  || inst_decf
               || inst_incf  || inst_movf  || inst_sublw || inst_subwf
               || inst_xorlw || inst_xorwf || inst_iorlw || inst_iorwf )
              status_reg[2] <= aluout_zero_node; // Z=1 if result == 0

      // 2-5-3. Clear RAM write enables (hazard-free)
      ram_we_reg <= 0;
      aux_we_reg <= 0;

    end    // End of Q4 state
  end // End of "if (~exec_stall_reg)"    
end  // End of process


// Calculation of next processor state.
// (Not including reset conditions, which are covered by the clocked logic,
//  which also includes a "global clock enable."
always @(
            state_reg
         or inst_sleep
         or inte_sync_reg
         or exec_stall_reg
         or int_condition
         )
begin
  case (state_reg)
  Q2_PP     : if (int_condition) next_state_node <= QINT_PP;
              else next_state_node <= Q4_PP;
  Q4_PP     : if (~exec_stall_reg && inst_sleep) next_state_node <= QSLEEP_PP;
              else next_state_node <= Q2_PP;
  QINT_PP   : next_state_node <= Q2_PP;
  QSLEEP_PP : if (inte_sync_reg) next_state_node <= Q2_PP;
              else next_state_node <= QSLEEP_PP;
              // Default condition provided for convention and completeness
              // only.  Logically, all of the conditions are already covered.
  default   : next_state_node <= Q2_PP;
  endcase
end


// Clocked state transitions, based upon dataflow (non-clocked logic) in
// the previous always block.
always @(posedge clk_i)
begin
  if (reset_i) state_reg <= Q2_PP;
  else if (clk_en_i) state_reg <= next_state_node;
end  // End of process


// Detect external interrupt requests
// You can code multiple interrupts if you wish, or use the single interrupt
// provided and simply have the interrupt service routine (ISR) check to find
// out the source of the interrupt, by or-ing together all of the interrupt
// sources and providing a readable register of their values at the time
// the interrupt occurred.
//
// When an interrupt is recognized by the processor, this is signified by
// entering "QINT_PP," which is treated like an executable instruction.
// The interrupt instruction can only be executed when not in a stall condition.
// It simply "pre-empts" the instruction that would have been executed during
// that cycle.  Then, when retfie is executed, the pre-empted instruction is
// re-started (the stall cycle of the retfie is when the address of the 
// instruction being re-started is fetched.)
//
// I was unable to obtain correct operation for capturing the negative edge,
// so I am discarding it.  If one really needs to generate an interrupt on the
// falling edge, just use an inverted version of the signal (the inversion is
// often "free" inside of an FPGA anyhow.)
//
// Upon further testing, I discovered that even the rising edge "trigger" was not
// really truly an edge detection, it was more like a "set-reset" flip flop
// type of behavior.  Rather than mess around with it any more, I am implementing
// a clocked "poor man's rising edge detector."
// Capture the rising edge of the interrupt input...  This part is self clearing.
// It also means that the interrupt must last longer than one clock cycle in
// order to be properly recognized.  (It is "pseudo edge triggered", not a true
// rising edge trigger.)
// When the interrupt is recognized, inte_sync_reg is cleared.


always @(posedge clk_i)
begin
  if (clk_en_i) intrise_reg <= int0_i;
end // process
assign intrise = (int0_i && ~intrise_reg);

//  The inte_sync_reg signal is used for waking up from SLEEP.
//  (this flip flop is also a synchronizer to minimize the
//   possibility of metastability due to changes at the input
//   occurring at the same time as the processor clock edge...)
//  It might be possible to eliminate this step, and issue the interrupt
//  directly without this intermediate synchronizer flip-flop.
always @(posedge clk_i)
begin
  if (reset_i || (state_reg == QINT_PP)) inte_sync_reg <= 0;
  else if (clk_en_i && intrise && intcon_reg[4]) inte_sync_reg <= 1;
end

// Issue an interrupt when the interrupt is present.
// Also, do not issue an interrupt when there is a stall cycle coming!
assign int_condition = (inte_sync_reg && ~exec_stall_reg && intcon_reg[7]);
                               // Interrupt must be pending
                               // Next processor cycle must not be a stall
                               // GIE bit must be set to issue interrupt

// Circuit's output signals
assign prog_adr_o = pc_reg;        // program ROM address
assign ram_adr_o  = ram_adr_node;  // data RAM address
assign ram_dat_o  = aluout;        // data RAM write data
assign ram_we_o   = ram_we_reg;    // data RAM write enable

assign aux_adr_o  = {aux_adr_hi_reg,aux_adr_lo_reg};
assign aux_dat_io = (aux_we_reg && clk_en_i)?aluout:{8{1'bZ}};
assign aux_we_o   = aux_we_reg;

endmodule


//`undef STATEBIT_SIZE