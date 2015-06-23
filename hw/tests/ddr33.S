/*****************************************************************
//                                                              //
//  Amber 2 Core DDR3 Memory Access                             //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Test back to back write-read accesses to DDR3 memory        //
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
#define ARRAY_WORDS 0x40

	.section .text
	.globl	main        
main:
        ldr     r10, DDRBase
        mov     r5, #40         @ main loop count
        
1:      ldr     r0,  AdrRanNum
        ldmia   r0,{r1-r2}
        orr     r2, r2, r1, lsl #8
        mov     r2, r2, lsl #2
        add     r2, r2, r10
  
        ldr     r3, Data0
        ldr     r6, Data1
        ldr     r8, Data2
        
        @ DDR accesses
        str     r3, [r2]
        ldr     r4, [r2], #4
        str     r6, [r2], #4
        str     r8, [r2], #-4
        ldr     r7, [r2], #4
        ldr     r9, [r2]
        
        cmp     r3, r4
        movne   r10, #10
        bne     testfail

        cmp     r6, r7
        movne   r10, #20
        bne     testfail

        cmp     r8, r9
        movne   r10, #30
        bne     testfail

        subs    r5, r5, #1
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
AdrTestStatus:  .word ADR_AMBER_TEST_STATUS
AdrRanNum:      .word ADR_AMBER_TEST_RANDOM_NUM
DDRBase:        .word 0x20000
Data0:          .word 0xff00cc55
Data1:          .word 0x7711ff17
Data2:          .word 0x12345678
