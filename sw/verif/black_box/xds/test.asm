	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the XDS instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra


	;; *******************************************************************
	;; XOR 0
	jsr	init_ram

	;; xor 0 in digit 0
	lbi	0, 0
	jsr	init_bd
	;;
	xds	0		; 0, 3 = 0x3
	;;
	cba
	xds	0		; 0, 2 = 0x2
	;;
	cba
	xds	0		; 0, 1 = 0x1
	;;
	cba
	xds	0		; 0, 0 = 0x0
	jmp	fail

	;; xor 0 in digit 1
	lbi	1, 0
	jsr	init_bd
	;;
	aisc	1 << 2
	xds	0		; 1, 3 = 0x7
	;;
	cba
	aisc	1 << 2
	xds	0		; 1, 2 = 0x6
	;;
	cba
	aisc	1 << 2
	xds	0		; 1, 1 = 0x5
	;;
	cba
	aisc	1 << 2
	xds	0		; 1, 0 = 0x4
	jmp	fail

	;; xor 0 in digit 2
	lbi	2, 0
	jsr	init_bd
	;;
	aisc	2 << 2
	xds	0		; 2, 3 = 0xb
	;;
	cba
	aisc	2 << 2
	xds	0		; 2, 2 = 0xa
	;;
	cba
	aisc	2 << 2
	xds	0		; 2, 1 = 0x9
	;;
	cba
	aisc	2 << 2
	xds	0		; 2, 0 = 0x8
	jmp	fail

	;; xor 0 in digit 3
	lbi	3, 0
	jsr	init_bd
	;;
	aisc	3 << 2
	xds	0		; 3, 3 = 0xf
	;;
	cba
	aisc	3 << 2
	xds	0		; 3, 2 = 0xe
	;;
	cba
	aisc	3 << 2
	xds	0		; 3, 1 = 0xd
	;;
	cba
	aisc	3 << 2
	xds	0		; 3, 0 = 0xc
	jmp	fail
	;; check remaining Br == 3
	clra
	cab
	aisc	0xc
	ske
	jmp	fail

	jsr	check_ram


	;; *******************************************************************
	;; XOR 1
	jsr	init_ram

	;;
	;; xor 1 in digit 0 & 1
	;;
	lbi	0, 0
	jsr	init_bd
	;;
	xds	1		; 0, 3 = 0x3
	;;
	cba
	aisc	1 << 2
	xds	1		; 1, 2 = 0x6
	;;
	cba
	xds	1		; 0, 1 = 0x1
	;;
	cba
	aisc	1 << 2
	xds	1		; 1, 0 = 0x4
	jmp	fail
	;; check remaining Br == 0
	clra
	cab
	aisc	0xf		; RAM init value
	ske
	jmp	fail
	;; reload to Br = 1
	lbi	1, 0
	jsr	init_bd
	;;
	aisc	1 << 2
	xds	1		; 1, 3 = 0x7
	;;
	cba
	xds	1		; 0, 2 = 0x2
	;;
	cba
	aisc	1 << 2
	xds	1		; 1, 1 = 0x5
	;;
	cba
	xds	1		; 0, 0 = 0x0
	jmp	fail
	;; check remaining Br == 1
	clra
	cab
	aisc	0x4
	ske
	jmp	fail

	;;
	;; xor 1 in digit 2 & 3
	;;
	lbi	2, 0
	jsr	init_bd
	;;
	aisc	2 << 2
	xds	1		; 2, 3 = 0xb
	;;
	cba
	aisc	3 << 2
	xds	1		; 3, 2 = 0xe
	;;
	cba
	aisc	2 << 2
	xds	1		; 2, 1 = 0x9
	;;
	cba
	aisc	3 << 2
	xds	1		; 3, 0 = 0xc
	jmp	fail
	;; check remaining Br == 2
	clra
	cab
	aisc	0x7		; RAM init value
	ske
	jmp	fail
	;; reload to Br = 3
	lbi	3, 0
	jsr	init_bd
	;;
	aisc	3 << 2
	xds	1		; 3, 3 = 0xf
	;;
	cba
	aisc	2 << 2
	xds	1		; 2, 2 = 0xa
	;;
	cba
	aisc	3 << 2
	xds	1		; 3, 1 = 0xd
	;;
	cba
	aisc	2 << 2
	xds	1		; 2, 0 = 0x8
	jmp	fail
	;; check remaining Br == 3
	clra
	cab
	aisc	0xc
	ske
	jmp	fail

	jsr	check_ram


	;; *******************************************************************
	;; XOR 2
	jsr	init_ram

	;;
	;; xor 2 in digit 0 & 2
	;;
	lbi	0, 0
	jsr	init_bd
	;;
	xds	2		; 0, 3 = 0x3
	;;
	cba
	aisc	2 << 2
	xds	2		; 2, 2 = 0xa
	;;
	cba
	xds	2		; 0, 1 = 0x1
	;;
	cba
	aisc	2 << 2
	xds	2		; 2, 0 = 0x8
	jmp	fail
	;; check remainig Br == 0
	clra
	cab
	aisc	0xf		; RAM init value
	ske
	jmp	fail
	;; reload to Br == 2
	lbi	2, 0
	jsr	init_bd
	;;
	aisc	2 << 2
	xds	2		; 2, 3 = 0xb
	;;
	cba
	xds	2		; 0, 2 = 0x2
	;;
	cba
	aisc	2 << 2
	xds	2		; 2, 1 = 0x9
	;;
	cba
	xds	2		; 0, 0 = 0x0
	jmp	fail
	;; check remainig Br == 2
	clra
	cab
	aisc	0x8
	ske
	jmp	fail

	;;
	;; xor 2 in digit 1 & 3
	;;
	lbi	1, 0
	jsr	init_bd
	;;
	aisc	1 << 2
	xds	2		; 1, 3 = 0x7
	;;
	cba
	aisc	3 << 2
	xds	2		; 3, 2 = 0xe
	;;
	cba
	aisc	1 << 2
	xds	2		; 1, 1 = 0x5
	;;
	cba
	aisc	3 << 2
	xds	2		; 3, 0 = 0xc
	jmp	fail
	;; check remaining Br == 1
	clra
	cab
	aisc	0xc		; RAM init value
	ske
	jmp	fail
	;; reload to Br = 3
	lbi	3, 0
	jsr	init_bd
	;;
	aisc	3 << 2
	xds	2		; 3, 3 = 0xf
	;;
	cba
	aisc	1 << 2
	xds	2		; 1, 2 = 0x6
	;;
	cba
	aisc	3 << 2
	xds	2		; 3, 1 = 0xd
	;;
	cba
	aisc	1 << 2
	xds	2		; 1, 0 = 0x4
	jmp	fail
	;; check remaining Br == 3
	clra
	cab
	aisc	0xc
	ske
	jmp	fail

	jsr	check_ram
	
	
	;; *******************************************************************
	;; XOR 3
	jsr	init_ram

	;;
	;; xor 3 in digit 0 & 3
	;;
	lbi	0, 0
	jsr	init_bd
	;;
	xds	3		; 0, 3 = 0x3
	;;
	cba
	aisc	3 << 2
	xds	3		; 3, 2 = 0xe
	;;
	cba
	xds	3		; 0, 1 = 0x1
	;;
	cba
	aisc	3 << 2
	xds	3		; 3, 0 = 0xc
	jmp	fail
	;; check remaining BR == 0
	clra
	cab
	aisc	0xf		; RAM init value
	ske
	jmp	fail
	;; reload BR = 3
	lbi	3, 0
	jsr	init_bd
	;;
	aisc	3 << 2
	xds	3		; 3, 3 = 0xf
	;;
	cba
	xds	3		; 0, 2 = 0x2
	;;
	cba
	aisc	3 << 2
	xds	3		; 3, 1 = 0xb
	;;
	cba
	xds	3		; 0, 0 = 0x0
	jmp	fail
	;; check remaining BR == 3
	clra
	cab
	aisc	0xc
	ske
	jmp	fail

	;;
	;; xor 3 in digit 1 & 2
	;;
	lbi	1, 0
	jsr	init_bd
	;;
	aisc	1 << 2
	xds	3		; 1, 3 = 0x7
	;;
	cba
	aisc	2 << 2
	xds	3		; 2, 2 = 0xa
	;;
	cba
	aisc	1 << 2
	xds	3		; 1, 1 = 0x5
	;;
	cba
	aisc	2 << 2
	xds	3		; 2, 0 = 0x8
	jmp	fail
	;; check remaining BR == 1
	clra
	cab
	aisc	0xc		; RAM init value
	ske
	jmp	fail
	;; reload BR = 2
	lbi	2, 0
	jsr	init_bd
	;;
	aisc	2 << 2
	xds	3		; 2, 3 = 0xb
	;;
	cba
	aisc	1 << 2
	xds	3		; 1, 2 = 0x6
	;;
	cba
	aisc	2 << 2
	xds	3		; 2, 1 = 0x9
	;;
	cba
	aisc	1 << 2
	xds	3		; 1, 0 = 0x5
	jmp	fail
	;; check remaining BR == 2
	clra
	cab
	aisc	0x8
	ske
	jmp	fail

	jsr	check_ram


	jmp	pass

	
	
	
	org	0x158

	;; initializes Bd to 3
init_bd:
	clra
	aisc	0x3
	cab
	ret


	;; preload digits of each data register
init_ram:
	;; Br = 0
	lbi	0, 0
	stii	0xf
	stii	0xe
	stii	0xd
	stii	0xb
	;; Br = 1
	lbi	1, 0
	stii	0xc
	stii	0xa
	stii	0x9
	stii	0x8
	;; Br = 2
	lbi	2, 0
	stii	0x7
	stii	0x6
	stii	0x5
	stii	0x4
	;; Br = 3
	lbi	3, 0
	stii	0x3
	stii	0x2
	stii	0x1
	stii	0x0
	ret


check	MACRO	dig
	;; check dig, 0
	clra
	IF	dig > 0
	aisc	dig << 2
	ENDIF
	ske
	jmp	fail
	;; check 0, 1
	clra
	aisc	0x1
	cab
	IF	dig > 0
	aisc	dig << 2
	ENDIF
	ske
	jmp	fail
	;; check 0, 2
	clra
	aisc	0x2
	cab
	IF	dig > 0
	aisc	dig << 2
	ENDIF
	ske
	jmp	fail
	;; check 0, 3
	clra
	aisc	0x3
	cab
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
