/*****************************************************************
//                                                              //
//  Amber 2 System Ethernet MAC Test                            //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests wishbone access to the internal memory in the         //
//  Ethernet MAC module.                                        //
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

        @ Test reading of ethmac's internal BD memory
        @ 0x400 to 0x7ff
        ldr     r0, AdrEthMacMemBase
        ldr     r1, Data0
        str     r1, [r0], #4
        ldr     r1, Data1
        str     r1, [r0], #4
        ldr     r1, Data2
        str     r1, [r0], #4
        ldr     r1, Data3
        str     r1, [r0], #4
        
        @ Read back and check the 4 values
        ldr     r0, AdrEthMacMemBase
        ldr     r2, [r0], #4
        ldr     r3, Data0
        cmp     r2, r3
        movne   r10, #10
        bne     testfail

        ldr     r2, [r0], #4
        ldr     r3, Data1
        cmp     r2, r3
        movne   r10, #20
        bne     testfail

        ldr     r2, [r0], #4
        ldr     r3, Data2
        cmp     r2, r3
        movne   r10, #30
        bne     testfail
        
        ldr     r2, [r0], #4
        ldr     r3, Data3
        cmp     r2, r3
        movne   r10, #40
        bne     testfail


        @ Write all locations from 0x400 to 0x7ff, with Data == Address
        ldr     r0, AdrEthMacMemBase
        add     r1, r0, #0x400
        mov     r2, #0

1:      str     r2, [r0], #4
        cmp     r0, r1
        beq     checkem
        add     r2, r2, #4
        b       1b        
        
checkem:       
        @ Now read back all the locations, checking the values
        ldr     r0, AdrEthMacMemBase
        mov     r2, #0
        
2:      ldr     r3, [r0], #4
        
        cmp     r2, r3
        movne   r10, r0
        subne   r10, r10, #4
        bne     testfail
        
        add     r2, r2, #4
        
        cmp     r0, r1
        beq     testpass
        b       2b
        
        
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
AdrEthMacMemBase:       .word  ADR_ETHMAC_BDBASE

Data0:                  .word  0xc0c0c0c0
Data1:                  .word  0xff00ff00
Data2:                  .word  0x12345678
Data3:                  .word  0x77777777


/* ========================================================================= */
/* ========================================================================= */
