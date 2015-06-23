/*
 * The vectors page. Includes all exception handlers.
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#include INC_ARCH(asm.h)
#include INC_ARCH(asm-macros.S)

.section .data.vectors
__vector_vaddr:

BEGIN_PROC(arm_high_vector)
	b	arm_reset_exception
	b	arm_undef_exception_reentrant
	b	arm_swi_exception
	b	arm_prefetch_abort_exception_reentrant
	b	arm_data_abort_exception_reentrant
	nop
	b	arm_irq_exception_reentrant_with_schedule
	b	arm_fiq_exception
END_PROC(arm_high_vector)

.balign 4

/*
 * vect_reset
 *
 * Upon Entry:
 * - All registers are undefined and insignificant,
 * - FIQ/IRQs are disabled.
 * - PC:	0x00000000
 *
 *
 * PURPOSE:
 * CPU always starts executing from this vector
 * upon a HW reset. It may also be used as a SW reset.
 */
BEGIN_PROC(arm_reset_exception)
END_PROC(arm_reset_exception)


#if defined(CONFIG_SUBARCH_V5)
	.macro disable_irqs rx
		mrs	\rx, cpsr_fc
		orr	\rx, #ARM_IRQ_BIT
		msr	cpsr_fc, \rx
	.endm
	.macro enable_irqs rx
		mrs	\rx, cpsr_fc
		bic	\rx, #ARM_IRQ_BIT
		msr	cpsr_fc, \rx
	.endm
#endif

#if defined (CONFIG_SUBARCH_V7) || defined(CONFIG_SUBARCH_V6)
	.macro disable_irqs rx
		cpsid	ia
	.endm
	.macro enable_irqs rx
		cpsie	ia
	.endm
#endif

#if defined (CONFIG_SUBARCH_V7)
	.macro clear_exclusive
		clrex
	.endm
#else
	.macro clear_exclusive
	.endm
#endif

	/* Only works in SVC MODE. Know what you are doing! */
	.macro get_current rx
		bic	\rx, sp, #0xFF0
		bic	\rx, \rx, #0xF
	.endm
	/* Saves the address of system call argument registers pushed to stack
	 * to the current task's ktcb. */
	.macro	ktcb_ref_saved_regs regs_addr, ktcb, regs_off
		get_current \ktcb
		ldr	\regs_off, =syscall_regs_offset
		ldr	\regs_off, [\regs_off]
		str	\regs_addr, [\ktcb, \regs_off]
	.endm
	/* Depending on the SPSR condition determines whether irqs should be enabled
	 * during abort handling. If abort occured in userspace it orders irqs
	 * should be enabled. Else if irqs come from kernel mode, it orders irqs are
	 * enabled only if they were alreday enabled before the abort. */
	.macro	can_abort_enable_irqs temp1, r_spsr
		and \temp1, \r_spsr, #ARM_MODE_MASK
		cmp \temp1, #ARM_MODE_USR	 @ Usermode indicates irqs can be enabled.
		beq 1f			    @ Z flag set. Which indicates "can enable"
		and \temp1, \r_spsr, #ARM_IRQ_BIT @ Clear irq bit indicates irqs were enabled
		cmp \temp1, #0		    @ before the abort and can be safely enabled.
	1:				    @ Z flag must be set for "can enable" here.
	.endm

	/* Pushes the user sp and lr to stack, updates the stack pointer */
	.macro push_user_sp_lr sp
		@ stack state: (Low) |..|..|->(Original)| (High)
		stmfd	\sp, {sp, lr}^	@ Push USR banked regs to stack.
		nop			@ Need a NOOP after push/popping user registers.
		@ stack state: (Low) |SP_USR|LR_USR|->(Original)| (High)
		sub	\sp, \sp, #8	@ Adjust SP, since stack op on banked regs is no writeback.
		@ stack state: (Low) |->SP_USR|LR_USR|(Original)| (High)
	.endm

	.macro is_psr_usr rx
		and	\rx, \rx, #ARM_MODE_MASK
		cmp	\rx, #ARM_MODE_USR
	.endm

/* These really both read the same unified FSR and FAR registers */
#if defined (CONFIG_SUBARCH_V5)
	.macro	cp15_read_ifsr rx
		mrc	p15, 0, \rx, c5, c0, 0	@ Read FSR (Tells why the fault occured)

	.endm
	.macro cp15_read_ifar rx
		mrc	p15, 0, \rx, c6, c0, 0	@ Read FAR (Contains the faulted data address)
	.endm
	.macro	cp15_read_dfsr rx
		mrc	p15, 0, \rx, c5, c0, 0	@ Read FSR (Tells why the fault occured)

	.endm
	.macro cp15_read_dfar rx
		mrc	p15, 0, \rx, c6, c0, 0	@ Read FAR (Contains the faulted data address)
	.endm
#endif

/* These read the distinguished IFSR, IFAR, DFSR and DFAR registers */
#if defined (CONFIG_SUBARCH_V6) || defined (CONFIG_SUBARCH_V7)
	.macro	cp15_read_ifsr rx
		mrc	p15, 0, \rx, c5, c0, 1	@ Read IFSR (Tells why the fault occured)

	.endm
	.macro cp15_read_ifar rx
		mrc	p15, 0, \rx, c6, c0, 2	@ Read IFAR (Contains the faulted data address)
	.endm
	.macro	cp15_read_dfsr rx
		mrc	p15, 0, \rx, c5, c0, 0	@ Read DFSR (Tells why the fault occured)

	.endm
	.macro cp15_read_dfar rx
		mrc	p15, 0, \rx, c6, c0, 0	@ Read DFAR (Contains the faulted data address)
	.endm
#endif

#define	UNDEF_R0	0
#define UNDEF_SPSR	-4
#define UNDEF_R14	-8

/*
 * vect_undef
 *
 * Upon Entry:
 * - R14:	Address of next instruction after undefined instruction
 * - PC:	0x00000004
 * - IRQs are disabled (CPSR[7] = 1)
 *
 *
 * PURPOSE:
 * A co-processor instruction not supported by the core can be
 * emulated here. Also unrecognised/invalid instructions are handled.
 */
BEGIN_PROC(arm_undef_exception_reentrant)
	clear_exclusive
	str	lr, [sp, #UNDEF_R14]	@ Store undef address
	mrs	lr, spsr		@ Get SPSR
	str	lr, [sp, #UNDEF_SPSR]	@ Store SPSR
	str	r0, [sp, #UNDEF_R0]	@ Store r0
	@ NOTE: Can increase undef nest here.
	mov	r0, sp			@ Keep current sp point in R0
	mrs	lr, cpsr		@ Change to SVC mode.
	bic	lr, #ARM_MODE_MASK
	orr	lr, lr, #ARM_MODE_SVC
	msr	cpsr_fc, r14
	@ FIXME: Ensure 8-byte stack here.
	str	lr, [sp, #-8]!	@ Save lr_svc 2 words down from interrupted SP_SVC
    	@ Transfer Undef state to SVC
	ldr	lr, [r0, #UNDEF_R14]
	str	lr, [sp, #4]
	@ Stack state:  |LR_SVC<-|LR_UNDEF|{original SP_SVC}|
	ldr	lr, [r0, #UNDEF_SPSR]
	ldr	r0, [r0, #UNDEF_R0]
	stmfd	sp!, {r0-r3,r12,lr}
	@ Stack state:  |R0<-|R1|R2|R3|R12|UNDEF_SPSR|LR_SVC|LR_DUNDEF|{original SP_SVC}|
	push_user_sp_lr sp	@ NOTE: These must be pushed to avoid trashing them if preempted
	@ Stack state: |SP_USR<-|LR_USR|R0<-|R1|R2|R3|R12|UNDEF_SPSR|LR_SVC|LR_DUNDEF|{original SP_SVC}|

	@ All undef state saved. Can safely enable irqs here, if need be.
	ldr	r3, [sp, #28]		@ Load UNDEF_SPSR
	can_abort_enable_irqs r0, r3	@ Judge if irqs can be enabled depending on prev state.
	bne	1f			@ Branch here based on previous irq judgement.
	enable_irqs r3
1:
	/* Now check in what mode exception occured, and return that mode's LR in R4
	 * Also poplulate r0,r1,r2 parameters for undefined_instr_handler
	*/
	ldr	r1, [sp, #28]		@ Load UNDEF_SPSR
	is_psr_usr r0			@ Test if UNDEF_SPSR was user mode.
	ldrne	r2, [sp, #32]		@ Abort occured in kernel, load LR_SVC
	ldreq	r2, [sp, #4]		@ Abort occured in user, load LR_USR
	ldr	r0, [sp, #36]		@ Load LR_UNDEF saved previously.
	mov	lr, pc
	ldr	pc, =undefined_instr_handler 	@ Jump to function outside this page.
	disable_irqs r0			@ Disable irqs to avoid corrupting spsr.
					@ (i.e. an interrupt could overwrite spsr with current psr)
	ldmfd	sp, {sp, lr}^		@ Restore user sp and lr which might have been corrupt on preemption
	nop				@ User reg mod requires nop
	add	sp, sp, #8		@ Update SP.
	ldmfd	sp!, {r0-r3,r12,lr}	@ Restore previous context. (note, lr has spsr)
	msr	spsr_cxsf, r14		@ Restore spsr register from lr.
	@ Stack state: |LR_SVC<-|LR_PREV(UNDEF)|{original SP_SVC}|
	ldmfd	sp!, {r14, pc}^		@ Return, restoring cpsr. Note r14 gets r14_svc,
					@ and pc gets lr_undef. Saved at #4 and #8 offsets
					@ down from where svc stack had left.
END_PROC(arm_undef_exception_reentrant)

/*
 * vect_swi
 *
 * Upon Entry:
 * - R14:	Address of next instruction after the SWI
 * - PC:	0x00000008
 * - R0-R12:	Depending on the system call some of them contain
 *		indicators of what the exception means.
 * - IRQs are disabled (CPSR[7] = 1)
 * - SWI instruction's bits [7:0] may contain SWI indicator
 *
 * PURPOSE:
 * Used for trapping into a debugger or OS kernel via system calls.
 * Argument registers from R0 up to R12 and [7:0] of the causing SWI
 * instruction contains hints of what to do with this exception. What
 * R0-R12 contains depends on what userspace has put in them. Note this
 * is the only exception that userspace can generate and thus has control
 * on what it put into r0-rx.
 *
 * RECAP:
 * Normally across a function call, only r0-r3 are used for passing parameters.
 * Why r0-r3 only but not r4, r5...? See APCS (ARM procedure call standard)
 * Short answer: r4-r12 must be preserved across procedures but r0-r3 can be
 * trashed because they're set aside for argument passing. Arguments more than 4
 * go on the stack. Note APCS is a *suggestion*, rather than enforcement. So if
 * a userspace stub library is created that say, preserves and uses r0-r9 for a
 * system call, and the system call handler (this) knows about it, it is a
 * perfectly valid setup. In fact this is what we do here, we don't strictly use
 * r0-r3. Depending on the system call, the set of input registers (and output
 * registers to return results from the system call) may be redefined. These are
 * documented for each system call in the reference manual.
 * Another caveat to note in SWI usage is that we use the address offset of the
 * SWI instruction to see which offset it has in the system call vector, to
 * determine the correct system call, rather than [7:0] bits of the SWI.
 */
BEGIN_PROC(arm_swi_exception)
	clear_exclusive
	sub	lr, lr, #4	@ Get address of swi instruction user executed.
	stmfd	sp, {r0-r12,sp,lr}^ @ Push arguments, LR_USR and SP_USR to stack.
	nop

	@ Future optimisation 1:
	@ For all syscalls we need not push any more than r8 but we push up to
	@ r12 because upon a fork, a child's easiest way to restore user
	@ registers is to pop it from stack during return_from_syscall. In future
	@ fork function could return back to here, save all context into child
	@ from actual registers instead of reading from stack, and then return.

	@ Future optimisation 2:
	@ SP_USR MUST be pushed here, otherwise a kernel preemption could
	@ cause user mode of another process to overwrite SP_USR. The reason we
	@ save it here is because the preemption path does not currently save it
	@ if it is a kernel preemption. User SP can also be used here, as the
	@ user might have pushed data to its stack to be used by system calls.
	@ But we dont plan to pass data to kernel in this way, so saving of
	@ SP_USR can be done in preemption path as an optimisation.

	/*
	 * The LR_usr is important here, because the user application uses a BL
	 * to jump to the system call SWI, so the LR_usr contains the return
	 * address, i.e. the next instruction after the *jumping* instruction to
	 * the system call SWI (not the one after the swi itself, which is in
	 * LR_svc).
	 */

	sub	sp, sp, #60	@ stmfd on user registers can't writeback the SP. We do it manually.
	mrs	r0, spsr_fc	@ psr also need saving in case this context is interrupted.
	stmfd	sp!, {r0}
	enable_irqs r0
	mov	r0, sp		@ Current SP has pointer to all saved context.
	ktcb_ref_saved_regs r0, r1, r2 @ Save syscall context pointer in ktcb
	mov	r1, lr		@ Pass swi instruction address in LR as arg1
	mov 	lr, pc
	ldr 	pc, =syscall

.global return_from_syscall;    @ Newly created threads use this path to return,
return_from_syscall:		@ if they duplicated another thread's address space.
	disable_irqs r1		@ Not disabling irqs at this point causes the SP_USR and spsr
				@ to get corrupt causing havoc.
	ldmfd	sp!, {r1}
	msr	spsr, r1
	add	sp, sp, #4	@ Skip, r0's location, since r0 already has returned result.
				@ Note we're obliged to preserve at least r3-r8 because they're MRs.
	ldmfd	sp!, {r1-r12}	@ Restore r1-r8 pushed to stack earlier. r0 already has return result.
	ldmfd	sp, {sp}^	@ Restore user stack pointer, which might have been corrupt on preemption
	nop
	add	sp, sp, #4	@ Update sp.
	ldmfd	sp!, {lr}	@ Load userspace return address
	movs	pc, lr
END_PROC(arm_swi_exception)

/* Minimal abort state saved on data abort stack right after abort vector enters: */
#define	ABT_R0		0
#define ABT_SPSR	-4
#define ABT_R14		-8

/* Minimal prefetch abort state saved on abort stack upon entry. */
#define	ABT_R0		0
#define ABT_SPSR	-4
#define ABT_R14		-8

/*
 * vect_pabt
 *
 * Upon Entry:
 * - R14_abt:	Address of next instruction after aborted instruction
 * - R14_usr:	Address of return instruction in last function call**
 * - PC:	0x0000000c
 * - IRQs are disabled (CPSR[7] = 1)
 *
 *
 * PURPOSE:
 * Used for handling instructions that caused *memory aborts* during
 * the *prefetching* of the instruction. The instruction is also marked
 * as invalid by the core. It handles the cause for the memory abort.
 *
 * (One reason why a memory abort would occur is when we were entering
 * into a new page region that contained executable code and was not
 * present in memory, or its physical-to-virtual translation was not
 * present in the page tables. See other causes for memory aborts)
 *
 * **In case abort occured in userspace. This is useful if the abort
 * was due to a null/invalid function pointer call. Since R14_abt
 * includes the aborting instruction itself, R14_usr gives the clue to
 * where this call came from.
 */
BEGIN_PROC(arm_prefetch_abort_exception_reentrant)
	clear_exclusive
	sub	lr, lr, #4		@ lr-4 points at aborted instruction
	str	lr, [r13, #ABT_R14]	@ Store abort address.
	mrs	lr, spsr		@ Get SPSR
	str	lr, [r13, #ABT_SPSR]	@ Store SPSR
	str	r0, [r13, #ABT_R0]	@ Store R0 to use as temp register.
	mov	r0, r13			@ SP to R0
	mrs	lr, cpsr		@ Change to SVC mode.
	bic	lr, #ARM_MODE_MASK
	orr	lr, lr, #ARM_MODE_SVC
	msr	cpsr_fc, r14
	@ FIXME: Ensure 8-byte stack here.
	str	lr, [sp, #-8]!	@ NOTE: Switched mode! Save LR_SVC 2 words down from SP_SVC.
transfer_pabt_state_to_svc: 	@ Move data saved on PABT stack to SVC stack.
	ldr	lr, [r0, #ABT_R14]
	str	lr, [sp, #4]
	@ Stack state: |LR_SVC<-|LR_PABT|{original SP_SVC}|
	ldr	lr, [r0, #ABT_SPSR]
	ldr	r0, [r0, #ABT_R0]
	stmfd	sp!, {r0-r3,r12,lr}
	@ Stack state:  |R0<-|R1|R2|R3|R12|PABT_SPSR|LR_SVC|LR_PABT|{original SP_SVC}|
	push_user_sp_lr sp	@ NOTE: These must be pushed to avoid trashing if preempted
	@ Stack state:  |SP_USR<-|LR_USR|R0|R1|R2|R3|R12|PABT_SPSR|LR_SVC|LR_PABT|{original SP_SVC}|
read_pabt_state:
	cp15_read_ifsr r1	@ Reads FSR on ARMv5, IFSR on ARMv6-v7. Fault status information
	cp15_read_ifar r2	@ Reads FAR on ARMv5, IFAR on ARMv6-v7. Fault address information
	@ All abort state and (FAR/FSR) saved. Can safely enable irqs here, if need be.
	ldr	r3, [sp, #28]		@ Load PABT_SPSR
	can_abort_enable_irqs r0, r3	@ Judge if irqs can be enabled depending on prev state.
	bne	1f			@ Branch here based on previous irq judgement.
	enable_irqs r3
1:
	ldr	r3, [sp, #28]		@ Load PABT_SPSR to r3, the spsr for the aborted mode
	ldr	r0, [sp, #36]		@ Load LR_PABT - 4 saved previously. (Address that aborted)
	mov	lr, pc
	ldr	pc, =prefetch_abort_handler @ Jump to function outside this page.
	disable_irqs r0			@ Disable irqs to avoid corrupting spsr.
					@ (i.e. an interrupt could overwrite spsr with current psr)
	ldmfd	sp, {sp, lr}^		@ Restore user sp and lr which might have been corrupt on preemption
	nop				@ User reg mod requires nop
	add	sp, sp, #8		@ Update SP.
	ldmfd	sp!, {r0-r3,r12,lr}	@ Restore previous context. (note, lr has spsr)
	msr	spsr_cxsf, r14		@ Restore spsr register from lr.
	@ Stack state: |LR_SVC<-|LR_PREV(PABT)|{original SP_SVC}|
	ldmfd	r13!, {r14, pc}^	@ Return, restoring cpsr. Note r14 gets r14_svc,
					@ and pc gets lr_dabt. Saved at #4 and #8 offsets
					@ down from where svc stack had left.
END_PROC(arm_prefetch_abort_exception_reentrant)

/*
 * vect_dabt
 *
 * Upon Entry:
 * - R14_abt:	Address of next instruction after aborted instruction
 * - PC:	0x00000010
 * - IRQs are disabled (CPSR[7] = 1)
 *
 *
 * PURPOSE:
 * Used for handling instructions that caused *memory aborts* during
 * the *execution* of the current instruction. This may happen if the
 * instruction accessed a memory address (e.g LDR/STR) that is not
 * defined as part of the currently executing process (aka illegal
 * access). Another possibility is the address is within the address
 * space of the process, but it is not mapped, i.e. does not have
 * physical-to-virtual translation entry in the page tables.
 */
BEGIN_PROC(arm_data_abort_exception)
	sub	lr, lr, #8	@ lr-8 points at aborted instruction
	mrc	p15, 0, r2, c5, c0, 0 @ Read FSR
	mrc	p15, 0, r1, c6, c0, 0 @ Read FAR
	mov	r0, lr		@ Get data abort address
	mov	r5, lr		@ Save it in r5 in case r0 will get trashed
	mov	lr, pc		@ Save return address
	ldr	pc, =data_abort_handler @ Jump to function outside this page.
1:
	b	1b
END_PROC(arm_data_abort_exception)

/*
 * The method of saving abort state to svc stack is identical with that of
 * reentrant irq vector. Natural to this, Restoring of the previous state
 * is also identical.
 */
BEGIN_PROC(arm_data_abort_exception_reentrant)
	clear_exclusive
	sub	lr, lr, #8		@ Get abort address
	str	lr, [r13, #ABT_R14]	@ Store abort address
	mrs	lr, spsr		@ Get SPSR
	str	lr, [r13, #ABT_SPSR]	@ Store SPSR
	str	r0, [r13, #ABT_R0]	@ Store r0
	@ NOTE: Can increase data abort nest here.
	mov	r0, r13			@ Keep current sp point in R0
	mrs	lr, cpsr		@ Change to SVC mode.
	bic	lr, #ARM_MODE_MASK
	orr	lr, lr, #ARM_MODE_SVC
	msr	cpsr_fc, r14
	@ FIXME: Ensure 8-byte stack here.
	str	lr, [sp, #-8]!	@ Save lr_svc 2 words down from interrupted SP_SVC
transfer_dabt_state_to_svc:
	ldr	lr, [r0, #ABT_R14]
	str	lr, [sp, #4]
	@ Stack state:  |LR_SVC<-|LR_DABT|{original SP_SVC}|
	ldr	lr, [r0, #ABT_SPSR]
	ldr	r0, [r0, #ABT_R0]
	stmfd	sp!, {r0-r3,r12,lr}
	@ Stack state:  |R0<-|R1|R2|R3|R12|DABT_SPSR|LR_SVC|LR_DABT|{original SP_SVC}|
	push_user_sp_lr sp
	@ Stack state:  |SP_USR<-|LR_USR|R0|R1|R2|R3|R12|DABT_SPSR|LR_SVC|LR_DABT|{original SP_SVC}|
read_dabt_state:
	cp15_read_dfsr r1	@ Read DFSR (Tells why the fault occured)
	cp15_read_dfar r2	@ Read DFAR (Contains the faulted data address)
	@ All abort state and (FAR/FSR) saved. Can safely enable irqs here, if need be.
	ldr	r3, [sp, #28]		@ Load DABT_SPSR
	can_abort_enable_irqs r0, r3	@ Judge if irqs can be enabled depending on prev state.
	bne	1f			@ Branch here based on previous irq judgement.
	enable_irqs r3
1:
	ldr	r0, [sp, #36]		@ Load LR_DABT saved previously.
	mov	lr, pc
	ldr	pc, =data_abort_handler @ Jump to function outside this page.
	disable_irqs r0			@ Disable irqs to avoid corrupting spsr.
	ldmfd	sp, {sp, lr}^		@ Restore user sp and lr which might have been corrupt on preemption
	nop				@ User reg mod requires nop
	add	sp, sp, #8		@ Update SP.
	ldmfd	sp!, {r0-r3,r12,lr}	@ Restore previous context. (note, lr has spsr)
	msr	spsr_cxsf, r14		@ Restore spsr register from lr.
	@ Stack state: |LR_SVC<-|LR_PREV(DABT)|{original SP_SVC}|
	ldmfd	r13!, {r14, pc}^	@ Return, restoring cpsr. Note r14 gets r14_svc,
					@ and pc gets lr_dabt. Saved at #4 and #8 offsets
					@ down from where svc stack had left.
END_PROC(arm_data_abort_exception_reentrant)

/*
 * vect_irq
 *
 * Upon Entry:
 * - R14:	Address of next instruction after interrupted instruction.
 * - PC:	0x00000018
 * - IRQs are disabled (CPSR[7] = 1)
 * - A vectored interrupt controller would also provide where to jump in
 *   order to handle the interrupt, or an irq controller in general would
 *   provide registers that indicate what kind of interrupt has occured.
 *
 *
 * PURPOSE:
 * Used for handling IRQs. IRQs have lower priority compared to other
 * types of exceptions.
 */

/* The most basic handler where neither context switching nor re-entry can occur. */
BEGIN_PROC(arm_irq_exception_basic)
	sub	lr, lr, #4
	stmfd	sp!, {r0-r3,lr}
	mov	lr, pc
	ldr	pc, =do_irq
	ldmfd	sp!, {r0-r3, pc}^
END_PROC(arm_irq_exception)

/* Minimal IRQ state saved on irq stack right after irq vector enters: */
#define	IRQ_R0		0
#define IRQ_SPSR	-4
#define IRQ_R14		-8

/* A reentrant handler that uses svc mode stack to prevent banked lr_irq corruption. */
BEGIN_PROC(arm_irq_exception_reentrant)
	sub	lr, lr, #4
@ Save minimal state to irq stack:
	str	r14, [r13, #IRQ_R14]	@ Save lr_irq
	mrs	r14, spsr		@ Copy spsr
	str	r14, [r13, #IRQ_SPSR]	@ Save spsr on irq stack
	str	r0, [r13, #IRQ_R0]	@ Save r0.
	mov	r0, r13			@ Using r0 to keep banked sp_irq when mode is switched.
	mrs	r14, cpsr		@ Get current psr (irq)
	bic	r14, #ARM_MODE_MASK	@ Clear mode part from psr
	orr	r14, r14, #ARM_MODE_SVC	@ Write SVC mode bits.
	msr	cpsr_fc, r14		@ Change to SVC mode.
	str	r14, [r13, #-8]!	@ Save lr_svc 2 words down from where svc stack left.
@ Transfer minimal irq state saved to svc stack:
	ldr	r14, [r0, #IRQ_R14]	@ Load lr_irq to lr using r0 that contains sp_irq.
	str	r14, [r13, #4]		@ Save lr_irq 1 word down from where svc stack left.
	ldr	r14, [r0, #IRQ_SPSR]	@ Load irq spsr.
	ldr	r0, [r0, #IRQ_R0]	@ Restore r0.
	stmfd	sp!, {r0-r3,r12,lr}	@ Save all of rest of irq context to svc stack.
	bl	do_irq			@ Read irq number etc. Free to re-enable irqs here.
	ldmfd	sp!, {r0-r3-r12,lr}	@ Restore previous context. (note, lr has spsr)
	msr	spsr_cxsf, lr		@ Restore spsr register from lr.
	ldmfd	r13!, {r14, pc}^	@ Return, restoring cpsr. Note r14 gets r14_svc,
					@ and pc gets lr_irq. Saved at #4 and #8 offsets
					@ down from where svc stack had left.
END_PROC(arm_irq_exception_reentrant)

	.macro	need_resched rx, ry
	get_current \rx
	ldr	\ry, =need_resched_offset
	ldr	\ry, [\ry]
	ldr	\ry, [\rx, \ry]
	cmp	\ry, #1
	.endm

/*
 * Keeps the PSR of the last pre-empted process. This helps to tell
 * what mode the process was in when it was preempted.
 */
.global preempted_psr;
preempted_psr:
.word	0
.word	0
.word	0
.word	0

/* Keeps track of how many nests of irqs have happened. */
.global current_irq_nest_count;
current_irq_nest_count:
.word	0
.word	0
.word	0
.word	0

#if defined (CONFIG_SMP)
	@ Rx contains the address of per cpu variable
	.macro per_cpu adr, temp, varname
		get_cpuid \temp
		ldr \adr, =\varname
		add \adr, \adr, \temp, lsl #2
	.endm
#else
	.macro per_cpu adr, temp, varname
		ldr \adr, =\varname
	.endm
#endif

/*
 * FIXME: current_irq_nest_count also counts for any preempt_disable() calls.
 * However this nesting check assumes all nests come from real irqs.
 * We should make this check just the real ones.
 */
#define IRQ_NESTING_MAX			32
	.macro	inc_irq_cnt_with_overnest_check rx, ry
	per_cpu \rx, \ry, current_irq_nest_count @ Get per-cpu address of variable
	ldr	\ry, [\rx]
	add	\ry, \ry, #1			@ No need for atomic inc since irqs are disabled.
	str	\ry, [\rx]
	cmp	\ry, #IRQ_NESTING_MAX		@ Check no more than max nests, and die miserably if so.
	ldrge	pc, =irq_overnest_error
	.endm

	@ This decrement need not be atomic because if you are *decrementing* this, then it means
	@ Preemption is already *disabled*. Ruling out preemption, only race could be against irqs.
	@ If an irq preempts it during decrement and modifies it, it is still responsible to change
	@ it back to the original value as it was when we read it, before it returns. So effectively
	@ anything that runs during the decrement does not affect the value of the count.
	.macro	dec_irq_nest_cnt rx, ry
	per_cpu \ry, \rx, current_irq_nest_count
	ldr	\rx, [\ry]
	sub	\rx, \rx, #1
	str	\rx, [\ry]
	.endm
	.macro in_process_context rx, ry
	per_cpu	\rx, \ry, current_irq_nest_count
	ldr	\rx, [\rx]
	cmp	\rx, #0
	.endm
	/* If interrupted a process (as opposed to another irq), saves spsr value to preempted_psr */
	.macro cmp_and_save_process_psr rx, ry
	in_process_context \rx, \ry		@ If nest count is 0, a running process is preempted.
	bne 9999f				@ Branch ahead if not a process
	per_cpu \rx, \ry, preempted_psr		@ Get per-cpu preempted psr
	mrs	\ry, SPSR			@ Re-read spsr since register was trashed
	str	\ry, [\rx]			@ Store it in per-cpu preempted psr
	9999:
	.endm

	/*
	 * Clear irq bits on register.
	 *
	 * If ARMv5, only I-bit is cleared, but if ARMv6-v7,
	 * A-bit is also cleared.
	 */
	.macro clr_irq_bits_on_reg rx
		bic	\rx, #ARM_IRQ_BIT
#if defined (CONFIG_SUBARCH_V6) || defined (CONFIG_SUBARCH_V7)
		bic	\rx, #ARM_A_BIT
#endif
	.endm

#define	CONTEXT_PSR		0
#define CONTEXT_R0		4
#define CONTEXT_R1		8
#define CONTEXT_R2		12
#define CONTEXT_R3		16
#define CONTEXT_R4		20
#define CONTEXT_R5		24
#define CONTEXT_R6		28
#define CONTEXT_R7		32
#define CONTEXT_R8		36
#define CONTEXT_r9		40
#define CONTEXT_R10		44
#define CONTEXT_R11		48
#define CONTEXT_R12		52
#define CONTEXT_R13		56
#define CONTEXT_R14		60
#define CONTEXT_PC		64

/*
 * TODO: Optimization:
 * May use SRS/RFE on irq exception _only_. But not
 * yet aware of its implications. Only irq handler can
 * do it because RFE enables interrupts unconditionally.
 */
BEGIN_PROC(arm_irq_exception_reentrant_with_schedule)
	clear_exclusive
	sub	lr, lr, #4
	str	lr, [r13, #IRQ_R14]	@ Save lr_irq
	mrs	r14, spsr		@ Copy spsr
	str	r14, [r13, #IRQ_SPSR]	@ Save spsr on irq stack
	str	r0, [r13, #IRQ_R0]	@ Save r0.
	cmp_and_save_process_psr r0, r14 @ R14 should have spsr here.
	inc_irq_cnt_with_overnest_check r0, r14
	mov	r0, r13			@ Using r0 to keep banked sp_irq when mode is switched.
	mrs	r14, cpsr		@ Get current psr (irq)
	bic	r14, #ARM_MODE_MASK	@ Clear mode part from psr
	orr	r14, r14, #ARM_MODE_SVC	@ Write SVC mode bits.
	msr	cpsr_fc, r14		@ Change to SVC mode.
	@ FIXME: Ensure 8-byte aligned stack here! Make sure to restore original state later!
	str	r14, [r13, #-8]!	@ Save lr_svc 2 words down from where svc stack left. SP updated.
@ Transfer minimal irq state to svc stack:
	ldr	r14, [r0, #IRQ_R14]	@ Load lr_irq to lr using r0 that contains sp_irq.
	str	r14, [r13, #4]		@ Save lr_irq 1 word down from where svc stack left.
	ldr	r14, [r0, #IRQ_SPSR]	@ Load irq spsr.
	ldr	r0, [r0, #IRQ_R0]	@ Restore r0.
	stmfd	sp!, {r0-r3,r12,lr}	@ Save all of rest of irq context to svc stack.
	mov	lr, pc
	ldr	pc, =do_irq		@ Read irq number etc. Free to re-enable irqs here.
	@ stack state: (Low) r0|r1|r2|r3|r12|SPSR|LR_SVC|LR_IRQ| (High)

/*
 * Decision point for taking the preemption path
 */
#if !defined(CONFIG_PREEMPT_DISABLE)
	per_cpu	r0, r1, current_irq_nest_count
	ldr	r0, [r0]
	cmp	r0, #1			@ Expect 1 as lowest since each irq increase preempt cnt by 1.
	bgt	return_to_prev_context	@ if (irq_nest > 1) return_to_prev_context();
	need_resched r0, r1		@ if (irq_nest == 1 && need_resched) schedule();
	beq	preemption_path		@ if (irq_nest == 1 && !need_resched) return_to_prev_context();
#endif

/*
 * Return to previous context path
 */
return_to_prev_context:
	dec_irq_nest_cnt r0, r1
	disable_irqs r0			@ Disable irqs to avoid corrupting spsr.
	ldmfd	sp!, {r0-r3,r12,lr}	@ Restore previous context. (note, lr has spsr)
	msr	spsr_cxsf, r14		@ Restore spsr register from lr.
	@ stack state: (Low) |LR_SVC<-|LR_PREV(IRQ)|{original SP_SVC}| (High)
	ldmfd	r13!, {r14, pc}^	@ Return, restoring cpsr. Note r14 gets r14_svc,
					@ and pc gets lr_irq. Saved at #4 and #8 offsets
					@ down from where svc stack had left.

/*
 * Preemption path
 */
#if !defined(CONFIG_PREEMPT_DISABLE)
preemption_path:
	disable_irqs r0			@ Interrupts can corrupt stack state.
	get_current r0			@ Get the interrupted process
	@ stack state: (Low) |->r0|r1|r2|r3|r12|SPSR|LR_SVC|LR_IRQ(<return_address>)| (High)
save_interrupted_context:
	add	sp, sp, #4
	@ stack state: (Low) |r0|->r1|r2|r3|r12|SPSR|LR_SVC|LR_IRQ(<return_address>)| (High)
	ldmfd	sp!, {r1-r3, r12, lr}
	@ stack state: (Low) |r0|..|..|..|..|..|->LR_SVC|LR_IRQ(<return_address>)| (High)
	str	lr, [r0, #CONTEXT_PSR]
	is_psr_usr lr
	add	r0, r0, #CONTEXT_R1	@ Points at register save location for #CONTEXT_R1
	stmia	r0!, {r1-r12}
	ldmfd	sp!, {r1-r2}		@ At this point SP_SVC is at its original svc location.
	@ stack state: (Low) |r0|..|..|..|..|..|..|..|->(Original)| (High)
	@ register state: r0 = (register save loc for #CONTEXT_R13) r1 = LR_SVC, r2 = LR_IRQ
	beq	save_usr_context
save_svc_context:
	stmib	r0, {r1-r2}		@ Save LR_SVC and LR_RETURN in advancing locations.
	str	sp, [r0]		@ Current sp is where sp_svc has left, and r0 at #CONTEXT_SP loc.
	sub	r0, r0, #CONTEXT_R13	@ Go back to first word from SP position.
	ldr	r1, [sp, #-32]		@ Load r0 from stack
	str	r1, [r0, #CONTEXT_R0]	@ Save r0
	b 	prepare_schedule	@ All registers saved.
save_usr_context:
	sub	r0, r0, #CONTEXT_R13
	str	r2, [r0, #CONTEXT_PC]	@ Save Program counter
	@ LR_SVC need restoring because it won't be pushed to context frame. SP_SVC is already up-to-date.
	mov	lr, r1
	stmfd	sp, {sp, lr}^	@ Push USR banked regs to stack.
	@ stack state: (Low) |r0|..|..|..|..|..|SP_USR|LR_USR|->(Original)| (High)
	nop			@ Need a NOP after twiddling with usr registers.
	sub	sp, sp, #8	@ Adjust SP, since stack op on banked regs is no writeback.
	@ stack state: (Low) |r0|..|..|..|..|..|->SP_USR|LR_USR|(Original)| (High)
	ldmfd	sp!, {r1-r2} 	@ Pop USR Banked regs.
	@ stack state: (Low) |r0|..|..|..|..|..|..|..|->(Original)| (High)
	str	r1, [r0, #CONTEXT_R13]	@ Save SP_USR to context frame.
	str	r2, [r0, #CONTEXT_R14]	@ Save LR_USR to context frame.
	ldr	r1, [sp, #-32]
	str	r1, [r0, #CONTEXT_R0]
	@ stack state: (Low) |..|..|..|..|..|..|..|..|->(Original)| (High)
prepare_schedule:
	mov lr, pc
	ldr pc, =schedule
1:
	b	1b	/* To catch if schedule returns in irq mode */
#endif /* End of !CONFIG_PREEMPT_DISABLE */

END_PROC(arm_irq_exception_reentrant_with_schedule)

/*
 * Context switch implementation.
 *
 * Upon entry:
 *
 * - r0 = current ktcb ptr, r1 = next ktcb ptr. r2 and r3 = insignificant.
 * - The current mode is always SVC, but the call may be coming from interrupt
 *   or process context.
 * - If coming from interrupt, the interrupted context is already copied to current
 *   ktcb in the irq handler, before coming here. Interrupted context can be SVC or USR.
 *
 * PURPOSE: Handles all paths from irq exception, thread_switch system call,
 * and sleeping in the kernel.
 *
 * NOTES:
 * - If coming from interrupt, the interrupted context is already copied to current
 *   ktcb in the irq handler, before coming here. Interrupted context can be SVC or USR.
 * - If coming from a process context, the current process context need saving here.
 * - From irq contexts, preemption is disabled, i.e. preemption count is 1. This is because
 *   irqs naturally increase preemption count. From process context preemption count is 0.
 *   Process context disables preemption during schedule(), but re-enables before calling
 *   switch_to(). Irq and process contexts are distinguished by preemption_count.
 *   Furthermore, irqs are also disabled shortly before calling switch_to() from both contexts.
 *   This happens at points where stack state would be irrecoverable if an irq occured.
 */
BEGIN_PROC(arch_context_switch)
	clear_exclusive
	in_process_context r2, r3	@ Note this depends on preempt count being 0.
	beq	save_process_context	@ Voluntary switch needs explicit saving of current state.
	dec_irq_nest_cnt r2, r3		@ Soon leaving irq context, so reduce preempt count here.
	b 	load_next_context	@ Interrupted context already saved by irq handler.
save_process_context:		@ Voluntary process schedules enter here:
	mrs	r2, cpsr_fc
	str	r2, [r0]
	stmib	r0, {r0-r14}	@ Voluntary scheduling always in SVC mode, so using svc regs.
	str	r14, [r0, #CONTEXT_PC]	@ Store R15 as R14. R14 has return address for switch_to().
load_next_context:
	@ stack state: (Low) |..|..|..|..|..|..|..|..|..|->(Original)| (High)
	mov	sp, r1
	ldr	r0, [sp, #CONTEXT_PSR]	@ Load r0 with SPSR
	clr_irq_bits_on_reg r0		@ Enable irqs on will-be-restored context.
	msr	spsr_fcxs, r0		@ Restore spsr from r0.
	is_psr_usr r0
	bne load_next_context_svc	@ Loading user context is different than svc.
load_next_context_usr:
	ldmib	sp, {r0-r14}^		@ Load all including banked user regs.
	ldr	lr, [sp, #CONTEXT_PC]	@ Load value of PC to r14
	orr	sp, sp, #0xFF0
	orr	sp, sp, #0x8		@ 8-byte aligned.
	movs	pc, lr			@ Jump to user changing modes.
load_next_context_svc:
	ldmib	sp, {r0-r15}^		@ Switch to svc context and jump, loading R13 and R14 from stack.
					@ This is OK since the jump is to current context.
END_PROC(arch_context_switch)


/*
 * vect_fiq
 *
 * Upon Entry:
 * - R14:	Address of next instruction after interrupted instruction.
 * - PC:	0x00000014
 * - FIQs are disabled (CPSR[6] = 1)
 * - IRQs are disabled (CPSR[7] = 1)
 * - As in IRQ, the irq controller would provide registers that indicate
 *   what kind of interrupt has occured.
 *
 * PURPOSE:
 * Handling of high-priority interrupts. FIQs have highest priority after
 * reset and data abort exceptions. They're mainly used for achieving
 * low-latency interrupts, e.g. for DMA.
 */
BEGIN_PROC(arm_fiq_exception)
END_PROC(arm_fiq_exception)

/* * * * * * * * * * * * * * * * * * * * * * * *
 * External functions with absolute addresses  *
 * * * * * * * * * * * * * * * * * * * * * * * */

/*
 * NOTE: Notes on relative and absolute symbols on this file:
 *
 * Note that branches (B and BL) are *RELATIVE* on ARM. So no need to take any
 * special action to access symbols within this file, even though this page
 * (in virtual memory) is relocated to another address at run-time (high or low
 * vectors) - this is an address other than where it is linked at, at
 * compile-time.
 *
 * To access external symbols from this file, (e.g. calling some function in the
 * kernel) one needs to use the: `LDR, pc, =external_symbol' pseudo-instruction,
 * (note the "=") and use absolute addressing. This automatically generates an
 * inline data word within the current module and indirectly loads the value in
 * that word to resolve the undefined reference. All other methods, (LDR, B
 * instructions, or ADR pseudoinstruction) generate relative addresses, and they
 * will complain for external symbols because a relative offset cannot be
 * calculated for an unknown distance. In conclusion, relative branches are
 * useful for accessing symbols on this page, but they mean nothing outside this
 * page, because the page is relocated at run-time. So, wherever you access
 * *relatively* outside this page, would be *relative* to where this page is at
 * that moment.
 */

/* * * * * * * * * * * * * * * * *
 * Stacks for Exception Vectors  *
 * * * * * * * * * * * * * * * * */
.global	__stacks_end;
.global __abt_stack_high;
.global __irq_stack_high;
.global __fiq_stack_high;
.global __und_stack_high;

/*
 * These are also linked at high vectors, just as any other symbol
 * on this page.
 */
.balign 4
.equ __abt_stack_high, (__abt_stack - __vector_vaddr + 0xFFFF0000);
.equ __irq_stack_high, (__irq_stack - __vector_vaddr + 0xFFFF0000);
.equ __fiq_stack_high, (__fiq_stack - __vector_vaddr + 0xFFFF0000);
.equ __und_stack_high, (__und_stack - __vector_vaddr + 0xFFFF0000);

/*
 * NOTE: This could be cache line aligned.
 * (use a macro, e.g. ____arm_asm_cache_aligned)
 */
.balign 4

/* 16 bytes each per-cpu, up to 8 cpus */
__stacks_end:	.space 128
__abt_stack:	.space 128
__irq_stack:	.space 128
__fiq_stack:	.space 128
__und_stack:	.space 128


