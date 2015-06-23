	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test XRL A, data.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	clr	a
	xrl	a, #0FFH
	jz	fail
	xrl	a, #0FFH
	jnz	fail

	clr	a
	xrl	a, #055H
	add	a, #0ABH
	jnz	fail

	clr	a
	xrl	a, #023H
	xrl	a, #0A9H
	add	a, #076H
	jnz	fail

pass:	PASS

fail:	FAIL
