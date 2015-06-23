/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests ldm where the user mode registers are loaded          //
//  whilst in a privileged mode.                                //
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

        @ Start in Supervisor Mode
        
        @ Load values directly into the two dedicated supervisor mode registers
        @ and then check they are unaffected by the ldm instruction
        mov     r13, #17
        mov     r14, #34
        
        @ Load user mode registers with some values from memory
        ldr     r3, StaticBase
        ldmia   r3, {r0-r14}^
        
        cmp     r13, #17
        movne   r10, #200
        bne     testfail

        cmp     r14, #34
        movne   r10, #210
        bne     testfail
        
        
        @ Jump into user mode
        @ and check that the user mode registers
        @ were all loaded
        mov     r2, #0x00000000
        teqp    pc, r2
        nop
        
        @ the value 14 comes from the dataset below 
        @ thats used by ldm above
        cmp     r14, #0xe
        movne   r10, #10
        bne     testfail
        
        cmp     r13, #0xd
        movne   r10, #20
        bne     testfail

        cmp     r12, #0xc
        movne   r10, #30
        bne     testfail

        cmp     r11, #0xb
        movne   r10, #40
        bne     testfail

        cmp     r10, #0xa
        movne   r10, #40
        bne     testfail
        
        cmp     r9,  #0x9
        movne   r10, #50
        bne     testfail

        cmp     r8,  #0x8
        movne   r10, #60
        bne     testfail

        cmp     r7,  #0x7
        movne   r10, #70
        bne     testfail

        cmp     r6,  #0x6
        movne   r10, #80
        bne     testfail

        cmp     r5,  #0x5
        movne   r10, #90
        bne     testfail

        cmp     r4,  #0x4
        movne   r10, #100
        bne     testfail

        cmp     r3,  #0x3
        movne   r10, #110
        bne     testfail

        cmp     r1,  #0x1
        movne   r10, #130
        bne     testfail

        cmp     r0,  #0x0
        movne   r10, #140
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
        

