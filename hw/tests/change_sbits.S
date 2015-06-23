/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests movs where the destination register is r15, the pc    //
//  Depending on the processor mode and whether the s bit is    //
//  set or not, some or none of the status bits will change.    //
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
        @ ------------------------------------------------------------------------
        @ In supervisor mode, change to user mode
        ldr     r0, UserMode
        @ set the condition flags
        orr     r0, r0, #0xf0000000
        @ set one of the interrupt masks
        orr     r0, r0, #0x04000000
        
        ldr     r1, =1f
        ldr     r2, PCMask
        and     r2, r1, r2
        orr     r3, r2, r0
        movs    pc, r3
        
        @ Check that the jump works correctly
        b       testfail
        b       testfail
1:      b       2f
        b       testfail
        b       testfail
  
        @ Now check that the status bits are changed correctly
2:      mov     r8, pc
        ldr     r9, PCMask
        bic     r9, r8, r9        
        ldr     r12, ExpectedBits1
        cmp     r9, r12
        movne   r10, #20
        bne     testfail
        
        @ ------------------------------------------------------------------------
        @ Test that in user mode, only the condition status bit
        @ and the pc can be changed
        @ In User mode, change to Supervisor mode (this isn't allowed and will fail)
        ldr     r0, SupervisorMode
        @ set the condition flags
        orr     r0, r0, #0x30000000
        @ set one of the interrupt masks
        orr     r0, r0, #0x08000000

        ldr     r1, =3f
        ldr     r2, PCMask
        and     r2, r1, r2
        orr     r3, r2, r0
        movs    pc, r3
        
        @ Check that the jump works correctly
        b       testfail
        b       testfail
3:      b       4f
        b       testfail
        b       testfail

        @ Now check that the status bits are changed correctly
4:      mov     r8, pc
        ldr     r9, PCMask
        bic     r9, r8, r9        
        ldr     r12, ExpectedBits2
        cmp     r9, r12
        movne   r10, #30
        bne     testfail

        @ ------------------------------------------------------------------------
        @ Test that in user mode, only the pc changes when the s bit is not set
        mov     r12, pc     @ remeber the current pc status bits
        ldr     r9, PCMask
        bic     r12, r12, r9
        
        ldr     r0, UserMode
        @ set the condition flags
        orr     r0, r0, #0xc0000000

        ldr     r1, =5f
        ldr     r2, PCMask
        and     r2, r1, r2
        orr     r3, r2, r0
        mov     pc, r3

        @ Check that the jump works correctly
        b       testfail
        b       testfail
5:      b       6f
        b       testfail
        b       testfail

        @ Now check that the status bits are not changed
6:      mov     r8, pc
        ldr     r9, PCMask
        bic     r9, r8, r9        
        cmp     r9, r12
        movne   r10, #40
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

/* Switch to user mode */
UserMode:       .word  0x00000000
SupervisorMode: .word  0x00000003
PCMask:         .word  0x03fffffc
ExpectedBits1:  .word  0xf4000000
ExpectedBits2:  .word  0x34000000
ExpectedBits3:  .word  0x34000000

/* ========================================================================= */
/* ========================================================================= */
        

