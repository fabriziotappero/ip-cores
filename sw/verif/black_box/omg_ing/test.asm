	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the OMG and ING instructions.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; output 0 on G and check
	;; note: this is done before actually starting the
	;;       sequence because 0 will end the sequence for
	;;       the T411L flavour.
	x	0x0
	omg
	clra
	comp
	ing
	ske
	jmp	fail

	;; output 1 on G
	clra
	aisc	0x1
	x	0x0
	omg
	ing
	ske
	jmp	fail

	;; output 2 on G
	clra
	aisc	0x2
	x	0x0
	omg
	ing
	ske
	jmp	fail

	;; output 4 on G
	clra
	aisc	0x4
	x	0x0
	omg
	ing
	ske
	jmp	fail

	;; output 8 on G
	;; note: last action on COP411L
	clra
	aisc	0x8
	x	0x0
	omg
	ing
	ske
	jmp	fail

	;; output 0xf on G
	clra
	aisc	0xf
	x	0x0
	omg
	ing
	ske
	jmp	fail

	org	0x100
	include	"pass_fail.asm"
