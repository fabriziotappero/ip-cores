	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the STII instruction.
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

	;; now scan through all 8 locations and check the contents
	;; check location 0, data 0
	clra
	cab
	ske
	jmp	fail

	;; check location 1, data 1
	aisc	0x1
	cab
	ske
	jmp	fail

	;; check location 2, data 2
	aisc	0x1
	cab
	ske
	jmp	fail

	;; check location 3, data 3
	aisc	0x1
	cab
	ske
	jmp	fail

	;; check location 4, data 4
	aisc	0x1
	cab
	ske
	jmp	fail

	;; check location 5, data 5
	aisc	0x1
	cab
	ske
	jmp	fail

	;; check location 6, data 6
	aisc	0x1
	cab
	ske
	jmp	fail

	;; check location 7, data 7
	aisc	0x1
	cab
	ske
	jmp	fail


	jmp	pass

	org	0x100
	include	"pass_fail.asm"
