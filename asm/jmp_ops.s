;**********************************************************************************
;*                                                                                *
;* checks all jump, call, etc. instructions                                       *
;*                                                                                *
;**********************************************************************************
	aseg

	org	00h
	jp	(hl)

	org	08h
	push	bc		;0004h @ fff4h
	inc	bc
	jp	(hl)

	org	10h
	push	bc		;0006h @ ffeeh
	inc	bc
	jp	(hl)

	org	18h
	push	bc		;0008h @ ffe8h
	inc	bc
	jp	(hl)

	org	20h
	push	bc		;000ah @ ffe2h
	inc	bc
	jp	(hl)

	org	28h
	push	bc		;000ch @ ffdch
	inc	bc
	jp	(hl)

	org	30h
	push	bc		;000eh @ ffd6h
	inc	bc
	jp	(hl)

	org	38h
	push	bc		;0010h @ ffd0h
	inc	bc
	jp	(hl)

	org	0c0h		;pattern finish location
	nop
	jr	0c0h

	org	0100h
	ld	sp, 0000h
	xor	a
	ld	bc, 0000h
	ld	de, 0010h
	ld	hl, 2010h
	ld	ix, 1000h
	ld	iy, 2000h
	inc	bc
	jp	(ix)

	org	300h
	dw	0001h		;c flag
	dw	00feh		;not c flag
	dw	0004h		;p/v flag
	dw	00fbh		;not p/v flag
	dw	0040h		;z flag
	dw	00bfh		;not z flag
	dw	0080h		;s flag
	dw	007fh		;not s flag
	dw	0000h		;pattern exit value

	org	0400h
	dw	7160h
	dw	7170h
	dw	7180h
	dw	7190h
	dw	71a0h
	dw	71b0h
	dw	71c0h
	dw	71d0h
	dw	71e0h
	dw	71f0h

	org	1000h
	push	bc		;0001h @ fffeh
	inc	bc
	jp	(iy)

	org	2000h
	push	bc		;0002h @ fffch
	inc	bc
	rst	00h		;2003h @ fffah

	org	2010h
	push	bc		;0003h @ fff8h
	add	hl, de
	inc	bc
	rst	08h		;2014h @ fff6h

	org	2020h
	push	bc		;0005h @ fff2h
	add	hl, de
	inc	bc
	rst	10h		;2024h @ fff0h

	org	2030h
	push	bc		;0007h @ ffech
	add	hl, de
	inc	bc
	rst	18h		;2034h @ ffeah

	org	2040h
	push	bc		;0009h @ ffe6h
	add	hl, de
	inc	bc
	rst	20h		;2044h @ ffe4h

	org	2050h
	push	bc		;000bh @ ffe0h
	add	hl, de
	inc	bc
	rst	28h		;2054h @ ffdeh

	org	2060h
	push	bc		;000dh @ ffdah
	add	hl, de
	inc	bc
	rst	30h		;2064h @ ffd8h

	org	2070h
	push	bc		;000fh @ ffd4h
	add	hl, de
	inc	bc
	rst	38h		;2074h @ ffd2h

	org	2080h
	jp	0ccffh

	org	7000h
	push	bc		;0018h @ ffbeh
	inc	bc
	ld	sp, 0300h
	pop	af		;0001h @ 0300h
	ld	sp, 0ffbeh
	call	c, 7010h	;700ch @ ffbch
	halt

	org	7010h
	push	bc		;0019h @ ffbah
	inc	bc
	jp	c, 7020h
	halt

	org	7020h
	push	bc		;001ah @ ffb8h
	inc	bc
	jr	c, 7030h
	halt

	org	7030h
	push	bc		;001bh @ ffb6h
	inc	bc
	ld	sp, 0302h
	pop	af		;00feh @ 0302h
	ld	sp, 0ffb6h
	call	nc, 7040h	;703ch @ ffb4h
	halt

	org	7040h
	push	bc		;001ch @ ffb2h
	inc	bc
	jp	nc, 7050h
	halt

	org	7050h
	push	bc		;001dh @ ffb0h
	inc	bc
	jr	nc, 7060h
	halt

	org	7060h
	push	bc		;001eh @ ffaeh
	inc	bc
	ld	sp, 0304h
	pop	af		;0004h @ 0304h
	ld	sp, 0ffaeh
	call	pe, 7070h	;706ch @ ffach
	halt

	org	7070h
	push	bc		;001fh @ ffaah
	inc	bc
	jp	pe, 7080h
	halt

	org	7080h
	push	bc		;0020h @ ffa8h
	inc	bc
	ld	sp, 0306h
	pop	af		;00fbh @ 0306h
	ld	sp, 0ffa8h
	call	po, 7090h	;708ch @ ffa6h
	halt

	org	7090h
	push	bc		;0021h @ ffa4h
	inc	bc
	jp	po, 70a0h
	halt

	org	70a0h
	push	bc		;0022h @ ffa2h
	inc	bc
	ld	sp, 0308h
	pop	af		;0040h @ 0308h
	ld	sp, 0ffa2h
	call	z, 70b0h	;70ach @ ffa0h
	halt

	org	70b0h
	push	bc		;0023h @ ff9eh
	inc	bc
	jp	z, 70c0h
	halt

	org	70c0h
	push	bc		;0024h @ ff9ch
	inc	bc
	jr	z, 70d0h
	halt

	org	70d0h
	push	bc		;0025h @ ff9ah
	inc	bc
	ld	sp, 030ah
	pop	af		;00bfh @ 030ah
	ld	sp, 0ff9ah
	call	nz, 70e0h	;70dch @ ff98h
	halt

	org	70e0h
	push	bc		;0026h @ ff96h
	inc	bc
	jp	nz, 70f0h
	halt

	org	70f0h
	push	bc		;0027h @ ff94h
	inc	bc
	jr	nz, 7100h
	halt

	org	7100h
	push	bc		;0028h @ ff92h
	inc	bc
	ld	sp, 030ch
	pop	af		;0080h @ 030ch
	ld	sp, 0ff92h
	call	m, 7110h	;710ch @ ff90h
	halt

	org	7110h
	push	bc		;0029h @ ff8eh
	inc	bc
	jp	m, 7120h
	halt

	org	7120h
	push	bc		;002ah @ ff8ch
	inc	bc
	ld	sp, 030eh
	pop	af		;007fh @ 030eh
	ld	sp, 0ff8ch
	call	p, 7130h	;712ch @ ff8ah
	halt

	org	7130h
	push	bc		;002bh @ ff88h
	inc	bc
	jp	p, 7140h
	halt

	org	7140h
	push	bc		;002ch @ ff86h
	inc	bc
	ld	sp, 0300h
	pop	af		;0001h @ 0300h
	ccf
	ld	hl, 0fe00h
	ld	sp, 0400h
	ret			;7160h @ 0400h

	org	7160h
	ld	(hl), c		;  2dh @ fe00h
	inc	bc
	inc	hl
	ld	sp, 0302h
	pop	af		;00feh @ 0302h
	ccf
	ld	sp, 0402h
	ret			;7170h @ 0402h

	org	7170h
	ld	(hl), c		;  2eh @ fe01h
	inc	bc
	inc	hl
	ld	sp, 0300h
	pop	af		;0001h @ 0300h
	ld	sp, 0404h
	ret	c		;7180h @ 0404h

	org	7180h
	ld	(hl), c		;  2fh @ fe02h
	inc	bc
	inc	hl
	ld	sp, 0302h
	pop	af		;00feh @ 0302h
	ld	sp, 0406h
	ret	nc		;7190h @ 0406h

	org	7190h
	ld	(hl), c		;  30h @ fe03h
	inc	bc
	inc	hl
	ld	sp, 0304h
	pop	af		;0004h @ 0304h
	ld	sp, 0408h
	ret	pe		;71a0h @ 0408h

	org	71a0h
	ld	(hl), c		;  31h @ fe04h
	inc	bc
	inc	hl
	ld	sp, 0306h
	pop	af		;00fbh @ 0306h
	ld	sp, 040ah
	ret	po		;71b0h @ 040ah

	org	71b0h
	ld	(hl), c		;  32h @ fe05h
	inc	bc
	inc	hl
	ld	sp, 0308h
	pop	af		;0040h @ 0308h
	ld	sp, 040ch
	ret	z		;71c0h @ 040ch

	org	71c0h
	ld	(hl), c		;  33h @ fe06h
	inc	bc
	inc	hl
	ld	sp, 030ah
	pop	af		;00bfh @ 030ah
	ld	sp, 040eh
	ret	nz		;71d0h @ 040eh

	org	71d0h
	ld	(hl), c		;  34h @ fe07h
	inc	bc
	inc	hl
	ld	sp, 030ch
	pop	af		;0080h @ 030ch
	ld	sp, 0410h
	ret	m		;71e0h @ 0410h

	org	71e0h
	ld	(hl), c		;  35h @ fe08h
	inc	bc
	inc	hl
	ld	sp, 030eh
	pop	af		;007fh @ 030eh
	ld	sp, 0412h
	ret	p		;71f0h @ 0412h

	org	71f0h
	ld	(hl), c		;  36h @ fe09h
	inc	bc
	ld	sp, 0ff86h
	ld	b, 81h
	djnz	dlp1

	org	7200h
dlp1:	push	bc		;8037h @ ff84h
	inc	bc
	ld	b, 41h
	djnz	dlp2

	org	7210h
dlp2:	push	bc		;4038h @ ff82h
	inc	bc
	ld	b, 21h
	djnz	dlp3

	org	7220h
dlp3:	push	bc		;2039h @ ff80h
	inc	bc
	ld	b, 11h
	djnz	dlp4

	org	7230h
dlp4:	push	bc		;103ah @ ff7eh
	inc	bc
	ld	b, 09h
	djnz	dlp5

	org	7240h
dlp5:	push	bc		;083bh @ ff7ch
	inc	bc
	ld	b, 05h
	djnz	dlp6

	org	7250h
dlp6:	push	bc		;043ch @ ff7ah
	inc	bc
	ld	b, 03h
	djnz	dlp7

	org	7260h
dlp7:	push	bc		;023dh @ ff78h
	inc	bc
	ld	b, 01h
	djnz	dlp8
	push	bc		;003eh @ ff76h
	inc	bc
	jr	dlp9	

	org	7270h
dlp8:	halt

	org	7280h
dlp9:	push	bc		;003fh @ ff74h
	inc	bc
	inc	b
	inc	b
	djnz	dlpb
	halt

	org	728bh
dlpa:	push	bc		;0241h @ ff70h
	ld	sp, 0310h
	pop	af		;0000h @ 0310h
	ld	hl, 0100h
	jp	0c0h

	org	7305h
dlpb:	push	bc		;0140h @ ff72h
	inc	bc
	inc	b
	inc	b
	djnz	dlpa
	halt

	org	0ccffh
	push	bc		;0011h @ ffceh
	inc	bc
	ld	sp, 0300h
	pop	af		;0001h @ 0300h
	jp	nc, fail	;none taken
	jr	nc, fail
	call	nc, fail
	ret	nc
	pop	af		;00feh @ 0302h
	jp	c, fail		;none taken
	jr	c, fail
	call	c, fail
	ret	c
	pop	af		;0004h @ 0304h
	jp	po, fail	;none taken
	call	po, fail
	ret	po
	pop	af		;00fbh @ 0306h
	jp	pe, fail	;none taken
	call	pe, fail
	ret	pe
	pop	af		;0040h @ 0308h
	jp	nz, fail	;none taken
	jr	nz, fail
	call	nz, fail
	ret	nz
	pop	af		;00bfh @ 030ah
	jp	z, fail		;none taken
	jr	z, fail
	call	z, fail
	ret	z
	pop	af		;0080h @ 030ch
	jp	p, fail		;none taken
	call	p, fail
	ret	p
	pop	af		;007fh @ 030eh
	jp	m, fail		;none taken
	call	m, fail
	ret	m
	jr	rel2
rel1:	push	bc		;0013h @ ffcah
	inc	bc
	jr	rel3
fail:	halt
rel2:	ld	sp, 0300h
	pop	af		;0001h @ 0300h
	ccf
	ld	sp, 0ffceh
	push	bc		;0012h @ ffcch
	inc	bc
	jr	rel1
rel3:	push	bc		;0014h @ ffc8h
	inc	bc
	jp	0cefbh

	org	0cefbh
	push	bc		;0015h @ ffc6h
	inc	bc
	jr	rel5

	org	0cf02h
rel4:	push	bc		;0017h @ ffc2h
	inc	bc
	call	07000h		;cf07h @ ffc0h

	org	0cf7eh
rel5:	push	bc		;0016h @ ffc4h
	inc	bc
	jr	rel4






