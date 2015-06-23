/*****************************************************************
//                                                              //
//  Amber 2 System Ethernet MAC Test                            //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests wishbone access to registers in the Ethernet MAC      //
//  module.                                                     //
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

        @ Test reading of a register in the ethmac module
        ldr     r0, AdrEthMacModer
        ldr     r1, [r0]
        ldr     r2, EthMacModerDefault
        cmp     r1, r2
        movne   r10, #10
        bne     testfail

        @ Turn on Duplex Mode, bit 10, and write back new value
        orr     r1, r1, #0x400
        str     r1, [r0]
        
        @ Read back again to check the value
        ldr     r3, [r0]
        orr     r2, r2, #0x400
        cmp     r3, r2
        movne   r10, #20
        bne     testfail
        
        @ Set clock divider to 10 -> 3.3MHz MDC
        ldr     r4, AdrEthMacMIIModer
        mov     r5, #10
        str     r5, [r4]
        
        @ Set MII address - device [4:0], register [12:8]
        ldr     r4, AdrEthMacMIIAddress
        mov     r5,       #0x07

		@ MII_BMSR register in eth_test.v has reg address of 1
        orr     r5, r5, #0x0100
        str     r5, [r4]
        
        @ receive (read PHY register) Command
        ldr     r4, AdrEthMacMIICommand
        mov     r5, #0x2
        str     r5, [r4]
         
        @ wait for busy, bit 1, to go low
        @ Use r6 as a timeout
        ldr     r4, AdrEthMacMIIStatus
        mov     r6, #0
wait_busy:
        add     r6, r6, #1
        cmp     r6, #0x400
        @ Timeout error
        moveq   r10, #30
        beq     testfail
        
        ldr     r5, [r4]
        ands    r5, r5, #2  
        beq     readback
        b       wait_busy

        
readback:
        ldr     r4, AdrEthMacMIIRxData
        ldr     r5, [r4]
        ldr     r6, ExpectedMIIReadBack
        cmp     r5, r6
        movne   r10, #100
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
AdrTestStatus:          .word  ADR_AMBER_TEST_STATUS
AdrEthMacModer:         .word  ADR_ETHMAC_MODER
AdrEthMacMIIModer:      .word  ADR_ETHMAC_MIIMODER  
AdrEthMacMIICommand:    .word  ADR_ETHMAC_MIICOMMAND
AdrEthMacMIIAddress:    .word  ADR_ETHMAC_MIIADDRESS
AdrEthMacMIITxData:     .word  ADR_ETHMAC_MIITXDATA 
AdrEthMacMIIRxData:     .word  ADR_ETHMAC_MIIRXDATA 
AdrEthMacMIIStatus:     .word  ADR_ETHMAC_MIISTATUS
 
EthMacModerDefault:     .word  0x0000a000
ExpectedMIIReadBack:    .word  0x0000fe04  @ value from eth_test.v, state MD_TURN1


/* ========================================================================= */
/* ========================================================================= */
        
