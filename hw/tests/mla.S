/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests the mla (multiply and accumulate) instruction.        // 
//                                                              //
//  Uses a testset of 16 numbers and multiplies them            //
//  with each other in every combination.                       //
//  Checks each result against an expected result               //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
*****************************************************************/

#include "amber_registers.h"

	.section .text
	.globl	main        
main:       
        @ -------------------------------
        @ Test mla
        @ -------------------------------
        mov     r6, #0
        ldr     r8, AdrTestset
        
        
loop:   and     r2, r6, #0xf
        ldr     r7, [r8, r2, lsl #2]
        
        and     r4, r6, #0xf0
        ldr     r5, [r8, r4, lsr #2]
        
        and     r9,  r6, #0xf00
        ldr     r4, [r8, r9, lsr #6]
        
        mla     r12, r7, r5, r4
                
        @ -------------------------------
        @ Check Result
        @ -------------------------------
        ldr     r9,  AdrAnswers
        ldr     r10, [r9, r6, lsl #2]
        cmp     r12, r10
        bne     testfail
        
        add     r6, r6, #1
        cmp     r6, #512
        beq     test2       
        b       loop        



test2:
        @-------------------------------
        @ Test Flags
        @ Ensure that C and V retain their
        @ old values
        @ -------------------------------
        @ clear flags first
        mov     r2, pc
        ldr     r7, PCMask
        bic     r2, r2, r7          @ clear pc bits
        bic     r2, r2, #0xf0000000 @ clear condition clags
        orr     r2, r2, #0x10000000 @ set C and V flags
        teqp    pc, r2
    
        mov     r0, #0
        mov     r1, #-1
        mov     r3, #-27
        
        
        @  mla{<cond>}{S} <Rd>, <Rm>, <Rs>, <Rn>
        @  Rd = (Rm * Rs + Rn)[31:0]
        mlas    r5, r0, r1, r3

        mov     r4, pc
        ldr     r7, PCMask
        bic     r4, r4, r7          @ clear pc bits
        and     r4, r4, #0xf0000000 @ clear non-flag bits
        cmp     r4,     #0x90000000 @ negate flag ( bit [31] ) set by mlas
        movne   r10, #110
        bne     testfail2

        cmp     r5, #-27
        movne   r10, #120
        bne     testfail2


test3:
        @-------------------------------
        @ Test complex sequence of instructions
        @ -------------------------------
        mov     r0, #1
        mov     r1, #2
        mov     r2, #7
        mov     r3, #3
        mov     r4, #5
        mov     r5, #6
        mov     r6, #7

        cmp     r0, #-1
        ldreq   r1, Data1
        ldrne   r2, Data2
        
        @  mla{<cond>}{S} <Rd>, <Rm>, <Rs>, <Rn>
        @  Rd = (Rm * Rs + Rn)[31:0]
        mlane   r3, r1, r2, r4
        ldreq   r5, Data3
        ldrne   r6, Data3
        
        cmp     r3, #19
        movne   r10, #200
        bne     testfail2
        
        cmp     r5, #6
        movne   r10, #210
        bne     testfail2
        
        cmp     r6, #0
        movne   r10, #220
        bne     testfail2
        

@ ------------------------------------------        
@ ------------------------------------------        

        b       testpass

testfail:
        ldr     r11, AdrTestStatus
        str     r10, [r11]
        b       testfail
        
        
testfail2:
        ldr     r11, AdrTestStatus
        str     r10, [r11]
        b       testfail2
        
testpass:             
        ldr     r11, AdrTestStatus
        mov     r10, #17
        str     r10, [r11]
        b       testpass
                       
               
@ ------------------------------------------        
@ ------------------------------------------        

/* Write 17 to this address to generate a Test Passed message */
AdrTestStatus:  .word  ADR_AMBER_TEST_STATUS
AdrTestset:     .word  Testset
AdrAnswers:     .word  Answers
Data1:          .word  0x3
Data2:          .word  0x7
Data3:          .word  0
PCMask:         .word  0x03fffffc


Testset:
.word  0
.word  1
.word  2
.word  3 
.word  27
.word  0x0000ffff
.word  0x40000000
.word  0x7fffffff 
.word  0x7ffffffe
.word  0xffffffff
.word  0xfffffffe
.word  0xfffffffd 
.word  0xffffffe5
.word  0x8fff0000
.word  0x80000000
.word  0x80000001


Answers:      
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000001
.word 0x00000002
.word 0x00000003
.word 0x0000001b
.word 0x0000ffff
.word 0x40000000
.word 0x7fffffff
.word 0x7ffffffe
.word 0xffffffff
.word 0xfffffffe
.word 0xfffffffd
.word 0xffffffe5
.word 0x8fff0000
.word 0x80000000
.word 0x80000001
.word 0x00000000
.word 0x00000002
.word 0x00000004
.word 0x00000006
.word 0x00000036
.word 0x0001fffe
.word 0x80000000
.word 0xfffffffe
.word 0xfffffffc
.word 0xfffffffe
.word 0xfffffffc
.word 0xfffffffa
.word 0xffffffca
.word 0x1ffe0000
.word 0x00000000
.word 0x00000002
.word 0x00000000
.word 0x00000003
.word 0x00000006
.word 0x00000009
.word 0x00000051
.word 0x0002fffd
.word 0xc0000000
.word 0x7ffffffd
.word 0x7ffffffa
.word 0xfffffffd
.word 0xfffffffa
.word 0xfffffff7
.word 0xffffffaf
.word 0xaffd0000
.word 0x80000000
.word 0x80000003
.word 0x00000000
.word 0x0000001b
.word 0x00000036
.word 0x00000051
.word 0x000002d9
.word 0x001affe5
.word 0xc0000000
.word 0x7fffffe5
.word 0x7fffffca
.word 0xffffffe5
.word 0xffffffca
.word 0xffffffaf
.word 0xfffffd27
.word 0x2fe50000
.word 0x80000000
.word 0x8000001b
.word 0x00000000
.word 0x0000ffff
.word 0x0001fffe
.word 0x0002fffd
.word 0x001affe5
.word 0xfffe0001
.word 0xc0000000
.word 0x7fff0001
.word 0x7ffe0002
.word 0xffff0001
.word 0xfffe0002
.word 0xfffd0003
.word 0xffe5001b
.word 0x70010000
.word 0x80000000
.word 0x8000ffff
.word 0x00000000
.word 0x40000000
.word 0x80000000
.word 0xc0000000
.word 0xc0000000
.word 0xc0000000
.word 0x00000000
.word 0xc0000000
.word 0x80000000
.word 0xc0000000
.word 0x80000000
.word 0x40000000
.word 0x40000000
.word 0x00000000
.word 0x00000000
.word 0x40000000
.word 0x00000000
.word 0x7fffffff
.word 0xfffffffe
.word 0x7ffffffd
.word 0x7fffffe5
.word 0x7fff0001
.word 0xc0000000
.word 0x00000001
.word 0x80000002
.word 0x80000001
.word 0x00000002
.word 0x80000003
.word 0x8000001b
.word 0x70010000
.word 0x80000000
.word 0xffffffff
.word 0x00000000
.word 0x7ffffffe
.word 0xfffffffc
.word 0x7ffffffa
.word 0x7fffffca
.word 0x7ffe0002
.word 0x80000000
.word 0x80000002
.word 0x00000004
.word 0x80000002
.word 0x00000004
.word 0x80000006
.word 0x80000036
.word 0xe0020000
.word 0x00000000
.word 0x7ffffffe
.word 0x00000000
.word 0xffffffff
.word 0xfffffffe
.word 0xfffffffd
.word 0xffffffe5
.word 0xffff0001
.word 0xc0000000
.word 0x80000001
.word 0x80000002
.word 0x00000001
.word 0x00000002
.word 0x00000003
.word 0x0000001b
.word 0x70010000
.word 0x80000000
.word 0x7fffffff
.word 0x00000000
.word 0xfffffffe
.word 0xfffffffc
.word 0xfffffffa
.word 0xffffffca
.word 0xfffe0002
.word 0x80000000
.word 0x00000002
.word 0x00000004
.word 0x00000002
.word 0x00000004
.word 0x00000006
.word 0x00000036
.word 0xe0020000
.word 0x00000000
.word 0xfffffffe
.word 0x00000000
.word 0xfffffffd
.word 0xfffffffa
.word 0xfffffff7
.word 0xffffffaf
.word 0xfffd0003
.word 0x40000000
.word 0x80000003
.word 0x80000006
.word 0x00000003
.word 0x00000006
.word 0x00000009
.word 0x00000051
.word 0x50030000
.word 0x80000000
.word 0x7ffffffd
.word 0x00000000
.word 0xffffffe5
.word 0xffffffca
.word 0xffffffaf
.word 0xfffffd27
.word 0xffe5001b
.word 0x40000000
.word 0x8000001b
.word 0x80000036
.word 0x0000001b
.word 0x00000036
.word 0x00000051
.word 0x000002d9
.word 0xd01b0000
.word 0x80000000
.word 0x7fffffe5
.word 0x00000000
.word 0x8fff0000
.word 0x1ffe0000
.word 0xaffd0000
.word 0x2fe50000
.word 0x70010000
.word 0x00000000
.word 0x70010000
.word 0xe0020000
.word 0x70010000
.word 0xe0020000
.word 0x50030000
.word 0xd01b0000
.word 0x00000000
.word 0x00000000
.word 0x8fff0000
.word 0x00000000
.word 0x80000000
.word 0x00000000
.word 0x80000000
.word 0x80000000
.word 0x80000000
.word 0x00000000
.word 0x80000000
.word 0x00000000
.word 0x80000000
.word 0x00000000
.word 0x80000000
.word 0x80000000
.word 0x00000000
.word 0x00000000
.word 0x80000000
.word 0x00000000
.word 0x80000001
.word 0x00000002
.word 0x80000003
.word 0x8000001b
.word 0x8000ffff
.word 0x40000000
.word 0xffffffff
.word 0x7ffffffe
.word 0x7fffffff
.word 0xfffffffe
.word 0x7ffffffd
.word 0x7fffffe5
.word 0x8fff0000
.word 0x80000000
.word 0x00000001
.word 0x00000001
.word 0x00000001
.word 0x00000001
.word 0x00000001
.word 0x00000001
.word 0x00000001
.word 0x00000001
.word 0x00000001
.word 0x00000001
.word 0x00000001
.word 0x00000001
.word 0x00000001
.word 0x00000001
.word 0x00000001
.word 0x00000001
.word 0x00000001
.word 0x00000001
.word 0x00000002
.word 0x00000003
.word 0x00000004
.word 0x0000001c
.word 0x00010000
.word 0x40000001
.word 0x80000000
.word 0x7fffffff
.word 0x00000000
.word 0xffffffff
.word 0xfffffffe
.word 0xffffffe6
.word 0x8fff0001
.word 0x80000001
.word 0x80000002
.word 0x00000001
.word 0x00000003
.word 0x00000005
.word 0x00000007
.word 0x00000037
.word 0x0001ffff
.word 0x80000001
.word 0xffffffff
.word 0xfffffffd
.word 0xffffffff
.word 0xfffffffd
.word 0xfffffffb
.word 0xffffffcb
.word 0x1ffe0001
.word 0x00000001
.word 0x00000003
.word 0x00000001
.word 0x00000004
.word 0x00000007
.word 0x0000000a
.word 0x00000052
.word 0x0002fffe
.word 0xc0000001
.word 0x7ffffffe
.word 0x7ffffffb
.word 0xfffffffe
.word 0xfffffffb
.word 0xfffffff8
.word 0xffffffb0
.word 0xaffd0001
.word 0x80000001
.word 0x80000004
.word 0x00000001
.word 0x0000001c
.word 0x00000037
.word 0x00000052
.word 0x000002da
.word 0x001affe6
.word 0xc0000001
.word 0x7fffffe6
.word 0x7fffffcb
.word 0xffffffe6
.word 0xffffffcb
.word 0xffffffb0
.word 0xfffffd28
.word 0x2fe50001
.word 0x80000001
.word 0x8000001c
.word 0x00000001
.word 0x00010000
.word 0x0001ffff
.word 0x0002fffe
.word 0x001affe6
.word 0xfffe0002
.word 0xc0000001
.word 0x7fff0002
.word 0x7ffe0003
.word 0xffff0002
.word 0xfffe0003
.word 0xfffd0004
.word 0xffe5001c
.word 0x70010001
.word 0x80000001
.word 0x80010000
.word 0x00000001
.word 0x40000001
.word 0x80000001
.word 0xc0000001
.word 0xc0000001
.word 0xc0000001
.word 0x00000001
.word 0xc0000001
.word 0x80000001
.word 0xc0000001
.word 0x80000001
.word 0x40000001
.word 0x40000001
.word 0x00000001
.word 0x00000001
.word 0x40000001
.word 0x00000001
.word 0x80000000
.word 0xffffffff
.word 0x7ffffffe
.word 0x7fffffe6
.word 0x7fff0002
.word 0xc0000001
.word 0x00000002
.word 0x80000003
.word 0x80000002
.word 0x00000003
.word 0x80000004
.word 0x8000001c
.word 0x70010001
.word 0x80000001
.word 0x00000000
.word 0x00000001
.word 0x7fffffff
.word 0xfffffffd
.word 0x7ffffffb
.word 0x7fffffcb
.word 0x7ffe0003
.word 0x80000001
.word 0x80000003
.word 0x00000005
.word 0x80000003
.word 0x00000005
.word 0x80000007
.word 0x80000037
.word 0xe0020001
.word 0x00000001
.word 0x7fffffff
.word 0x00000001
.word 0x00000000
.word 0xffffffff
.word 0xfffffffe
.word 0xffffffe6
.word 0xffff0002
.word 0xc0000001
.word 0x80000002
.word 0x80000003
.word 0x00000002
.word 0x00000003
.word 0x00000004
.word 0x0000001c
.word 0x70010001
.word 0x80000001
.word 0x80000000
.word 0x00000001
.word 0xffffffff
.word 0xfffffffd
.word 0xfffffffb
.word 0xffffffcb
.word 0xfffe0003
.word 0x80000001
.word 0x00000003
.word 0x00000005
.word 0x00000003
.word 0x00000005
.word 0x00000007
.word 0x00000037
.word 0xe0020001
.word 0x00000001
.word 0xffffffff
.word 0x00000001
.word 0xfffffffe
.word 0xfffffffb
.word 0xfffffff8
.word 0xffffffb0
.word 0xfffd0004
.word 0x40000001
.word 0x80000004
.word 0x80000007
.word 0x00000004
.word 0x00000007
.word 0x0000000a
.word 0x00000052
.word 0x50030001
.word 0x80000001
.word 0x7ffffffe
.word 0x00000001
.word 0xffffffe6
.word 0xffffffcb
.word 0xffffffb0
.word 0xfffffd28
.word 0xffe5001c
.word 0x40000001
.word 0x8000001c
.word 0x80000037
.word 0x0000001c
.word 0x00000037
.word 0x00000052
.word 0x000002da
.word 0xd01b0001
.word 0x80000001
.word 0x7fffffe6
.word 0x00000001
.word 0x8fff0001
.word 0x1ffe0001
.word 0xaffd0001
.word 0x2fe50001
.word 0x70010001
.word 0x00000001
.word 0x70010001
.word 0xe0020001
.word 0x70010001
.word 0xe0020001
.word 0x50030001
.word 0xd01b0001
.word 0x00000001
.word 0x00000001
.word 0x8fff0001
.word 0x00000001
.word 0x80000001
.word 0x00000001
.word 0x80000001
.word 0x80000001
.word 0x80000001
.word 0x00000001
.word 0x80000001
.word 0x00000001
.word 0x80000001
.word 0x00000001
.word 0x80000001
.word 0x80000001
.word 0x00000001
.word 0x00000001
.word 0x80000001
.word 0x00000001
.word 0x80000002
.word 0x00000003
.word 0x80000004
.word 0x8000001c
.word 0x80010000
.word 0x40000001
.word 0x00000000
.word 0x7fffffff
.word 0x80000000
.word 0xffffffff
.word 0x7ffffffe
.word 0x7fffffe6
.word 0x8fff0001
.word 0x80000001
.word 0x00000002
.word 0x00000002
.word 0x00000002
.word 0x00000002
.word 0x00000002
.word 0x00000002
.word 0x00000002
.word 0x00000002
.word 0x00000002
.word 0x00000002
.word 0x00000002
.word 0x00000002
.word 0x00000002
.word 0x00000002
.word 0x00000002
.word 0x00000002
.word 0x00000002
.word 0x00000002
.word 0x00000003
.word 0x00000004
.word 0x00000005
.word 0x0000001d
.word 0x00010001
.word 0x40000002
.word 0x80000001
.word 0x80000000
.word 0x00000001
.word 0x00000000
.word 0xffffffff
.word 0xffffffe7
.word 0x8fff0002
.word 0x80000002
.word 0x80000003
.word 0x00000002
.word 0x00000004
.word 0x00000006
.word 0x00000008
.word 0x00000038
.word 0x00020000
.word 0x80000002
.word 0x00000000
.word 0xfffffffe
.word 0x00000000
.word 0xfffffffe
.word 0xfffffffc
.word 0xffffffcc
.word 0x1ffe0002
.word 0x00000002
.word 0x00000004
.word 0x00000002
.word 0x00000005
.word 0x00000008
.word 0x0000000b
.word 0x00000053
.word 0x0002ffff
.word 0xc0000002
.word 0x7fffffff
.word 0x7ffffffc
.word 0xffffffff
.word 0xfffffffc
.word 0xfffffff9
.word 0xffffffb1
.word 0xaffd0002
.word 0x80000002
.word 0x80000005
.word 0x00000002
.word 0x0000001d
.word 0x00000038
.word 0x00000053
.word 0x000002db
.word 0x001affe7
.word 0xc0000002
.word 0x7fffffe7
.word 0x7fffffcc
.word 0xffffffe7
.word 0xffffffcc
.word 0xffffffb1
.word 0xfffffd29
.word 0x2fe50002
.word 0x80000002
.word 0x8000001d
.word 0x00000002
.word 0x00010001
.word 0x00020000
.word 0x0002ffff
.word 0x001affe7
.word 0xfffe0003
.word 0xc0000002
.word 0x7fff0003
.word 0x7ffe0004
.word 0xffff0003
.word 0xfffe0004
.word 0xfffd0005
.word 0xffe5001d
.word 0x70010002
.word 0x80000002
.word 0x80010001
.word 0x00000002
.word 0x40000002
.word 0x80000002
.word 0xc0000002
.word 0xc0000002
.word 0xc0000002
.word 0x00000002
.word 0xc0000002
.word 0x80000002
.word 0xc0000002
.word 0x80000002
.word 0x40000002
.word 0x40000002
.word 0x00000002
.word 0x00000002
.word 0x40000002
.word 0x00000002
.word 0x80000001
.word 0x00000000
.word 0x7fffffff
.word 0x7fffffe7
.word 0x7fff0003
.word 0xc0000002
.word 0x00000003
.word 0x80000004
.word 0x80000003
.word 0x00000004
.word 0x80000005
.word 0x8000001d
.word 0x70010002
.word 0x80000002
.word 0x00000001
.word 0x00000002
.word 0x80000000
.word 0xfffffffe
.word 0x7ffffffc
.word 0x7fffffcc
.word 0x7ffe0004
.word 0x80000002
.word 0x80000004
.word 0x00000006
.word 0x80000004
.word 0x00000006
.word 0x80000008
.word 0x80000038
.word 0xe0020002
.word 0x00000002
.word 0x80000000
.word 0x00000002
.word 0x00000001
.word 0x00000000
.word 0xffffffff
.word 0xffffffe7
.word 0xffff0003
.word 0xc0000002
.word 0x80000003
.word 0x80000004
.word 0x00000003
.word 0x00000004
.word 0x00000005
.word 0x0000001d
.word 0x70010002
.word 0x80000002
.word 0x80000001
.word 0x00000002
.word 0x00000000
.word 0xfffffffe
.word 0xfffffffc
.word 0xffffffcc
.word 0xfffe0004
.word 0x80000002
.word 0x00000004
.word 0x00000006
.word 0x00000004
.word 0x00000006
.word 0x00000008
.word 0x00000038
.word 0xe0020002
.word 0x00000002
.word 0x00000000
.word 0x00000002
.word 0xffffffff
.word 0xfffffffc
.word 0xfffffff9
.word 0xffffffb1
.word 0xfffd0005
.word 0x40000002
.word 0x80000005
.word 0x80000008
.word 0x00000005
.word 0x00000008
.word 0x0000000b
.word 0x00000053
.word 0x50030002
.word 0x80000002
.word 0x7fffffff
.word 0x00000002
.word 0xffffffe7
.word 0xffffffcc
.word 0xffffffb1
.word 0xfffffd29
.word 0xffe5001d
.word 0x40000002
.word 0x8000001d
.word 0x80000038
.word 0x0000001d
.word 0x00000038
.word 0x00000053
.word 0x000002db
.word 0xd01b0002
.word 0x80000002
.word 0x7fffffe7
.word 0x00000002
.word 0x8fff0002
.word 0x1ffe0002
.word 0xaffd0002
.word 0x2fe50002
.word 0x70010002
.word 0x00000002
.word 0x70010002
.word 0xe0020002
.word 0x70010002
.word 0xe0020002
.word 0x50030002
.word 0xd01b0002
.word 0x00000002
.word 0x00000002
.word 0x8fff0002
.word 0x00000002
.word 0x80000002
.word 0x00000002
.word 0x80000002
.word 0x80000002
.word 0x80000002
.word 0x00000002
.word 0x80000002
.word 0x00000002
.word 0x80000002
.word 0x00000002
.word 0x80000002
.word 0x80000002
.word 0x00000002
.word 0x00000002
.word 0x80000002
.word 0x00000002
.word 0x80000003
.word 0x00000004
.word 0x80000005
.word 0x8000001d
.word 0x80010001
.word 0x40000002
.word 0x00000001
.word 0x80000000
.word 0x80000001
.word 0x00000000
.word 0x7fffffff
.word 0x7fffffe7
.word 0x8fff0002
.word 0x80000002
.word 0x00000003
.word 0x00000003
.word 0x00000003
.word 0x00000003
.word 0x00000003
.word 0x00000003
.word 0x00000003
.word 0x00000003
.word 0x00000003
.word 0x00000003
.word 0x00000003
.word 0x00000003
.word 0x00000003
.word 0x00000003
.word 0x00000003
.word 0x00000003
.word 0x00000003
.word 0x00000003
.word 0x00000004
.word 0x00000005
.word 0x00000006
.word 0x0000001e
.word 0x00010002
.word 0x40000003
.word 0x80000002
.word 0x80000001
.word 0x00000002
.word 0x00000001
.word 0x00000000
.word 0xffffffe8
.word 0x8fff0003
.word 0x80000003
.word 0x80000004
.word 0x00000003
.word 0x00000005
