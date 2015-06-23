/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Test added to catch specific bug with linux memcpy          //
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
        @ setup
        ldr     r0,  AdrCopyDest
        ldr     r1,  AdrCopySource
        mov     r2,  #2
        
        @ memcpy code for 3 bytes or less
        subs    r2, r2, #4
        blt     bytes
        
        mov     r10, #10
        b       testfail
        
bytes:        
        movs    r2, r2, lsl #31
        ldrneb  r3,  [r1], #1
        ldrcsb  r4,  [r1], #1
        ldrcsb  r12, [r1], #1
        strneb  r3,  [r0], #1
        strcsb  r4,  [r0], #1
        strcsb  r12, [r0], #1      


        @ test that move worked
        ldr     r0, AdrCopyDest
        ldrb    r1, [r0], #1
        cmp     r1, #0x31
        movne   r10, #20
        bne     testfail
        
        ldrb    r1, [r0], #1
        cmp     r1, #0x0
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
AdrCopyDest:    .word  Text2
AdrCopySource:  .word  Text1

Text1:          .ascii	"1\000"
                .align 2
Text2:          .ascii	"2222\000"

/* ========================================================================= */
/* ========================================================================= */
        

