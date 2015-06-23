



This component comes from the opencores t6507lp  project and makes it socgen compatible. The original project checked in by   Gabriel Oshiro Zardo and Samuel Nascimento Pagliarini was a atari 2600 on a chip. This project only takes the t6507 processor and uses it as a 6502.  It had some documentation and a  test suite that was somewhat working.

I chose it because a 6502 is  a useful module and had clean partitioning. The following changes were made:



1) Converted to a full 16 bit address bus.

   also hardcoded the 8 bit data bus. Hasn't changed in thirty five years.

2) Converted parameters to `defines

3) Converted reset to synchronous active high

4) Converted test suite to socgen format

   Each test is in it's own subdirectory and any needed code is assembled and loaded into sram

5) Design had no reset/interrupt vectors. Added reset vector. May add interupt(s) later.

6) Added enable logic so that it could work with synchronous sram

7) Design doesn't appear to be fully functional.  
    CLC followed by BCC missed the offset by one clock cycle.
    JSR doesn't push high address on stack. puts wrong data in page 00
    Branch backwards doesn't work. 
    read/modify/write did not work
    pha pushed onto page 0
    pha data latched one clock to late
    jmp indirect didn't work

8) Split T6502_fsm into smaller blocks for ease of documenting and verifying

9) Move branch decision logic into sequencer block

10) removed BCD logic

11) moved alu_opcode to instr_decode block

12) created datapath logic for alu_operand_a, alu_operand_b and alu_operand_c

13) split alu into alu_control and alu blocks

14) reworked the inst_decode signals to alu and pulled datapath out of sequencer

15) removed the latched alu_result. Outside of alu now uses raw




This appears to be a work in progress with numerous issues. I fixed enough of them so that I can
synthesize into an fpga and it runs the io_poll program on a Nexys2 Board. I will commit this as
a start but it is alpha code and will have bugs.
