	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the ADD instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; preload M0 with 0x1
	rmb	0x3
	rmb	0x2
	rmb	0x1
	smb	0x0

	;; test a0 + m1
	add
	ske
	jmp	fail

	;; test a1 + m1
	add
	aisc	16+1 - 2
	nop
	ske
	jmp	fail

	aisc	2-1
	;; test a2 + m1
	add
	aisc	16+1 - 3
	nop
	ske
	jmp	fail

	aisc	3-1
	;; test a3 + m1
	add
	aisc	16+1 - 4
	nop
	ske
	jmp	fail

	aisc	4-1
	;; test a4 + m1
	add
	aisc	16+1 - 5
	nop
	ske
	jmp	fail

	aisc	5-1
	;; test a5 + m1
	add
	aisc	16+1 - 6
	nop
	ske
	jmp	fail

	aisc	6-1
	;; test a6 + m1
	add
	aisc	16+1 - 7
	nop
	ske
	jmp	fail

	aisc	7-1
	;; test a7 + m1
	add
	aisc	16+1 - 8
	nop
	ske
	jmp	fail

	aisc	8-1
	;; test a8 + m1
	add
	aisc	16+1 - 9
	nop
	ske
	jmp	fail

	aisc	9-1
	;; test a9 + m1
	add
	aisc	16+1 - 10
	nop
	ske
	jmp	fail

	aisc	10-1
	;; test a10 + m1
	add
	aisc	16+1 - 11
	nop
	ske
	jmp	fail

	aisc	11-1
	;; test a11 + m1
	add
	aisc	16+1 - 12
	nop
	ske
	jmp	fail

	aisc	12-1
	;; test a12 + m1
	add
	aisc	16+1 - 13
	nop
	ske
	jmp	fail

	aisc	13-1
	;; test a13 + m1
	add
	aisc	16+1 - 14
	nop
	ske
	jmp	fail

	aisc	14-1
	;; test a14 + m1
	add
	aisc	16+1 - 15
	nop
	ske
	jmp	fail

	aisc	15-1
	;; test a15 + m1
	add
	aisc	16+1 - 16
	nop
	ske
	jmp	fail


	jmp	pass

	org	0x100
	include	"pass_fail.asm"
