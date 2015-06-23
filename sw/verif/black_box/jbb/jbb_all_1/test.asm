
	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #0FFH
	jb0	ok_0
	jmp	fail

ok_0:	jb1	ok_1
	jmp	fail

ok_1:	jb2	ok_2
	jmp	fail

ok_2:	jb3	ok_3
	jmp	fail
	
ok_3:	jb4	ok_4
	jmp	fail

ok_4:	jb5	ok_5
	jmp	fail

ok_5:	jb6	ok_6
	jmp	fail

ok_6:	jb7	pass

fail:	FAIL

pass:	PASS
