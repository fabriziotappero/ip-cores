	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test JNI.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	jni	fail

	mov	r0, #000H
poll:	jni	pass
	djnz	r0, poll

fail:	FAIL

pass:	PASS
