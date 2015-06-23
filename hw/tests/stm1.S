/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests stm                                                   //
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

@ ------------------------------------------        
@ 1. stmia   r14!, {r0-r13}
@ ------------------------------------------        
        
        mov     r0,  #0
        mov     r1,  #1
        mov     r2,  #2
        mov     r3,  #3
        mov     r4,  #4
        mov     r5,  #5
        mov     r6,  #6
        mov     r7,  #7
        mov     r8,  #8
        mov     r9,  #9
        mov     r10, #10
        mov     r11, #11
        mov     r12, #12
        mov     r13, #13
        ldr     r14, StoreBase
        stmia   r14!, {r0-r13}
        
        
        @ Check that r14 was updated correctly
        ldr     r0, StoreBase
        add     r0, r0, #56  @ 14 x 4
        cmp     r14, r0
        movne   r10, #20
        bne     testfail
        
        @ Check that all values were saved to memory correctly
        mov     r2, #0
        ldr     r0, StoreBase
loop1:  ldr     r1, [r0], #4
        cmp     r1, r2
        movne   r10, #30
        bne     testfail
        cmp     r2, #13
        beq     start2
        add     r2, r2, #1
        b       loop1
        
        
@ ------------------------------------------        
@ 2. stmib   r14!, {r0-r13}
@ ------------------------------------------        
start2:
        mov     r0,  #0
        mov     r1,  #1
        mov     r2,  #2
        mov     r3,  #3
        mov     r4,  #4
        mov     r5,  #5
        mov     r6,  #6
        mov     r7,  #7
        mov     r8,  #8
        mov     r9,  #9
        mov     r10, #10
        mov     r11, #11
        mov     r12, #12
        mov     r13, #13
        ldr     r14, StoreBase
        stmib   r14!, {r0-r13}
        
        @ Check that r14 was updated correctly
        ldr     r0, StoreBase
        add     r0, r0, #56  @ 14 x 4
        cmp     r14, r0
        movne   r10, #40
        bne     testfail
        
        @ Check that all values were saved to memory correctly
        mov     r2, #0
        ldr     r0, StoreBase
        add     r0, r0, #4
loop2:  ldr     r1, [r0], #4
        cmp     r1, r2
        movne   r10, #50
        bne     testfail
        cmp     r2, #13
        beq     start3
        add     r2, r2, #1
        b       loop2


@ ------------------------------------------        
@ 3. stmib   r14!, {r14}
@ Test that the starting value of r14 is stored
@ Test that storing a single register works correctly
@ ------------------------------------------        
start3:
        ldr     r14, StoreBase
        stmib   r14!, {r14}
        
        @ check that r14 got updated with a new value
        ldr     r0, StoreBase
        add     r1, r0, #4
        cmp     r14, r1
        movne   r10, #60
        bne     testfail
        
        @ check that the old value in r14 was stored
        ldr     r2, [r1]
        cmp     r2, r0
        movne   r10, #70
        bne     testfail
        


@ ------------------------------------------        
@ 4. stmda   r0, {r14, pc}
@ Test that r0 is not updated
@ Test that the correct pc value is stored
@ Test that Descending works
@ ------------------------------------------        
start4:
        mov     r14, #97
        ldr     r0, StoreBase
        mov     r2, pc  @ NB this must be immediately before
                        @ the stm instruction to capture the
                        @ correct pc value for checking below
        stmda   r0, {lr, pc}
        
        @ check that r0 did not get updated
        ldr     r1, StoreBase
        cmp     r0, r1
        movne   r10, #70
        bne     testfail
        
        @ check that the correct pc value was stored
        @ The value of the pc is 12 bytes after the address of the stm instruction
        add     r2, r2, #8
        ldr     r3, [r1]
        cmp     r2, r3
        movne   r10, #80
        bne     testfail
        
        @ check that r14 was stored in the correct place
        ldr     r1, StoreBase
        sub     r1, r1, #4
        ldr     r4, [r1]
        cmp     r4, #97
        movne   r10, #90
        bne     testfail
        
        
@ ------------------------------------------        
@ 5. stmdb   r9!, {r0, r9, r10}
@ Test non-continuous range of registers
@ Test that r9 is updated correctly
@ ------------------------------------------        
        mov     r0,  #17
        ldr     r9,  StoreBase
        mov     r10, #18
        stmdb   r9!, {r0, r9, r10}

        ldr     r3,  StoreBase
        sub     r3,  r3, #12
        ldr     r4,  [r3], #4
        cmp     r4,  #17
        movne   r10, #100
        bne     testfail
        
        @ r9 is the second register on the list, so the updated
        @ value gets stored in StoreBase - 8
        ldr     r4,  [r3]       @ r3 points to StoreBase - 8
        ldr     r3,  StoreBase
        sub     r3,  r3, #12
        cmp     r3,  r4
        movne   r10, #110
        bne     testfail
        
        ldr     r3,  StoreBase
        sub     r3,  r3, #4
        ldr     r4,  [r3]
        cmp     r4,  #18
        movne   r10, #120
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
AdrData1:       .word  Data1
AdrData2:       .word  Data2
StoreBase:      .word  0x800
Data1:          .word  0x12345678
Data2:          .word  0xffccbbaa
Data3:          .word  0x12345600

/* ========================================================================= */
/* ========================================================================= */
        

