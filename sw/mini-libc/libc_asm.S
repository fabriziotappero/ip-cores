/*----------------------------------------------------------------
//                                                              //
//  libc_asm.S                                                  //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Assembly routines for the mini-libc library.                //
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


/* _testfail: Used to terminate execution in Verilog simulations */
/* On the board just puts the processor into an infinite loop    */
	.section .text
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

/* _outbyte: Output a single character through UART 0 */
        @ if the uart tx fifo is stuck full
        @ this routine will cycle forever
	.globl _outbyte      
_outbyte:        
        ldr     r1, AdrUARTDR
        ldr     r3, AdrUARTFR
        @ Check the tx_full flag
1:      ldr     r2, [r3]
        and     r2, r2, #0x20
        cmp     r2, #0
        streqb  r0, [r1]
        moveqs  pc, lr          @ return
        bne     1b


/* _inbyte: Input a single character from UART 0 */
        @ r0 is the timeout in mS
	.globl _inbyte      
_inbyte:        
        ldr     r2, AdrUARTDR @ data
        ldr     r3, AdrUARTFR @ flags
        
        @ Multiple delay value by 2560
        @ as the delay loop takes about 12 clock cycles running cached
        @ so that factor gives 1:1mS @33MHz
        mov     r1, r0, lsl #11
        add     r1, r1, r0, lsl #9
        
        @ Check the r2 empty flag
2:      ldr     r0, [r3]
        ands    r0, r0, #0x10
        ldreqb  r0, [r2]
        moveq   pc, lr
        
        @ decrement timeout
        subs    r1, r1, #1
        bne     2b
        
        mov     r0, #-1
        movs    pc, lr


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
        @ only if both strings are zero-aligned use the fast 'aligned' algorithm
        orr     r2, r6, r1
        tst     r2, #3
        bne     strcpy_slow

strcpy_fast:
        @ process strings 12 bytes at a time
        ldmia   r1!, {r2-r5}

        @ check for a zero byte
        @ only need to examine one of the strings because
        @ they are equal up to this point!
        tst     r2, #0xff
        tstne   r2, #0xff00
        tstne   r2, #0xff0000
        tstne   r2, #0xff000000
        strne   r2, [r6], #4
        subeq   r1, r1, #4
                
        tstne   r3, #0xff
        tstne   r3, #0xff00
        tstne   r3, #0xff0000
        tstne   r3, #0xff000000
        strne   r3, [r6], #4
        subeq   r1, r1, #4
        
        tstne   r4, #0xff
        tstne   r4, #0xff00
        tstne   r4, #0xff0000
        tstne   r4, #0xff000000
        strne   r4, [r6], #4
        subeq   r1, r1, #4

        tstne   r5, #0xff
        tstne   r5, #0xff00
        tstne   r5, #0xff0000
        tstne   r5, #0xff000000
        strne   r5, [r6], #4
        subeq   r1, r1, #4
        
        @ loop back to look at next 12 bytes
        bne     strcpy_fast

        @ the source string contains a zero character


strcpy_aligned_slow:
        @ unroll the loop 4 times
        ldr     r3, [r1], #4
        strb    r3, [r6], #1
        ands    r4, r3,   #0xff
        ldmeqia	sp!, {r4-r6, pc}^
        
        lsr     r3, r3, #8
        strb    r3, [r6], #1
        ands    r4, r3,   #0xff
        ldmeqia	sp!, {r4-r6, pc}^
        
        lsr     r3, r3, #8
        strb    r3, [r6], #1
        ands    r4, r3,   #0xff
        ldmeqia	sp!, {r4-r6, pc}^
        
        lsr     r3, r3, #8
        strb    r3, [r6], #1
        ands    r4, r3,   #0xff
        ldmeqia	sp!, {r4-r6, pc}^
        
        b       strcpy_aligned_slow  


strcpy_slow:
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
        
        b       strcpy_slow


/* int strcmp ( const char * str1, const char * str2 );
   A value greater than zero indicates that the first character 
   that does not match has a greater value in str1 than in str2; 
   And a value less than zero indicates the opposite.
*/   
        .globl strcmp
strcmp: 
        stmdb   sp!, {r4-r8, lr}
        
        @ only if both strings are zero-aligned use the fast 'aligned' algorithm
        orr     r2, r0, r1
        tst     r2, #3
        bne     strcmp_slow
        
strcmp_fast:
        @ process strings 12 bytes at a time
        ldmia   r0!, {r2-r4}
        ldmia   r1!, {r5-r7}
        cmp     r2, r5
        bne     1f
        cmpeq   r3, r6
        bne     2f
        cmpeq   r4, r7
        bne     3f

        @ strings are equal - find a zero byte
        @ only need to examine one of the strings because
        @ they are equal up to this point!
        tst     r2, #0xff
        tstne   r2, #0xff00
        tstne   r2, #0xff0000
        tstne   r2, #0xff000000
        
        tstne   r3, #0xff
        tstne   r3, #0xff00
        tstne   r3, #0xff0000
        tstne   r3, #0xff000000
        
        tstne   r4, #0xff
        tstne   r4, #0xff00
        tstne   r4, #0xff0000
        tstne   r4, #0xff000000
        
        @ loop back to look at next 12 bytes
        bne     strcmp_fast

        @ the first string contains a zero character
        @ the strings are the same, so both strings end
        moveq   r0, #0
        ldmeqia	sp!, {r4-r8, pc}^


        @ Roll back the string pointers to before the mismatch
        @ then handle the remaining part byte by byte
1:      sub     r0, r0, #12
        sub     r1, r1, #12

strcmp_slow:         
        ldrb    r2, [r0], #1
        ldrb    r3, [r1], #1
        eors    r4, r2, r3          @ are the bytes equal ?
        bne     bytes_different
        ldrb    r5, [r0], #1
        ldrb    r6, [r1], #1
        cmp     r2, #0              @ are they equal and zero ?
        beq     bytes_zero
        eors    r7, r5, r6          @ are the bytes equal ?
        bne     bytes_different
        ldrb    r2, [r0], #1
        ldrb    r3, [r1], #1
        cmp     r5, #0              @ are they equal and zero ?
        beq     bytes_zero
        eors    r4, r2, r3          @ are the bytes equal ?
        bne     bytes_different
        ldrb    r5, [r0], #1
        ldrb    r6, [r1], #1
        cmp     r2, #0              @ are they equal and zero ?
        beq     bytes_zero
        eors    r7, r5, r6          @ are the bytes equal ?
        bne     bytes_different
        cmp     r5, #0              @ are they equal and zero ?
        beq     bytes_zero

        bne     strcmp_slow



@ Skipping first 4 bytes so just check they
@ don't contain an end of string 0 character
2:      tst    r2, #0xff
        tstne  r2, #0xff00
        tstne  r2, #0xff0000
        tstne  r2, #0xff000000
        beq     bytes_zero
        
        @ start looking at 5th byte
        sub     r0, r0, #8
        sub     r1, r1, #8
        
        ldrb    r2, [r0], #1
        ldrb    r3, [r1], #1
        eors    r4, r2, r3          @ are the bytes equal ?
        bne     bytes_different
        ldrb    r5, [r0], #1
        ldrb    r6, [r1], #1
        cmp     r2, #0              @ are they equal and zero ?
        beq     bytes_zero
        eors    r7, r5, r6          @ are the bytes equal ?
        bne     bytes_different
        ldrb    r2, [r0], #1
        ldrb    r3, [r1], #1
        cmp     r5, #0              @ are they equal and zero ?
        beq     bytes_zero
        eors    r4, r2, r3          @ are the bytes equal ?
        bne     bytes_different
        ldrb    r5, [r0], #1
        ldrb    r6, [r1], #1
        cmp     r2, #0              @ are they equal and zero ?
        beq     bytes_zero
        eors    r7, r5, r6          @ are the bytes equal ?
        bne     bytes_different
        cmp     r5, #0              @ are they equal and zero ?
        beq     bytes_zero

        bne     strcmp_slow
        
@ Skipping first 8 bytes so just check they
@ don't contain an end of string 0 character
3:      tst     r2, #0xff
        tstne   r2, #0xff00
        tstne   r2, #0xff0000
        tstne   r2, #0xff000000
        
        tstne   r3, #0xff
        tstne   r3, #0xff00
        tstne   r3, #0xff0000
        tstne   r3, #0xff000000
        beq     bytes_zero
        
        sub     r0, r0, #4
        sub     r1, r1, #4
        ldrb    r2, [r0], #1
        ldrb    r3, [r1], #1
        eors    r4, r2, r3          @ are the bytes equal ?
        bne     bytes_different
        ldrb    r5, [r0], #1
        ldrb    r6, [r1], #1
        cmp     r2, #0              @ are they equal and zero ?
        beq     bytes_zero
        eors    r7, r5, r6          @ are the bytes equal ?
        bne     bytes_different
        ldrb    r2, [r0], #1
        ldrb    r3, [r1], #1
        cmp     r5, #0              @ are they equal and zero ?
        beq     bytes_zero
        eors    r4, r2, r3          @ are the bytes equal ?
        bne     bytes_different
        ldrb    r5, [r0], #1
        ldrb    r6, [r1], #1
        cmp     r2, #0              @ are they equal and zero ?
        beq     bytes_zero
        eors    r7, r5, r6          @ are the bytes equal ?
        bne     bytes_different
        cmp     r5, #0              @ are they equal and zero ?
        beq     bytes_zero

        bne     strcmp_slow


bytes_zero:
        moveq   r0, #0              @ if equal and zero, return zero
        ldmeqia	sp!, {r4-r8, pc}^


bytes_different:        
        sub     r0, r5, r6
        ldmia	sp!, {r4-r8, pc}^
        

        @ initialize malloc
        .globl init_malloc
init_malloc:
        ldr     r1, AdrMalloc
        str     r1, [r1]
        mov     pc, lr


        /* void *malloc(size_t size); */
        .globl malloc
malloc:
        ldr     r1, AdrMalloc
        ldr     r0, [r1]
        add     r0, r0, #0x10000
        str     r0, [r1]
        mov     pc, lr



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


AdrMalloc:      .word  0x7000000
AdrTestStatus:  .word  ADR_AMBER_TEST_STATUS
AdrUARTDR:      .word  ADR_AMBER_UART0_DR
AdrUARTFR:      .word  ADR_AMBER_UART0_FR
/* ========================================================================= */
/* ========================================================================= */
        

