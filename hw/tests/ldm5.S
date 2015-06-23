/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //

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
        mov    r14, #100
        ldr    r13, Data1Base
        ldmia  r13!,{r1-r14}^  // load into user mode registers

        // supervisor r14 value should be unchanged
        mov    r0, r14
        cmp    r0, #100
        bne    testfail

        // same test again, using r13 instead of r14
        mov    r13, #100
        ldr    r14, Data1Base
        ldmia  r14!,{r1-r13}^  // load into user mode registers        
        mov    r0, r13
        cmp    r0, #100
        ldr    r1, Data14Base
        cmp    r1, r14
        bne    testfail

        beq    testpass

testfail:
        ldr     r11, AdrTestStatus
        str     r10, [r11]
        b       testfail
        
testpass:             
        ldr     r11, AdrTestStatus
        mov     r10, #17
        str     r10, [r11]
        b       testpass

 
/* Write 17 to  this address to generate a Test Passed message */
AdrTestStatus:  .word  ADR_AMBER_TEST_STATUS
Data1Base:      .word  Data1
Data14Base:     .word  Data14
Data1:          .word  0x00
                .word  0x01
                .word  0x02
                .word  0x03
                .word  0x04
                .word  0x05
                .word  0x06
                .word  0x07
                .word  0x08
                .word  0x09
                .word  0x0a
                .word  0x0b
                .word  0x0c
Data14:         .word  0x0d
                .word  0x0e
                .word  0x0f
                .word  0x10

/* ========================================================================= */
/* ========================================================================= */
        

