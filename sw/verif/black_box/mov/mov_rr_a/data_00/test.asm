	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test MOV Rr, A for RB0 with 0x00.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #00H
	mov	r0, a
	mov	a, #0FFH
	mov	r1, a
	mov	r2, a
	mov	r3, a
	mov	r4, a
	mov	r5, a
	mov	r6, a
	mov	r7, a

	mov	a, r0
	jnz	fail

	mov	a, #000H
	mov	r1, a
	mov	a, #0FFH
	mov	r0, a
	mov	a, r1
	jnz	fail

	mov	a, #000H
	mov	r2, a
	mov	a, #0FFH
	mov	r1, a
	mov	a, r2
	jnz	fail

	mov	a, #000H
	mov	r3, a
	mov	a, #0FFH
	mov	r2, a
	mov	a, r3
	jnz	fail

	mov	a, #000H
	mov	r4, a
	mov	a, #0FFH
	mov	r3, a
	mov	a, r4
	jnz	fail

	mov	a, #000H
	mov	r5, a
	mov	a, #0FFH
	mov	r4, a
	mov	a, r5
	jnz	fail

	mov	a, #000H
	mov	r6, a
	mov	a, #0FFH
	mov	r5, a
	mov	a, r6
	jnz	fail

	mov	a, #000H
	mov	r7, a
	mov	a, #0FFH
	mov	r6, a
	mov	a, r7
	jnz	fail

pass:	PASS

fail:	FAIL
