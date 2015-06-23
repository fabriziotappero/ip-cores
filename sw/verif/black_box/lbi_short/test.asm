	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the LBI instruction (single byte).
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;;
	;; initialize 4 x 8 RAM digits
	;;

	;; register 0
	stii	0x0
	aisc	0x9
	cab
	stii	0x1
	stii	0x2
	stii	0x3
	stii	0x4
	stii	0x5
	stii	0x6
	stii	0x7

	;; register 1
	ld	0x1
	stii	0x4
	cba
	aisc	0x8
	cab
	stii	0x5
	stii	0x6
	stii	0x7
	stii	0x8
	stii	0x9
	stii	0xa
	stii	0xb

	;; register 2
	ld	0x3
	stii	0x8
	cba
	aisc	0x8
	cab
	stii	0x9
	stii	0xa
	stii	0xb
	stii	0xc
	stii	0xd
	stii	0xe
	stii	0xf

	;; register 3
	ld	0x1
	stii	0xc
	cba
	aisc	0x8
	cab
	stii	0xd
	stii	0xe
	stii	0xf
	stii	0x0
	stii	0x1
	stii	0x2
	stii	0x3

	jmp	test_code


	;; subroutine page 2
	org	0x80
lbi_call_reg0:
	lbi	0, 0
	lbi	0, 9
	lbi	0, 10
	lbi	0, 11
	lbi	0, 12
	lbi	0, 13
	lbi	0, 14
	lbi	0, 15
	ret
lbi_call_reg1:
	lbi	1, 0
	lbi	1, 9
	lbi	1, 10
	lbi	1, 11
	lbi	1, 12
	lbi	1, 13
	lbi	1, 14
	lbi	1, 15
	ret
lbi_call_reg2:
	lbi	2, 0
	lbi	2, 9
	lbi	2, 10
	lbi	2, 11
	lbi	2, 12
	lbi	2, 13
	lbi	2, 14
	lbi	2, 15
	ret
lbi_call_reg3:
	lbi	3, 0
	lbi	3, 9
	lbi	3, 10
	lbi	3, 11
	lbi	3, 12
	lbi	3, 13
	lbi	3, 14
	lbi	3, 15
	ret


	org	0x100

	;;
	;; now test each register digit
	;;
test_code:

	;; register 0
	;; digit 0
	clra
	jsrp	lbi_call_reg0 + 0
	ske
	jmp	fail
	;; digit 9
	aisc	0x1
	jsrp	lbi_call_reg0 + 1
	ske
	jmp	fail
	;; digit 10
	aisc	0x1
	jsrp	lbi_call_reg0 + 2
	ske
	jmp	fail
	;; digit 11
	aisc	0x1
	jsrp	lbi_call_reg0 + 3
	ske
	jmp	fail
	;; digit 12
	aisc	0x1
	jsrp	lbi_call_reg0 + 4
	ske
	jmp	fail
	;; digit 13
	aisc	0x1
	jsrp	lbi_call_reg0 + 5
	ske
	jmp	fail
	;; digit 14
	aisc	0x1
	jsrp	lbi_call_reg0 + 6
	ske
	jmp	fail
	;; digit 15
	aisc	0x1
	jsrp	lbi_call_reg0 + 7
	ske
	jmp	fail

	;; register 1
	;; digit 0
	clra
	aisc	 0x4
	jsrp	lbi_call_reg1 + 0
	ske
	jmp	fail
	;; digit 9
	aisc	0x1
	jsrp	lbi_call_reg1 + 1
	ske
	jmp	fail
	;; digit 10
	aisc	0x1
	jsrp	lbi_call_reg1 + 2
	ske
	jmp	fail
	;; digit 11
	aisc	0x1
	jsrp	lbi_call_reg1 + 3
	ske
	jmp	fail
	;; digit 12
	aisc	0x1
	jsrp	lbi_call_reg1 + 4
	ske
	jmp	fail
	;; digit 13
	aisc	0x1
	jsrp	lbi_call_reg1 + 5
	ske
	jmp	fail
	;; digit 14
	aisc	0x1
	jsrp	lbi_call_reg1 + 6
	ske
	jmp	fail
	;; digit 15
	aisc	0x1
	jsrp	lbi_call_reg1 + 7
	ske
	jmp	fail

	;; register 2
	;; digit 0
	clra
	aisc	0x8
	jsrp	lbi_call_reg2 + 0
	ske
	jmp	fail
	;; digit 9
	aisc	0x1
	jsrp	lbi_call_reg2 + 1
	ske
	jmp	fail
	;; digit 10
	aisc	0x1
	jsrp	lbi_call_reg2 + 2
	ske
	jmp	fail
	;; digit 11
	aisc	0x1
	jsrp	lbi_call_reg2 + 3
	ske
	jmp	fail
	;; digit 12
	aisc	0x1
	jsrp	lbi_call_reg2 + 4
	ske
	jmp	fail
	;; digit 13
	aisc	0x1
	jsrp	lbi_call_reg2 + 5
	ske
	jmp	fail
	;; digit 14
	aisc	0x1
	jsrp	lbi_call_reg2 + 6
	ske
	jmp	fail
	;; digit 15
	aisc	0x1
	jsrp	lbi_call_reg2 + 7
	ske
	jmp	fail

	;; register 3
	;; digit 0
	clra
	aisc	0xc
	jsrp	lbi_call_reg3 + 0
	ske
	jmp	fail
	;; digit 9
	aisc	0x1
	jsrp	lbi_call_reg3 + 1
	ske
	jmp	fail
	;; digit 10
	aisc	0x1
	jsrp	lbi_call_reg3 + 2
	ske
	jmp	fail
	;; digit 11
	aisc	0x1
	jsrp	lbi_call_reg3 + 3
	ske
	jmp	fail
	;; digit 12
	aisc	0x1
	nop
	jsrp	lbi_call_reg3 + 4
	ske
	jmp	fail
	;; digit 13
	aisc	0x1
	jsrp	lbi_call_reg3 + 5
	ske
	jmp	fail
	;; digit 14
	aisc	0x1
	jsrp	lbi_call_reg3 + 6
	ske
	jmp	fail
	;; digit 15
	aisc	0x1
	jsrp	lbi_call_reg3 + 7
	ske
	jmp	fail


	jmp	pass

	include	"pass_fail.asm"
