	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test ANL BUS, data.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #0FFH
	outl	bus, a

	clr	a
	ins	a, bus
	inc	a
	jnz	fail

	anl	bus, #0AAH
	jnz	fail

	ins	a, bus
	add	a, #056H
	jnz	fail

pass:	PASS

fail:	FAIL
