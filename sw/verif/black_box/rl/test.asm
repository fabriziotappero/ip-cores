	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test RL(C) A.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #001H

	rl	a
	jb0	fail
	jb1	ok1_1
	jmp	fail

ok1_1:	rl	a
	jb1	fail
	jb2	ok1_2
	jmp	fail

ok1_2:	rl	a
	jb2	fail
	jb3	ok1_3
	jmp	fail

ok1_3:	rl	a
	jb3	fail
	jb4	ok1_4
	jmp	fail

ok1_4:	rl	a
	jb4	fail
	jb5	ok1_5
	jmp	fail

ok1_5:	rl	a
	jb5	fail
	jb6	ok1_6
	jmp	fail

ok1_6:	rl	a
	jb6	fail
	jb7	ok1_7
	jmp	fail

ok1_7:	rl	a
	jb7	fail
	jb0	ok2
	jmp	fail


ok2:	mov	a, #0FEH
	cpl	c

	rlc	a
	jb0	ok2_1
	jmp	fail
ok2_1:	jb1	fail

	rlc	a
	jb1	ok2_2
	jmp	fail
ok2_2:	jb2	fail

	rlc	a
	jb2	ok2_3
	jmp	fail
ok2_3:	jb3	fail

	rlc	a
	jb3	ok2_4
	jmp	fail
ok2_4:	jb4	fail

	rlc	a
	jb4	ok2_5
	jmp	fail
ok2_5:	jb5	fail

	rlc	a
	jb5	ok2_6
	jmp	fail
ok2_6:	jb6	fail

	rlc	a
	jb6	ok2_7
	jmp	fail
ok2_7:	jb7	fail
	jnc	fail

	rlc	a
	jb7	ok2_8
	jmp	fail
ok2_8:	jc	fail

	rlc	a
	jc	ok2_9
	jmp	fail
ok2_9:	jb0	fail


pass:	PASS

fail:	FAIL
