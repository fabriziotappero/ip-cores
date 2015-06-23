	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test DA A.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	r7, #000H

	;; testcase from "Single Component MCS-48 System"
	mov	a, #09BH
	da	a
	jnc	fail
	mov	r0, a
	mov	a, psw
	jb6	fail
	mov	a, r0
	cpl	a
	add	a, #001H
	cpl	a
	jnz	fail

	;; a value that should not be changed
	;; upper nibble: no overflow
	;; lower nibble: no overflow
	mov	a, #037H
	add	a, r7		; clear C and AC
	da	a
	jc	fail
	mov	r0, a
	mov	a, psw
	jb6	fail
	mov	a, r0
	cpl	a
	add	a, #037H
	cpl	a
	jnz	fail

	;; upper nibble: no overflow
	;; lower nibble: overflow
	mov	a, #04AH
	add	a, r7		; clear C and AC
	da	a
	jc	fail
	mov	r0, a
	mov	a, psw
	jb6	fail
	mov	a, r0
	cpl	a
	add	a, #050H
	cpl	a
	jnz	fail

	;; upper nibble: overflow
	;; lower nibble: no overflow
	mov	a, #0C1H
	add	a, r7		; clear C and AC
	da	a
	jnc	fail
	mov	r0, a
	mov	a, psw
	jb6	fail
	mov	a, r0
	cpl	a
	add	a, #021H
	cpl	a
	jnz	fail

	;; upper nibble: overflow
	;; lower nibble: overflow
	mov	a, #0DEH
	add	a, r7		; clear C and AC
	da	a
	jnc	fail
	mov	r0, a
	mov	a, psw
	jb6	fail
	mov	a, r0
	cpl	a
	add	a, #044H
	cpl	a
	jnz	fail


	;; ******************************************************************
	;; Next round with Auxiliary Carry
	;; ******************************************************************

	add	a, r7		; clear C and AC
	;; upper nibble: no overflow
	;; lower nibble: no overflow
	mov	a, #029H	; add two BCD numbers
	add	a, #019H	; result: 042H, but should be 48 BCD
	jc	fail
	mov	r0, a
	mov	a, psw
	jb6	goon1
	jmp	fail
goon1:	mov	a, r0
	da	a
	jc	fail
	cpl	a
	add	a, #048H
	cpl	a
	jnz	fail

	add	a, r7		; clear C and AC
	;; upper nibble: overflow
	;; lower nibble: no overflow
	mov	a, #067H	; add two BCD numbers
	add	a, #059H	; result: 0C0H, but should be 126 BCD
	jc	fail
	mov	r0, a
	mov	a, psw
	jb6	goon2
	jmp	fail
goon2:	mov	a, r0
	clr	c		; clear Carry, make set Carry by da testable
	da	a
	jnc	fail
	cpl	a
	add	a, #026H
	cpl	a
	jnz	fail

	add	a, r7		; clear C and AC
	;; upper nibble: no overflow
	;; lower nibble: overflow
	mov	a, #01FH	; this is not a BCD number!
	add	a, #033H	; reault: 052H, reveals 58 BCD
	jc	fail
	mov	r0, a
	mov	a, psw
	jb6	goon3
	jmp	fail
goon3:	mov	a, r0
	da	a
	jc	fail
	cpl	a
	add	a, #058H
	cpl	a
	jnz	fail

	add	a, r7		; clear C and AC
	;; upper nibble: overflow
	;; lower nibble: overflow
	mov	a, #0EEH	; this is not a BCD number!
	add	a, #0C5H	; result: 1B3H. reveals 119 BCD
	jnc	fail
	mov	r0, a
	mov	a, psw
	jb6	goon4
	jmp	fail
goon4:	mov	a, r0
	clr	c		; clear Carry, make set Carry by da testable
	da	a
	jnc	fail
	cpl	a
	add	a, #019H
	cpl	a
	jnz	fail


pass:	PASS

fail:	FAIL
