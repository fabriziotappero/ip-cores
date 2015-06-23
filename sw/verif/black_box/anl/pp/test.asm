	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test ANL Pp, data.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #0FFH
	outl	p1, a
	outl	p2, a

	clr	a
	in	a, p1
	inc	a
	jnz	fail

	in	a, p2
	inc	a
	jnz	fail

	anl	P1, #0AAH
	jnz	fail
	anl	P2, #055H
	jnz	fail

	in	a, p1
	add	a, #056H
	jnz	fail

	in	a, p2
	add	a, #0ABH
	jnz	fail

pass:	PASS

fail:	FAIL
