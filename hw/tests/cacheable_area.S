/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests the cacheable area co-processor function.             //
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
        @ ---------------------
        @ Enable the cache
        @ ---------------------
        mov     r0,  #0x00000001
	mcr	15, 0, r0, cr3, cr0, 0   @ cacheable area
        mov     r0,  #1
	mcr	15, 0, r0, cr2, cr0, 0   @ cache enable
        nop
        nop

        @ Write to a block of memory that straddles
        @ across a cache region boundary so that
        @ the first 16 bytes are cacheable and
        @ the second 16 are not
        ldr     r0, AdrTestBase
        mov     r2, #0x20
1:      subs    r2, r2, #1
        str     r2, [r0], #4
        bne     1b

        @ loop a few times so that
        @ the instructions will be caches on the second and
        @ subsequent passes
        mov     r7, #3
        
        @ Read back the same block
loop:   ldr     r3, AdrTestBase
        mov     r5, #0x20
        mov     r6, #0
2:      ldr     r4, [r3], #4
        add     r6, r6, r4
        subs    r5, r5, #1
        bne     2b
        
        @ Check that the sum of the data reads is correct
        cmp     r6, #0x1f0
        movne   r10, #10
        bne     testfail
        
        subs    r7, r7, #1
        bne     loop
        
        
        b       testpass
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



/* Write 17 to this address to generate a Test Passed message */
AdrTestStatus:              .word ADR_AMBER_TEST_STATUS
AdrTestBase  :              .word 0x001fffc0

/* sum of numbers 0 to 2047 inclusive */
MagicNumber1024  :          .word  523776
MagicNumber2048  :          .word 2096128

/* ========================================================================= */
/* ========================================================================= */
        
