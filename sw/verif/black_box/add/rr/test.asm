	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test ADD A, Rr without carry, RB0 and RB1.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	;; fill RB0
	call	fill

	;; check RB0
	sel	rb0
	call	check

	;; fill RB1
	sel	rb1
	call	fill
	sel	rb0

	;; clear RB0
	mov	r0, #007H
	clr	a
clr_loop:
	mov	@r0, a
	djnz	r0, clr_loop

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


check:	mov	a, #002H
	add	a, r0
	jnz	fail_p3

	mov	a, #003H
	add	a, r1
	jnz	fail_p3

	mov	a, #005H
	add	a, r2
	jnz	fail_p3

	mov	a, #009H
	add	a, r3
	jnz	fail_p3

	mov	a, #011H
	add	a, r4
	jnz	fail_p3

	mov	a, #021H
	add	a, r5
	jnz	fail_p3

	mov	a, #041H
	add	a, r6
	jnz	fail_p3

	mov	a, #081H
	add	a, r7
	jnz	fail_p3

	ret


fail_p3:
	FAIL
