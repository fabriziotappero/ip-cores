/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests instruction and data flow.                            //
//  Specifically tests that a stm writing to cached memory      //
//  also writes all data through to main memory.                //
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
        mvn     r0,  #0
	mcr	15, 0, r0, cr3, cr0, 0   @ cacheable area
        mov     r0,  #1
	mcr	15, 0, r0, cr2, cr0, 0   @ cache enable

        mov     r13, #0x1000
        orr     r13, r13, #0x08
        
        ldr     r0, =Data1
        ldm     r0,  {r1-r5}
        stm     r13, {r1-r5}
        @ load the data values back to put them into the data cache
        ldm     r13, {r6-r10}
        
        ldr     r0, =Data2
        ldm     r0,  {r1-r5}
        @ second stm will be to cached memory
        stm     r13, {r1-r5}
        @ load it back from the cache to check that
        @ it was written to the cache correctly
        ldm     r13, {r6-r10}
        cmp     r1, r6
        cmpeq   r2, r7
        cmpeq   r3, r8
        cmpeq   r4, r9
        cmpeq   r5, r10
        movne   r10, #100
        bne     testfail

        @ Clear the cache and read back the data from main memory
        @ Write any value to cp15 reg1 to flush the cache
	mcr     15, 0, r0, cr1, cr0, 0
        
        ldm     r13, {r6-r10}
        cmp     r1, r6
        cmpeq   r2, r7
        cmpeq   r3, r8
        cmpeq   r4, r9
        cmpeq   r5, r10
        movne   r10, #200
        bne     testfail
        
        b       testpass
        
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

Data1:          .word  0x3
                .word  0x4
                .word  0x5
                .word  0x6
                .word  0x7
Data2:          .word  0x13
                .word  0x14
                .word  0x15
                .word  0x16
                .word  0x17



/* ========================================================================= */
/* ========================================================================= */
        
