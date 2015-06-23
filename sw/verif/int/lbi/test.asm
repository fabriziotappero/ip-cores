	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks interrupt on LBI.
	;; LBI is interrupted twice:
	;;   1) short, 1 byte instruction
	;;   2) long, 2 byte instruction
	;;

	;; the cpu type is defined on asl's command line

	include	"int_macros.inc"

	org	0x00
	clra

	;; prepare RAM digits
	lbi	0, 3
	stii	0x3
	lbi	0, 9
	stii	0x9
	lbi	0, 0		; default RAM location

	int_flag_clear
	;; write return instruction identifier to current M
	;; ret_instr_030 = 0x01
	clra
	aisc	0x1
	x	0

	lei	0x02
	jp	int_mark_030

	org	0x030
int_mark_030:
	nop
	nop
int_instr_030:
	lbi	0, 9		; short LBI
	nop
ret_instr_030:
	nop

	;; check whether interrupt really occured
	int_flag_check

	;;
	;; prepare next interrupt
	;;
	int_flag_clear
	;; write return instruction identifier to current M
	;; ret_instr_0b0 = 0x2
	clra
	aisc	0x2
	x	0

	lei	0x02
	jmp	int_mark_0b0

	org	0x0ae
	jmp	fail
	org	0x0b0
int_mark_0b0:
	nop
	nop
int_instr_0b0:
	lbi	0, 3		; long LBI
	nop
ret_instr_0b0:
	nop

	;; check whether interrupt really occured
	int_flag_check
	jmp	pass
	

	;; *******************************************************************
	;; Interrupt routine
	;;
	org	0x0fd
	jmp	fail
int_routine:
	nop
	save_a_m_c

	int_flag_set

	;; read interrupt location selector
	lbi	0, 0
	ldd	0, 0
	x	0
	skmbz	0x0
	jp	check_sa_030
	skmbz	0x1
	jmp	check_sa_0b0
	jmp	fail

check_sa_030:
	check_sa	ret_instr_030
	;; check saved contents of 'current M'
	;; expect 0x9
	lbi	3, 14
	clra
	aisc	0x9
	ske
	jmp	fail
	jmp	int_finished

check_sa_0b0:
	check_sa	ret_instr_0b0
	;; check saved contents of 'current M'
	;; expect 0x3
	lbi	3, 14
	clra
	aisc	0x3
	ske
	jmp	fail

int_finished:
	lbi	0, 0
	restore_c_m_a
	ret
	;;
	;; *******************************************************************


	org	0x200
	include	"int_pass_fail.asm"
