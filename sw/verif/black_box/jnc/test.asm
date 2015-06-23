	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test JNC instruction.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	jnc	ok_1
	jmp	fail

ok_1:	mov	a, #0FFH
	add	a, #001H
	jnc	fail

pass:	PASS

fail:	FAIL
