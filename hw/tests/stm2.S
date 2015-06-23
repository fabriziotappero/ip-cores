/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Test jumps into user mode, loads some values into           //
//  registers r8 - r14, then jumps to FIRQ and                  //
//  saves the user mode registers to memory                     //
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
        /* 0x00 Reset Interrupt vector address */
        b       start
        
        /* 0x04 Undefined Instruction Interrupt vector address */
        b       testfail
        
        /* 0x08 SWI Interrupt vector address */
        b       testfail
        
        /* 0x0c Prefetch abort Interrupt vector address */
        b       testfail
        
        /* 0x10 Data abort Interrupt vector address */
        b       testfail
        
        /* Address exception Interrupt vector address */
        b       testfail
        
        /* 0x18 IRQ vector address */
        b       testfail
        
        /* 0x1c FIRQ vector address */
        b       service_firq


start:
        @ Jump into user mode
        mov     r2, #0x00000010
        teqp    pc, r2
        
        ldr     r3, StaticBase
        ldmia   r3, {r8-r14}
        
        @ Jumo into FIRQ mode by triggering a Fast Interrupt
        @ set the firq timer to trigger a firq request
        ldr     r5, AdrFIRQTimer
        mov     r6, #10
        str     r6, [r5]
        
        @ loop waiting for the interrupt
        @ to trigger
loop:   nop
        nop
        nop
        b       loop
        
        @ These should never get executed
        b       testfail
        b       testfail
        b       testfail
        
@ ------------------------------------------        
@ ------------------------------------------        
service_firq:
        @ Disable the FIRQ Timer
        ldr     r10, AdrFIRQTimer
        mov     r11, #0
        str     r11, [r10]
        
        
        @ load a couple of numbers
        @ into FIRQ registers
        mov     r9,  #50
        mov     r10, #60
        mov     r11, #70
        mov     r12, #80
        mov     r13, #90
        mov     r14, #100
        
        movs    r1, #0
        ldr     r2, StoreBase
        
        @ execute the stm instruction
        @ and check that its conditional execution works
        @ Now in firq mode but this instruction saves the
        @ user mode register values
        stmeqia r2, {r8-pc}^

        mov     r4, #4
        
        ldr     r3, [r2], #4
        cmp     r3, #8
        movne   r10, #20
        bne     testfail

        ldr     r3, [r2], #4
        cmp     r3, #9
        movne   r10, #30
        bne     testfail
        
        ldr     r3, [r2], #4
        cmp     r3, #10
        movne   r10, #40
        bne     testfail
        
        ldr     r3, [r2], #4
        cmp     r3, #11
        movne   r10, #50
        bne     testfail
        
        ldr     r3, [r2], #4
        cmp     r3, #12
        movne   r10, #60
        bne     testfail
        
        ldr     r3, [r2], #4
        cmp     r3, #13
        movne   r10, #70
        bne     testfail
        
        ldr     r3, [r2], #4
        cmp     r3, #14
        movne   r10, #80
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
AdrFIRQTimer:   .word  ADR_AMBER_TEST_FIRQ_TIMER
StoreBase:      .word  0x800
StaticBase:     .word  Data1
StaticEnd:      .word  Data18

Data1:          .word  0x08
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
        

