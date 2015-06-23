	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the XIS instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra


	;; *******************************************************************
	;; XOR 0
	jsr	init_ram

	;; xor 0 in digit 0
	lbi	0, 14
	;;
	cba
	comp
	xis	0		; 0, 0xe = 0x1
	;;
	cba
	comp
	xis	0		; 0, 0xf = 0x0
	jmp	fail

	;; xor 0 in digit 1
	lbi	1, 14
	;;
	cba
	comp
	aisc	1 << 2
	xis	0		; 1, 0xe = 0x5
	;;
	cba
	comp
	aisc	1 << 2
	xis	0		; 1, 0xf = 0x4
	jmp	fail

	;; xor 0 in digit 2
	lbi	2, 14
	;;
	cba
	comp
	aisc	2 << 2
	xis	0		; 2, 0xe = 0x9
	;;
	cba
	comp
	aisc	2 << 2
	xis	0		; 2, 0xf = 0x8
	jmp	fail

	;; xor 0 in digit 3
	lbi	3, 14
	;;
	cba
	comp
	aisc	3 << 2
	xis	0		; 3, 0xe = 0xd
	;;
	cba
	comp
	aisc	3 << 2
	xis	0		; 3, 0xf = 0xc
	jmp	fail

	jsr	check_ram


	;; *******************************************************************
	;; XOR 1
	jsr	init_ram

	;;
	;; xor 1 in digit 0 & 1
	;;
	lbi	0, 14
	;;
	cba
	comp
	xis	1		; 0, 0xe = 0x1
	;;
	cba
	comp
	aisc	1 << 2
	xis	1		; 1, 0xf = 0x4
	jmp	fail
	;; check remaining Br == 0
	clra
	cab
	aisc	0x3		; marker value
	ske
	jmp	fail
	;; reload to Br = 1
	lbi	1, 14
	;;
	cba
	comp
	aisc	1 << 2
	xis	1		; 1, 0xe = 0x5
	;;
	cba
	comp
	xis	1		; 0, 0xf = 0x0
	jmp	fail
	;; check remaining Br == 1
	clra
	cab
	aisc	0x7		; marker value
	ske
	jmp	fail
	jmp	pass

	;;
	;; xor 1 in digit 2 & 3
	;;
	lbi	2, 14
	;;
	cba
	comp
	aisc	2 << 2
	xis	1		; 2, 0xe = 0x9
	;;
	cba
	comp
	aisc	3 << 2
	xis	1		; 3, 0xf = 0xc
	jmp	fail
	;; check remaining Br == 2
	clra
	cab
	aisc	0xb		; marker value
	ske
	jmp	fail
	;; reload to Br = 3
	lbi	3, 14
	;;
	cba
	comp
	aisc	3 << 2
	xis	1		; 3, 0xe = 0xc
	;;
	cba
	comp
	aisc	2 << 2
	xis	1		; 2, 0xf = 0x8
	jmp	fail
	;; check remaining BR == 3
	clra
	cab
	aisc	0xf		; marker value
	ske
	jmp	fail

	jsr	check_ram


	;; *******************************************************************
	;; XOR 2
	jsr	init_ram

	;;
	;; xor 2 in digit 0 & 2
	;;
	lbi	0, 14
	;;
	cba
	comp
	xis	2		; 0, 0xe = 0x1
	;;
	cba
	comp
	aisc	2 << 2
	xis	2		; 2, 0xf = 0x8
	jmp	fail
	;; check remainig Br == 0
	clra
	cab
	aisc	0xb		; marker value
	ske
	jmp	fail
	;; reload to Br == 2
	lbi	2, 14
	;;
	cba
	comp
	aisc	2 << 2
	xis	2		; 2, 0xe = 0x9
	;;
	cba
	comp
	xis	2		; 0, 0xf = 0x0
	jmp	fail
	;; check remainig Br == 2
	clra
	cab
	aisc	0x3		; marker value
	ske
	jmp	fail

	;;
	;; xor 2 in digit 1 & 3
	;;
	lbi	1, 14
	;;
	cba
	comp
	aisc	1 << 2
	xis	2		; 1, 0xe = 0x5
	;;
	cba
	comp
	aisc	3 << 2
	xis	2		; 3, 0xf = 0xc
	jmp	fail
	;; check remaining Br == 1
	clra
	cab
	aisc	0x7		; marker value
	ske
	jmp	fail
	;; reload to Br = 3
	lbi	3, 14
	;;
	cba
	comp
	aisc	3 << 2
	xis	2		; 3, 0xe = 0xd
	;;
	cba
	comp
	aisc	1 << 2
	xis	2		; 1, 0xf = 0x4
	jmp	fail
	;; check remaining Br == 3
	clra
	cab
	aisc	0xf		; marker value
	ske
	jmp	fail

	jsr	check_ram
	
	
	;; *******************************************************************
	;; XOR 3
	jsr	init_ram

	;;
	;; xor 3 in digit 0 & 3
	;;
	lbi	0, 14
	;;
	cba
	comp
	xis	3		; 0, 0xe = 0x1
	;;
	cba
	comp
	aisc	3 << 2
	xis	3		; 3, 0xf = 0xc
	jmp	fail
	;; check remaining BR == 0
	clra
	cab
	aisc	0x3		; marker value
	ske
	jmp	fail
	;; reload BR = 3
	lbi	3, 14
	;;
	cba
	comp
	aisc	3 << 2
	xis	3		; 3, 0xe = 0xd
	;;
	cba
	comp
	xis	3		; 0, 0xf = 0x0
	jmp	fail
	;; check remaining BR == 3
	clra
	cab
	aisc	0xf		; marker value
	ske
	jmp	fail

	;;
	;; xor 3 in digit 1 & 2
	;;
	lbi	1, 14
	;;
	cba
	comp
	aisc	1 << 2
	xis	3		; 1, 0xe = 0x5
	;;
	cba
	comp
	aisc	2 << 2
	xis	3		; 2, 0xf = 0x8
	jmp	fail
	;; check remaining BR == 1
	clra
	cab
	aisc	0x7		; marker value
	ske
	jmp	fail
	;; reload BR = 2
	lbi	2, 14
	;;
	cba
	comp
	aisc	2 << 2
	xis	3		; 2, 0xe = 0x9
	;;
	cba
	comp
	aisc	1 << 2
	xis	3		; 1, 0xf = 0x4
	jmp	fail
	;; check remaining BR == 2
	clra
	cab
	aisc	0xb		; marker value
	ske
	jmp	fail

	jsr	check_ram


	jmp	pass

	
	
	
	org	0x150

	;; preload digits of each data register
init_ram:
	;; Br = 0
	lbi	0, 14
	stii	0x3
	stii	0x2
	stii	0x3		; marker value
	;; Br = 1
	lbi	1, 14
	stii	0x7
	stii	0x6
	stii	0x7		; marker value
	;; Br = 2
	lbi	2, 14
	stii	0xb
	stii	0xa
	stii	0xb		; marker value
	;; Br = 3
	lbi	3, 14
	stii	0xf
	stii	0xe
	stii	0xf		; marker value
	ret


check	MACRO	dig
	;; check dig, 14
	clra
	aisc	0xe
	cab
	comp
	IF	dig > 0
	aisc	dig << 2
	ENDIF
	ske
	jmp	fail
	;; check 0, 15
	clra
	aisc	0xf
	cab
	comp
	IF	dig > 0
	aisc	dig << 2
	ENDIF
	ske
	jmp	fail
	ENDM

	;; check contents of RAM entries
check_ram:
	;; check digit 0
	lbi	0, 0
	check	0

	;; check digit 1
	lbi	1, 0
	check	1

	;; check digit 2
	lbi	2, 0
	check	2

	;; check digit 3
	lbi	3, 0
	check	3

	ret
	
	include	"pass_fail.asm"
