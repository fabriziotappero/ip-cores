#include "board.h"
#include "mc.h"

	.global ___main
        .section .stack, "aw", @nobits
.space  STACK_SIZE
_stack:

        .section .vectors, "ax"
        .org 0x100
_reset:
        l.movhi r1,hi(_stack-4)
        l.ori   r1,r1,lo(_stack-4)
        l.addi  r2,r0,-3
        l.and   r1,r1,r2
 
        l.movhi r2,hi(_main)
        l.ori   r2,r2,lo(_main)
        l.jr    r2
        l.addi  r2,r0,0

___main:
	l.jr	r9
	l.nop
