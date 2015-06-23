	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Pass test.
	;; Always finds the pass mark.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	jmp	pass


	org	0x0c0
	include	"pass_fail.asm"
