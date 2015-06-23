/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests swp and swpb                                          //
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
        @ swp     r2, r2, [r0]
        @ ---------------------
        ldr     r0, AdrData1
        mov     r2, #2
        swp     r2, r2, [r0]

        @ check the value written to memory        
        ldr     r3, Data1
        cmp     r3, #2
        movne   r10, #10
        bne     testfail
        
        @ check the value read from  memory        
        ldr     r4, Data4
        cmp     r4, r2
        movne   r10, #20
        bne     testfail
        
        
        @ ---------------------
        @ swpb    r2, r2, [r0]
        @ ---------------------
        ldr     r0, AdrData2
        add     r0, r0, #1
        ldr     r2, Data3
        swpb    r2, r2, [r0]

        @ check the value written to memory        
        ldr     r3, Data2
        ldr     r4, Data5
        cmp     r3, r4
        movne   r10, #30
        bne     testfail
        
        @ check the value read from to memory        
        mov     r5, #0xbb
        cmp     r2, r5
        movne   r10, #40
        bne     testfail
        
        @ ---------------------
        @ Test flow control, skip
        @ ---------------------
        mov     r7, #2
        mov     r8, #3
        cmp     r7, r8
        swpeq   r2, r2, [r0]
        b       check4
        
        @ these should never be executed
        b       testfail
        b       testfail

check4:
        @ check that r2 did not change
        cmp     r2, r5
        movne   r10, #50
        bne     testfail



        @ ---------------------
        @ Test flow control, skip first, execute second
        @ ---------------------
        ldr     r9, AdrData6
        mov     r7, #2
        mov     r8, #3
        cmp     r7, r8
        swpeq   r2, r2, [r9]
        swpne   r3, r3, [r9]
        b       check5

        @ these should never be executed
        b       testfail
        b       testfail
        
check5:
        @ check that r2 did not change
        cmp     r2, r5
        movne   r10, #60
        bne     testfail
        
        @ check that r3 holds correct value
        ldr     r8, Data7
        cmp     r3, r8 
        movne   r10, #70
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


@ put this data section here so its reachable
@ by the 8-bit immediate offset in LDRH
Data1:          .word  0x12345678
Data2:          .word  0xffccbbaa
Data3:          .word  0x01020304
Data4:          .word  0x12345678
Data5:          .word  0xffcc04aa
Data6:          .word  0x33445566
Data7:          .word  0x33445566

/* Write 17 to this address to generate a Test Passed message */
AdrTestStatus:  .word  ADR_AMBER_TEST_STATUS
AdrData1:       .word  Data1
AdrData2:       .word  Data2
AdrData3:       .word  Data3
AdrData4:       .word  Data4
AdrData5:       .word  Data5
AdrData6:       .word  Data6

/* ========================================================================= */
/* ========================================================================= */
        

