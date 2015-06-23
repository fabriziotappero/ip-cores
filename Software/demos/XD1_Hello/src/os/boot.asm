###############################################################################
# TITLE: Boot Up Code
# AUTHOR: Grant Ayers (ayers@cs.utah.edu)
# DATE: 19 July 2011
# FILENAME: boot.asm
# PROJECT: University of Utah XUM Single Core
# DESCRIPTION:
#   Initializes the global pointer and stack pointer.
#   Zeros BSS memory region and jumps to main().
#
###############################################################################


	.text
	.balign	4
	.global	boot
	.ent	boot
	.set	noreorder
boot:
	la	$t0, _bss_start		# Defined in linker script
	la	$t1, _bss_end
	la	$sp, _sp
	la	$gp, _gp

$bss_clear:
	beq	$t0, $t1, $cp0_setup	# Loop until BSS is cleared
	nop
	sb	$0, 0($t0)
	j	$bss_clear
	addiu	$t0, $t0, 1

$cp0_setup:
	la	$26, $run
	mtc0	$26, $30, 0		# ErrorEPC gets address of $run
	mfc0	$26, $13, 0		# Load Cause register
	lui	$27, 0x0080		# Use "special" interrupt vector
	or	$26, $26, $27
	mtc0	$26, $13, 0		# Commit new Cause register
	mfc0	$26, $12, 0		# Load Status register
	lui	$27, 0x0fff		# Disable access to Coprocessors
	ori	$27, $27, 0x00ee	# Disable all interrupts,
	and	$26, $26, $27		#   and set kernel mode
	mtc0	$26, $12, 0		# Commit new Status register
	eret				# Return from Reset Exception

$run:
	jal	main
	nop

$done:
	j	$done
	nop
	.end boot

