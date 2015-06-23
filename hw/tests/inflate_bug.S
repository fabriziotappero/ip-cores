/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  A load store sequence was found to not execute correctly.   //
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
  
        @ setup
        mov     r9, #4
        ldr     lr, =Data2
        add     lr, lr, #2
        
        @ -------------------------------------
        @ Replicated code from Linux Kernel
        @ -------------------------------------
        ldr     r2, Data1
        ldr     r3, [lr, #4]
        ldr     r1, [r2]
        strb    r3, [r1, r9]
        
        @ -------------------------------------
        @ Check correct value was saved
        @ -------------------------------------
        ldrb    r6, [r1, r9]
        cmp     r6, #0x22
        movne   r10, #10
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
AdrTestStatus:        .word ADR_AMBER_TEST_STATUS
AdrFrame:             .word 0x400
AdrDataBase:          .word Data1

Data1:                .word Data4
Data2:                .word 0x7777aaaa
Data3:                .word 0x11225566
Data4:                .word Data5
Data5:                .word 0x33448899

Expected:             .word 0x71f8


/* ========================================================================= */
/* ========================================================================= */
        

