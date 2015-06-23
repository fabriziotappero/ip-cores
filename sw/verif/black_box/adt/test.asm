	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the ADT instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; preload M0 with 0xa
	smb	0x3
	rmb	0x2
	smb	0x1
	rmb	0x0

	;; test 0 + 10
	adt
	ske
	jmp	fail

	;; preload M0 with 0x4
	rmb	0x3
	smb	0x2
	rmb	0x1
	rmb	0x0

	;; test 0xa + 10
	adt
	ske
	jmp	fail


	jmp	pass

	org	0x100
	include	"pass_fail.asm"
