	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test INC Rr for RB0 and RB1.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

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
	call	clr_rb0

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
fill:	mov	a, #0FFH
	mov	r0, a
	mov	r1, a
	mov	r2, a
	mov	r3, a
	mov	r4, a
	mov	r5, a
	mov	r6, a
	mov	r7, a
	ret

clr_rb0:
	mov	r0, #007H
	clr	a
clr_loop:
	mov	@r0, a
	djnz	r0, clr_loop
	ret

check:	mov	a, #000H
	inc	r0
	jnz	fail_p3
	mov	a, r0
	jnz	fail_p3
	;;
	mov	a, r1
	jz	fail_p3
	mov	a, r2
	jz	fail_p3
	mov	a, r3
	jz	fail_p3
	mov	a, r4
	jz	fail_p3
	mov	a, r5
	jz	fail_p3
	mov	a, r6
	jz	fail_p3
	mov	a, r7
	jz	fail_p3

	mov	a, #000H
	inc	r1
	jnz	fail_p3
	mov	a, r1
	jnz	fail_p3
	;;
	mov	a, r0
	jnz	fail_p3
	;;
	mov	a, r2
	jz	fail_p3
	mov	a, r3
	jz	fail_p3
	mov	a, r4
	jz	fail_p3
	mov	a, r5
	jz	fail_p3
	mov	a, r6
	jz	fail_p3
	mov	a, r7
	jz	fail_p3

	mov	a, #000H
	inc	r2
	jnz	fail_p3
	mov	a, r2
	jnz	fail_p3
	;;
	mov	a, r0
	jnz	fail_p3
	mov	a, r1
	jnz	fail_p3
	;;
	mov	a, r3
	jz	fail_p3
	mov	a, r4
	jz	fail_p3
	mov	a, r5
	jz	fail_p3
	mov	a, r6
	jz	fail_p3
	mov	a, r7
	jz	fail_p3

	mov	a, #000H
	inc	r3
	jnz	fail_p3
	mov	a, r3
	jnz	fail_p3
	;;
	mov	a, r0
	jnz	fail_p3
	mov	a, r1
	jnz	fail_p3
	mov	a, r2
	jnz	fail_p3
	;;
	mov	a, r4
	jz	fail_p3
	mov	a, r5
	jz	fail_p3
	mov	a, r6
	jz	fail_p3
	mov	a, r7
	jz	fail_p3

	mov	a, #000H
	inc	r4
	jnz	fail_p3
	mov	a, r4
	jnz	fail_p3
	;;
	mov	a, r0
	jnz	fail_p3
	mov	a, r1
	jnz	fail_p3
	mov	a, r2
	jnz	fail_p3
	mov	a, r3
	jnz	fail_p3
	;;
	mov	a, r5
	jz	fail_p3
	mov	a, r6
	jz	fail_p3
	mov	a, r7
	jz	fail_p3

	mov	a, #000H
	inc	r5
	jnz	fail_p3
	mov	a, r5
	jnz	fail_p3
	;;
	mov	a, r0
	jnz	fail_p3
	mov	a, r1
	jnz	fail_p3
	mov	a, r2
	jnz	fail_p3
	mov	a, r3
	jnz	fail_p3
	mov	a, r4
	jnz	fail_p3
	;;
	mov	a, r6
	jz	fail_p3
	mov	a, r7
	jz	fail_p3

	mov	a, #000H
	inc	r6
	jnz	fail_p3
	mov	a, r6
	jnz	fail_p3
	;;
	mov	a, r0
	jnz	fail_p3
	mov	a, r1
	jnz	fail_p3
	mov	a, r2
	jnz	fail_p3
	mov	a, r3
	jnz	fail_p3
	mov	a, r4
	jnz	fail_p3
	mov	a, r5
	jnz	fail_p3
	;;
	mov	a, r7
	jz	fail_p3

	mov	a, #000H
	inc	r7
	jnz	fail_p3
	mov	a, r7
	jnz	fail_p3
	;;
	mov	a, r0
	jnz	fail_p3
	mov	a, r1
	jnz	fail_p3
	mov	a, r2
	jnz	fail_p3
	mov	a, r3
	jnz	fail_p3
	mov	a, r4
	jnz	fail_p3
	mov	a, r5
	jnz	fail_p3
	mov	a, r6
	jnz	fail_p3
	ret

fail_p3:
	FAIL
