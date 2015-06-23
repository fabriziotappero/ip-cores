/* Support file for c based tests */

#include "spr_defs.h"

/* ********************************************************************** */
/* Registers                                                              */
/* ********************************************************************** */
/*
Register	Preserved across function calls		Usage
R31		No					Temporary register
R30		Yes					Callee-saved register
R29		No					Temporary register
R28		Yes					Callee-saved register
R27		No					Temporary register
R26		Yes					Callee-saved register
R25		No					Temporary register
R24		Yes					Callee-saved register
R23		No					Temporary register
R22		Yes					Callee-saved register
R21		No					Temporary register
R20		Yes					Callee-saved register
R19		No					Temporary register
R18		Yes					Callee-saved register
R17		No					Temporary register
R16		Yes					Callee-saved register
R15		No					Temporary register
R14		Yes					Callee-saved register
R13		No					Temporary register
R12		No					Temporary register (RVH - Return value high 32 bits of 64-bit value on 32-bit system)
R11		No					RV Return value
R10		Yes					Callee-saved register
R9		Yes					LR Link address register
R8		No					Function parameter number 5
R7		No					Function parameter number 4
R6		No					Function parameter number 3
R5		No					Function parameter number 2 
R4		No					Function parameter number 1
R3		No					Function parameter number 0
R2		Yes					FP Frame pointer
R1		Yes					SP Stack pointer
R0		-					Fixed to zero
*/

/* ********************************************************************** */
/* section .stack                                                         */
/* ********************************************************************** */
        .section .stack
        //.space 0x00400000
        //.space 0x1000 /* 4kbyte(1024longword-stack) */
        .space 0x800 /* 2kbyte(512longword-stack) */
_stack:

/* ********************************************************************** */
/* section .reset                                                         */
/* ********************************************************************** */
        .section .reset, "ax"
        .org    0x100
_reset_vector:
// loop test
//      l.movhi r2,0x9000
//      l.ori   r2,r2,0x0004
//      l.movhi r3,0x0000
//      l.ori   r3,r3,0x0003
//	l.sb 0x0(r2),r3
//	l.sb 0x0(r2),r3
//      l.movhi r3,0x0000
//      l.ori   r3,r3,0x0001
//	l.sb 0x0(r2),r3
//	l.sb 0x0(r2),r3
//	l.movhi r2,hi(_reset_vector)
//	l.ori   r2,r2,lo(_reset_vector)
//	l.jr    r2
//	l.nop

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
        l.movhi r3,hi(_start)
        l.ori   r3,r3,lo(_start)
        l.jr    r3				/* jump to _start */
        l.nop

/* ********************************************************************** */
/* section .text                                                          */
/* ********************************************************************** */
        .section .text
_start:

// /* Wait for SDRAM */
// 	l.movhi r3,0x0020
// 	l.ori   r3,r3,0x0000
// //// /*	l.addi  r3,r0,0x1000 */
// 1:	l.sfeqi r3,0
// 	l.bnf   1b
// 	l.addi  r3,r3,-1

.if IC | DC
        /* Flush IC and/or DC */
        l.addi  r10,r0,0   
        l.addi  r11,r0,0   
        l.addi  r12,r0,0   
.if IC
        l.addi  r11,r0,IC_SIZE
.endif
.if DC
	l.addi	r12,r0,DC_SIZE
.endif
	l.sfleu	r12,r11
	l.bf	loop
	l.nop
	l.add	r11,r0,r12
loop:
.if IC
	l.mtspr r0,r10,SPR_ICBIR		/* Invalidate */
.endif
.if DC
	//l.mtspr r0,r10,SPR_DCBFR		/* Flush */
	l.mtspr r0,r10,SPR_DCBIR		/* Invalidate */
	l.mtspr r0,r10,SPR_DCBWR		/* WriteBack */
.endif
	l.sfne  r10,r11
	l.bf    loop
	l.addi  r10,r10,16			/* enable line(blanch excute) */

.endif // IC|DC


        l.addi  r10,r0,(SPR_SR_SM)		/* add Supervisor Mode */
.if IC
        l.ori	r10,r10,(SPR_SR_ICE)		/* Enable IC */
.endif
.if DC
        l.ori	r10,r10,(SPR_SR_DCE)		/* Enable DC */
.endif
        l.ori	r10,r10,(SPR_SR_IEE)		/* add Interupt Except Enable */
        l.ori	r10,r10,(SPR_SR_TEE)		/* add Tick timer Except Enable */
        l.mtspr r0,r10,SPR_SR			/* add Interupt Except Enable */
        l.nop					/* add Interupt Except Enable pipline idle */
        l.nop					/* add Interupt Except Enable pipline idle */
        l.nop					/* add Interupt Except Enable pipline idle */
        l.nop					/* add Interupt Except Enable pipline idle */
        l.nop					/* add Interupt Except Enable pipline idle */
        l.nop					/* add Interupt Except Enable pipline idle */
        l.nop					/* add Interupt Except Enable pipline idle */
        l.nop					/* add Interupt Except Enable pipline idle */
        l.nop					/* add Interupt Except Enable pipline idle */
        l.nop					/* add Interupt Except Enable pipline idle */
        l.nop					/* add Interupt Except Enable pipline idle */
        l.nop					/* add Interupt Except Enable pipline idle */
        l.nop					/* add Interupt Except Enable pipline idle */
        l.nop					/* add Interupt Except Enable pipline idle */

/* Wait for SDRAM */
//	l.movhi r3,0x0000
//	l.ori   r3,r3,0xffff
//	l.addi  r3,r0,0x1000			/* 0x1000 */
//1:	l.sfeqi r3,0
//	l.bnf   1b
//	l.addi  r3,r3,-1

/* cp flash_data to (ram,sdram) */
	/* cp _src_beg to r3 (vectors->icm->data) */
        l.movhi r3,hi(_src_beg)
        l.ori   r3,r3,lo(_src_beg)

/* Copy from flash to sram (cp .vectors section) */
        l.movhi r4,hi(_vec_start)
        l.ori   r4,r4,lo(_vec_start)
        l.movhi r5,hi(_vec_end)
        l.ori   r5,r5,lo(_vec_end)
        l.sub   r5,r5,r4
        l.sfeqi r5,0
        l.bf    2f
        l.nop
1:      l.lwz   r6,0(r3)
        l.sw    0(r4),r6
        l.addi  r3,r3,4
        l.addi  r4,r4,4
        l.addi  r5,r5,-4
        l.sfgtsi r5,0
        l.bf    1b
        l.nop
2:

/* Copy from flash to sram (cp .icm section) ????????? */
        l.movhi r4,hi(_icm_start)
        l.ori   r4,r4,lo(_icm_start)
        l.movhi r5,hi(_icm_end)
        l.ori   r5,r5,lo(_icm_end)
        l.sub   r5,r5,r4
        l.sfeqi r5,0
        l.bf    20f
        l.nop
10:     l.lwz   r6,0(r3)
        l.sw    0(r4),r6
        l.addi  r3,r3,4
        l.addi  r4,r4,4
        l.addi  r5,r5,-4
        l.sfgtsi r5,0
        l.bf    10b
        l.nop
20:

/* Copy from flash to sram (cp .data section) ????????? */
        l.movhi r4,hi(_dst_beg)
        l.ori   r4,r4,lo(_dst_beg)
        l.movhi r5,hi(_dst_end)
        l.ori   r5,r5,lo(_dst_end)
        l.sub   r5,r5,r4
        l.sfeqi r5,0
        l.bf    20f
        l.nop
10:     l.lwz   r6,0(r3)
        l.sw    0(r4),r6
        l.addi  r3,r3,4
        l.addi  r4,r4,4
        l.addi  r5,r5,-4
        l.sfgtsi r5,0
        l.bf    10b
        l.nop
20:

/* Copy from flash to sram (cp .extdata section) ????????? */
        l.movhi r4,hi(_extdst_beg)
        l.ori   r4,r4,lo(_extdst_beg)
        l.movhi r5,hi(_extdst_end)
        l.ori   r5,r5,lo(_extdst_end)
        l.sub   r5,r5,r4
        l.sfeqi r5,0
        l.bf    20f
        l.nop
10:     l.lwz   r6,0(r3)
        l.sw    0(r4),r6
        l.addi  r3,r3,4
        l.addi  r4,r4,4
        l.addi  r5,r5,-4
        l.sfgtsi r5,0
        l.bf    10b
        l.nop
20:

/* Cpoy from flash to sram (cp .data section) r3 is source-pointer */
//        l.movhi r4,hi(_dst_beg)
//        l.ori   r4,r4,lo(_dst_beg)
//        l.movhi r5,hi(_dst_end)
//        l.ori   r5,r5,lo(_dst_end)
//1:      l.sfgeu r4,r5
//        l.bf    1f
//        l.nop
//        l.lwz   r8,0(r3)
//        l.sw    0(r4),r8
//        l.addi  r3,r3,4
//        l.bnf   1b
//        l.addi  r4,r4,4
//1:
//        l.addi  r3,r0,0
//        l.addi  r4,r0,0
//3:

/* Set stack pointer */
        l.movhi r1,hi(_stack)				/* r1 stack pointer */
        l.ori   r1,r1,lo(_stack)			/* r1 stack pointer */

///* Set timer TTMR */
//	l.addi	r4,r0,SPR_TTMR
//	l.movhi	r5,hi(SPR_TTMR_RT | SPR_TTMR_IE)
//	l.addi	r5,r5,1000				/* every 1000 cycle interrupt exception */
//	l.mtspr	r4,r5,0

/* Jump to main */
	l.movhi r2,hi(_reset)
	l.ori   r2,r2,lo(_reset)
	l.jr    r2					/* jump to _reset(support.c) */
	l.nop						/* must not return,so hold _exit(support.c) */

/* ********************************************************************** */
/* section .icm                                                           */
/* ********************************************************************** */
	.section .icm,"ax"

start_except:
        l.sw    0x00(r1),r2
        l.sw    0x04(r1),r3
        l.sw    0x08(r1),r4
        l.sw    0x0c(r1),r5
        l.sw    0x10(r1),r6
        l.sw    0x14(r1),r7
        l.sw    0x18(r1),r8
 	// r9 is used(return address) 
        l.sw    0x20(r1),r10
        l.sw    0x24(r1),r11
        l.sw    0x28(r1),r12
        l.sw    0x2c(r1),r13
        l.sw    0x30(r1),r14
        l.sw    0x34(r1),r15
        l.sw    0x38(r1),r16
        l.sw    0x3c(r1),r17
        l.sw    0x40(r1),r18
        l.sw    0x44(r1),r19
        l.sw    0x48(r1),r20
        l.sw    0x4c(r1),r21
        l.sw    0x50(r1),r22
        l.sw    0x54(r1),r23
        l.sw    0x58(r1),r24
        l.sw    0x5c(r1),r25
        l.sw    0x60(r1),r26
        l.sw    0x64(r1),r27
        l.sw    0x68(r1),r28
        l.sw    0x6c(r1),r29
        l.sw    0x70(r1),r30
        l.sw    0x74(r1),r31
        l.jr    r9
	//
        l.nop

end_except:
        l.lwz   r2,0x00(r1)
        l.lwz   r3,0x04(r1)
        l.lwz   r4,0x08(r1)
        l.lwz   r5,0x0c(r1)
        l.lwz   r6,0x10(r1)
        l.lwz   r7,0x14(r1)
        l.lwz   r8,0x18(r1)
        l.lwz   r9,0x1c(r1)
        l.lwz   r10,0x20(r1)
        l.lwz   r11,0x24(r1)
        l.lwz   r12,0x28(r1)
        l.lwz   r13,0x2c(r1)
        l.lwz   r14,0x30(r1)
        l.lwz   r15,0x34(r1)
        l.lwz   r16,0x38(r1)
        l.lwz   r17,0x3c(r1)
        l.lwz   r18,0x40(r1)
        l.lwz   r19,0x44(r1)
        l.lwz   r20,0x48(r1)
        l.lwz   r21,0x4c(r1)
        l.lwz   r22,0x50(r1)
        l.lwz   r23,0x54(r1)
        l.lwz   r24,0x58(r1)
        l.lwz   r25,0x5c(r1)
        l.lwz   r26,0x60(r1)
        l.lwz   r27,0x64(r1)
        l.lwz   r28,0x68(r1)
        l.lwz   r29,0x6c(r1)
        l.lwz   r30,0x70(r1)
        l.lwz   r31,0x74(r1)
        l.addi  r1,r1,120
	//l.mtspr r0,r9,SPR_EPCR_BASE
        l.rfe
        l.nop 


except_wrapper:
	// push
        l.addi  r1,r1,-120	/* 120 = 4byte * 30reg */
	l.sw    0x00(r1),r2
	l.sw    0x04(r1),r3
	l.sw    0x08(r1),r4
	l.sw    0x0c(r1),r5
	l.sw    0x10(r1),r6
	l.sw    0x14(r1),r7
	l.sw    0x18(r1),r8
	l.sw    0x1c(r1),r9
	l.sw    0x20(r1),r10
	l.sw    0x24(r1),r11
	l.sw    0x28(r1),r12
	l.sw    0x2c(r1),r13
	l.sw    0x30(r1),r14
	l.sw    0x34(r1),r15
	l.sw    0x38(r1),r16
	l.sw    0x3c(r1),r17
	l.sw    0x40(r1),r18
	l.sw    0x44(r1),r19
	l.sw    0x48(r1),r20
	l.sw    0x4c(r1),r21
	l.sw    0x50(r1),r22
	l.sw    0x54(r1),r23
	l.sw    0x58(r1),r24
	l.sw    0x5c(r1),r25
	l.sw    0x60(r1),r26
	l.sw    0x64(r1),r27
	l.sw    0x68(r1),r28
	l.sw    0x6c(r1),r29
	l.sw    0x70(r1),r30
	l.sw    0x74(r1),r31
	// debug function(free all register)
	// ....
	// ....
	// call handler function (pushed r3)->r2
        l.lwz   r2,0x04(r1)
        l.jalr  r2				/* jump interrupt handler _int_main(int.c) and link */
        l.nop
	// pop
        l.lwz   r2,0x00(r1)
        l.lwz   r3,0x04(r1)
        l.lwz   r4,0x08(r1)
        l.lwz   r5,0x0c(r1)
        l.lwz   r6,0x10(r1)
        l.lwz   r7,0x14(r1)
        l.lwz   r8,0x18(r1)
        l.lwz   r9,0x1c(r1)
        l.lwz   r10,0x20(r1)
        l.lwz   r11,0x24(r1)
        l.lwz   r12,0x28(r1)
        l.lwz   r13,0x2c(r1)
        l.lwz   r14,0x30(r1)
        l.lwz   r15,0x34(r1)
        l.lwz   r16,0x38(r1)
        l.lwz   r17,0x3c(r1)
        l.lwz   r18,0x40(r1)
        l.lwz   r19,0x44(r1)
        l.lwz   r20,0x48(r1)
        l.lwz   r21,0x4c(r1)
        l.lwz   r22,0x50(r1)
        l.lwz   r23,0x54(r1)
        l.lwz   r24,0x58(r1)
        l.lwz   r25,0x5c(r1)
        l.lwz   r26,0x60(r1)
        l.lwz   r27,0x64(r1)
        l.lwz   r28,0x68(r1)
        l.lwz   r29,0x6c(r1)
        l.lwz   r30,0x70(r1)
        l.lwz   r31,0x74(r1)
        l.addi  r1,r1,120
	l.jr	r9
        l.nop

/* ********************************************************************** */
/* End section .icm                                                       */
/* ********************************************************************** */
	.section .rodata
	.global _boot_id
	.align 2
.if IC
.if DC
_boot_id: .asciz "QuickMem(8KByte) StoreBuf(4deapth) ICache(4KByte) DCache(4KByte)"
.else
_boot_id: .asciz "QuickMem(8KByte) StoreBuf(4deapth) ICache(4KByte) DCache(NotUse)"
.endif
.else
.if DC
_boot_id: .asciz "QuickMem(8KByte) StoreBuf(4deapth) ICache(NotUse) DCache(4KByte)"
.else
_boot_id: .asciz "QuickMem(8KByte) StoreBuf(4deapth) ICache(NotUse) DCache(NotUse)"
.endif
.endif

/* ********************************************************************** */
/* section .vectors  0x0000-0x0fff(16tables)                              */
/* ********************************************************************** */
	.section .vectors,"ax"

	.org 0x000
_except_0x000: /* ram_vec support 0x000-0x03f */
	l.addi  r1,r1,-120
	l.sw    0x1c(r1),r9
	l.jal   start_except				// jump store_regs and link
	l.nop
	l.movhi r9,hi(end_except)			// r9 <= return address is end_except
	l.ori   r9,r9,lo(end_except)
	//l.movhi r2,hi(_vector_0x000)
	//l.ori   r2,r2,lo(_vector_0x000)
	//l.lwz   r2,0(r2)				// r2 = *(r2)
	l.movhi r2,hi(_dummy0x000_main)
	l.ori   r2,r2,lo(_dummy0x000_main)
	l.jr    r2					// jump interrupt _int_main(int.c)
	l.nop

	.org 0x100
_except_0x100: /* ram_vec support 0x100-0x13f */
	l.addi  r1,r1,-120
	l.sw    0x1c(r1),r9
	l.jal   start_except
	l.nop
	l.movhi r9,hi(end_except)
	l.ori   r9,r9,lo(end_except)
	//l.movhi r2,hi(_vector_0x100)
	//l.ori   r2,r2,lo(_vector_0x100)
	//l.lwz   r2,0(r2)
	l.movhi r2,hi(_dummy0x100_main)
	l.ori   r2,r2,lo(_dummy0x100_main)
	l.jr    r2
	l.nop

	.org 0x200
_except_0x200: /* ram_vec support 0x200-0x23f */
	l.addi  r1,r1,-120
	l.sw    0x1c(r1),r9
	l.jal   start_except
	l.nop
	l.movhi r9,hi(end_except)
	l.ori   r9,r9,lo(end_except)
	//l.movhi r2,hi(_vector_0x200)
	//l.ori   r2,r2,lo(_vector_0x200)
	//l.lwz   r2,0(r2)
	l.movhi r2,hi(_dummy0x200_main)
	l.ori   r2,r2,lo(_dummy0x200_main)
	l.jr    r2
	l.nop

	.org 0x300
_except_0x300: /* ram_vec support 0x300-0x33f */
	l.addi  r1,r1,-120
	l.sw    0x1c(r1),r9
	l.jal   start_except
	l.nop
	l.movhi r9,hi(end_except)
	l.ori   r9,r9,lo(end_except)
	//l.movhi r2,hi(_vector_0x300)
	//l.ori   r2,r2,lo(_vector_0x300)
	//l.lwz   r2,0(r2)
	l.movhi r2,hi(_dummy0x300_main)
	l.ori   r2,r2,lo(_dummy0x300_main)
	l.jr    r2
	l.nop

	.org 0x400
_except_0x400: /* ram_vec support 0x400-0x43f */
	l.addi  r1,r1,-120
	l.sw    0x1c(r1),r9
	l.jal   start_except
	l.nop
	l.movhi r9,hi(end_except)
	l.ori   r9,r9,lo(end_except)
	//l.movhi r2,hi(_vector_0x400)
	//l.ori   r2,r2,lo(_vector_0x400)
	//l.lwz   r2,0(r2)
	l.movhi r2,hi(_dummy0x400_main)
	l.ori   r2,r2,lo(_dummy0x400_main)
	l.jr    r2
	l.nop

	.org 0x500
_except_0x500: // ram_vec support 0x500-0x53f		// tick timer
	l.addi  r1,r1,-120
	l.sw    0x1c(r1),r9
	l.jal   start_except
	l.nop
	l.movhi r9,hi(end_except)
	l.ori   r9,r9,lo(end_except)
	//l.movhi r2,hi(_vector_0x500)
	//l.ori   r2,r2,lo(_vector_0x500)
	//l.lwz   r2,0(r2)
	l.movhi r2,hi(_tick_main)
	l.ori   r2,r2,lo(_tick_main)
	l.jr    r2
	l.nop

// max 16
//	l.addi  r1,r1,-12
//	l.sw    0x0(r1),r2
//	l.sw    0x4(r1),r9
//	l.sw    0x8(r1),r3
//	l.movhi r3,hi(_tick_main)
//	l.ori   r3,r3,lo(_tick_main)
//	l.movhi r2,hi(except_wrapper)
//	l.ori   r2,r2,lo(except_wrapper)
//	l.jalr  r2
//	l.nop
//	l.lwz   r2,0x0(r1)
//	l.lwz   r9,0x4(r1)
//	l.lwz   r3,0x8(r1)
//	l.addi  r1,r1,12
//	l.rfe
//	l.nop

	.org 0x600
_except_0x600: // ram_vec support 0x600-0x63f
	l.addi  r1,r1,-120
	l.sw    0x1c(r1),r9
	l.jal   start_except
	l.nop
	l.movhi r9,hi(end_except)
	l.ori   r9,r9,lo(end_except)
	//l.movhi r2,hi(_vector_0x600)
	//l.ori   r2,r2,lo(_vector_0x600)
	//l.lwz   r2,0(r2)
	l.movhi r2,hi(_dummy0x600_main)
	l.ori   r2,r2,lo(_dummy0x600_main)
	l.jr    r2
	l.nop

	.org 0x700
_except_0x700: // ram_vec support 0x700-0x73f
	l.addi  r1,r1,-120
	l.sw    0x1c(r1),r9
	l.jal   start_except
	l.nop
	l.movhi r9,hi(end_except)
	l.ori   r9,r9,lo(end_except)
	//l.movhi r2,hi(_vector_0x700)
	//l.ori   r2,r2,lo(_vector_0x700)
	//l.lwz   r2,0(r2)
	l.movhi r2,hi(_dummy0x700_main)
	l.ori   r2,r2,lo(_dummy0x700_main)
	l.jr    r2
	l.nop

	.org 0x800
_except_0x800: // ram_vec support 0x800-0x83f	 	// pic interrupt
	l.addi  r1,r1,-120
	l.sw    0x1c(r1),r9
	l.jal   start_except
	l.nop
	l.movhi r9,hi(end_except)
	l.ori   r9,r9,lo(end_except)
	//l.movhi r2,hi(_vector_0x800)
	//l.ori   r2,r2,lo(_vector_0x800)
	//l.lwz   r2,0(r2)
	l.movhi r2,hi(_int_main)
	l.ori   r2,r2,lo(_int_main)
	l.jr    r2
	l.nop

	.org 0x900
_except_0x900: // ram_vec support 0x900-0x93f
	l.addi  r1,r1,-120
	l.sw    0x1c(r1),r9
	l.jal   start_except
	l.nop
	l.movhi r9,hi(end_except)
	l.ori   r9,r9,lo(end_except)
	//l.movhi r2,hi(_vector_0x900)
	//l.ori   r2,r2,lo(_vector_0x900)
	//l.lwz   r2,0(r2)
	l.movhi r2,hi(_dummy0x900_main)
	l.ori   r2,r2,lo(_dummy0x900_main)
	l.jr    r2
	l.nop

	.org 0xa00
_except_0xa00: // ram_vec support 0xa00-0xa3f
	l.addi  r1,r1,-120
	l.sw    0x1c(r1),r9
	l.jal   start_except
	l.nop
	l.movhi r9,hi(end_except)
	l.ori   r9,r9,lo(end_except)
	//l.movhi r2,hi(_vector_0xa00)
	//l.ori   r2,r2,lo(_vector_0xa00)
	//l.lwz   r2,0(r2)
	l.movhi r2,hi(_dummy0xa00_main)
	l.ori   r2,r2,lo(_dummy0xa00_main)
	l.jr    r2
	l.nop

	.org 0xb00
_except_0xb00: // ram_vec support 0xb00-0xb3f
	l.addi  r1,r1,-120
	l.sw    0x1c(r1),r9
	l.jal   start_except
	l.nop
	l.movhi r9,hi(end_except)
	l.ori   r9,r9,lo(end_except)
	//l.movhi r2,hi(_vector_0xb00)
	//l.ori   r2,r2,lo(_vector_0xb00)
	//l.lwz   r2,0(r2)
	l.movhi r2,hi(_dummy0xb00_main)
	l.ori   r2,r2,lo(_dummy0xb00_main)
	l.jr    r2
	l.nop

	.org 0xc00
_except_0xc00: // ram_vec support 0xc00-0xc3f
	l.addi  r1,r1,-120
	l.sw    0x1c(r1),r9
	l.jal   start_except
	l.nop
	l.movhi r9,hi(end_except)
	l.ori   r9,r9,lo(end_except)
	//l.movhi r2,hi(_vector_0xc00)
	//l.ori   r2,r2,lo(_vector_0xc00)
	//l.lwz   r2,0(r2)
	l.movhi r2,hi(_dummy0xc00_main)
	l.ori   r2,r2,lo(_dummy0xc00_main)
	l.jr    r2
	l.nop

	.org 0xd00
_except_0xd00: // ram_vec support 0xd00-0xd3f
	l.addi  r1,r1,-120
	l.sw    0x1c(r1),r9
	l.jal   start_except
	l.nop
	l.movhi r9,hi(end_except)
	l.ori   r9,r9,lo(end_except)
	//l.movhi r2,hi(_vector_0xd00)
	//l.ori   r2,r2,lo(_vector_0xd00)
	//l.lwz   r2,0(r2)
	l.movhi r2,hi(_dummy0xd00_main)
	l.ori   r2,r2,lo(_dummy0xd00_main)
	l.jr    r2
	l.nop

	.org 0xe00
_except_0xe00: // ram_vec support 0xe00-0xe3f
	l.addi  r1,r1,-120
	l.sw    0x1c(r1),r9
	l.jal   start_except
	l.nop
	l.movhi r9,hi(end_except)
	l.ori   r9,r9,lo(end_except)
	//l.movhi r2,hi(_vector_0xe00)
	//l.ori   r2,r2,lo(_vector_0xe00)
	//l.lwz   r2,0(r2)
	l.movhi r2,hi(_dummy0xe00_main)
	l.ori   r2,r2,lo(_dummy0xe00_main)
	l.jr    r2
	l.nop

	.org 0xf00
_except_0xf00: // ram_vec support 0xf00-0xf3f
	l.addi  r1,r1,-120
	l.sw    0x1c(r1),r9
	l.jal   start_except
	l.nop
	l.movhi r9,hi(end_except)
	l.ori   r9,r9,lo(end_except)
	//l.movhi r2,hi(_vector_0xf00)
	//l.ori   r2,r2,lo(_vector_0xf00)
	//l.lwz   r2,0(r2)
	l.movhi r2,hi(_dummy0xf00_main)
	l.ori   r2,r2,lo(_dummy0xf00_main)
	l.jr    r2
	l.nop

