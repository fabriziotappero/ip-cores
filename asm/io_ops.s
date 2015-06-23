;**********************************************************************************
;*                                                                                *
;* checks all i/o and block instructions                                          *
;*                                                                                *
;**********************************************************************************
	aseg

	org	00h
	jp	01000h

	org	0c0h		;pattern finish location
	nop
	jr	0c0h

	org	0e0h
	db	010h

	org	01e1h
	db	013h
	db	088h

	org	02e1h
	db	012h
	db	017h

	org	03e1h
	db	011h
	db	016h

	org	04e2h
	db	015h

	org	05e2h
	db	014h

	org	01000h
	ld	sp, 0000h
	xor	a
	ld	b, a
	ld	c, 0ffh
	ld	d, a
	ld	e, 021h
	ld	h, a
	ld	l, 0aah
	ld	a, 0cch
	in	a, (0f0h)	;  5ah @ ccf0h
	push	af		;5a44h @ fffeh
	out	(3ch), a	;  5ah @ 5a3ch
	ld	a, 0ffh

	ld	sp, 0ffd2h
	ld	bc, 0e123h
	in	b, (c)		;  c6h @ e123h
	push	af		;ff84h @ ffd0h
	push	bc		;c623h @ ffceh
	in	c, (c)		;  10h @ c623h
	push	af		;ff00h @ ffcch
	push	bc		;c610h @ ffcah
	in	d, (c)		;  a0h @ c610h
	push	af		;ff84h @ ffc8h
	push	bc		;c610h @ ffc6h
	push	de		;a021h @ ffc4h
	inc	bc
	in	e, (c)		;  eah @ c611h
	push	af		;ff80h @ ffc2h
	push	bc		;c611h @ ffc0h
	push	de		;a0eah @ ffbeh
	inc	bc
	in	h, (c)		;  66h @ c612h
	push	af		;ff04h @ ffbch
	push	bc		;c612h @ ffbah
	push	de		;a0eah @ ffb8h
	push	hl		;66aah @ ffb6h
	inc	bc
	in	l, (c)		;  00h @ c613h
	push	af		;ff44h @ ffb4h
	push	bc		;c613h @ ffb2h
	push	de		;a0eah @ ffb0h
	push	hl		;6600h @ ffaeh
	inc	bc
	in	a, (c)		;  43h 2 c614h
	push	af		;4300h @ ffach
	push	bc		;c614h @ ffaah
	push	de		;a0eah @ ffa8h
	push	hl		;6600h @ ffa6h

	inc	bc
	out	(c), b		;  c6h @ c615h
	inc	bc
	out	(c), c		;  16h @ c616h
	inc	bc
	out	(c), d		;  a0h @ c617h
	inc	bc
	out	(c), e		;  eah @ c618h
	inc	bc
	out	(c), h		;  66h @ c619h
	inc	bc
	out	(c), l		;  00h @ c61ah
	inc	bc
	out	(c), a		;  43h @ c61bh

	or	b
	ld	a, 043h

	ld	sp, 0ff8eh
	ld	bc, 08000h
	ld	de, 0a000h
	ld	hl, 05000h
	ldd			;  55h @ 5000h read
				;  55h @ a000h write
	push	af		;4384h @ ff8ch
	push	bc		;7fffh @ ff8ah
	push	de		;9fffh @ ff88h
	push	hl		;4fffh @ ff86h
	ldi			;  aah @ 4fffh read
				;  aah @ 9fffh write
	push	af		;4384h @ ff84h
	push	bc		;7ffeh @ ff82h
	push	de		;a000h @ ff80h
	push	hl		;5000h @ ff7eh
	ld	bc, 0003h
	ld	de, 0a001h
	ld	hl, 05002h
	ldir			;  01h @ 5002h read
				;  01h @ a001h	write
				;  02h @ 5003h read
				;  02h @ a002h write
				;  03h @ 5004h read
				;  03h @ a003h write
	push	af		;4380h @ ff7ch
	push	bc		;0000h @ ff7ah
	push	de		;a004h @ ff78h
	push	hl		;5005h @ ff76h
	ld	bc, 0004h
	ld	de, 09ffeh
	ld	hl, 04ffdh
	lddr			;  04h @ 4ffdh read
				;  04h @ 9ffeh write
				;  05h @ 4ffch read
				;  05h @ 9ffdh write
				;  06h @ 4ffbh read
				;  06h @ 9ffch write
				;  07h @ 4ffah read
				;  07h @ 9ffbh write
	push	af		;4380h @ ff74h
	push	bc		;0000h @ ff72h
	push	de		;9ffah @ ff70h
	push	hl		;4ff9h @ ff6eh
	cpd			;  08h @ 4ff9h read
	push	af		;4316h @ ff6ch
	push	bc		;ffffh @ ff6ah
	push	de		;9ffah @ ff68h
	push	hl		;4ff8h @ ff66h
	ld	bc, 0007h
	cpdr			;  09h @ 4ff8h read
				;  0ah @ 4ff7h read
				;  43h @ 4ff6h read
	push	af		;4346h @ ff64h
	push	bc		;0004h @ ff62h
	push	de		;9ffah @ ff60h
	push	hl		;4ff5h @ ff5eh
	ld	bc, 8000h
	ld	hl, 5005h
	cpi			;  0bh @ 5005h read
	push	af		;4316h @ ff5ch
	push	bc		;7fffh @ ff5ah
	push	de		;9ffah @ ff58h
	push	hl		;5006h @ ff56h
	ld	bc, 0004h
	cpir			;  0ch @ 5006h read
				;  0dh @ 5007h read
				;  0eh @ 5008h read
				;  0fh @ 5009h read
	push	af		;4312h @ ff54h
	push	bc		;0000h @ ff52h
	push	de		;9ffah @ ff50h
	push	hl		;500ah @ ff4eh
	ld	bc, 00e0h
	ini			;  10h @ 00e0h read
				;  10h @ 500ah write
	push	af		;4310h @ ff4ch
	push	bc		;ffe0h @ ff4ah
	push	de		;9ffah @ ff48h
	push	hl		;500bh @ ff46h
	ld	bc, 03e1h
	inir			;  11h @ 03e1h read
				;  11h @ 500bh write
				;  12h @ 02e1h read
				;  12h @ 500ch write
				;  13h @ 01e1h read
				;  13h @ 500dh write
	push	af		;4350h @ ff44h
	push	bc		;00e1h @ ff42h
	push	de		;9ffah @ ff40h
	push	hl		;500eh @ ff3eh
	ld	bc, 05e2h
	ld	hl, 4ff5h
	ind			;  14h @ 05e2h read
				;  14h @ 4ff5h write
	push	af		;4310h @ ff3ch
	push	bc		;04e2h @ ff3ah
	push	de		;9ffah @ ff38h
	push	hl		;4ff4h @ ff36h
	indr			;  15h @ 04e2h read
				;  15h @ 4ff4h write
				;  16h @ 03e2h read
				;  16h @ 4ff3h write
				;  17h @ 02e2h read
				;  17h @ 4ff2h write
				;  88h @ 01e2h read
				;  88h @ 4ff1h write
	push	af		;4352h @ ff34h
	push	bc		;00e2h @ ff32h
	push	de		;9ffah @ ff30h
	push	hl		;4ff0h @ ff2eh
	ld	bc, 04e3h
	outd			;  19h @ 4ff0h read
				;  19h @ 04e3h write
	push	af		;4310h @ ff2ch
	push	bc		;00e3h @ ff2ah
	push	de		;9ffah @ ff28h
	push	hl		;4fefh @ ff26h
	otdr			;  1ah @ 4fefh read
				;  1ah @ 03e3h write
				;  1bh @ 4feeh read
				;  1bh @ 02e3h write
				;  1ch @ 4fedh read
				;  1ch @ 01e3h write
	push	af		;4350h @ ff24h
	push	bc		;00e3h @ ff22h
	push	de		;9ffah @ ff20h
	push	hl		;4fech @ ff1eh
	ld	bc, 05e4h
	ld	hl, 500eh
	outi			;  1dh @ 500eh read
				;  1dh @ 05e4h write
	push	af		;4310h @ ff1ch
	push	bc		;04e4h @ ff1ah
	push	de		;9ffah @ ff18h
	push	hl		;500fh @ ff16h
	otir			;  1eh @ 500fh read
				;  1eh @ 04e4h write
				;  1fh @ 5010h read
				;  1fh @ 03e4h write
				;  20h @ 5011h read
				;  20h @ 02e4h write
				;  a1h @ 5012h read
				;  a1h @ 01e4h write
	push	af		;4352h @ ff14h
	push	bc		;00e4h @ ff12h
	push	de		;9ffah @ ff10h
	push	hl		;5013h @ ff0eh

	ld	hl, 0100h
	jp	0c0h

	org	04fe8h
	db	0ffh, 0ffh, 0a8h, 027h, 026h, 01ch, 01bh, 01ah
	db	019h, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 043h, 00ah
	db	009h, 008h, 007h, 006h, 005h, 004h, 0ffh, 0aah
	db	055h, 0ffh, 001h, 002h, 003h, 00bh, 00ch, 00dh
	db	00eh, 00fh, 0ffh, 0ffh, 0ffh, 0ffh, 01dh, 01eh
	db	01fh, 020h, 0a1h, 022h, 023h, 022h, 025h, 0ffh

	org	06600h
	db	0bch

	org	0c610h
	db	0a0h, 0eah, 066h, 000h, 043h

	org	0c61bh
	db	08fh

	org	0c623h
	db	10h

	org	0ccf0h
	db	05ah

	org	0e123h
	db	0c6h






