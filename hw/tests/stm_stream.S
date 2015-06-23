/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Generates as dense a stream of writes as possible to check  //
//  that the memory subsystem can cope with this worst case.    //
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
#include "amber_macros.h"

	.section .text
	.globl	main        
main:
        @ ---------------------
        @ Enable the cache
        @ ---------------------
        @ The instruction space is cached and the data space is not.
        @ So when the written data is read back, it comes from
        @ main memory and not the dcache.
        mov     r0,  #0x1
	mcr	15, 0, r0, cr3, cr0, 0   @ cacheable area
        mov     r0,  #1
	mcr	15, 0, r0, cr2, cr0, 0   @ cache enable
        
        mov     r14, #3

loop:   mov     r0, #0x1000000
        add     r1, r14, #0x1
        add     r2, r14, #0x2
        add     r3, r14, #0x3
        add     r4, r14, #0x4
        add     r5, r14, #0x5
        add     r6, r14, #0x6
        add     r7, r14, #0x7
        add     r8, r14, #0x8
        
        @ ---------------------        
        @ write 1024 bytes
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}
        stm     r0!, {r1-r8}

        @ Read back and check
        mov     r0, #0x1000000
        mov     r13, #320
1:      mov     r9, r14
2:      add     r9, r9, #1
        ldr     r12, [r0], #4
        compare r12, r9, __LINE__
        add     r10, r14, #8
        cmp     r9, r10
        bne     2b
        
        subs    r13, r13, #10
        bne     1b
        
        subs    r14, r14, #1
        bne     loop
        
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
Data1:          .word  Data2
Data2:          .word  0xff

/* ========================================================================= */
/* ========================================================================= */
        
