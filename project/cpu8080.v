////////////////////////////////////////////////////////////////////////////////
// Company:                                                                   //  
// Engineer:       Scott Moore                                                //
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
// Chris N. Strahm - Modifications for Altera Quartus build.                  //
//                                                                            //
// Create Date:    11:45:32 09/04/2006                                        // 
// Design Name:                                                               // 
// Module Name:    cpu8080                                                    //
// Project Name:   cpu8080                                                    //
// Target Devices: xc3c200, xc3s1000                                          //
// Tool versions:                                                             //
// Description:                                                               //
//                                                                            //
//     Executes the 8080 instruction set. It is designed to be an internal    //
//     cell. Each of the I/Os are positive logic, and all signals are         //
//     constant with the exception of the data bus. The control signals are   //
//     fully decoded (unlike the orignal 8080), and features read and write   //
//     signals for both memory and I/O space. The I/O space is an 8 bit       //
//     address as in the original 8080. It does NOT echo the lower 8 bits to  //
//     the higher 8 bits, as was the practice in some systems.                //
//                                                                            //
//     Like the original 8080, the interrupt vectoring is fully external. The //
//     the external controller forces a full instruction onto the data bus.   //
//     The sequence begins with the assertion of interrupt request. The CPU   //
//     will then assert interrupt acknowledge, then it will run a special     //
//     read cycle with inta asserted for each cycle of a possibly             //
//     multibyte instruction. This matches the original 8080, which typically //
//     used single byte restart instructions to form a simple interrupt       //
//     controller, but was capable of full vectoring via insertion of a jump, //
//     call or similar instruction.                                           //
//                                                                            //
//     Note that the interrupt vector instruction should branch. This is      //
//     because the PC gets changed by the vector instruction, so if it does   //
//     not branch, it will have skipped a number of bytes after the interrupt //
//     equivalent to the vector instruction. The only instructions that       //
//     should really be used to vector are jmp, rst and call instructions.    //
//     Specifically, rst and call instruction compensate for the pc movement  //
//     by putting the pc unmodified on the stack.                             //
//                                                                            //
//     The memory, I/O and interrupt fetches all obey a simple clocking       //
//     sequence as follows. The CPU uses the positive clock edge to assert    //
//     and sample signals and data. The external logic theoretically uses the //
//     negative edge to check signal assertions and sample data, but it can   //
//     either use the negative edge, or actually be asynronous logic.         //
//                                                                            //
//     A standard read sequence is as follows:                                //
//                                                                            //
//     1. At the positive clock edge, readmem, readio or readint is asserted. //
//     2. At the negative clock edge (or immediately), the external memory    //
//        places data onto the data bus.                                      //
//     3. We hold automatically for one cycle.                                //
//     4. At the next positive clock edge, the data is sampled, and the read  //
//        Signal is deasserted.                                               //
//                                                                            //
//     A standard write sequence is as follows:                               //
//                                                                            //
//     1. At the positive edge, data is asserted on the data bus.             //
//     2. At the next postive clock edge, writemem or writeio is asserted.    //
//     3. At the next positive clock edge, writemem or writeio is deasserted. //
//     4. At the next positive edge, the data is deasserted.                  //
//                                                                            //
// Dependencies:                                                              //
//                                                                            //
// Revision:                                                                  //
// Revision 0.01 - File Created                                               //
// Additional Comments:                                                       //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

//
// Build option
//
// Uncomment this line to build without wait state ability. Many FPGA 
// applications don't require wait states. This can save silicon area.
//
// Defining this option will cause the wait line to be ignored.
//
// `define NOWAIT

//
// Build option
//
// Uncomment this line to build without I/O instruction ability. An application
// may have memory mapped I/O only, and not require I/O instructions. This can
// save silicon area.
//
// Defining this option will cause I/O instructions to be treated as no-ops.
// alternately, you can modify what they do.
//
// `define NOIO

//
// CPU states
//

`define cpus_idle     6'h00 // Idle
`define cpus_fetchi   6'h01 // Instruction fetch
`define cpus_fetchi2  6'h02 // Instruction fetch 2
`define cpus_fetchi3  6'h03 // Instruction fetch 3
`define cpus_fetchi4  6'h04 // Instruction fetch 4
`define cpus_halt     6'h05 // Halt (wait for interrupt)
`define cpus_alucb    6'h06 // alu cycleback
`define cpus_indcb    6'h07 // inr/dcr cycleback
`define cpus_movmtbc  6'h08 // Move memory to bc
`define cpus_movmtde  6'h09 // Move memory to de
`define cpus_movmthl  6'h0a // Move memory to hl
`define cpus_movmtsp  6'h0b // Move memory to sp
`define cpus_lhld     6'h0c // LHLD
`define cpus_jmp      6'h0d // JMP
`define cpus_write    6'h0e // write byte
`define cpus_write2   6'h0f // write byte #2
`define cpus_write3   6'h10 // write byte #3
`define cpus_write4   6'h11 // write byte #4
`define cpus_read     6'h12 // read byte
`define cpus_read2    6'h13 // read byte #2
`define cpus_read3    6'h14 // read byte #3
`define cpus_pop      6'h15 // POP completion
`define cpus_in       6'h16 // IN
`define cpus_in2      6'h17 // IN #2
`define cpus_in3      6'h18 // IN #3
`define cpus_out      6'h19 // OUT
`define cpus_out2     6'h1a // OUT #2
`define cpus_out3     6'h1b // OUT #3
`define cpus_out4     6'h1c // OUT #4
`define cpus_movtr    6'h1d // move to register
`define cpus_movrtw   6'h1e // move read to write
`define cpus_movrtwa  6'h1f // move read to write address
`define cpus_movrtra  6'h20 // move read to read address
`define cpus_accimm   6'h21 // accumulator immediate operations
`define cpus_daa      6'h22 // DAA completion
`define cpus_call     6'h23 // CALL completion
`define cpus_ret      6'h24 // RET completion
`define cpus_movtalua 6'h25 // move to alu a
`define cpus_movtalub 6'h26 // move to alu b
`define cpus_indm     6'h27 // inc/dec m

//
// Register numbers
//

`define reg_b 3'b000 // B
`define reg_c 3'b001 // C
`define reg_d 3'b010 // D
`define reg_e 3'b011 // E
`define reg_h 3'b100 // H
`define reg_l 3'b101 // L
`define reg_m 3'b110 // M
`define reg_a 3'b111 // A

//
// ALU operations
//

`define aluop_add 3'b000 // add
`define aluop_adc 3'b001 // add with carry in
`define aluop_sub 3'b010 // subtract
`define aluop_sbb 3'b011 // subtract with borrow in
`define aluop_and 3'b100 // and
`define aluop_xor 3'b101 // xor
`define aluop_or  3'b110 // or
`define aluop_cmp 3'b111 // compare

//
// State macros
//
`define mac_writebyte  1  // write a byte
`define mac_readbtoreg 2  // read a byte, place in register
`define mac_readdtobc  4  // read double byte to BC
`define mac_readdtode  6  // read double byte to DE
`define mac_readdtohl  8 // read double byte to HL
`define mac_readdtosp  10 // read double byte to SP
`define mac_readbmtw   12 // read byte and move to write
`define mac_readbmtr   15 // read byte and move to register
`define mac_sta        17 // STA
`define mac_lda        21 // LDA
`define mac_shld       26 // SHLD
`define mac_lhld       31 // LHLD
`define mac_writedbyte 37 // write double byte
`define mac_pop        39 // POP
`define mac_xthl       41 // XTHL
`define mac_accimm     45 // accumulator immediate
`define mac_jmp        46 // JMP
`define mac_call       48 // CALL
`define mac_in         52 // IN
`define mac_out        53 // OUT
`define mac_rst        54 // RST
`define mac_ret        56 // RET
`define mac_alum       58 // op a,m
`define mac_indm       60 // inc/dec m

module cpu8080(addr,     // Address out
               data,     // Data bus
               readmem,  // Memory read   
               writemem, // Memory write
               readio,   // Read I/O space
               writeio,  // Write I/O space
               intr,     // Interrupt request 
               inta,     // Interrupt request 
               waitr,    // Wait request
               reset,    // Reset
               clock);   // System clock

   output [15:0] addr;
   inout  [7:0] data;
   output readmem;
   output writemem;
   output readio;
   output writeio;
   input  intr;
   output inta;
   input  waitr;
   input  reset;
   input  clock;
    
   // Output or input lines that need to be registered
    
   reg           readmem;
   reg           writemem;
   reg    [15:0] pc;
   reg    [15:0] addr;
   reg           readio;
   reg           writeio;
   reg           inta;
   reg    [15:0] sp;
                     
   // Local registers
    
   reg    [5:0]  state;       // CPU state machine
   reg    [2:0]  regd;        // Destination register
   reg    [7:0]  datao;       // Data output register
   reg           dataeno;     // Enable output data
   reg    [15:0] waddrhold;   // address holding for write
   reg    [15:0] raddrhold;   // address holding for read
   reg    [7:0]  wdatahold;   // single byte write data holding
   reg    [7:0]  wdatahold2;  // single byte write data holding
   reg    [7:0]  rdatahold;   // single byte read data holding
   reg    [7:0]  rdatahold2;  // single byte read data holding
   reg    [1:0]  popdes;      // POP destination code
   reg    [5:0]  statesel;    // state map selector
   reg    [5:0]  nextstate;   // next state output
   reg           eienb;       // interrupt enable delay shift reg
   reg    [7:0]  opcode;      // opcode holding
   
   // Register file. Note that 3'b110 (6) is not used, and is the code for a
   // memory reference.
    
   reg    [7:0]  regfil[0:7];

   // The flags are represented individually

   reg           carry; // carry bit
   reg           auxcar; // auxiliary carry bit
   reg           sign; // sign bit
   reg           zero; // zero bit
   reg           parity; // parity bit
   reg           ei; // interrupt enable
   reg           intcyc; // in interrupt cycle

   // ALU communication

   wire   [7:0]  alures;  // result
   reg    [7:0]  aluopra; // left side operand
   reg    [7:0]  aluoprb; // right side operand
   reg           alucin;  // carry in
   wire          alucout; // carry out
   wire          alupar;  // parity out
   wire          aluaxc;  // auxiliary carry
   reg    [2:0]  alusel;  // alu operational select
    
   // Instantiate the ALU

   alu alu(alures, aluopra, aluoprb, alucin, alucout, aluzout, alusout, alupar,
           aluaxc, alusel);
   
   always @(posedge clock)
      if (reset) begin // syncronous reset actions
       
      state    <= `cpus_fetchi; // Clear CPU state to initial fetch
      pc       <= 0; // reset program counter to 1st location
      dataeno  <= 0; // get off the data bus
      readmem  <= 0; // all signals out false
      writemem <= 0;
      readio   <= 0;
      writeio  <= 0;
      inta     <= 0;
      intcyc   <= 0;
      ei       <= 1; // interrupts on by default
      eienb    <= 0;

   end else case (state)
       
      `cpus_fetchi: begin // start of instruction fetch
       
         // if interrupt request is on, enter interrupt cycle, else exit it now
         if (intr&&ei) begin

            intcyc <= 1; // enter interrupt cycle
            inta   <= 1; // activate interrupt acknowledge
            ei     <= 0; // disable interrupts

         end else begin

            intcyc  <= 0; // leave interrupt cycle
            readmem <= 1; // activate instruction memory read

         end
            
         addr <= pc; // place current program count on output
         if (eienb) ei <=1; // process delayed interrupt enable
         eienb <=0; // reset interrupt enabler
         state <= `cpus_fetchi2; // next state
       
      end

      `cpus_fetchi2: begin // wait

         state <= `cpus_fetchi3; // next state

       end

      `cpus_fetchi3: begin // complete instruction memory read

`ifndef NOWAIT
         if (!waitr) 
`endif
            begin // no wait selected, otherwise cycle

            opcode <= data; // latch opcode
            readmem <= 0; // Deactivate instruction memory read
            inta <= 0; // and interrupt acknowledge
            state <= `cpus_fetchi4; // next state

         end
   
      end
       
      `cpus_fetchi4: begin // complete instruction memory read
          
         // We split off the instructions into 4 groups. Most of the 8080
         // instructions are in the MOV and ACC operations class.
          
         case (opcode[7:6]) // Decode top level
          
            2'b00: begin // 00: Data transfers and others
             
               case (opcode[5:0]) // decode these instructions

                  6'b000000: begin // NOP

                     // yes, do nothing

                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b110111: begin // STC

                     carry <= 1; // set carry flag
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b111111: begin // CMC

                     carry <= ~carry; // complement carry flag
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b101111: begin // CMA

                     regfil[`reg_a] <= ~regfil[`reg_a]; // complement accumulator
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b100111: begin // DAA

                     // decimal adjust accumulator, or remove by carry any 
                     // results in nybbles greater than 9

                     if (regfil[`reg_a][3:0] > 9 || auxcar)
                        { auxcar, regfil[`reg_a] } <= regfil[`reg_a]+8'h06;
                     state <= `cpus_daa; // finish DAA
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b000100, 6'b001100, 6'b010100, 6'b011100, 6'b100100, 
                  6'b101100, 6'b110100, 6'b111100, 6'b000101, 6'b001101, 
                  6'b010101, 6'b011101, 6'b100101, 6'b101101, 6'b110101, 
                  6'b111101: begin // INR/DCR

                     regd <= opcode[5:3]; // get source/destination reg
                     aluopra <= regfil[opcode[5:3]]; // load as alu a
                     aluoprb <= 1; // load 1 as alu b
                     if (opcode[0]) alusel <= `aluop_sub; // set subtract
                     else alusel <= `aluop_add; // set add
                     if (opcode[5:3] == `reg_m) begin

                        raddrhold <= regfil[`reg_h]<<8|regfil[`reg_l];
                        statesel <= `mac_indm; // inc/dec m
                        state <= `cpus_read; // read byte

                     end else state <= `cpus_indcb; // go inr/dcr cycleback
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b000010, 6'b010010: begin // STAX

                     wdatahold <= regfil[`reg_a]; // place A as source
                     if (opcode[4]) // use DE pair
                        waddrhold <= regfil[`reg_d]<<8|regfil[`reg_e];
                     else // use BC pair
                        waddrhold <= regfil[`reg_b] << 8|regfil[`reg_c];
                     statesel <= `mac_writebyte; // write byte
                     state <= `cpus_write;
                     pc <= pc+16'h1; // Next instruction byte
                    
                  end

                  6'b001010, 6'b011010: begin // LDAX

                     regd <= `reg_a; // set A as destination
                     if (opcode[4]) // use DE pair
                        raddrhold <= regfil[`reg_d]<<8|regfil[`reg_e];
                     else // use BC pair
                        raddrhold <= regfil[`reg_b]<<8|regfil[`reg_c];
                     statesel <= `mac_readbtoreg; // read byte to register
                     state <= `cpus_read;
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b000111: begin // RLC

                     // rotate left circular
                     { carry, regfil[`reg_a] } <= 
                        (regfil[`reg_a] << 1)+regfil[`reg_a][7];
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b010111: begin // RAL

                     // rotate left through carry
                     { carry, regfil[`reg_a] } <= (regfil[`reg_a] << 1)+carry;
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b001111: begin // RRC

                     // rotate right circular
                     regfil[`reg_a] <= 
                        (regfil[`reg_a] >> 1)+(regfil[`reg_a][0] << 7);
                     carry <= regfil[`reg_a][0];
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b011111: begin // RAR

                     // rotate right through carry
                     regfil[`reg_a] <= (regfil[`reg_a] >> 1)+(carry << 7);
                     carry <= regfil[`reg_a][0];
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b001001: begin // DAD B

                     // add BC to HL
                     { carry, regfil[`reg_h], regfil[`reg_l] } <= 
                        (regfil[`reg_h] << 8)+regfil[`reg_l]+
                        (regfil[`reg_b] << 8)+regfil[`reg_c];
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b011001: begin // DAD D

                     // add DE to HL
                     { carry, regfil[`reg_h], regfil[`reg_l] } <= 
                        (regfil[`reg_h] << 8)+regfil[`reg_l]+
                        (regfil[`reg_d] << 8)+regfil[`reg_e];
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b101001: begin // DAD H

                     // add HL to HL
                     { carry, regfil[`reg_h], regfil[`reg_l] } <= 
                        (regfil[`reg_h] << 8)+regfil[`reg_l]+
                        (regfil[`reg_h] << 8)+regfil[`reg_l];
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b111001: begin // DAD SP

                     // add SP to HL
                     { carry, regfil[`reg_h], regfil[`reg_l] } <= 
                        (regfil[`reg_h] << 8)+regfil[`reg_l]+sp;
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b000011: begin // INX B

                     // increment BC, no flags set
                     regfil[`reg_b] <= 
                        (((regfil[`reg_b] << 8)+regfil[`reg_c])+16'h1)>>8;
                     regfil[`reg_c] <= 
                        ((regfil[`reg_b] << 8)+regfil[`reg_c])+16'h1;
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b010011: begin // INX D

                     // increment DE, no flags set
                     regfil[`reg_d] <= 
                        (((regfil[`reg_d] << 8)+regfil[`reg_e])+16'h1)>>8;
                     regfil[`reg_e] <= 
                        ((regfil[`reg_d] << 8)+regfil[`reg_e])+16'h1;
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b100011: begin // INX H

                     // increment HL, no flags set
                     regfil[`reg_h] <= 
                        (((regfil[`reg_h] << 8)+regfil[`reg_l])+16'h1)>>8;
                     regfil[`reg_l] <= 
                        ((regfil[`reg_h] << 8)+regfil[`reg_l])+16'h1;
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b110011: begin // INX SP

                     // increment SP, no flags set
                     sp <= sp + 16'b1;
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b001011: begin // DCX B

                     // decrement BC, no flags set
                     regfil[`reg_b] <= 
                        (((regfil[`reg_b] << 8)+regfil[`reg_c])-16'h1)>>8;
                     regfil[`reg_c] <= 
                        ((regfil[`reg_b] << 8)+regfil[`reg_c])-16'h1;
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b011011: begin // DCX D

                     // decrement DE, no flags set
                     regfil[`reg_d] <= 
                        (((regfil[`reg_d] << 8)+regfil[`reg_e])-16'h1)>>8;
                     regfil[`reg_e] <= 
                        ((regfil[`reg_d] << 8)+regfil[`reg_e])-16'h1;
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b101011: begin // DCX H

                     // decrement HL, no flags set
                     regfil[`reg_h] <= 
                        (((regfil[`reg_h] << 8)+regfil[`reg_l])-16'h1)>>8;
                     regfil[`reg_l] <= 
                        ((regfil[`reg_h] << 8)+regfil[`reg_l])-16'h1;
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+1'h1; // Next instruction byte

                  end

                  6'b111011: begin // DCX SP

                     // decrement SP, no flags set
                     sp <= sp-16'b1;
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b000001: begin // LXI B

                     raddrhold <= pc+16'h1; // pick up after instruction
                     statesel <= `mac_readdtobc; // read double to BC
                     state <= `cpus_read;
                     pc <= pc+16'h3; // skip

                  end

                  6'b010001: begin // LXI D

                     raddrhold <= pc+16'h1; // pick up after instruction
                     statesel <= `mac_readdtode; // read double to DE
                     state <= `cpus_read;
                     pc <= pc+16'h3; // skip

                  end

                  6'b100001: begin // LXI H

                     raddrhold <= pc+16'h1; // pick up after instruction
                     statesel <= `mac_readdtohl; // read double to HL
                     state <= `cpus_read;
                     pc <= pc+16'h3; // skip

                  end

                  6'b110001: begin // LXI SP

                     raddrhold <= pc+16'h1; // pick up after instruction
                     statesel <= `mac_readdtosp; // read double to SP
                     state <= `cpus_read;
                     pc <= pc+16'h3; // skip

                  end

                  6'b000110, 6'b001110, 6'b010110, 6'b011110, 6'b100110, 
                  6'b101110, 6'b110110, 6'b111110: begin // MVI

                     // move immediate to register
                     regd <= opcode[5:3]; // set destination register
                     raddrhold <= pc+16'h1; // set pickup address
                     if (opcode[5:3] == `reg_m) begin // it's mvi m,imm

                        regd <= opcode[5:3]; // set destination register
                        // set destination address
                        waddrhold <= { regfil[`reg_h], regfil[`reg_l] };
                        statesel <= `mac_readbmtw; // read byte and move to write

                     end else 
                        statesel <= `mac_readbmtr; // read byte and move to register
                     state <= `cpus_read;
                     pc <= pc+16'h2; // advance over byte

                  end

                  6'b110010: begin // STA

                     wdatahold <= regfil[`reg_a]; // set write data
                     raddrhold <= pc+16'h1; // set read address
                     statesel <= `mac_sta; // perform sta
                     state <= `cpus_read;
                     pc <= pc + 16'h3; // next

                  end

                  6'b111010: begin // LDA

                     raddrhold <= pc+16'h1; // set read address
                     regd <= `reg_a; // set destination
                     statesel <= `mac_lda; // perform lda
                     state <= `cpus_read;
                     pc <= pc+16'h3; // next

                  end

                  6'b100010: begin // SHLD

                     wdatahold <= regfil[`reg_l]; // set write data
                     wdatahold2 <= regfil[`reg_h];
                     raddrhold <= pc+16'h1; // set read address
                     statesel <= `mac_shld; // perform SHLD
                     state <= `cpus_read;
                     pc <= pc+16'h3; // skip

                  end

                  6'b101010: begin // LHLD

                     raddrhold <= pc+16'h1; // set read address
                     statesel <= `mac_lhld; // perform LHLD
                     state <= `cpus_read;
                     pc <= pc+16'h3; // skip

                  end

                  // the illegal opcodes behave as NOPs

                  6'b001000, 6'b010000, 6'b011000, 6'b100000, 6'b101000, 
                  6'b110000, 6'b110000: begin 

                     state <= `cpus_fetchi; // fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

               endcase

            end
             
            2'b01: begin // 01: MOV instruction
             
               // Check its the halt instruction, which occupies the invalid
               // "MOV M,M" instruction.
               if (opcode == 8'b01110110) state <= `cpus_halt;
               // Otherwise, the 01 prefix is single instruction format.
               else begin

                  // Format 01DDDSSS
   
                  // Check memory source, use state if so
                  if (opcode[2:0] == `reg_m) begin

                     // place hl as address
                     raddrhold <= regfil[`reg_h]<<8|regfil[`reg_l];
                     regd <= opcode[5:3]; // set destination
                     statesel <= `mac_readbtoreg; // read byte to register
                     state <= `cpus_read;

                  // Check memory destination, use state if so
                  end else if (opcode[5:3] == `reg_m) begin

                     // place hl as address
                     waddrhold <= regfil[`reg_h]<<8|regfil[`reg_l];
                     wdatahold <= regfil[opcode[2:0]]; // place data to write
                     statesel <= `mac_writebyte; // write byte
                     state <= `cpus_write;

                  // otherwise simple register to register
                  end else begin

                     regfil[opcode[5:3]] <= regfil[opcode[2:0]];
                     state <= `cpus_fetchi; // Fetch next instruction

                  end

               end
               pc <= pc+16'h1; // Next instruction byte
             
            end
             
            2'b10: begin // 10: Reg or mem to accumulator ops
             
               // 10 prefix is single instruction format
               aluopra <= regfil[`reg_a]; // load as alu a
               aluoprb <= regfil[opcode[2:0]]; // load as alu b
               alusel <= opcode[5:3]; // set alu operation from instruction
               alucin <= carry; // input carry
               if (opcode[2:0] == `reg_m) begin

                  // set read address
                  raddrhold <= regfil[`reg_h]<<8|regfil[`reg_l];
                  statesel <= `mac_alum; // alu from m
                  state <= `cpus_read; // read byte

               end else
                  state <= `cpus_alucb; // go to alu cycleback
               pc <= pc+16'h1; // Next instruction byte

            end
             
            2'b11: begin // 11: jmp/call and others
             
               case (opcode[5:0]) // decode these instructions

                  6'b000101, 6'b010101, 6'b100101, 6'b110101: begin // PUSH

                     waddrhold <= sp-16'h2; // write to stack
                     sp <= sp-16'h2; // pushdown stack
                     case (opcode[5:4]) // register set

                        2'b00: { wdatahold2, wdatahold } <= 
                                  { regfil[`reg_b], regfil[`reg_c] };
                        2'b01: { wdatahold2, wdatahold } <= 
                                  { regfil[`reg_d], regfil[`reg_e] };
                        2'b10: { wdatahold2, wdatahold } <= 
                                  { regfil[`reg_h], regfil[`reg_l] };
                        2'b11: { wdatahold2, wdatahold } <= 
                                  { regfil[`reg_a], sign, zero, 1'b0, auxcar, 
                                    1'b0, parity, 1'b1, carry };

                     endcase
                     statesel <= `mac_writedbyte; // write double byte
                     state <= `cpus_write;
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b000001, 6'b010001, 6'b100001, 6'b110001: begin // POP

                     popdes <= opcode[5:4]; // set destination
                     raddrhold <= sp; // read from stack
                     sp <= sp+16'h2; // pushup stack
                     statesel <= `mac_pop; // perform POP
                     state <= `cpus_read;
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b101011: begin // XCHG

                     regfil[`reg_d] <= regfil[`reg_h];
                     regfil[`reg_e] <= regfil[`reg_l];
                     regfil[`reg_h] <= regfil[`reg_d];
                     regfil[`reg_l] <= regfil[`reg_e];
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b100011: begin // XTHL

                     raddrhold <= sp; // address SP for read
                     waddrhold <= sp; // address SP for write
                     wdatahold <= regfil[`reg_l]; // set data is HL
                     wdatahold2 <= regfil[`reg_h];
                     statesel <= `mac_xthl; // perform XTHL
                     state <= `cpus_read;
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b111001: begin // SPHL

                     sp <= { regfil[`reg_h], regfil[`reg_l] };
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b000110, 6'b001110, 6'b010110, 6'b011110, 6'b100110, 
                  6'b101110, 6'b110110, 
                  6'b111110: begin // immediate arithmetic to accumulator

                     aluopra <= regfil[`reg_a]; // load as alu a
                     alusel <= opcode[5:3]; // set alu operation from instruction
                     alucin <= carry; // input carry
                     raddrhold <= pc+16'h1; // read at PC
                     statesel <= `mac_accimm; // finish accumulator immediate
                     state <= `cpus_read;
                     pc <= pc+16'h2; // skip immediate byte

                  end

                  6'b101001: begin // PCHL

                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= { regfil[`reg_h], regfil[`reg_l] };

                  end

                  6'b000011: begin // JMP

                     raddrhold <= pc+16'h1; // pick up jump address
                     statesel <= `mac_jmp; // finish JMP
                     state <= `cpus_read;
  
                  end

                  6'b000010, 6'b001010, 6'b010010, 6'b011010, 6'b100010, 
                  6'b101010, 6'b110010, 6'b111010: begin // Jcc

                     raddrhold <= pc+16'h1; // pick up jump address
                     statesel <= `mac_jmp; // finish JMP
                     // choose continue or read according to condition
                     case (opcode[5:3]) // decode flag cases

                        3'b000: if (zero) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b001: if (!zero) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b010: if (carry) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b011: if (!carry) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b100: if (parity) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b101: if (!parity) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b110: if (sign) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b111: if (!sign) state <= `cpus_fetchi;
                                else state <= `cpus_read;

                     endcase
                     pc <= pc+16'h3; // advance after jump for false

                  end

                  6'b001101: begin // CALL

                     raddrhold <= pc+16'h1; // pick up call address
                     waddrhold <= sp-16'h2; // place address on stack
                     // if interrupt cycle, use current pc, else use address
                     // after call
                     if (intcyc) { wdatahold2, wdatahold } <= pc;
                     else { wdatahold2, wdatahold } <= pc+16'h3;
                     statesel <= `mac_call; // finish CALL
                     state <= `cpus_read;

                  end

                  6'b000100, 6'b001100, 6'b010100, 6'b011100, 6'b100100, 
                  6'b101100, 6'b110100, 6'b111100: begin // Ccc

                     raddrhold <= pc+16'h1; // pick up call address
                     waddrhold <= sp-16'h2; // place address on stack
                     // of address after call
                     { wdatahold2, wdatahold } <= pc + 16'h3;
                     statesel <= `mac_call; // finish CALL
                     // choose continue or read according to condition
                     case (opcode[5:3]) // decode flag cases

                        3'b000: if (zero) state <= `cpus_fetchi; 
                                else state <= `cpus_read;
                        3'b001: if (!zero) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b010: if (carry) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b011: if (!carry) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b100: if (parity) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b101: if (!parity) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b110: if (sign) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b111: if (!sign) state <= `cpus_fetchi;
                                else state <= `cpus_read;

                     endcase
                     pc <= pc+16'h3; // advance after jump for false

                  end

                  6'b001001: begin // RET

                     raddrhold <= sp; // read from stack
                     statesel <= `mac_ret; // finish RET
                     state <= `cpus_read;

                  end

                  6'b000000, 6'b001000, 6'b010000, 6'b011000, 6'b100000, 
                  6'b101000, 6'b110000, 6'b111000: begin // Rcc

                     raddrhold <= sp; // read from stack
                     statesel <= `mac_ret; // finish JMP
                     // choose read or continue according to condition
                     case (opcode[5:3]) // decode flag cases

                        3'b000: if (zero) state <= `cpus_fetchi; 
                                else state <= `cpus_read;
                        3'b001: if (!zero) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b010: if (carry) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b011: if (!carry) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b100: if (parity) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b101: if (!parity) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b110: if (sign) state <= `cpus_fetchi;
                                else state <= `cpus_read;
                        3'b111: if (!sign) state <= `cpus_fetchi;
                                else state <= `cpus_read;

                     endcase
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b000111, 6'b001111, 6'b010111, 6'b011111, 6'b100111, 
                  6'b101111, 6'b110111, 6'b111111: begin // RST

                     pc <= opcode & 8'b00111000; // place restart value in PC
                     waddrhold <= sp-16'h2; // place address on stack
                     // if interrupt cycle, use current pc, else use address
                     // after call
                     if (intcyc) { wdatahold2, wdatahold } <= pc;
                     else { wdatahold2, wdatahold } <= pc+16'h3;
                     { wdatahold2, wdatahold } <= pc+16'h1; // of address after call
                     sp <= sp-16'h2; // pushdown stack CNS
                     statesel <= `mac_writedbyte; // finish RST
                     state <= `cpus_write; // write to stack

                  end

                  6'b111011: begin // EI

                     eienb <= 1'b1; // set delayed interrupt enable
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b110011: begin // DI

                     ei <= 1'b0;
                     state <= `cpus_fetchi; // Fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

                  6'b011011: begin // IN p

`ifndef NOIO
                     // perform input
                     raddrhold <= pc+1; // pick up byte I/O address
                     statesel <= `mac_in; // finish IN
                     state <= `cpus_read;
                     pc <= pc+16'h2; // advance over byte
`else
                     // ignore instruction
                     state <= `cpus_fetchi; // fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte
`endif       

                  end

                  6'b010011: begin // OUT p

`ifndef NOIO
                     // perform output
                     raddrhold <= pc+1; // pick up byte I/O address
                     statesel <= `mac_out; // finish OUT
                     state <= `cpus_read;
                     pc <= pc+16'h2; // advance over byte
`else
                     // ignore instruction
                     state <= `cpus_fetchi; // fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte
`endif       

                  end

                  // the illegal opcodes behave as NOPs

                  6'b001011, 6'b011001, 6'b011101, 6'b101101, 
                  6'b111101: begin

                     state <= `cpus_fetchi; // fetch next instruction
                     pc <= pc+16'h1; // Next instruction byte

                  end

               endcase

            end
            
         endcase
                
      end

      // Follow states. These state handlers implement the following cycles past
      // M1, or primary fetch state.
      
      //
      // single byte write, writes wdatahold to the waddrhold address
      //

      `cpus_write: begin

         addr <= waddrhold; // place address on output
         waddrhold <= waddrhold + 1'b1; // next address
         datao <= wdatahold; // set data to output
         wdatahold <= wdatahold2; // next data
         dataeno <= 1; // enable output data
         state <= `cpus_write2; // next state
         
      end

      `cpus_write2: begin // continue write #2

         writemem <= 1; // enable write memory data
         state <= `cpus_write3; // idle one cycle for write

      end

      `cpus_write3: begin // continue write #3

`ifndef NOWAIT
         if (!waitr) 
`endif
            begin // no wait selected, otherwise cycle

            writemem <= 0; // disable write memory data
            state <= `cpus_write4; // idle hold time

         end

      end

      `cpus_write4: begin // continue write #4

         dataeno <= 0; // disable output data
         state <= nextstate; // get next macro state
         statesel <= statesel+6'b1; // and index next in macro 

      end

      //
      // single byte read, reads rdatahold from the raddrhold address
      //

      `cpus_read: begin

         addr <= raddrhold; // place address on output
         raddrhold <= raddrhold + 16'h1; // next address
         if (intcyc) inta <= 1; // activate interrupt acknowledge
         else readmem <= 1; // activate memory read
         state <= `cpus_read2; // next state
         
      end

      `cpus_read2: begin // continue read #2

         // wait one cycle
         state <= `cpus_read3; // next state

      end

      `cpus_read3: begin // continue read #3

`ifndef NOWAIT
         if (!waitr) 
`endif
            begin // no wait selected, otherwise cycle

            rdatahold2 <= rdatahold; // shift data
            rdatahold <= data; // read new data
            readmem <= 0; // deactivate instruction memory read
            inta <= 0; // deactivate interrupt acknowledge
            state <= nextstate; // get next macro state
            statesel <= statesel+6'b1; // and index next in macro 

         end

      end

      `cpus_pop: begin // finish POP instruction

         case (popdes) // register set

            2'b00: { regfil[`reg_b], regfil[`reg_c] } <= 
                      { rdatahold, rdatahold2 };
            2'b01: { regfil[`reg_d], regfil[`reg_e] } <= 
                      { rdatahold, rdatahold2 };
            2'b10: { regfil[`reg_h], regfil[`reg_l] } <= 
                      { rdatahold, rdatahold2 };
            2'b11: begin

               regfil[`reg_a] <= rdatahold;
               sign   <= ((rdatahold2 >> 7)& 1'b1) ? 1'b1:1'b0;
               zero   <= ((rdatahold2 >> 6)& 1'b1) ? 1'b1:1'b0;
               auxcar <= ((rdatahold2 >> 4)& 1'b1) ? 1'b1:1'b0;
               parity <= ((rdatahold2 >> 2)& 1'b1) ? 1'b1:1'b0;
               carry  <= ((rdatahold2 >> 0)& 1'b1) ? 1'b1:1'b0;

            end

         endcase
         state <= `cpus_fetchi; // Fetch next instruction

      end

      `cpus_jmp: begin // jump address

         state <= `cpus_fetchi; // and return to instruction fetch
         pc <= { rdatahold, rdatahold2 };

      end

      `cpus_call: begin // call address

         sp <= sp-16'h2; // pushdown stack
         state <= `cpus_fetchi; // and return to instruction fetch
         pc <= { rdatahold, rdatahold2 };

      end

      `cpus_ret: begin // return from call

         sp <= sp+16'h2; // pushup stack
         state <= `cpus_fetchi; // and return to instruction fetch
         pc <= { rdatahold, rdatahold2 };

      end

`ifndef NOIO // if I/O instructions are to be included
      `cpus_in: begin // input single byte to A

         addr <= rdatahold; // place I/O address on address lines
         readio <= 1; // set read I/O
         state <= `cpus_in2; // continue

      end

      `cpus_in2: begin // input single byte to A #2
         
         // wait one cycle
         state <= `cpus_in3; // continue

      end

      `cpus_in3: begin // input single byte to A #3

`ifndef NOWAIT
         if (!waitr) 
`endif
            begin // no wait selected, otherwise cycle

            regfil[`reg_a] <= data; // place input data
            readio <= 0; // clear read I/O
            state <= `cpus_fetchi; // Fetch next instruction

         end

      end

      `cpus_out: begin // output single byte from A

         addr <= rdatahold; // place address on output
         datao <= regfil[`reg_a]; // set data to output
         dataeno <= 1; // enable output data
         state <= `cpus_out2; // next state
         
      end

      `cpus_out2: begin // continue out #2

         writeio <= 1; // enable write I/O data
         state <= `cpus_out3; // idle one cycle for write

      end

      `cpus_out3: begin // continue out #3

`ifndef NOWAIT
         if (!waitr) 
`endif
            begin // no wait selected, otherwise cycle

            writeio <= 0; // disable write I/O data
            state <= `cpus_out4; // idle hold time

         end

      end

      `cpus_out4: begin // continue write #4

         dataeno <= 0; // disable output data
         state <= `cpus_fetchi; // Fetch next instruction

      end
`endif

      `cpus_halt: begin // Halt waiting for interrupt

         // If there is an interrupt request and interrupts are enabled, then we
         // can leave halt. Otherwise we stay here.
         if (intr&&ei) state <= `cpus_fetchi; // Fetch next instruction
         else state <= `cpus_halt;

      end

      `cpus_movtr: begin // move to register

         regfil[regd] <= rdatahold; // place data
         state <= nextstate; // get next macro state
         statesel <= statesel+6'b1; // and index next in macro 

      end

      `cpus_movtalua: begin // move to alu a

         aluopra <= rdatahold; // place data
         state <= nextstate; // get next macro state
         statesel <= statesel+6'b1; // and index next in macro 

      end

      `cpus_movtalub: begin // move to alu b

         aluoprb <= rdatahold; // place data
         state <= nextstate; // get next macro state
         statesel <= statesel+6'b1; // and index next in macro 

      end

      `cpus_alucb: begin // alu cycleback

         regfil[`reg_a] <= alures; // place alu result back to A
         carry <= alucout; // place carry
         sign <= alusout; // place sign
         zero <= aluzout; // place zero
         parity <= alupar; // place parity
         auxcar <= aluaxc; // place auxiliary carry
         state <= `cpus_fetchi; // and return to instruction fetch

      end

      `cpus_indcb: begin // inr/dcr cycleback

         regfil[regd] <= alures; // place alu result back to source/dest
         sign <= alures[7]; // place sign
         zero <= aluzout; // place zero
         parity <= alupar; // place parity
         auxcar <= aluaxc; // place auxiliary carry
         state <= `cpus_fetchi; // and return to instruction fetch

      end

      `cpus_indm: begin // inr/dcr cycleback to m

         waddrhold <= regfil[`reg_h]<<8|regfil[`reg_l]; // place address
         wdatahold <= alures; // place data to write
         sign <= alures[7]; // place sign
         zero <= aluzout; // place zero
         parity <= alupar; // place parity
         auxcar <= aluaxc; // place auxiliary carry
         state <= nextstate; // get next macro state
         statesel <= statesel+6'b1; // and index next in macro 

      end

      `cpus_movmtbc: begin // finish LXI B

         regfil[`reg_b] <= rdatahold; // place upper
         regfil[`reg_c] <= rdatahold2; // place lower
         state <= `cpus_fetchi; // and return to instruction fetch

      end

      `cpus_movmtde: begin // finish LXI D

         regfil[`reg_d] <= rdatahold; // place upper
         regfil[`reg_e] <= rdatahold2; // place lower
         state <= `cpus_fetchi; // and return to instruction fetch

      end

      `cpus_movmthl: begin // finish LXI H

         regfil[`reg_h] <= rdatahold; // place upper
         regfil[`reg_l] <= rdatahold2; // place lower
         state <= `cpus_fetchi; // and return to instruction fetch

      end

      `cpus_movmtsp: begin // finish LXI SP

         sp <= { rdatahold, rdatahold2 }; // place
         state <= `cpus_fetchi; // and return to instruction fetch

      end

      `cpus_movrtw: begin // move read to write

         wdatahold <= rdatahold; // move read to write data
         state <= nextstate; // get next macro state
         statesel <= statesel+6'b1; // and index next in macro

      end

      `cpus_movrtwa: begin // move read data to write address

         waddrhold <= { rdatahold, rdatahold2 };
         state <= nextstate; // get next macro state
         statesel <= statesel+6'b1; // and index next in macro

      end

      `cpus_movrtra: begin // move read data to read address

         raddrhold <= { rdatahold, rdatahold2 };
         state <= nextstate; // get next macro state
         statesel <= statesel+6'b1; // and index next in macro

      end

      `cpus_lhld: begin // load HL from read data

         regfil[`reg_l] <= rdatahold2; // low
         regfil[`reg_h] <= rdatahold; // high
         state <= nextstate; // get next macro state
         statesel <= statesel+6'b1; // and index next in macro CNS

      end

      `cpus_accimm: begin

         aluoprb <= rdatahold; // load as alu b
         state <= `cpus_alucb; // go to alu cycleback

      end

      `cpus_daa: begin

         if (regfil[`reg_a][7:4] > 9 || carry)
            { carry, regfil[`reg_a] } <= regfil[`reg_a]+8'h60;
         state <= `cpus_fetchi; // and return to instruction fetch

      end

      default: state <= 5'bx;

   endcase

   // Enable drive for data output
   assign data = dataeno ? datao: 8'bz;

   //
   // State macro generator
   //
   // This ROM contains series of state execution lists that perform various
   // tasks, usually involving reads or writes.
   //

   always @(statesel) case (statesel)

      // mac_writebyte: write a byte

       1: nextstate = `cpus_fetchi; // fetch next instruction

      // mac_readbtoreg: read a byte, place in register

       2: nextstate = `cpus_movtr; // move to register
       3: nextstate = `cpus_fetchi; // Fetch next instruction

      // mac_readdtobc: read double byte to BC

       4: nextstate = `cpus_read; // get high byte
       5: nextstate = `cpus_movmtbc; // place in BC

      // mac_readdtode: read double byte to DE

       6: nextstate = `cpus_read; // get high byte
       7: nextstate = `cpus_movmtde; // place in DE

      // mac_readdtohl: read double byte to HL

       8: nextstate = `cpus_read; // get high byte
       9: nextstate = `cpus_movmthl; // place in HL

      // mac_readdtosp: read double byte to SP

      10: nextstate = `cpus_read; // get high byte
      11: nextstate = `cpus_movmtsp; // place in SP

      // mac_readbmtw: read byte and move to write

      12: nextstate = `cpus_movrtw; // move read to write 
      13: nextstate = `cpus_write; // write to destination
      14: nextstate = `cpus_fetchi; // Fetch next instruction

      // mac_readbmtr: read byte and move to register

      15: nextstate = `cpus_movtr; // place in register
      16: nextstate = `cpus_fetchi; // Fetch next instruction

      // mac_sta: STA

      17: nextstate = `cpus_read; // read high byte
      18: nextstate = `cpus_movrtwa; // move read to write address
      19: nextstate = `cpus_write; // write to destination
      20: nextstate = `cpus_fetchi; // Fetch next instruction

      // mac_lda: LDA

      21: nextstate = `cpus_read; // read high byte
      22: nextstate = `cpus_movrtra; // move read to write address
      23: nextstate = `cpus_read; // read byte
      24: nextstate = `cpus_movtr; // move to register
      25: nextstate = `cpus_fetchi; // Fetch next instruction

      // mac_shld: SHLD

      26: nextstate = `cpus_read; // read high byte
      27: nextstate = `cpus_movrtwa; // move read to write address
      28: nextstate = `cpus_write; // write to destination low
      29: nextstate = `cpus_write; // write to destination high
      30: nextstate = `cpus_fetchi; // Fetch next instruction

      // mac_lhld: LHLD

      31: nextstate = `cpus_read; // read high byte
      32: nextstate = `cpus_movrtra; // move read to write address
      33: nextstate = `cpus_read; // read byte low
      34: nextstate = `cpus_read; // read byte high
      35: nextstate = `cpus_lhld; // move to register
      36: nextstate = `cpus_fetchi; // Fetch next instruction

      // mac_writedbyte: write double byte

      37: nextstate = `cpus_write; // double write
      38: nextstate = `cpus_fetchi; // then fetch

      // mac_pop: POP

      39: nextstate = `cpus_read; // double it
      40: nextstate = `cpus_pop; // then finish

      // mac_xthl: XTHL

      41: nextstate = `cpus_read; // double it
      42: nextstate = `cpus_write; // then write
      43: nextstate = `cpus_write; // double it
      44: nextstate = `cpus_movmthl; // place word in hl

      // mac_accimm: accumulator immediate

      45: nextstate = `cpus_accimm; // finish

      // mac_jmp: JMP

      46: nextstate = `cpus_read; // double read
      47: nextstate = `cpus_jmp; // then go pc

      // mac_call: CALL

      48: nextstate = `cpus_read; // double read
      49: nextstate = `cpus_write; // then write
      50: nextstate = `cpus_write; // double write
      51: nextstate = `cpus_call; // then go to that

      // mac_in: IN

      52: nextstate = `cpus_in; // go to IN after getting that

      // mac_out: OUT

      53: nextstate = `cpus_out; // go to OUT after getting that

      // mac_rst: RST

      54: nextstate = `cpus_write; // double write
      55: nextstate = `cpus_jmp; // then go to that

      // mac_ret: RET

      56: nextstate = `cpus_read; // double read
      57: nextstate = `cpus_ret; // then go to that

      // mac_alum: op a,m

      58: nextstate = `cpus_movtalub; // go move to alu a
      59: nextstate = `cpus_alucb; // cycle back to acc

      // mac_idm: inc/dec m

      60: nextstate = `cpus_movtalua; // go move to alu b
      61: nextstate = `cpus_indm; // set up alu result
      62: nextstate = `cpus_write; // write it
      63: nextstate = `cpus_fetchi; // Fetch next instruction

      default nextstate = 6'bx; // other states never reached

   endcase

endmodule

//
// Alu module
//
// Finds arithmetic operations needed. Latches on the positive edge of the
// clock. There are 8 different types of operations, which come from bits
// 3-5 of the instruction.
//

module alu(res, opra, oprb, cin, cout, zout, sout, parity, auxcar, sel);

   input  [7:0] opra;   // Input A
   input  [7:0] oprb;   // Input B
   input        cin;    // Carry in
   output       cout;   // Carry out
   output       zout;   // Zero out
   output       sout;   // Sign out
   output       parity; // parity
   output       auxcar; // auxiliary carry
   input  [2:0] sel;    // Operation select
   output [7:0] res;    // Result of alu operation
   
   reg       cout;   // Carry out
   reg       zout;   // Zero out
   reg       sout;   // sign out
   reg       parity; // parity
   reg       auxcar; // auxiliary carry
   reg [7:0] resi;   // Result of alu operation intermediate
   reg [7:0] res;    // Result of alu operation

   always @(opra, oprb, cin, sel, res, resi) begin

      case (sel)
      
         `aluop_add: begin // add

            { cout, resi } = opra+oprb; // find result and carry
            // find auxiliary carry
            auxcar = (((opra[3:0]+oprb[3:0]) >> 4) & 8'b1) ? 1'b1 : 1'b0;

         end
         `aluop_adc: begin // adc

            { cout, resi } = opra+oprb+cin; // find result and carry
            // find auxiliary carry
            auxcar = (((opra[3:0]+oprb[3:0]+cin) >> 4) & 8'b1) ? 1'b1 : 1'b0;

         end
         `aluop_sub, `aluop_cmp: begin // sub/cmp

            { cout, resi } = opra-oprb; // find result and carry
            // find auxiliary borrow
            auxcar = (((opra[3:0]-oprb[3:0]) >> 4) & 8'b1) ? 1'b1 : 1'b0;

         end
         `aluop_sbb: begin // sbb

            { cout, resi } = opra-oprb-cin; // find result and carry
            // find auxiliary borrow 
            auxcar = (((opra[3:0]-oprb[3:0]-cin >> 4)) & 8'b1) ? 1'b1 : 1'b0;

         end
         `aluop_and: begin // ana

            { cout, resi } = {1'b0, opra&oprb}; // find result and carry
            auxcar = 1'b0; // clear auxillary carry

          end
         `aluop_xor: begin // xra

            { cout, resi } = {1'b0, opra^oprb}; // find result and carry
            auxcar = 1'b0; // clear auxillary carry

         end
         `aluop_or:  begin // ora

            { cout, resi } = {1'b0, opra|oprb}; // find result and carry
            auxcar = 1'b0; // clear auxillary carry

         end
                     
      endcase

      if (sel != `aluop_cmp) res = resi; else res = opra;
      zout <= ~|resi; // set zero flag from result
      sout <= resi[7]; // set sign flag from result
      parity <= ~^resi; // set parity flag from result

   end

endmodule