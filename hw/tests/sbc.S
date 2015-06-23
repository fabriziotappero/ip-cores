/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests 64-bit subtractions using sbc (subtract with carry)   //
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

        mov     r12, #0
        
        
loop:   ldr     r0, AdrData1
        add     r0, r0, r12, lsl #3  @ double-word elements
        ldr     r1, [r0], #4
        ldr     r2, [r0]
        
        ldr     r3, AdrData2
        add     r3, r3, r12, lsl #3  @ double-word elements
        ldr     r4, [r3], #4
        ldr     r5, [r3]
        
        @ {r1, r2} - {r4, r5}
        subs    r6, r2, r5
        sbc     r7, r1, r4
        
        ldr     r0, AdrAnswers
        add     r0, r0, r12, lsl #3  @ double-word elements
        ldr     r1, [r0], #4
        ldr     r2, [r0]
        
        cmp     r1, r7
        movne   r10, #10
        bne     testfail
        cmp     r2, r6
        movne   r10, #20
        bne     testfail
        
        @ increment loop counter
        cmp     r12, #2
        beq     testpass
        add     r12, r12, #1
        b       loop

testfail:
        ldr     r11, AdrTestStatus
        str     r10, [r11]
        b       testfail
        
testpass:             
        ldr     r11, AdrTestStatus
        mov     r10, #17
        str     r10, [r11]
        b       testpass

                

/* Write 17 to this address to generate a Test Passed message */
AdrTestStatus:  .word  ADR_AMBER_TEST_STATUS
AdrData1:       .word  Data1
AdrData2:       .word  Data2
AdrAnswers:     .word  Answers

Data1:
@ HiWord, LoWord
.word 0x10000000
.word 0x00000001
.word 0x10000000
.word 0x00000000
.word 0x00000001
.word 0xc8d14800

Data2:
@ HiWord, LoWord
.word 0x08000000
.word 0x00000001
.word 0x08000000
.word 0xffffffff
.word 0x00000000
.word 0x3b9aca00

Answers:
@ HiWord, LoWord
.word 0x08000000
.word 0x00000000
.word 0x07ffffff
.word 0x00000001
.word 0x00000001
.word 0x8d367e00


/* ========================================================================= */
/* ========================================================================= */
        

