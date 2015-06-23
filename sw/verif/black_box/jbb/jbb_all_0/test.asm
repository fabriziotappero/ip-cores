
	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #000H
	jb0	fail
	jb1	fail
	jb2	fail
	jb3	fail
	jb4	fail
	jb5	fail
	jb6	fail
	jb7	fail

pass:	PASS

fail:	FAIL
