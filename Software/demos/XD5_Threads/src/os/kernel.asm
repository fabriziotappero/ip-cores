###############################################################################
# TITLE: Thread kernel demo
# AUTHOR: Grant Ayers (ayers@cs.utah.edu)
# DATE: 30 June 2012
# FILENAME: kernel.asm
# PROJECT: University of Utah XUM Single Core
# DESCRIPTION:
#    Switches between 8 simultaneously-running threads.
#    Demonstrates interrupts and llsc atomic operations.
#
###############################################################################


	.text
	.balign	4
	.global	kernel
	.ent	kernel
	.set	noreorder
	.set	noat
kernel:
	addiu	$sp, $sp, -1152		# Room for 9*32 registers
	
	# Set the stack pointer ($29) for each of 8 threads
	lui	$t0, 0x0007
	ori	$t0, $t0, 0x4000
	sw	$t0, 1140($sp)
	addiu	$t0, $t0, 0x4000
	sw	$t0, 1012($sp)
	addiu   $t0, $t0, 0x4000
	sw	$t0, 884($sp)
	addiu   $t0, $t0, 0x4000
	sw	$t0, 756($sp)
	addiu   $t0, $t0, 0x4000
	sw	$t0, 628($sp)
	addiu   $t0, $t0, 0x4000
	sw	$t0, 500($sp)
	addiu   $t0, $t0, 0x4000
	sw	$t0, 372($sp)
	addiu   $t0, $t0, 0x4000
	sw	$t0, 244($sp)

	# Set the global pointer ($28) for each of 8 threads
	sw	$gp, 240($sp)
	sw	$gp, 368($sp)
	sw      $gp, 496($sp)
	sw      $gp, 624($sp)
	sw      $gp, 752($sp)
	sw      $gp, 880($sp)
	sw      $gp, 1008($sp)
	sw      $gp, 1136($sp)

	# Set the EPC for each of 8 threads to start at main
	lui	$t0, main
	ori	$t0, $t0, main
	sw	$t0, 128($sp)
	sw      $t0, 256($sp)
	sw      $t0, 384($sp)
	sw      $t0, 512($sp)
	sw      $t0, 640($sp)
	sw      $t0, 768($sp)
	sw      $t0, 896($sp)
	sw      $t0, 1024($sp)

	sw	$zero, 0($sp)		# Current thread stored in 0($sp)
	mfc0	$k0, $12, 0		# Enable timer interrupt
	ori	$k0, $k0, 0x8000
	mtc0	$k0, $12, 0

$wait:
	j	$wait			# Wait for interrupt to begin schedule
	nop
	.end	kernel




	.global	scheduler
	.ent	scheduler
scheduler:
	addu	$k0, $0, $sp		# Recover the kernel stack pointer
	la	$sp, _sp
	addiu	$sp, $sp, -1152
	sw	$25, 4($sp)		# Free four registers for use
	sw	$28, 8($sp)
	sw	$30, 12($sp)
	sw	$31, 16($sp)
	lw	$k1, 0($sp)		# Current TID to k1
	beq	$k1, $zero, $skip_save	# Don't save kernel's registers
	nop	
	jal	save_registers
	nop
$skip_save:
	lw	$t0, 0($sp)		# Increment TID
	addiu	$t0, $t0, 1
	addiu	$t1, $zero, 9		# Move TID back to 1 if it reaches 9
	beq	$t0, $t1, $reset_tid
	nop
$tid_done:
	sw	$t0, 0($sp)
	jal	restore_registers	# Load registers for next thread
	nop
	la	$k1, _sp		# Recover kernel stack pointer again
	addiu	$k1, $k1, -1152
	lw	$k1, 0($k1)		# Load TID to k1 for main function
	mfc0	$26, $9, 0		# Read Count to clear timer interrupt
	eret				# Run thread
$reset_tid:
	addiu	$t0, $zero, 1
	j	$tid_done
	nop
	.end	scheduler


save_registers:
	# Requires: k0 hold thread stack pointer
	#           k1 holds TID
	#           sp points to kernel stack
	# Destroys:

	# Find offset for register table in kernel space
	addiu	$25, $zero, 128
	mul	$25, $25, $k1
	addu	$25, $25, $sp

	# Store thread stack pointer
	sw	$k0, 116($25)
	addu	$k0, $0, $25

	# Store EPC from CP0
	mfc0	$25, $14, 0
	sw	$25, 0($k0)

	# Store remaining registers
	sw	$1, 4($k0)
	sw	$2, 8($k0)
	sw	$3, 12($k0)
	sw	$4, 16($k0)
	sw	$5, 20($k0)
	sw	$6, 24($k0)
	sw	$7, 28($k0)
	sw	$8, 32($k0)
	sw	$9, 36($k0)
	sw	$10, 40($k0)
	sw	$11, 44($k0)
	sw	$12, 48($k0)
	sw	$13, 52($k0)
	sw	$14, 56($k0)
	sw	$15, 60($k0)
	sw	$16, 64($k0)
	sw	$17, 68($k0)
	sw	$18, 72($k0)
	sw	$19, 76($k0)
	sw	$20, 80($k0)
	sw	$21, 84($k0)
	sw	$22, 88($k0)
	sw	$23, 92($k0)
	sw	$24, 96($k0)
	lw	$25, 4($sp)
	sw	$25, 100($k0)
	lw	$28, 8($sp)
	sw	$28, 112($k0)
	lw	$30, 12($sp)
	sw	$30, 120($k0)
	addu	$k1, $0, $31
	lw	$31, 16($sp)
	sw	$31, 124($k0)
	jr	$k1
	nop


restore_registers:
	# Requires: t0 specifies which thread (1-8)
	#           sp points to kernel stack
	# Destroys: All registers

	# Find offset for register table in kernel space
	addiu	$k1, $zero, 128
	mul	$k0, $t0, $k1
	addu	$k0, $k0, $sp


	# Load EPC to CP0
	lw	$k1, 0($k0)
	mtc0	$k1, $14, 0
	# Load remaining registers
	lw	$1, 4($k0)
	lw	$2, 8($k0)
	lw	$3, 12($k0)
	lw	$4, 16($k0)
	lw	$5, 20($k0)
	lw	$6, 24($k0)
	lw	$7, 28($k0)
	lw	$8, 32($k0)
	lw	$9, 36($k0)
	lw	$10, 40($k0)
	lw	$11, 44($k0)
	lw	$12, 48($k0)
	lw	$13, 52($k0)
	lw	$14, 56($k0)
	lw	$15, 60($k0)
	lw	$16, 64($k0)
	lw	$17, 68($k0)
	lw	$18, 72($k0)
	lw	$19, 76($k0)
	lw	$20, 80($k0)
	lw	$21, 84($k0)
	lw	$22, 88($k0)
	lw	$23, 92($k0)
	lw	$24, 96($k0)
	lw	$25, 100($k0)
	lw	$28, 112($k0)
	lw	$29, 116($k0)
	lw	$30, 120($k0)
	addu	$k1, $0, $31
	lw	$31, 124($k0)
	jr	$k1
	nop

