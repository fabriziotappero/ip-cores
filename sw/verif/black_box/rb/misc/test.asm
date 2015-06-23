	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test several operations in conjunction with RB-switching.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test

	;; fill data memory with 0
	clr	a
	mov	r0, a
fill_loop:
	mov	@r0, a
	djnz	r0, fill_loop

	;; set up both register banks with indirect writes
	mov	r0, #01FH
	mov	r1, #008H
fill_rb1_loop:
	mov	a, r0
	mov	@r0, a
	dec	r0
	djnz	r1, fill_rb1_loop

	mov	r0, #007H
fill_rb0_loop:
	mov	a, r0
	mov	@r0, a
	djnz	r0, fill_rb0_loop
	mov	a, r0
	mov	@r0, a

	;; check RB0
	call	check_rb0

	;; check RB1
	sel	rb1
	call	check_rb1

	;; check RB0 again
	sel	rb0
	call	check_rb0

	;; check memory between RB0 and RB1 for 0
	mov	r0, #00EH	; check 14 bytes
	mov	r1, #00AH	; starting from address A
chk_loop1:
	mov	a, @r1
	jnz	fail
	inc	r1
	djnz	r0, chk_loop1

	;; check memory above RB1 for 0
	mov	r0, #0100H - 0020H ; check 256-32 bytes
	mov	r1, #020H	; starting from address 20H
chk_loop2:
	mov	a, @r1
	jnz	fail
	inc	r1
	djnz	r0, chk_loop2

	;; now use RB1 to indirect address register 0-7
	mov	r1, #001H	; restore r1
	mov	r0, #000H	; restore r0, set trap
	sel	rb1
	mov	r0, #007H
ind_chk_loop:
	mov	a, @r0
	cpl	a
	add	a, r0
	cpl	a
	jnz	fail
	djnz	r0, ind_chk_loop


pass:	PASS

fail:	FAIL



	ORG	0300H
check_rb0:
	mov	a, r0
	jnz	fail_p3
	mov	a,r1
	add	a, #0FFH
	jnz	fail_p3
	mov	a,r2
	add	a, #0FEH
	jnz	fail_p3
	mov	a,r3
	add	a, #0FDH
	jnz	fail_p3
	mov	a,r4
	add	a, #0FCH
	jnz	fail_p3
	mov	a,r5
	add	a, #0FBH
	jnz	fail_p3
	mov	a,r6
	add	a, #0FAH
	jnz	fail_p3
	mov	a,r7
	add	a, #0F9H
	jnz	fail_p3
	ret

check_rb1:
	mov	a, r0
	add	a, #0E8H
	jnz	fail_p3
	mov	a,r1
	add	a, #0E7H
	jnz	fail_p3
	mov	a,r2
	add	a, #0E6H
	jnz	fail_p3
	mov	a,r3
	add	a, #0E5H
	jnz	fail_p3
	mov	a,r4
	add	a, #0E4H
	jnz	fail_p3
	mov	a,r5
	add	a, #0E3H
	jnz	fail_p3
	mov	a,r6
	add	a, #0E2H
	jnz	fail_p3
	mov	a,r7
	add	a, #0E1H
	jnz	fail_p3
	ret

fail_p3:
	FAIL
