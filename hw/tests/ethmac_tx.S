/*****************************************************************
//                                                              //
//  Amber 2 System Ethernet MAC Test                            //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests ethernet MAC frame transmit and receive functions     //
//  and Ethmac DMA access to hiboot mem. Ethmac is put in       //
//  loopback mode and a packet is transmitted and received.     //
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
        ldr     r0, AdrEthMacMemBase

/* Write the Transmit Packet Buffer Descriptor */
        ldr     r1, TxBufferW0
        str     r1, [r0]
        ldr     r1, TxBufferW1
        add     r1, r1, #2      @ shift start by 2 bytes
        str     r1, [r0, #4]
        
/* Write the Receive Packet Buffer Descriptor */
        ldr     r1, RxBufferW0
        str     r1, [r0, #0x200]
        ldr     r1, RxBufferW1
        str     r1, [r0, #0x204]

/* Copy a Frame into the transmit buffer */
        ldr     r0, TxBufferW1
        ldr     r1, =TxFrame
        ldr     r2, =EndTxFrame
        
        @ copy 8 words at a time
1:      ldmia   r1!, {r3-r10}
        stmia   r0!, {r3-r10}
        
        cmp     r1, r2
        blt     1b

        
/*  Set Mode Register */
        ldr     r0, AdrEthMacModer
        ldr     r1, EthMacModerValue
        str     r1, [r0]

        
/* Start transmit */
        ldr     r0, AdrEthMacMemBase
        ldr     r1, TxBufferW0
        orr     r1, r1, #0x8000
        str     r1, [r0]


/* Check register values */
        ldr     r0, AdrEthMacModer
        ldr     r1, EthMacModerValue
        ldr     r2, [r0]
        cmp     r1, r2
        movne   r10, #200
        bne     testfail
        
        ldr     r0, AdrEthMacMemBase
        ldr     r1, TxBufferW0
        orr     r1, r1, #0x8000
        ldr     r2, [r0]
        cmp     r1, r2
        movne   r10, #220
        bne     testfail
        

/* Wait until receive complete - Wait for Empty bit to go low */
2:      ldr     r1, [r0, #0x200]
        ands    r1, r1, #0x8000
        bne     2b

/* Wait a bit */
        mov     r0, #80
3:      subs    r0, r0, #1
        bne     3b
        
        
/* Check receive buffer */       
        ldr     r0, RxBufferW1
        add     r3, r0, #2
        ldr     r1, =TxFrame
        add     r1, r1, #4
        ldr     r2, =EndTxFrame
        @ end of frame is crc which is different so dont check it
        sub     r2, r2, #4
        
        @ there is a 2-byte shift from tx to rx buffer
        @ so load in the data from the rx buffer in 2 byte chunks
        @ and re-arrange to match the tx buffer
 4:     ldr     r4, [r0, #4]!
        mov     r6, r4, lsl #16
        ldr     r5, [r3], #4
        ldr     r12, LoMask
        and     r5, r5, r12
        orr     r7, r5, r6
        
        ldr     r8, [r1], #4
        
        cmp     r7, r8
        movne   r10, #100
        bne     testfail
   
        cmp     r1, r2
        blt     4b
                    
        
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
AdrEthMacMemBase:       .word  ADR_ETHMAC_BDBASE
EthMacModerDefault:     .word  0x0000a000
ExpectedMIIReadBack:    .word  0x0000ffff
LoMask:                 .word  0x0000ffff

/* [31:16] = length in bytes, Bit[15] = ready, Bit [13] = wrap bit */
TxBufferW0:             .word  0x00a02800
/* [31:16] = length in bytes, Bit[15] = empty, Bit [13] = wrap bit */
RxBufferW0:             .word  0x0000a800


/* Buffer Pointer in Main Memory */
TxBufferW1:             .word  0x00011000
RxBufferW1:             .word  0x00011200


/*
 Ethmac Mode Register
 [15] = Add pads to short frames
 [13] = CRCEN
 [7]  = loopback
 [5]  = 1 for promiscuous, 0 rx only frames that match mac address
 [1]  = txen
 [0]  = rxen
*/
EthMacModerValue:       .word  0xa0a3

TxFrame:
.word  0x0e000000
.word  0xa0583e0c  @ rx  1200: 3e0c 0e00
.word  0x554e5300  @ rx  1204: 5300 a058
.word  0x0008304c
.word  0x90000045
.word  0x00400000
.word  0xd5b61140
.word  0x0501a8c0
.word  0x3201a8c0
.word  0x01080203
.word  0xb6c47c00
.word  0xf67d4fc7
.word  0x00000000
.word  0x02000000
.word  0xa3860100
.word  0x03000000
.word  0x06000000
.word  0x01000000
.word  0x18000000
.word  0x025b8f02
.word  0x02000000
.word  0x00003170
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x00000000
.word  0x24000000
.word  0x01070001
.word  0x00143ed5
.word  0x00000000
.word  0x2c043c7f
.word  0x6c41657c
.word  0x8cc37e87
.word  0x2340a928
.word  0x0026048e
.word  0xec587a0e
.word  0x00000000
.word  0x00080000
.word  0x00080000
.word  0x00000000
EndTxFrame:
.word  0
.word  0
.word  0
.word  0
.word  0
.word  0
.word  0

/* ========================================================================= */
/* ========================================================================= */
        
