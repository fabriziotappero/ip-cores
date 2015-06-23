	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test CALL + RET(R) with simple program.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	r0, #008H
	call	recursive

call1:	call	sub1
	jc	fail
	jf0	fail
	jf1	ok_1
	jmp	fail
ok_1:
	;; check stack contents
	mov	r0, #008H
	mov	a, @r0
	add	a, #(~(call1+2 & 0FFH) + 1) & 0FFH
	jnz	fail

	inc	r0
	mov	a, @r0
	add	a, #(~((call1+2) >> 8) + 1) & 0FFH
	jnz	fail

	inc	r0
	mov	a, @r0
	add	a, #(~(call2+2 & 0FFH) + 1) & 0FFH
	jnz	fail

	inc	r0
	mov	a, @r0
	add	a, #(~((call2+2) >> 8 | 0A0H) + 1) & 0FFH
	jnz	fail


	clr	c
	clr	f0
	clr	f1
	call	sub3
	jc	fail
	jf0	fail

pass:	PASS

fail:	FAIL



	ORG	0156H
recursive:
	dec	r0
	mov	a, r0
	jz	rec_end
	call	recursive
rec_end:
	ret


	ORG	0245H

sub1:	cpl	f0
	cpl	f1
	cpl	c
call2:	call	sub2
	jf0	sub1_1
	jmp	fail2
sub1_1:	jnc	fail2
	retr

sub2:	jf0	sub2_1
	jmp	fail2
sub2_1:	clr	f0
	jnc	fail2
	clr	c	
	retr

fail2:	FAIL


	ORG	0311H

sub3:	cpl	f0
	cpl	c
	call	sub4
	jf0	fail3
	jc	fail3
	ret

sub4:	jf0	sub4_1
	jmp	fail3
sub4_1:	clr	f0
	jnc	fail3
	clr	c
	ret

fail3:	FAIL
