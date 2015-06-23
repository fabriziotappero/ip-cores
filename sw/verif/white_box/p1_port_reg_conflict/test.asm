	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test P1 conflict for reading port or output register.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test

	;; access testbench peripherals
	mov	r0, #0FFH
	mov	a, #002H
	movx	@r0, a

	;; check functionality of P1 testbench peripheral
	in	a, p1
	inc	a
	jnz	fail

	mov	r0, #000H
	;; extern write 00H to P1
	clr	a
	movx	@r0, a
	in	a, p1
	jnz	fail
	;; extern write 0AAH to P1
	mov	a, #0AAH
	movx	@r0, a
	clr	a
	in	a, p1
	add	a, #056H
	jnz	fail
	;; extern write 055H to P1
	mov	a, #055H
	movx	@r0, a
	clr	a
	in	a, p1
	add	a, #0ABH
	jnz	fail

	;; reset extern P1 to 0FFH
	dec	a
	movx	@r0, a

	;;
	;; Start of real test
	;;

	;; Test ORL

	;; set internal P1 to 0AAH
	mov	a, #0AAH
	outl	p1, a
	in	a, p1
	add	a, #056H
	jnz	fail

	;; extern write 055H to P1
	mov	a, #055H
	movx	@r0, a

	in	a, p1
	jnz	fail

	;; set internal P1 to 0ABH, setting P1[0] to 1
	orl	P1, #001H
	in	a, p1
	dec	a
	jnz	fail

	;; reset extern P1 to 0FFH
	dec	a
	movx	@r0, a

	;; compare P1 vs. 0ABH
	in	a, p1
	cpl	a
	add	a, #0ABH
	cpl	a
	jnz	fail

	;; reset intern P1 to 0FFH
	dec	a
	outl	p1, a

	;; set internal P1 to 055H
	mov	a, #055H
	outl	p1, a
	clr	a
	in	a, p1
	add	a, #0ABH
	jnz	fail

	;; external write 0AAH to P1
	mov	a, #0AAH
	movx	@r0, a

	;; set internal P1 to 054H
	anl	P1, #0FEH

	;; reset extern P1 to 0FFH
	mov	a, #0FFH
	movx	@r0, a

	;; compare P1 vs. 054H
	in	a, p1
	cpl	a
	add	a, #054H
	cpl	a
	jnz	fail


pass:	PASS

fail:	FAIL
