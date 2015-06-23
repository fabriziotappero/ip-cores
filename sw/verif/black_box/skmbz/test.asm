	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the SKGMZ instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; preload two ram digits with test data
	lbi	0, 0
	stii	0x5
	lbi	0, 9
	stii	0xa

	;; check SKBMZs on 0x5
	lbi	0, 0
	skmbz	0
	jp	ok_5_0
	jmp	fail
ok_5_0:
	skmbz	1
	jmp	fail
	skmbz	2
	jp	ok_5_2
	jmp	fail
ok_5_2:
	skmbz	3
	jmp	fail

	;; check SKMBZ on 0xa
	lbi	0, 9
	skmbz	0
	jmp	fail
	skmbz	1
	jp	ok_a_1
	jmp	fail
ok_a_1:
	skmbz	2
	jmp	fail
	skmbz	3
	jp	ok_a_3
	jmp	fail
ok_a_3:

	jmp	pass

	org	0x100
	include	"pass_fail.asm"
