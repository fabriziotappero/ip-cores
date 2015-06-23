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

#include "amber_registers.h"
#include "amber_macros.h"

	.section .text
	.globl	main        
main:
        // sets all four flags
        // Cant use p version of instrustion in 32-bit CPU because it writes the upper 4 bits of PC
        teqp    pc, #0xf0000000

        // 
        // Check that they are set
        bvc     testfail  // V flag 
        bpl     testfail  // N flag
        bne     testfail  // Z flag
        bcc     testfail  // C flag

        mov     r1, #0

        // should not unset the V flag value
        tst     r1, #0

        // Check the V flag and Z flag are still set, the C flag 
        // is set to the carry out, and the N flag gets cleared
        bvc     testfail
        bne     testfail
        bcc     testfail
        bmi     testfail

        // Test "Strange issue with r12 after TEQLSP"
        mov     r1,  #0x1 
        mov     r2,  #0x1 
        mov     r8,  #0 
        mov     r6,  #10 
        mov     r10, #13 
        mov     r12, #100
        nop

        add     r6,  r6,#1 
        cmp     r6,  r8 
        ldrls   r3,  [r9,r6,lsl #2] 
        movls   r4,  r11 
        movhi   r3,  #0 
        teqp    r1,  r2 // r1 XOR r2 = 0x1 -> sets the mode bits of the PC to 1
        mov     r12, r6 // normal r12 or FIRQ r12 ? 


        // test if carry flag correctly set
        // set the carry up 
        mov     r1,  #0xffffffff 
        adds    r1,  r1, #1 

        // do the test 
        mov     r1,  #0x00800000 
        tst     r1,  #0x00ff0000 
        movcc   r0,  #0 
        movcs   r0,  #1 

        // test carry flag
        mov     r0,  #2 
        mov     r1,  #1 
        mov     r3,  #0x930 
        cmp     r0,  #1 
        mov     r1,  r3 
        tst     r1,  #0x10 
        
        bcc     testfail
        bcc     testfail
        bcc     testfail


        // clears all four flags
        // Cant use p version of instrustion in 32-bit CPU because it writes the upper 4 bits of PC
        teqp    pc, #0x00000000

        mov     r0, #2
        mov     r1, #1
        mov     r3, #0x930
        // next instruction sets the carry flag
        // compare subtracts a 1 from the r0 value of 2
        // means 2's compliment of '1' gets added to '2', so the carry bit is set
        cmp     r0, #1
        mov     r1, r3
        
        // leaves carry flag at previous value
        tst     r1, #0x10
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

