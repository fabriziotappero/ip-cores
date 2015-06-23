	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the CASC instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; preload M0 with 0x5
	rmb	0x3
	smb	0x2
	rmb	0x1
	smb	0x0

	rc
	aisc	0xf
	;; test /(a15) + m5 + c0
	casc
	jmp	ok_a15_m5_c0_carry
	jmp	fail
ok_a15_m5_c0_carry:
	skc
	jmp	ok_a15_m5_c0_c
	jmp	fail
ok_a15_m5_c0_c:
	;; expect 0x5 as result
	ske
	jmp	fail

	sc
	clra
	aisc	0xa
	;; test /(a10) + m5 + c1
	casc
	jmp	ok_a10_m5_c1_carry
	jmp	fail
ok_a10_m5_c1_carry:
	skc
	jmp	ok_a10_m5_c1_c
	jmp	fail
ok_a10_m5_c1_c:
	;; expect 0xb as result
	aisc	0xa
	nop
	ske
	jmp	fail

	;; preload M0 with 0xa
	smb	0x3
	rmb	0x2
	smb	0x1
	rmb	0x0
	;;
	rc
	clra
	aisc	0x5
	;; test /(a5) + m10 + c0
	casc
	jmp	fail
	skc
	jmp	fail
	;; expect 0x4 as result
	aisc	0x6
	ske
	jmp	fail

	;; preload M0 with 0xf
	smb	0x3
	smb	0x2
	smb	0x1
	smb	0x0
	;;
	sc
	clra
	;; test /(a0) + m15 + c1
	casc
	jmp	fail
	skc
	jmp	fail
	;; expect 0xf as result
	ske
	jmp	fail


	jmp	pass

	org	0x100
	include	"pass_fail.asm"
