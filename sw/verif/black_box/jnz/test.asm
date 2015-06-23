	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test JNZ instruction.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	mov	a, #000H
	jnz	fail

	mov	a, #001H
	jnz	ok_01
	jmp	fail

ok_01:	mov	a, #002H
	jnz	ok_02
	jmp	fail

ok_02:	mov	a, #004H
	jnz	ok_04
	jmp	fail

ok_04:	mov	a, #008H
	jnz	ok_08
	jmp	fail

ok_08:	mov	a, #010H
	jnz	ok_10
	jmp	fail

ok_10:	mov	a, #020H
	jnz	ok_20
	jmp	fail

ok_20:	mov	a, #040H
	jnz	ok_40
	jmp	fail

ok_40:	mov	a, #080H
	jnz	pass

fail:	FAIL

pass:	PASS
