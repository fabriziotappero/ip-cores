/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests ldm where the pc is loaded which causes a jump.       //
//  At the same time the mode is changed, This is repeated      //
//  with the cache enabled.                                     //
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

        @ Run through the test 4 times
        @ 1 - cache off
        @ 2 - cache on but empty
        @ 3 - cache on and loaded
        @ 4 - same as 3
        
        mov     r7, #40
        
1:      mov     r0, #0x1000
        ldr     r6, =JumpHere
        bic     r6, r6, #0x3
        orr     r6, r6, #0x1 @ set the mode to jump to
        mov     r2, #17
        mov     r3, #46
        mov     r4, #99
        mov     r5, #123
        
        stm     r0, {r2-r6}
        ldm     r0, {r11-pc}^
    
        b       testfail
        b       testfail
        b       testfail
        b       testfail
        b       testfail
        b       testfail
        b       testfail
        b       testfail
        b       testfail
        b       testfail
        
JumpHere:
        b       2f
        b       testfail
        b       testfail
        b       testfail

2:
        @ Check the mode is 0x1
        mov     r0, pc
        and     r0, r0, #0x3
        cmp     r0, #0x1
        movne   r10, #10
        bne     testfail
        
        @ Switch back to supervisor mode
        teqp    pc, #0x3

        @ Test that the instructions immediately
        @ following a non-executed ldr pc are executed
        mov     r10, #20
        mov     r0, #5
        cmp     r0, #6
        ldreq   pc, =testfail  @ not executed                    
        teq     r0, #5
        bne     testfail
        b       3f
        b       testfail
        b       testfail
        b       testfail
3:        
        
        @ Test that the instruction after two ldrs, where the second ldr depends on the first,
        @ is executed.
        mov     r0, #5
        cmp     r0, #6
        ldmeqia sp!, {r4,pc}
        ldr     r2, Data1
        ldr     r2, [r2]
        mov     r0, #7
        cmp     r0, #7
        movne   r10, #30
        bne     testfail
        
        cmp     r2, #0xff
        movne   r10, #40
        bne     testfail
        
        
        @ ---------------------
        @ Enable the cache
        @ ---------------------
        mvn     r0,  #0
	mcr	15, 0, r0, cr3, cr0, 0   @ cacheable area
        mov     r0,  #1
	mcr	15, 0, r0, cr2, cr0, 0   @ cache enable

        subs    r7, r7, #10
        bne     1b
        
        b       testpass

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
AdrTestStatus:  .word  ADR_AMBER_TEST_STATUS
Data1:          .word  Data2
Data2:          .word  0xff

/* ========================================================================= */
/* ========================================================================= */
        
