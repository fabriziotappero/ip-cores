;**********************************************************************************
;*                                                                                *
;* checks all bit manipulation instructions                                       *
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
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	ld	ix, 07ffeh
	ld	iy, 07201h
	push	af		;0044h @ fffeh
	push	bc		;0000h @ fffch
	push	de		;0000h @ fffah
	push	hl		;0000h @ fff8h
	push	ix		;7ffeh @ fff6h
	push	iy		;7201h @ fff4h
	set	0, a
	set	1, b
	set	2, c
	set	3, d
	set	4, e
	set	5, h
	set	6, l
	push	af		;0144h @ fff2h
	push	bc		;0204h @ fff0h
	push	de		;0810h @ ffeeh
	push	hl		;2040h @ ffech
	xor	a
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	set	0, b
	set	1, c
	set	2, d
	set	3, e
	set	4, h
	set	5, l
	set	6, a
	push	af		;4044h @ ffeah
	push	bc		;0102h @ ffe8h
	push	de		;0408h @ ffe6h
	push	hl		;1020h @ ffe4h
	xor	a
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	set	0, c
	set	1, d
	set	2, e
	set	3, h
	set	4, l
	set	5, a
	set	6, b
	push	af		;2044h @ ffe2h
	push	bc		;4001h @ ffe0h
	push	de		;0204h @ ffdeh
	push	hl		;0810h @ ffdch
	xor	a
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	set	0, d
	set	1, e
	set	2, h
	set	3, l
	set	4, a
	set	5, b
	set	6, c
	push	af		;1044h @ ffdah
	push	bc		;2040h @ ffd8h
	push	de		;0102h @ ffd6h
	push	hl		;0408h @ ffd4h
	xor	a
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	set	0, e
	set	1, h
	set	2, l
	set	3, a
	set	4, b
	set	5, c
	set	6, d
	push	af		;0844h @ ffd2h
	push	bc		;1020h @ ffd0h
	push	de		;4001h @ ffceh
	push	hl		;0204h @ ffcch
	xor	a
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	set	0, h
	set	1, l
	set	2, a
	set	3, b
	set	4, c
	set	5, d
	set	6, e
	push	af		;0444h @ ffcah
	push	bc		;0810h @ ffc8h
	push	de		;2040h @ ffc6h
	push	hl		;0102h @ ffc4h
	xor	a
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	set	0, l
	set	1, a
	set	2, b
	set	3, c
	set	4, d
	set	5, e
	set	6, h
	push	af		;0244h @ ffc2h
	push	bc		;0408h @ ffc0h
	push	de		;1020h @ ffbeh
	push	hl		;4001h @ ffbch
	xor	a
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	hl, 7000h
	set	0, (hl)		;  00h @ 7000h read
				;  01h @ 7000h write
	set	7, a
	push	af		;8044h @ ffbah
	push	bc		;0000h @ ffb8h
	push	de		;0000h @ ffb6h
	push	hl		;7000h @ ffb4h
	ld	a, b
	inc	hl
	set	1, (hl)		;  00h @ 7001h read
				;  02h @ 7001h write
	set	7, b
	push	af		;0044h @ ffb2h
	push	bc		;8000h @ ffb0h
	push	de		;0000h @ ffaeh
	push	hl		;7001h @ ffach
	ld	b, a
	inc	hl
	set	2, (hl)		;  00h @ 7002h read
				;  04h @ 7002h write
	set	7, c
	push	af		;0044h @ ffaah
	push	bc		;0080h @ ffa8h
	push	de		;0000h @ ffa6h
	push	hl		;7002h @ ffa4h
	ld	c, a
	inc	hl
	set	3, (hl)		;  00h @ 7003h read
				;  08h @ 7003h write
	set	7, d
	push	af		;0044h @ ffa2h
	push	bc		;0000h @ ffa0h
	push	de		;8000h @ ff9eh
	push	hl		;7003h @ ff9ch
	ld	d, a
	inc	hl
	set	4, (hl)		;  00h @ 7004h read
				;  10h @ 7004h write
	set	7, e
	push	af		;0044h @ ff9ah
	push	bc		;0000h @ ff98h
	push	de		;0080h @ ff96h
	push	hl		;7004h @ ff94h
	ld	e, a
	inc	hl
	set	5, (hl)		;  00h @ 7005h read
				;  20h @ 7005h write
	set	7, h
	push	af		;0044h @ ff92h
	push	bc		;0000h @ ff90h
	push	de		;0000h @ ff8eh
	push	hl		;f005h @ ff8ch
	ld	hl, 7006h
	set	6, (hl)		;  00h @ 7006h read
				;  40h @ 7006h write
	set	7, l
	push	af		;0044h @ ff8ah
	push	bc		;0000h @ ff88h
	push	de		;0000h @ ff86h
	push	hl		;7086h @ ff84h
	ld	hl, 7007h
	set	7, (hl)		;  00h @ 7007h read
				;  80h @ 7007h write
	push	af		;0044h @ ff82h
	push	bc		;0000h @ ff80h
	push	de		;0000h @ ff7eh
	push	hl		;7007h @ ff7ch
	set	0, (ix+7h)	;  00h @ 8005h read
				;  01h @ 8005h write
	set	1, (ix+6h)	;  00h @ 8004h read
				;  02h @ 8004h write
	set	2, (ix+5h)	;  00h @ 8003h read
				;  04h @ 8003h write
	set	3, (ix+4h)	;  00h @ 8002h read
				;  08h @ 8002h write
	set	4, (ix+3h)	;  00h @ 8001h read
				;  10h @ 8001h write
	set	5, (ix+2h)	;  00h @ 8000h read
				;  20h @ 8000h write
	set	6, (ix+1h)	;  00h @ 7fffh read
				;  40h @ 7fffh write
	set	7, (ix+0h)	;  00h @ 7ffeh read
				;  80h @ 7ffeh write
	set	0, (iy+0ffh)	;  00h @ 7200h read
				;  01h @ 7200h write
	set	1, (iy+0feh)	;  00h @ 71ffh read
				;  02h @ 71ffh write
	set	2, (iy+0fdh)	;  00h @ 71feh read
				;  04h @ 71feh write
	set	3, (iy+0fch)	;  00h @ 71fdh read
				;  08h @ 71fdh write
	set	4, (iy+0fbh)	;  00h @ 71fch read
				;  10h @ 71fch write
	set	5, (iy+0fah)	;  00h @ 71fbh read
				;  20h @ 71fbh write
	set	6, (iy+0f9h)	;  00h @ 71fah read
				;  40h @ 71fah write
	set	7, (iy+0f8h)	;  00h @ 71f9h read
				;  80h @ 71f9h write
	ld	a, 0ffh		;initialize the main registers
	or	a		;initialize flags
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	ld	ix, 7401h
	ld	iy, 70feh
	push	af		;ff84h @ ff7ah
	push	bc		;ffffh @ ff78h
	push	de		;ffffh @ ff76h
	push	hl		;ffffh @ ff74h
	push	ix		;7401h @ ff72h
	push	iy		;70feh @ ff70h
	res	0, a
	res	1, b
	res	2, c
	res	3, d
	res	4, e
	res	5, h
	res	6, l
	push	af		;fe84h @ ff6eh
	push	bc		;fdfbh @ ff6ch
	push	de		;f7efh @ ff6ah
	push	hl		;dfbfh @ ff68h
	ld	a, 0ffh
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	res	0, b
	res	1, c
	res	2, d
	res	3, e
	res	4, h
	res	5, l
	res	6, a
	push	af		;bf84h @ ff66h
	push	bc		;fefdh @ ff64h
	push	de		;fbf7h @ ff62h
	push	hl		;efdfh @ ff60h
	ld	a, 0ffh
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	res	0, c
	res	1, d
	res	2, e
	res	3, h
	res	4, l
	res	5, a
	res	6, b
	push	af		;df84h @ ff5eh
	push	bc		;bffeh @ ff5ch
	push	de		;fdfbh @ ff5ah
	push	hl		;f7efh @ ff58h
	ld	a, 0ffh
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	res	0, d
	res	1, e
	res	2, h
	res	3, l
	res	4, a
	res	5, b
	res	6, c
	push	af		;ef84h @ ff56h
	push	bc		;dfbfh @ ff54h
	push	de		;fefdh @ ff52h
	push	hl		;fbf7h @ ff50h
	ld	a, 0ffh
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	res	0, e
	res	1, h
	res	2, l
	res	3, a
	res	4, b
	res	5, c
	res	6, d
	push	af		;f784h @ ff4eh
	push	bc		;efdfh @ ff4ch
	push	de		;bffeh @ ff4ah
	push	hl		;fdfbh @ ff48h
	ld	a, 0ffh
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	res	0, h
	res	1, l
	res	2, a
	res	3, b
	res	4, c
	res	5, d
	res	6, e
	push	af		;fb84h @ ff46h
	push	bc		;f7efh @ ff44h
	push	de		;dfbfh @ ff42h
	push	hl		;fefdh @ ff40h
	ld	a, 0ffh
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	res	0, l
	res	1, a
	res	2, b
	res	3, c
	res	4, d
	res	5, e
	res	6, h
	push	af		;fd84h @ ff3eh
	push	bc		;fbf7h @ ff3ch
	push	de		;efdfh @ ff3ah
	push	hl		;bffeh @ ff38h
	ld	a, 0ffh
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	hl, 08480h
	res	0, (hl)		;  ffh @ 8480h read
				;  feh @ 8480h write
	res	7, a
	push	af		;7f84h @ ff36h
	push	bc		;ffffh @ ff34h
	push	de		;ffffh @ ff32h
	push	hl		;8480h @ ff30h
	ld	a, b
	inc	hl
	res	1, (hl)		;  ffh @ 8481h read
				;  fdh @ 8481h write
	res	7, b
	push	af		;ff84h @ ff2eh
	push	bc		;7fffh @ ff2ch
	push	de		;ffffh @ ff2ah
	push	hl		;8481h @ ff28h
	ld	b, a
	inc	hl
	res	2, (hl)		;  ffh @ 8482h read
				;  fbh @ 8482h write
	res	7, c
	push	af		;ff84h @ ff26h
	push	bc		;ff7fh @ ff24h
	push	de		;ffffh @ ff22h
	push	hl		;8482h @ ff20h
	ld	c, a
	inc	hl
	res	3, (hl)		;  ffh @ 8483h read
				;  f7h @ 8483h write
	res	7, d
	push	af		;ff84h @ ff1eh
	push	bc		;ffffh @ ff1ch
	push	de		;7fffh @ ff1ah
	push	hl		;8483h @ ff18h
	ld	d, a
	inc	hl
	res	4, (hl)		;  ffh @ 8484h read
				;  efh @ 8484h write
	res	7, e
	push	af		;ff84h @ ff16h
	push	bc		;ffffh @ ff14h
	push	de		;ff7fh @ ff12h
	push	hl		;8484h @ ff10h
	ld	e, a
	inc	hl
	res	5, (hl)		;  ffh @ 8485h read
				;  dfh @ 8485h write
	res	7, h
	push	af		;ff84h @ ff0eh
	push	bc		;ffffh @ ff0ch
	push	de		;ffffh @ ff0ah
	push	hl		;0485h @ ff08h
	ld	hl, 8486h
	res	6, (hl)		;  ffh @ 8486h read
				;  bfh @ 8486h write
	res	7, l
	push	af		;ff84h @ ff06h
	push	bc		;ffffh @ ff04h
	push	de		;ffffh @ ff02h
	push	hl		;8406h @ ff00h
	ld	hl, 8487h
	res	7, (hl)		;  ffh @ 8487h read
				;  7fh @ 8487h write
	push	af		;ff84h @ fefeh
	push	bc		;ffffh @ fefch
	push	de		;ffffh @ fefah
	push	hl		;8487h @ fef8h
	res	0, (ix+00h)	;  ffh @ 7401h read
				;  feh @ 7401h write
	res	1, (ix+0ffh)	;  ffh @ 7400h read
				;  fdh @ 7400h write
	res	2, (ix+0feh)	;  ffh @ 73ffh read
				;  fbh @ 73ffh write
	res	3, (ix+0fdh)	;  ffh @ 73feh read
				;  f7h @ 73feh write
	res	4, (ix+0fch)	;  ffh @ 73fdh read
				;  efh @ 73fdh write
	res	5, (ix+0fbh)	;  ffh @ 73fch read
				;  dfh @ 73fch write
	res	6, (ix+0fah)	;  ffh @ 73fbh read
				;  bfh @ 73fbh write
	res	7, (ix+0f9h)	;  ffh @ 73fah read
				;  7fh @ 73fah write
	res	0, (iy+2h)	;  ffh @ 7100h read
				;  feh @ 7100h write
	res	1, (iy+3h)	;  ffh @ 7101h read
				;  fdh @ 7101h write
	res	2, (iy+4h)	;  ffh @ 7102h read
				;  fbh @ 7102h write
	res	3, (iy+5h)	;  ffh @ 7103h read
				;  f7h @ 7103h write
	res	4, (iy+6h)	;  ffh @ 7104h read
				;  efh @ 7104h write
	res	5, (iy+7h)	;  ffh @ 7105h read
				;  dfh @ 7105h write
	res	6, (iy+8h)	;  ffh @ 7106h read
				;  bfh @ 7106h write
	res	7, (iy+9h)	;  ffh @ 7107h read
				;  7fh @ 7107h write
	xor	a		;clear accumulator
	ld	b, a		;clear register file
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	ld	ix, 0a000h
	ld	iy, 09000h
	ld	sp, 0c000h
	pop	af		;7fffh @ c000h
	ld	sp, 0c000h
	bit	7, a
	push	af		;7ffdh @ bffeh
	ld	sp, 0c002h
	pop	af		;40ffh @ c002h
	ld	sp, 0bffeh
	bit	6, a
	push	af		;40bdh @ bffch
	ld	sp, 0c004h
	pop	af		;df00h @ c004h
	ld	sp, 0bffch
	bit	5, a
	push	af		;df50h @ bffah
	ld	sp, 0c006h
	pop	af		;1000h @ c006h
	ld	sp, 0bffah
	bit	4, a
	push	af		;1010h @ bff8h
	ld	a, 0f7h
	bit	3, a
	push	af		;f750f @ bff6h
	ld	a, 04h
	bit	2, a
	push	af		;0410h @ bff4h
	ld	a, 0fdh
	bit	1, a
	push	af		;fd50h @ bff2h
	ld	a, 01h
	bit	0, a
	push	af		;0110h @ bff0h
	xor	a
	ld	bc, 0f0cch
	ld	de, 0aa0fh
	ld	hl, 3355h
	bit	7, b
	push	af		;0014h @ bfeeh
	bit	6, b
	push	af		;0014h @ bfech
	bit	5, b
	push	af		;0014h @ bfeah
	bit	4, b
	push	af		;0014h @ bfe8h
	bit	3, b
	push	af		;0054h @ bfe6h
	bit	2, b
	push	af		;0054h @ bfe4h
	bit	1, b
	push	af		;0054h @ bfe2h
	bit	0, b
	push	af		;0054h @ bfe0h
	bit	7, c
	push	af		;0014h @ bfdeh
	bit	6, c
	push	af		;0014h @ bfdch
	bit	5, c
	push	af		;0054h @ bfdah
	bit	4, c
	push	af		;0054h @ bfd8h
	bit	3, c
	push	af		;0014h @ bfd6h
	bit	2, c
	push	af		;0014h @ bfd4h
	bit	1, c
	push	af		;0054h @ bfd2h
	bit	0, c
	push	af		;0054h @ bfd0h
	bit	7, d
	push	af		;0014h @ bfceh
	bit	6, d
	push	af		;0054h @ bfcch
	bit	5, d
	push	af		;0014h @ bfcah
	bit	4, d
	push	af		;0054h @ bfc8h
	bit	3, d
	push	af		;0014h @ bfc6h
	bit	2, d
	push	af		;0054h @ bfc4h
	bit	1, d
	push	af		;0014h @ bfc2h
	bit	0, d
	push	af		;0054h @ bfc0h
	bit	7, e
	push	af		;0054h @ bfbeh
	bit	6, e
	push	af		;0054h @ bfbch
	bit	5, e
	push	af		;0054h @ bfbah
	bit	4, e
	push	af		;0054h @ bfb8h
	bit	3, e
	push	af		;0014h @ bfb6h
	bit	2, e
	push	af		;0014h @ bfb4h
	bit	1, e
	push	af		;0014h @ bfb2h
	bit	0, e
	push	af		;0014h @ bfb0h
	bit	7, h
	push	af		;0054h @ bfaeh
	bit	6, h
	push	af		;0054h @ bfach
	bit	5, h
	push	af		;0014h @ bfaah
	bit	4, h
	push	af		;0014h @ bfa8h
	bit	3, h
	push	af		;0054h @ bfa6h
	bit	2, h
	push	af		;0054h @ bfa4h
	bit	1, h
	push	af		;0014h @ bfa2h
	bit	0, h
	push	af		;0014h @ bfa0h
	bit	7, l
	push	af		;0054h @ bf9eh
	bit	6, l
	push	af		;0014h @ bf9ch
	bit	5, l
	push	af		;0054h @ bf9ah
	bit	4, l
	push	af		;0014h @ bf98h
	bit	3, l
	push	af		;0054h @ bf96h
	bit	2, l
	push	af		;0014h @ bf94h
	bit	1, l
	push	af		;0054h @ bf92h
	bit	0, l
	push	af		;0014h @ bf90h
	ld	hl, 8500h
	bit	7, (hl)		;  80h @ 8500h
	push	af		;0014h @ bf8eh
	inc	hl
	bit	6, (hl)		;  bfh @ 8501h
	push	af		;0054h @ bf8ch
	inc	hl
	bit	5, (hl)		;  20h @ 8502h
	push	af		;0014h @ bf8ah
	inc	hl
	bit	4, (hl)		;  10h @ 8503h
	push	af		;0014h @ bf88h
	inc	hl
	bit	3, (hl)		;  f7h @ 8504h
	push	af		;0054h @ bf86h
	inc	hl
	bit	2, (hl)		;  40h @ 8505h
	push	af		;0054h @ bf84h
	inc	hl
	bit	1, (hl)		;  fdh @ 8506h
	push	af		;0054h @ bf82h
	inc	hl
	bit	0, (hl)		;  feh @ 8507h
	push	af		;0054h @ bf80h
	ld	ix, 8502h
	ld	iy, 8564h
	bit	7, (ix+3eh)	;  00h @ 8540h
	push	af		;0054h @ bf7eh
	bit	6, (ix+3fh)	;  00h @ 8541h
	push	af		;0054h @ bf7ch
	bit	5, (ix+40h)	;  ffh @ 8542h
	push	af		;0014h @ bf7ah
	bit	4, (ix+41h)	;  ffh @ 8543h
	push	af		;0014h @ bf78h
	bit	3, (ix+42h)	;  ffh @ 8544h
	push	af		;0014h @ bf76h
	bit	2, (ix+43h)	;  ffh @ 8545h
	push	af		;0014h @ bf74h
	bit	1, (ix+44h)	;  00h @ 8546h
	push	af		;0054h @ bf72h
	bit	0, (ix+45h)	;  00h @ 8547h
	push	af		;0054h @ bf70h
	bit	7, (iy+1ch)	;  00h @ 8580h
	push	af		;0054h @ bf6eh
	bit	6, (iy+1dh)	;  ffh @ 8581h
	push	af		;0014h @ bf6ch
	bit	5, (iy+1eh)	;  00h @ 8582h
	push	af		;0054h @ bf6ah
	bit	4, (iy+1fh)	;  ffh @ 8583h
	push	af		;0014h @ bf68h
	bit	3, (iy+20h)	;  ffh @ 8584h
	push	af		;0014h @ bf66h
	bit	2, (iy+21h)	;  00h @ 8585h
	push	af		;0054h @ bf64h
	bit	1, (iy+22h)	;  ffh @ 8586h
	push	af		;0014h @ bf62h
	bit	0, (iy+23h)	;  00h @ 8587h
	push	af		;0054h @ bf60h

	ld	hl, 0100h	;init hl for next pattern
	jp	0c0h

	org	07000h		;data for set (hl)
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

	org	07100h		;data for res (iy+d)
	db	0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh

	org	071f9h		;data for set (iy+d)
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

	org	073fah		;data for res (ix+d)
	db	0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh

	org	07ffeh		;data for set (ix+d)
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

	org	08480h		;data for res (hl)
	db	0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh

	org	08500h		;data for bit (hl)
	db	80h, 0bfh, 20h, 10h, 0f7h, 40h, 0fdh, 0feh

	org	08540h		;data for bit (ix+d)
	db	00h, 00h, 0ffh, 0ffh, 0ffh, 0ffh, 00h, 00h

	org	08580h		;data for bit (iy+d)
	db	00h, 0ffh, 00h, 0ffh, 0ffh, 00h, 0ffh, 00h

	org	0c000h		;af data for bit
	dw	07fffh
	dw	040ffh
	dw	0df00h
	dw	01000h
