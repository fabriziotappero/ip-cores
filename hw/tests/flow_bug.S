/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  The processor illegally skipped an instruction              //
//  after a sequence of 3 conditional not-execute               //
//  instructions and 1 conditional execute instruction          //
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

        ldr     r6, AdrData1
        sub     r6, r6, #4
        nop
        nop
        
        
@ ------------------------------------------    
@ Bad sequence    
@ ------------------------------------------        

        ldr     r5, [r6, #4]
        cmp     r5, #0
        addne   r3, r5, #16
        ldmneda r3, {r1,r3}
        subne   r1, r3, r1
        moveq   r1, r5
        ldr	r0, Data2   @ SKIPPED !!!!
        bl      check_r0
                
@ ------------------------------------------        
@ ------------------------------------------        
check_r0:
        ldr     r7, Data2
        cmp     r0, r7
        movne   r10, #100
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
AdrTestStatus:              .word ADR_AMBER_TEST_STATUS
AdrData1:                   .word Data1
Data1:                      .word 0
Data2:                      .word 17

/* ========================================================================= */
/* ========================================================================= */
        

