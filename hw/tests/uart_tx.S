/*****************************************************************
//                                                              //
//  Amber 2 System UART Test                                    //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Uses the tb_uart in loopback mode to verify the transmitted //
//  data.                                                       //
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
        
        @ Put test_uart into loopback mode, and enable transmit        
        ldr     r0, AdrTEST_UART_CONTROL
        mov     r1, #0x3
        str     r1, [r0]
        
        @ Write to and read back from UART0 registers
        ldr     r4, AdrUART0DR
        ldr     r5, =Message
        ldr     r9, =Message
        ldr     r7, =EndMessage

1:      bl      wait_tx_full
        ldrb    r6, [r5], #1
        @ transmit byte from test_uart
        str     r6, [r4]
        bl      uart_rx_check        
        @ keep doing this until get to the end of the message
        cmp     r5, r7
        bne     1b

        @ The complete message has now been transmitted
        @ but some bytes are still en route
        @ check the last few bytes received
        bl      uart_rx_check
        
        @ check that all bytes were received
        add     r9, r9, #2
        cmp     r9, r7
        movne   r10, #100
        bne     testfail
                
        b       testpass

        @ -------------------------------------------


wait_tx_full:
        @ with timeout loop of 0x400
        ldr     r0, AdrUART0FR
        mov     r2, #0x400
1:      subs    r2, r2, #1
        moveq   r10, #100
        beq     testfail
        ldr     r1, [r0]
        ands    r1, r1, #0x20
        bne     1b
        mov     pc, lr


uart_rx_check:
        ldr     r2, AdrUART0DR @ rx/tx byte
        ldr     r3, AdrUART0FR @ flags

        @ if rx fifo empty flag == 1, return without doing anything
1:      ldr     r0, [r3]    
        ands    r0, r0, #0x10
        movne   pc, lr
        
        ldrb    r0, [r2]        @ uart rx byte
        ldrb    r1, [r9], #1    @ transmitted text
        cmp     r0, r1
        movne   r10, #20
        bne     testfail                
        
        @ check if there are more bytes in rx buffer
        b       1b


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
AdrTestStatus:          .word  ADR_AMBER_TEST_STATUS

AdrTEST_UART_CONTROL:   .word  ADR_AMBER_TEST_UART_CONTROL     
AdrUART0DR:             .word  ADR_AMBER_UART0_DR
AdrUART0FR:             .word  ADR_AMBER_UART0_FR
Message:                .ascii "\nThis message is brought to you by UART0\nThats all folks\n"
EndMessage:             .word  0
