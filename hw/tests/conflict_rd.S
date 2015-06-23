/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests that a register conflict between a ldr and a regop    //
//  that changes the value of the same register is handled      //
//  correctly.                                                  //
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
        
1:      mov     r1, #1
        mov     r2, #2
        mov     r3, #3
        mov     r4, #4
        mov     r5, #0x1000
        mov     r6, #6
        str     r6, [r5]
        mov     sp, #0x800
        
        @ --------------------------
        tst     r3,  #1
        add     r0,  r6,  r4
        ldr     r1, Data1
        ldr     r3, Data2
        ldr     r2, Data3
        movne   r2,  r3     @ always executed
        ldr     r3, [r5]
        
        bl      2f
        
        nop
        nop
        nop
        
2:      stmdb   sp!, {r1, r2, r3}      

        nop
        nop
        
        ldr     r8, [sp, #4]
        ldr     r9, Data2
        cmp     r8, r9
        addne   r10, #1
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

Data1:          .word  0x1000
Data2:          .word  0x2000
Data3:          .word  0x3000

/* ========================================================================= */
/* ========================================================================= */
        
