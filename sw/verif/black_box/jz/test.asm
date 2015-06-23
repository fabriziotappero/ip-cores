	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test JZ instruction.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #000H
	jz	ok_0
	jmp	fail

ok_0:	mov	a, #001H
	jz	fail

	mov	a, #002H
	jz	fail

	mov	a, #004H
	jz	fail

	mov	a, #008H
	jz	fail

	mov	a, #010H
	jz	fail

	mov	a, #020H
	jz	fail

	mov	a, #040H
	jz	fail

	mov	a, #080H
	jz	fail

pass:	PASS

fail:	FAIL
