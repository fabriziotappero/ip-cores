/*****************************************************************
//                                                              //
//  Amber 2 Core Interrupt Test                                 //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests Address Exception Interrupt                           //
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
        @ Exception vectors
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
        
        /* 0x14 Address Exception Interrupt vector */
        b       service_addr_ex
        
        /* 0x18 IRQ vector address */
        b       testfail
        
        /* 0x1c FIRQ vector address */
        b       testfail


start:
        @ Change to user mode
        teqp    pc, #0x0c000000
        
        @ count interrupts
        mov     r0, #0  
        mov     r8, #0
        
        mov     r0, #0x4000000
        sub     r0, r0, #4
        ldr     r3, no_op
        str     r3, [r0], #4
        str     r3, [r0], #4
        str     r3, [r0], #4
        
        mov     r0, #0x4000000
        sub     r0, r0, #4
        mov     r1, pc
        ldr     r13, PCMask
        bic     r1, r1, r13
        orr     r2, r1, r0
        
        @ this jumps to 0x3ffffff
        @ then the core executes a nop at 0x3ffffff
        @ and increments the address to 0x4000000
        @ which triggers an address exception
pos1:   mov     pc, r2

        b       testfail
        b       testfail

no_op:  nop
        nop
                  

service_addr_ex:
        @ Check that we're in supervisor mode again
        mov     r5, pc
        and     r5, r5, #3
        cmp     r5, #3
        movne   r10, #10
        bne     testfail
        
        @ Check the address
        ldr     r13, PCMask
        and     r13, r13, lr
        @ The exception occurs on address 0x4000000, so the 
        @ interrupt return address is 0x4000008, but the msb
        @ is not recorded by the pc so it becomes just 0x8
        cmp     r13, #0x08 
        movne   r10, #20
        bne     testfail
        
        @ Check that the irq and firq masks are shown correctly in the lr
        and     r13, lr, #0x0c000000
        cmp     r13, #0x0c000000
        movne   r10, #30
        bne     testfail
        
        b       testpass
        
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
AdrTestStatus:              .word ADR_AMBER_TEST_STATUS
Adrpos1:                    .word pos1
PCMask:                     .word 0x03fffffc
