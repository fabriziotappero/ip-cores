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

exc_save:
	addiu	$sp, $sp, -96
	sw	$2,   0($sp)
	sw	$3,   4($sp)
	sw	$4,   8($sp)
	sw	$5,  12($sp)
	sw	$6,  16($sp)
	sw	$7,  20($sp)
	sw	$8,  24($sp)
	sw	$9,  28($sp)
	sw	$10, 32($sp)
	sw	$11, 36($sp)
	sw	$12, 40($sp)
	sw	$13, 44($sp)
	sw	$14, 48($sp)
	sw	$15, 52($sp)
	sw	$16, 56($sp)
	sw	$17, 60($sp)
	sw	$18, 64($sp)
	sw	$19, 68($sp)
	sw	$20, 72($sp)
	sw	$21, 76($sp)
	sw	$22, 80($sp)
	sw	$23, 84($sp)
	sw	$24, 88($sp)
	jr	$ra
	sw	$25, 92($sp)

exc_restore:
	lw      $2,   0($sp)
	lw      $3,   4($sp)
	lw      $4,   8($sp)
	lw      $5,  12($sp)
	lw      $6,  16($sp)
	lw      $7,  20($sp)
	lw      $8,  24($sp)
	lw      $9,  28($sp)
	lw      $10, 32($sp)
	lw      $11, 36($sp)
	lw      $12, 40($sp)
	lw      $13, 44($sp)
	lw      $14, 48($sp)
	lw      $15, 52($sp)
	lw      $16, 56($sp)
	lw      $17, 60($sp)
	lw      $18, 64($sp)
	lw      $19, 68($sp)
	lw      $20, 72($sp)
	lw      $21, 76($sp)
	lw      $22, 80($sp)
	lw      $23, 84($sp)
	lw      $24, 88($sp)
	lw      $25, 92($sp)
	jr      $ra
	addiu	$sp, $sp, 96


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

	clz	$26, $26
	addiu	$27, $0, 24
	beq	$26, $27, scheduler	# Hw Int 5 goes directly to scheduler
	nop

	addu	$27, $0, $ra
	jal	exc_save
	nop
	la	$ra, $end_interrupt
	addiu	$t0, $0, 25
	addiu	$t1, $0, 26
	addiu	$t2, $0, 27
	beq	$26, $t0, mips32_handler_HwInt4
	addiu	$t0, $0, 28
	beq	$26, $t1, mips32_handler_HwInt3
	addiu	$t1, $0, 29
	beq	$26, $t2, mips32_handler_HwInt2
	addiu	$t2, $0, 30
	beq	$26, $t0, mips32_handler_HwInt1
	addiu	$t0, $0, 31
	beq	$26, $t1, mips32_handler_HwInt0
	nop
	beq	$26, $t2, mips32_handler_SwInt1
	nop
	beq	$26, $t0, mips32_handler_SwInt0
	nop

$end_interrupt:
	jal	exc_restore
	xor	$27, $0, $0
	or	$ra, $0, $26
	xor	$26, $0, $0
	eret
	.end	mips32_interrupt_exception

