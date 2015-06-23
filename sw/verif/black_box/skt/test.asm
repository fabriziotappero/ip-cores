	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the SKT instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; timer not elapsed right after power-on reset
	skt
	jp	ok_1
	jmp	fail
ok_1:


	;; preload timeout value
	stii	0x4
	stii	0x0
	stii	0x0

	;; *******************************************************************
	;; Poll for timer flag with and time out after a while.
	;;
poll_loop:
	;; decrement timeout counter
	lbi	0, 2
	sc
	clra
	aisc	0x1
	casc			; M(0, 2) - 1
	jp	proc_digit_1
	x	0
	jp	dec_finished

proc_digit_1:
	xds	0		; A loads 0 from M
	sc
	aisc	0x1
	casc			; M(0, 1) - 1
	jp	proc_digit_0
	x	0
	jp	dec_finished

proc_digit_0:
	xds	0		; A loads 0 from M
	sc
	aisc	0x1
	casc			; M(0, 0) - 1
	jmp	fail		; TIMEOUT!
	x	0
dec_finished:

	;; poll timer flag
	skt
	jp	poll_loop

	;; check that last skt cleared the flag
	skt
	jp	ok_2
	jmp	fail
ok_2:


	jmp	pass

	include	"pass_fail.asm"
