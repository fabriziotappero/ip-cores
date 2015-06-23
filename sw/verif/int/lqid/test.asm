	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks interrupt on LQID.
	;;

	;; the cpu type is defined on asl's command line

	include	"int_macros.inc"

	org	0x00
	clra

	int_flag_clear

	;; prepare LQID
	clra
	comp
	x	0
	ld	0
	camq
	clra
	x	0
	clra
	aisc	0x5

	lei	0x06		; also enable L output drivers
	jp	int_mark

	org	0x030
int_mark:
	nop
	nop
int_instr:
	lqid
	inl			; read data from LQID
				; lower nibble is OD from DUT
ret_instr:
	;; disable L output drivers
	lei	0x0
	;; and check for 0x5 in M
	clra
	aisc	0x5
	ske
	jmp	fail

	nop
	int_flag_check
	jmp	pass


	;; -------------------------------------------------------------------
	;; LQID table
	;;
	org	0x050
	db	0x05f		; keep low nibble OD inactive


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
