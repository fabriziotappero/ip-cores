/*
 * Starting point for everything (bootstrap)
 *
 * Initializes the stack pointer and jumps to main().
 */

#include "regdef.h"

	.text
	.align  2
	.globl  _start
	.ent    _start
_start:
	.set noreorder

	j	reset_handler
	nop
	
	j	handling_exception
	nop

	
reset_handler:
	/* Setup stack pointer */
        la      sp, _sp
      
        /* Clear bss */
        la      t0, 0x00000000      /* First address */
        la      t1, _end        /* Last  address */
	
	mfc0 k0, $12
	add k0, k0, 3
	mtc0 k0, $12
	
	
	jal	main
	nop
	j loop
	nop
	
handling_exception:	
	nop
	mfc0 k0, $13
	mfc0 k1, $14
	
	srl k0, k0, 2
	andi k0, k0, 0x1F
	
	beq k0, $0, handling_interrupt
	nop
	
	add $11, $0, $0
	addiu $11, k1, 4
	mtc0 $11, $14
	eret
	nop
	
	
handling_interrupt:
	nop
	eret
	nop

	/* Run endless loop when the program terminates */
loop:
	j	loop

	.set	reorder
	.end	_start
