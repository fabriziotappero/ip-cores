	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test Program Memory bank selector with interrupts.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0
	jmp	start
	ORG	3
	jmp	interrupt & 07FFH

	ORG	7
	jmp	fail

	;; Start of test
start:
	sel	mb1
	mov	r0, #000H
	en	i
poll:	jf1	goon1
	djnz	r0, poll
	jmp	fail
goon1:

	call	test_mb1 & 07FFH

pass:	PASS

fail:	FAIL

	ORG	0232H
	jmp	fail
interrupt:
	call	trick_mb
	cpl	f1
	retr

	ORG	0250H
trick_mb:
	ret

	ORG	0260H
	jmp	fail


	ORG	0A32H
	jmp	fail_hi
	jmp	fail_hi
	jmp	fail_hi

	ORG	0A50H
	jmp	fail_hi

	ORG	0A60H
test_mb1:
	ret

fail_hi:
	FAIL
