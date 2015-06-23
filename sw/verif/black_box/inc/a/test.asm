	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test INC A.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #000H
	inc	a
	add	a, #0FFH
	jnz	fail

	inc	a
	jb0	ok_0
	jmp	fail

ok_0:	mov	a, #0FFH
	inc	a
	jnz	fail

	mov	a, #010100101B
	inc	a
	add	a, #001011001B
	inc	a
	jnz	fail

pass:	PASS

fail:	FAIL
