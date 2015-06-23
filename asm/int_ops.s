;**********************************************************************************
;*                                                                                *
;* checks interrupt options and conditions                                        *
;*                                                                                *
;**********************************************************************************
	aseg

	org	00h
	jp	(hl)

	org	38h
	inc	bc
	exx
	inc	hl
	ld	(hl), l	;write a marker
	exx
	jp	(hl)

	org	66h
	inc	bc
	inc	ix
	ld	(ix+0), c	;write a marker
	jp	(hl)

	org	0c0h		;pattern finish location
	nop
	jr	0c0h

	org	0100h
	ex	af,af'
	xor	a
	dec	a
	ex	af,af'
	exx
	ld	bc, 0edb7h
	ld	de, 08421h
	ld	hl, 03cc3h
	exx
	xor	a
	ld	bc, 00001h
	ld	de, 00100h
	ld	hl, 01000h
	ld	ix, 09669h
	ld	iy, 0bffeh
	jp	(hl)		;1000h

	org	1000h
	push	bc		;0001h @ fffeh
	add	hl, de
	add	iy, de
	jp	(iy)		;c0feh

	org	1100h
	inc	bc		;compensate for mode 0
	push	bc		;0002h @ fffah
	im	2
	add	hl, de
	im	1		;toggles back okay
	add	iy, de
	ei
	jp	(iy)		;c1feh

	org	1200h
	push	bc		;0003h @ fff6h
	add	hl, de
	add	iy, de
	ei
	jp	(iy)		;c2feh

	org	1300h
	push	bc		;0004h @ fff2h
	add	hl, de
	add	iy, de
	ei
	jp	(iy)		;c3feh

	org	1400h
	push	bc		;0005h @ ffeeh
	add	hl, de
	add	iy, de
	ei
	jp	(iy)		;c4feh

	org	1500h
	push	bc		;0006h @ ffeah
	add	hl, de
	add	iy, de
	ei
	jp	(iy)		;c5feh

	org	1600h
	push	bc		;0007h @ ffe6h
	add	hl, de
	add	iy, de
	ei
	jp	(iy)		;c6feh

	org	1700h
	push	bc		;0008h @ ffe2h
	add	hl, de
	add	iy, de
	ei
	jp	(iy)		;c7feh

	org	1800h
	push	bc		;0009h @ ffdeh
	add	hl, de
	add	iy, de
	ei
	jp	(iy)		;c8feh

	org	1900h
	push	bc		;000ah @ ffdah
	add	hl, de
	add	iy, de
	ei
	jp	(iy)		;c9feh

	org	1a00h
	push	bc		;000bh @ ffd6h
	add	hl, de
	add	iy, de
	ei
	jp	(iy)		;cafeh

	org	1b00h
	push	bc		;000ch @ ffd2h
	add	hl, de
	add	iy, de
	ei
	jp	(iy)		;cbfeh

	org	1c00h
	push	bc		;000dh @ ffceh
	inc	bc		;compensate for cpir
	add	hl, de
	add	iy, de
	ei
	jp	(iy)		;ccfeh

	org	1d00h
	db	0ffh		;cpir no match data
	push	bc		;000eh @ ffcah
	inc	bc		;compensate for cpir
	dec	hl		;compensate for cpir
	add	hl, de
	add	iy, de
	ei
	jp	(iy)		;cdfeh

	org	1e00h
	db	00h		;cpir match data
	push	bc		;000fh @ ffc6h
	dec	hl		;compensate for cpir
	add	hl, de
	add	iy, de
	jp	(iy)		;cefeh

	org	1f00h
	push	bc		;0010h @ ffc2h
	add	hl, de
	add	iy, de
	jp	(iy)		;cffeh

	org	2000h
	push	bc		;0011h @ ffbeh
	add	hl, de
	add	iy, de
	im	0		;no effect
	ei
	jp	(iy)		;d0feh

	org	2100h
	inc	bc		;compensate for im 0 address
	push	bc		;0012h @ ffbah
	add	hl, de
	add	iy, de
	ei
	jp	(iy)		;d1feh

	org	2200h
	push	bc		;0013h @ ffb6h
	add	hl, de
	add	iy, de
	ld	a, i
	push	af		;0044h @ ffb4h
	ld	sp, 02250h
	retn			;2230h @ 2250h read
	halt			;not executed

	org	2230h
	ld	a, i
	ld	sp, 0ffb4h
	push	af		;0044h @ ffb2h
	ld	a, 055h
	ld	i, a
	im	2
	jp	(iy)		;d2feh

	org	2250h
	dw	02230h	;data for retn

	org	2300h
	inc	bc
	push	bc		;0014h @ ffaeh
	add	hl, de
	add	iy, de
	ld	a, i
	push	af		;5500h @ ffach
	ld	sp, 02350h
	reti			;2330h @ 2350h read
	halt			;not executed

	org	2330h
	ld	a, i
	ld	sp, 0ffach
	im	0		;no effect
	push	af		;5500h @ ffaah
	ei
	ld	iy, 0d310h
	jp	(iy)		;d310h

	org	2350h
	dw	02330h	;data for reti

	org	2400h
	push	bc		;0015h @ ffa6h
	add	hl, de
	add	iy, de
	ld	sp, 02450h
	retn			;2430h @ 2450h read
	halt			;not executed

	org	2430h
	ld	sp, 0ffa6h
	jp	(iy)		;d410h

	org	2450h
	dw	02430h	;data for retn

	org	2500h
	inc	bc		;compensate for mode 0
	push	bc		;0016h @ ffa2h
	add	hl, de
	add	iy, de
	ld	sp, 02550h
	retn			;2530h @ 2550h read
	halt			;not executed

	org	2530h
	ld	sp, 0ffa2h
	jp	(iy)		;d510h

	org	2550h
	dw	02530h	;data for retn


	org	2600h
	push	bc		;0017h @ ff9eh
	push	de		;0100h @ ff9eh
	push	hl		;2600h @ ff9ch
	push	af		;5500h @ ff98h
	im	1
	ld	hl, 2700h
	ld	iy, 0d6feh
	ei
	jp	(iy)		;d6feh

	org	2700h
	push	bc		;0018h @ ff94h
	push	de		;0100h @ ff92h
	push	hl		;2700h @ ff90h
	push	af		;4204h @ ff8eh
	ld	hl, 2800h
	ld	iy, 0d7feh
	ei
	jp	(iy)		;d7feh

	org	2800h
	push	bc		;0019h @ ff8ah
	push	de		;0100h @ ff88h
	push	hl		;2800h @ ff86h
	push	af		;6a04h @ ff84h
	ld	hl, 2900h
	ld	iy, 0d8feh
	ei
	jp	(iy)		;d8feh

	org	2900h
	push	bc		;001ah @ ff80h
	push	de		;0100h @ ff7eh
	push	hl		;2900h @ ff7ch
	push	af		;9394h @ ff7ah
	ld	hl, 2a00h
	ld	iy, 0d9feh
	ei
	jp	(iy)		;d9feh

	org	2a00h
	push	bc		;001bh @ ff76h
	push	de		;0100h @ ff74h
	push	hl		;2a00h @ ff72h
	push	af		;6916h @ ff70h
	ld	hl, 1580h
	ld	iy, 0dafeh
	ei
	jp	(iy)		;dafeh

	org	2b00h
	push	bc		;001ch @ ff6ch
	push	de		;0100h @ ff6ah
	push	hl		;2b00h @ ff68h
	push	af		;6900h @ ff66h
	ld	hl, 1600h
	ld	iy, 0dbfeh
	ei
	jp	(iy)		;dbfeh

	org	2c00h
	push	bc		;001dh @ ff62h
	push	de		;0100h @ ff60h
	push	hl		;2c00h @ ff5eh
	push	af		;6900h @ ff5ch
	ld	hl, 2d01h
	ld	iy, 0dcfeh
	ei
	jp	(iy)		;dcfeh

	org	2d00h
	push	bc		;001eh @ ff58h
	push	de		;0100h @ ff56h
	push	hl		;2d00h @ ff54h
	push	af		;6900h @ ff52h
	ld	hl, 2e01h
	ld	iy, 0ddfeh
	ei
	jp	(iy)		;ddfeh

	org	2e00h
	push	bc		;001fh @ ff4eh
	push	de		;0100h @ ff4ch
	push	hl		;2e00h @ ff4ah
	push	af		;6900h @ ff48h
	ld	sp, 02e50h
	retn			;2e30h @ 2e50h read
	halt			;not executed

	org	2e30h
	ld	sp, 0ff48h
	ld	iy, 0d610h
	jp	(iy)		;d610h

	org	2e50h
	dw	02e30h

	org	4ce3h
	db	05ah

	org	5564h
	dw	02300h

	org	0c0feh
	dec	hl		;int next
	inc	hl
	ei
	nop			;c101h @ fffch with busreq
	jp	nc, 5000h	;c102h @ fffch
	halt			;not executed

	org	0c1feh
	nop			;nmi next
	jp	c, 5000h	;c202h @ fff8h
	halt			;not executed

	org	0c2feh
	nop			;int next
	jp	nc, 5000h	;5000h @ fff4h
	halt			;not executed

	org	0c3feh
	nop			;nmi next
	jp	nc, 5000h	;5000h @ fff0h
	halt			;not executed

	org	0c4feh
	nop			;int next
	jr	c, 0c4feh	;c501h @ ffech
	halt			;not executed

	org	0c5feh
	nop			;nmi next
	jr	c, 0c5feh	;c601h @ ffe8h
	halt			;not executed

	org	0c6feh
	nop			;int next
	jr	nc, 0c6feh	;c6feh @ ffe4h
	halt			;not executed

	org	0c7feh
	nop			;nmi next
	jr	nc, 0c7feh	;c7feh @ ffe0h
	halt			;not executed

	org	0c8feh
	halt			;int next
	rst	28h		;c8ffh @ ffdch

	org	0c9feh
	halt			;nmi next
	rst	28h		;c9ffh @ ffd8h
	jp	5000h		;not executed

	org	0cafeh
	nop			;int next
	halt			;cb00h @ ffd4h
	jp	5000h		;not executed

	org	0cbfeh
	nop			;nmi next
	halt			;cc00h @ ffd0h
	jp	5000h		;not executed

	org	0ccfeh
	nop			;int next
	cpir			;ccffh @ ffcch
	rst	08h		;not executed

	org	0cdfeh
	nop			;nmi next
	cpir			;ce01h @ ffc8h
	rst	10h		;not executed

	org	0cefeh
	nop			;int next
	ei			;cf00h @ ffc4h with busreq
	nop			;cf01h @ ffc4h
	rst	18h		;not executed

	org	0cffeh
	nop			;nmi next
	di			;d001h @ ffc0h
	nop
	rst	28h		;not executed

	org	0d0feh
	nop			;int next
	di			;d101h @ ffbch
	dec	hl
	inc	hl
	ei
	nop			;d103h @ ffbch with busreq
	rst	30h		;not executed

	org	0d1feh
	dec	hl		;nmi next
	inc	hl		;d200h @ ffb8h
	rst	28h		;not executed

	org	0d2feh
	dec	hl		;int next
	inc	hl		;d300h @ ffb0h
	db	064h		;2300h @ 5564h read - mode 2

	org	0d310h
	halt			;nmi next
	rst	30h		;d311h @ ffa8h

	org	0d410h
	nop			;int next
	halt			;d412h @ ffa4h
	jp	5000h		;not executed

	org	0d510h
	nop			;int next
	halt			;d512h @ ffa0h
	jp	5000h		;not executed

	org	0d610h
	xor	a
	ld	a, 04ch
	in	a, (0e3h)	;  5ah @ 4ce3h
	push	af		;5a44h @ ff46h
	out	(3ch), a	;  5ah @ 5a3ch
	push	af
	push	bc
	push	de
	push	hl
	push	ix
	push	iy
	ex	af,af'
	push	af
	ex	af,af'
	exx
	push	bc
	push	de
	push	hl
	exx

	di
	nop
	slp
	nop

	ld	hl,0d740h
	ei			;int next
	slp			;d633h @ ff30h
	rst	00h		;not executed

	org	0d640h
	di
	ld	hl, 0100h
	jp 0c0h

	org	0d6feh
	nop			;int next
	xor	c		;d700 @ ff96h

	org	0d740h
	di
	ld	hl,0d640h
	nop			;nmi next
	slp			;d747h @ ff2eh
	rst	00h

	org	0d7feh
	nop			;nmi next
	xor	h		;d800 @ ff8ch
	nop

	org	0d8feh
	nop			;int next
	adc	a,h		;d900 @ ff82h
	nop

	org	0d9feh
	nop			;nmi next
	sbc	a,h		;da00 @ ff78h
	nop

	org	0dafeh
	nop			;int next
	adc	hl, hl	;db00 @ ff6eh
	nop

	org	0dbfeh
	nop			;nmi next
	adc	hl, hl	;dc00 @ ff64h
	nop

	org	0dcfeh
	nop			;int next
	dec	hl		;dd00 @ ff5ah
	nop

	org	0ddfeh
	nop			;nmi next
	dec	hl		;de00 @ ff50h
	nop

	end
