	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the CLRA instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; preload M0 with 0x0
	rmb	0x3
	rmb	0x2
	rmb	0x1
	rmb	0x0

	;; test for initial 0 in a
	ske
	jmp	fail

	;; test for clearing all bits in a
	aisc	0xf
	clra
	ske
	jmp	fail

	jmp	pass

	org	0x100
	include	"pass_fail.asm"
