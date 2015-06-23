/*****************************************************************
//                                                              //
//  Amber 2 Core Boot Memory Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests wishbone read and write access to hi (non-cachable)   //
//  boot SRAM.                                                  //
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

        /* Store word and single Byte */
        ldr     r0,  HiBootBase
        mov     r1,  #0xff
        mov     r2,  #0xcc
        str     r1,  [r0], #4
        strb    r2,  [r0]
        
        ldr     r0,  HiBootBase
        ldr     r3, [r0], #4
        ldrb    r4, [r0]

        cmp     r3, #0xff
        movne   r10, #10
        bne     testfail   
             
        cmp     r4, #0xcc
        movne   r10, #20
        bne     testfail
             
@ ------------------------------------------        
@ ------------------------------------------        

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

/* NB do not overwrite the execution code space !! */
HiBootBase:     .word  0x28000200

/* ========================================================================= */
/* ========================================================================= */
        

