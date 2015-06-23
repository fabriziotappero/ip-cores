	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test ADD A, data without carry.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #000H

	add	a, #055H
	jz	fail
	;; exact check for 055H
	jb0	ok_1
	jmp	fail

ok_1:	jb1	fail

	jb2	ok_2
	jmp	fail

ok_2:	jb3	fail

	jb4	ok_4
	jmp	fail

ok_4:	jb5	fail

	jb6	ok_6
	jmp	fail

ok_6:	jb7	fail

	add	a, #0AAH
	jz	fail
	add	a, #001H
	jnz	fail

	add	a, #011111110B
	jb0	fail

	add	a, #011111111B
	jb1	fail
	jb0	ko_1
	jmp	fail

ko_1:	add	a, #011111110B
	jb2	fail
	jb1	ko_2
	jmp	fail

ko_2:	add	a, #011111100B
	jb3	fail
	jb2	ko_3
	jmp	fail

ko_3:	add	a, #011111000B
	jb4	fail
	jb3	ko_4
	jmp	fail

ko_4:	add	a, #011110000B
	jb5	fail
	jb4	ko_5
	jmp	fail

ko_5:	add	a, #011100000B
	jb6	fail
	jb5	ko_6
	jmp	fail

ko_6:	add	a, #011000000B
	jb7	fail
	jb6	pass

fail:	FAIL

pass:	PASS
