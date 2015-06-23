	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test Program Memory bank selector with CALL and JMP.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test
	sel	mb1
	call	call1 & 07FFH
	sel	mb1
	jmp	jmp1  & 07FFH
	;; trap
	nop
	jmp	fail
	nop
	jmp	fail
	;;
jmp2:	sel	mb1
	call	call3 & 07FFH
	sel	mb1
	jmp	jmp3  & 07FFH
	;; trap
	nop
	jmp	fail
	nop
	jmp	fail
	;;
jmp4:	sel	mb1
	call	call5 & 07FFH
	sel	mb1
	jmp	jmp5  & 07FFH
	;; trap
	nop
	jmp	fail
	nop
	jmp	fail
jmp6:

pass:	PASS

fail:	FAIL

	ORG	0100H

	;; trap
	jmp	fail
	;;
call2:	sel	mb1
	ret
	;; trap
	jmp	fail
	;;
call4:	sel	mb0
	ret
	;; trap
	jmp	fail
	;;
call6:	sel	mb1
	ret



	ORG	0800H

	;; trap
	nop
	jmp	fail_hi
	nop
	jmp	fail_hi
	;;
jmp1:	sel	mb0
	call	call2 | 0800H
	sel	mb0
	jmp	jmp2  | 0800H
	;; trap
	nop
	jmp	fail_hi
	nop
	jmp	fail_hi
	;;
jmp3:	sel	mb0
	call	call4 | 0800H
	sel	mb0
	jmp	jmp4  | 0800H
	;; trap
	nop
	jmp	fail_hi
	nop
	jmp	fail_hi
	;;
jmp5:	sel	mb0
	call	call6 | 0800H
	sel	mb0
	jmp	jmp6  | 0800H
	;; trap
	nop
	jmp	fail_hi
	nop
	jmp	fail_hi


fail_hi:
	FAIL


	ORG	0900H
call1:	sel	mb0
	ret
	;; trap
	jmp	fail_hi
	;;
call3:	sel	mb1
	ret
	;; trap
	jmp	fail_hi
	;;
call5:	sel	mb0
	ret
	;; trap
	jmp	fail_hi
