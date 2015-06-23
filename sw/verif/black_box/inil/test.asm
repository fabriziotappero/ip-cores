	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the INIL instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; check reset level of latches
	inil
	x	0
	skmbz	3
	jmp	fail
	skmbz	2		; CKO
	jmp	fail
	skmbz	0
	jmp	fail


	;; set IN to 0xf and recheck levels
	ogi	0xf
	nop
	nop
	inil
	x	0
	skmbz	3
	jmp	fail
	skmbz	2		; CKO
	jp	+
	jmp	fail
+	skmbz	0
	jmp	fail


	;; set IN0 to 0 and check that IL0 triggered
	ogi	0xe
	nop
	inil
	x	0
	skmbz	3
	jmp	fail
	skmbz	2		; CKO
	jp	+
	jmp	fail
+	skmbz	0
	jp	+
	jmp	fail
+

	jmp	page_1
	org	0x040
page_1:

	;; set IN3 to 0 and check that IL1 triggered
	ogi	0x6
	nop
	inil
	x	0
	skmbz	3
	jp	+
	jmp	fail
+	skmbz	2		; CKO
	jp	+
	jmp	fail
+	skmbz	0
	jmp	fail


	;; reload IN3 to trigger both IL latches
	ogi	0x9
	ogi	0x0
	nop
	inil
	x	0
	skmbz	3
	jp	+
	jmp	fail
+	skmbz	2		; CKO
	jmp	fail
	skmbz	0
	jp	+
	jmp	fail
+


	;; check that INIL prevents setting of IL latches
	;; when both events occur at the same cycle
	ogi	0x9
	ogi	0x0
	inil
	x	0
	skmbz	3
	jmp	fail
	skmbz	2		; CKO
	jmp	fail
	skmbz	0
	jmp	fail


	jmp	pass


	org	0x100	
	include	"pass_fail.asm"
