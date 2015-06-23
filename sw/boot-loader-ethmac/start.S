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
#include "address_map.h"

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
        b       service_irq

        /* 0x1c FIRQ vector address */
        b       _testfail


        .global _restart
_restart:
        @ jump to address 0 in irq mode
        mov     pc, #0x00000002
        nop
        nop
        nop


startup:
        /* copy program to exec space */
        mov     r0, #0
        ldr     r1, AdrExecBase
1:      ldm     r0!, {r2-r9}
        stm     r1!, {r2-r9}
        cmp     r0, #0x4000
        bne     1b

        /* Fix the interrupt jump pointers */
        ldr     r0, AdrExecBase
        mov     r1, r0, lsr #2
        mov     r2, #0

2:      ldr     r3, [r2]
        orr     r3, r3, r1
        str     r3, [r2], #4
        cmp     r2, #0x1c
        bne     2b

        /* Jump to 2f but offset from ExecBase not current location */
3:      ldr     r0, AdrExecBase
        ldr     r1, AdrJumpPoint
        orr     r0, r0, r1
        mov     pc, r0

_jump_point:

        /* Switch to IRQ Mode */
        mov     r0, #0x00000002
        teqp    pc, r0
        /* Set IRQ Mode stack pointer */
        ldr     sp, AdrIRQStack

        /* Switch to SVC mode and Unset interrupt mask bits */
        mov     r0, #0x00000003
        teqp    pc, r0

        @ Enable the cache
        @ set region 24 to be uncached. Used for packet buffers
        mov     r0, #0xfeffffff
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


service_irq:
        @ As this is an interrupt, need to save all registers to the stack
        @ that will be used here
        stmfd   sp!, {r0-r3, lr}

        @ is it a timer interrupt ?
        ldr     r0, AdrInterruptStatus
        ldr     r3, [r0]
        ands    r2, r3, #0x20
        beq     1f  @ not timer int, jump
        @ Remember that registers r0 to r2 can be changed by this function
        .extern timer_interrupt
        bl timer_interrupt

        @ is it an ethernet interrupt ?
1:      ands    r2, r3, #0x100
        beq     2f  @ not ethmac int, jump
        .extern ethmac_interrupt
        @ Remember that registers r0 to r2 can be changed by this function
        bl ethmac_interrupt


2:      @ Restore all registers from the stack
        ldmfd   sp!, {r0-r3, lr}

        @ Jump straight back to normal execution
        subs    pc, lr, #4



/* _testfail: Used to terminate execution in Verilog simulations */
/* On the board just puts the processor into an infinite loop    */
        .globl _testfail
_testfail:
        ldr     r11, AdrTestStatus
        str     r0, [r11]
        b       _testfail


/* _testpass: Used to terminate execution in Verilog simulations */
/* On the board just puts the processor into an infinite loop    */
        .globl _testpass
_testpass:
        ldr     r11, AdrTestStatus
        mov     r10, #17
        str     r10, [r11]
        b       _testpass




/* _div: Integer division function */
        @ Divide r0 by r1
        @ Answer returned in r1
        .globl _div
        .globl __aeabi_idiv
__aeabi_idiv:
_div:
        stmdb   sp!, {r4, lr}

        @ set r4 to 1 if one of the two inputs is negative
        and     r2, r0, #0x80000000
        and     r3, r1, #0x80000000
        eor     r4, r2, r3

        @ Invert negative numbers
        tst     r0, #0x80000000
        mvnne   r0, r0
        addne   r0, r0, #1

        tst     r1, #0x80000000
        mvnne   r1, r1
        addne   r1, r1, #1

        @ divide r1 by r2, also use registers r0 and r4
        mov     r2, r1
        mov     r1, r0

        cmp      r2, #0
        beq      3f

        @ In order to divide r1 by r2, the first thing we need to do is to shift r2
        @ left by the necessary number of places. The easiest method of doing this
        @ is simply by trial and error - shift until we discover that r2 has become
        @ too big, then stop.
        mov      r0,#0     @ clear r0 to accumulate result
        mov      r3,#1     @ set bit 0 in r3, which will be
                           @ shifted left then right

1:      cmp      r3, #0    @ escape on error
        moveq    r3, #0x10000000
        beq      2f
        cmp      r2,r1
        movls    r2,r2,lsl#1
        movls    r3,r3,lsl#1
        bls      1b
        @ shift r2 left until it is about to be bigger than r1
        @ shift r3 left in parallel in order to flag how far we have to go

        @ r0 will be used to hold the result. The role of r3 is more complicated.
        @ In effect, we are using r3 to mark where the right-hand end of r2 has got to
        @ - if we shift r2 three places left, this will be indicated by a value of %1000
        @ in r3. However, we also add it to r0 every time we manage a successful subtraction,
        @ since it marks the position of the digit currently being calculated in the answer.
        @ In the binary example (50 ÷ 10) above, we shifted the '10' two places left,
        @ so at the time of the first subtraction, r3 would have been %100, at the time
        @ of the second (which failed) it would have been %10, and at the time of the
        @ third %1. Adding it to r0 after each successful subtraction would have
        @ given us, once again, the answer of %101!

        @ Now for the loop that actually does the work:
2:      cmp       r1,r2      @ carry set if r1>r2 (don't ask why)
        subcs     r1,r1,r2   @ subtract r2 from r1 if this would
                             @ give a positive answer
        addcs     r0,r0,r3   @ and add the current bit in r3 to
                             @ the accumulating answer in r0

        @ In subtraction (a cmp instruction simulates a subtraction in
        @ order to set the flags), if r1 - r2 gives a positive answer and no 'borrow'
        @ is required, the carry flag is set. This is required in order to make SBC
        @ (Subtract with Carry) work properly when used to carry out a 64-bit subtraction,
        @ but it is confusing!

        @ In this case, we are turning it to our advantage. The carry flag is set to
        @ indicate that a successful subtraction is possible, i.e. one that doesn't
        @ generate a negative result, and the two following instructions are carried
        @ out only when the condition Carry Set applies. Note that the 'S' on the end
        @ of these instructions is part of the 'CS' condition code and does not mean
        @ that they set the flags!

        movs      r3,r3,lsr #1    @ Shift r3 right into carry flag
        movcc     r2,r2,lsr #1    @ and if bit 0 of r3 was zero, also
                                  @ shift r2 right
        bcc       2b              @ If carry not clear, r3 has shifted
                                  @ back to where it started, and we
                                  @ can end

        @ if one of the inputs is negetive then return a negative result
        tst     r4, #0x80000000
        mvnne   r0, r0
        addne   r0, r0, #1
3:      ldmia	sp!, {r4, pc}^


/* strcpy: String copy function
    char * strcpy ( char * destination, const char * source );
    destination is returned
*/
        @ r0 points to destination
        @ r1 points to source string which terminates with a 0
        .globl strcpy
strcpy:
        stmdb   sp!, {r4-r6, lr}
        @ Use r6 to process the destination pointer.
        @ At the end of the function, r0 is returned, so need to preserve it
        mov     r6, r0

strcpy_main:
        @ unroll the loop 4 times
        ldrb    r3, [r1], #1
        strb    r3, [r6], #1
        cmp     r3, #0
        ldmeqia	sp!, {r4-r6, pc}^

        ldrb    r3, [r1], #1
        strb    r3, [r6], #1
        cmp     r3, #0
        ldmeqia	sp!, {r4-r6, pc}^

        ldrb    r3, [r1], #1
        strb    r3, [r6], #1
        cmp     r3, #0
        ldmeqia	sp!, {r4-r6, pc}^

        ldrb    r3, [r1], #1
        strb    r3, [r6], #1
        cmp     r3, #0
        ldmeqia	sp!, {r4-r6, pc}^

        b       strcpy_main



/* strncpy: String copy function */
        @ r0 points to destination
        @ r1 points to source string
        @ r2 is the number of bytes to copy
        .globl strncpy
strncpy:
        stmdb	sp!, {r4, lr}
        cmp     r2, #0
        beq     2f
        add     r4, r0, r2    @ set r4 to the address of the last byte copied
1:      ldrb    r3, [r1], #1
        strb    r3, [r0], #1
        cmp     r0,  r4
        bne     1b
2:      ldmia	sp!, {r4, pc}^



/* strncpy: String compare function */
        @ r0 points to first string
        @ r1 points to second string
        @ r2 is the number of bytes to compare
        @ return the difference if the strings don't match
        .globl strncmp
strncmp:
        stmdb	sp!, {r4, r5, r6, lr}

        @ check for 0 length
        cmp     r2, #0
        moveq   r0, #1
        beq     2f

        mov     r3, #0

1:      add     r3, r3,   #1
        ldrb    r4, [r0], #1
        ldrb    r5, [r1], #1

        subs    r6, r4, r5
        movne   r0, r6
        bne     2f

        cmp     r3, r2
        moveq   r0, #0
        beq     2f

        b       1b
2:      ldmia	sp!, {r4, r5, r6, pc}^



        .globl init_malloc
init_malloc:
        ldr     r0, AdrMallocBase
        ldr     r1, AdrMallocPointer
        str     r0, [r1]

        @ initialize the counter to 0
        ldr     r1, AdrMallocCount
        mov     r2, #0
        str     r2, [r1]

        mov     pc, lr


        /* void *malloc(size_t size); */
        .globl malloc
malloc:
        /* r0 contains the size of the object in bytes */
        ldr     r1, AdrMallocPointer
        ldr     r2, [r1]    /* r2 now containts the starting address of the next memory block to use */
        add     r3, r0, r2  /* r3 contains the address after the end of the new object */

        /* Round r3 up to the nearest 0x100 to keep memory aligned */
        tst     r3, #0xff
        beq     1f
        bic     r3, r3, #0xff
        add     r3, r3, #0x100

1:      str     r3, [r1]    /* Update the malloc pointer */
        mov     r0, r2      /* Return the address from before the pointer was updated */

        @ Update the block count
        ldr     r1, AdrMallocCount
        ldr     r2, [r1]
        add     r2, r2, #1
        str     r2, [r1]

        mov     pc, lr


        .global serial_putchar_
serial_putchar_:
        ldr     r1, AdrUARTDR
        ldr     r3, AdrUARTFR
        @ Check the tx_full flag
1:      ldr     r2, [r3]
        and     r2, r2, #0x20
        cmp     r2, #0
        streqb  r0, [r1]
        moveqs  pc, lr          @ return
        bne     1b


/* stack at top of ddr3 memory space */
AdrJumpPoint:               .word _jump_point
AdrExecBase:                .word ADR_EXEC_BASE
AdrStack:                   .word ADR_STACK
AdrIRQStack:                .word ADR_IRQ_STACK
AdrMallocPointer:           .word ADR_MALLOC_POINTER
AdrMallocCount:             .word ADR_MALLOC_COUNT
AdrMallocBase:              .word ADR_MALLOC_BASE

AdrMemCtrl:                 .word ADR_AMBER_TEST_MEM_CTRL
AdrTestStatus:              .word ADR_AMBER_TEST_STATUS
AdrInterruptStatus:         .word ADR_AMBER_IC_IRQ0_STATUS

AdrUARTDR:                  .word ADR_AMBER_UART0_DR
AdrUARTFR:                  .word ADR_AMBER_UART0_FR

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
