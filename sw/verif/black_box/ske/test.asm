	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the SKE instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; test 0 == 0
	x	0x0
	clra
	ske
	jmp	fail

	;; test 5 == 5
	clra
	aisc	0x5
	x	0x0
	ld	0x0
	ske
	jmp	fail

	;; test a == a
	clra
	aisc	0xa
	x	0x0
	ld	0x0
	ske
	jmp	fail

	;; test f == f
	clra
	aisc	0xf
	x	0x0
	ld	0x0
	ske
	jmp	fail

	;; test 0 == f
	clra
	ske
	jmp	ok_0_ne_f
	jmp	fail

ok_0_ne_f:
	;; test f == 0
	x	0x0
	ske
	jmp	ok_f_ne_0
	jmp	fail

ok_f_ne_0:
	jmp	pass


	org	0x100
	include	"pass_fail.asm"
