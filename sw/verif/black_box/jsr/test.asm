	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the JSR instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; preload data memory with jsr target values
	stii	0x0
	stii	0x1
	stii	0x2
	stii	0x3
	stii	0x4
	stii	0x5
	stii	0x6
	stii	0x7

	cab
	jsr	target_0
	;;
	aisc	0x1
	cab
	clra
	jsr	target_1
	;;
	aisc	0x2
	cab
	clra
	jsr	target_2
	;;
	aisc	0x3
	cab
	clra
	jsr	target_3
	;;
	IF	MOMCPUNAME <> "COP410"
	aisc	0x4
	cab
	clra
	jsr	target_4
	;;
	aisc	0x5
	cab
	clra
	jsr	target_5
	;;
	aisc	0x6
	cab
	clra
	jsr	target_6
	;;
	aisc	0x7
	cab
	clra
	jsr	target_7
	ENDIF

	jmp	pass

	;; subroutine targets
	org	0x06f
target_0:
	ske
	jmp	fail
	ret
	;;
	org	0x09e
target_1:
	aisc	0x1
	ske
	jmp	fail
	clra
	ret
	;;
	org	0x12d
target_2:
	aisc	0x2
	ske
	jmp	fail
	clra
	ret
	;;
	org	0x13c
target_3:
	aisc	0x3
	ske
	jmp	fail
	clra
	ret
	;;
	IF	MOMCPUNAME <> "COP410"
	org	0x24b
target_4:
	aisc	0x4
	ske
	jmp	fail
	clra
	ret
	;;
	org	0x2da
target_5:
	aisc	0x5
	ske
	jmp	fail
	clra
	ret
	;;
	org	0x369
target_6:
	aisc	0x6
	ske
	jmp	fail
	clra
	ret
	;;
	org	0x378
target_7:
	aisc	0x7
	ske
	jmp	fail
	clra
	ret
	ENDIF

	org	0x1d0
	include	"pass_fail.asm"
