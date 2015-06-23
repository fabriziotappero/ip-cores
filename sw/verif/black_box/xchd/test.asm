	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test XCHD A, @ Rr.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

testR0R1	MACRO	pos
	inc	r0
	inc	r1
	mov	a, @r0
	cpl	a
	add	a, #((~((pos+7) # 8) << 4) & 0F0H) | (pos & 00FH)
	cpl	a
	jnz	fail
	mov	a, @r1
	cpl	a
	add	a, #((~((pos+7) # 8) << 4) & 0F0H) | (pos & 00FH)
	cpl	a
	jnz	fail
	ENDM

	ORG	0

	;; Start of test
	mov	r0, #010H
	mov	r1, #020H
	mov	a, #0F0H
	mov	@r0, a
	mov	@r1, a
	inc	r0
	inc	r1
	mov	a, #0E1H
	mov	@r0, a
	mov	@r1, a
	inc	r0
	inc	r1
	mov	a, #0D2H
	mov	@r0, a
	mov	@r1, a
	inc	r0
	inc	r1
	mov	a, #0C3H
	mov	@r0, a
	mov	@r1, a
	inc	r0
	inc	r1
	mov	a, #0B4H
	mov	@r0, a
	mov	@r1, a
	inc	r0
	inc	r1
	mov	a, #0A5H
	mov	@r0, a
	mov	@r1, a
	inc	r0
	inc	r1
	mov	a, #096H
	mov	@r0, a
	mov	@r1, a
	inc	r0
	inc	r1
	mov	a, #087H
	mov	@r0, a
	mov	@r1, a

	dec	r0
	xchd	a, @r0
	dec	r0
	xchd	a, @r0
	dec	r0
	xchd	a, @r0
	dec	r0
	xchd	a, @r0
	dec	r0
	xchd	a, @r0
	dec	r0
	xchd	a, @r0
	dec	r0
	xchd	a, @r0
	mov	r0, #017H
	xchd	a, @r0

	mov	a, @r1
	dec	r1
	xchd	a, @r1
	dec	r1
	xchd	a, @r1
	dec	r1
	xchd	a, @r1
	dec	r1
	xchd	a, @r1
	dec	r1
	xchd	a, @r1
	dec	r1
	xchd	a, @r1
	dec	r1
	xchd	a, @r1
	mov	r1, #027H
	xchd	a, @r1

	jmp	goon

	ORG	256
	;;
goon:	mov	r0, #00FH
	mov	r1, #01FH
	testR0R1	1
	testR0R1	2
	testR0R1	3
	testR0R1	4
	testR0R1	5
	testR0R1	6
	testR0R1	7
	testR0R1	0

pass:	PASS

fail:	FAIL
