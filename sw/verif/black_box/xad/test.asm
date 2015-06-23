	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the XAD instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; *******************************************************************
	;; Dedicated test for XAD 3, 15
	;;
	lbi	0, 9
	stii	0x02
	stii	0x03

	aisc	0x2
	xad	3, 15
	clra
	aisc	0x3

	xad	3, 15
	;; expect 0x2
	lbi	0, 9
	ske
	jmp	fail

	xad	3, 15
	;; expect 0x3
	lbi	0, 10
	ske
	jmp	fail

	IF	MOMCPUNAME = "COP410"
	jmp	pass
	ELSEIF


	;; macro for checking XAD on a complete register
check	MACRO	register
	lbi	register, 0
	ld	0
	xad	register, 1
	xad	register, 2
	xad	register, 3
	xad	register, 4
	xad	register, 5
	xad	register, 6
	xad	register, 7
	xad	register, 8
	xad	register, 9
	xad	register, 10
	xad	register, 11
	xad	register, 12
	xad	register, 13
	xad	register, 14
	xad	register, 15
	xad	register, 0

	clra
	lbi	register, 1
	ske			; expect 0 in digit 1
	jmp	fail
	;;
	aisc	0x1
	lbi	register, 2
	ske			; expect 1 in digit 2
	jmp	fail
	;;
	aisc	0x1
	lbi	register, 3
	ske			; expect 2 in digit 3
	jmp	fail
	;;
	aisc	0x1
	lbi	register, 4
	ske			; expect 3 in digit 4
	jmp	fail
	;;
	aisc	0x1
	lbi	register, 5
	ske			; expect 4 in digit 5
	jmp	fail
	;;
	aisc	0x1
	lbi	register, 6
	ske			; expect 5 in digit 6
	jmp	fail
	;;
	aisc	0x1
	lbi	register, 7
	ske			; expect 6 in digit 7
	jmp	fail
	;;
	aisc	0x1
	lbi	register, 8
	ske			; expect 7 in digit 8
	jmp	fail
	;;
	aisc	0x1
	lbi	register, 9
	ske			; expect 8 in digit 9
	jmp	fail
	;;
	aisc	0x1
	lbi	register, 10
	ske			; expect 9 in digit 10
	jmp	fail
	;;
	aisc	0x1
	lbi	register, 11
	ske			; expect 10 in digit 11
	jmp	fail
	;;
	aisc	0x1
	lbi	register, 12
	ske			; expect 11 in digit 12
	jmp	fail
	;;
	aisc	0x1
	lbi	register, 13
	ske			; expect 12 in digit 13
	jmp	fail
	;;
	aisc	0x1
	lbi	register, 14
	ske			; expect 13 in digit 14
	jmp	fail
	;;
	aisc	0x1
	lbi	register, 15
	ske			; expect 14 in digit 15
	jmp	fail
	;;
	aisc	0x1
	lbi	register, 0
	ske			; expect 15 in digit 0
	jmp	fail
	ENDM

	
	
	;; prepare other registers
	;; register 1
	lbi	1, 0
	jsr	clear_reg
	;; register 2
	lbi	2, 0
	jsr	clear_reg
	;; register 3
	lbi	3, 0
	jsr	clear_reg

	
	;; *******************************************************************
	;; Test XAD on register 0
	;;
	lbi	0, 0
	jsr	init_reg
	;;
	check	0

	
	;; *******************************************************************
	;; Test XAD on register 1
	;;
	lbi	0, 0
	jsr	clear_reg
	lbi	1, 0
	jsr	init_reg
	;;
	check	1

	
	;; *******************************************************************
	;; Test XAD on register 2
	;;
	lbi	1, 0
	jsr	clear_reg
	lbi	2, 0
	jsr	init_reg
	;;
	check	2

	
	;; *******************************************************************
	;; Test XAD on register 3
	;;
	lbi	2, 0
	jsr	clear_reg
	lbi	3, 0
	jsr	init_reg
	;;
	check	3

	
	jmp	pass


	;;
	;; initialize current register with proper values
	;;
init_reg:
	clra
	cab
	stii	0x0
	stii	0x1
	stii	0x2
	stii	0x3
	stii	0x4
	stii	0x5
	stii	0x6
	stii	0x7
	stii	0x8
	stii	0x9
	stii	0xa
	stii	0xb
	stii	0xc
	stii	0xd
	stii	0xe
	stii	0xf
	ret

	;;
	;; clear current register
	;;
clear_reg:
	clra
	cab
	stii	0x0
	stii	0x0
	stii	0x0
	stii	0x0
	stii	0x0
	stii	0x0
	stii	0x0
	stii	0x0
	stii	0x0
	stii	0x0
	stii	0x0
	stii	0x0
	stii	0x0
	stii	0x0
	stii	0x0
	stii	0x0
	ret

	ENDIF

	
	
	include	"pass_fail.asm"
