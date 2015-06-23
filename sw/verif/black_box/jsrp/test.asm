	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the JSRP instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; preload data memory with jsrp target values
	stii	0x0
	stii	0x1
	stii	0x2
	stii	0x3
	stii	0x4
	stii	0x5
	stii	0x6
	stii	0x7

	cab
	jsrp	target_0
	;;
	aisc	0x1
	cab
	clra
	jsrp	target_1
	;;
	aisc	0x2
	cab
	clra
	jsrp	target_2
	;;
	aisc	0x3
	cab
	clra
	jsrp	target_3
	;;
	aisc	0x4
	cab
	clra
	jsrp	target_4
	;;
	aisc	0x5
	cab
	clra
	jsrp	target_5
	;;
	aisc	0x6
	cab
	clra
	jsrp	target_6
	;;
	aisc	0x7
	cab
	clra
	jsrp	target_7

	jmp	pass

	;; subroutine targets in page 2 & 3
	org	0x080
target_0:
	ske
	jmp	fail
	ret
	;;
	org	0x088
target_1:
	aisc	0x1
	ske
	jmp	fail
	clra
	ret
	;;
	org	0x090
target_2:
	aisc	0x2
	ske
	jmp	fail
	clra
	ret
	;;
	org	0x098
target_3:
	aisc	0x3
	ske
	jmp	fail
	clra
	ret
	;;
	org	0x0a0
target_4:
	aisc	0x4
	ske
	jmp	fail
	clra
	ret
	;;
	org	0x0a8
target_5:
	aisc	0x5
	ske
	jmp	fail
	clra
	ret
	;;
	org	0x0b0
target_6:
	aisc	0x6
	ske
	jmp	fail
	clra
	ret
	;;
	org	0x0b8
target_7:
	aisc	0x7
	ske
	jmp	fail
	clra
	ret

	jmp	fail

	org	0x100
	include	"pass_fail.asm"
