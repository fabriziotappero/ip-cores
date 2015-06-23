/*$$HEADER*/
/******************************************************************************/
/*                                                                            */
/*                    H E A D E R   I N F O R M A T I O N                     */
/*                                                                            */
/******************************************************************************/

// Project Name                   : Development Board Debugger Example 
// File Name                      : BootReset.S
// Prepared By                    : jb
// Project Start                  : 2009-01-01


/*$$COPYRIGHT NOTICE*/
/******************************************************************************/
/*                                                                            */
/*                      C O P Y R I G H T   N O T I C E                       */
/*                                                                            */
/******************************************************************************/

// Copyright (c) ORSoC 2009 All rights reserved.

// The information in this document is the property of ORSoC.
// Except as specifically authorized in writing by ORSoC, the receiver of
// this document shall keep the information contained herein confidential and
// shall protect the same in whole or in part thereof from disclosure and
// dissemination to third parties. Disclosure and disseminations to the receiver's
// employees shall only be made on a strict need to know basis.


/*$$DESCRIPTION*/
/******************************************************************************/
/*                                                                            */
/*                           D E S C R I P T I O N                            */
/*                                                                            */
/******************************************************************************/

// Define the contents of the reset vector (from 0x100), an IC enable routine
// as well as en external IRQ service routine.

/*$$CHANGE HISTORY*/
/******************************************************************************/
/*                                                                            */
/*                         C H A N G E  H I S T O R Y                         */
/*                                                                            */
/******************************************************************************/

// Date		Version	Description
//------------------------------------------------------------------------
// 090101	1.0	First version				jb


/*$$INCLUDE FILES*/
/******************************************************************************/
/*                                                                            */
/*                      I N C L U D E   F I L E S                             */
/*                                                                            */
/******************************************************************************/

#include "board.h"
#include "spr_defs.h"

/*$$PRIVATE MACROS*/
/******************************************************************************/
/*                                                                            */
/*                      P R I V A T E   M A C R O S                           */
/*                                                                            */
/******************************************************************************/

/******************************************************************************/
/*        L O A D   3 2  B I T   C O N S T A N T  I N T O   R E G I S T E R   */
/******************************************************************************/

.macro  load32i reg const
        l.movhi \reg,hi(\const)
        l.ori   \reg,\reg,lo(\const)
.endm

/******************************************************************************/
/*                   S E T U P   E X C E P T I O N   V E C T O R              */
/******************************************************************************/

.macro  exception_vector name org
        .org \org
        .p2align 8
        .global  __exception_\name
__exception_\name:
        
        l.j __exception_\name
        l.nop
.endm

/******************************************************************************/
/*                         B R A N C H   T O   N A M E                        */
/******************************************************************************/

.macro  BSR name
        l.j    \name
        l.nop
ret_\name:  
.endm


/*$$RESET START*/
/******************************************************************************/
/*                                                                            */
/*                          R E S E T   S T A R T                             */
/*                                                                            */
/******************************************************************************/

.section .vectors, "ax"

.org 0x100 - 0x100 		// Sector .vectors start at 0x100


_reset:

// Set stack pointer (r1) to 00003560
// Clear all other registers

	.equ sp,0x00003560	;
	l.movhi r0,0x0000	; #r0 = 0
	l.ori r0,r0,0x0000	; 
	l.movhi r1,hi(sp)	; #r1 = sp
	l.ori r1,r1,lo(sp)	;
	l.or r2,r0,r0		; #clear r2
	l.or r3,r0,r0		; #clear r3
	l.or r4,r0,r0		; #clear r4
	l.or r5,r0,r0		; #clear r5
	l.or r6,r0,r0		; #clear r6
	l.or r7,r0,r0		; #clear r7
	l.or r8,r0,r0		; #clear r8
	l.or r9,r0,r0		; #clear r9
	l.or r10,r0,r0		; #clear r10
	l.or r11,r0,r0		; #clear r11
	l.or r12,r0,r0		; #clear r12
	l.or r13,r0,r0		; #clear r13
	l.or r14,r0,r0		; #clear r14
	l.or r15,r0,r0		; #clear r15
	l.or r16,r0,r0		; #clear r16
	l.or r17,r0,r0		; #clear r17
	l.or r18,r0,r0		; #clear r18
	l.or r19,r0,r0		; #clear r19
	l.or r20,r0,r0		; #clear r20
	l.or r21,r0,r0		; #clear r21
	l.or r22,r0,r0		; #clear r22
	l.or r23,r0,r0		; #clear r23
	l.or r24,r0,r0		; #clear r24
	l.or r25,r0,r0		; #clear r25
	l.or r26,r0,r0		; #clear r26
	l.or r27,r0,r0		; #clear r27
	l.or r28,r0,r0		; #clear r28
	l.or r29,r0,r0		; #clear r29
	l.or r30,r0,r0		; #clear r30
	l.or r31,r0,r0		; #clear r31
	

#if IC_ENABLE == 1      /* INSTRUCTION CACHE */
        BSR ic_enable
#endif

// Jump to start of program

        load32i r2, (_Start)
        l.jr    r2
        l.nop

        exception_vector        bus_error               0x200 - 0x100 // Sector .vectors start at 0x100 
        exception_vector        data_page_fault         0x300 - 0x100 // Sector .vectors start at 0x100
        exception_vector        instruction_page_fault  0x400 - 0x100 // Sector .vectors start at 0x100
        exception_vector        tick_timer              0x500 - 0x100 // Sector .vectors start at 0x100
        exception_vector        unaligned_access        0x600 - 0x100 // Sector .vectors start at 0x100
        exception_vector        illegal_instruction     0x700 - 0x100 // Sector .vectors start at 0x100


// Defines what will happen when an external interrupt occurs

.org 0x800 - 0x100

        .global  __external_IRQ

__external_IRQ:        
        l.addi r1,r1,-30*4			//move SP 30*4 adresses lower

        l.sw 0x1c(r1),r9
        
        l.jal (save_state)
        l.nop
		                
        // we mess with r3, r4 and r9
        //
        l.mfspr r3,r0,SPR_ESR_BASE      // get SR before interrupt
        l.andi  r4,r3,SPR_SR_IEE        // check if it had SPR_SR_IEE bit enabled
        l.sfeqi r4,0
        l.bnf   JUMP                      // external irq enabled, all ok.
        l.nop

JUMP:	  l.jal (_external_exeption)
        l.nop

        l.jal (restore_state)
        l.nop

        l.lwz r9 ,0x1c(r1)
        l.addi r1,r1,30*4			//move SP 30*4 adresses lower
                
        //Return from exception
        l.rfe


// Save current state (all general purpose registers)

save_state:
    l.sw 0x0(r1),r2
    l.sw 0x4(r1),r3
    l.sw 0x8(r1),r4
    l.sw 0xc(r1),r5
    l.sw 0x10(r1),r6
    l.sw 0x14(r1),r7
    l.sw 0x18(r1),r8
    l.sw 0x20(r1),r10
    l.sw 0x24(r1),r11
    l.sw 0x28(r1),r12
    l.sw 0x2c(r1),r13
    l.sw 0x30(r1),r14
    l.sw 0x34(r1),r15
    l.sw 0x38(r1),r16
    l.sw 0x3c(r1),r17
    l.sw 0x40(r1),r18
    l.sw 0x44(r1),r19
    l.sw 0x48(r1),r20
    l.sw 0x4c(r1),r21
    l.sw 0x50(r1),r22
    l.sw 0x54(r1),r23
    l.sw 0x58(r1),r24
    l.sw 0x5c(r1),r25
    l.sw 0x60(r1),r26
    l.sw 0x64(r1),r27
    l.sw 0x68(r1),r28
    l.sw 0x6c(r1),r29
    l.sw 0x70(r1),r30
    l.jr r9
    l.nop

// Restore current state

restore_state:
    // disable interrupts (if needed)
    l.lwz r2,0x0(r1)
    l.lwz r3  ,0x4(r1)
    l.lwz r4  ,0x8(r1)
    l.lwz r5  ,0xc(r1)
    l.lwz r6 ,0x10(r1)
    l.lwz r7 ,0x14(r1)
    l.lwz r8 ,0x18(r1)
    l.lwz r10,0x20(r1)
    l.lwz r11,0x24(r1)
    l.lwz r12,0x28(r1)
    l.lwz r13,0x2c(r1)
    l.lwz r14,0x30(r1)
    l.lwz r15,0x34(r1)
    l.lwz r16,0x38(r1)
    l.lwz r17,0x3c(r1)
    l.lwz r18,0x40(r1)
    l.lwz r19,0x44(r1)
    l.lwz r20,0x48(r1)
    l.lwz r21,0x4c(r1)
    l.lwz r22,0x50(r1)
    l.lwz r23,0x54(r1)
    l.lwz r24,0x58(r1)
    l.lwz r25,0x5c(r1)
    l.lwz r26,0x60(r1)
    l.lwz r27,0x64(r1)
    l.lwz r28,0x68(r1)
    l.lwz r29,0x6c(r1)
    l.lwz r30,0x70(r1)
    l.jr r9
    l.nop



/***************************
 * Instruction cache enable 
 */
#if IC_ENABLE == 1      
ic_enable:

        /* Disable IC */
        l.mfspr r6,r0,SPR_SR
        l.addi  r5,r0,-1
        l.xori  r5,r5,SPR_SR_ICE
        l.and   r5,r6,r5
        l.mtspr r0,r5,SPR_SR

        /* Invalidate IC */
        l.addi  r6,r0,0
        l.addi  r5,r0,IC_SIZE
1:
        l.mtspr r0,r6,SPR_ICBIR
        l.sfne  r6,r5
        l.bf    1b
        l.addi  r6,r6,IC_LINE

        /* Enable IC */
        l.mfspr r6,r0,SPR_SR
        l.ori   r6,r6,SPR_SR_ICE
        l.mtspr r0,r6,SPR_SR
        l.nop
        l.nop
        l.nop
        l.nop
        l.nop
        l.nop
        l.nop
        l.nop
        l.nop
        l.nop
        l.j  ret_ic_enable
        l.nop
#endif