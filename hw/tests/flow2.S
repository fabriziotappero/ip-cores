/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests instruction and data flow.                            //
//  Specifically tests that a stream of str instrutions writing //
//  to cached memory works correctly.                           //
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

        @ Run through the test 4 times
        @ 1 - cache off
        @ 2 - cache on but empty
        @ 3 - cache on and loaded
        @ 4 - same as 3
        
        mov     r10, #40
        
1:      mov     r0, #0x1000
        ldr     r1, Data2
        str     r1, [r0]
        
        ldr     r2, [r0], #1
        ldr     r3, [r0], #1
        ldr     r4, [r0], #1
        ldr     r5, [r0]
        
        ldrb    r6, [r0], #-1
        ldrb    r7, [r0], #-1
        ldrb    r8, [r0], #-1
        ldrb    r9, [r0]
        
        cmp     r2, r1
        addne   r10, r10, #2
        bne     testfail
        
        mov     r1, r1, ror #8
        cmp     r3, r1
        addne   r10, r10, #3
        bne     testfail

        mov     r1, r1, ror #8
        cmp     r4, r1
        addne   r10, r10, #4
        bne     testfail
        
        mov     r1, r1, ror #8
        cmp     r5, r1
        addne   r10, r10, #5
        bne     testfail
        
        @ Test conflict detection
        mov     r1, #5
        ldr     r1, Data1
        mov     r2, r1
        cmp     r2, #3
        addne   r10, r10, #6
        bne     testfail

        @ Test ldm/stm with conflicts   
        
        mov     r13, #0x1000
        orr     r13, r13, #0x08
        
        ldr     r0, =Data1
        ldmia   r0, {r1-r5}
        mov     r6,  r13
        str     r1, [r6], #4        
        str     r2, [r6], #4        
        str     r3, [r6], #4        
        str     r4, [r6], #4        
        str     r5, [r6], #4        

        mov     r6,  r13
        ldr     r7,  [r6], #4      
        ldr     r8,  [r6], #4      
        ldr     r9,  [r6], #4      
        ldr     r14, [r6], #4      
        ldr     r11, [r6], #4      
        
        cmp     r1, r7
        cmpeq   r2, r8
        cmpeq   r3, r9
        cmpeq   r4, r14
        cmpeq   r5, r11
        addne   r10, r10, #7
        bne     testfail
        
        
        @ Test conflict detection for a stm
        mov     r6,  r13
        mov     r2, #3
        mov     r0, #4
        ldr     r1, Data3
        stm     r6, {r0,r1,r2}
        
        mov     r6,  r13
        ldr     r4, [r6, #4]
        cmp     r1, r4
        addne   r10, r10, #8
        bne     testfail

        @ Test conflict detection for add
        ldr     r5, Data1
        add     r5, r5, #1
        cmp     r5, #4
        addne   r10, r10, #9
        bne     testfail
        
        @ Throw in an uncached memory access
        mov     r1, #0x99
        ldr     r0, AdrHiBootBase
        str     r1, [r0]
        ldr     r2, [r0]
        cmp     r2, #0x99
        addne   r10, r10, #100
        bne     testfail
                
        @ ---------------------
        @ Enable the cache
        @ ---------------------
        mvn     r0,  #0
	mcr	15, 0, r0, cr3, cr0, 0   @ cacheable area
        mov     r0,  #1
	mcr	15, 0, r0, cr2, cr0, 0   @ cache enable

        subs    r10, r10, #10
        bne     1b
        
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
AdrHiBootBase:  .word  ADR_HIBOOT_BASE

Data1:          .word  0x3
                .word  0x4
                .word  0x5
                .word  0x6
                .word  0x7
Data2:          .word  0x44332211
Data3:          .word  0x12345678

/* ========================================================================= */
/* ========================================================================= */
        
