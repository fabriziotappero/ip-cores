	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test MOV A, Rr for RB0 with 2*r.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #000H
	mov	r0, #0FEH
	mov	r1, #0FDH
	mov	r2, #0FBH
	mov	r3, #0F7H
	mov	r4, #0EFH
	mov	r5, #0DFH
	mov	r6, #0BFH
	mov	r7, #07FH

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
