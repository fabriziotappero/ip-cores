	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the OGI instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; output 1 on G
	ogi	0x1

	;; output 2 on G
	ogi	0x2

	;; output 4 on G
	ogi	0x4

	;; output 8 on G
	ogi	0x8

	;; output f on G
	ogi	0xf

	jmp	fail

	org	0x100
	include	"pass_fail.asm"
