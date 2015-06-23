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

        /* Setup stack pointer */
        la      sp, _sp
      
        /* Clear bss */
        la      t0, 0x00000000      /* First address */
        la      t1, _end        /* Last  address */
bbs_zero:       
        /*sw      zero, 0(t0)
        bne     t0, t1, bbs_zero
        addiu   t0, 4*/

        /* Jump to main */
        jal	main
	nop

	/* Run endless loop when the program terminates */
loop:
	j	loop

	.set	reorder
	.end	_start
