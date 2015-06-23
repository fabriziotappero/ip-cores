/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests the standard form of ldm.                             //
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

@ ------------------------------------------        
@ 1. ldmda   r14!, {r0-r12}
@ ------------------------------------------        

        ldr     r14, StaticEnd
        ldmda   r14!, {r0-r12}
        
        @ check that the base register, r14 was correctly updated
        ldr     r13, StaticEnd
        sub     r13, r13, #52 @ 13 x 4
        cmp     r13, r14
        movne   r10, #10
        bne     testfail
        
        @check the values loaded into r0 to r12
        @r0
        mov     r13, #0x05
        cmp     r13, r0
        movne   r10, #20
        bne     testfail
        @r1
        mov     r13, #0x06
        cmp     r13, r1
        movne   r10, #30
        bne     testfail
        @r2
        mov     r13, #0x07
        cmp     r13, r2
        movne   r10, #40
        bne     testfail
        @r3
        mov     r13, #0x08
        cmp     r13, r3
        movne   r10, #50
        bne     testfail
        @r4
        mov     r13, #0x09
        cmp     r13, r4
        movne   r10, #60
        bne     testfail
        @r5
        mov     r13, #0x0a
        cmp     r13, r5
        movne   r10, #70
        bne     testfail
        @r6
        mov     r13, #0x0b
        cmp     r13, r6
        movne   r10, #80
        bne     testfail
        @r7
        mov     r13, #0x0c
        cmp     r13, r7
        movne   r10, #90
        bne     testfail
        @r8
        mov     r13, #0x0d
        cmp     r13, r8
        movne   r10, #100
        bne     testfail
        @r9
        mov     r13, #0x0e
        cmp     r13, r9
        movne   r10, #110
        bne     testfail
        @r10
        mov     r13, #0x0f
        cmp     r13, r10
        movne   r10, #120
        bne     testfail
        @r11
        mov     r13, #0x10
        cmp     r13, r11
        movne   r10, #130
        bne     testfail
        @r12
        mov     r13, #0x11
        cmp     r13, r12
        movne   r10, #140
        bne     testfail


@ ------------------------------------------        
@ 2. ldmia   r0, {pc}
@ Test loading the pc
@ ------------------------------------------        

        ldr     r0, StoreBase
        ldr     r1, =jump2
        str     r1, [r0]
        ldmia   r0, {pc}    @ causes a jump to 'jump2'
        
        @ these should never be executed
        b       testfail
        b       testfail
        b       testfail
        b       testfail

jump2:  b       start3
        

@ ------------------------------------------        
@ 2. ldmia   r0, {r5, pc}
@ Test loading the pc, as part of a group
@ ------------------------------------------        

start3:
        ldr     r0, StoreBase
        mov     r1, #17
        str     r1, [r0], #4
        ldr     r1, =jump3
        str     r1, [r0]        
        
        ldr     r0, StoreBase
        ldmia   r0, {r5, pc}    @ causes a jump to 'jump2'
        
        @ these should never be executed
        b       testfail
        b       testfail
        b       testfail
        b       testfail

        @ Check that r5 was loaded with the correct value
jump3:  mov     r7, #17
        cmp     r5, r7
        movne   r10, #200
        bne     testfail
        

@ ------------------------------------------        
@ ------------------------------------------        

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
StoreBase:      .word  0x800
StaticBase:     .word  Data1
StaticEnd:      .word  Data18

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
                .word  0x0d
                .word  0x0e
                .word  0x0f
                .word  0x10
Data18:         .word  0x11

/* ========================================================================= */
/* ========================================================================= */
        

