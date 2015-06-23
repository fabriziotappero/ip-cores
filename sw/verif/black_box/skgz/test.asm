	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the SKGZ instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; output 0x1 on G
	aisc	0x1
	x	0x0
	omg
	;; check no skip on 0x1
	skgz
	jmp	ok_1
	jmp	fail
ok_1:

	;; output 0x2 on G
	clra
	aisc	0x2
	x	0x0
	omg
	;; check no skip on 0x2
	skgz
	jmp	ok_2
	jmp	fail
ok_2:

	;; output 0x4 on G
	clra
	aisc	0x4
	x	0x0
	omg
	;; check no skip on 0x4
	skgz
	jmp	ok_4
	jmp	fail
ok_4:

	;; output 0x1 on G to break G monitoring sequence
	clra
	aisc	0x1
	x	0x0
	omg

	;; output 0x8 on G
	clra
	aisc	0x8
	x	0x0
	omg
	;; check no skip on 0x8
	skgz
	jmp	ok_8
	jmp	fail
ok_8:


	;; output 0x0 on G
	clra
	x	0x0
	omg
	;; check skip on 0x0
	skgz
	jmp	fail
	jmp	pass

	org	0x100
	include	"pass_fail.asm"
