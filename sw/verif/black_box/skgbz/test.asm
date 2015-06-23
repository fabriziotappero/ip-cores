	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the SKGBZ instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; output 0x0 on G
	x	0x0
	omg
	;; check G0
	skgbz	0x0
	jmp	fail
	;; check G1
	skgbz	0x1
	jmp	fail
	;; check G2
	skgbz	0x2
	jmp	fail
	;; check G3
	skgbz	0x3
	jmp	fail

	;; output 0x1 on G
	clra
	aisc	0x1
	x	0x0
	omg
	;; check G0
	skgbz	0x0
	jmp	ok_0
	jmp	fail
ok_0:
	;; check G1
	skgbz	0x1
	jmp	fail
	;; check G2
	skgbz	0x2
	jmp	fail
	;; check G3
	skgbz	0x3
	jmp	fail

	;; output 0x2 on G
	clra
	aisc	0x2
	x	0x0
	omg
	;; check G0
	skgbz	0x0
	jmp	fail
	;; check G1
	skgbz	0x1
	jmp	ok_1
	jmp	fail
ok_1:
	;; check G2
	skgbz	0x2
	jmp	fail
	;; check G3
	skgbz	0x3
	jmp	fail

	;; output 0x4 on G
	clra
	aisc	0x4
	x	0x0
	omg
	;; check G0
	skgbz	0x0
	jmp	fail
	;; check G1
	skgbz	0x1
	jmp	fail
	;; check G2
	skgbz	0x2
	jmp	ok_2
	jmp	fail
ok_2:
	;; check G3
	skgbz	0x3
	jmp	fail

	;; output 0x1 on G to break monitoring sequence
	;; on T411L
	clra
	aisc	0x1
	x	0x0
	omg

	;; output 0x8 on G
	clra
	aisc	0x8
	x	0x0
	omg
	;; check G0
	skgbz	0x0
	jmp	fail
	;; check G1
	skgbz	0x1
	jmp	fail
	;; check G2
	skgbz	0x2
	jmp	fail
	;; check G3
	skgbz	0x3
	jmp	pass
	jmp	fail

	org	0x100
	include	"pass_fail.asm"
