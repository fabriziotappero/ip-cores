/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests lsl, ror                                              //
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

        @ Run through the test 4 times
        @ 1 - cache off
        @ 2 - cache on but empty
        @ 3 - cache on and loaded
        @ 4 - same as 3
        mov     r10, #4


/* lsl 0 */
1:      mov     r1, #1
        mov     r2, r1, lsl #0
        expect  r2, 1, __LINE__

/* lsl 1 */
        mov     r4, #1
        mov     r5, r4, lsl #1
        expect  r5, 2, __LINE__
        
/* lsl 31 */
        mov     r7, #1
        mov     r8, r1, lsl #31
        expect  r8, 0x80000000, __LINE__
        
/* lsr 1 */
        mov     r1, #2
        mov     r2, r1, lsr #1
        expect  r2, 1, __LINE__
        
/* lsr 8 */
        mov     r4, #0xff00
        mov     r5, r4, lsr #8
        expect  r5, 0xff, __LINE__
        
/* ror 8 */
        ldr     r6, Data1
        mov     r7, r6, ror #8
        ldr     r8, Data2
        compare r7, r8, __LINE__


        @ ---------------------
        @ Sequences of shift operations
        @ ---------------------

        @ lsl
        mov     r0, #0
        mov     r1, #1
        mov     r2, #2
        mov     r3, #3
        mov     r4, #4
        mov     r5, #5
        
        mov     r6, r3, lsl #31
        mov     r7, r0, lsl #2
        mov     r8, r1, lsl #11
        mov     r9, r2, lsl #17
        
        expect  r6, 0x80000000, __LINE__
        expect  r7, 0x00000000, __LINE__
        expect  r8, 0x00000800, __LINE__
        expect  r9, 0x00040000, __LINE__

        mov     r6, r3, lsl #30
        mov     r7, r1, lsl #2
        mov     r8, r2, lsl #4
        mov     r9, r3, lsl #5
        
        expect  r6, 0xc0000000, __LINE__
        expect  r7, 0x00000004, __LINE__
        expect  r8, 0x00000020, __LINE__
        expect  r9, 0x00000060, __LINE__

        @ lsr
        mov     r0, #0x80000000
        mov     r1, #0x7f000000
        mov     r2, #0x80000001
        mov     r3, #0x7fffffff
        mov     r4, #0x7ffffffe
        mov     r5, #0x55000000
        orr     r5, r5, #0x55

        mov     r6, r0, lsr #1
        mov     r7, r0, lsr #2
        mov     r8, r1, lsr #24
        mov     r9, r2, lsr #1
        
        expect  r6, 0x40000000, __LINE__
        expect  r7, 0x20000000, __LINE__
        expect  r8, 0x0000007f, __LINE__
        expect  r9, 0x40000000, __LINE__

        @ ---------------------
        @ Enable the cache
        @ ---------------------
        mvn     r0,  #0
	mcr	15, 0, r0, cr3, cr0, 0   @ cacheable area
        mov     r0,  #1
	mcr	15, 0, r0, cr2, cr0, 0   @ cache enable

        subs    r10, r10, #1
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
Data1:          .word  0x12345678
Data2:          .word  0x78123456

/* ========================================================================= */
/* ========================================================================= */
        

