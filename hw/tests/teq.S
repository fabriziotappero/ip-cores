/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests add with carry                                        //
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

// Test "Strange issue with r12 after TEQLSP"
// Tests for bug where testlsp command would switch the core 
// from supervisor into FIRQ mode if it were executed. However the condition is not
// met so it is not executed. The bug is the next instrument works in FIRQ mode anyway.
// This was caused because the mode bits used in the ececute stage were not conditional on the
// teq instrumention being executed.

// Also tests correct setting of carry flag when second operand is a constant


#include "amber_registers.h"
#include "amber_macros.h"

	.section .text
	.globl	main        
main:

        // Test "Strange issue with r12 after TEQLSP"
        mov     r1,  #0x0 
        mov     r2,  #0x1 
        mov     r6,  #10 
        mov     r12, #100
        nop

        // this next instrument does not get executed because 'ls' condition is false
        teqlsp  r1,  r2 // r1 XOR r2 = 0x1 -> sets the mode bits of the PC to 1
        mov     r12, r6 // user r12 or FIRQ r12 ? 

        cmp     r12, r6 // error if user mode r12 was not updated with new value
        bne     testfail

        // check the carry flag
        // When a flexible second operand constant is used with the instructions MOVS, MVNS, ANDS, ORRS, ORNS, EORS, BICS,
        // TEQ or TST, the carry flag is updated to bit[31] of the constant, if the constant is greater than 255
        // and can be produced by shifting an 8-bit value. These instructions do not affect the carry flag if
        // Operand2 is any other constant.
        teq     r4, #0x80000000 
        bcc     testfail

        // keeps carry flag the same
        teq     r4, #0x00000000 
        bcc     testfail

        // sets the carry flag back to zero
        teq     r4, #0x40000000 
        bcs     testfail       

        // set the carry flag and verify that teq with register for operand 2 does not clear it
        teq     r4, #0x80000000 
        mov     r4, #0 
        mov     r5, #0x40000000 
        teq     r4, r5 
        bcc     testfail
        
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
        

AdrTestStatus:  .word  ADR_AMBER_TEST_STATUS

