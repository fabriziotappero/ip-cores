;**********************************************************************************
;*                                                                                *
;* checks all data movement instructions                                          *
;*                                                                                *
;**********************************************************************************
	aseg

	org	00h
	jp	100h

	org	0c0h		;pattern finish location
	nop
	jr	0c0h

	org	0100h
	ld	sp, 0000h	;point sp at result table
	ld	a, 0ffh		;initialize the main registers
	xor	a		;initialize flags
	ld	b, 01h		;immediate loads
	ld	c, 02h
	ld	d, 04h
	ld	e, 08h
	ld	h, 10h
	ld	l, 20h
	ld	ix, 0aaaah
	ld	iy, 5555h
	push	af		;0044h @ fffeh
	push	bc		;0102h @ fffch
	push	de		;0408h @ fffah
	push	hl		;1020h @ fff8h
	push	ix		;aaaah @ fff6h
	push	iy		;5555h @ fff4h
	ld	a, 0f0h
	ld	(bc), a		;  f0h @ 0102h
	ld	a, 0fh
	ld	(de), a		;  0fh @ 0408h
	ld	(hl), a		;  0fh @ 1020h
	inc	hl
	ld	(hl), b		;  01h @ 1021h
	inc	hl
	ld	(hl), c		;  02h @ 1022h
	inc	hl
	ld	(hl), d		;  04h @ 1023h
	inc	hl
	ld	(hl), e		;  08h @ 1024h
	inc	hl
	ld	(hl), h		;  10h @ 1025h
	inc	hl
	ld	(hl), l		;  26h @ 1026h
	inc	hl
	ld	(hl), 3ch	;  3ch @ 1027h
	ld	hl, 1020h
	push	af		;0f44h @ fff2h
	push	bc		;0102h @ fff0h
	push	de		;0408h @ ffeeh
	push	hl		;1020h @ ffech
	ld	a, 00h
	ex	af, af'
	ld	a, 0ffh		;initialize the alternate registers
	or	a
	exx
	ld	bc, 0fefdh	;immediate loads
	ld	de, 0fbf7h
	ld	hl, 0efdfh
	push	af		;ff84h @ ffeah
	push	bc		;fefdh @ ffe8h
	push	de		;fbf7h @ ffe6h
	push	hl		;efdfh @ ffe4h
	exx
	push	af		;ff84h @ ffe2h
	push	bc		;0102h @ ffe0h
	push	de		;0408h @ ffdeh
	push	hl		;1020h @ ffdch
	ex	de, hl
	push	af		;ff84h @ ffdah
	push	bc		;0102h @ ffd8h
	push	de		;1020h @ ffd6h
	push	hl		;0408h @ ffd4h
	exx
	push	af		;ff84h @ ffd2h
	push	bc		;fefdh @ ffd0h
	push	de		;fbf7h @ ffceh
	push	hl		;efdfh @ ffcch
	ex	de, hl
	push	af		;ff84h @ ffcah
	push	bc		;fefdh @ ffc8h
	push	de		;efdfh @ ffc6h
	push	hl		;fbf7h @ ffc4h
	exx
	push	af		;ff84h @ ffc2h
	push	bc		;0102h @ ffc0h
	push	de		;1020h @ ffbeh
	push	hl		;0408h @ ffbch
	ex	de, hl
	push	af		;ff84h @ ffbah
	push	bc		;0102h @ ffb8h
	push	de		;0408h @ ffb6h
	push	hl		;1020h @ ffb4h
	exx
	push	af		;ff84h @ ffb2h
	push	bc		;fefdh @ ffb0h
	push	de		;efdfh @ ffaeh
	push	hl		;fbf7h @ ffach
	ex	de, hl
	push	af		;ff84h @ ffaah
	push	bc		;fefdh @ ffa8h
	push	de		;fbf7h @ ffa6h
	push	hl		;efdfh @ ffa4h
	exx
	ld	b, b
	ld	c, c
	ld	d, d
	ld	h, h
	ld	l, l
	ld	a, a
	push	af		;ff84h @ ffa2h
	push	bc		;0102h @ ffa0h
	push	de		;0408h @ ff9eh
	push	hl		;1020h @ ff9ch
	ld	a, b
	ld	b, c
	ld	c, d
	ld	d, e
	ld	e, h
	ld	h, l
	ld	l, a
	push	af		;0184h @ ff9ah
	push	bc		;0204h @ ff98h
	push	de		;0810h @ ff96h
	push	hl		;2001h @ ff94h
	xor	a
	ld	b, 01h
	ld	c, 02h
	ld	d, 04h
	ld	e, 08h
	ld	h, 10h
	ld	l, 20h
	ld	a, c
	ld	b, d
	ld	c, e
	ld	d, h
	ld	e, l
	ld	h, a
	ld	l, b
	push	af		;0244h @ ff92h
	push	bc		;0408h @ ff90h
	push	de		;1020h @ ff8eh
	push	hl		;0204h @ ff8ch
	xor	a
	ld	b, 01h
	ld	c, 02h
	ld	d, 04h
	ld	e, 08h
	ld	h, 10h
	ld	l, 20h
	ld	a, d
	ld	b, e
	ld	c, h
	ld	d, l
	ld	e, a
	ld	h, b
	ld	l, c
	push	af		;0444h @ ff8ah
	push	bc		;0810h @ ff88h
	push	de		;2004h @ ff86h
	push	hl		;0810h @ ff84h
	xor	a
	ld	b, 01h
	ld	c, 02h
	ld	d, 04h
	ld	e, 08h
	ld	h, 10h
	ld	l, 20h
	ld	a, e
	ld	b, h
	ld	c, l
	ld	d, a
	ld	e, b
	ld	h, c
	ld	l, d
	push	af		;0844h @ ff82h
	push	bc		;1020h @ ff80h
	push	de		;0810h @ ff7eh
	push	hl		;2008h @ ff7ch
	xor	a
	ld	b, 01h
	ld	c, 02h
	ld	d, 04h
	ld	e, 08h
	ld	h, 10h
	ld	l, 20h
	ld	a, h
	ld	b, l
	ld	c, a
	ld	d, b
	ld	e, c
	ld	h, d
	ld	l, e
	push	af		;1044h @ ff7ah
	push	bc		;2010h @ ff78h
	push	de		;2010h @ ff76h
	push	hl		;2010h @ ff74h
	xor	a
	ld	b, 01h
	ld	c, 02h
	ld	d, 04h
	ld	e, 08h
	ld	h, 10h
	ld	l, 20h
	ld	a, l
	ld	b, a
	ld	c, b
	ld	d, c
	ld	e, d
	ld	h, e
	ld	l, h
	push	af		;2044h @ ff72h
	push	bc		;2020h @ ff70h
	push	de		;2020h @ ff6eh
	push	hl		;2020h @ ff6ch
	ld	b, (hl)		;  5ah @ 2020h
	inc	hl
	ld	c, (hl)		;  69h @ 2021h
	inc	hl
	ld	d, (hl)		;  78h @ 2022h
	inc	hl
	ld	e, (hl)		;  87h @ 2023h
	inc	hl
	push	af		;2044h @ ff6ah
	push	bc		;5a69h @ ff68h
	push	de		;7887h @ ff66h
	push	hl		;2024h @ ff64h
	ld	h, (hl)		;  96h @ 2024h
	push	hl		;9624h @ ff62h
	ld	h, 20h
	inc	hl
	ld	l, (hl)		;  a5h @ 2025h
	push	hl		;20a5h @ ff60h
	ld	a, (bc)		;  b4h @ 5a69h
	push	af		;b444h @ ff5eh
	ld	a, (de)		;  c3h @ 7887h
	push	af		;c344h @ ff5ch
	ld	a, (7888h)	;  d2h @ 7888h
	push	af		;d244h @ ff5ah
	ld	bc, (7889h)	;e1f0h @ 7889h
	ld	de, (788bh)	;0f1eh @ 788bh
	ld	hl, (788dh)	;2d3ch @ 788dh
	ld	ix, (788fh)	;4b5ah @ 788fh
	ld	iy, (7891h)	;6978h @ 7891h
	ld	sp, (7893h)	;fe00h @ 7893h
	ld	(7895h), a	;  d2h @ 7895h
	ld	(7896h), bc	;e1f0h @ 7896h
	ld	(7898h), de	;0f1eh @ 7898h
	ld	(789ah), hl	;2d3ch @ 789ah
	ld	(789ch), ix	;4b5ah @ 789ch
	ld	(789eh), iy	;6978h @ 789eh
	ld	(78a0h), sp	;fe00h @ 78a0h
	ld	sp, 0f000h
	pop	af		;0f00h @ f000h
	pop	bc		;ee11h @ f002h
	pop	de		;dd22h @ f004h
	pop	hl		;cc33h @ f006h
	pop	ix		;bb44h @ f008h
	pop	iy		;aa55h @ f00ah
	ld	sp, 0fe00h
	push	af		;0f00h @ fdfeh
	push	bc		;ee11h @ fdfch
	push	de		;dd22h @ fdfah
	push	hl		;cc33h @ fdf8h
	push	ix		;bb44h @ fdf6h
	push	iy		;aa55h @ fdf4h
	inc	hl
	ld	sp, hl
	push	af		;0f00h @ cc32h
	push	hl		;cc34h @ cc30h
	ld	sp, ix
	push	af		;0f00h @ bb42h
	push	ix		;bb44h @ bb40h
	inc	iy
	ld	sp, iy
	push	af		;0f00h @ aa54h
	push	iy		;aa56h @ aa52h
	ld	sp, 0fd00h
	ex	(sp), hl	;2345h @ fd00h read
				;cc34h @ fd00h write
	inc	sp
	inc	sp
	ex	(sp), ix	;6789h @ fd02h read
				;bb44h @ fd02h write
	inc	sp
	inc	sp
	ex	(sp), iy	;abcdh @ fd04h read
				;aa56h @ fd04h write
	ld	a, (ix+0h)	;  ffh @ 6789h
	ld	b, (ix+1h)	;  fdh @ 678ah
	ld	c, (ix+2h)	;  fbh @ 678bh
	ld	d, (ix+3h)	;  f9h @ 678ch
	ld	e, (ix+4h)	;  f7h @ 678dh
	ld	h, (ix+5h)	;  f5h @ 678eh
	ld	l, (ix+6h)	;  f3h @ 678fh
	ld	sp, 0fd00h
	push	af		;ff00h @ fcfeh
	push	bc		;fdfbh @ fcfch
	push	de		;f9f7h @ fcfah
	push	hl		;f5f3h @ fcf8h
	ld	a, (iy+0h)	;  01h @ abcdh
	ld	b, (iy+1h)	;  03h @ abceh
	ld	c, (iy+2h)	;  05h @ abcfh
	ld	d, (iy+3h)	;  07h @ abd0h
	ld	e, (iy+4h)	;  09h @ abd1h
	ld	h, (iy+5h)	;  0bh @ abd2h
	ld	l, (iy+6h)	;  0dh @ abd3h
	push	af		;0100h @ fcf6h
	push	bc		;0305h @ fcf4h
	push	de		;0709h @ fcf2h
	push	hl		;0b0dh @ fcf0h
	ld	(ix-001h), a	;  01h @ 6788h
	ld	(ix-002h), b	;  03h @ 6787h
	ld	(ix-003h), c	;  05h @ 6786h
	ld	(ix-004h), d	;  07h @ 6785h
	ld	(ix-005h), e	;  09h @ 6784h
	ld	(ix-006h), h	;  0bh @ 6783h
	ld	(ix-007h), l	;  0dh @ 6782h
	ld	(ix-008h), 0fh	;0fh @ 6781h
	ld	(iy-001h), a	;  01h @ abcch
	ld	(iy-002h), b	;  03h @ abcbh
	ld	(iy-003h), c	;  05h @ abcah
	ld	(iy-004h), d	;  07h @ abc9h
	ld	(iy-005h), e	;  09h @ abc8h
	ld	(iy-006h), h	;  0bh @ abc7h
	ld	(iy-007h), l	;  0dh @ abc6h
	ld	(iy-008h), 0fh	;0fh @ abc5h
	xor	a
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	exx
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	exx
	ex	af, af'
	xor	a
	ld	a, 0ffh
	ld	r, a
	push	af		;ff44h @ fceeh
	push	bc		;0000h @ fcech
	push	de		;0000h @ fceah
	push	hl		;0000h @ fce8h
	xor	a
	push	af		;0044h @ fce6h
	ld	a, r
	push	af		;ff80h @ fce4h
	push	bc		;0000h @ fce2h
	push	de		;0000h @ fce0h
	push	hl		;0000h @ fcdeh
	xor	a
	ld	r, a
	ld	a, 55h
	ld	i, a
	push	af		;5544h @ fcdch
	push	bc		;0000h @ fcdah
	push	de		;0000h @ fcd8h
	push	hl		;0000h @ fcd6h
	xor	a
	push	af		;0044h @ fcd4h
	ld	a, i
	push	af		;5500h @ fcd2h
	ei
	ld	a, i
	push	af		;5504h @ fcd0h
	di
	ld	a, i
	push	af		;5500h @ fcceh
;-------------
	xor	a
	ld	sp, 0fc00h
	ld	ix, 00000h
	ld	iy, 0ffffh
	ld	bc, 0aaaah
	ld	de, 05555h
	ld	hl, 02222h
	ld	xh, 0a5h
	push	ix		;a500h @ fbfeh
	ld	xl, 057h
	push	ix		;a557h @ fbfch
	ld	yh, 0beh
	push	iy		;beffh @ fbfah
	ld	yl, 03dh
	push	iy		;be3dh @ fbf8h
	push	af		;0044h @ fbf6h
	push	bc		;aaaah @ fbf4h
	push	de		;5555h @ fbf2h
	push	hl		;2222h @ fbf0h
;
	ld	a,xh
	push	af		;a544h @ fbeeh
	ld	a,xl
	push	af		;5744h @ fbech
	ld	a,yh
	push	af		;be44h @ fbeah
	ld	a,yl
	push	af		;3d44h @ fbe8h
;
	ld	a,05h
	ld	xl,a
	ld	a,0feh
	ld	yh,a
	ld	a,0adh
	ld	xh,a
	ld	a,7eh
	ld	yl,a
	push	ix		;ad05h @ fbe6h
	push	iy		;fe7eh @ fbe4h
	push	af		;7e44h @ fbe2h
;
	ld	b,xh
	ld	c,xl
	ld	xl,b
	ld	xh,c
	push	bc		;ad05h @ fbe0h
	push	ix		;05adh @ fbdeh
	ld	b,yh
	ld	c,yl
	ld	yl,b
	ld	yh,c
	push	bc		;fe7eh @ fbdch
	push	iy		;7efeh @ fbdah
	ld	b,xl
	ld	c,xh
	ld	xh,b
	ld	xl,c
	push	bc		;ad05h @ fbd8h
	push	ix		;ad05h @ fbd6h
	ld	b,yl
	ld	c,yh
	ld	yh,b
	ld	yl,c
	push	bc		;fe7eh @ fbd4h
	push	iy		;fe7eh @ fbd2h
	push	af		;7e44h @ fbd0h

	ld	e,xh
	ld	d,xl
	ld	xl,e
	ld	xh,d
	push	de		;05adh @ fbceh
	push	ix		;05adh @ fbcch
	ld	d,yh
	ld	e,yl
	ld	yl,d
	ld	yh,e
	push	de		;fe7eh @ fbcah
	push	iy		;7efeh @ fbc8h
	ld	e,xl
	ld	d,xh
	ld	xh,e
	ld	xl,d
	push	de		;05adh @ fbc6h
	push	ix		;ad05h @ fbc4h
	ld	d,yl
	ld	e,yh
	ld	yh,d
	ld	yl,e
	push	de		;fe7eh @ fbc2h
	push	iy		;fe7eh @ fbc0h
	ld	a,xl
	ld	xl,xh
	ld	xh,a
	push	ix		;05adh @ fbbeh
	ld	a,yl
	ld	yl,yh
	ld	yh,a
	push	iy		;7efeh @ fbbch
	push	bc		;fe7eh @ fbbah
	push	hl		;2222h @ fbb8h
;-------------
	ld	hl, 0100h	;init hl for next pattern
	jp	0c0h

	org	02020h		;data for ld r,(hl)
	db	05ah
	db	069h
	db	078h
	db	087h
	db	096h
	db	0a5h

	org	05a69h		;data for ld a,(bc)
	db	0b4h

	org	06789h		;data for ld r,(ix+d)
	db	0ffh
	db	0fdh
	db	0fbh
	db	0f9h
	db	0f7h
	db	0f5h
	db	0f3h

	org	07887h		;data for ld rr,(mn)
	db	0c3h
	db	0d2h
	dw	0e1f0h
	dw	00f1eh
	dw	02d3ch
	dw	04b5ah
	dw	06978h
	dw	0fe00h

	org	0abcdh		;dta for ld r,(iy+d)
	db	01h
	db	03h
	db	05h
	db	07h
	db	09h
	db	0bh
	db	0dh

	org	0f000h		;data for pop
	dw	00f00h
	dw	0ee11h
	dw	0dd22h
	dw	0cc33h
	dw	0bb44h
	dw	0aa55h

	org	0fd00h		;data for ex (sp),
	dw	02345h
	dw	06789h
	dw	0abcdh

	end
