	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks interrupt on JID.
	;;

	;; the cpu type is defined on asl's command line

	include	"int_macros.inc"

	org	0x00
	clra

	int_flag_clear
	lei	0x02

	;; prepare JID
	clra
	x	0
	clra
	aisc	0x4

	jp	int_mark

	org	0x030
int_mark:
	nop
	nop
int_instr:
	jid


	;; -------------------------------------------------------------------
	;; JID table
	;;
	org	0x040
	db	0x060


	org	0x05e
	jmp	fail
	org	0x060
	nop	
ret_instr:
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
	check_sa	ret_instr
	restore_c_m_a
	ret


	org	0x200
	include	"int_pass_fail.asm"
