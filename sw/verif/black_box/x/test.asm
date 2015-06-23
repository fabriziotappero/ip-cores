	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the X instruction.
	;; Br can't be observed directly via XABR on COP41x.
	;; Therefore, Br address is observed indirectly via memory content.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; preload a digit of each data register
	;; Br = 0 -> data = 0x1
	lbi	0, 0
	stii	0x1
	;; Br = 1 -> data = 0x2
	lbi	1, 0
	stii	0x2
	;; Br = 2 -> data = 0x3
	lbi	2, 0
	stii	0x3
	;; Br = 3 -> data = 0x4
	lbi	3, 0
	stii	0x4


	;; *******************************************************************
	;; XOR 0
	;;
	;; Br(0) xor 0
	clra
	aisc	0xf
	lbi	0, 0
	x	0x0
	xad	3, 15		; save A
	;; expect 0xf in M
	clra
	aisc	0xf
	ske
	jmp	fail
	xad	3, 15		; restore A
	x	0x0
	;; expect 0x1 in M
	clra
	aisc	0x1
	ske
	jmp	fail

	;; Br(1) xor 0
	clra
	aisc	0xf
	lbi	1, 0
	x	0x0
	xad	3, 15		; save A
	;; expect 0xf in M
	clra
	aisc	0xf
	ske
	jmp	fail
	xad	3, 15		; restore A
	x	0x0
	;; expect 0x2 in M
	clra
	aisc	0x2
	ske
	jmp	fail

	;; Br(2) xor 0
	clra
	aisc	0xf
	lbi	2, 0
	x	0x0
	xad	3, 15		; save A
	;; expect 0xf in M
	clra
	aisc	0xf
	ske
	jmp	fail
	xad	3, 15		; restore A
	x	0x0
	;; expect 0x3 in M
	clra
	aisc	0x3
	ske
	jmp	fail

	;; Br(3) xor 0
	clra
	aisc	0xf
	lbi	3, 0
	x	0x0
	xad	3, 15		; save A
	;; expect 0xf in M
	clra
	aisc	0xf
	ske
	jmp	fail
	xad	3, 15		; restore A
	x	0x0
	;; expect 0x4 in M
	clra
	aisc	0x4
	ske
	jmp	fail


	clra
	aisc	0xf
	;; *******************************************************************
	;; XOR 1
	;;
	;; Br(0) & Br(1) xor 1
	lbi	0, 0
	x	0x1		; Br(0)=0xf, A=0x1, now Br(1)
	xad	3, 15		; save A
	;; expect 0x2 in M
	clra
	aisc	0x2
	ske
	jmp	fail
	xad	3, 15		; restore A
	x	0x1		; Br(1)=0x1, A=0x2, now Br(0)
	xad	3, 15		; save A
	;; expect 0xf in M
	clra
	aisc	0xf
	ske
	jmp	fail
	xad	3, 15		; restore A
	x	0x1		; Br(0)=0x2, A=0xf, now Br(1)
	xad	3, 15		; save A
	;; expect 0x1 in M
	clra
	aisc	0x1
	ske
	jmp	fail
	xad	3, 15		; restore A
	;; swap all back
	x	0x1		; Br(1)=0xf, A=0x1, now Br(0)
	x	0x1		; Br(0)=0x1, A=0x2, now Br(1)
	x	0x1		; Br(1)=0x2, A=0xf, now Br(0)
	;; same memory & accumulator content as before

	;; Br(2) & Br(3) xor 1
	lbi	2, 0
	x	0x1		; Br(2)=0xf, A=0x3, now Br(3)
	xad	3, 15		; save A
	;; expect 0x4 in M
	clra
	aisc	0x4
	ske
	jmp	fail
	xad	3, 15		; restore A
	x	0x1		; Br(3)=0x3, A=0x4, now Br(2)
	xad	3, 15		; save A
	;; expect 0xf in M
	clra
	aisc	0xf
	ske
	jmp	fail
	xad	3, 15		; restore A
	x	0x1		; Br(2)=0x4, A=0xf, now Br(3)
	xad	3, 15		; save A
	;; expect 0x3 in M
	clra
	aisc	0x3
	ske
	jmp	fail
	xad	3, 15		; restore A
	;; swap all back
	x	0x1		; Br(3)=0xf, A=0x3, now Br(2)
	x	0x1		; Br(2)=0x3, A=0x4, now Br(3)
	x	0x1		; Br(3)=0x4, A=0xf, now Br(2)
	;; same memory & accumulator content as before

	;; now check that all
	clra
	lbi	0, 0
	aisc	0x1
	ske			; Br(0) == 1 ?
	jmp	fail
	lbi	1, 0
	aisc	0x1
	ske			; Br(1) == 2 ?
	jmp	fail
	lbi	2, 0
	aisc	0x1
	ske			; Br(2) == 3 ?
	jmp	fail
	lbi	3, 0
	aisc	0x1
	ske			; Br(3) == 4 ?
	jmp	fail


	clra
	aisc	0xf
	;; *******************************************************************
	;; XOR 2
	;;
	;; Br(0) & Br(2) xor 2
	lbi	0x0, 0x0
	x	0x2		; Br(0)=0xf, A=0x1, now Br(2)
	xad	3, 15		; save A
	;; expect 0x3 in M
	clra
	aisc	0x3
	ske
	jmp	fail
	xad	3, 15		; restore A
	x	0x2		; Br(2)=0x1, A=0x3, now Br(0)
	xad	3, 15		; save A
	;; expect 0xf in M
	clra
	aisc	0xf
	ske
	jmp	fail
	xad	3, 15		; restore A
	x	0x2		; Br(0)=0x3, A=0xf, now Br(2)
	xad	3, 15		; save A
	;; expect 0x1 in M
	clra
	aisc	0x1
	ske
	jmp	fail
	xad	3, 15		; restore A
	;; swap all back
	x	0x2		; Br(2)=0xf, A=0x1, now Br(0)
	x	0x2		; Br(0)=0x1, A=0x3, now Br(2)
	x	0x2		; Br(2)=0x3, A=0xf, now Br(0)
	;; same memory & accumulator content as before

	;; Br(1) & Br(3) xor 2
	lbi	0x1, 0x0
	x	0x2		; Br(1)=0xf, A=0x2, now Br(3)
	xad	3, 15		; save A
	;; expect 0x4 in M
	clra
	aisc	0x4
	ske
	jmp	fail
	xad	3, 15		; restore A
	x	0x2		; Br(3)=0x2, A=0x4, now Br(1)
	xad	3, 15		; save A
	;; expect 0xf in M
	clra
	aisc	0xf
	ske
	jmp	fail
	xad	3, 15		; restore A
	x	0x2		; Br(1)=0x4, A=0xf, now Br(3)
	xad	3, 15		; save A
	;; expect 0x2 in M
	clra
	aisc	0x2
	ske
	jmp	fail
	xad	3, 15		; restore A
	;; swap all back
	x	0x2		; Br(3)=0xf, A=0x2, now Br(1)
	x	0x2		; Br(1)=0x2, A=0x4, now Br(3)
	x	0x2		; Br(3)=0x4, A=0xf, now Br(1)
	;; same memory & accumulator content as before

	;; now check that all
	clra
	lbi	0, 0
	aisc	0x1
	ske			; Br(0) == 1 ?
	jmp	fail
	lbi	1, 0
	aisc	0x1
	ske			; Br(1) == 2 ?
	jmp	fail
	lbi	2, 0
	aisc	0x1
	ske			; Br(2) == 3 ?
	jmp	fail
	lbi	3, 0
	aisc	0x1
	ske			; Br(3) == 4 ?
	jmp	fail


	clra
	aisc	0xf
	;; *******************************************************************
	;; XOR 3
	;;
	;; Br(0) & Br(3) xor 3
	lbi	0x0, 0x0
	x	0x3		; Br(0)=0xf, A=0x1, now Br(3)
	xad	3, 15		; save A
	;; expect 0x4 in M
	clra
	aisc	0x4
	ske
	jmp	fail
	xad	3, 15		; restore A
	x	0x3		; Br(3)=0x1, A=0x4, now Br(0)
	xad	3, 15		; save A
	;; expect 0xf in M
	clra
	aisc	0xf
	ske
	jmp	fail
	xad	3, 15		; restore A
	x	0x3		; Br(0)=0x4, A=0xf, now Br(3)
	xad	3, 15		; save A
	;; expect 0x1 in M
	clra
	aisc	0x1
	ske
	jmp	fail
	xad	3, 15		; restore A
	;; swap all back
	x	0x3		; Br(3)=0xf, A=0x1, now Br(0)
	x	0x3		; Br(0)=0x1, A=0x4, now Br(3)
	x	0x3		; Br(3)=0x4, A=0xf, now Br(0)
	;; same memory & accumulator content as before

	;; Br(1) & Br(2) xor 3
	lbi	0x1, 0x0
	x	0x3		; Br(1)=0xf, A=0x2, now Br(2)
	xad	3, 15		; save A
	;; expect 0x3 in M
	clra
	aisc	0x3
	ske
	jmp	fail
	xad	3, 15		; restore A
	x	0x3		; Br(2)=0x2, A=0x3, now Br(1)
	xad	3, 15		; save A
	;; expect 0xf in M
	clra
	aisc	0xf
	ske
	jmp	fail
	xad	3, 15		; restore A
	x	0x3		; Br(1)=0x3, A=0xf, now Br(2)
	xad	3, 15		; save A
	;; expect 0x2 in M
	clra
	aisc	0x2
	ske
	jmp	fail
	xad	3, 15		; restore A
	;; swap all back
	x	0x3		; Br(2)=0xf, A=0x2, now Br(1)
	x	0x3		; Br(1)=0x2, A=0x3, now Br(2)
	x	0x3		; Br(2)=0x3, A=0xf, now Br(1)
	;; same memory & accumulator content as before

	;; now check that all
	clra
	lbi	0, 0
	aisc	0x1
	ske			; Br(0) == 1 ?
	jmp	fail
	lbi	1, 0
	aisc	0x1
	ske			; Br(1) == 2 ?
	jmp	fail
	lbi	2, 0
	aisc	0x1
	ske			; Br(2) == 3 ?
	jmp	fail
	lbi	3, 0
	aisc	0x1
	ske			; Br(3) == 4 ?
	jmp	fail
	

	jmp	pass
	
	org	0x1c0
	include	"pass_fail.asm"
