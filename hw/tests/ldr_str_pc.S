/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests lrd and str of r15                                    //
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
        mov     r0, #0x800
        
        @ this saves with pc and status bits
1:      str     pc, [r0]
        nop
        nop
        ldr     r1, [r0]
        
        @ Check that the mode (supervisor) was saved
        and     r2, r1, #3
        cmp     r2, #3
        movne   r10, #10
        bne     testfail
        
        @ Check that the correct pc value (location + 12) was saved
        ldr     r6, FilterPC
        and     r3, r1, r6
        ldr     r4, =1b
        add     r4, r4, #12
        cmp     r3, r4
        movne   r10, #20
        bne     testfail
        
        
        @ loading the pc with ldr only changes the pc values,
        @ not the status bits
        ldr     pc, =pcx
        b       testfail
        b       testfail
        b       testfail
        b       testfail
        @ if the jump is 1 ahead or 1 behind the
        @ test will fail
pcx:    b       2f        
        b       testfail
        b       testfail
        b       testfail
        b       testfail
        
        @ Check that the pc load did not change the status bits, 
        @ - that we're still in supervisor mode
2:      mov     r1, pc
        and     r2, r1, #3
        cmp     r2, #3
        movne   r10, #30
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

/* Mark the location of the pc bits of r15 */
FilterPC:       .word  0x03fffffc
LoadPC:         .word  =pcx

/* ========================================================================= */
/* ========================================================================= */
        

