/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests lrd and ldrb                                          //
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

/* Load Byte 0 */
        ldr     r0, AdrData1
        ldrb    r1, [r0]
        ldr     r2, Data2
        cmp     r1, r2
        movne   r10, #10
        bne     testfail
                
/* Load Byte 1 */
        add     r0, r0, #1
        ldrb    r3, [r0]
        ldr     r4, Data3
        cmp     r3, r4
        movne   r10, #20
        bne     testfail

/* Load Byte 2 */
        add     r0, r0, #1
        ldrb    r5, [r0]
        ldr     r6, Data4
        cmp     r5, r6
        movne   r10, #30
        bne     testfail
        
/* Load Byte 3 */
        add     r0, r0, #1
        ldrb    r7, [r0]
        ldr     r8, Data5
        cmp     r7, r8
        movne   r10, #40
        bne     testfail
        
        
/* Immediate offset  */
        ldr     r0,  AdrData1
        ldr     r1, [r0, #4]
        ldr     r3, Data2
        cmp     r1, r3
        movne   r10, #50
        bne     testfail
        
        @ Check that r0 is not altered
        ldr     r8,  AdrData1
        cmp     r0, r8
        movne   r10, #60
        bne     testfail
        
        /* test negative offset */
        ldr     r0,  AdrData8
        ldr     r2, [r0, #-12]
        ldr     r3, Data5
        cmp     r2, r3
        movne   r10, #70
        bne     testfail
 
        @ Check that r0 is not altered
        ldr     r8, AdrData8
        cmp     r0, r8
        movne   r10, #80
        bne     testfail


/* Immediate pre-indexed  */
        ldr     r0,  AdrData1
        ldr     r1, [r0, #4]!
        
        @ check that r0 was incremented correctly
        ldr     r8,  AdrData1
        add     r8, r8, #4
        cmp     r0, r8
        movne   r10, #90
        bne     testfail
        
        @ check that correct value was loaded into r1
        ldr     r2, Data2
        cmp     r1, r2
        movne   r10, #100
        bne     testfail
        
        
/* Immediate post-indexed  */
        ldr     r0,  AdrData1
        ldr     r1, [r0], #4
        ldr     r2, [r0], #4
        
        ldr     r3, Data1
        cmp     r1, r3
        movne   r10, #110
        bne     testfail
        
        ldr     r4, Data2
        cmp     r2, r4
        movne   r10, #120
        bne     testfail
        
        ldr     r8,  AdrData1
        add     r8, r8, #8
        cmp     r0, r8
        movne   r10, #130
        bne     testfail
        

/* Register offset  */
        ldr     r0,  AdrData1
        mov     r1,  #1
        ldr     r2, [r0, r1]
        ldr     r3, Data7
        cmp     r2, r3
        movne   r10, #140
        bne     testfail
        
        
/* Register offset pre-indexed */
        ldr     r0,  AdrData1
        mov     r1,  #3
        ldr     r2, [r0, r1]!
        
        ldr     r3, Data8
        cmp     r2, r3
        movne   r10, #150
        bne     testfail
        
        ldr     r4,  AdrData1
        add     r4,  r4, #3
        cmp     r0, r4
        

/* Register offset post-indexed */
        ldr     r5,  AdrData1
        mov     r6,  #2
        ldr     r7, [r5], -r6
        
        ldr     r8, Data1
        cmp     r7, r8
        movne   r10, #160
        bne     testfail
        
        ldr     r9,  AdrData1
        sub     r9, r9, #2
        cmp     r5, r9
        bne     testfail
        
             
/* Scaled Register offset */
        ldr     r0,  AdrData1
        mov     r1, #2
        /* r2 <- contents of 'AdrData1 + 8' */
        ldr     r2, [r0, r1, lsl #2]

        ldr     r3, Data3
        cmp     r2, r3
        movne   r10, #170
        bne     testfail


/* Scaled Register offset pre-indexed */
        ldr     r4,  AdrData1
        mov     r5, #8
        /* r6 <- contents of 'AdrData1 + 4' */
        /* r4 <- AdrData1 + 4 */
        ldr     r6, [r4, r5, lsr #1]!

        ldr     r8,  Data2
        cmp     r6, r8
        movne   r10, #180
        bne     testfail

        ldr     r7,  AdrData1
        add     r7,  r7, #4
        cmp     r4, r7
        movne   r10, #190
        bne     testfail
        
        
/* Scaled Register offset post-indexed */
        ldr     r0,  AdrData8
        mov     r1, #1
        ldr     r2, [r0], -r1, ror #28
        
        ldr     r3, Data8
        cmp     r2, r3
        movne   r10, #200
        bne     testfail
        
        ldr     r4, AdrData8
        sub     r4, r4, #16
        cmp     r0, r4
        movne   r10, #210
        bne     testfail
        

/* Test unaligned word loads */
        ldr     r0, Data9
        mov     r1, #0x200
        str     r0, [r1]
        
        ldr     r2, [r1], #1
        ldr     r3, [r1], #1
        ldr     r4, [r1], #1
        ldr     r5, [r1], #1
        
        cmp     r2, r0
        movne   r10, #220
        bne     testfail

        mov     r6, r0, ror #8
        cmp     r6, r3
        movne   r10, #230
        bne     testfail
        
        mov     r7, r0, ror #16
        cmp     r7, r4
        movne   r10, #240
        bne     testfail
        
        mov     r8, r0, ror #24
        cmp     r8, r5
        movne   r10, #250
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
AdrTestStatus:  .word  ADR_AMBER_TEST_STATUS
AdrData1:       .word  Data1
AdrData8:       .word  Data8
Data1:          .word  0x12345678
Data2:          .word  0x00000078
Data3:          .word  0x00000056
Data4:          .word  0x00000034
Data5:          .word  0x00000012
Data6:          .word  0xfecba987
Data7:          .word  0x78123456
Data8:          .word  0x34567812
Data9:          .word  0x33221100

/* ========================================================================= */
/* ========================================================================= */
        

