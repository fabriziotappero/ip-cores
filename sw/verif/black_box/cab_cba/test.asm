	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the CAB & CBA instructions.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; preload data memory with mismtach values
	stii	0xf
	stii	0xe
	stii	0xd
	stii	0xc
	stii	0xb
	stii	0xa
	stii	0x9
	stii	0x8
	stii	0x7
	stii	0x6
	stii	0x5
	stii	0x4
	stii	0x3
	stii	0x2
	stii	0x1
	stii	0x0

	;; test value 0
	cab
	x	0x0
	cba
	ske
	jmp	fail

	;; test value 1
	clra
	aisc	0x1
	nop
	cab
	x	0x0
	cba
	ske
	jmp	fail

	;; test value 2
	clra
	aisc	0x2
	nop
	cab
	x	0x0
	cba
	ske
	jmp	fail

	;; test value 3
	clra
	aisc	0x3
	nop
	cab
	x	0x0
	cba
	ske
	jmp	fail

	;; test value 4
	clra
	aisc	0x4
	nop
	cab
	x	0x0
	cba
	ske
	jmp	fail

	;; test value 5
	clra
	aisc	0x5
	nop
	cab
	x	0x0
	cba
	ske
	jmp	fail

	;; test value 6
	clra
	aisc	0x6
	nop
	cab
	x	0x0
	cba
	ske
	jmp	fail

	;; test value 7
	clra
	aisc	0x7
	nop
	cab
	x	0x0
	cba
	ske
	jmp	fail

	;; test value 8
	clra
	aisc	0x8
	nop
	cab
	x	0x0
	cba
	ske
	jmp	fail

	;; test value 9
	clra
	aisc	0x9
	nop
	cab
	x	0x0
	cba
	ske
	jmp	fail

	;; test value 10
	clra
	aisc	0xa
	nop
	cab
	x	0x0
	cba
	ske
	jmp	fail

	;; test value 11
	clra
	aisc	0xb
	nop
	cab
	x	0x0
	cba
	ske
	jmp	fail

	;; test value 12
	clra
	aisc	0xc
	nop
	cab
	x	0x0
	cba
	ske
	jmp	fail

	;; test value 13
	clra
	aisc	0xd
	nop
	cab
	x	0x0
	cba
	ske
	jmp	fail

	;; test value 14
	clra
	aisc	0xe
	nop
	cab
	x	0x0
	cba
	ske
	jmp	fail

	;; test value 15
	clra
	aisc	0xf
	nop
	cab
	x	0x0
	cba
	ske
	jmp	fail


	jmp	pass


	org	0x100
	include	"pass_fail.asm"
