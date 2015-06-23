	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks interrupt on JSRP and RETSK.
	;;

	;; the cpu type is defined on asl's command line

	include	"int_macros.inc"

	org	0x00
	clra

	int_flag_clear
	;; write return instruction identifier to current M
	;; ret_instr_1b0 = 0x01
	clra
	aisc	0x1
	x	0

	lei	0x02
	jmp	int_mark_1b0

	org	0x1b0
int_mark_1b0:
	nop
	nop
int_instr_1b0:
	jsrp	prep_0b0
	aisc	0x1		; to be skipped by retsk
ret_instr_0b0:
	;; check whether aisc has been skipped
	x	0
	clra
	ske
	jmp	fail
	;; check whether interrupt really occured
	int_flag_check

	jmp	pass


	org	0x090
	jmp	fail
	org	0x092
prep_0b0:
	nop
ret_instr_1b0:
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
	jp	int_mark_0b0

	org	0x0ae
	jmp	fail
	org	0x0b0
int_mark_0b0:
	nop
	clra
int_instr_0b0:
	retsk
	

	;; *******************************************************************
	;; Interrupt routine
	;;
	org	0x0fd
	jmp	fail
int_routine:
	nop
	save_a_m_c

	int_flag_set

	;; access current M of main program
	ldd	3, 14
	x	0
	skmbz	0x0
	jp	check_sa_1b0
	skmbz	0x1
	jp	check_sa_0b0
	jmp	fail

check_sa_1b0:
	check_sa	ret_instr_1b0
	jmp	int_finished
check_sa_0b0:
	check_sa	ret_instr_0b0

int_finished:
	restore_c_m_a
	ret
	;;
	;; *******************************************************************


	org	0x200
	include	"int_pass_fail.asm"
