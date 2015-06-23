	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test MOV Rr, A for RB0 with 2*r.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #0FEH
	mov	r0, a
	mov	a, #0FDH
	mov	r1, a
	mov	a, #0FBH
	mov	r2, a
	mov	a, #0F7H
	mov	r3, a
	mov	a, #0EFH
	mov	r4, a
	mov	a, #0DFH
	mov	r5, a
	mov	a, #0BFH
	mov	r6, a
	mov	a, #07FH
	mov	r7, a

	mov	a, #000H

	mov	a, r0
	jz	fail
	jb0	fail

	mov	a, r1
	jb1	fail

	mov	a, r2
	jb2	fail

	mov	a, r3
	jb3	fail

	mov	a, r4
	jb4	fail

	mov	a, r5
	jb5	fail

	mov	a, r6
	jb6	fail

	mov	a, r7
	jb7	fail

pass:	PASS

fail:	FAIL
