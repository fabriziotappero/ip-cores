	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the LBI instruction (two byte).
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; register 0
	ld	0x0
	jsr	clear_reg
	;; register 1
	ld	0x1
	jsr	clear_reg
	;; register 2
	ld	0x3
	jsr	clear_reg
	;; register 3
	ld	0x1
	jsr	clear_reg

	jmp	test_code


	;; subroutines for combined long LBI
	org	0x010
lbi_call_reg0:
	db	0x33, 0x80	; lbi	0, 0
	db	0x33, 0x81	; lbi	0, 1
	db	0x33, 0x82	; lbi	0, 2
	db	0x33, 0x83	; lbi	0, 3
	db	0x33, 0x84	; lbi	0, 4
	db	0x33, 0x85	; lbi	0, 5
	db	0x33, 0x86	; lbi	0, 6
	db	0x33, 0x87	; lbi	0, 7
	db	0x33, 0x88	; lbi	0, 8
	db	0x33, 0x89	; lbi	0, 9
	db	0x33, 0x8a	; lbi	0, 10
	db	0x33, 0x8b	; lbi	0, 11
	db	0x33, 0x8c	; lbi	0, 12
	db	0x33, 0x8d	; lbi	0, 13
	db	0x33, 0x8e	; lbi	0, 14
	db	0x33, 0x8f	; lbi	0, 15
	ret
	jmp	fail		; catch me if you can
lbi_call_reg1:
	db	0x33, 0x90	; lbi	1, 0
	db	0x33, 0x91	; lbi	1, 1
	db	0x33, 0x92	; lbi	1, 2
	db	0x33, 0x93	; lbi	1, 3
	db	0x33, 0x94	; lbi	1, 4
	db	0x33, 0x95	; lbi	1, 5
	db	0x33, 0x96	; lbi	1, 6
	db	0x33, 0x97	; lbi	1, 7
	db	0x33, 0x98	; lbi	1, 8
	db	0x33, 0x99	; lbi	1, 9
	db	0x33, 0x9a	; lbi	1, 10
	db	0x33, 0x9b	; lbi	1, 11
	db	0x33, 0x9c	; lbi	1, 12
	db	0x33, 0x9d	; lbi	1, 13
	db	0x33, 0x9e	; lbi	1, 14
	db	0x33, 0x9f	; lbi	1, 15
	ret
	jmp	fail		; catch me if you can
lbi_call_reg2:
	db	0x33, 0xa0	; lbi	2, 0
	db	0x33, 0xa1	; lbi	2, 1
	db	0x33, 0xa2	; lbi	2, 2
	db	0x33, 0xa3	; lbi	2, 3
	db	0x33, 0xa4	; lbi	2, 4
	db	0x33, 0xa5	; lbi	2, 5
	db	0x33, 0xa6	; lbi	2, 6
	db	0x33, 0xa7	; lbi	2, 7
	db	0x33, 0xa8	; lbi	2, 8
	db	0x33, 0xa9	; lbi	2, 9
	db	0x33, 0xaa	; lbi	2, 10
	db	0x33, 0xab	; lbi	2, 11
	db	0x33, 0xac	; lbi	2, 12
	db	0x33, 0xad	; lbi	2, 13
	db	0x33, 0xae	; lbi	2, 14
	db	0x33, 0xaf	; lbi	2, 15
	ret
	jmp	fail		; catch me if you can
lbi_call_reg3:
	db	0x33, 0xb0	; lbi	3, 0
	db	0x33, 0xb1	; lbi	3, 1
	db	0x33, 0xb2	; lbi	3, 2
	db	0x33, 0xb3	; lbi	3, 3
	db	0x33, 0xb4	; lbi	3, 4
	db	0x33, 0xb5	; lbi	3, 5
	db	0x33, 0xb6	; lbi	3, 6
	db	0x33, 0xb7	; lbi	3, 7
	db	0x33, 0xb8	; lbi	3, 8
	db	0x33, 0xb9	; lbi	3, 9
	db	0x33, 0xba	; lbi	3, 10
	db	0x33, 0xbb	; lbi	3, 11
	db	0x33, 0xbc	; lbi	3, 12
	db	0x33, 0xbd	; lbi	3, 13
	db	0x33, 0xbe	; lbi	3, 14
	db	0x33, 0xbf	; lbi	3, 15
	ret
	jmp	fail		; catch me if you can


	;;
	;; now test each register digit
	;;
test_code:

	;; *******************************************************************
	;; register 0
	;;
	;; initialize all digits of register
	;;
	ld	0x3		; r: 3 -> 0
	jsr	init_reg

	
	;; digit 0
	clra
	jsr	lbi_call_reg0 + 0 * 2
	ske
	jmp	fail
	;; digit 1
	aisc	0x1
	jsr	lbi_call_reg0 + 1 * 2
	ske
	jmp	fail
	;; digit 2
	aisc	0x1
	jsr	lbi_call_reg0 + 2 * 2
	ske
	jmp	fail
	;; digit 3
	aisc	0x1
	jsr	lbi_call_reg0 + 3 * 2
	ske
	jmp	fail
	;; digit 4
	aisc	0x1
	jsr	lbi_call_reg0 + 4 * 2
	ske
	jmp	fail
	;; digit 5
	aisc	0x1
	jsr	lbi_call_reg0 + 5 * 2
	ske
	jmp	fail
	;; digit 6
	aisc	0x1
	jsr	lbi_call_reg0 + 6 * 2
	ske
	jmp	fail
	;; digit 7
	aisc	0x1
	jsr	lbi_call_reg0 + 7 * 2
	ske
	jmp	fail
	;; digit 8
	aisc	0x1
	jsr	lbi_call_reg0 + 8 * 2
	ske
	jmp	fail
	;; digit 9
	aisc	0x1
	jsr	lbi_call_reg0 + 9 * 2
	ske
	jmp	fail
	;; digit 10
	aisc	0x1
	jsr	lbi_call_reg0 + 10 * 2
	ske
	jmp	fail
	;; digit 11
	aisc	0x1
	jsr	lbi_call_reg0 + 11 * 2
	ske
	jmp	fail
	;; digit 12
	aisc	0x1
	jsr	lbi_call_reg0 + 12 * 2
	ske
	jmp	fail
	;; digit 13
	aisc	0x1
	jsr	lbi_call_reg0 + 13 * 2
	ske
	jmp	fail
	;; digit 14
	aisc	0x1
	jsr	lbi_call_reg0 + 14 * 2
	ske
	jmp	fail
	;; digit 15
	aisc	0x1
	jsr	lbi_call_reg0 + 15 * 2
	ske
	jmp	fail


	;; *******************************************************************
	;; register 1
	;;
	;; initialize all digits of register
	;;
	ld	0x0		; r: 0 -> 0
	jsr	clear_reg
	ld	0x1		; r: 0 -> 1
	jsr	init_reg

	
	;; digit 0
	clra
	jsr	lbi_call_reg1 + 0 * 2
	ske
	jmp	fail
	;; digit 1
	aisc	0x1
	jsr	lbi_call_reg1 + 1 * 2
	ske
	jmp	fail
	;; digit 2
	aisc	0x1
	jsr	lbi_call_reg1 + 2 * 2
	ske
	jmp	fail
	;; digit 3
	aisc	0x1
	jsr	lbi_call_reg1 + 3 * 2
	ske
	jmp	fail
	;; digit 4
	aisc	0x1
	jsr	lbi_call_reg1 + 4 * 2
	ske
	jmp	fail
	;; digit 5
	aisc	0x1
	jsr	lbi_call_reg1 + 5 * 2
	ske
	jmp	fail
	;; digit 6
	aisc	0x1
	jsr	lbi_call_reg1 + 6 * 2
	ske
	jmp	fail
	;; digit 7
	aisc	0x1
	jsr	lbi_call_reg1 + 7 * 2
	ske
	jmp	fail
	;; digit 8
	aisc	0x1
	jsr	lbi_call_reg1 + 8 * 2
	ske
	jmp	fail
	;; digit 9
	aisc	0x1
	jsr	lbi_call_reg1 + 9 * 2
	ske
	jmp	fail
	;; digit 10
	aisc	0x1
	jsr	lbi_call_reg1 + 10 * 2
	ske
	jmp	fail
	;; digit 11
	aisc	0x1
	jsr	lbi_call_reg1 + 11 * 2
	ske
	jmp	fail
	;; digit 12
	aisc	0x1
	jsr	lbi_call_reg1 + 12 * 2
	ske
	jmp	fail
	;; digit 13
	aisc	0x1
	jsr	lbi_call_reg1 + 13 * 2
	ske
	jmp	fail
	;; digit 14
	aisc	0x1
	jsr	lbi_call_reg1 + 14 * 2
	ske
	jmp	fail
	;; digit 15
	aisc	0x1
	jsr	lbi_call_reg1 + 15 * 2
	ske
	jmp	fail


	;; *******************************************************************
	;; register 2
	;;
	;; initialize all digits of register
	;;
	ld	0x0		; r: 1 -> 1
	jsr	clear_reg
	ld	0x3		; r: 1 -> 2
	jsr	init_reg

	
	;; digit 0
	clra
	jsr	lbi_call_reg2 + 0 * 2
	ske
	jmp	fail
	;; digit 1
	aisc	0x1
	jsr	lbi_call_reg2 + 1 * 2
	ske
	jmp	fail
	;; digit 2
	aisc	0x1
	jsr	lbi_call_reg2 + 2 * 2
	ske
	jmp	fail
	;; digit 3
	aisc	0x1
	jsr	lbi_call_reg2 + 3 * 2
	ske
	jmp	fail
	;; digit 4
	aisc	0x1
	jsr	lbi_call_reg2 + 4 * 2
	ske
	jmp	fail
	;; digit 5
	aisc	0x1
	jsr	lbi_call_reg2 + 5 * 2
	ske
	jmp	fail
	;; digit 6
	aisc	0x1
	jsr	lbi_call_reg2 + 6 * 2
	ske
	jmp	fail
	;; digit 7
	aisc	0x1
	jsr	lbi_call_reg2 + 7 * 2
	ske
	jmp	fail
	;; digit 8
	aisc	0x1
	jsr	lbi_call_reg2 + 8 * 2
	ske
	jmp	fail
	;; digit 9
	aisc	0x1
	jsr	lbi_call_reg2 + 9 * 2
	ske
	jmp	fail
	;; digit 10
	aisc	0x1
	jsr	lbi_call_reg2 + 10 * 2
	ske
	jmp	fail
	;; digit 11
	aisc	0x1
	jsr	lbi_call_reg2 + 11 * 2
	ske
	jmp	fail
	;; digit 12
	aisc	0x1
	jsr	lbi_call_reg2 + 12 * 2
	ske
	jmp	fail
	;; digit 13
	aisc	0x1
	jsr	lbi_call_reg2 + 13 * 2
	ske
	jmp	fail
	;; digit 14
	aisc	0x1
	jsr	lbi_call_reg2 + 14 * 2
	ske
	jmp	fail
	;; digit 15
	aisc	0x1
	jsr	lbi_call_reg2 + 15 * 2
	ske
	jmp	fail


	;; *******************************************************************
	;; register 3
	;;
	;; initialize all digits of register
	;;
	ld	0x0		; r: 2 -> 2
	jsr	clear_reg
	ld	0x1		; r: 2 -> 3
	jsr	init_reg

	
	;; digit 0
	clra
	jsr	lbi_call_reg3 + 0 * 2
	ske
	jmp	fail
	;; digit 1
	aisc	0x1
	jsr	lbi_call_reg3 + 1 * 2
	ske
	jmp	fail
	;; digit 2
	aisc	0x1
	jsr	lbi_call_reg3 + 2 * 2
	ske
	jmp	fail
	;; digit 3
	aisc	0x1
	jsr	lbi_call_reg3 + 3 * 2
	ske
	jmp	fail
	;; digit 4
	aisc	0x1
	jsr	lbi_call_reg3 + 4 * 2
	ske
	jmp	fail
	;; digit 5
	aisc	0x1
	jsr	lbi_call_reg3 + 5 * 2
	ske
	jmp	fail
	;; digit 6
	aisc	0x1
	jsr	lbi_call_reg3 + 6 * 2
	ske
	jmp	fail
	;; digit 7
	aisc	0x1
	jsr	lbi_call_reg3 + 7 * 2
	ske
	jmp	fail
	;; digit 8
	aisc	0x1
	jsr	lbi_call_reg3 + 8 * 2
	ske
	jmp	fail
	;; digit 9
	aisc	0x1
	jsr	lbi_call_reg3 + 9 * 2
	ske
	jmp	fail
	;; digit 10
	aisc	0x1
	jsr	lbi_call_reg3 + 10 * 2
	ske
	jmp	fail
	;; digit 11
	aisc	0x1
	jsr	lbi_call_reg3 + 11 * 2
	ske
	jmp	fail
	;; digit 12
	aisc	0x1
	jsr	lbi_call_reg3 + 12 * 2
	ske
	jmp	fail
	;; digit 13
	aisc	0x1
	jsr	lbi_call_reg3 + 13 * 2
	ske
	jmp	fail
	;; digit 14
	aisc	0x1
	jsr	lbi_call_reg3 + 14 * 2
	ske
	jmp	fail
	;; digit 15
	aisc	0x1
	jsr	lbi_call_reg3 + 15 * 2
	ske
	jmp	fail



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

	include	"pass_fail.asm"
