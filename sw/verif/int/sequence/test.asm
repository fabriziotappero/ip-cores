	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks interrupt on a sequence of "transfer of control"
	;; instructions.
	;;

	;; the cpu type is defined on asl's command line

	include	"int_macros.inc"

	org	0x00
	clra

	int_flag_clear
	lei	0x02
	jp	int_mark

	org	0x030
int_mark:
	nop
	nop
int_instr:
	jmp	+
+	jp	+
+	jsrp	jsrp_target
	jsr	jsrp_target
	lqid
	nop
ret_instr:
	jmp	+
	org	0x040
+	int_flag_check
	jmp	pass


	org	0x080
jsrp_target:
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
	check_sa	ret_instr
	restore_c_m_a
	ret


	org	0x200
	include	"int_pass_fail.asm"
