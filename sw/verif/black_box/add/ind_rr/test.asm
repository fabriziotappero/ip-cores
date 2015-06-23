	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test ADD A, @ Rr without carry.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

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
	mov	r0, #010H
	mov	r1, #020H
	mov	a, #002H
	add	a, @r0
	jnz	fail
	mov	a, #002H
	add	a, @r1
	jnz	fail

	inc	r0
	inc	r1
	mov	a, #003H
	add	a, @r0
	jnz	fail
	mov	a, #003H
	add	a, @r1
	jnz	fail

	inc	r0
	inc	r1
	mov	a, #005H
	add	a, @r0
	jnz	fail
	mov	a, #005H
	add	a, @r1
	jnz	fail

	inc	r0
	inc	r1
	mov	a, #009H
	add	a, @r0
	jnz	fail
	mov	a, #009H
	add	a, @r1
	jnz	fail

	inc	r0
	inc	r1
	mov	a, #011H
	add	a, @r0
	jnz	fail
	mov	a, #011H
	add	a, @r1
	jnz	fail

	inc	r0
	inc	r1
	mov	a, #021H
	add	a, @r0
	jnz	fail
	mov	a, #021H
	add	a, @r1
	jnz	fail

	inc	r0
	inc	r1
	mov	a, #041H
	add	a, @r0
	jnz	fail
	mov	a, #041H
	add	a, @r1
	jnz	fail

	inc	r0
	inc	r1
	mov	a, #081H
	add	a, @r0
	jnz	fail
	mov	a, #081H
	add	a, @r1
	jnz	fail

pass:	PASS

fail:	FAIL
