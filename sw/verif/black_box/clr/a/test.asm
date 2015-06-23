	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test CLR A.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #0FFH
	jz	fail
	clr	a
	jnz	fail

	inc	a
	jb0	ok_1
	jmp	fail

ok_1:	add	a, #0FFH
	jnz	fail

	add	a, #010H
	clr	a
	dec	a
	add	a, #001H
	jnz	fail

pass:	PASS

fail:	FAIL
