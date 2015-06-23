
/* Template boot-code for LEON3 test benches */

#ifndef STACKSIZE
#define STACKSIZE 0x00002000
#endif

#include "prom.h"

	.seg	"text"
	.proc	0
	.align	4
	.global start
start:

	flush
	set 0x10e0, %g1		! init IU
	mov %g1, %psr
	mov %g0, %wim
	mov %g0, %tbr
	mov %g0, %y
	nop
	set  0x81000f, %g1
	sta %g1, [%g0] 2

2:
	mov %asr17, %g3
	and %g3, 0x1f, %g3
	mov %g0, %g4
	mov %g0, %g5
	mov %g0, %g6
	mov %g0, %g7
1:
	mov %g0, %l0
	mov %g0, %l1
	mov %g0, %l2
	mov %g0, %l3
	mov %g0, %l4
	mov %g0, %l5
	mov %g0, %l6
	mov %g0, %l7
	mov %g0, %o0
	mov %g0, %o1
	mov %g0, %o2
	mov %g0, %o3
	mov %g0, %o4
	mov %g0, %o5
	mov %g0, %o6
	mov %g0, %o7
	subcc %g3, 1, %g3
	bge 1b
	save

	mov	2, %g1
	mov	%g1, %wim
	set 0x10e0, %g1		! enable traps
	mov %g1, %psr
	nop; nop; nop;

	mov %psr, %g1
	srl %g1, 12, %g1
	andcc %g1, 1, %g0
	be 1f
	nop

	set _fsrxx, %g3
	ld [%g3], %fsr
	ldd [%g3], %f0
	ldd [%g3], %f2
	ldd [%g3], %f4
	ldd [%g3+8], %f6
	ldd [%g3], %f8
	ldd [%g3], %f10
	ldd [%g3], %f12
	ldd [%g3], %f14
	ldd [%g3], %f16
	ldd [%g3], %f18
	ldd [%g3], %f20
	ldd [%g3], %f22
	ldd [%g3], %f24
	ldd [%g3], %f26
	ldd [%g3], %f28
	ba  1f
	ldd [%g3], %f30

.align	8
_fsrxx:
	.word 0
	.word 0


1:	set STACKSIZE, %g2
        mov %g0, %g1
				
/*
	set 0x80000d00, %g4
!	set 0x40000000+114*4, %g5
	set 0x400005E4, %g5
	set 0x405685E4, %g6
	st %g5, [%g4]
!	add %g5, 0x200, %g5
	st %g6, [%g4+4]
	set 0x1a0005, %g5
	st %g5, [%g4+8]
4:
	ba 4b
	nop
*/

3:	set RAMSTART+ RAMSIZE-32, %fp
	sub %fp, %g1, %fp
	sub %fp, 96, %sp

	set RAMSTART, %g1

	jmp %g1
	nop	

.align	32
