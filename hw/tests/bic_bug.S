/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Test added to catch specific bug with bic during Linux      //
//  kernel_init. The following instruction stored the result    // 
//  in r3, instead of r2                                        //
//  c00b229c:	e1120310 	tst	r2, r0, lsl r3          //
//  c00b22a0:	11c22310 	bicne	r2, r2, r0, lsl r3      //
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

/* bicne   r2, r2, r0, lsl r3  with r3 = 0 */
        mov     r3, #0
        mov     r0, #0x01
        mov     r2, #0xff
        tst         r2, r0, lsl r3   /* r2 and  ( r0 << r3 ) */
        bicne   r2, r2, r0, lsl r3
        
        cmp     r2, #0xfe
        movne   r10, #10
        bne     testfail
          
        cmp     r3, #0x0
        movne   r10, #20
        bne     testfail        
        
/* bicne   r2, r2, r0, lsl r3  with r3 = 1 */
        mov     r3, #1
        mov     r2, #0xff
        tst         r2, r0, lsl r3   /* r2 and  ( r0 << r3 ) */
        bicne   r2, r2, r0, lsl r3

        cmp     r2, #0xfd
        movne   r10, #30
        bne     testfail
          
        cmp     r3, #0x1
        movne   r10, #40
        bne     testfail        


/* bicne   r2, r2, r0, lsl r3  with r3 = 1, r2 = 0xf0 */
/* So bit 1 of r2 is already a zero, the bic should
   not execute */
        mov     r3, #1
        mov     r2, #0xf0
        tst         r2, r0, lsl r3   /* r2 and  ( r0 << r3 ) */
        bicne   r2, r2, r0, lsl r3
        movne   r2, #0x00            /* add the mov here, just so I can verify
                                        that the NE condition is false and neither
                                        bic or mov execute */
        
        cmp     r2, #0xf0
        movne   r10, #50
        bne     testfail
          
        cmp     r3, #0x1
        movne   r10, #60
        bne     testfail        
   
   
   
@ ------------------------------------------------
@ ------------------------------------------------
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
AdrTestStatus:  .word ADR_AMBER_TEST_STATUS

/* ========================================================================= */
/* ========================================================================= */
        

