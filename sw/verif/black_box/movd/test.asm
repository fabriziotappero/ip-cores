	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test MOVD.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test

	;;
	;; read initial values
	;;

	;; port 4
	cpl	a
	movd	a, p4
	xrl	a, #00fh
	jnz	fail

	;; port 5
	cpl	a
	movd	a, p5
	xrl	a, #00fh
	jnz	fail

	;; port 6
	cpl	a
	movd	a, p6
	xrl	a, #00fh
	jnz	fail

	;; port 7
	cpl	a
	movd	a, p7
	xrl	a, #00fh
	jnz	fail


	;;
	;; test read/write via direct connection
	;;

	;; port 4 => port 6
	mov	a, #005h
	movd	p4, a
	cpl	a
	movd	a, p6
	xrl	a, #005h
	jnz	fail

	mov	a, #00ah
	movd	p4, a
	cpl	a
	movd	a, p6
	xrl	a, #00ah
	jnz	fail
	movd	a, p4

	;; port 6 => port 4
	mov	a, #000h
	movd	p6, a
	cpl	a
	movd	a, p4
	xrl	a, #000h
	jnz	fail

	mov	a, #00fh
	movd	p6, a
	cpl	a
	movd	a, p4
	xrl	a, #00fh
	jnz	fail
	movd	p6, a

	;; port 5 => port 7
	mov	a, #005h
	movd	p5, a
	cpl	a
	movd	a, p7
	xrl	a, #005h
	jnz	fail

	mov	a, #00ah
	movd	p5, a
	cpl	a
	movd	a, p7
	xrl	a, #00ah
	jnz	fail
	movd	a, p7

	;; port 7 => port 5
	mov	a, #000h
	movd	p7, a
	cpl	a
	movd	a, p5
	xrl	a, #000h
	jnz	fail

	mov	a, #00fh
	movd	p7, a
	cpl	a
	movd	a, p5
	xrl	a, #00fh
	jnz	fail
	movd	p7, a


	jmp	pass

	jmp	fail
pass:	PASS

fail:	FAIL
