	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	jmp	start


start:
	call	test_code
	sel	mb0


pass:	PASS

fail:	FAIL
	
	

	ORG	0400H
test_code:
	;; write to P2
	mov	a, #089h
	outl	p2, a

	;; use expander
	mov	a, #00ch
	movd	p5, a

	;; write to P2
	mov	a, #098h
	outl	p2, a

	;; use expander
	movd	a, p6

	ret
