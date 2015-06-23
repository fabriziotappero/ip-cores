	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test wrap-around of Program Counter on bits 10 - 0.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test

	;; decide whether this is the first time that the test
	;; executes from address 0
	in	a, P1
	jnz	first_time

	;; came here for the second time
	;; -> that's great!
	jmp	pass

first_time:
	clr	a
	outl	P1, a		; tag P1 -> lock this path
	;; jump to external Program Memory
	jmp	end_of_first_2k

pass:	PASS

fail:	FAIL


	;; end of first 2k program memory
	ORG	07FEH
end_of_first_2k:
	nop
	nop
	;; no wrap-around to address 0


	ORG	0800H

	jmp	fail

