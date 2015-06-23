/*****************************************************************
//                                                              //
//  Amber 2 Core Cache Test                                     //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests simple interaction between cached data and uncached   //
//  instruction accesses.                                       //
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
        @ Enable the cache
        @ ---------------------
        mov     r0,  #0xffffffff
	mcr	15, 0, r0, cr3, cr0, 0   @ cacheable area
        mov     r0,  #1
	mcr	15, 0, r0, cr2, cr0, 0   @ cache enable
        nop
        nop

        mov     r1, #27
        ldr     r2, AdrData
        nop
        nop
        nop
        str     r1, [r2]
        
        nop
        nop
        nop
        
        ldr     r3, [r2]
        cmp     r1, r3
        
        movne   r10, #10
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
Result:                     .word 3300
AdrData:                    .word Data
Data:                       .word 0



/* ========================================================================= */
/* ========================================================================= */
        
