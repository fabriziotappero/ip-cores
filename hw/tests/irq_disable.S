/*****************************************************************
//                                                              //
//  Amber 2 Core Interrupt Test                                 //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests running a simple algorithm to add a bunch of numbers  //
//  and check that the result is correct. This algorithm runs   //
//  80 times. During this, a whole bunch of IRQ interrupts are  //
//  triggered using the random timer.                           //
//                                                              //
//  The test passes if the add algorithm runs successfully      //
//  each time.                                                  //
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
        b       testfail
        
        /* 0x18 IRQ vector address */
        b       service_irq
        
        /* 0x1c FIRQ vector address */
        b       testfail

        /* This doesn't actually disabe the irq because
           you can't disable it uin user mode */
disable_irq:
        orr lr, lr, #0x08000000
        mov pc, lr 

start:
        /* Set Supervisor Mode stack pointer */
        ldr     sp, AdrSVCStack

        /* Test that lr is immediately accessible after a mode switch */
        mov     lr, #0x8000
        mov     r0, #0x08000002
        teqp    pc, r0 @ move to irq mode
        nop
        nop        
                
        @ Switch back to supervisor mode
        mov     r0, #0x08000003
        teqp    pc, r0 
        sub     lr, lr, #4  @ access lr immediately after mode switch
        
        mov     r0, #0x8000
        sub     r0, r0, #4
        cmp     lr, r0
        movne   r10, #200
        bne     testfail
        
        /* Switch to IRQ Mode */
        mov     r0, #0x00000002
        teqp    pc, r0  
        /* Set IRQ Mode stack pointer */
        ldr     sp, AdrIRQStack
        
        /* Switch to User Mode */
        /* and unset interrupt mask bits */
        mov     r0, #0x00000000
        teqp    pc, r0
        
        bl      disable_irq
        
        /* Set User Mode stack pointer */
        ldr     sp, AdrUSRStack
        
        ldr     r4, AdrRanNum
        ldr     r5, [r4]
        and     r5, r5, #0x1c
        add     r5, r5, #5
        ldr     r6, AdrIRQTimer
        str     r5, [r6]
        
        mov     r2,     #0
                
loop:   
        @ set some condition bits
        @ to test that these get preserved
        @ correctly through interrupts
        mov     r3,     #4
        subs    r3, r3, #4
        
        mov     r1,     #1
        add     r1, r1, #2
        add     r1, r1, #3
        add     r1, r1, #4
        addeq   r1, r1, #5
        add     r1, r1, #6
        add     r1, r1, #7
        addeq   r1, r1, #8
        add     r1, r1, #9
        add     r1, r1, #10
        add     r1, r1, #11
        add     r1, r1, #12
        
        mov     r7, #13
        mov     r8, #14
        mov     r9, #15
        
        stmfd   sp!, {r7, r8, r9}
        mov     r7, #0
        mov     r8, #0
        mov     r9, #0
        ldmfd   sp!, {r7, r8, r9}
        
        add     r1, r1, r7
        add     r1, r1, r8
        add     r1, r1, r9
        
        add     r1, r1, #16
        add     r1, r1, #17
        add     r1, r1, #18
        add     r1, r1, #19
        add     r1, r1, #20
        add     r1, r1, #21
        add     r1, r1, #22
        add     r1, r1, #23
        add     r1, r1, #24
        add     r1, r1, #25
        add     r1, r1, #26
        add     r1, r1, #27
        add     r1, r1, #28
        add     r1, r1, #29              
        add     r1, r1, #30
        add     r1, r1, #47   @ adds up to exactly 512           

        cmp     r1, #512
        movne   r10, r2
        bne     testfail
        
        cmp     r2, #80
        beq     testpass
        
        add     r2, r2, #1
        b       loop
        
        @ just put these here in case
        @ the cpu incorrectly executes some instructions
        b       testfail
        b       testfail
        b       testfail
        
          
service_irq:
        @ Save lr to the stack
        stmfd   sp!, {lr}   
                
        @ Set the IRQ Timer to a random number
        ldr     r5, [r4]
        and     r5, r5, #0x7f
        
        @ Ensure that never set the IRQ timer to zero
        add     r5, r5, #30
        str     r5, [r6]
        
        @ Restore lr from the stack
        ldmfd   sp!, {lr}   
        
        @ Jump straight back to normal execution
        subs    pc, lr, #4
        
@ ------------------------------------------        
@ ------------------------------------------        

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
AdrIRQTimer:    .word ADR_AMBER_TEST_IRQ_TIMER

AdrText1:       .word  Text1

AdrSVCStack:    .word  0x0800
AdrUSRStack:    .word  0x1000
AdrIRQStack:    .word  0x1800


        .align 2
Text1:  .ascii	"Interrupt!\n\000"

/* ========================================================================= */
/* ========================================================================= */
        

