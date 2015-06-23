	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test CPL F0.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	jf0	fail
	cpl	f0
	jf0	ok_1
	jmp	fail

ok_1:	cpl	f0
	jf0	fail

pass:	PASS

fail:	FAIL
