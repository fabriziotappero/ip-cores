	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test ORLD.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test

	;; port 4
	mov	a, #000h
	movd	p4, a
	mov	a, #001h
	orld	p4, a
	cpl	a
	movd	a, p6
	xrl	a, #001h
	jnz	fail
	movd	a, p4
	xrl	a, #001h
	jnz	fail

	mov	a, #00eh
	orld	p4, a
	movd	a, p6
	xrl	a, #00fh
	jnz	fail
	movd	a, p4
	xrl	a, #00fh
	jnz	fail

	;; port 5
	mov	a, #000h
	movd	p5, a
	mov	a, #006h
	orld	p5, a
	cpl	a
	movd	a, p7
	xrl	a, #006h
	jnz	fail
	movd	a, p5
	xrl	a, #006h
	jnz	fail

	mov	a, #003h
	orld	p5, a
	movd	a, p7
	xrl	a, #007h
	jnz	fail
	movd	a, p5
	xrl	a, #007h
	jnz	fail

	;; port 6
	mov	a, #000h
	movd	p6, a
	mov	a, #009h
	orld	p6, a
	cpl	a
	movd	a, p4
	xrl	a, #009h
	jnz	fail
	movd	a, p6
	xrl	a, #009h
	jnz	fail

	mov	a, #006h
	orld	p6, a
	movd	a, p4
	xrl	a, #00fh
	jnz	fail
	movd	a, p6
	xrl	a, #00fh
	jnz	fail
	jmp	pass

	;; port 7
	mov	a, #000h
	movd	p7, a
	mov	a, #004h
	orld	p7, a
	cpl	a
	movd	a, p5
	xrl	a, #004h
	jnz	fail
	movd	a, p7
	xrl	a, #004h
	jnz	fail

	mov	a, #00ah
	orld	p7, a
	movd	a, p5
	xrl	a, #00eh
	jnz	fail
	movd	a, p7
	xrl	a, #00eh
	jnz	fail


	jmp	pass

	jmp	fail
pass:	PASS

fail:	FAIL
