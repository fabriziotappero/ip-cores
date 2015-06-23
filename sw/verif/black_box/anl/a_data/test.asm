	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test ANL A, data.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #0FFH
	anl	a, #000H
	jnz	fail
	anl	a, #000H
	jnz	fail

	mov	a, #0FFH
	anl	a, #055H
	add	a, #0ABH
	jnz	fail

	mov	a, #0FFH
	anl	a, #0B6H
	anl	a, #023H
	add	a, #0DEH
	jnz	fail

pass:	PASS

fail:	FAIL
