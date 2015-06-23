/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests add                                                   //
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
        
/* 3 + 1 */
        mov     r1, #3
        mov     r2, #1
        add     r3, r1, r2
        expect  r3, 4, __LINE__
        
/* 0 + 0 */
        mov     r4, #0
        mov     r5, #0
        add     r6, r5, r4
        expect  r6, 0, __LINE__
        
/* 0 + -1 */
        mov     r7, #0
        mov     r8, #-1
        add     r9, r7, r8
        expect  r9, -1, __LINE__
        
/* -1 + 0 */
        mov     r1, #-1
        mov     r2, #0
        add     r3, r1, r2
        expect  r3, -1, __LINE__
        
/* -1 + -1 */
        mov     r4, #-1
        mov     r5, #-1
        add     r6, r4, r5
        expect  r6, -2, __LINE__

/* -1 + -255 */
        mov     r7, #-1
        mov     r8, #-255
        add     r9, r7, r8
        expect  r9, -256, __LINE__

/* 1 + 0x7fffffff */
        ldr     r1, MaxPos
        mov     r2, #1
        adds    r3, r1, r2
        /* this should generate an overflow */
        /* so if the V flag is Clear then fail */
        bvc     testfail
        ldr     r0, MaxNeg
        compare r0, r3, __LINE__

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
MaxPos:         .word  0x7fffffff
MaxNeg:         .word  0x80000000

/* ========================================================================= */
/* ========================================================================= */
        

