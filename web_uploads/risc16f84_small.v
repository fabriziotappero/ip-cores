//---------------------------------------------------------------------------
// RISC 16F84 "small" core
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
// Update: 26/04/02 Fixed bug in aluout_reg logic, so that bitwise operators
//                  are used for AND/OR.  (They had been wrongly coded using
//                  logical operators!)
// Update: 01/05/02 Fixed another bug -- the rrf and rlf instructions were
//                  coded incorrectly.
// Update: 03/05/02 Fixed another bug -- the carry bit was incorrect (the
//                  problem was discovered while performing SUBWF X,W where
//                  W contained 0 and X contained 1. (1-0).  The logic for
//                  the carry bit appears to have been incorrect even in
//                  the original VHDL code by Sumio Morioka.
// Update: 10/30/02 Fixed syntax error pointed out by Cheol-Kyoo Lee, who got
//                  the source code from opencores.com.  Removed semicolon
//                  from "endcase" statements.
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
//---------------------------------------------------------------------------

`define STATEBIT_SIZE 3      // Size of state machine register (bits)


module risc16f84_small (
  prog_dat_i,           // [13:0] ROM read data
  prog_adr_o,           // [12:0] ROM address
  ram_dat_i,            // [7:0] RAM read data
  ram_dat_o,            // [7:0] RAM write data
  ram_adr_o,            // [8:0] RAM address; ram_adr[8:7] indicates RAM-BANK
  readram_o,            // RAM read strobe (H active)
  writeram_o,           // RAM write strobe (H active)
  porta_io,             // [4:0] PORT-A
  portb_io,             // [7:0] PORT-B
  int0_i,               // PORT-B(0) INT
  pon_rst_n_i,          // Power-on reset (L active)
  clk_i                 // Clock input
);


// You can change the following parameters as you would like
parameter STACK_SIZE_PP      = 8;   // Size of PC stack
parameter LOG2_STACK_SIZE_PP = 3;   // Log_2(stack_size)
parameter WDT_SIZE_PP        = 255; // Size of watch dog timer (WDT)
parameter WDT_BITS_PP        = 8;   // Bits needed for watch dog timer (WDT)

// State definitions for state machine, provided as parameters to allow
// for redefinition of state values by the instantiator if desired.
parameter QRESET_PP = 3'b100; // reset state
parameter Q1_PP     = 3'b000; // state Q1
parameter Q2_PP     = 3'b001; // state Q2
parameter Q3_PP     = 3'b011; // state Q3
parameter Q4_PP     = 3'b010; // state Q4


// I/O declarations

       // program ROM data bus/address bus
input  [13:0] prog_dat_i;   // ROM read data
output [12:0] prog_adr_o;   // ROM address

       // data RAM data bus/address bus/control signals
input  [7:0] ram_dat_i;     // RAM read data
output [7:0] ram_dat_o;     // RAM write data
output [8:0] ram_adr_o;     // RAM address; ram_adr[8:7] indicates RAM-BANK
output readram_o;           // RAM read  strobe (H active)
output writeram_o;          // RAM write strobe (H active)

       // I/O ports
inout  [4:0] porta_io;      // PORT-A
inout  [7:0] portb_io;      // PORT-B

       // PORT-B interrupt input
input  int0_i;              // PORT-B(0) INT

       // CPU reset
input  pon_rst_n_i;         // Power-on reset (LOW active)

       // CPU clock
input  clk_i;               // Clock input


// Internal signal declarations

     // User registers
reg  [7:0] w_reg;            // W
reg  [12:0] pc_reg;          // PCH/PCL
reg  [7:0] status_reg;       // STATUS
reg  [7:0] fsr_reg;          // FSR
reg  [4:0] porta_i_sync_reg; // PORTA IN (synchronizer)
reg  [4:0] porta_o_reg;      // PORTA OUT
reg  [7:0] portb_i_sync_reg; // PORTB IN (synchronizer)
reg  [7:0] portb_o_reg;      // PORTB OUT
reg  [4:0] pclath_reg;       // PCLATH
reg  [7:0] intcon_reg;       // INTCON
reg  [7:0] option_reg;       // OPTION
reg  [4:0] trisa_reg;        // TRISA
reg  [7:0] trisb_reg;        // TRISB

     // Internal registers for controlling instruction execution
reg  [13:0] inst_reg;        // Hold fetched op-code/operand
reg  [7:0] aluinp1_reg;      // data source (1 of 2)
reg  [7:0] aluinp2_reg;      // data source (2 of 2)
reg        c_in;             // Used with ALU data sources.
reg  [7:0] aluout_reg;       // result of calculation
reg  exec_op_reg;            // if L (i.e. GOTO instruction etc), stall exec.
reg  intstart_reg;           // if H (i.e. interrupt), stall instr. exec.
reg  sleepflag_reg;          // if H, sleeping.

     // Stack
                             // stack (array of data-registers)
reg  [12:0] stack_reg [STACK_SIZE_PP-1:0];
                             // stack pointer (binary encoded)
reg  [LOG2_STACK_SIZE_PP-1:0] stack_pnt_reg;

     // Interrupt registers/nodes
reg  intrise_reg;            // detect positive edge of PORT-B inputs
reg  intdown_reg;            // detect negative edge of PORT-B inputs

wire rb0_int;                // Interrupt trigger

wire inte;                    // RB0   interrupt trigger
reg  intclr_reg;              // CPU; clear intrise_reg and intdown_reg

     // State register
reg  [`STATEBIT_SIZE-1:0] state_reg;

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
wire addr_porta;
wire addr_portb;
wire addr_pclath;
wire addr_intcon;
wire addr_option;
wire addr_trisa;
wire addr_trisb;
wire addr_sram;

     // Other output registers (for removing hazards)
reg  writeram_reg;      // data-sram write strobe
reg  [8:0] ram_adr_reg; // data-sram address

     // Synchronizers
reg  inte_sync_reg;
reg  reset_condition;

     // Signals used in "main_efsm" procedure
     // (Intermediate nodes used for resource sharing.)
reg  [7:0] ram_i_node;   // result of reading RAM/Special registers
reg  [12:0] inc_pc_node; // value of PC + 1
wire [7:0] mask_node;    // bit mask for logical operations
reg  [8:0] add_node;     // result of 8bit addition
reg  [4:0] addlow_node;  // result of low-4bit addition
wire temp;               // Placeholder wire
wire dtemp;              // Placeholder wire
reg  aluout_zero_node;   // H if ALUOUT = 0
reg  writew_node;        // H if destination is W register
reg  writeram_node;      // H if destination is RAM/Special registers
reg  int_node;           // H if interrupt request comes

//--------------------------------------------------------------------------
// Instantiations
//--------------------------------------------------------------------------


//--------------------------------------------------------------------------
// Functions & Tasks
//--------------------------------------------------------------------------

function [7:0] bitwise_tristate;
  input [7:0] port;
  input [7:0] tris;
  integer k;
  begin
    for (k=0; k<8; k=k+1) bitwise_tristate[k] <= (tris[k])?1'bZ:port[k];
  end
endfunction


//--------------------------------------------------------------------------
// Module code
//--------------------------------------------------------------------------


// CPU synchronizers
always @(posedge clk_i)
begin
  inte_sync_reg   <= inte;
  reset_condition <= ~pon_rst_n_i;
end


// Decode OPcode    (see pp.54 of PIC16F84 data sheet)
// only 1 signal of the following signals will be '1'
assign inst_call     = (inst_reg[13:11] ==  3'b100           );
assign inst_goto     = (inst_reg[13:11] ==  3'b101           );
assign inst_bcf      = (inst_reg[13:10] ==  4'b0100          );
assign inst_bsf      = (inst_reg[13:10] ==  4'b0101          );
assign inst_btfsc    = (inst_reg[13:10] ==  4'b0110          );
assign inst_btfss    = (inst_reg[13:10] ==  4'b0111          );
assign inst_movlw    = (inst_reg[13:10] ==  4'b1100          );
assign inst_retlw    = (inst_reg[13:10] ==  4'b1101          );
assign inst_sublw    = (inst_reg[13:9]  ==  5'b11110         );
assign inst_addlw    = (inst_reg[13:9]  ==  5'b11111         );
assign inst_iorlw    = (inst_reg[13:8]  ==  6'b111000        );
assign inst_andlw    = (inst_reg[13:8]  ==  6'b111001        );
assign inst_xorlw    = (inst_reg[13:8]  ==  6'b111010        );
assign inst_subwf    = (inst_reg[13:8]  ==  6'b000010        );
assign inst_decf     = (inst_reg[13:8]  ==  6'b000011        );
assign inst_iorwf    = (inst_reg[13:8]  ==  6'b000100        );
assign inst_andwf    = (inst_reg[13:8]  ==  6'b000101        );
assign inst_xorwf    = (inst_reg[13:8]  ==  6'b000110        );
assign inst_addwf    = (inst_reg[13:8]  ==  6'b000111        );
assign inst_movf     = (inst_reg[13:8]  ==  6'b001000        );
assign inst_comf     = (inst_reg[13:8]  ==  6'b001001        );
assign inst_incf     = (inst_reg[13:8]  ==  6'b001010        );
assign inst_decfsz   = (inst_reg[13:8]  ==  6'b001011        );
assign inst_rrf      = (inst_reg[13:8]  ==  6'b001100        );
assign inst_rlf      = (inst_reg[13:8]  ==  6'b001101        );
assign inst_swapf    = (inst_reg[13:8]  ==  6'b001110        );
assign inst_incfsz   = (inst_reg[13:8]  ==  6'b001111        );
assign inst_movwf    = (inst_reg[13:7]  ==  7'b0000001       );
assign inst_clrw     = (inst_reg[13:7]  ==  7'b0000010       );
assign inst_clrf     = (inst_reg[13:7]  ==  7'b0000011       );
assign inst_ret      = (inst_reg[13:0]  == 14'b00000000001000);
assign inst_retfie   = (inst_reg[13:0]  == 14'b00000000001001);
assign inst_sleep    = (inst_reg[13:0]  == 14'b00000001100011);


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
assign addr_pcl     = (ram_adr_node[6:0] ==  7'b0000010); // 02H, 82H
assign addr_stat    = (ram_adr_node[6:0] ==  7'b0000011); // 03H, 83H
assign addr_fsr     = (ram_adr_node[6:0] ==  7'b0000100); // 04H, 84H
assign addr_porta   = (ram_adr_node[7:0] == 8'b00000101); // 05H
assign addr_portb   = (ram_adr_node[7:0] == 8'b00000110); // 06H
assign addr_pclath  = (ram_adr_node[6:0] ==  7'b0001010); // 0AH, 8AH
assign addr_intcon  = (ram_adr_node[6:0] ==  7'b0001011); // 0BH, 8BH
assign addr_option  = (ram_adr_node[7:0] == 8'b10000001); // 81H
assign addr_trisa   = (ram_adr_node[7:0] == 8'b10000101); // 85H
assign addr_trisb   = (ram_adr_node[7:0] == 8'b10000110); // 86H

// construct bit-mask for logical operations and bit tests
assign mask_node = 1 << inst_reg[9:7];

// MAIN EFSM: description of register value changes in each clock cycle
always @(posedge clk_i)
begin
  // 1. Intermediate nodes for resource sharing

  // This is a long if/else chain.  Consider pulling in the decoded signals
  // addr_tmr0 etc., and using a case statement instead?
  // 1-1. Reading RAM/data sources  (see pp.13 of PIC16F84 data sheet)
  if (addr_sram)         ram_i_node <= ram_dat_i;   // data from ext. SRAM
  else if (addr_pcl)     ram_i_node <= pc_reg[7:0]; // data from pcl
  else if (addr_stat)    ram_i_node <= status_reg;  // data from status
  else if (addr_fsr)     ram_i_node <= fsr_reg;     // data from fsr
  else if (addr_porta)
  begin
    // Logic implements a 2:1 mux for each bit [4:0] of ram_i_node
    ram_i_node[4:0] <= (
                           (~trisa_reg[4:0] & porta_o_reg[4:0])
                        || ( trisa_reg[4:0] & porta_i_sync_reg[4:0])
                        );
    ram_i_node[7:5] <= 3'b0;
  end
  else if (addr_portb)
  begin
    // Logic implements a 2:1 mux for each bit [7:0] of ram_i_node
    ram_i_node[7:0] <= (
                           (~trisb_reg[7:0] & portb_o_reg[7:0])
                        || ( trisb_reg[7:0] & portb_i_sync_reg[7:0])
                        );
  end
  else if (addr_pclath)  ram_i_node <= {3'b0,pclath_reg}; // pclath (5bit)
  else if (addr_intcon)  ram_i_node <= intcon_reg;        // data from intcon
  else if (addr_option)  ram_i_node <= option_reg;        // data from option
  else if (addr_trisa)   ram_i_node <= {3'b0,trisa_reg};  // trisa (5bit)
  else if (addr_trisb)   ram_i_node <= trisb_reg;         // data from trisb
  else ram_i_node <= 0;


  // 1-2. PC + 1
  inc_pc_node  <= pc_reg + 1;

  // 1-3. Adder (ALU)
  // full 8bit-addition, with carry in/out.
  {add_node,temp}     <=    {1'b0,aluinp1_reg,1'b1} 
                          + {1'b0,aluinp2_reg,c_in};
  // lower 4bit-addition
  {addlow_node,dtemp} <=    {1'b0,aluinp1_reg[3:0],1'b1} 
                          + {1'b0,aluinp2_reg[3:0],c_in};

  // 1-4. Test if aluout = 0
  aluout_zero_node <= (aluout_reg == 0)?1:0;

  // 1-5. Determine destination
  if (intstart_reg)
  begin
    writew_node     <= 0;
    writeram_node   <= 0;
  end
  else if (inst_movwf || inst_bcf || inst_bsf || inst_clrf)
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

  // 1-6. Interrupt request   (see pp.17 of PIC16F84 data sheet)
  int_node <= intcon_reg[7]        // GIE
              && (intcon_reg[4] && intcon_reg[1]); // INTE,INTF

  // 2. EFSM body
  case (state_reg)

    // 2-1. Reset state (see pp.14 and pp.42 of PIC16F84 data sheet)
    QRESET_PP :
    begin
      pc_reg          <= 0;     // 0
      status_reg[7:5] <= 3'b0;
      pclath_reg      <= 0;     // 0
      intcon_reg[7:1] <= 7'b0;
      option_reg      <= -1;    // Set to all ones, like vhdl (others => 1)
      trisa_reg       <= -1;    // Set to all ones, like vhdl (others => 1)
      trisb_reg       <= -1;    // Set to all ones, like vhdl (others => 1)
      exec_op_reg     <= 0;
      intclr_reg      <= 1;     // clear int
      intstart_reg    <= 0;
      writeram_reg    <= 0;
      sleepflag_reg   <= 0;
      status_reg[4]   <= 1;     // /T0 = 1
      status_reg[3]   <= 1;     // /PD = 1
      stack_pnt_reg   <= 0;     // Reset stack pointer

      // go to Q1 state if reset signal is de-asserted
      if (~reset_condition) state_reg <= Q1_PP;

    end  // End of QRESET_PP state


    // 2-2. Q1 cycle
    Q1_PP :
    begin
      // 2-2-1. Clear external interrupt registers if GIE=0
      if (intcon_reg[7]) intclr_reg <= 0;
      else intclr_reg <= 1;     // clear interrupt

      // 2-2-2. Read I/O port
      porta_i_sync_reg <= porta_io;
      portb_i_sync_reg <= portb_io;

      // 2-2-3. Read RAM read address, if not stalled
      if (exec_op_reg && ~intstart_reg) ram_adr_reg <= ram_adr_node;

      // 2-2-5. Goto next cycle
      if (reset_condition) state_reg <= QRESET_PP;
      else
        // if in the sleep mode, wait until wake-up trigger comes
        if (sleepflag_reg && ~intstart_reg)
        begin
          if (inte_sync_reg)
          begin
          // if rb0/inte interrupt comes, then resume execution
            sleepflag_reg <= 0;
            state_reg     <= Q2_PP;
          end
        end
        // if not in sleep mode, or if stalled, continue execution
        else state_reg   <= Q2_PP;

// Alternate rendition of 2-2-5...
//      // 2-2-5. Goto next cycle
//      if (reset_condition) state_reg <= QRESET_PP; // Reset
//      else if (~sleepflag_reg) state_reg <= Q2_PP; // Not sleeping, move on
//      else if (intstart_reg)   state_reg <= Q2_PP; // Stalled, move on
//      else if (~inte_sync_reg) state_reg <= Q1_PP; // No wakeup, stay sleeping
//      else // Not stalled and wake-up trigger comes...
//      begin
//        // if rb0/int interrupt comes, then resume execution
//        sleepflag_reg <= 0;    // Exit sleep mode condition
//        state_reg     <= Q2_PP;
//      end


    end   // End of Q1 state

    // 2-3. Q2 cycle
    Q2_PP :
    begin
      // 2-3-1. Read data-RAM and substitute source values to alu-input regs
      if (exec_op_reg && ~intstart_reg)  // if NOT STALLED
      begin
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
        if      (inst_decf || inst_decfsz) aluinp2_reg <= -1; // for decr.
        else if (inst_incf || inst_incfsz) aluinp2_reg <=  1; // for incr.
                // -1 * W register (for subtract)
        else if (inst_sublw || inst_subwf) aluinp2_reg <= ~w_reg + 1; 
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

        // 2-3-1-4. Set ram_adr register (set RAM write address)
        ram_adr_reg  <= ram_adr_node;     // RAM write address
      end

      // 2-3-4. Goto next cycle
      if (reset_condition) state_reg <= QRESET_PP;
      else state_reg <= Q3_PP;
    end   // End of Q2 state

    // 2-4. Q3 cycle
    Q3_PP :
    begin
      // 2-4-1. Calculation and store result into alu-output register
      if (exec_op_reg && ~intstart_reg) // if NOT STALLED
      begin
        // 2-4-1-1. Set aluout register
                // Rotate left
        if      (inst_rlf) 
                aluout_reg <= {aluinp1_reg[6:0],status_reg[0]};
                // Rotate right
        else if (inst_rrf) 
                aluout_reg  <= {status_reg[0],aluinp1_reg[7:1]};
                // Swap nibbles
        else if (inst_swapf)
                aluout_reg <= {aluinp1_reg[3:0],aluinp1_reg[7:4]};
                // Logical inversion
        else if (inst_comf)
                aluout_reg  <= ~aluinp1_reg;
                // Logical AND, bit clear/bit test
        else if (   inst_andlw || inst_andwf || inst_bcf || inst_btfsc
                 || inst_btfss) 
                aluout_reg  <= (aluinp1_reg & aluinp2_reg);
                // Logical OR, bit set
        else if (inst_bsf || inst_iorlw || inst_iorwf)
                aluout_reg  <= (aluinp1_reg | aluinp2_reg);
                // Logical XOR
        else if (inst_xorlw || inst_xorwf)
                aluout_reg  <= (aluinp1_reg ^ aluinp2_reg);
                // Addition, Subtraction, Increment, Decrement
        else if (  inst_addlw || inst_addwf  || inst_sublw || inst_subwf
                 || inst_decf || inst_decfsz || inst_incf  || inst_incfsz)
                aluout_reg  <= add_node[7:0];
                // Pass through
        else aluout_reg  <= aluinp1_reg;

        // 2-4-1-2. Set C flag and DC flag
        if (inst_addlw || inst_addwf || inst_sublw || inst_subwf)
        begin
          status_reg[1]   <= addlow_node[4];          // DC flag
          status_reg[0]   <= add_node[8];             // C flag
        end
        else if (inst_rlf) status_reg[0] <= aluinp1_reg[7];  // C flag
        else if (inst_rrf) status_reg[0] <= aluinp1_reg[0];  // C flag

        // 2-4-1-3. Set data-SRAM write enable (hazard-free)
        if (writeram_node && addr_sram) writeram_reg <= 1;
        else writeram_reg <= 0;

      end
      else writeram_reg <= 0; // If stalled

      // 2-4-2. Check external interrupt and set int. flag
      if (~intstart_reg && intcon_reg[7]) // GIE
      begin
        // PORT-B0 INT
        if (inte_sync_reg)
        begin
          intcon_reg[1] <= 1;     // set INTF
          intclr_reg    <= 1;     // clear external int-register
                                  // (intrise_reg and intdown_reg)
        end
      end

      // 2-4-3. Goto next cycle
      if (reset_condition) state_reg   <= QRESET_PP;
      else            state_reg   <= Q4_PP;

    end    // End of Q3 state


    // 2-5. Q4 cycle
    Q4_PP :
    begin
      // 2-5-1. Fetch next program-instruction
      inst_reg    <= prog_dat_i;

      if (~exec_op_reg && ~intstart_reg)      // if STALLED (not interrupt) 
      begin
        pc_reg          <= inc_pc_node; // increment PC
        exec_op_reg     <= 1;           // end of stall
      end
      else  // if NOT stalled 
      begin
        // (note: if intstart_reg, only stack/pc-operations in this 
        //        else-clause will be performed)
        // 2-5-2. Store calculation result into destination, 
        // set PC and flags, and determine if execute next cycle.

        // 2-5-2-1. Set W register, if not in stall cycle 
        //          (~intstart_reg) and destination is W
        
        // writew_node == 0 if intstart_reg...
        if (writew_node) w_reg   <= aluout_reg;    // write W reg

        // 2-5-2-2. Set data RAM/special registers,
        // if not in stall cycle (~intstart_reg)
        if (writeram_node)
        begin
          if (addr_stat)
          begin
            status_reg[7:5] <= aluout_reg[7:5];      // write IRP,RP1,RP0
            // status(4),status(3)...unwritable, see below (/PD,/T0 part)
            status_reg[1:0] <= aluout_reg[1:0];      // write DC,C
          end
          if (addr_fsr)         fsr_reg <= aluout_reg;      // write FSR
          if (addr_porta)   porta_o_reg <= aluout_reg[4:0]; // write PORT-A
          if (addr_portb)   portb_o_reg <= aluout_reg;      // write PORT-B
          if (addr_pclath)   pclath_reg <= aluout_reg[4:0]; // write PCLATH
          if (addr_intcon) intcon_reg[6:0] <= aluout_reg[6:0]; 
                           // write INTCON (except GIE)
                           // intcon(7)...see below (GIE part)
          if (addr_option)   option_reg <= aluout_reg;      // write OPTION
          if (addr_trisa)     trisa_reg <= aluout_reg[4:0]; // write TRISA
          if (addr_trisb)     trisb_reg <= aluout_reg;      // write TRISB
        end

        // 2-5-2-3. Set/clear Z flag, if not in stall cycle (~intstart_reg)
        if (~intstart_reg)
        begin
          if (addr_stat) status_reg[2] <= aluout_reg[2]; // (dest. is Z flag)
          else if (   inst_addlw || inst_addwf || inst_andlw || inst_andwf
                   || inst_clrf  || inst_clrw  || inst_comf  || inst_decf
                   || inst_incf  || inst_movf  || inst_sublw || inst_subwf
                   || inst_xorlw || inst_xorwf || inst_iorlw || inst_iorwf )
                  status_reg[2] <= aluout_zero_node; // Z=1 if result == 0
        end

        // 2-5-2-4. Set PC and determine whether to execute next cycle or not
        // After interrupt-stall cycle ends, jump to interrupt vector
        if (intstart_reg) 
        begin
          pc_reg      <= 4;     // (interrupt vector)
          exec_op_reg <= 0;     // the next cycle is a stall cycle
        end
        else if (inst_ret || inst_retlw || inst_retfie) // "return" instr.
        begin
          pc_reg      <= stack_reg[stack_pnt_reg];
          exec_op_reg <= 0;              // the next cycle is stall cycle
        end
        else if (inst_goto || inst_call) // "goto/call" instructions
        begin
          // (see pp.18 of PIC16F84 data sheet)
          pc_reg      <= {pclath_reg[4:3],inst_reg[10:0]};
          exec_op_reg <= 0;
        end
        else if ( (   (inst_btfsc || inst_decfsz || inst_incfsz) 
                       && aluout_zero_node)
                   || (inst_btfss && ~aluout_zero_node)
                   ) // bit_test instrcutions
        begin
          pc_reg      <= inc_pc_node;
          exec_op_reg <= 0;
          // the next cycle is stall cycle, if test conditions are met.
        end
        else if (writeram_node && addr_pcl) // PCL is data-destination
        begin
          // (see pp.18 of PIC16F84 data sheet)
          pc_reg      <= pclath_reg[4:0] & aluout_reg;
          exec_op_reg <= 0;
        end
        else
        begin
          // this check MUST be located AFTER the above if/else sentences
          // check if interrupt trigger comes
          if (~int_node) pc_reg <= inc_pc_node; 
          // if not, the next instr. fetch/exec. will be performed normally
          else pc_reg <= pc_reg; 
          // if so, value of PC must be held 
          //(will be pushed onto stack at the end of next instruction cycle)
          exec_op_reg <= 1;
        end

        // 2-5-2-5. Push current PC value into stack, if necessary
        if (inst_call || intstart_reg)
        // CALL instr. or End of interrupt-stall cycle
        begin
          stack_reg[stack_pnt_reg] <= pc_reg;  // write PC value
          stack_pnt_reg <= stack_pnt_reg + 1;  // increment stack pointer
        end

        // 2-5-2-6. Set GIE bit in intcon register (intcon_reg(7))
        if (~intstart_reg)
        begin
          if (int_node) // interrupt trigger comes
          begin
            intcon_reg[7] <= 0; // clear GIE
            intstart_reg  <= 1; // the next cycle is interrupt-stall cycle
          end
          else if (inst_retfie) // "return from interrupt" instruction
          begin
            intcon_reg[7] <= 1;
            intstart_reg  <= 0;
          end
          else if (writeram_node && addr_intcon) // destination is GIE
          begin
            intcon_reg[7] <= aluout_reg[7];
            intstart_reg  <= 0;
          end
          else intstart_reg <= 0;
        end
        else intstart_reg <= 0;

        // 2-5-2-7. Enter sleep mode if needed. (No need to set /TO and /PD)
        if (~intstart_reg && inst_sleep) sleepflag_reg <= 1;

      end // (if not stalled)

      // 2-5-3. Clear data-SRAM write enable (hazard-free)
      writeram_reg <= 0;

      // 2-5-6. Goto next cycle
      if (reset_condition) state_reg   <= QRESET_PP;
      else state_reg   <= Q1_PP;
    end    // End of Q4 state

    // 2-6. Illegal states (NEVER REACHED in normal execution)
    default : state_reg   <= QRESET_PP;      // goto reset state
    endcase
end  // End of process


// Detect external interrupt requests
// INT0 I/F
always @(posedge int0_i or posedge intclr_reg)
begin
  if (intclr_reg) intrise_reg <= 0;
  else intrise_reg <= 1; // catch positive edge
end // process

always @(negedge int0_i or posedge intclr_reg)
begin
  if (intclr_reg) intdown_reg <= 0;
  else intdown_reg <= 1; // catch negative edge
end // process
assign rb0_int = option_reg[6]?intrise_reg:intdown_reg;

// Decode INT triggers 
// (do not AND with GIE(intcon_reg(7)), since these signals are 
//  also used for waking up from SLEEP)
assign inte  = intcon_reg[4] && rb0_int;                                       // G0IE and raw-trigger signal


// Circuit's output signals
assign prog_adr_o = pc_reg;        // program ROM address
assign ram_adr_o  = ram_adr_reg;   // data RAM address
assign ram_dat_o  = aluout_reg;    // data RAM write data
assign readram_o  = (state_reg[1:0] == Q2_PP[1:0]); // data RAM read enable 
                                               //(1 when state_reg = Q2_PP)
assign writeram_o = writeram_reg;  // data RAM write enable

assign porta_io   = bitwise_tristate(porta_o_reg, trisa_reg); // PORT-A
assign portb_io   = bitwise_tristate(portb_o_reg, trisb_reg); // PORT-B

endmodule


//`undef STATEBIT_SIZE