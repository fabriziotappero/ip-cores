	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the RMB and SMB instructions.
	;; Starting with 0 in M, all bits are set and then reset.
	;; All intermediate values are checked.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra


	;; *******************************************************************
	;; Set bits
	;;

	;; clear M
	X	0x0
	clra

	;; set bit 0
	smb	0x0
	aisc	0x1
	ske
	jmp	fail

	;; set bit 1
	smb	0x1
	aisc	0x2
	ske
	jmp	fail

	;; set bit 2
	smb	0x2
	aisc	0x4
	ske
	jmp	fail

	;; set bit 3
	smb	0x3
	aisc	0x8
	ske
	jmp	fail


	;; *******************************************************************
	;; Reset bits
	;;

	;; reset bit 0
	rmb	0x0
	comp
	aisc	0x1
	comp
	ske
	jmp	fail

	;; reset bit 1
	rmb	0x1
	comp
	aisc	0x2
	comp
	ske
	jmp	fail

	;; reset bit 2
	rmb	0x2
	comp
	aisc	0x4
	comp
	ske
	jmp	fail

	;; reset bit 3
	rmb	0x3
	comp
	aisc	0x8
	comp
	ske
	jmp	fail


	;; test passed
	jmp	pass


	org	0x100
	include	"pass_fail.asm"
