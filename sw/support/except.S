#include "spr_defs.h"

// Linked from 0x200, so subtract 0x200 from each .org
.section .vectors, "ax" 

/*
.org 0x100
 
_reset:
	l.nop
	l.j	_reset_except
	l.nop
*/
.org 0x000
 
_except_200:
	l.nop
    l.addi  r1,r1,-116			//free 29 words of stack (stack is r1)
    l.sw    0x18(r1),r9			//save register r9(return addr) to stack
    l.jal   store_regs			//save registers r3-r31 (except r9) to stack (r9 is changed here)
    l.nop

    l.movhi r9,hi(end_except)		//set return addr to end_except instruction
    l.ori   r9,r9,lo(end_except)	//set return addr to end_except instruction
	l.j	_buserr_except
	l.nop

.org 0x100
 
_except_300:
	l.nop
    l.addi  r1,r1,-116			//free 29 words of stack (stack is r1)
    l.sw    0x18(r1),r9			//save register r9(return addr) to stack
    l.jal   store_regs			//save registers r3-r31 (except r9) to stack (r9 is changed here)
    l.nop

    l.movhi r9,hi(end_except)		//set return addr to end_except instruction
    l.ori   r9,r9,lo(end_except)	//set return addr to end_except instruction
	l.j	_dpf_except
	l.nop

.org 0x200
 
_except_400:
	l.nop
    l.addi  r1,r1,-116			//free 29 words of stack (stack is r1)
    l.sw    0x18(r1),r9			//save register r9(return addr) to stack
    l.jal   store_regs			//save registers r3-r31 (except r9) to stack (r9 is changed here)
    l.nop

    l.movhi r9,hi(end_except)		//set return addr to end_except instruction
    l.ori   r9,r9,lo(end_except)	//set return addr to end_except instruction
	l.j	_ipf_except
	l.nop

.org 0x300
 
_except_500:
	l.nop
    l.addi  r1,r1,-116			//free 29 words of stack (stack is r1)
    l.sw    0x18(r1),r9			//save register r9(return addr) to stack
    l.jal   store_regs			//save registers r3-r31 (except r9) to stack (r9 is changed here)
    l.nop

    l.movhi r9,hi(end_except)		//set return addr to end_except instruction
    l.ori   r9,r9,lo(end_except)	//set return addr to end_except instruction
	l.j	_lpint_except
	l.nop

.org 0x400
 
_except_600:
	l.nop
    l.addi  r1,r1,-116			//free 29 words of stack (stack is r1)
    l.sw    0x18(r1),r9			//save register r9(return addr) to stack
    l.jal   store_regs			//save registers r3-r31 (except r9) to stack (r9 is changed here)
    l.nop

    l.movhi r9,hi(end_except)		//set return addr to end_except instruction
    l.ori   r9,r9,lo(end_except)	//set return addr to end_except instruction
	l.j	_align_except
	l.nop

.org 0x500
 
_except_700:
	l.nop
    l.addi  r1,r1,-116			//free 29 words of stack (stack is r1)
    l.sw    0x18(r1),r9			//save register r9(return addr) to stack
    l.jal   store_regs			//save registers r3-r31 (except r9) to stack (r9 is changed here)
    l.nop

    l.movhi r9,hi(end_except)		//set return addr to end_except instruction
    l.ori   r9,r9,lo(end_except)	//set return addr to end_except instruction
	l.j	_illegal_except
	l.nop

.org 0x600
 
_except_800:
	l.nop
    l.addi  r1,r1,-116			//free 29 words of stack (stack is r1)
    l.sw    0x18(r1),r9			//save register r9(return addr) to stack
    l.jal   store_regs			//save registers r3-r31 (except r9) to stack (r9 is changed here)
    l.nop

    l.movhi r9,hi(end_except)		//set return addr to end_except instruction
    l.ori   r9,r9,lo(end_except)	//set return addr to end_except instruction
    l.j _hpint_except			//jmp to C interrupt handler (returns later to end_except)
    l.nop


.org 0x700
 
_except_900:
	l.nop
    l.addi  r1,r1,-116			//free 29 words of stack (stack is r1)
    l.sw    0x18(r1),r9			//save register r9(return addr) to stack
    l.jal   store_regs			//save registers r3-r31 (except r9) to stack (r9 is changed here)
    l.nop

    l.movhi r9,hi(end_except)		//set return addr to end_except instruction
    l.ori   r9,r9,lo(end_except)	//set return addr to end_except instruction
	l.j	_dtlbmiss_except
	l.nop

.org 0x800
 
_except_a00:
	l.nop
    l.addi  r1,r1,-116			//free 29 words of stack (stack is r1)
    l.sw    0x18(r1),r9			//save register r9(return addr) to stack
    l.jal   store_regs			//save registers r3-r31 (except r9) to stack (r9 is changed here)
    l.nop

    l.movhi r9,hi(end_except)		//set return addr to end_except instruction
    l.ori   r9,r9,lo(end_except)	//set return addr to end_except instruction
	l.j	_itlbmiss_except
	l.nop

.org 0x900
 
_except_b00:
	l.nop
    l.addi  r1,r1,-116			//free 29 words of stack (stack is r1)
    l.sw    0x18(r1),r9			//save register r9(return addr) to stack
    l.jal   store_regs			//save registers r3-r31 (except r9) to stack (r9 is changed here)
    l.nop

    l.movhi r9,hi(end_except)		//set return addr to end_except instruction
    l.ori   r9,r9,lo(end_except)	//set return addr to end_except instruction
	l.j	_range_except
	l.nop

.org 0xa00
 
_except_c00:
	l.nop
    l.addi  r1,r1,-116			//free 29 words of stack (stack is r1)
    l.sw    0x18(r1),r9			//save register r9(return addr) to stack
    l.jal   store_regs			//save registers r3-r31 (except r9) to stack (r9 is changed here)
    l.nop

    l.movhi r9,hi(end_except)		//set return addr to end_except instruction
    l.ori   r9,r9,lo(end_except)	//set return addr to end_except instruction
	l.j	_syscall_except
	l.nop

.org 0xb00
 
_except_d00:
	l.nop
    l.addi  r1,r1,-116			//free 29 words of stack (stack is r1)
    l.sw    0x18(r1),r9			//save register r9(return addr) to stack
    l.jal   store_regs			//save registers r3-r31 (except r9) to stack (r9 is changed here)
    l.nop

    l.movhi r9,hi(end_except)		//set return addr to end_except instruction
    l.ori   r9,r9,lo(end_except)	//set return addr to end_except instruction
	l.j	_res1_except
	l.nop

.org 0xc00
 
_except_e00:
	l.nop
    l.addi  r1,r1,-116			//free 29 words of stack (stack is r1)
    l.sw    0x18(r1),r9			//save register r9(return addr) to stack
    l.jal   store_regs			//save registers r3-r31 (except r9) to stack (r9 is changed here)
    l.nop

    l.movhi r9,hi(end_except)		//set return addr to end_except instruction
    l.ori   r9,r9,lo(end_except)	//set return addr to end_except instruction
	l.j	_trap_except
	l.nop

.org 0xd00
 
_except_f00:
	l.nop
    l.addi  r1,r1,-116			//free 29 words of stack (stack is r1)
    l.sw    0x18(r1),r9			//save register r9(return addr) to stack
    l.jal   store_regs			//save registers r3-r31 (except r9) to stack (r9 is changed here)
    l.nop

    l.movhi r9,hi(end_except)		//set return addr to end_except instruction
    l.ori   r9,r9,lo(end_except)	//set return addr to end_except instruction
	l.j	_res2_except
	l.nop

store_regs:		//save registers r3-r31 (except r9) to stack
        l.sw    0x00(r1),r3
        l.sw    0x04(r1),r4
        l.sw    0x08(r1),r5
        l.sw    0x0c(r1),r6
        l.sw    0x10(r1),r7
        l.sw    0x14(r1),r8
        l.sw    0x1c(r1),r10
        l.sw    0x20(r1),r11
        l.sw    0x24(r1),r12
        l.sw    0x28(r1),r13
        l.sw    0x2c(r1),r14
        l.sw    0x30(r1),r15
        l.sw    0x34(r1),r16
        l.sw    0x38(r1),r17
        l.sw    0x3c(r1),r18
        l.sw    0x40(r1),r19
        l.sw    0x44(r1),r20
        l.sw    0x48(r1),r21
        l.sw    0x4c(r1),r22
        l.sw    0x50(r1),r23
        l.sw    0x54(r1),r24
        l.sw    0x58(r1),r25
        l.sw    0x5c(r1),r26
        l.sw    0x60(r1),r27
        l.sw    0x64(r1),r28
        l.sw    0x68(r1),r29
        l.sw    0x6c(r1),r30
        l.sw    0x70(r1),r31
        l.jr    r9
        l.nop

end_except:		//load back registers from stack r3-r31
        l.lwz   r3,0x00(r1)
        l.lwz   r4,0x04(r1)
        l.lwz   r5,0x08(r1)
        l.lwz   r6,0x0c(r1)
        l.lwz   r7,0x10(r1)
        l.lwz   r8,0x14(r1)
        l.lwz   r9,0x18(r1)
        l.lwz   r10,0x1c(r1)
        l.lwz   r11,0x20(r1)
        l.lwz   r12,0x24(r1)
        l.lwz   r13,0x28(r1)
        l.lwz   r14,0x2c(r1)
        l.lwz   r15,0x30(r1)
        l.lwz   r16,0x34(r1)
        l.lwz   r17,0x38(r1)
        l.lwz   r18,0x3c(r1)
        l.lwz   r19,0x40(r1)
        l.lwz   r20,0x44(r1)
        l.lwz   r21,0x48(r1)
        l.lwz   r22,0x4c(r1)
        l.lwz   r23,0x50(r1)
        l.lwz   r24,0x54(r1)
        l.lwz   r25,0x58(r1)
        l.lwz   r26,0x5c(r1)
        l.lwz   r27,0x60(r1)
        l.lwz   r28,0x64(r1)
        l.lwz   r29,0x68(r1)
        l.lwz   r30,0x6c(r1)
        l.lwz   r31,0x70(r1)
        l.addi  r1,r1,116				//free stack places
        l.rfe							//recover SR register and prior PC (jumps back to program)
        l.nop

