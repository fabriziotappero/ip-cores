	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the XABR instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; preload digit 0 of all registers with different data
	lbi	0, 0
	stii	0x4
	stii	0x0		; register number
	lbi	1, 0
	stii	0x5
	stii	0x1		; register number
	lbi	2, 0
	stii	0x6
	stii	0x2		; register number
	lbi	3, 0
	stii	0x7
	stii	0x3		; register number


	;; *******************************************************************
	;; check Br -> A path of XABR
	;;
	lbi	0, 0
	xabr
	lbi	0, 1
	ske			; check against preloaded register number
	jmp	fail
	;;
	lbi	1, 0
	xabr
	lbi	1, 1
	ske			; check against preloaded register number
	jmp	fail
	;;
	lbi	2, 0
	xabr
	lbi	2, 1
	ske			; check against preloaded register number
	jmp	fail
	;;
	lbi	3, 0
	xabr
	lbi	3, 1
	ske			; check against preloaded register number
	jmp	fail


	;; *******************************************************************
	;; check A -> Br path of XABR
	;;
	lbi	0, 0		; set Bd

	;; check for Br = 3
	clra
	aisc	0x3
	xabr
	;; expect 0x7 @ 3, 0
	clra
	aisc	0x7
	ske
	jmp	fail

	;; check for Br = 2
	clra
	aisc	0x2
	xabr
	;; expect 0x6 @ 2, 0
	clra
	aisc	0x6
	ske
	jmp	fail

	;; check for Br = 1
	clra
	aisc	0x1
	xabr
	;; expect 0x5 @ 1, 0
	clra
	aisc	0x5
	ske
	jmp	fail

	;; check for Br = 0
	clra
	xabr
	;; expect 0x4 @ 0, 0
	clra
	aisc	0x4
	ske
	jmp	fail


	jmp	pass

	
	include	"pass_fail.asm"
