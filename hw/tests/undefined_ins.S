/*****************************************************************
//                                                              //
//  Amber 2 Core Interrupt Test                                 //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests Undefined Instruction Interrupt                       //
//  Fires a few FP instructions into the core. These            //
//  cause undefined instruction interrupts when executed.       //
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
        b       service_undefined_instruction
        
        /* 0x08 SWI Interrupt vector address */
        b       testfail
        
        /* 0x0c Prefetch abort Interrupt vector address */
        b       testfail
        
        /* 0x10 Data abort Interrupt vector address */
        b       testfail
        
        /* 0x14 whats this one for? */
        b       testfail
        
        /* 0x18 IRQ vector address */
        b       testfail
        
        /* 0x1c FIRQ vector address */
        b       testfail


start:
        @ count interrupts
        mov     r0, #0  
        mov     r8, #0
        
        @ set the flags to not equal so some undefined instructions tested below
        @ won't execute (which we want)
        cmp     r0, #1
        
        @ save status bits so can check value in isr
        ldr     r3, PCMask
        mov     r4, pc
        bic     r4, r4, r3
        
        @ floating point instruction
        @ ldfp	f2, [ip], #8   @  ecfca102
.word   0xecfca102


pos1:      
        @ fstmiax	ip!, {d8-d15} 
.word   0xecac8b11        
         
pos2:      
        @ Next FP instruction is not executed, so does not
        @ cause an interrupt
        @ stfpeq	f2, [ip], #8        
.word   0x0ceca102
        add     r8, r8, #7  @ executes
        addeq   r8, r8, #3  @ doesnt execute

        @ fmxr	fpscr, r1
.word   0xeee11a10

pos3:      
        @ Check that the isr has run the correction number of times
        cmp     r0, #12     @ 3 times = 12
        movne   r10, #120
        bne     testfail
        
        @ Check that the mov r8 instruction was executed
        cmp     r8, #7
        movne   r10, #130
        bne     testfail
        
        b       testpass
        b       testfail
        b       testfail

          
service_undefined_instruction:        
        @ Check the r14 return address is correct
        ldr     r1, =Adrpos1
        @ add the interrupt number (which increments by 4 each time)
        add     r1, r1, r0
        
        @ Check the expected return address
        ldr     r2, [r1]
        ldr     r13, PCMask
        and     r13, r13, r14
        cmp     r2, r13
        movne   r10, r0
        bne     testfail
        
        @ Check the status bits
        ldr     r13, PCMask
        bic     r5, r14, r13
        cmp     r4, r5
        movne   r10, #100
        bne     testfail
        
        @ Check that Mode == SVC
        mov     r6, pc
        and     r6, r6, #0x3
        cmp     r6, #0x3
        movne   r10, #110
        bne     testfail
        
        @ increment the isr counter
        add     r0, r0, #4
        
        @ return to the next instruction from the isr
        movs    pc, r14

        b       testfail
        b       testfail
        b       testfail
        
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
Adrpos2:                    .word pos2
Adrpos3:                    .word pos3
PCMask:                     .word 0x03fffffc
