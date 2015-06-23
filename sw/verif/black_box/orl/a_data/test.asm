	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test ORL A, data.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	clr	a
	orl	a, #0FFH
	jz	fail
	orl	a, #0FFH
	jz	fail

	clr	a
	orl	a, #055H
	add	a, #0ABH
	jnz	fail

	clr	a
	orl	a, #023H
	orl	a, #088H
	add	a, #055H
	jnz	fail

pass:	PASS

fail:	FAIL
