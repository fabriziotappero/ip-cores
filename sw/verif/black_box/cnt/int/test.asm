	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test Counter Interrupt.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0
	jmp	start
	nop
	jmp	fail
	jmp	fail
	jmp	counter_int
	jmp	fail

	;; Start of test
start:	mov	a, #0FEH
	mov	t, a

	mov	r0, #000H

	strt	cnt
	en	tcnti

	jtf	fail

	;; apply falling edge on T1 -> T = 0FFH
	anl	P1, #0FDH
	call	check_cnt_idle
	mov	a, t
	inc	a
	jnz	fail
	;; apply rising edge on T1
	orl	P1, #002H
	call	check_cnt_idle
	mov	a, t
	inc	a
	jnz	fail

	;; apply falling edge on T1 -> T = 000H
	anl	P1, #0FDH
	jtf	goon
	jmp	fail
goon:	mov	a, r0
	inc	a
	jnz	fail
	mov	r0, a
	jtf	fail
	;; apply rising edge on T1
	orl	P1, #002H
	call	check_cnt_idle

	;; apply falling edge on T1 -> T = 001H
	anl	P1, #0FDH
	call	check_cnt_idle
	mov	a, t
	dec	a
	jnz	fail
	;; apply rising edge on T1
	orl	P1, #002H
	call	check_cnt_idle
	mov	a, t
	dec	a
	jnz	fail

	;; apply falling edge on T1 -> T = 002H
	anl	P1, #0FDH
	call	check_cnt_idle
	mov	a, t
	dec	a
	dec	a
	jnz	fail
	;; apply rising edge on T1
	orl	P1, #002H
	call	check_cnt_idle
	mov	a, t
	dec	a
	dec	a
	jnz	fail

	;; disable interrupt and trigger overflow
	dis	tcnti
	mov	a, #0FFH
	mov	t, a
	call	check_cnt_idle

	;; apply falling edge on T1 -> T = 000H
	anl	P1, #0FDH
	jtf	goon2
	jmp	fail
goon2:	mov	a, r0
	jnz	fail
	mov	a, t
	jnz	fail


pass:	PASS

fail:	FAIL


check_cnt_idle:
	jtf	fail
	mov	a, r0
	jnz	fail
	ret


counter_int:
	mov	r0, #0FFH
	retr
