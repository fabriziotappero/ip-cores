/*****************************************************************
//                                                              //
//  Amber 2 Core Cache Test                                     //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests the interaction between a swap instruction            //
//  and the cache.                                              //
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

/*
Bug is caused by very subtle timing interactions in the Cache

It does not detect a hit, which it should, on the read phase of the swap
operation. It doesnt detect the hit because it is still completing
a fill started by the memory request to load an instructuion
at swap instruction + 8.
This only occurs when the swap target address is in the cache
but the cache instruction address is not, and the instruction
address the third of a group of 4 instruction words.

Test copies sequence to another bit of memory and runs it.
Repeats this a few times moving the sequence to slightly
different memory locations each time
*/

#include "amber_registers.h"

	.section .text
	.globl	main        
main:
                
        @ ------------------------------------------ 
        @ Copy code
        @ ------------------------------------------
        @ Copy code sequence to another area in memory
        mov     r13, #4
        
big_loop:        
        ldr     r9,  Loc1
        add     r9,  r9, r13
        mov     r11, r9
        
        ldr     r8,  Adrseq
        ldr     r10, Adrseqend

copy:        
        ldmia   r8!,  {r0-r7}
        stmia   r11!, {r0-r7}
        
        cmp     r8, r10
        blt     copy


        @ ------------------------------------------ 
        @ Enable and clear cache
        @ ------------------------------------------
        @ Enable the cache
        mov     r0,  #0xffffffff
	mcr	15, 0, r0, cr3, cr0, 0   @ cacheable area
        mov     r0,  #1
	mcr	15, 0, r0, cr2, cr0, 0   @ cache enable
        nop
        nop
        
        @ flush the cache
	mcr     15, 0, r0, cr1,  cr0,  0 
        nop
        nop
        
        
        @ jump to special sequence
        @ want to return to the instruction immediately after mov pc, r9
        mov     lr, pc
        mov     pc, r9
return:         
        ldr     r3, [r5]
        
        cmp     r3, #0
        movne   r10, #10
        bne     testfail
        
        cmp     r13, #40        
        beq     testpass
        add     r13, r13, #4
        mov     r0, r13
        b       big_loop
        
        @ ------------------------------------------ 
        @ ------------------------------------------ 
        @ puts swap address into cache
        @ move 0x7ff32c0 into r5
seq:    mov     r5,     #0x000000c0
        orr     r5, r5, #0x00003200 
        orr     r5, r5, #0x00ff0000 
        orr     r5, r5, #0x07000000 
        ldr     r8, [r5]
        mov     ip, #0
        mov     r2, #1
        str     r2, [r5]
        nop
        nop
        nop
        nop
        
        @ ------------------------------------------ 
        @ busybox code
        @ ------------------------------------------ 
        str     r2, [r5, #4]
        nop
        nop
        nop
        nop
        str     ip, [r5, #4]          
        nop
        nop
        nop
        nop
        nop
        nop
        str     ip, [r5, #8]
        swp     r3, ip, [r5]
        nop
        nop
        nop
        nop
        ldr     r3, [r5, #8]
        nop
        nop
        nop
        nop
        mov     pc, lr
        nop
        nop
        nop
seqend: nop

        @ ------------------------------------------ 
        @ ------------------------------------------ 
        

testfail:
        ldr     r11, AdrTestStatus
        str     r10, [r11]
        b       testfail
        
testpass:             
        ldr     r11, AdrTestStatus
        mov     r10, #17
        str     r10, [r11]
        b       testpass
                


Loc1:           .word  0x200
Adrseq:         .word  seq
Adrseqend:      .word  seqend

/* Write 17 to this address to generate a Test Passed message */
AdrTestStatus:  .word  ADR_AMBER_TEST_STATUS

/* ========================================================================= */
/* ========================================================================= */
        

