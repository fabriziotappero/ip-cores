	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test INC @ Rr for RB0.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #0FFH
	mov	r1, a
	mov	r2, a
	mov	r3, a
	mov	r4, a
	mov	r5, a
	mov	r6, a
	mov	r7, a

	mov	r0, #001H
	mov	a, #000H
	inc	@r0
	jnz	fail
	mov	a, r1
	jnz	fail
	;;
	mov	a, r2
	jz	fail
	mov	a, r3
	jz	fail
	mov	a, r4
	jz	fail
	mov	a, r5
	jz	fail
	mov	a, r6
	jz	fail
	mov	a, r7
	jz	fail

	mov	a, #000H
	inc	r0
	jnz	fail
	inc	@r0
	jnz	fail
	mov	a, r2
	jnz	fail
	;;
	mov	a, r1
	jnz	fail
	;;
	mov	a, r3
	jz	fail
	mov	a, r4
	jz	fail
	mov	a, r5
	jz	fail
	mov	a, r6
	jz	fail
	mov	a, r7
	jz	fail

	mov	a, #000H
	inc	r0
	jnz	fail
	inc	@r0
	jnz	fail
	mov	a, r3
	jnz	fail
	;;
	mov	a, r1
	jnz	fail
	mov	a, r2
	jnz	fail
	;;
	mov	a, r4
	jz	fail
	mov	a, r5
	jz	fail
	mov	a, r6
	jz	fail
	mov	a, r7
	jz	fail

	mov	a, #000H
	inc	r0
	jnz	fail
	inc	@r0
	jnz	fail
	mov	a, r4
	jnz	fail
	;;
	mov	a, r1
	jnz	fail
	mov	a, r2
	jnz	fail
	mov	a, r3
	jnz	fail
	;;
	mov	a, r5
	jz	fail
	mov	a, r6
	jz	fail
	mov	a, r7
	jz	fail

	mov	a, #000H
	inc	r0
	jnz	fail
	inc	@r0
	jnz	fail
	mov	a, r5
	jnz	fail
	;;
	mov	a, r1
	jnz	fail
	mov	a, r2
	jnz	fail
	mov	a, r3
	jnz	fail
	mov	a, r4
	jnz	fail
	;;
	mov	a, r6
	jz	fail
	mov	a, r7
	jz	fail

	mov	a, #000H
	inc	r0
	jnz	fail
	inc	@r0
	jnz	fail
	mov	a, r6
	jnz	fail
	;;
	mov	a, r1
	jnz	fail
	mov	a, r2
	jnz	fail
	mov	a, r3
	jnz	fail
	mov	a, r4
	jnz	fail
	mov	a, r5
	jnz	fail
	;;
	mov	a, r7
	jz	fail

	mov	a, #000H
	inc	r0
	jnz	fail
	inc	@r0
	jnz	fail
	mov	a, r7
	jnz	fail
	;;
	mov	a, r1
	jnz	fail
	mov	a, r2
	jnz	fail
	mov	a, r3
	jnz	fail
	mov	a, r4
	jnz	fail
	mov	a, r5
	jnz	fail
	mov	a, r6
	jnz	fail

	jmp	test_r1

fail:	FAIL

	;;
	ALIGN	256
	;;

test_r1:
	mov	a, #0FFH
	mov	r0, a
	mov	r2, a
	mov	r3, a
	mov	r4, a
	mov	r5, a
	mov	r6, a
	mov	r7, a

	mov	r1, #000H
	mov	a, #000H
	inc	@r1
	jnz	fail2
	mov	a, r0
	jnz	fail2
	;;
	mov	a, r2
	jz	fail2
	mov	a, r3
	jz	fail2
	mov	a, r4
	jz	fail2
	mov	a, r5
	jz	fail2
	mov	a, r6
	jz	fail2
	mov	a, r7
	jz	fail2

	mov	a, #000H
	inc	r1
	inc	r1
	jnz	fail2
	inc	@r1
	jnz	fail2
	mov	a, r2
	jnz	fail2
	;;
	mov	a, r0
	jnz	fail2
	;;
	mov	a, r3
	jz	fail2
	mov	a, r4
	jz	fail2
	mov	a, r5
	jz	fail2
	mov	a, r6
	jz	fail2
	mov	a, r7
	jz	fail2

	mov	a, #000H
	inc	r1
	jnz	fail2
	inc	@r1
	jnz	fail2
	mov	a, r3
	jnz	fail2
	;;
	mov	a, r0
	jnz	fail2
	mov	a, r2
	jnz	fail2
	;;
	mov	a, r4
	jz	fail2
	mov	a, r5
	jz	fail2
	mov	a, r6
	jz	fail2
	mov	a, r7
	jz	fail2

	mov	a, #000H
	inc	r1
	jnz	fail2
	inc	@r1
	jnz	fail2
	mov	a, r4
	jnz	fail2
	;;
	mov	a, r0
	jnz	fail2
	mov	a, r2
	jnz	fail2
	mov	a, r3
	jnz	fail2
	;;
	mov	a, r5
	jz	fail2
	mov	a, r6
	jz	fail2
	mov	a, r7
	jz	fail2

	mov	a, #000H
	inc	r1
	jnz	fail2
	inc	@r1
	jnz	fail2
	mov	a, r5
	jnz	fail2
	;;
	mov	a, r0
	jnz	fail2
	mov	a, r2
	jnz	fail2
	mov	a, r3
	jnz	fail2
	mov	a, r4
	jnz	fail2
	;;
	mov	a, r6
	jz	fail2
	mov	a, r7
	jz	fail2

	mov	a, #000H
	inc	r1
	jnz	fail2
	inc	@r1
	jnz	fail2
	mov	a, r6
	jnz	fail2
	;;
	mov	a, r0
	jnz	fail2
	mov	a, r2
	jnz	fail2
	mov	a, r3
	jnz	fail2
	mov	a, r4
	jnz	fail2
	mov	a, r5
	jnz	fail2
	;;
	mov	a, r7
	jz	fail2

	mov	a, #000H
	inc	r1
	jnz	fail2
	inc	@r1
	jnz	fail2
	mov	a, r7
	jnz	fail2
	;;
	mov	a, r0
	jnz	fail2
	mov	a, r2
	jnz	fail2
	mov	a, r3
	jnz	fail2
	mov	a, r4
	jnz	fail2
	mov	a, r5
	jnz	fail2
	mov	a, r6
	jnz	fail2

pass:	PASS

fail2:	FAIL
