	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test ADDC A, data.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	jc	fail
	mov	a, #000H

	addc	a, #055H
	jc	fail
	addc	a, #0ABH
	jnz	fail
	jnc	fail

	addc	a, #000H
	jc	fail
	addc	a, #0FFH
	jnz	fail
	jnc	fail

pass:	PASS

fail:	FAIL
