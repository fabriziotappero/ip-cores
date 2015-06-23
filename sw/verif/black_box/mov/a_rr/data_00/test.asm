	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test MOV A, Rr for RB0 with 0x00.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #055H
	mov	r0, #000H
	mov	r1, #0FFH
	mov	r2, #0FFH
	mov	r3, #0FFH
	mov	r4, #0FFH
	mov	r5, #0FFH
	mov	r6, #0FFH
	mov	r7, #0FFH

	mov	a, r0
	jnz	fail

	mov	r1, #000H
	mov	r0, #0FFH
	mov	a, r1
	jnz	fail

	mov	r2, #000H
	mov	r1, #0FFH
	mov	a, r2
	jnz	fail

	mov	r3, #000H
	mov	r2, #0FFH
	mov	a, r3
	jnz	fail

	mov	r4, #000H
	mov	r3, #0FFH
	mov	a, r4
	jnz	fail

	mov	r5, #000H
	mov	r4, #0FFH
	mov	a, r5
	jnz	fail

	mov	r6, #000H
	mov	r5, #0FFH
	mov	a, r6
	jnz	fail

	mov	r7, #000H
	mov	r6, #0FFH
	mov	a, r7
	jnz	fail

pass:	PASS

fail:	FAIL
