	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the RC and SC instructions.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; preload M with 0x8
	smb	0x3
	rmb	0x2
	rmb	0x1
	rmb	0x0

	;; check initial value of C
	skc
	jmp	ok_res
	jmp	fail
ok_res:

	sc
	skc
	jmp	fail

	rc
	skc
	jmp	ok_rc
	jmp	fail
ok_rc:

	asc
	asc
	nop
	skc
	jmp	fail

	rc
	skc
	jmp	pass
	jmp	fail

	org	0x100
	include	"pass_fail.asm"
