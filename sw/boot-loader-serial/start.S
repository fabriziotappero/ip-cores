/*----------------------------------------------------------------
//                                                              //
//  start.S                                                     //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Assembly routines for boot-loader.                          //
//  As boot-loader is a stand-alone application, it needs a     //
//  simple start function written in assembly to call the       //
//  C code main() function.                                     //
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
----------------------------------------------------------------*/

#include "amber_registers.h"


/* Defined in vmlinux/include/asm-arm/setup.h */
#define ATAG_CORE       0x54410001
#define ATAG_MEM	0x54410002
#define ATAG_INITRD	0x54410005
#define ATAG_RAMDISK    0x54410004
#define ATAG_NONE	0x00000000

#define ATAG_CORE_SIZE    ((2*4 + 3*4) >> 2)
#define ATAG_MEM_SIZE     ((2*4 + 2*4) >> 2)
#define ATAG_INITRD_SIZE  ((2*4 + 2*4) >> 2)
#define ATAG_RAMDISK_SIZE ((2*4 + 3*4) >> 2)


/* from vmlinux/arch/arm/kernel/compat.c */
#define FLAG_READONLY	1

/* from the list in wmlinux/arch/arm/tools/mach-types */
#define MACH_TYPE_A5K   11



	.section .text
	.globl	start 
start:               
        /* 0x00 Reset Interrupt vector address */
        b       startup

        /* 0x04 Undefined Instruction Interrupt vector address */
        b       _testfail
        
        /* 0x08 SWI Interrupt vector address */
        b       _testfail
        
        /* 0x0c Prefetch abort Interrupt vector address */
        b       _testfail
        
        /* 0x10 Data abort Interrupt vector address */
        b       _testfail
        b       _testfail
        
        /* 0x18 IRQ vector address */
        b       _testfail
        
        /* 0x1c FIRQ vector address */
        b       _testfail
        
startup:
        /* Unset interrupt mask bits, stay in svc mode */
        mov     r0, #0x00000003
        teqp    pc, r0 
 
        @ Enable the cache
        mov     r0, #0xffffffff
	mcr	15, 0, r0, cr3, cr0, 0   @ cacheable area
        mov     r0, #1
	mcr	15, 0, r0, cr2, cr0, 0   @ cache enable
        
        @ init SP
        ldr     sp, AdrStack

        @ Set 32MB memory mode
        ldr     r0, AdrMemCtrl
        mov     r1, #1
        str     r1, [r0]
        
        .extern main
        bl      main
                
        @ jump to program at r0
	.globl _jump_to_program
_jump_to_program:

        
        @ ----------------------------------------------
        @ Copy ATAG structure to AdrBootParams
        @ ----------------------------------------------
        ldr     r1, AdrBootParams
        ldr     r2, AdrATAGBase
        ldr     r3, AdeEndATAG
        
1:      cmp     r2, r3
        beq     2f
        ldr     r4, [r2], #4
        str     r4, [r1], #4
        b       1b
        
        @ Set memc page tables
2:      ldr     r2, AdrPageTabes        
        mov     r3, #0
        mov     r4, #40
3:      str     r3,[r2],#4
        subs    r4, r4, #1
        bne     3b
           
        @ ----------------------------------------------
        @ jump to start of program in svc mode with interrupts disabled
        @ ----------------------------------------------
        mov     r4, r0
        orr     r4, #0x0c000003
        mov     r0, #0  
        mov     pc, r4


        @ ----------------------------------------------
        @ Print CPU Core status
        @ ----------------------------------------------
	.globl	 _core_status
_core_status:
        stmdb   sp!,{lr}
        stmdb   sp!,{r0-r12}
        mov     r4, #0
        mov     r5, sp
        mov     r6, lr
        
1:      ldr     r0, =Status_Message
        mov     r1, r4
        ldr     r2, [r5], #4
        bl      printf
        
        cmp     r4, #13
        addne   r4, r4, #1
        bne     1b
        
        @ Stack Pointer
        ldr     r0, =SPStatus_Message
        mov     r1, sp
        bl      printf
        
        @ Program Counter - Use Link Register value because
        @ want the PC value of whatever called this function
        ldr     r0, =PCStatus_Message
        sub     r1, r6, #4
        bl      printf
                
        ldmia  sp!,{r0-r12}
        ldmia  sp!,{pc}^
        

/* stack at top of ddr3 memory space */
AdrStack:                   .word 0x02000000
AdrMemCtrl:                 .word ADR_AMBER_TEST_MEM_CTRL

/* core status messages */
Status_Message:             .ascii "r%2d  %08x\n\00"
SPStatus_Message:           .ascii "sp   %08x\n\00"
PCStatus_Message:           .ascii "pc   %08x\n\00"

                            .align 2
AdrATAGBase:                .word ATAGBase
AdeEndATAG:                 .word EndATAG

ATAGBase:                   .word ATAG_CORE_SIZE
                            .word ATAG_CORE
                            .word FLAG_READONLY     @ flags
                            .word 4096              @ page size
                            .word 0x0               @ rootdev
                
                            .word ATAG_MEM_SIZE
                            .word ATAG_MEM
                            .word 32*1024*1024      @ size - 32MB
                            .word 0x0               @ start

                            .word ATAG_RAMDISK_SIZE
                            .word ATAG_RAMDISK
                            .word 1                 @ flags: bit 0 = load, bit 1 = prompt
                            .word 0x000000d0        @ size in 1k blocks
                            .word 0x00800000        @ physical address of start of ramdisk

                            .word ATAG_INITRD_SIZE
                            .word ATAG_INITRD
                            .word 0x02800000        @ virtual address of start of initrd image
                            .word 0x00032000        @ size = 200k
                
                            .word ATAG_NONE
                            .word 0x0
EndATAG:                    .word 0x0

AdrBootParams:              .word 0x7c000
AdrPageTabes:               .word 0x3f01000
