	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test CLR F1.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	jf1	fail
	cpl	f1
	jf1	ok_1
	jmp	fail

ok_1:	clr	f1
	jf1	fail

pass:	PASS

fail:	FAIL
