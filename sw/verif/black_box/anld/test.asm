	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test ANLD.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test

	;; port 4
	mov	a, #00fh
	movd	p4, a
	mov	a, #00ch
	anld	p4, a
	cpl	a
	movd	a, p6
	xrl	a, #00ch
	jnz	fail
	movd	a, p4
	xrl	a, #00ch
	jnz	fail

	mov	a, #003h
	anld	p4, a
	movd	a, p6
	jnz	fail
	movd	a, p4
	jnz	fail

	;; port 5
	mov	a, #00fh
	movd	p5, a
	mov	a, #003h
	anld	p5, a
	cpl	a
	movd	a, p7
	xrl	a, #003h
	jnz	fail
	movd	a, p5
	xrl	a, #003h
	jnz	fail

	mov	a, #009h
	anld	p5, a
	movd	a, p7
	xrl	a, #001h
	jnz	fail
	movd	a, p5
	xrl	a, #001h
	jnz	fail

	;; port 6
	mov	a, #00fh
	movd	p6, a
	mov	a, #005h
	anld	p6, a
	cpl	a
	movd	a, p4
	xrl	a, #005h
	jnz	fail
	movd	a, p6
	xrl	a, #005h
	jnz	fail

	mov	a, #00eh
	anld	p6, a
	movd	a, p4
	xrl	a, #004h
	jnz	fail
	movd	a, p6
	xrl	a, #004h
	jnz	fail

	;; port 7
	mov	a, #00fh
	movd	p7, a
	mov	a, #00ah
	anld	p7, a
	cpl	a
	movd	a, p5
	xrl	a, #00ah
	jnz	fail
	movd	a, p7
	xrl	a, #00ah
	jnz	fail

	mov	a, #00dh
	anld	p7, a
	movd	a, p5
	xrl	a, #008h
	jnz	fail
	movd	a, p7
	xrl	a, #008h
	jnz	fail


	jmp	pass

	jmp	fail
pass:	PASS

fail:	FAIL
