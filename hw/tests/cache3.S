/*****************************************************************
//                                                              //
//  Amber 2 Core Cache Test                                     //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests that the cache can write to and read back multiple    // 
//  times from 2k words in sequence in memory - the size of     //
//  the cache.                                                  //
//                                                              //
//  256 lines x 4 words x 1 way = 1024 words                    //
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
        mov     r0,  #0xffffffff
	mcr	15, 0, r0, cr3, cr0, 0   @ cacheable area
        mov     r0,  #1
	mcr	15, 0, r0, cr2, cr0, 0   @ cache enable
        nop
        nop

        @ ---------------------
        @ Write to 2k locations
        @ ---------------------
        ldr     r2, AdrTestBase
        mov     r3, #0

write_loop:    
        str     r3, [r2], #4
        add     r3, r3, #1
        cmp     r3, #1024
        bne     write_loop
        
        @ ---------------------
        @ Read back - caches the reads
        @ ---------------------
        ldr     r2, AdrTestBase
        mov     r3, #0
        mov     r0, #0

read1_loop:
        ldr     r1, [r2], #4
        add     r0, r0, r1
        add     r3, r3, #1
        cmp     r3, #1024
        bne     read1_loop

        ldr     r4, MagicNumber1024
        cmp     r0, r4        
        movne   r10, #10
        bne     testfail
        
        @ ---------------------
        @ Read back a second time and check the values
        @ These reads will all be from the cache
        @ ---------------------
        ldr     r2, AdrTestBase
        mov     r3, #0
        mov     r0, #0

read2_loop:
        ldr     r1, [r2], #4
        add     r0, r0, r1
        add     r3, r3, #1
        cmp     r3, #1024
        bne     read2_loop

        ldr     r4, MagicNumber1024
        cmp     r0, r4        
        movne   r10, #10
        bne     testfail

        
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
AdrTestBase  :              .word 0x20000

/* sum of numbers 0 to 2047 inclusive */
MagicNumber1024  :          .word  523776
MagicNumber2048  :          .word 2096128

/* ========================================================================= */
/* ========================================================================= */
        
