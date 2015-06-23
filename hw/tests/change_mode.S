/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests teq, tst, cmp and cmn with the p flag set             //
//  Starts in supervisor mode, changes to Interrupt mode,       //
//  then Fast Interrupt mode, then supervisor mode again        //
//  and finally User mode                                       //
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
        @ ------------------------------------------------------------
        @ Change to Interrupt mode using tstp
        @ tstp does an AND
        mov     r4, #0xfffffffe
        @ When the pc is in the rn position, it includes the status bits
        tstp    r4, pc
        
        @ Check that we're now in Interrupt mode
        mov     r5, pc
        @ just want the mode bits
        and     r5, r5, #0x3
        cmp     r5, #2
        movne   r10, #50
        bne     testfail
        
        @ ------------------------------------------------------------
        @ Change to Fast Interrupt mode using cmpp
        @ cmpp does a subtract
        mov     r6, pc
        cmpp    r6, #1
        mov     r7, pc
        and     r8, r7, #3
        cmp     r8, #1
        movne   r10, #60
        bne     testfail
        
        @ ------------------------------------------------------------
        @ Change back to Supervisor mode using cmnp 
        @ cmnp does an add
        ldr     r1, Status1
        cmnp    pc, #0xf0000003
        nop
        mov     r9, pc
        ldr     r0, PCMask
        bic     r13, r9, r0
        cmp     r13, r1
        movne   r10, #70
        bne     testfail
                
        @ ------------------------------------------------------------
        @ Clear all the status bits and change to user mode
        @ teq does an XOR
        teqp    pc, #0
        b       1f
        b       testfail
        b       testfail
        
        @ Check that all the status bits are now zero
1:      ldr     r0, PCMask
        mov     r1, pc
        bics    r1, r1, r0      
        movne   r10, #10
        bne     testfail
        
        @ ------------------------------------------------------------
        @ Now in user mode, so can't change back to supervisor mode
        @ But can set the condition flags
        teqp    pc, #0xf0000003
        mov     r2, #0
        orr     r1, r2, pc
        bic     r1, r1, r0      
        cmp     r1, #0xf0000000
        movne   r10, #20
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
PCMask:         .word  0x03fffffc
Status1:        .word  0xf0000003

/* ========================================================================= */
/* ========================================================================= */
        

