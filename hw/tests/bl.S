/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests branch and link instruction                           //
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

        mov     r10, #100
        mov     r1, #37
        mov     r2, #47
        cmp     r1, r2
        movne   r3, #42
        moveq   r3, #0
        mov     r5, #0

        @ branch and link
        blne    1f
ret:
        
        cmp     r5, #0xff
        movne   r10, #10
        bne     testfail

        cmp     r1, #37
        movne   r10, #20
        bne     testfail
        
        cmp     r2, #47
        movne   r10, #30
        bne     testfail

        cmp     r3, #42
        movne   r10, #40
        bne     testfail
        
        b       testpass

             
        b       testfail     
        b       testfail    
        
        @ check that the link register gets the correct return address 
1:      ldr     r6, =ret
        ldr     r7, PCMask
        and     r7, lr, r7
        cmp     r6, r7
        movne   r10, #80
        bne     testfail
        
        @ check that the value in r5 survives the jump back
        mov     r5, #0xff
        mov     pc, lr
        b       testfail     
        b       testfail     
        
        
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
PCMask:         .word 0x03fffffc                

/* ========================================================================= */
/* ========================================================================= */
        

