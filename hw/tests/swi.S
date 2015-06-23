/*****************************************************************
//                                                              //
//  Amber 2 Core Interrupt Test                                 //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests the software interrupt - swi.                         //
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
        b       service_swi
        
        /* 0x0c Prefetch abort Interrupt vector address */
        b       testfail
        
        /* 0x10 Data abort Interrupt vector address */
        b       testfail
        b       testfail
        
        /* 0x18 IRQ vector address */
        b       testfail
        
        /* 0x1c FIRQ vector address */
        b       testfail

start:
        /* Switch to User Mode */
        /* and unset interrupt mask bits */
        mov     r0,   #0x00000000
        teqp    pc, r0        
        
        @ Check that we're in user mode now
        mov     r2, pc
        ands    r2, r2, #3
        movne   r10, #10
        bne     testfail        
    
        @ ---------------------------------
        @ Test a SWI that does execute
        @ ---------------------------------
        swieq   #0xff8877                      
pos1:   b       testpass
        b       testfail
        b       testfail

continue:
        mov     r1, #3
        mov     r2, #2
        cmp     r1, r2
        moveq   r3, #17
        @ ---------------------------------
        @ Test a SWI that does not execute
        @ ---------------------------------
        swieq   #0xff1122
        moveq   r10, #20
        beq     testfail
        
        bne     testpass
        
@ ---------------------------------
@ Test Conditional Execution of SWI
@ ---------------------------------

        
service_swi:
        @ Check that the address immediately
        @ after the SWI instruction is saved
        @ in the supervisor mode lr
        ldr     r0, Adrpos1
        ldr     r13, PCMask
        and     r14, r14, r13
        cmp     r0, r14
        movne   r10, #20
        bne     testfail
        
        @ Check that we're back in supervisor mode now
        mov     r2, pc
        @ filter out all bits other than mode bits
        and     r2, r2, #0x3
        cmp     r2, #0x00000003
        movne   r10, #30
        bne     testfail        
        
@ ------------------------------------------ 
@ Retun after interrupt      
@ ------------------------------------------        
        b       continue


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
Data3:          .word  0xffccbbaa
Data4:          .word  0x12345600
Data5:          .word  0x0000ffff
Data6:          .word  0xffff0000
Data7:          .word  0x5678ffff
Data8:          .word  0xffffffff
PCMask:         .word  0x03fffffc

/* Write 17 to this address to generate a Test Passed message */
AdrTestStatus:  .word  ADR_AMBER_TEST_STATUS
AdrData1:       .word  Data1
AdrData2:       .word  Data2
AdrData3:       .word  Data3
AdrData4:       .word  Data4
AdrData5:       .word  Data5
AdrData6:       .word  Data6
AdrData7:       .word  Data7
AdrData8:       .word  Data8
Adrpos1:        .word  pos1

/* ========================================================================= */
/* ========================================================================= */
        

