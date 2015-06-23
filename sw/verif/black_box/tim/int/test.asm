	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test Timer Interrupt.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0
	jmp	start
	nop
	jmp	fail
	jmp	fail
	jmp	timer_int
	jmp	fail

	;; Start of test
start:	mov	a, #0F8H
	mov	t, a
	clr	a
	mov	r0, a
	mov	r1, a

	en	tcnti
	jtf	fail

	strt	t

loop:	mov	a, r0
	jnz	pass
	djnz	r1, loop

fail:	FAIL

pass:	PASS


timer_int:
	mov	r0, #0FFH
	retr
