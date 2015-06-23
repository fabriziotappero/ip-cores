	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test the JBb instruction on 0AAH.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #0AAH
	jb0	fail

	jb1	ok_1
	jmp	fail

ok_1:	jb2	fail

	jb3	ok_3
	jmp	fail

ok_3:	jb4	fail

	jb5	ok_5
	jmp	fail

ok_5:	jb6	fail

	jb7	pass

fail:	FAIL

pass:	PASS
