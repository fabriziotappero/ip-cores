	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test Expander port functionality.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #00AH
	movd	p4, a
	mov	a, #005H
	movd	p5, a
	mov	a, #00BH
	movd	p6, a
	mov	a, #000H
	movd	p7, a

	;; check P4
	movd	a, p4
	orl	a, #0F5H
	inc	a
	;jnz	fail
	mov	a, #0F5H
	orld	p4, a
	movd	a, p4
	inc	a
	;jnz	fail
	mov	a, #0FEH
	anld	p4, a
	movd	a, p4
	add	a, #0F2H
	;jnz	fail

	;; check P5
	movd	a, p5
	orl	a, #0FAH
	inc	a
	;jnz	fail
	mov	a, #0FAH
	orld	p5, a
	movd	a, p5
	inc	a
	;jnz	fail
	mov	a, #0FDH
	anld	p5, a
	movd	a, p5
	add	a, #0F3H
	;jnz	fail

	;; check P6
	movd	a, p6
	orl	a, #0F4H
	inc	a
	;jnz	fail
	mov	a, #0F4H
	orld	p6, a
	movd	a, p6
	inc	a
	;jnz	fail
	mov	a, #0F8H
	anld	p6, a
	movd	a, p6
	add	a, #0F8H
	;jnz	fail

	;; check P7
	movd	a, p7
	orl	a, #0FFH
	inc	a
	;jnz	fail
	mov	a, #0FFH
	orld	p7, a
	movd	a, p7
	inc	a
	;jnz	fail
	mov	a, #0F7H
	anld	p7, a
	movd	a, p7
	add	a, #0F9H
	;jnz	fail

pass:	PASS

fail:	FAIL
