	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the LQID and INL instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; preload reference data
	lbi	0, 0
	stii	0x0
	lbi	0, 9
	stii	0x1
	stii	0x2
	stii	0x3
	stii	0x4
	stii	0x5
	stii	0x6
	stii	0x7

	lbi	1, 0
	stii	0x8
	lbi	1, 9
	stii	0x9
	stii	0xa
	stii	0xb
	stii	0xc
	stii	0xd
	stii	0xe
	stii	0xf


load	MACRO	addr, noadd
	lbi	2, 0
	stii	addr & 0x0f
	clra
	IF	noadd <> 1
	aisc	(addr >> 4) & 0x0f
	ENDIF
	lbi	2, 0
	lqid
	inl
	ENDM

	;; enable Q output to L
	lei	0x4

	;;
	load	read_block_0_55, 0
	lbi	0, 8 + 5
	ske
	jmp	fail
	lbi	2, 0
	ske
	jmp	fail

	;;
	load	read_block_0_aa, 0
	lbi	1, 0xa
	ske
	jmp	fail
	lbi	2, 0
	ske
	jmp	fail

	;;
	load	read_block_0_0f, 0
	lbi	1, 0xf
	ske
	jmp	fail
	lbi	2, 0
	clra
	ske
	jmp	fail

	;;
	load	read_block_0_f0, 0
	lbi	0, 0
	ske
	jmp	fail
	lbi	2, 0
	clra
	aisc	0xf
	ske
	jmp	fail

	jmp	block_1
	

	;; -------------------------------------------------------------------
	;; Block 0 testdata
	;;
	org	0x064
read_block_0_55:
	db	0x55

	org	0x071
read_block_0_aa:
	db	0xaa

	org	0x0a9
read_block_0_0f:
	db	0x0f

	org	0x0ff
read_block_0_f0:
	db	0xf0


	;; -------------------------------------------------------------------
	;; Block 1 testdata
	;;
	org	0x105
read_block_1_68:
	db	0x68

	org	0x120
read_block_1_b1:
	db	0xb1

	org	0x17e
read_block_1_04:
	db	0x04

	org	0x1c2
read_block_1_db:
	db	0xdb


	org	0x128
block_1:
	;;
	load	read_block_1_68, 1
	lbi	1, 0
	ske
	jmp	fail
	lbi	2, 0
	clra
	aisc	0x6
	ske
	jmp	fail

	;;
	load	read_block_1_b1, 0
	lbi	0, 8 + 1
	ske
	jmp	fail
	lbi	2, 0
	clra
	aisc	0xb
	ske
	jmp	fail

	;;
	load	read_block_1_04, 0
	lbi	0, 8 + 4
	ske
	jmp	fail
	lbi	2, 0
	clra
	ske
	jmp	fail

	;;
	load	read_block_1_db, 0
	lbi	1, 0xb
	ske
	jmp	fail
	lbi	2, 0
	clra
	aisc	0xd
	ske
	jmp	fail


	IF	MOMCPUNAME <> "COP420"
	jmp	pass
	ELSEIF
	jmp	block_2
	ENDIF


	org	0x180
	include	"pass_fail.asm"


	IF	MOMCPUNAME = "COP420"

	;; -------------------------------------------------------------------
	;; Block 2 testdata
	;;
	org	0x211
read_block_2_34:
	db	0x34

	org	0x237
read_block_2_91:
	db	0x91

	org	0x254
read_block_2_89:
	db	0x89

	org	0x296
read_block_2_3c:
	db	0x3c

	
	org	0x2b0
block_2:
	;;
	load	read_block_2_34, 0
	lbi	0, 8 + 4
	ske
	jmp	fail
	lbi	2, 0
	clra
	aisc	0x3
	ske
	jmp	fail

	;;
	load	read_block_2_91, 0
	lbi	0, 8 + 1
	ske
	jmp	fail
	lbi	2, 0
	clra
	aisc	0x9
	ske
	jmp	fail

	;;
	load	read_block_2_89, 0
	lbi	1, 9
	ske
	jmp	fail
	lbi	2, 0
	clra
	aisc	0x8
	ske
	jmp	fail

	;;
	load	read_block_2_3c, 0
	lbi	1, 0xc
	ske
	jmp	fail
	lbi	2, 0
	clra
	aisc	0x3
	ske
	jmp	fail

	jmp	block_3


	;; -------------------------------------------------------------------
	;; Block 3 testdata
	;;
	org	0x300
read_block_3_76:
	db	0x76

	org	0x34b
read_block_3_33:
	db	0x33

	org	0x3a4
read_block_3_e9:
	db	0xe9

	org	0x3e0
read_block_3_9d:
	db	0x9d

	
	org	0x350
block_3:
	;;
	load	read_block_3_76, 1
	lbi	0, 8 + 6
	ske
	jmp	fail
	lbi	2, 0
	clra
	aisc	0x7
	ske
	jmp	fail

	;;
	load	read_block_3_33, 0
	lbi	0, 8 + 3
	ske
	jmp	fail
	lbi	2, 0
	clra
	aisc	0x3
	ske
	jmp	fail

	;;
	load	read_block_3_e9, 0
	lbi	1, 9
	ske
	jmp	fail
	lbi	2, 0
	clra
	aisc	0xe
	ske
	jmp	fail

	;;
	load	read_block_3_9d, 0
	lbi	1, 0xd
	ske
	jmp	fail
	lbi	2, 0
	clra
	aisc	0x9
	ske
	jmp	fail

	jmp	pass
	
	ENDIF
