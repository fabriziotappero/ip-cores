	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the ASC instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; preload M with 0x5
	rmb	0x3
	smb	0x2
	rmb	0x1
	smb	0x0

	clra
	rc
	;; test a0 + m5 + c0
	asc
	jmp	ok_a0_m5_c0_carry
	jmp	fail
ok_a0_m5_c0_carry:
	skc
	jmp	ok_a0_m5_c0_c
	jmp	fail
ok_a0_m5_c0_c:
	ske
	jmp	fail

	;; test a5 + m5 + c0
	asc
	jmp	ok_a5_m5_c0_carry
	jmp	fail
ok_a5_m5_c0_carry:
	skc
	jmp	ok_a5_m5_c0_c
	jmp	fail
ok_a5_m5_c0_c:
	aisc	16+5 - 10
	nop
	ske
	jmp	fail

	rc
	asc
	;; test a10 + m5 + c0
	asc
	jmp	ok_a10_m5_c0_carry
	jmp	fail
ok_a10_m5_c0_carry:
	skc
	jmp	ok_a10_m5_c0_c
	jmp	fail
ok_a10_m5_c0_c:
	aisc	16+5 - 15
	nop
	ske
	jmp	fail

	rc
	asc
	asc
	;; test a15 + m5 + c0
	asc
	jmp	fail
	skc
	jmp	fail
	rc
	aisc	16+5 - 20
	nop
	ske
	jmp	fail

	sc
	clra
	;; test a0 + m5 + c1
	asc
	jmp	ok_a0_m5_c1_carry
	jmp	fail
ok_a0_m5_c1_carry:
	skc
	jmp	ok_a0_m5_c1_c
	jmp	fail
ok_a0_m5_c1_c:
	aisc	16+5 - 6
	nop
	ske
	jmp	fail

	sc
	;; test a5 + m5 + c1
	asc
	jmp	ok_a5_m5_c1_carry
	jmp	fail
ok_a5_m5_c1_carry:
	skc
	jmp	ok_a5_m5_c1_c
	jmp	fail
ok_a5_m5_c1_c:
	aisc	16+5 - 11
	nop
	ske
	jmp	fail

	rc
	asc
	sc
	;; test a10 + m5 + c1
	asc
	jmp	fail
	skc
	jmp	fail
	aisc	16+5 - 16
	nop
	ske
	jmp	fail

	rc
	asc
	asc
	sc
	;; test a15 + m5 + c1
	asc
	jmp	fail
	skc
	jmp	fail
	;; aisc	16+5 - 21
	nop
	ske
	jmp	fail


	rc
	aisc	0xa
	x	0x0
	clra
	;; test a0 + m15 + c0
	asc
	jmp	ok_a0_m15_c0_carry
	jmp	fail
ok_a0_m15_c0_carry:
	skc
	jmp	ok_a0_m15_c0_c
	jmp	fail
ok_a0_m15_c0_c:
	ske
	jmp	fail

	rc
	;; test a15 + m15 + c0
	asc
	jmp	fail
	skc
	jmp	fail
	aisc	16+15 - 30
	nop
	ske
	jmp	fail

	sc
	clra
	;; test a0 + m15 + c1
	asc
	jmp	fail
	skc
	jmp	fail
	aisc	16+15 - 16
	nop
	ske
	jmp	fail

	sc
	;; test a15 + m15 + c1
	asc
	jmp	fail
	skc
	jmp	fail
	;; aisc	16+15 - 31
	nop
	ske
	jmp	fail


	jmp	pass

	org	0x100
	include	"pass_fail.asm"
