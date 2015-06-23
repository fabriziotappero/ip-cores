	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test CLR C.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	jc	fail
	cpl	c
	jnc	fail
	clr	c
	jc	fail
	clr	c
	jc	fail

	mov	a, #0FFH
	add	a, #001H
	jnc	fail
	clr	c
	jc	fail

pass:	PASS

fail:	FAIL
