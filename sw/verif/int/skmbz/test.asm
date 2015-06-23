	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks interrupt on SKMBZ.
	;; AISC is interrupted twice:
	;;   1) no carry, thus no skip
	;;   2) carry, skip after interrupt completion
	;;

	;; the cpu type is defined on asl's command line

	include	"int_macros.inc"

	org	0x00
	clra

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
	skmbz	0x1
ret_instr_030:
	jmp	fail		; must be skipped!

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
	skmbz	0x1
ret_instr_0b0:
	jp	+		; must not be skipped!
	jmp	fail		; must be skipped!
+

	;; check whether interrupt really occured
	int_flag_check

	;;
	;; prepare next interrupt
	;;
	int_flag_clear
	;; write return instruction identifier to current M
	;; ret_instr_230 = 0x4
	clra
	aisc	0x4
	x	0

	lei	0x02
	jmp	int_mark_230

	org	0x22e
	jmp	fail
	org	0x230
int_mark_230:
	nop
	skmbz	0x3
int_instr_230:
	jmp	fail		; must be skipped
ret_instr_230:

	;; check whether interrupt really occured
	int_flag_check

	;;
	;; prepare next interrupt
	;;
	int_flag_clear
	;; write return instruction identifier to current M
	;; ret_instr_330 = 0x8
	clra
	aisc 0x8
	x	0

	lei	0x02
	jmp	int_mark_330

	org	0x32e
	jmp	fail
	org	0x330
int_mark_330:
	nop
	skmbz	0x3
int_instr_330:
	jp	+		; must not be skipped!
	jmp	fail
+
	nop
ret_instr_330:

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

	;; access current M of main program
	ldd	3, 14
	x	0
	skmbz	0x0
	jp	check_sa_030
	skmbz	0x1
	jp	check_sa_0b0
	skmbz	0x2
	jmp	check_sa_230
	skmbz	0x3
	jmp	check_sa_330
	jmp	fail

check_sa_030:
	check_sa	ret_instr_030
	jmp	int_finished
check_sa_0b0:
	check_sa	ret_instr_0b0
	jmp	int_finished
check_sa_230:
	check_sa	ret_instr_230
	jmp	int_finished
check_sa_330:
	check_sa	ret_instr_330

int_finished:
	restore_c_m_a
	ret
	;;
	;; *******************************************************************


	org	0x200
	include	"int_pass_fail.asm"
