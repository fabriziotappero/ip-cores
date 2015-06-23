	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test ADDC A, @ Rr.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

testADDC	MACRO	val
	jmp	goon
	ALIGN	040H
goon:	inc	r0
	inc	r1
	mov	a, #val
	addc	a, @r0
	jnz	fail
	jnc	fail
	mov	a, #val
	addc	a, @r0
	dec	a
	jnz	fail
	jnc	fail
	clr	c
	;;
	mov	a, #val
	addc	a, @r1
	jnz	fail
	jnc	fail
	mov	a, #val
	addc	a, @r1
	dec	a
	jnz	fail
	jnc	fail
	clr	c
	jmp	pass
	;;
fail:	FAIL
pass:
	ENDM

	ORG	0

	;; Start of test
	mov	r0, #010H
	mov	r1, #020H
	mov	a, #0FEH
	mov	@r0, a
	mov	@r1, a
	inc	r0
	inc	r1
	mov	a, #0FDH
	mov	@r0, a
	mov	@r1, a
	inc	r0
	inc	r1
	mov	a, #0FBH
	mov	@r0, a
	mov	@r1, a
	inc	r0
	inc	r1
	mov	a, #0F7H
	mov	@r0, a
	mov	@r1, a
	inc	r0
	inc	r1
	mov	a, #0EFH
	mov	@r0, a
	mov	@r1, a
	inc	r0
	inc	r1
	mov	a, #0DFH
	mov	@r0, a
	mov	@r1, a
	inc	r0
	inc	r1
	mov	a, #0BFH
	mov	@r0, a
	mov	@r1, a
	inc	r0
	inc	r1
	mov	a, #07FH
	mov	@r0, a
	mov	@r1, a

	;;
	mov	r0, #00FH
	mov	r1, #01FH

	testADDC	002H
	testADDC	003H
	testADDC	005H
	testADDC	009H
	testADDC	011H
	testADDC	021H
	testADDC	041H
	testADDC	081H

pass:	PASS
