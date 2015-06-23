	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test JMPP.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

table	MACRO	data
	DB	data & 0FFH
	ENDM

	ORG	0

	;; Start of test
	mov	a, #000H
	jmp	table1

fail:	FAIL

pass:	PASS


	;; *******************************************************************
	ORG	0100H
	;;
	table	t1_e00
	table	t1_e01
	table	t1_e02
	table	t1_e03
	table	t1_e04
	table	t1_e05
	table	t1_e06
	table	t1_e07
	table	t1_e08
	table	t1_e09
	table	t1_e0a
	table	t1_e0b
	table	t1_e0c
	table	t1_e0d
	table	t1_e0e
	table	t1_e0f
	table	t1_e10
	table	t1_e11
	table	t1_e12
	table	t1_e13
	table	t1_e14
	table	t1_e15
	table	t1_e16
	table	t1_e17
	table	t1_e18
	table	t1_e19
	table	t1_e1a
	table	t1_e1b
	table	t1_e1c
	table	t1_e1d
	table	t1_e1e
	table	t1_e1f
	;;
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	;;
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	;;
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	;;
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	;;
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	;;
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01
	table	t1_e01

	jmp	fail
table1:	jmpp	@a
	jmp	fail
	
t1_e00:	mov	a, #007H
	jmp	table2
	;;
t1_e01:	jmp	fail
	jmp	fail
	;;
t1_e02:	mov	a, #005H
	jmp	table2
	;;
t1_e03:	jmp	fail
	jmp	fail
	;;
t1_e04:	mov	a, #003H
	jmp	table2
	;;
t1_e05:	jmp	fail
	jmp	fail
	;;
t1_e06:	mov	a, #001H
	jmp	table2
	;;
t1_e07:	jmp	fail
	jmp	fail
	;;
t1_e08:	jmp	fail
	jmp	fail
	;;
t1_e09:	jmp	fail
	jmp	fail
	;;
t1_e0a:	jmp	fail
	jmp	fail
	;;
t1_e0b:	jmp	fail
	jmp	fail
	;;
t1_e0c:	jmp	fail
	jmp	fail
	;;
t1_e0d:	jmp	fail
	jmp	fail
	;;
t1_e0e:	jmp	fail
	jmp	fail
	;;
t1_e0f:	jmp	fail
	jmp	fail
	;;
t1_e10:	mov	a, #018H
	jmp	table2
	;;
t1_e11:	jmp	fail
	jmp	fail
	;;
t1_e12:	jmp	fail
	jmp	fail
	;;
t1_e13:	jmp	fail
	jmp	fail
	;;
t1_e14:	jmp	fail
	jmp	fail
	;;
t1_e15:	jmp	fail
	jmp	fail
	;;
t1_e16:	jmp	fail
	jmp	fail
	;;
t1_e17:	jmp	fail
	jmp	fail
	;;
t1_e18:	jmp	fail
	jmp	fail
	;;
t1_e19:	jmp	fail
	jmp	fail
	;;
t1_e1a:	jmp	fail
	jmp	fail
	;;
t1_e1b:	jmp	fail
	jmp	fail
	;;
t1_e1c:	jmp	fail
	jmp	fail
	;;
t1_e1d:	jmp	fail
	jmp	fail
	;;
t1_e1e:	jmp	fail
	jmp	fail
	;;
t1_e1f:	jmp	pass
	jmp	fail


	;; *******************************************************************
	ORG	512
	;;
	table	t2_e00
	table	t2_e01
	table	t2_e02
	table	t2_e03
	table	t2_e04
	table	t2_e05
	table	t2_e06
	table	t2_e07
	table	t2_e08
	table	t2_e09
	table	t2_e0a
	table	t2_e0b
	table	t2_e0c
	table	t2_e0d
	table	t2_e0e
	table	t2_e0f
	table	t2_e10
	table	t2_e11
	table	t2_e12
	table	t2_e13
	table	t2_e14
	table	t2_e15
	table	t2_e16
	table	t2_e17
	table	t2_e18
	table	t2_e19
	table	t2_e1a
	table	t2_e1b
	table	t2_e1c
	table	t2_e1d
	table	t2_e1e
	table	t2_e1f
	;;
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	;;
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	;;
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	;;
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	;;
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	;;
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01
	table	t2_e01

	jmp	fail
table2:	jmpp	@a
	jmp	fail
	
t2_e00:	jmp	fail
	jmp	fail
	;;
t2_e01:	mov	a, #010H
	jmp	table1
	;;
t2_e02:	jmp	fail
	jmp	fail
	;;
t2_e03:	mov	a, #006H
	jmp	table1
	;;
t2_e04:	jmp	fail
	jmp	fail
	;;
t2_e05:	mov	a, #004H
	jmp	table1
	;;
t2_e06:	jmp	fail
	jmp	fail
	;;
t2_e07:	mov	a, #002H
	jmp	table1
	;;
t2_e08:	jmp	fail
	jmp	fail
	;;
t2_e09:	jmp	fail
	jmp	fail
	;;
t2_e0a:	jmp	fail
	jmp	fail
	;;
t2_e0b:	jmp	fail
	jmp	fail
	;;
t2_e0c:	jmp	fail
	jmp	fail
	;;
t2_e0d:	jmp	fail
	jmp	fail
	;;
t2_e0e:	jmp	fail
	jmp	fail
	;;
t2_e0f:	jmp	fail
	jmp	fail
	;;
t2_e10:	jmp	fail
	jmp	fail
	;;
t2_e11:	jmp	fail
	jmp	fail
	;;
t2_e12:	jmp	fail
	jmp	fail
	;;
t2_e13:	jmp	fail
	jmp	fail
	;;
t2_e14:	jmp	fail
	jmp	fail
	;;
t2_e15:	jmp	fail
	jmp	fail
	;;
t2_e16:	jmp	fail
	jmp	fail
	;;
t2_e17:	jmp	fail
	jmp	fail
	;;
t2_e18:	mov	a, #01FH
	jmp	table1
	;;
t2_e19:	jmp	fail
	jmp	fail
	;;
t2_e1a:	jmp	fail
	jmp	fail
	;;
t2_e1b:	jmp	fail
	jmp	fail
	;;
t2_e1c:	jmp	fail
	jmp	fail
	;;
t2_e1d:	jmp	fail
	jmp	fail
	;;
t2_e1e:	jmp	fail
	jmp	fail
	;;
t2_e1f:	jmp	fail
	jmp	fail
