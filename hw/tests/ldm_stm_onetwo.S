/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests ldm and stm of single registers with cache enabled.   //
//  Tests ldm and stm of 2 registers with cache enabled.        //
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
        
        mov     r10, #400
        
        @ stm 1 -------------------------------------
1:      mov     r0, #0x1000
        mov     r1, r0
        
        ldr     r2, Data2
        stmia   r1!, {r2}
        ldr     r3, [r0], #4
        
        @ Check that the address pointers were both incremented correctly
        cmp     r0, r1
        addne   r10, r10, #1
        bne     testfail
        
        @ Check that the correct value was saved to memory
        cmp     r2, r3
        addne   r10, r10, #2
        bne     testfail


        @ ldm 1 -------------------------------------
        mov     r0, #0x1000
        mov     r1, r0
        
        ldr     r2, Data2
        str     r2, [r1], #4
        ldmia   r0!, {r3}
        
        @ Check that the address pointers were both incremented correctly
        cmp     r0, r1
        addne   r10, r10, #3
        bne     testfail
        
        @ Check that the correct value was saved to memory
        cmp     r2, r3
        addne   r10, r10, #4
        bne     testfail
        
        
        
        @ ldm 1, pc -------------------------------------
        mov     r0, #0x1000
        mov     r1, r0
        
        ldr     r2, =jpc1
        str     r2, [r1], #4
        ldmia   r0!, {pc}
        
        b       testfail
        b       testfail
        b       testfail
        b       testfail
jpc1:   b       2f
        b       testfail
        b       testfail
        b       testfail
        b       testfail
                        
        
        @ Check that the address pointers were both incremented correctly
 2:     cmp     r0, r1
        addne   r10, r10, #5
        bne     testfail
        

        @ stm 2 -------------------------------------
        mov     r0, #0x1000
        mov     r1, r0
        
        mov     r4, #0x33
        mov     r6, #0x44
        stmia   r1!, {r4, r6}
        ldr     r7, [r0], #4
        ldr     r8, [r0], #4
        
        @ Check that the address pointers were both incremented correctly
        cmp     r0, r1
        addne   r10, r10, #6
        bne     testfail
        
        @ Check that the correct value was saved to memory
        cmp     r4, r7
        addne   r10, r10, #7
        bne     testfail
        cmp     r6, r8
        addne   r10, r10, #8
        bne     testfail


        @ ldm 2 -------------------------------------
        mov     r0, #0x1000
        mov     r1, r0
        
        mov     r4, #0x33
        mov     r5, #0x44
        str     r4, [r0], #4
        str     r5, [r0], #4
        ldmia   r1!, {r6, r7}
        
        @ Check that the address pointers were both incremented correctly
        cmp     r0, r1
        addne   r10, r10, #9
        bne     testfail
        
        @ Check that the correct value was saved to memory
        cmp     r4, r6
        addne   r10, r10, #10
        bne     testfail
        cmp     r5, r7
        addne   r10, r10, #11
        bne     testfail


        @ ldm 2, pc -------------------------------------
        mov     r0, #0x1000
        mov     r1, r0
        
        mov     r4, #0x33
        ldr     r5, =jpc2
        str     r4, [r0], #4
        str     r5, [r0], #4
        ldmia   r1!, {r6, pc}
        
        b       testfail
        b       testfail
        b       testfail
        b       testfail
        b       testfail
jpc2:   b       2f
        b       testfail
        b       testfail
        b       testfail
        b       testfail
        b       testfail
                        
        
        @ Check that the address pointers were both incremented correctly
2:      cmp     r0, r1
        addne   r10, r10, #12
        bne     testfail
        
                                       
        @ ---------------------
        @ Enable the cache
        @ ---------------------
        mvn     r13,  #0
	mcr	15, 0, r13, cr3, cr13, 0   @ cacheable area
        mov     r13,  #1
	mcr	15, 0, r13, cr2, cr13, 0   @ cache enable

        subs    r10, r10, #100
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
        
