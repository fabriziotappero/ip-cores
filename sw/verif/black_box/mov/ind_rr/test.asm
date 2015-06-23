	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test MOV @ Rr for RB0.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	r0, #0FFH
fill_loop:
	mov	a, r0
	mov	@r0, a
	djnz	r0, fill_loop

	;; check memory
	mov	a, r0
	jnz	fail
	mov	r0, #0FFH
check_loop1:
	mov	a, @r1
	add	a, r0
	jnz	fail
	dec	r0
	inc	r1
	mov	a, r1
	jnz	check_loop1
	jmp	test_2

fail:	FAIL

	;;
	ALIGN	256
	;;

test_2:	;; test MOV @ Rr, data
	mov	r0, #0C0H
	mov	r1, #0E0H
	mov	@r0, #000H
	mov	@r1, #020H

	inc	r0
	inc	r1
	mov	@r0, #001H
	mov	@r1, #021H
	inc	r0
	inc	r1
	mov	@r0, #002H
	mov	@r1, #022H
	inc	r0
	inc	r1
	mov	@r0, #003H
	mov	@r1, #023H
	inc	r0
	inc	r1
	mov	@r0, #004H
	mov	@r1, #024H
	inc	r0
	inc	r1
	mov	@r0, #005H
	mov	@r1, #025H
	inc	r0
	inc	r1
	mov	@r0, #006H
	mov	@r1, #026H
	inc	r0
	inc	r1
	mov	@r0, #007H
	mov	@r1, #027H
	inc	r0
	inc	r1
	mov	@r0, #008H
	mov	@r1, #028H
	inc	r0
	inc	r1
	mov	@r0, #009H
	mov	@r1, #029H
	inc	r0
	inc	r1
	mov	@r0, #00AH
	mov	@r1, #02AH
	inc	r0
	inc	r1
	mov	@r0, #00BH
	mov	@r1, #02BH
	inc	r0
	inc	r1
	mov	@r0, #00CH
	mov	@r1, #02CH
	inc	r0
	inc	r1
	mov	@r0, #00DH
	mov	@r1, #02DH
	inc	r0
	inc	r1
	mov	@r0, #00EH
	mov	@r1, #02EH
	inc	r0
	inc	r1
	mov	@r0, #00FH
	mov	@r1, #02FH
	;;
	inc	r0
	inc	r1
	mov	@r0, #010H
	mov	@r1, #030H
	inc	r0
	inc	r1
	mov	@r0, #011H
	mov	@r1, #031H
	inc	r0
	inc	r1
	mov	@r0, #012H
	mov	@r1, #032H
	inc	r0
	inc	r1
	mov	@r0, #013H
	mov	@r1, #033H
	inc	r0
	inc	r1
	mov	@r0, #014H
	mov	@r1, #034H
	inc	r0
	inc	r1
	mov	@r0, #015H
	mov	@r1, #035H
	inc	r0
	inc	r1
	mov	@r0, #016H
	mov	@r1, #036H
	inc	r0
	inc	r1
	mov	@r0, #017H
	mov	@r1, #037H
	inc	r0
	inc	r1
	mov	@r0, #018H
	mov	@r1, #038H
	inc	r0
	inc	r1
	mov	@r0, #019H
	mov	@r1, #039H
	inc	r0
	inc	r1
	mov	@r0, #01AH
	mov	@r1, #03AH
	inc	r0
	inc	r1
	mov	@r0, #01BH
	mov	@r1, #03BH
	inc	r0
	inc	r1
	mov	@r0, #01CH
	mov	@r1, #03CH
	inc	r0
	inc	r1
	mov	@r0, #01DH
	mov	@r1, #03DH
	inc	r0
	inc	r1
	mov	@r0, #01EH
	mov	@r1, #03EH
	inc	r0
	inc	r1
	mov	@r0, #01FH
	mov	@r1, #03FH

	mov	r0, #0FFH
	mov	r1, #11000001B
check_loop2:
	mov	a, @r0
	add	a, r1
	jnz	fail2
	inc	r1
	dec	r0
	mov	a, #01000000B
	add	a, r0
	jnz	check_loop2

pass2:	PASS

fail2:	FAIL
