	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test MOVP A, @ A and MOVP3 A, @ A.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

table	MACRO	data
	DB	data & 0FFH
	ENDM

	ORG	0

	;; Start of test
	mov	r1, #008H

loop:	mov	a, r1
	dec	a
	call	fetch_table1
	mov	r0, a

	mov	a, r1
	dec	a
	call	fetch_table3

	add	a, r0
	cpl	a
	jnz	fail

	djnz	r1, loop


pass:	PASS

fail:	FAIL


	ORG	0100H

	db	0AFH
	db	033H
	db	0C0H
	db	012H
	db	055H
	db	061H
	db	02BH
	db	0F4H
fetch_table1:
	movp	a, @a
	ret
fetch_table3:
	movp3	a, @a
	ret


	ORG	0300H

	db	050H
	db	0CCH
	db	03FH
	db	0EDH
	db	0AAH
	db	09EH
	db	0D4H
	db	00BH
