	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the LDD instruction.
	;;

	;; the cpu type is defined on asl's command line

	;; macro for checking a digit
check_d	MACRO	reg, digit
	lbi	(reg ! 3), ~digit & 0xf	; select inverse digit
	ldd	reg, digit
	lbi	reg, digit
	ske
	jmp	fail
	ENDM


	;; macro for checking LDD on a complete register
check_r	MACRO	reg
	check_d	reg, 0
	check_d	reg, 1
	check_d	reg, 2
	check_d	reg, 3
	check_d	reg, 4
	check_d	reg, 5
	check_d	reg, 6
	check_d	reg, 7
	check_d	reg, 8
	check_d	reg, 9
	check_d	reg, 10
	check_d	reg, 11
	check_d	reg, 12
	check_d	reg, 13
	check_d	reg, 14
	check_d	reg, 15
	ENDM

	
	org	0x00
	clra


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
	;; Test LDD on register 0
	;;
	lbi	0, 0
	jsr	init_reg
	;;
	check_r	0


	;; *******************************************************************
	;; Test LDD on register 1
	;;
	lbi	0, 0
	jsr	clear_reg
	lbi	1, 0
	jsr	init_reg
	;;
	check_r	1


	;; *******************************************************************
	;; Test LDD on register 2
	;;
	lbi	1, 0
	jsr	clear_reg
	lbi	2, 0
	jsr	init_reg
	;;
	check_r	2

	;; *******************************************************************
	;; Test LDD on register 3
	;;
	lbi	2, 0
	jsr	clear_reg
	lbi	3, 0
	jsr	init_reg
	;;
	check_r	3


	jmp	pass


	
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

	org	0x380
	include	"pass_fail.asm"
