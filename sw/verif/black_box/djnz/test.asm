	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test DJNZ Rr, addr
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	r0, #003H
	mov	a, #000H
	djnz	r0, r0_2
	jmp	fail

r0_2:	djnz	r0, r0_1
	jmp	fail
r0_1:	mov	a, #0FFH
	djnz	r0, fail

	
	mov	r1, #000H
	mov	r2, #000H
r1_loop:
	mov	a, r2
	add	a, r1
	jnz	fail
	inc	r2
	djnz	r1, r1_loop

	mov	a, r1
	jnz	fail


	mov	a, #002H
	mov	r3, a
	mov	r4, a
	mov	r5, a
	djnz	r5, ok_r5
	jmp	fail
ok_r5:	djnz	r4, ok_r4
	jmp	fail
ok_r4:	djnz	r3, ok_r3
	jmp	fail
	
ok_r3:	djnz	r3, fail
	djnz	r4, fail
	djnz	r5, fail

pass:	PASS

fail:	FAIL
