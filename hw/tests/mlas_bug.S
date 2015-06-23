/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Bug with Multiply Accumulate. The flags were gettting set   // 
//  1 cycle early. So in an operation with ( 0 x n ) + 1, the   // 
//  Z flag was set because it didn't take into account the      //
//  addition done right at the end.                             //
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

  @ r6 = mode
  @ r3 = inode->i_mode
  
        @ setup
        mov     r0, #0
        mov     r1, #4
        mov     sp, #StackArea
        
        @ -------------------------------------
        @ Replicated code from Linux Kernel
        @ chip.c / set_irq_chip

 	stmda	sp,{r4, r5, r6, lr}
 	ldr	r3, [pc, #120]	@ 2e53ac <set_irq_chip+0x84>
 	ldr	r3, [r3]
 	cmp	r0, r3
 	mov	r5, r1
 	bcs	j1
 	ldr	r2, [pc, #104]	@ 2e53b0 <set_irq_chip+0x88>
 	mov	r3, #60	@ 0x3c
 	mlas	r6, r0, r3, r2  @ if result == 0 -> warn_slowpath
 	bne	j2
j1:  
 	mov	r3, r0
 	mov	r1, #95	@ 0x5f
 	ldr	r0, [pc, #84]	@ 2e53b4 <set_irq_chip+0x8c>
 	ldr	r2, [pc, #84]	@ 2e53b8 <set_irq_chip+0x90>
 	bl	warn_slowpath
 	mvn	r0, #21	@ 0x15
 	ldmib	sp, {r4, r5, r6, pc}
j2:  
 	ldr	r3, [pc, #72]	@ 2e53bc <set_irq_chip+0x94>
 	cmp	r1, #0	@ 0x0
 	moveq	r5, r3
 	mov	r4, pc
 	orr	r3, r4, #128	@ 0x80
 	teqp	pc, r3
 	mov	r0, r5
 	bl	irq_chip_set_defaults
 	ands	r0, r4, #128	@ 0x80
 	str	r5, [r6, #8]
 	beq	j3
 	teqp	pc, r4
 	mov	r0, #0	@ 0x0
 	ldmib	sp, {r4, r5, r6, pc}
j3:  
 	teqp	pc, r4
 	ldmib	sp, 	{r4, r5, r6, pc}
 	.word	nr_irqs
 	.word	0xc04c6ce4
 	.word	0xc0482c14
 	.word	0xc0482c28
 	.word	0xc04c77e8

nr_irqs:
        .word   47
        
        b       testpass

        @ -------------------------------------
warn_slowpath:
        mov     r10, #20
        b       testfail       

irq_chip_set_defaults:
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
AdrTestStatus:              .word ADR_AMBER_TEST_STATUS

        .word   0
        .word   0
        .word   0
        .word   0
StackArea:
