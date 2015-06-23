/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Test Rs barrel shifts                                       //
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
        @ ------------------------------------------------
        @ lsr
        @ test that shift of 0 leaves Rm unchanged
        @ ------------------------------------------------
        mov     r1, #8
        mov     r3, #0
        mov     r1, r1, lsr r3
        
        cmp     r1, #8
        movne   r10, #10
        bne     testfail
        
        
        @ ------------------------------------------------
        @ lsr
        @ test that shift of > 32 sets Rm and Cout to 0
        @ ------------------------------------------------
        
        @ set C Flag to 1
        mov     r4, pc
        orr     r4, r4, #0x20000000
        teqp    pc, r4
        
        @ check that the C Flag to 1
        mov     r7, pc
        ands    r7, r7, #0x20000000
        moveq   r10, #20
        beq     testfail
        
        
        mov     r1, #0xC0000003
        mov     r3, #255
        movs    r1, r1, lsr r3
 
        @ check that the carry flag has been cleared by the mov lsr operation       
        mov     r4, pc
        ands    r4, r4, #0x20000000
        movne   r10, #30
        bne     testfail
        
        
@ ------------------------------------------------
@ ------------------------------------------------
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


/* ========================================================================= */
/* ========================================================================= */
        

