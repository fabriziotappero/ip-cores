	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the JID instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	aisc	0x6
	x	0x0
	clra
	aisc	0x8
	jid
	jmp	fail

goon_1:
	x	0x0
	aisc	0x4
	nop
	x	0x0
	jid
	jmp	fail

goon_2:
	x	0x0
	aisc	0x2
	x	0x0
	jid
	jmp	fail
goon_3:
	x	0x0
	aisc	0x1
	x	0x0
	jid
	jmp	fail

goon_4:

	jmp	pass


loc_fail:
	jmp	fail

	org	0x080
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	goon_1
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	goon_2
	db	loc_fail
	db	goon_3
	db	goon_4
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail
	db	loc_fail

	jmp	fail
	org	0x100
	include	"pass_fail.asm"
