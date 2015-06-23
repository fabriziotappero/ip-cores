	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks interrupt on JSR and RET.
	;;

	;; the cpu type is defined on asl's command line

	include	"int_macros.inc"

	org	0x00
	clra

	int_flag_clear
	;; write return instruction identifier to current M
	;; ret_instr_230 = 0x01
	clra
	aisc	0x1
	x	0

	lei	0x02
	jmp	int_mark_230

	org	0x230
int_mark_230:
	nop
	nop
int_instr_230:
	jsr	prep_2b0
	nop
ret_instr_2b0:
	;; check whether interrupt really occured
	int_flag_check

	jmp	pass


	org	0x290
	jmp	fail
	org	0x292
prep_2b0:
	nop
ret_instr_230:
	;; check whether interrupt really occured
	int_flag_check

	;;
	;; prepare next interrupt
	;;
	int_flag_clear
	;; write return instruction identifier to current M
	;; ret_instr_2b0 = 0x2
	clra
	aisc	0x2
	x	0

	lei	0x02
	jp	int_mark_2b0

	org	0x2ae
	jmp	fail
	org	0x2b0
int_mark_2b0:
	nop
	nop
int_instr_2b0:
	ret
	

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
	jp	check_sa_230
	skmbz	0x1
	jp	check_sa_2b0
	jmp	fail

check_sa_230:
	check_sa	ret_instr_230
	jmp	int_finished
check_sa_2b0:
	check_sa	ret_instr_2b0

int_finished:
	restore_c_m_a
	ret
	;;
	;; *******************************************************************


	org	0x200
	include	"int_pass_fail.asm"
