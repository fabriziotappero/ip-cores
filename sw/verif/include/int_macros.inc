	;; *******************************************************************
	;; $Id: int_macros.inc 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Defines macros for interrupt tests.
	;;

	;; -------------------------------------------------------------------
	;; Save current A, M and C to M(3,15), M(3,14) and M(3,13).
	;;
save_a_m_c	MACRO
	xad	3, 15		; save A to M(3,15)

	x	0		; save current M
	xad	3, 14		; to M(3,14)

	smb	0x0		; save C
	skc			; to M(3,13)
	rmb     0x0		;
	x	0		;
	xad	3, 13		;
	ENDM


	;; -------------------------------------------------------------------
	;; Check SA against specified address
	;;
check_sa	MACRO	addr
	;; request nibble 0 of SA
	ogi	0x0
	inl
	;; check this nibble
	x	0
	clra
	IF	addr & 0xf <> 0
	aisc	addr & 0xf
	ENDIF
	ske
	jmp	fail

	;; request nibble 1 of SA
	ogi	0x1
	inl
	;; check this nibble
	x	0
	clra
	IF	addr & 0x0f0 <> 0
	aisc	(addr >> 4) & 0xf
	ENDIF
	ske
	jmp	fail

	;; request nibble 2 of SA
	ogi	0x2
	inl
	;; check this nibble
	x	0
	clra
	IF	addr & 0xf00 <> 0
	aisc	(addr >> 8) & 0xf
	ENDIF
	ske
	jmp	fail

	ENDM


	;; -------------------------------------------------------------------
	;; Restore C, M and A from M(3,13), M(3,14) and M(3,15)
	;;
restore_c_m_a	MACRO
	xad	3, 13		; restore C
	x	0		; from M(3,13)
	rc			;
	skmbz	0x0		;
	sc			;

	xad	3, 14		; restore current M
	x	0		; from M(3,14)

	xad	3, 15		; restore A
	ENDM


	;; -------------------------------------------------------------------
	;; Flag that interrupt occured in M(3,12).1
	;;
int_flag_set	MACRO
	clra
	aisc	0x1
	xad	3, 12
	ENDM

	;; -------------------------------------------------------------------
	;; Clear 'interrupt occured' flag
	;;
int_flag_clear	MACRO
	clra
	xad	3, 12
	ENDM

	;; -------------------------------------------------------------------
	;; Check interrupt occurence
	;;
int_flag_check	MACRO
	lbi	3, 12
	skmbz	0x0
	jp	+
	jmp	fail		; no interrupt!
+	lbi	0, 0
	ENDM
