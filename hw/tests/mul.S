/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests the mul (multiply) instruction                        //
//                                                              //
//  Uses a testset of 16 numbers and multiplies them            //
//  with eachother in every combination - 256 multiplications.  //
//  Checks each result against an expected result               //
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

        @ -------------------------------
        @ Test mul
        @ -------------------------------
        mov     r6, #0
        ldr     r8, AdrTestset
        
        
loop:   and     r2, r6, #0xf
        ldr     r7, [r8, r2, lsl #2]
        
        and     r4, r6, #0xf0
        ldr     r5, [r8, r4, lsr #2]
        
        mul     r4, r7, r5
                
        @-------------------------------
        @ Check Result
        @ -------------------------------
        ldr     r9,  AdrAnswers
        ldr     r10, [r9, r6, lsl #2]
        cmp     r4, r10
        bne     testfail
        
        add     r6, r6, #1
        cmp     r6, #256
        beq     test2       
        b       loop        



test2:
        @-------------------------------
        @ Test Flags
        @ Only the N and Z flags get set
        @ the C and V flags can be unpredictable in v4
        @ but this implementation leaves them at their
        @ old values
        @ -------------------------------
        @ clear flags first
        bic     r2, r2, #0xf0000000
        teqp    pc, r2
    
        mov     r0, #1
        mov     r1, #-1
        
        muls    r2, r0, r1

        mov     r4, pc
        and     r4, r4, #0xf0000000 @ clear non-flag bits
        cmp     r4,     #0x80000000
        movne   r10, #100
        bne     testfail2

        cmp     r2, #-1
        movne   r10, #110
        bne     testfail2


test3:
        @-------------------------------
        @ Test Flags
        @ This time ensure that C and V retain their
        @ old values
        @ -------------------------------
        @ clear flags first
        mov     r2, pc
        ldr     r7, PCMask
        bic     r2, r2, r7           @ clear pc bits
        bic     r2, r2, #0xf0000000  @ clear condition clags
        orr     r2, r2, #0x30000000  @ set C and V flags
        teqp    pc, r2
    
        mov     r0, #0
        mov     r1, #-1
        
        muls    r2, r0, r1

        mov     r4, pc
        and     r4, r4, #0xf0000000 @ clear non-flag bits
        cmp     r4,     #0x70000000 
        movne   r10, #120
        bne     testfail2

        cmp     r2, #0
        movne   r10, #130
        bne     testfail2


test4:
        @-------------------------------
        @ Test sequence of back-to-back MULs 
        @ where only some are executed
        @-------------------------------
        mov     r0, #1
        mov     r1, #2
        mov     r2, #7
        mov     r3, #3
        mov     r4, #5
        mov     r5, #6
        
        mov     r7,  #0
        mov     r8,  #0
        mov     r9,  #0
        mov     r10, #0
        
        cmp     r0, r1
        
        mulne   r7,  r4, r5     @ executes
        muleq   r8,  r2, r3     @ doesnt execute
        mulne   r9,  r1, r4     @ executes
        mulne   r10, r3, r3     @ executes
        
        cmp     r7, #30
        movne   r10, #200
        bne     testfail2
        
        cmp     r8, #0
        movne   r10, #210
        bne     testfail2
        
        cmp     r9, #10
        movne   r10, #220
        bne     testfail2
        
        cmp     r10, #9
        movne   r10, #230
        bne     testfail2

test5:        
        @-------------------------------
        @ Test sequence of back-to-back MULs 
        @ where only some are executed
        @ and some change flags
        @-------------------------------
        mov     r0, #0
        mov     r1, #-1
        mov     r2, #7
        mov     r3, #3
        mov     r4, #5
        mov     r5, #6
        
        mov     r7,  #0
        mov     r8,  #0
        mov     r9,  #0
        mov     r10, #0
        
        cmp     r0, r1
        
        mulnes  r7,  r0, r1     @ executes and changes flags
        muleq   r8,  r2, r3     @ executes
        mulne   r9,  r1, r4     @ doesnt execute
        mulne   r10, r3, r3     @ doesnt executes
        
        cmp     r7, #0
        movne   r10, #240
        bne     testfail2
        
        cmp     r8, #21
        movne   r10, #245
        bne     testfail2
        
        cmp     r9, #0
        movne   r10, #250
        bne     testfail2
        
        cmp     r10, #0
        movne   r10, #255
        bne     testfail2
        
        
test6:        
        @-------------------------------
        @ Test tricky sequence of operations
        @-------------------------------
        mov     r3, #1
        mov     r5, #0
        mov     r1, #7
        cmp     r1, #7
        
        ldreq   r2, Data1       @ 3
        ldrne   r3, Data2       @ 7, not loaded
        muleq   r4, r2, r3
        ldrne   r5, Data2
        
        cmp     r5, #0
        movne   r10, #150
        bne     testfail2
        
        cmp     r4, #3
        movne   r10, #160
        bne     testfail2
        
@ ------------------------------------------        
@ ------------------------------------------        

        b       testpass
        
testfail:
testfail2:
        ldr     r11, AdrTestStatus
        str     r10, [r11]
        b       testfail2
        
testpass:             
        ldr     r11, AdrTestStatus
        mov     r10, #17
        str     r10, [r11]
        b       testpass
               
               
@ ------------------------------------------        
@ ------------------------------------------        

/* Write 17 to this address to generate a Test Passed message */
AdrTestStatus:  .word  ADR_AMBER_TEST_STATUS
AdrTestset:     .word  Testset
AdrAnswers:     .word  Answers
Data1:          .word  0x3
Data2:          .word  0x7
PCMask:         .word  0x03fffffc


Testset:
.word  0
.word  1
.word  2
.word  3 
.word  27
.word  0x0000ffff
.word  0x40000000
.word  0x7fffffff 
.word  0x7ffffffe
.word  0xffffffff
.word  0xfffffffe
.word  0xfffffffd 
.word  0xffffffe5
.word  0x8fff0000
.word  0x80000000
.word  0x80000001


Answers:      
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000001
.word  0x00000002
.word  0x00000003
.word  0x0000001b
.word  0x0000ffff
.word  0x40000000
.word  0x7fffffff
.word  0x7ffffffe
.word  0xffffffff
.word  0xfffffffe
.word  0xfffffffd
.word  0xffffffe5
.word  0x8fff0000
.word  0x80000000
.word  0x80000001
.word  0x00000000
.word  0x00000002
.word  0x00000004
.word  0x00000006
.word  0x00000036
.word  0x0001fffe
.word  0x80000000
.word  0xfffffffe
.word  0xfffffffc
.word  0xfffffffe
.word  0xfffffffc
.word  0xfffffffa
.word  0xffffffca
.word  0x1ffe0000
.word  0x00000000
.word  0x00000002
.word  0x00000000
.word  0x00000003
.word  0x00000006
.word  0x00000009
.word  0x00000051
.word  0x0002fffd
.word  0xc0000000
.word  0x7ffffffd
.word  0x7ffffffa
.word  0xfffffffd
.word  0xfffffffa
.word  0xfffffff7
.word  0xffffffaf
.word  0xaffd0000
.word  0x80000000
.word  0x80000003
.word  0x00000000
.word  0x0000001b
.word  0x00000036
.word  0x00000051
.word  0x000002d9
.word  0x001affe5
.word  0xc0000000
.word  0x7fffffe5
.word  0x7fffffca
.word  0xffffffe5
.word  0xffffffca
.word  0xffffffaf
.word  0xfffffd27
.word  0x2fe50000
.word  0x80000000
.word  0x8000001b
.word  0x00000000
.word  0x0000ffff
.word  0x0001fffe
.word  0x0002fffd
.word  0x001affe5
.word  0xfffe0001
.word  0xc0000000
.word  0x7fff0001
.word  0x7ffe0002
.word  0xffff0001
.word  0xfffe0002
.word  0xfffd0003
.word  0xffe5001b
.word  0x70010000
.word  0x80000000
.word  0x8000ffff
.word  0x00000000
.word  0x40000000
.word  0x80000000
.word  0xc0000000
.word  0xc0000000
.word  0xc0000000
.word  0x00000000
.word  0xc0000000
.word  0x80000000
.word  0xc0000000
.word  0x80000000
.word  0x40000000
.word  0x40000000
.word  0x00000000
.word  0x00000000
.word  0x40000000
.word  0x00000000
.word  0x7fffffff
.word  0xfffffffe
.word  0x7ffffffd
.word  0x7fffffe5
.word  0x7fff0001
.word  0xc0000000
.word  0x00000001
.word  0x80000002
.word  0x80000001
.word  0x00000002
.word  0x80000003
.word  0x8000001b
.word  0x70010000
.word  0x80000000
.word  0xffffffff
.word  0x00000000
.word  0x7ffffffe
.word  0xfffffffc
.word  0x7ffffffa
.word  0x7fffffca
.word  0x7ffe0002
.word  0x80000000
.word  0x80000002
.word  0x00000004
.word  0x80000002
.word  0x00000004
.word  0x80000006
.word  0x80000036
.word  0xe0020000
.word  0x00000000
.word  0x7ffffffe
.word  0x00000000
.word  0xffffffff
.word  0xfffffffe
.word  0xfffffffd
.word  0xffffffe5
.word  0xffff0001
.word  0xc0000000
.word  0x80000001
.word  0x80000002
.word  0x00000001
.word  0x00000002
.word  0x00000003
.word  0x0000001b
.word  0x70010000
.word  0x80000000
.word  0x7fffffff
.word  0x00000000
.word  0xfffffffe
.word  0xfffffffc
.word  0xfffffffa
.word  0xffffffca
.word  0xfffe0002
.word  0x80000000
.word  0x00000002
.word  0x00000004
.word  0x00000002
.word  0x00000004
.word  0x00000006
.word  0x00000036
.word  0xe0020000
.word  0x00000000
.word  0xfffffffe
.word  0x00000000
.word  0xfffffffd
.word  0xfffffffa
.word  0xfffffff7
.word  0xffffffaf
.word  0xfffd0003
.word  0x40000000
.word  0x80000003
.word  0x80000006
.word  0x00000003
.word  0x00000006
.word  0x00000009
.word  0x00000051
.word  0x50030000
.word  0x80000000
.word  0x7ffffffd
.word  0x00000000
.word  0xffffffe5
.word  0xffffffca
.word  0xffffffaf
.word  0xfffffd27
.word  0xffe5001b
.word  0x40000000
.word  0x8000001b
.word  0x80000036
.word  0x0000001b
.word  0x00000036
.word  0x00000051
.word  0x000002d9
.word  0xd01b0000
.word  0x80000000
.word  0x7fffffe5
.word  0x00000000
.word  0x8fff0000
.word  0x1ffe0000
.word  0xaffd0000
.word  0x2fe50000
.word  0x70010000
.word  0x00000000
.word  0x70010000
.word  0xe0020000
.word  0x70010000
.word  0xe0020000
.word  0x50030000
.word  0xd01b0000
.word  0x00000000
.word  0x00000000
.word  0x8fff0000
.word  0x00000000
.word  0x80000000
.word  0x00000000
.word  0x80000000
.word  0x80000000
.word  0x80000000
.word  0x00000000
.word  0x80000000
.word  0x00000000
.word  0x80000000
.word  0x00000000
.word  0x80000000
.word  0x80000000
.word  0x00000000
.word  0x00000000
.word  0x80000000
.word  0x00000000
.word  0x80000001
.word  0x00000002
.word  0x80000003
.word  0x8000001b
.word  0x8000ffff
.word  0x40000000
.word  0xffffffff
.word  0x7ffffffe
.word  0x7fffffff
.word  0xfffffffe
.word  0x7ffffffd
.word  0x7fffffe5
.word  0x8fff0000
.word  0x80000000
.word  0x00000001
