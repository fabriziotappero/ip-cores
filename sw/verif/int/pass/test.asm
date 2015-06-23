	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Pass interrupt test.
	;; Always finds the pass mark when there's an interrupt
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	lei	0x02
	jp	int_mark

	org	0x030
int_mark:
	nop
	nop
	nop
	jmp	fail


	org	0x0ff
	nop
	jmp	pass


	org	0x200
	include	"int_pass_fail.asm"
