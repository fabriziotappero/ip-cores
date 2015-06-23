###############################################################################
# TITLE: Exception Vectors
# AUTHOR: Grant Ayers (ayers@cs.utah.edu)
# DATE: 23 May 2012
# FILENAME: exceptions.asm
# PROJECT: University of Utah XUM Single Core
# DESCRIPTION:
#   Provides the exception vectors which jump to
#   exception-handling routines.
#
###############################################################################

	.text
	.balign	4
	.set	noreorder
	.set	noat

exc_save:
	# Save all registers except k0 k1 sp ra
	addiu	$sp, $sp, -112
	sw	$1,    0($sp)
	sw	$2,    4($sp)
	sw	$3,    8($sp)
	sw	$4,   12($sp)
	sw	$5,   16($sp)
	sw	$6,   20($sp)
	sw	$7,   24($sp)
	sw	$8,   28($sp)
	sw	$9,   32($sp)
	sw	$10,  36($sp)
	sw	$11,  40($sp)
	sw	$12,  44($sp)
	sw	$13,  48($sp)
	sw	$14,  52($sp)
	sw	$15,  56($sp)
	sw	$16,  60($sp)
	sw	$17,  64($sp)
	sw	$18,  68($sp)
	sw	$19,  72($sp)
	sw	$20,  76($sp)
	sw	$21,  80($sp)
	sw	$22,  84($sp)
	sw	$23,  88($sp)
	sw	$24,  92($sp)
	sw	$25,  96($sp)
	sw	$28, 100($sp)
	jr	$ra
	sw	$30, 104($sp)

exc_restore:
	# Restore all registers except k0 k1 sp ra
	lw	$1,    0($sp)
	lw      $2,    4($sp)
	lw      $3,    8($sp)
	lw      $4,   12($sp)
	lw      $5,   16($sp)
	lw      $6,   20($sp)
	lw      $7,   24($sp)
	lw      $8,   28($sp)
	lw      $9,   32($sp)
	lw      $10,  36($sp)
	lw      $11,  40($sp)
	lw      $12,  44($sp)
	lw      $13,  48($sp)
	lw      $14,  52($sp)
	lw      $15,  56($sp)
	lw      $16,  60($sp)
	lw      $17,  64($sp)
	lw      $18,  68($sp)
	lw      $19,  72($sp)
	lw      $20,  76($sp)
	lw      $21,  80($sp)
	lw      $22,  84($sp)
	lw      $23,  88($sp)
	lw      $24,  92($sp)
	lw      $25,  96($sp)
	lw	$28, 100($sp)
	lw	$30, 104($sp)
	jr      $ra
	addiu	$sp, $sp, 112


	.global	mips32_general_exception
	.ent	mips32_general_exception
mips32_general_exception:
	or	$26, $0, $ra
	jal	exc_save
	nop
	mfc0	$27, $13, 0		# Read Cause which has ExcCode bits
	srl	$27, $27, 2		# Extract exception code to $k1
	andi	$27, $27, 0x001f

	la	$ra, $end_exception	# Jump to the appropriate handler
	addiu	$t0, $0, 4
	addiu	$t1, $0, 5
	addiu	$t2, $0, 8
	addiu	$t3, $0, 9
	beq	$t0, $27, mips32_handler_AdEL
	addiu	$t0, $0, 10
	beq	$t1, $27, mips32_handler_AdES
	addiu	$t1, $0, 11
	beq	$t2, $27, mips32_handler_Sys
	addiu	$t2, $0, 12
	beq	$t3, $27, mips32_handler_Bp
	addiu	$t3, $0, 13
	beq	$t0, $27, mips32_handler_RI
	nop
	beq	$t1, $27, mips32_handler_CpU
	nop
	beq	$t2, $27, mips32_handler_Ov
	nop
	beq	$t3, $27, mips32_handler_Tr
	nop

$end_exception:
	jal	exc_restore
	xor	$27, $0, $0
	or	$ra, $0, $26
	xor	$26, $0, $0
	eret
	.end	mips32_general_exception



### "Special" Interrupt Vector: Cause_IV must be set.
	
	.ent	mips32_interrupt_exception
	.global	mips32_interrupt_exception
mips32_interrupt_exception:
	mfc0	$26, $12, 0		# Status register for IM bits
	mfc0	$27, $13, 0		# Cause register for IP bits
	and	$26, $26, $27		# Extract pending, unmasked interrupts
	srl	$26, $26, 8
	andi	$26, $26, 0x00ff

	addu	$27, $0, $ra
	jal	exc_save	
	clz	$26, $26
	la	$ra, $end_interrupt	# All C functions will return here
	addiu	$t0, $0, 24
	addiu	$t1, $0, 25
	addiu	$t2, $0, 26
	beq	$26, $t0, mips32_handler_HwInt5
	addiu	$t0, $0, 27
	beq	$26, $t1, mips32_handler_HwInt4
	addiu	$t1, $0, 28
	beq	$26, $t2, mips32_handler_HwInt3
	addiu	$t2, $0, 29
	beq	$26, $t0, mips32_handler_HwInt2
	addiu	$t0, $0, 30
	beq	$26, $t1, mips32_handler_HwInt1
	addiu	$t1, $0, 31
	beq	$26, $t2, mips32_handler_HwInt0
	nop
	beq	$26, $t0, mips32_handler_SwInt1
	nop
	beq	$26, $t1, mips32_handler_SwInt0
	nop
	

$end_interrupt:
	jal	exc_restore
	mfc0	$26, $9, 0		# Clear HwInt5 if applicable
	or	$ra, $0, $27
	eret
	.end	mips32_interrupt_exception


