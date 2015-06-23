	;; *******************************************************************
	;; $Id: int_pass_fail.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Provides pass/fail signalling via port D for interrupt tests.
	;;
	;; Signalling on D:
	;;   0x1
	;;   0x2
	;;   0x4
	;;   0x8
	;;    0xf -> pass
	;;    0x0 -> fail
	;;

	;; catch spurious code execution
	jmp	fail

PROLOGUE	MACRO
	;; output 0x1 on D
	clra
	aisc	0x1
	cab
	obd
	;; output 0x2 on D
	aisc	0x1
	cab
	obd
	;; output 0x4 on D
	aisc	0x2
	cab
	obd
	;; output 0x8 on D
	aisc	0x4
	cab
	obd
	ENDM


pass:
	PROLOGUE
	;; output 0xf to D
	aisc	0x7
	cab
	obd
	jp	.

fail:
	PROLOGUE
	;; output 0x0 to D
	clra
	cab
	obd
	jp	.
