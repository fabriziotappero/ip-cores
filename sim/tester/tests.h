/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

#ifndef __TESTS_H
#define __TESTS_H

#include "shared_mem.h"

//------------------------------------------------------------------------------

struct tst_t;

typedef void   (*func_init) (tst_t *tst, shared_mem_t *shared_ptr);


struct tst_t {
    func_init  init;
};

//------------------------------------------------------------------------------

uint32 rand_uint32();

//------------------------------------------------------------------------------

void arith_logic_till_exc_init  (tst_t *tst, shared_mem_t *shared_ptr);
void exception_till_exc_init    (tst_t *tst, shared_mem_t *shared_ptr);
void tlb_commands_till_exc_init (tst_t *tst, shared_mem_t *shared_ptr);
void branch_till_exc_init       (tst_t *tst, shared_mem_t *shared_ptr);
void data_till_exc_init         (tst_t *tst, shared_mem_t *shared_ptr);
void interrupt_till_exc_init    (tst_t *tst, shared_mem_t *shared_ptr);
void tlb_fetch_till_exc_init    (tst_t *tst, shared_mem_t *shared_ptr);
void tlb_data_till_exc_init     (tst_t *tst, shared_mem_t *shared_ptr);

//------------------------------------------------------------------------------

/*

000000  . SPECIAL
    [5:0]
    000000 SLL
    000001
    000010 SRL
    000011 SRA
    000100 SLLV
    000101
    000110 SRLV
    000111 SRAV
    
    001000 JR
    001001 JALR
    001010
    001011
    001100 SYSCALL
    001101 BREAK
    001110
    001111
    
    010000 MFHI
    010001 MTHI
    010010 MFLO
    010011 MTLO
    010100
    010101
    010110
    010111
    
    011000 MULT
    011001 MULTU
    011010 DIV
    011011 DIVU
    011100
    011101
    011110
    011111
    
    100000 ADD
    100001 ADDU
    100010 SUB
    100011 SUBU
    100100 AND
    100101 OR
    100110 XOR
    100111 NOR
    
    101000
    101001
    101010 SLT
    101011 SLTU
    101100
    101101
    101110
    101111
    
    110000
    110001
    110010
    110011
    110100
    110101
    110110
    110111
    
    111000
    111001
    111010
    111011
    111100
    111101
    111110
    111111
000001  .
    [20:16]
    00000 BLTZ
    00001 BGEZ
    10000 BLTZAL
    10001 BGEZAL

000010 J
000011 JAL
000100 BEQ
000101 BNE
000110 BLEZ rt must be 0
000111 BGTZ rt must be 0

001000 ADDI
001001 ADDIU
001010 SLTI
001011 SLTIU
001100 ANDI
001101 ORI
001110 XORI
001111 LUI

010000  .
010001  .
010010  .
010011  .
    [25:21]
    00000 MFCz
    00001
    00010 CFCz
    00011
    00100 MTCz
    00101
    00110 CTCz
    00111
    01000   . BC0
        [20:16]
        00000 BC0F
        00001 BC0T
        00010 ign
        00011 ign
        other Reserved Instruction
    01001
    01010
    01011
    01100
    01101
    01110
    01111
    10000   .
    10001   .
    10010   .
    10011   .
    10100   .
    10101   .
    10110   .
    10111   .
    11000   .
    11001   .
    11010   .
    11011   .
    11100   .
    11101   .
    11110   .
    11111   .
        COPz
        [5:0] for COP0
        000001 TLBR
        000010 TLBWI
        000110 TLBWR
        001000 TLBP
        010000 RFE
        other Reserved Instruction
010100
010101
010110
010111

011000
011001
011010
011011
011100
011101
011110
011111

100000 LB
100001 LH
100010 LWL
100011 LW
100100 LBU
100101 LHU
100110 LWR
100111

101000 SB
101001 SH
101010 SWL
101011 SW
101100
101101
101110 SWR
101111

110000  .
110001  .
110010  .
110011  .
    LWCz
    
110100
110101
110110
110111

111000  .
111001  .
111010  .
111011  .
    SWCz

111100
111101
111110
111111
*/

//------------------------------------------------------------------------------

#endif //__TESTS_H
