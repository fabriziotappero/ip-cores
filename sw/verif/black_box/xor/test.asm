	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the XOR instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; preload M with 5
	aisc	0x5
	x	0x0
	;; preload A with 10
	clra
	aisc	0xa
	;; test a10 xor m5
	xor
	x	0x0
	clra
	aisc	0xf
	ske
	jmp	fail

	;; preload M with 10
	clra
	aisc	0xa
	x	0x0
	;; preload A with 5
	clra
	aisc	0x5
	;; test a5 xor m10
	xor
	x	0x0
	clra
	aisc	0xf
	ske
	jmp	fail

	;; M has 15
	;; preload A with 0
	clra
	;; test a0 xor m15
	xor
	ske
	jmp	fail

	;; preload M with 0
	clra
	x	0x0
	;; A now has 15
	;; test a15 xor m0
	xor
	x	0x0
	clra
	aisc	0xf
	ske
	jmp	fail

	jmp	pass

	org	0x100
	include	"pass_fail.asm"
