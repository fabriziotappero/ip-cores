ACTIVE	EQU		0x0001

configTable:	
	dc.b	"VLID"
	dc.l	0x0100000	; first megabyte
	dc.l	0x0E00000	; 14 megabytes available
	dc.l	0x0000		; auxillary reset code pointer
	dc.l	0x0000		; AUXDSP auxillary dispatch routine pointer
	dc.l	0x0000		; SERVPTR
	dc.l	0x00000000	; DATAPTR
	dc.l	0x00000001	; NTASKS

; Static task control block
	dc.l	0xFFFF1000	; starting address
	dc.b	"TINY BAS"	; Tiny basic
	dc.l	0x00000800	; 2k stack required
	dc.l	0x00000000	; EDC table pointer
	dc.l	0x00000000	; user parameter
	dc.w	ACTIVE
	dc.w	0x0001		; task #1

