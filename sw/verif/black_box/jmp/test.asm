	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the JMP instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	jmp	block_0


	org	0x00d
	jmp	fail
block_0:
	jmp	block_1
	jmp	fail

	org	0x10f
	jmp	fail
block_1:
	IF	MOMCPUNAME <> "COP410"
	jmp	block_2
	ELSEIF
	jmp	pass
	ENDIF
	jmp	fail

	org	0x120
	include	"pass_fail.asm"


	IF	MOMCPUNAME <> "COP410"

	org	0x21f
	jmp	fail
block_2:
	jmp	block_3
	jmp	fail

	org	0x32f
	jmp	fail
block_3:
	jmp	pass
	jmp	fail

	ENDIF
