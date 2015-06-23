	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test a simple jump to interrupt.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	jmp	start_user


	ORG	3
	jmp	pass


	ORG	010H
start_user:
	en	i
	mov	r0, #080H
loop:	djnz	r0, loop

fail:	FAIL

pass:	PASS
