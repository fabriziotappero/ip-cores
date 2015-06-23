/*****************************************************************
//                                                              //
//  Amber 2 Core DDR3 Memory Access                             //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests byte read and write accesses.                         //
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

        mov     r3, #4      @ main loop count
        ldr     r0,  AdrRanNum
mainl:  ldr     r1, [r0]    @ load a random number        
        mov     r1, r1, lsl #12
        
        @ --------------------------------------------
        @ write phase
        ldr     r8,  DDRBase
        add     r8, r8, r1
        mov     r9,  #0xff
1:      strb    r9, [r8], #1
        subs    r9, r9, #1
        bne     1b
        
        @ read phase
        ldr     r8,  DDRBase
        add     r8, r8, r1
        mov     r9,  #0xff
2:      ldrb    r7, [r8], #1
        cmp     r7, r9
        movne   r10, #10
        bne     testfail
        subs    r9, r9, #1
        bne     2b
        
        @ --------------------------------------------
        subs    r3, r3, #1
        bne     mainl

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
AdrTestStatus:  .word ADR_AMBER_TEST_STATUS
AdrRanNum:      .word ADR_AMBER_TEST_RANDOM_NUM
DDRBase:        .word 0x100000
