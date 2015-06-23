	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test interrupts in conjunction with RB-switching.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	jmp	start
	nop
	jmp	interrupt
	jmp	fail
	jmp	fail
	jmp	fail


	;; Start of test
start:
	;; fill	RB0
	clr	a
	call	fill

	;; fill	RB1
	sel	rb1
	mov	a, #010H
	call	fill
	sel	rb0

	;; set up interrupt
	clr	f1
	;; sync on next interrupt
	call	sync_on_int

	mov	r0, #000H
	en	i
loop1:	jf1	goon1
	djnz	r0, loop1
	jmp	fail

goon1:
	dis	i
	clr	f1

	;; check BS implicitely
	;; r0 must not be zero
	mov	a, r0
	jz	fail

	;; check RB1
	sel	rb1
	call	check_0

	;; check RB0
	sel	rb0
	call	check_rb0

pass:	PASS

fail:	FAIL


	ORG	0200H
interrupt:
	sel	rb1
	mov	r0, a

	call	check_rb1

	clr	a
	mov	r1, a
	mov	r2, a
	mov	r3, a
	mov	r4, a
	mov	r5, a
	mov	r6, a
	mov	r7, a
	xch	a, r0

	cpl	f1

	retr


	ORG	0300H

fill:	add	a, #0B0H
	mov	r0, a
	inc	a
	mov	r1, a
	inc	a
	mov	r2, a
	inc	a
	mov	r3, a
	inc	a
	mov	r4, a
	inc	a
	mov	r5, a
	inc	a
	mov	r6, a
	inc	a
	mov	r7, a
	ret

check_0:
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
	mov	a, r7
	jnz	fail_p3
	ret

	;; synchronize on interrupt
	;; use r7 for timeout detection
sync_on_int:
	mov	a, r7		; save r7
	mov	r7, #000H
wait_int1:
	jni	sync_on_int2
	djnz	r7, wait_int1
	jmp	fail_p3

sync_on_int2:
	mov	r7, #000H
wait_int2:
	jni	still_int
	mov	r7, a		; restore r7
	call	clr_int
	retr
still_int:
	djnz	r7, wait_int2
	jmp	fail_p3

clr_int:
	;; clear latched interrupt request with RETR!
	retr

check_rb1:
	mov	a, #(~0C1H & 0FFH)
	add	a, r1
	cpl	a
	jnz	fail_p3

	mov	a, #(~0C2H & 0FFH)
	add	a, r2
	cpl	a
	jnz	fail_p3

	mov	a, #(~0C3H & 0FFH)
	add	a, r3
	cpl	a
	jnz	fail_p3

	mov	a, #(~0C4H & 0FFH)
	add	a, r4
	cpl	a
	jnz	fail_p3

	mov	a, #(~0C5H & 0FFH)
	add	a, r5
	cpl	a
	jnz	fail_p3

	mov	a, #(~0C6H & 0FFH)
	add	a, r6
	cpl	a
	jnz	fail_p3

	mov	a, #(~0C7H & 0FFH)
	add	a, r7
	cpl	a
	jnz	fail_p3

	ret

check_rb0:
	mov	a, #(~0B1H & 0FFH)
	add	a, r1
	cpl	a
	jnz	fail_p3

	mov	a, #(~0B2H & 0FFH)
	add	a, r2
	cpl	a
	jnz	fail_p3

	mov	a, #(~0B3H & 0FFH)
	add	a, r3
	cpl	a
	jnz	fail_p3

	mov	a, #(~0B4H & 0FFH)
	add	a, r4
	cpl	a
	jnz	fail_p3

	mov	a, #(~0B5H & 0FFH)
	add	a, r5
	cpl	a
	jnz	fail_p3

	mov	a, #(~0B6H & 0FFH)
	add	a, r6
	cpl	a
	jnz	fail_p3

	mov	a, #(~0B7H & 0FFH)
	add	a, r7
	cpl	a
	jnz	fail_p3

	ret

fail_p3:
	FAIL
