/*****************************************************************
//                                                              //
//  Amber 2 Core Interrupt Test                                 //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests Fast Interrupt                                        //
//  Executes 20 FIRQs randomly while executing a small loop     //
//  of code. Test checks the full set of FIRQ registers (r8 to  // 
//  r14) and will only pass if all interrupts are handled       //
//  correctly                                                   //
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

        @ ---------------------
        @ Interrupt Vector Table
        @ ---------------------
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
        b       testfail
        
        /* 0x1c FIRQ vector address */
        b       service_firq


start:
        /* Switch to User Mode */
        /* and unset interrupt mask bits */
        mov     r0,   #0x00000000
        teqp    pc, r0        
        
        @ Check that we're in user mode now
        mov     r2, pc
        ands    r2, r2, #3
        movne   r10, #10
        bne     testfail    
        
        
        @ Set up 
        mov     r1, #0
        mov     r3, #20    @ Number of times to run the outer loop of the test
        
        @ set the firq timer to trigger a firq request
mloop:          
        ldr     r4, AdrRanNum
        ldr     r5, [r4]
        and     r5, r5, #0x3f
        add     r5, r5, #15
        
        ldr     r6, AdrFIRQTimer
        str     r5, [r6]
    
        @ loop forever
loop:   mov     r8,  #0x17
        mov     r9,  #0x39
        mov     r10, #0x87
        mov     r11, #0x14
        mov     r12, #0x97
        mov     r13, #0x52
        
        mov     r7, #0
        add     r7, r8, r7
        add     r7, r9, r7
        add     r7, r10, r7
        add     r7, r11, r7
        add     r7, r12, r7
        add     r7, r13, r7
        
        @ only jump to check regs after an interrupt has occurred.
        @ The interrupt service routine sets r1 to a 1
        @ and the check_regs sequence sets it back to 0
        cmp     r1,  #1
        beq     check_regs
        b       loop
        nop
        
loop1:  @ This lable needs to be 1 instruction after the end of the
        @ loop. The interrupt lr address is current instruction address + 4
        @ so if the interrupt hits on the b loop, then the FIRQ lr will
        @ be 2 instructions after the end of the loop
        
        
service_firq:
        @ Now in FIRQ mode
        @ Turn off the FIRQ interrupt count down trigger by writing a zero to it
        ldr     r10, AdrFIRQTimer
        mov     r11, #0
        str     r11, [r10]
        
        @ Check that the FIRQ Link Register (r14) got the correct return address
        @ Don't know exactly when the interrupt occurred so check the range loop to loop1
        ldr     r2, Adrloop
        ldr     r13, PCMask
        and     r13, lr, r13
        cmp     r13, r2
        movlt   r10, #100
        blt     testfail

        ldr     r2, Adrloop1
        cmp     r13, r2
        movgt   r10, #110
        bgt     testfail
        
        @ save a 1 to r1, this will exit the loop to testpass
        mov     r1, #1
        
        mov     r8,  #0x10
        mov     r9,  #0x20
        mov     r10, #0x30
        mov     r11, #0x40
        mov     r12, #0x50
        mov     r13, #0x60
        
        @ Jump straight back to normal execution, returning to user mode
        subs    pc, r14, #4

        
check_regs:
        mov     r1,  #0
        
        ldr     r6, Sum
        cmp     r7, r6
        movne   r10, #15
        bne     testfail
        
        cmp     r8,  #0x17        
        movne   r10, #20
        bne     testfail
        
        cmp     r9,  #0x39       
        movne   r10, #30
        bne     testfail
        
        cmp     r10, #0x87       
        movne   r10, #40
        bne     testfail
        
        cmp     r11, #0x14       
        movne   r10, #50
        bne     testfail
        
        cmp     r12, #0x97       
        movne   r10, #60
        bne     testfail

        cmp     r13, #0x52       
        movne   r10, #70
        bne     testfail
        
        cmp     r3, #0
        
        beq     testpass
        sub     r3, r3, #1
        b       mloop

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

                
@ ------------------------------------------        
@ ------------------------------------------        

AdrTestStatus:  .word ADR_AMBER_TEST_STATUS
AdrRanNum:      .word ADR_AMBER_TEST_RANDOM_NUM
AdrFIRQTimer:   .word ADR_AMBER_TEST_FIRQ_TIMER
Adrloop:        .word loop
Adrloop1:       .word loop1
Sum:            .word 0x1d4
PCMask:         .word 0x03fffffc
