/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests the usage of ldm in User Mode where the status        //
//  bits are loaded. The s bit should be ignored in User Mode   //
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
        @ Write values to user mode registers r13 and r14
        mov     r0, #0x200
        mov     r1, #0x66
        str     r1, [r0]
        mov     r1, #0x77
        str     r1, [r0, #4]
        ldmia   r0, {r13, r14}^

        @ set the condition flags, interrupt masks, and change to user mode
        teqp    pc, #0xf8000000
        
        @ The pc and condition flags are loaded, the other
        @ status bits are not, because we're in user mdoe
        ldr     r3, StaticBase
        ldmia   r3, {r0-pc}^
        b       testfail
        b       testfail
        b       testfail
        b       testfail

ldm_jump:
        @ Check that the condition flags are still 0xf
        mov     r4, pc
        and     r7, r4, #0xfc000000
        cmp     r7, #0x08000000
        movne   r10, #70
        bne     testfail    
        
        @ Check that we're still in user mode now
        ands    r6, r4, #0x3
        movne   r10, #10
        bne     testfail    

        @ Check that User Mode r13 and r14 were changed by the ldm instruction
        cmp     r13, #0xd
        movne   r10, #20
        bne     testfail    
        cmp     r14, #0xe
        movne   r10, #30
        bne     testfail    
        
        @ Check that r0 got loaded with the correct value
        cmp     r0,  #0
        movne   r10, #40
        bne     testfail    
        
        @ Check that r1 got loaded with the correct value
        cmp     r1,  #1
        movne   r10, #50
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
StaticBase:     .word  Data1
PCMask:         .word  0x03fffffc

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
                .word  ldm_jump
                .word  0x10
Data18:         .word  0x11

/* ========================================================================= */
/* ========================================================================= */
        

