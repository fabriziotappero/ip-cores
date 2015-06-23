/*****************************************************************
//                                                              //
//  Amber 2 System UART Test                                    //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests wishbone read and write access to the Amber UART      //
//  registers.                                                  //
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

        @ -------------------------------------------
        @ Write to and read back from UART0 registers
        ldr     r0, AdrUart0LCRH
        ldr     r1, AdrUart0LCRM
        ldr     r2, AdrUart0LCRL
        
        mov     r7, #0x80
        mov     r8, #0x0f
        mov     r9, #0xcc
        
        str     r7, [r0]
        str     r8, [r1]
        str     r9, [r2]
        
        @ Read Back
        ldr     r4, [r0]
        ldr     r5, [r1]
        ldr     r6, [r2]
        
        
        @ Check values read back
        cmp     r4, r7
        movne   r10, #10
        bne     testfail
        
        cmp     r5, r8
        movne   r10, #20
        bne     testfail
        
        cmp     r6, r9
        movne   r10, #30
        bne     testfail
        

        @ -------------------------------------------
        @ Write to and read back from UART1 registers
        ldr     r0, AdrUart1LCRH
        ldr     r1, AdrUart1LCRM
        ldr     r2, AdrUart1LCRL
        
        mov     r7, #0x44
        mov     r8, #0x22
        mov     r9, #0x55
        
        str     r7, [r0]
        str     r8, [r1]
        str     r9, [r2]
        
        @ Read Back
        ldr     r4, [r0]
        ldr     r5, [r1]
        ldr     r6, [r2]
        
        
        @ Check values read back
        cmp     r4, r7
        movne   r10, #40
        bne     testfail
        
        cmp     r5, r8
        movne   r10, #50
        bne     testfail
        
        cmp     r6, r9
        movne   r10, #60
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
               

@ ------------------------------------------        
@ ------------------------------------------        

/* Write 17 to this address to generate a Test Passed message */
AdrTestStatus:  .word  ADR_AMBER_TEST_STATUS

AdrUart0LCRH:   .word  ADR_AMBER_UART0_LCRH
AdrUart0LCRM:   .word  ADR_AMBER_UART0_LCRM
AdrUart0LCRL:   .word  ADR_AMBER_UART0_LCRL

AdrUart1LCRH:   .word  ADR_AMBER_UART1_LCRH
AdrUart1LCRM:   .word  ADR_AMBER_UART1_LCRM
AdrUart1LCRL:   .word  ADR_AMBER_UART1_LCRL

