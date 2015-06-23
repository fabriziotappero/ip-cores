/* Support file for c based tests */
#include "or1200.h"
#include <board.h>

    .section .stack
    .space STACK_SIZE
_stack:

    .section .reset, "ax"

    .org    0x100
_reset_vector:
    l.nop
    l.nop
    l.addi  r2,r0,0x0
    l.addi  r3,r0,0x0
    l.addi  r4,r0,0x0
    l.addi  r5,r0,0x0
    l.addi  r6,r0,0x0
    l.addi  r7,r0,0x0
    l.addi  r8,r0,0x0
    l.addi  r9,r0,0x0
    l.addi  r10,r0,0x0
    l.addi  r11,r0,0x0
    l.addi  r12,r0,0x0
    l.addi  r13,r0,0x0
    l.addi  r14,r0,0x0
    l.addi  r15,r0,0x0
    l.addi  r16,r0,0x0
    l.addi  r17,r0,0x0
    l.addi  r18,r0,0x0
    l.addi  r19,r0,0x0
    l.addi  r20,r0,0x0
    l.addi  r21,r0,0x0
    l.addi  r22,r0,0x0
    l.addi  r23,r0,0x0
    l.addi  r24,r0,0x0
    l.addi  r25,r0,0x0
    l.addi  r26,r0,0x0
    l.addi  r27,r0,0x0
    l.addi  r28,r0,0x0
    l.addi  r29,r0,0x0
    l.addi  r30,r0,0x0
    l.addi  r31,r0,0x0

/*        
    l.movhi r3,hi(MC_BASE_ADDR) 
    l.ori   r3,r3,MC_BA_MASK
    l.addi  r5,r0,0x00
    l.sw    0(r3),r5
*/      
    l.movhi r3,hi(_start)
    l.ori   r3,r3,lo(_start)
    l.jr    r3
    l.nop

    .section .text

_start:

.if IC | DC
    /* Flush IC and/or DC */
    l.addi  r10,r0,0   
    l.addi  r11,r0,0   
    l.addi  r12,r0,0   
.if IC
    l.addi  r11,r0,IC_SIZE
.endif
.if DC
    l.addi    r12,r0,DC_SIZE
.endif
    l.sfleu    r12,r11
    l.bf    loop
    l.nop
    l.add    r11,r0,r12
loop:
.if IC
    l.mtspr r0,r10,SPR_ICBIR
.endif
.if DC
    l.mtspr r0,r10,SPR_DCBIR
.endif
    l.sfne  r10,r11
    l.bf    loop   
    l.addi  r10,r10,16

    /* Enable IC and/or DC */
    l.addi  r10,r0,(SPR_SR_SM)
.if IC
    l.ori    r10,r10,(SPR_SR_ICE)
.endif
.if DC
    l.ori    r10,r10,(SPR_SR_DCE)
.endif
    l.mtspr r0,r10,SPR_SR
    l.nop
    l.nop
    l.nop
    l.nop
    l.nop
.endif

/* Set stack pointer */
    l.movhi r1,hi(_stack)
    l.ori   r1,r1,lo(_stack)

/* Jump to main */
    l.movhi r2,hi(CLABEL(reset))
    l.ori   r2,r2,lo(CLABEL(reset))
    l.jr    r2
    l.nop

