	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the ININ instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; preload reference data
	stii	0x0
	stii	0x1
	stii	0x2
	stii	0x3
	stii	0x4
	stii	0x5
	stii	0x6
	stii	0x7
	stii	0x8
	stii	0x9
	stii	0xa
	stii	0xb
	stii	0xc
	stii	0xd
	stii	0xe
	stii	0xf

	;; output 0 on G and check
	ogi	0x0
	inin
	lbi	0, 0
	ske
	jmp	fail

	;; output 8 on G and check
	ogi	0x8
	inin
	lbi	0, 8
	ske
	jmp	fail

	;; output 1 on G and check
	ogi	0x1
	inin
	lbi	0, 1
	ske
	jmp	fail

	;; output 4 on G and check
	ogi	0x4
	inin
	lbi	0, 4
	ske
	jmp	fail

	;; output 15 on G and check
	ogi	0xf
	inin
	lbi	0, 15
	ske
	jmp	fail



	jmp	pass


	org	0x100	
	include	"pass_fail.asm"
