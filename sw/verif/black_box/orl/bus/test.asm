	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test ORL BUS, data.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #000H
	outl	bus, a

	cpl	a
	ins	a, bus
	jnz	fail

	orl	bus, #0AAH
	jnz	fail

	ins	a, bus
	add	a, #056H
	jnz	fail

pass:	PASS

fail:	FAIL
