	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test P2 conflict for reading port or output register.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test

	;; access testbench peripherals
	mov	r0, #0FFH
	mov	a, #002H
	movx	@r0, a

	;; check functionality of P2 testbench peripheral
	in	a, p2
	inc	a
	jnz	fail

	mov	r0, #001H
	;; extern write 00H to P2
	clr	a
	movx	@r0, a
	in	a, p2
	jnz	fail
	;; extern write 0AAH to P2
	mov	a, #0AAH
	movx	@r0, a
	clr	a
	in	a, p2
	add	a, #056H
	jnz	fail
	;; extern write 055H to P2
	mov	a, #055H
	movx	@r0, a
	clr	a
	in	a, p2
	add	a, #0ABH
	jnz	fail

	;; reset extern P2 to 0FFH
	dec	a
	movx	@r0, a

	;;
	;; Start of real test
	;;

	;; Test ORL

	;; set internal P2 to 0AAH
	mov	a, #0AAH
	outl	p2, a
	in	a, p2
	add	a, #056H
	jnz	fail

	;; extern write 055H to P2
	mov	a, #055H
	movx	@r0, a

	in	a, p2
	jnz	fail

	;; set internal P2 to 0ABH, setting P2[0] to 1
	orl	P2, #001H
	in	a, p2
	dec	a
	jnz	fail

	;; reset extern P2 to 0FFH
	dec	a
	movx	@r0, a

	;; compare P2 vs. 0ABH
	in	a, p2
	cpl	a
	add	a, #0ABH
	cpl	a
	jnz	fail

	;; reset intern P2 to 0FFH
	dec	a
	outl	p2, a

	;; set internal P2 to 055H
	mov	a, #055H
	outl	p2, a
	clr	a
	in	a, p2
	add	a, #0ABH
	jnz	fail

	;; external write 0AAH to P2
	mov	a, #0AAH
	movx	@r0, a

	;; set internal P2 to 054H
	anl	P2, #0FEH

	;; reset extern P2 to 0FFH
	mov	a, #0FFH
	movx	@r0, a

	;; compare P2 vs. 054H
	in	a, p2
	cpl	a
	add	a, #054H
	cpl	a
	jnz	fail


pass:	PASS

fail:	FAIL
