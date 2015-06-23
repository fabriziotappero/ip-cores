/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests str and strb with different indexing modes.           //
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

        /* Store single Byte */
        ldr     r0,  StoreBase
        add     r0,  r0, #4
        mov     r4,  #0
        str     r4,  [r0]
        ldr     r1,  Data1
        strb    r1, [r0]
        
        and     r3, r1, #0xff
        ldr     r2, [r0]
        cmp     r3, r2
        movne   r10, #10   @ error number
        bne     testfail

        /* Store Byte at address 1, 2 and 3 */
        ldr     r0,  StoreBase
        add     r0,  r0, #8
        mov     r4,  #0
        @ start by writing a word of 0 to the memory location
        str     r4, [r0], #1
        ldr     r1,  Data1
        
        @ then store byte 0 in r1 to 3 positions
        @ in the memory location
        strb    r1, [r0], #1
        strb    r1, [r0], #1
        strb    r1, [r0], #1
        
        @ load back the memory location and check its contents
        ldr     r0,  StoreBase
        ldr     r2,  [r0, #8]
        ldr     r3,  Data3
        cmp     r2, r3
        movne   r10, #20   @ error number
        bne     testfail        
        
        /* Reverse order of bytes */
        @ read in Data1 and store it out to
        @ StoreBase + 12, reversing the order 
        @ of the bytes
        ldr     r2,  StoreBase
        add     r2, r2, #12
        ldr     r1,  Data1
        
        @ store byte 3
        mov     r1, r1, ror #24
        strb    r1, [r2], #1
        
        @ store byte 2
        mov     r1, r1, ror #24
        strb    r1, [r2], #1
        
        @ store byte 1
        mov     r1, r1, ror #24
        strb    r1, [r2], #1
        
        @ store byte 0
        mov     r1, r1, ror #24
        strb    r1, [r2], #1
        
        ldr     r2,  StoreBase
        add     r2, r2, #12
        ldr     r3, [r2]
        ldr     r4, Data4
        cmp     r3, r4
        movne   r10, #30
        bne     testfail
        
        /* Store word */
        ldr     r0,  StoreBase
        ldr     r1,  Data1
        str     r1, [r0]
        
        ldr     r2, [r0]
        cmp     r1, r2
        movne   r10, #50   @ error number
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
Data3:          .word  0x78787800
Data4:          .word  0x78563412

/* ========================================================================= */
/* ========================================================================= */
        

