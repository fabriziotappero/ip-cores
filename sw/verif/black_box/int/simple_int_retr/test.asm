	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test simple interrupt/RETR requences.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	jmp	start_user


	ORG	3
	cpl	f1
	cpl	f0
	mov	r1, #060H
int_loop:
	djnz	r1, int_loop
	jf1	int_goon
	jmp	fail
int_goon:	
	dis	i
	retr


	ORG	020H
start_user:
	mov	r0, #080H
	en	i
	nop
loop1:	djnz	r0, loop1
	jf0	fail
	jf1	goon1
	jmp	fail

goon1:	mov	r0, #080H
	cpl	f1
	en	i
loop2:	djnz	r0, loop2
	jf0	fail
	jf1	pass

fail:	FAIL

pass:	PASS
