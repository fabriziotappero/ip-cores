/*****************************************************************
//                                                              //
//  Amber 2 System UART Test                                    //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests the UART receive interrupt function                   //
//  Some text is sent from the test_uart to the uart            //
//  and an interrupt generated.                                 //
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
        /* 0x00 Reset Interrupt vector address */
        b       start
        
        /* 0x04 Undefined Instruction Interrupt vector address */
        b       testfail
        
        /* 0x08 SWI Interrupt vector address */
        b       testfail
        
        /* 0x0c Prefetch abort Interrupt vector address */
        b       testfail
        
        /* 0x10 Data abort Interrupt vector address */
        b       testfail
        b       testfail
        
        /* 0x18 IRQ vector address */
        b       service_irq
        
        /* 0x1c FIRQ vector address */
        b       testfail


start:
        /* Switch to User Mode */
        /* and unset interrupt mask bits */
        mov     r0,   #0x00000000
        teqp    pc, r0  


        @ Configure the Amber UART to use the FIFO to receive
        ldr     r4, AdrUART0LCRH
        mov     r5, #0x10
        str     r5, [r4]
        
        @ Configure the Amber UART to enable the receive interrupt
        ldr     r4, AdrUART0CR 
        mov     r5, #0x10
        str     r5, [r4]
        
        @ Configure the interrupt controller to enable the UART0 interrupt
        ldr     r4, AdrIC_IRQ0_ENABLESET  
        mov     r5, #0x2
        str     r5, [r4]
        
        
        @ Load some bytes into the testbench uart
        @ so it can transmit them to the Amber UART
        ldr     r4, AdrTEST_UART_TXD
        ldr     r5, =Message
        ldr     r9, =Message
        ldr     r7, =EndMessage
        ldr     r8, AdrTEST_UART_STATUS       
         
        @ transmit a byte from test uart
        ldrb    r6, [r5], #1
        str     r6, [r4]

        @ test_uart transmit enable
        ldr     r0, AdrTEST_UART_CONTROL
        mov     r1, #1
        str     r1, [r0]

main_loop:        
        @ wait if test_uart tx fifo full
1:      ldr     r0, [r8]
        ands    r0, r0, #2
        bne     1b

        @ transmit a byte from test uart
        ldrb    r6, [r5], #1
        str     r6, [r4]
        
        @ full message transmitted?
        cmp     r5, r7
        bne     main_loop


        @ while test_uart tx fifo empty == 0
2:      ldr     r0, [r8]
        ands    r0, r0, #1
        beq     2b

        @ wait until uart tx fifo empty == 1
        ldr     r3, AdrUART0FR @ flags
3:      ldr     r1, [r3]
        ands    r1, r1, #0x80
        beq     3b
        
        b       testpass

                
@ ------------------------------------------        
@ ------------------------------------------        

service_irq:
        ldr     r2, AdrUART0DR @ rx/tx byte
        ldr     r3, AdrUART0FR @ flags

1:      ldr     r0, [r3]    
        ands    r0, r0, #0x10
        @ Jump straight back to normal execution if rx fifo empty
        subnes  pc, lr, #4
        
        ldrb    r0, [r2]        @ uart rx byte
        ldrb    r1, [r9], #1    @ transmitted text
        cmp     r0, r1
        movne   r10, #20
        bne     testfail                
        
        @ check if there are more bytes in rx buffer
        b       1b


testfail:
        ldr     r11, AdrTEST_STATUS
        str     r10, [r11]
        b       testfail        
                
testpass:             
        ldr     r11, AdrTEST_STATUS
        mov     r10, #17
        str     r10, [r11]
        b       testpass
               

@ ------------------------------------------        
@ ------------------------------------------        

/* Write 17 to this address to generate a Test Passed message */
AdrTEST_STATUS:         .word  ADR_AMBER_TEST_STATUS    
AdrTEST_IRQ_TIMER:      .word  ADR_AMBER_TEST_IRQ_TIMER 
AdrTEST_RANDOM_NUM:     .word  ADR_AMBER_TEST_RANDOM_NUM
AdrTEST_UART_CONTROL:   .word  ADR_AMBER_TEST_UART_CONTROL     
AdrTEST_UART_STATUS:    .word  ADR_AMBER_TEST_UART_STATUS     
AdrTEST_UART_TXD:       .word  ADR_AMBER_TEST_UART_TXD  
AdrIC_IRQ0_ENABLESET:   .word  ADR_AMBER_IC_IRQ0_ENABLESET
AdrUART0LCRH:           .word  ADR_AMBER_UART0_LCRH
AdrUART0CR:             .word  ADR_AMBER_UART0_CR
AdrUART0DR:             .word  ADR_AMBER_UART0_DR
AdrUART0FR:             .word  ADR_AMBER_UART0_FR
Message:                .ascii "\nThis message is brought to you by UART0\nIsnt that cool\nThats all folks\n"
EndMessage:             .word  0
