	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the JP instruction.
	;; Both for pages 2,3 and other pages.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	jmp	page_0
	jmp	fail

	org	0x030 - 2
	jmp	fail
page_0:
	jp	page_0_loc
	jmp	fail
page_0_loc:
	jmp	page_1
	jmp	fail

	org	0x048 - 2
	jmp	fail
page_1:
	jp	page_1_loc
	jmp	fail
page_1_loc:
	jmp	page_4
	jmp	fail


	;; *******************************************************************
	;;
	org	0x080 - 2
	jmp	fail
page_2:
	jp	page_3_1
	jmp	fail

	org	0x08a - 2
	jmp	fail
page_2_2:
	jp	page_3_3
	jmp	fail

	org	0x093 - 2
	jmp	fail
page_2_4:
	jp	page_3_5
	jmp	fail

	org	0x09b - 2
	jmp	fail
page_2_6:
	jp	page_3_7
	jmp	fail

	org	0x0b9 - 2
	jmp	fail
page_2_8:
	jp	page_3_9
	jmp	fail


	org	0x0c5 - 2
	jmp	fail
page_3_1:
	jp	page_2_2
	jmp	fail

	org	0x0cd - 2
	jmp	fail
page_3_3:
	jp	page_2_4
	jmp	fail

	org	0x0d1 - 2
	jmp	fail
page_3_5:
	jp	page_2_6
	jmp	fail

	org	0x0da - 2
	jmp	fail
page_3_7:
	jp	page_2_8
	jmp	fail

	org	0x0e5 - 2
	jmp	fail
page_3_9:
	jmp	pass
	jmp	fail


	org	0x115 - 2
	jmp	fail
page_4:
	jp	page_4_loc
	jmp	fail
page_4_loc:
	jmp	page_5
	jmp	fail

	include	"pass_fail.asm"


	org	0x15c - 2
	jmp	fail
page_5:
	jp	page_5_loc
	jmp	fail
page_5_loc:
	jmp	page_6
	jmp	fail

	org	0x1a1 - 2
	jmp	fail
page_6:
	jp	page_6_loc
	jmp	fail
page_6_loc:
	jmp	page_7
	jmp	fail

	org	0x1c9 - 2
	jmp	fail
page_7:
	jp	page_7_loc
	jmp	fail
page_7_loc:
	IF	MOMCPUNAME <> "COP410"
	jmp	page_8
	ELSEIF
	jmp	page_2
	ENDIF
	jmp	fail


	IF	MOMCPUNAME <> "COP410"

	org	0x21e - 2
	jmp	fail
page_8:
	jp	page_8_loc
	jmp	fail
page_8_loc:
	jmp	page_9
	jmp	fail

	org	0x263 - 2
	jmp	fail
page_9:
	jp	page_9_loc
	jmp	fail
page_9_loc:
	jmp	page_10
	jmp	fail

	org	0x2a8 - 2
	jmp	fail
page_10:
	jp	page_10_loc
	jmp	fail
page_10_loc:
	jmp	page_11
	jmp	fail

	org	0x2fa - 2
	jmp	fail
page_11:
	jp	page_11_loc
	jmp	fail
page_11_loc:
	jmp	page_12
	jmp	fail

	org	0x327 - 2
	jmp	fail
page_12:
	jp	page_12_loc
	jmp	fail
page_12_loc:
	jmp	page_13
	jmp	fail

	org	0x370 - 2
	jmp	fail
page_13:
	jp	page_13_loc
	jmp	fail
page_13_loc:
	jmp	page_14
	jmp	fail

	org	0x3bb - 2
	jmp	fail
page_14:
	jp	page_14_loc
	jmp	fail
page_14_loc:
	jmp	page_15
	jmp	fail

	org	0x3e9 - 2
	jmp	fail
page_15:
	jp	page_15_loc
	jmp	fail
page_15_loc:
	jmp	page_2
	jmp	fail

	ENDIF
