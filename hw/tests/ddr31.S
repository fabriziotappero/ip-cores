/*****************************************************************
//                                                              //
//  Amber 2 Core DDR3 Memory Access                             //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Word accesses to random addresses in DDR3 memory            //
//  The test creates a list of addresses in an area of          //
//  boot_mem. It then writes to all addresses with data value   //
//  equal to address. Finally it reads back all locations       //
//  checking that the read value is correct.                    //
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

        @ --------------------------------------------
        @ Quick Pre-Test
        ldr     r0, DDRBase
        add     r4, r0, #12
        mov     r1, #0xff
        mov     r3, #0x55
        
        str     r1, [r0]
        str     r3, [r4]
        ldr     r2, [r0]
        ldr     r5, [r4]
        
        cmp     r1, r2
        movne   r10, #10
        bne     testfail
        
        cmp     r3, r5
        movne   r10, #15
        bne     testfail

        @ --------------------------------------------
        @ Create an array of random accresses
        @ Write data = address to each address
        @ Read back and verify data is correct
  
        @ setup
        ldr     r0,  AdrRanNum
        ldr     r9,  PointerBase
        ldr     r10, DDRBase
        mov     r11, #ARRAY_WORDS
        
1:      ldmia   r0,{r1-r8}
        add     r1, r10, r1, lsl #2
        add     r2, r1,  r2, lsl #2
        add     r3, r2,  r3, lsl #2
        add     r4, r3,  r4, lsl #2
        add     r5, r4,  r5, lsl #2
        add     r6, r5,  r6, lsl #2
        add     r7, r6,  r7, lsl #2
        add     r8, r7,  r8, lsl #2
        
        stmia   r9,{r1-r8}
        
        add     r9, r9, #32
        mov     r10, r8
        
        subs    r11, r11, #1
        bne     1b
        @ --------------------------------------------
        
        @ Write array to ddr memory
        ldr     r9,  PointerBase
        mov     r11, #ARRAY_WORDS
        
2:      ldmia   r9,  {r1-r8}
        str     r1, [r1]
        str     r2, [r2]
        str     r3, [r3]
        str     r4, [r4]
        str     r5, [r5]
        str     r6, [r6]
        str     r7, [r7]
        str     r8, [r8]
        
        add     r9, r9, #32
        subs    r11, r11, #1
        bne     2b
                

        @ --------------------------------------------
        
        @ Read array back from ddr and verify it
        ldr     r9,  PointerBase
        mov     r11, #ARRAY_WORDS
3:      ldmia   r9,  {r1-r8}

        @ r1
        ldr     r12, [r1]
        cmp     r12, r1
        movne   r10, #10
        bne     testfail

        @ r2
        ldr     r12, [r2]
        cmp     r12, r2
        movne   r10, #10
        bne     testfail

        @ r3
        ldr     r12, [r3]
        cmp     r12, r3
        movne   r10, #10
        bne     testfail

        @ r4
        ldr     r12, [r4]
        cmp     r12, r4
        movne   r10, #10
        bne     testfail


        @ r5
        ldr     r12, [r5]
        cmp     r12, r5
        movne   r10, #10
        bne     testfail

        @ r6
        ldr     r12, [r6]
        cmp     r12, r6
        movne   r10, #10
        bne     testfail

        @ r7
        ldr     r12, [r7]
        cmp     r12, r7
        movne   r10, #10
        bne     testfail

        @ r8
        ldr     r12, [r8]
        cmp     r12, r8
        movne   r10, #10
        bne     testfail

        add     r9, r9, #32
        subs    r11, r11, #1
        bne     3b


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
PointerBase:    .word 0x1000
DDRBase:        .word 0x20000
