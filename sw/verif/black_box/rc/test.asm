	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test RR(C) A.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #080H

	rr	a
	jb7	fail
	jb6	ok1_1
	jmp	fail

ok1_1:	rr	a
	jb6	fail
	jb5	ok1_2
	jmp	fail

ok1_2:	rr	a
	jb5	fail
	jb4	ok1_3
	jmp	fail

ok1_3:	rr	a
	jb4	fail
	jb3	ok1_4
	jmp	fail

ok1_4:	rr	a
	jb3	fail
	jb2	ok1_5
	jmp	fail

ok1_5:	rr	a
	jb2	fail
	jb1	ok1_6
	jmp	fail

ok1_6:	rr	a
	jb1	fail
	jb0	ok1_7
	jmp	fail

ok1_7:	rr	a
	jb0	fail
	jb7	ok2
	jmp	fail


ok2:	mov	a, #07FH
	cpl	c

	rrc	a
	jb7	ok2_1
	jmp	fail
ok2_1:	jb6	fail

	rrc	a
	jb6	ok2_2
	jmp	fail
ok2_2:	jb5	fail

	rrc	a
	jb5	ok2_3
	jmp	fail
ok2_3:	jb4	fail

	rrc	a
	jb4	ok2_4
	jmp	fail
ok2_4:	jb3	fail

	rrc	a
	jb3	ok2_5
	jmp	fail
ok2_5:	jb2	fail

	rrc	a
	jb2	ok2_6
	jmp	fail
ok2_6:	jb1	fail

	rrc	a
	jb1	ok2_7
	jmp	fail
ok2_7:	jb0	fail
	jnc	fail

	rrc	a
	jb0	ok2_8
	jmp	fail
ok2_8:	jc	fail

	rrc	a
	jc	ok2_9
	jmp	fail
ok2_9:	jb7	fail

pass:	PASS

fail:	FAIL
