/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests mov with RRX                                          //
//  Checks that the carry flag value is rotated into            //
//  target register                                             //
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
        // sets the carry big
        // Cant use p version of instrustion in 32-bit CPU because it writes the upper 4 bits of PC
        teqp    pc, #0x20000000
        mov     r0, #0
        // without the 's' the rotation does not change the carry flag
        mov     r0, r0, rrx 
        // carry flag should still be set
        bcc     testfail
        // check that r0 got the carry flag into bit 31
        cmp     r0, #0x80000000
        bne     testfail

        // same again, except with movs so the carry flag gets set to bit 0 of r0
        mov     r0, #0
        movs    r0, r0, rrx 
        // carry flag should be cleared now
        bcs     testfail
        // check that r0 got the carry flag into bit 31
        cmp     r0, #0x80000000
        bne     testfail

        // check that carry flag can be set to 1 with same sequence
        mov     r0, #1
        teqp    pc, #0x00000000
        bcs     testfail
        movs    r0, r0, rrx 
        bcc     testfail
        cmp     r0, #0x00000000
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
        

AdrTestStatus:  .word  ADR_AMBER_TEST_STATUS

