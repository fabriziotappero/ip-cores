/*****************************************************************
//                                                              //
//  Amber 2 Core Interrupt Test                                 //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests executes a loop of stm instructions. During this,     //
//  a whole bunch of IRQ interrupts are triggered using         //
//  the random timer. The test checks that the stm is           //
//  not executed twice in a row, once before the interrupt      //
//  and again after the interrupt.                              //
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
#include "amber_macros.h"

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


start:
        @ ---------------------
        @ Enable the cache
        @ ---------------------
        mvn     r0,  #0
	mcr	15, 0, r0, cr3, cr0, 0   @ cacheable area
        mov     r0,  #1
	mcr	15, 0, r0, cr2, cr0, 0   @ cache enable

        /* Set Supervisor Mode stack pointer */
        ldr     sp, AdrSVCStack
        
        /* Switch to IRQ Mode */
        mov     r0, #0x00000002
        teqp    pc, r0  
        /* Set IRQ Mode stack pointer */
        ldr     sp, AdrIRQStack
        
        /* Switch to User Mode */
        /* and unset interrupt mask bits */
        mov     r0,   #0x00000000
        teqp    pc, r0  
        
        /* Set User Mode stack pointer */
        ldr     sp, AdrUSRStack
        
        /* Configure IRQ Timer with a random time */
        ldr     r4, AdrRanNum
        ldr     r5, [r4]
        and     r5, r5, #0x1c
        add     r5, r5, #5
        ldr     r6, AdrIRQTimer
        str     r5, [r6]
        
        mov     r2, #40
        mov     r3, #7
        mov     r7, #0x700
        mov     r13, r7
        @ fill area with zeros
        mov     r8, #0x200
        
1:      str     r8, [r7, -r8]
        subs    r8, r8, #4
        beq     loop
        b       1b
        
        
        
loop:   
        
        mov     r3, #5
        ldmdb   r7!, {r8-r11}
        orr     r3,  r3,  r11, lsr #8
        mov     r11, r11, lsl #24 
       
        @ Follow the r7 address pointer and make
        @ sure it decrements correctly on each
        @ iteration of the loop
        sub     r13, r13, #16
        compare r7, r13, __LINE__
        
        subs    r2, r2, #1
        beq     testpass
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
        

