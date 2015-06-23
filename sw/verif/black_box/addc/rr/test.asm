	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test ADDC A, Rr with carry, RB0 and RB1.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

testADDC	MACRO	val,reg
	mov	a, #val
	addc	a, reg
	jnz	fail_p3
	jnc	fail_p3
	mov	a, #val
	addc	a, reg
	jz	fail_p3
	jnc	fail_p3
	dec	a
	jnz	fail_p3
	clr	c
	jc	fail_p3
	ENDM

	ORG	0

	;; Start of test
	;; fill RB0
	call	fill

	;; check RB0
	call	check

	;; fill RB1
	sel	rb1
	call	fill
	sel	rb0

	;; clear RB0
	call	clr

	;; check RB1
	sel	rb1
	call	check

	;; check RB0 for all 0
	mov	r0, #000H
	mov	r1, #008H
chk0_loop:
	mov	a, @r0
	jnz	fail
	inc	r0
	djnz	r1, chk0_loop

pass:	PASS

fail:	FAIL


	ORG	0300H

fill:	mov	a, #0FEH
	mov	r0, a
	mov	a, #0FDH
	mov	r1, a
	mov	a, #0FBH
	mov	r2, a
	mov	a, #0F7H
	mov	r3, a
	mov	a, #0EFH
	mov	r4, a
	mov	a, #0DFH
	mov	r5, a
	mov	a, #0BFH
	mov	r6, a
	mov	a, #07FH
	mov	r7, a
	ret

check:	testADDC	002H, r0
	testADDC	003H, r1
	testADDC	005H, r2
	testADDC	009H, r3
	testADDC	011H, r4
	testADDC	021H, r5
	testADDC	041H, r6
	testADDC	081H, r7
	ret

clr:	mov	r0, #007H
	clr	a
clr_loop:
	mov	@r0, a
	djnz	r0, clr_loop
	ret

fail_p3:
	FAIL
