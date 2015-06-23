	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the LD instruction.
	;; Br can't be observed directly via XABR on COP41x.
	;; Therefore, Br address os observed indirectly via memory content.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; preload for digit of each data register
	;; Br = 0 -> data = 0x1
	lbi	0x0, 0x0
	stii	0x1
	;; Br = 1 -> data = 0x2
	lbi	0x1, 0x0
	stii	0x2
	;; Br = 2 -> data = 0x3
	lbi	0x2, 0x0
	stii	0x3
	;; Br = 3 -> data = 0x4
	lbi	0x3, 0x0
	stii	0x4

	;; *******************************************************************
	;; XOR 0
	;;
	;; Br(0) xor 0
	lbi	0x0, 0x0
	ld	0x0
	ske			; expect no change of Br
	jmp	fail

	;; Br(1) xor 0
	lbi	0x1, 0x0
	ld	0x0
	ske			; expect no change of Br
	jmp	fail

	;; Br(2) xor 0
	lbi	0x2, 0x0
	ld	0x0
	ske			; expect no change of Br
	jmp	fail

	;; Br(3) xor 0
	lbi	0x3, 0x0
	ld	0x0
	ske			; expect no change of Br
	jmp	fail


	;; *******************************************************************
	;; XOR 1
	;;
	;; Br(0) xor 1
	lbi	0x0, 0x0
	ld	0x1
	xad	3, 15		; save load data
	;; expect 0x2 at current Br
	clra
	aisc	0x2
	ske
	jmp	fail
	;; expect 0x1 in accumulator
	xad	3, 15		; restore load data
	aisc	0x1
	ske
	jmp	fail

	;; Br(1) xor 1
	lbi	0x1, 0x0
	ld	0x1
	xad	3, 15		; save load data
	;; expect 0x1 at current Br
	clra
	aisc	0x1
	ske
	jmp	fail
	;; expect 0x2 in accumulator
	xad	3, 15		; restore load data
	aisc	0xf
	nop
	ske
	jmp	fail

	;; Br(2) xor 1
	lbi	0x2, 0x0
	ld	0x1
	xad	3, 15		; save load data
	;; expect 0x4 at current Br
	clra
	aisc	0x4
	ske
	jmp	fail
	;; expect 0x3 in accumulator
	xad	3, 15		; restore load data
	aisc	0x1
	nop
	ske
	jmp	fail

	;; Br(3) xor 1
	lbi	0x3, 0x0
	ld	0x1
	xad	3, 15		; save load data
	;; expect 0x3 at current Br
	clra
	aisc	0x3
	ske
	jmp	fail
	;; expect 0x4 in accumulator
	xad	3, 15		; restore load data
	aisc	0xf
	nop
	ske
	jmp	fail

	;; *******************************************************************
	;; XOR 2
	;;
	;; Br(0) xor 2
	lbi	0x0, 0x0
	ld	0x2
	xad	3, 15		; save load data
	;; expect 0x3 at current Br
	clra
	aisc	0x3
	ske
	jmp	fail
	;; expect 0x1 in accumulator
	xad	3, 15		; restore load data
	aisc	0x2
	ske
	jmp	fail

	;; Br(1) xor 2
	lbi	0x1, 0x0
	ld	0x2
	xad	3, 15		; save load data
	;; expect 0x4 at current Br
	clra
	aisc	0x4
	ske
	jmp	fail
	;; expect 0x2 in accumulator
	xad	3, 15		; restore load data
	aisc	0x2
	ske
	jmp	fail

	;; Br(2) xor 2
	lbi	0x2, 0x0
	ld	0x2
	xad	3, 15		; save load data
	;; expect 0x1 at current Br
	clra
	aisc	0x1
	ske
	jmp	fail
	;; expect 0x3 in accumulator
	xad	3, 15		; restore load data
	aisc	0xe
	nop
	ske
	jmp	fail

	;; Br(3) xor 2
	lbi	0x3, 0x0
	ld	0x2
	xad	3, 15		; save load data
	;; expect 0x2 at current Br
	clra
	aisc	0x2
	ske
	jmp	fail
	;; expect 0x4 in accumulator
	xad	3, 15		; restore load data
	aisc	0xe
	nop
	ske
	jmp	fail

	;; *******************************************************************
	;; XOR 3
	;;
	;; Br(0) xor 3
	lbi	0x0, 0x0
	ld	0x3
	xad	3, 15		; save load data
	;; expect 0x4 at current Br
	clra
	aisc	0x4
	ske
	jmp	fail
	;; expect 0x1 in accumulator
	xad	3, 15		; restore load data
	aisc	0x3
	ske
	jmp	fail

	;; Br(1) xor 3
	lbi	0x1, 0x0
	ld	0x3
	xad	3, 15		; save load data
	;; expect 0x3 at current Br
	clra
	aisc	0x3
	ske
	jmp	fail
	;; expect 0x2 in accumulator
	xad	3, 15		; restore load data
	aisc	0x1
	ske
	jmp	fail

	;; Br(2) xor 3
	lbi	0x2, 0x0
	ld	0x3
	xad	3, 15		; save load data
	;; expect 0x2 at current Br
	clra
	aisc	0x2
	ske
	jmp	fail
	;; expect 0x3 in accumulator
	xad	3, 15		; restore load data
	aisc	0xf
	nop
	ske
	jmp	fail

	;; Br(3) xor 3
	lbi	0x3, 0x0
	ld	0x3
	xad	3, 15		; save load data
	;; expect 0x1 at current Br
	clra
	aisc	0x1
	ske
	jmp	fail
	;; expect 0x4 in accumulator
	xad	3, 15		; restore load data
	aisc	0xd
	nop
	ske
	jmp	fail


	jmp	pass
	
	org	0x100
	include	"pass_fail.asm"
