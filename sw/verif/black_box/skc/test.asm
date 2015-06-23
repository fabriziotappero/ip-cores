	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the SKC instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	skc
	jmp	ok_no_c
	jmp	fail

ok_no_c:
	sc
	skc
	jmp	fail

	jmp	pass


	org	0x100
	include	"pass_fail.asm"
