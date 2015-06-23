;**********************************************************************************
;*                                                                                *
;* checks all z180 instructions                                                   *
;*                                                                                *
;**********************************************************************************
	aseg

	org	00h
	jp	100h

	org	038h
	jp	(hl)
	
	org	066h
	jp	(ix)
	
	org	80h
	db	00h, 01h, 2dh, 03h, 04h, 05h, 06h, 07h
	db	0fh, 1eh, 02h, 3ch, 4bh, 5ah, 69h, 78h

	org	0c0h		;pattern finish location
	nop
	jr	0c0h

	org	0100h
	di
	ld	sp, 0fffeh	;point sp at result table
	xor	a
	ld	hl, 01234h
	ld	de, 05678h
	ld	bc, 09abch
	mlt	sp
	push	af		;0044h @ fd00h
	mlt	hl
	push	hl		;03a8h @ fcfeh
	mlt	de
	push	de		;2850h @ fcfch
	mlt	bc
	push	bc		;7118h @ fcfah
	push	af		;0044h @ fcf8h
;
	add	a,1
	in0	a,(080h)	;read 00h @ 0080h
	push	af		;0044h @ fcf6h
	out0	(030h),b	;071 @ 0030h
	push	af		;0044h @ fcf4h
	in0	a,(08ah)	;read 02h @ 008ah
	push	af		;0200h @ fcf2h
	out0	(031h),c	;018 @ 0031h
	push	af		;0200h @ fcf0h
	in0	b,(81h)
	in0	c,(82h)
	in0	d,(83h)
	in0	e,(84h)
	in0	h,(85h)
	in0	l,(86h)		;read 06h @ 0086h
	push	af		;0204h @ fceeh
	push	bc		;012dh @ fcech
	push	de		;0304h @ fceah
	push	hl		;0506h @ fce8h
;
	out0	(032h),l	;06h @ 0032h
	out0	(033h),h	;05h @ 0033h
	out0	(034h),a	;02h @ 0034h
	out0	(035h),d	;03h @ 0035h
	out0	(036h),e	;04h @ 0036h
	push	af		;0204h @ fce6h
;
	ld	a, 0a9h
	tst	b	;a9h & 01h = 01h
	push	af		;a910h @ fce4h
	tst	c	;a9h & 2dh = 29h
	push	af		;a910h @ fce2h
	tst	d	;a9h & 03h = 01h
	push	af		;a910h @ fce0h
	scf
	tst	e	;a9h & 04h = 00h
	push	af		;a954h @ fcdeh
	tst	h	;a9h & 05h = 01h
	push	af		;a910h @ fcdch
	ld	l, 0f7h
	tst	l	;a9h & f7h = a1h
	push	af		;a990h @ fcdah
	tst	a	;a9h & a9h = a9h
	push	af		;a994h @ fcd8h
	scf
	ld	hl, 01000h
	tst	(hl)	;a9h & b7h = a1h
	push	af		;a990h @ fcd6h
	tst	056h	;a9h & 56h = 00h
	push	af		;a954h @ fcd4h
	ld	c, 08ch
	scf
	tstio	0aah	;a9h & 4bh = 09h
	push	af		;a914h @ fcd2h
;
	xor	a
	ld	hl, 02000h
	ld	bc, 00630h
	jp	001feh
	org	001feh
	otim			;read  71h @ 2000h
				;write 71h @ 0030h 
	push	af		;0006h @ fcd0h
	push	bc		;0531h @ fcceh
	push	hl		;2001h @ fccch
	jp	002feh
	org	002feh
	otimr			;read  18h @ 2001h
				;write 18h @ 0031h
				;read  06h @ 2002h
				;write 06h @ 0032h
				;read  05h @ 2003h
				;write 05h @ 0033h
				;read  02h @ 2004h
				;write 02h @ 0034h
				;read  03h @ 2005h
				;write 03h @ 0035h
	push	af		;0046h @ fccah
	push	bc		;0036h @ fcc8h
	push	hl		;2006h @ fcc6h
	ld	b,1
	jp	003ffh
	org	003ffh
	otimr			;read  04h @ 2006h
				;write 04h @ 0036h
	push	af		;0046h @ fcc4h
	push	bc		;0037h @ fcc2h
	push	hl		;2007h @ fcc0h
	inc	b
	jp	004ffh
	org	004ffh
	otim			;read  aah @ 2007h
				;write aah @ 0037h
	push	af		;0042h @ fcbeh
	push	bc		;0038h @ fcbch
	push	hl		;2008h @ fcbah
	ld	hl, 02007h
	ld	bc, 00637h
	jp	005feh
	org	005feh
	otdm			;read  aah @ 2007h
				;write aah @ 0037h
	push	af		;0002h @ fcb8h
	push	bc		;0536h @ fcb6h
	push	hl		;2006h @ fcb4h
	jp	006feh
	org	006feh
	otdmr			;read  04h @ 2006h
				;write 04h @ 0036h
				;read  03h @ 2005h
				;write 03h @ 0035h
				;read  02h @ 2004h
				;write 02h @ 0034h
				;read  05h @ 2003h
				;write 05h @ 0033h
				;read  06h @ 2002h
				;write 06h @ 0032h
	push	af		;0042h @ fcb2h
	push	bc		;0031h @ fcb0h
	push	hl		;2001h @ fcaeh
	inc	b
	xor	0aah
	jp	007ffh
	org	007ffh
	otdmr			;read  18h @ 2001h
				;write 18h @ 0031h
	push	af		;aac6h @ fcach
	push	bc		;0030h @ fcaah
	push	hl		;2000h @ fca8h
	inc	b
	jp	008ffh
	org	008ffh
	otdm			;read  71h @ 2000h
				;write 71h @ 0030h
	push	af		;aa42h @ fca6h
	push	bc		;002fh @ fca4h
	push	de		;0304h @ fca2h
	push	hl		;1fffh @ fca0h
;
	ld	hl, 00100h
	jp	0c0h
	
	org	01000h
	db	0b7h

	org	02000h
	db	071h, 018h, 006h, 005h, 002h, 003h, 004h, 0aah
	
	end
