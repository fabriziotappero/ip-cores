;**********************************************************************************
;*                                                                                *
;* checks all alu operation instructions                                          *
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
	ld	ix, 05678h
	ld	iy, 0789ah
	ccf
	push	af		;0045h @ fffeh
	ccf
	push	af		;0044h @ fffch
	scf
	push	af		;0045h @ fffah
	scf
	push	af		;0045h @ fff8h
	ld	a, 80h
	cpl
	push	af		;7f57h @ fff6h
	cpl
	push	af		;8057h @ fff4h
	xor	a
	neg
	push	af		;0042h @ fff2h
	inc	a
	neg
	push	af		;ff93h @ fff0h
	ld	a, 02h
	neg
	push	af		;fe93h @ ffeeh
	neg
	push	af		;0213h @ ffech
	ld	a, 80h
	neg
	push	af		;8087h @ ffeah
	xor	a
	dec	bc
	push	bc		;ffffh @ ffe8h
	inc	bc
	push	bc		;0000h @ ffe6h
	inc	bc
	push	bc		;0001h @ ffe4h
	dec	de
	push	de		;ffffh @ ffe2h
	inc	de
	push	de		;0000h @ ffe0h
	dec	hl
	push	hl		;ffffh @ ffdeh
	inc	hl
	push	hl		;0000h @ ffdch
	dec	ix
	push	ix		;5677h @ ffdah
	dec	iy
	push	iy		;7899h @ ffd8h
	dec	sp
	dec	sp
	push	iy		;7899h @ ffd4h
	inc	ix
	push	ix		;5678h @ ffd2h
	push	iy		;7899h @ ffd0h
	inc	iy
	push	ix		;5678h @ ffceh
	push	iy		;789ah @ ffcch
	ld	sp, 0ffa0h
	inc	sp
	inc	sp
	push	af		;0044h @ ffa0h
	push	bc		;0001h @ ff9eh
	push	de		;0000h @ ff9ch
	push	hl		;0000h @ ff9ah
	ld	bc, 5454h
	ld	de, 1234h
	ld	hl, 0fdb9h
	add	hl, bc
	push	af		;0055h @ ff98h
	push	bc		;5454h @ ff96h
	push	de		;1234h @ ff94h
	push	hl		;520dh @ ff92h
	add	hl, de
	push	af		;0044h @ ff90h
	push	bc		;5454h @ ff8eh
	push	de		;1234h @ ff8ch
	push	hl		;6441h @ ff8ah
	add	hl, hl
	push	af		;0044h @ ff88h
	push	bc		;5454h @ ff86h
	push	de		;1234h @ ff84h
	push	hl		;c882h @ ff82h
	add	hl, sp
	push	af		;0055h @ ff80h
	push	bc		;5454h @ ff7eh
	push	de		;1234h @ ff7ch
	push	hl		;c804h @ ff7ah
	push	ix		;5678h @ ff78h
	push	iy		;789ah @ ff76h
	add	ix, bc
	push	af		;0044h @ ff74h
	push	bc		;5454h @ ff72h
	push	de		;1234h @ ff70h
	push	hl		;c804h @ ff6eh
	push	ix		;aacch @ ff6ch
	push	iy		;789ah @ ff6ah
	add	ix, de
	push	af		;0044h @ ff68h
	push	bc		;5454h @ ff66h
	push	de		;1234h @ ff64h
	push	hl		;c804h @ ff62h
	push	ix		;bd00h @ ff60h
	push	iy		;789ah @ ff5eh
	add	ix, sp
	push	af		;0055h @ ff5ch
	push	bc		;5454h @ ff5ah
	push	de		;1234h @ ff58h
	push	hl		;c804h @ ff56h
	push	ix		;bc5eh @ ff54h
	push	iy		;789ah @ ff52h
	add	ix, ix
	push	af		;0055h @ ff50h
	push	bc		;5454h @ ff4eh
	push	de		;1234h @ ff4ch
	push	hl		;c804h @ ff4ah
	push	ix		;78bch @ ff48h
	push	iy		;789ah @ ff46h
	add	iy, bc
	push	af		;0044h @ ff44h
	push	bc		;5454h @ ff42h
	push	de		;1234h @ ff40h
	push	hl		;c804h @ ff3eh
	push	ix		;78bch @ ff3ch
	push	iy		;cceeh @ ff3ah
	add	iy, de
	push	af		;0044h @ ff38h
	push	bc		;5454h @ ff36h
	push	de		;1234h @ ff34h
	push	hl		;c804h @ ff32h
	push	ix		;78bch @ ff30h
	push	iy		;df22h @ ff2eh
	add	iy, sp
	push	af		;0055h @ ff2ch
	push	bc		;5454h @ ff2ah
	push	de		;1234h @ ff28h
	push	hl		;c804h @ ff26h
	push	ix		;78bch @ ff24h
	push	iy		;de50h @ ff22h
	add	iy, iy
	push	af		;0055h @ ff20h
	push	bc		;5454h @ ff1eh
	push	de		;1234h @ ff1ch
	push	hl		;c804h @ ff1ah
	push	ix		;78bch @ ff18h
	push	iy		;bca0h @ ff16h
	ld	sp, 0ff00h
	xor	a
	inc	a
	push	af		;0100h @ fefeh
	ld	a, 0fh
	inc	a
	push	af		;1010h @ fefch
	ld	a, 7fh
	inc	a
	push	af		;8094h @ fefah
	ld	a, 0ffh
	inc	a
	push	af		;0050h @ fef8h
	dec	a
	push	af		;ff92h @ fef6h
	dec	a
	push	af		;fe82h @ fef4h
	ld	a, 10h
	dec	a
	push	af		;0f12h @ fef2h
	ld	a, 80h
	dec	a
	push	af		;7f16h @ fef0h
	push	bc		;5454h @ feeeh
	push	de		;1234h @ feech
	push	hl		;c804h @ feeah
	push	ix		;78bch @ fee8h
	push	iy		;bca0h @ fee6h
	inc	b
	inc	d
	inc	d
	inc	h
	inc	h
	inc	h
	push	af		;7f80h @ fee4h
	push	bc		;5554h @ fee2h
	push	de		;1434h @ fee0h
	push	hl		;cb04h @ fedeh
	inc	c
	inc	c
	inc	c
	inc	e
	inc	e
	inc	l
	push	af		;7f00h @ fedch
	push	bc		;5557h @ fedah
	push	de		;1436h @ fed8h
	push	hl		;cb05h @ fed6h
	dec	b
	dec	b
	dec	b
	dec	d
	dec	d
	dec	h
	push	af		;7f82h @ fed4h
	push	bc		;5257h @ fed2h
	push	de		;1236h @ fed0h
	push	hl		;ca05h @ feceh
	dec	c
	dec	e
	dec	e
	dec	l
	dec	l
	dec	l
	push	af		;7f02h @ fecch
	push	bc		;5256h @ fecah
	push	de		;1234h @ fec8h
	push	hl		;ca02h @ fec6h
	push	ix		;78bch @ fec4h
	push	iy		;bca0h @ fec2h
	inc	(hl)		;  1fh @ ca02h read
				;  20h @ ca02h write
	push	af		;7f10h @ fec0h
	inc	hl
	dec	(hl)		;  00h @ ca03h
				;  ffh @ ca03h
	push	af		;7f92h @ febeh
	inc	(ix+0fh)	;  2eh @ 78cbh read
				;  2fh @ 78cbh write
	dec	(ix+10h)	;  c0h @ 78cch read
				;  bfh @ 78cch write
	inc	(iy-02h)	;  f0h @ bc9eh read
				;  f1h @ bc9eh write
	dec	(iy-01h)	;  80h @ bc9fh read
				;  7fh @ bc9fh write
	push	af		;7f16h @ febch
	push	bc		;5256h @ febah
	push	de		;1234h @ feb8h
	push	hl		;ca03h @ feb6h
	push	ix		;78bch @ feb4h
	push	iy		;bca0h @ feb2h
	xor	a
	adc	hl, bc
	push	af		;0001h @ feb0h
	push	bc		;5256h @ feaeh
	push	de		;1234h @ feach
	push	hl		;1c59h @ feaah
	scf
	adc	hl, bc
	push	af		;0000h @ fea8h
	push	bc		;5256h @ fea6h
	push	de		;1234h @ fea4h
	push	hl		;6eb0h @ fea2h
	and	a
	adc	hl, de
	push	af		;0094h @ fea0h
	push	bc		;5256h @ fe9eh
	push	de		;1234h @ fe9ch
	push	hl		;80e4h @ fe9ah
	scf
	adc	hl, de
	push	af		;0080h @ fe98h
	push	bc		;5256h @ fe96h
	push	de		;1234h @ fe94h
	push	hl		;9319h @ fe92h
	and	a
	adc	hl, hl
	push	af		;0005h @ fe90h
	push	bc		;5256h @ fe8eh
	push	de		;1234h @ fe8ch
	push	hl		;2632h @ fe8ah
	scf
	adc	hl, hl
	push	af		;0000h @ fe88h
	push	bc		;5256h @ fe86h
	push	de		;1234h @ fe84h
	push	hl		;4c65h @ fe82h
	and	a
	adc	hl, sp
	push	af		;0011h @ fe80h
	push	bc		;5256h @ fe7eh
	push	de		;1234h @ fe7ch
	push	hl		;4ae7h @ fe7ah
	scf
	adc	hl, sp
	push	af		;0011h @ fe78h
	push	bc		;5256h @ fe76h
	push	de		;1234h @ fe74h
	push	hl		;4962h @ fe72h
	and	a
	sbc	hl, bc
	push	af		;0083h @ fe70h
	push	bc		;5256h @ fe6eh
	push	de		;1234h @ fe6ch
	push	hl		;f70ch @ fe6ah
	scf
	sbc	hl, bc
	push	af		;0082h @ fe68h
	push	bc		;5256h @ fe66h
	push	de		;1234h @ fe64h
	push	hl		;a4b5h @ fe62h
	and	a
	sbc	hl, de
	push	af		;0082h @ fe60h
	push	bc		;5256h @ fe5eh
	push	de		;1234h @ fe5ch
	push	hl		;9281h @ fe5ah
	scf
	sbc	hl, de
	push	af		;0082h @ fe58h
	push	bc		;5256h @ fe56h
	push	de		;1234h @ fe54h
	push	hl		;804ch @ fe52h
	and	a
	sbc	hl, sp
	push	af		;0093h @ fe50h
	push	bc		;5256h @ fe4eh
	push	de		;1234h @ fe4ch
	push	hl		;81fah @ fe4ah
	scf
	sbc	hl, sp
	push	af		;0093h @ fe48h
	push	bc		;5256h @ fe46h
	push	de		;1234h @ fe44h
	push	hl		;83afh @ fe42h
	and	a
	sbc	hl, hl
	push	af		;0042h @ fe40h
	push	bc		;5256h @ fe3eh
	push	de		;1234h @ fe3ch
	push	hl		;0000h @ fe3ah
	scf
	sbc	hl, hl
	push	af		;0093h @ fe38h
	push	bc		;5256h @ fe36h
	push	de		;1234h @ fe34h
	push	hl		;ffffh @ fe32h
	ld	sp, 0fe00h
	ld	ix, 01000h
	ld	iy, 02000h
	xor	a
	scf
	ld	a, 0aah
	ld	b, 0c0h
	ld	c, 030h
	ld	d, 0ch
	ld	e, 03h
	ld	h, 055h
	ld	l, 08ah
	and	b
	push	af		;8090h @ fdfeh
	ld	a, 0aah
	and	c
	push	af		;2010h @ fdfch
	ld	a, 0aah
	and	d
	push	af		;0810h @ fdfah
	ld	a, 0aah
	and	e
	push	af		;0210h @ fdf8h
	ld	a, 0aah
	and	h
	push	af		;0054h @ fdf6h
	ld	a, 0aah
	and	l
	push	af		;8a90h @ fdf4h
	and	5fh
	push	af		;0a14h @ fdf2h
	ld	hl, 03000h
	ld	a, 0aah
	and	(hl)		;  3ch @ 3000h
	push	af		;2814h @ fdf0h
	and	(ix+0h)		;  c7h @ 1000h
	push	af		;0054h @ fdeeh
	ld	a, 0aah
	and	(iy+0h)		;  82h @ 2000h
	push	af		;8294h @ fdech
	scf
	ld	a, 0aah
	ld	b, 060h
	ld	c, 030h
	ld	d, 0aeh
	ld	e, 07h
	ld	h, 0aah
	ld	l, 08ah
	xor	b
	push	af		;ca84h @ fdeah
	ld	a, 0aah
	xor	c
	push	af		;9a84h @ fde8h
	ld	a, 0aah
	xor	d
	push	af		;0400h @ fde6h
	ld	a, 0aah
	xor	e
	push	af		;ad80h @ fde4h
	ld	a, 0aah
	xor	h
	push	af		;0044h @ fde2h
	ld	a, 0aah
	xor	l
	push	af		;2000h @ fde0h
	xor	0ffh
	push	af		;df80h @ fddeh
	ld	hl, 03001h
	ld	a, 0aah
	xor	(hl)		;  55h @ 3001h
	push	af		;ff84h @ fddch
	xor	(ix+1h)		;  a2h @ 1001h
	push	af		;5d00h @ fddah
	ld	a, 0aah
	xor	(iy+1h)		;  abh @ 2001h
	push	af		;0100h @ fdd8h
	scf
	ld	a, 0aah
	ld	b, 060h
	ld	c, 030h
	ld	d, 0aeh
	ld	e, 07h
	ld	h, 055h
	ld	l, 0h
	or	b
	push	af		;ea80h @ fdd6h
	ld	a, 0aah
	or	c
	push	af		;ba80h @ fdd4h
	ld	a, 0aah
	or	d
	push	af		;ae80h @ fdd2h
	ld	a, 0aah
	or	e
	push	af		;af84h @ fdd0h
	ld	a, 0aah
	or	h
	push	af		;ff84h @ fdceh
	ld	a, 0h
	or	l
	push	af		;0044h @ fdcch
	or	055h
	push	af		;5504h @ fdcah
	ld	hl, 03002h
	ld	a, 08eh
	or	(hl)		;  55h @ 3002h
	push	af		;df80h @ fdc8h
	ld	a, 0fh
	or	(ix+2h)		;  80h @ 1002h
	push	af		;8f80h @ fdc6h
	ld	a, 20h
	or	(iy+2h)		;  78h @ 2002h
	push	af		;7804h @ fdc4h
	scf
	ld	a, 0aah
	ld	b, 060h
	ld	c, 030h
	ld	d, 0aeh
	ld	e, 07h
	ld	h, 055h
	ld	l, 0f6h
	add	a, b
	push	af		;0a01h @ fdc2h
	ld	a, 0aah
	add	a, c
	push	af		;da80h @ fdc0h
	ld	a, 0aah
	add	a, d
	push	af		;5815h @ fdbeh
	ld	a, 0aah
	add	a, e
	push	af		;b190h @ fdbch
	ld	a, 0aah
	add	a, h
	push	af		;ff80h @ fdbah
	ld	a, 0aah
	add	a, l
	push	af		;a091h @ fdb8h
	add	a, 055h
	push	af		;f580h @ fdb6h
	ld	hl, 03003h
	ld	a, 0aah
	add	a, (hl)		;  ffh @ 3003h
	push	af		;a991h @ fdb4h
	ld	a, 0fh
	add	a, (ix+3h)	;  01h @ 1003h
	push	af		;1010h @ fdb2h
	ld	a, 20h
	add	a, (iy+3h)	;  78h @ 2003h
	push	af		;9884h @ fdb0h
	scf
	ld	a, 0aah
	ld	b, 060h
	ld	c, 030h
	ld	d, 0aeh
	ld	e, 07h
	ld	h, 055h
	ld	l, 0f6h
	sub	b
	push	af		;4a06h @ fdaeh
	ld	a, 0aah
	sub	c
	push	af		;7a06h @ fdach
	ld	a, 0aah
	sub	d
	push	af		;fc93h @ fdaah
	ld	a, 0aah
	sub	e
	push	af		;a382h @ fda8h
	ld	a, 0aah
	sub	h
	push	af		;5506h @ fda6h
	ld	a, 0aah
	sub	l
	push	af		;b483h @ fda4h
	sub	055h
	push	af		;5f16h @ fda2h
	ld	hl, 03004h
	ld	a, 0aah
	sub	(hl)		;  aah @ 3004h
	push	af		;0042h @ fda0h
	ld	a, 0fh
	sub	(ix+4h)		;  01h @ 1004h
	push	af		;0e02h @ fd9eh
	ld	a, 20h
	sub	(iy+4h)		;  60h @ 2004h
	push	af		;c083h @ fd9ch
	scf
	ld	a, 0aah
	ld	b, 060h
	ld	c, 030h
	ld	d, 0aeh
	ld	e, 07h
	ld	h, 055h
	ld	l, 0f6h
	cp	b
	push	af		;aa06h @ fd9ah
	cp	c
	push	af		;aa06h @ fd98h
	cp	d
	push	af		;aa93h @ fd96h
	cp	e
	push	af		;aa82h @ fd94h
	cp	h
	push	af		;aa06h @ fd92h
	cp	l
	push	af		;aa83h @ fd90h
	ld	a, 0b4h
	cp	055h
	push	af		;b416h @ fd8eh
	ld	hl, 03005h
	ld	a, 0aah
	cp	(hl)		;  aah @ 3005h
	push	af		;aa42h @ fd8ch
	ld	a, 0fh
	cp	(ix+5h)		;  01h @ 1005h
	push	af		;0f02h @ fd8ah
	ld	a, 20h
	cp	(iy+5h)		;  60h @ 2005h
	push	af		;2083h @ fd88h
	scf
	ld	a, 0aah
	ld	b, 060h
	ld	c, 030h
	ld	d, 0aeh
	ld	e, 07h
	ld	h, 055h
	ld	l, 0f6h
	adc	a, b
	push	af		;0b01h @ fd86h
	ld	a, 0aah
	adc	a, c
	push	af		;db80h @ fd84h
	ld	a, 0aah
	adc	a, d
	push	af		;5815h @ fd82h
	ld	a, 0aah
	adc	a, e
	push	af		;b290h @ fd80h
	ld	a, 0aah
	adc	a, h
	push	af		;ff80h @ fd7eh
	ld	a, 0aah
	adc	a, l
	push	af		;a091h @ fd7ch
	adc	a, 055h
	push	af		;f680h @ fd7ah
	ld	hl, 03006h
	ld	a, 0aah
	adc	a, (hl)		;  ffh @ 3006h
	push	af		;a991h @ fd78h
	ld	a, 0fh
	adc	a, (ix+6h)	;  01h @ 1006h
	push	af		;1110h @ fd76h
	ld	a, 20h
	adc	a, (iy+6h)	;  78h @ 2006h
	push	af		;9884h @ fd74h
	scf
	ld	a, 0aah
	ld	b, 060h
	ld	c, 030h
	ld	d, 0aeh
	ld	e, 07h
	ld	h, 055h
	ld	l, 0f6h
	sbc	a, b
	push	af		;4906h @ fd72h
	ld	a, 0aah
	sbc	a, c
	push	af		;7a06h @ fd70h
	ld	a, 0aah
	sbc	a, d
	push	af		;fc93h @ fd6eh
	ld	a, 0aah
	sbc	a, e
	push	af		;a282h @ fd6ch
	ld	a, 0aah
	sbc	a, h
	push	af		;5506h @ fd6ah
	ld	a, 0aah
	sbc	a, l
	push	af		;b483h @ fd68h
	sbc	a, 055h
	push	af		;5e16h @ fd66h
	ld	hl, 03007h
	ld	a, 0aah
	sbc	a, (hl)		;  aah @ 3007h
	push	af		;0042h @ fd64h
	ld	a, 0fh
	sbc	a, (ix+7h)	;  01h @ 1007h
	push	af		;0e02h @ fd62h
	ld	a, 20h
	sbc	a, (iy+7h)	;  60h @ 2007h
	push	af		;c083h @ fd60h
	scf
	xor	a
	push	af		;0044h @ fd5eh
	ld	a, 38h
	and	a
	push	af		;3810h @ fd5ch
	cp	a
	push	af		;3842h @ fd5ah
	add	a, a
	push	af		;7010h @ fd58h
	adc	a, a
	push	af		;e084h @ fd56h
	or	a
	push	af		;e080h @ fd54h
	scf
	adc	a, a
	push	af		;c181h @ fd52h
       ccf
	sbc	a, a
	push	af		;0042h @ fd50h
	scf
	sbc	a, a
	push	af		;ff93h @ fd4eh
	sub	a
	push	af		;0042h @ fd4ch
	ld	sp, 0fd00h
	xor	a
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	ld	a, 35h
	rlc	a
	push	af		;6a04h @ fcfeh
	rlc	a
	push	af		;d484h @ fcfch
	rlc	a
	push	af		;a985h @ fcfah
	rlc	a
	push	af		;5305h @ fcf8h
	rlc	a
	push	af		;a684h @ fcf6h
	rrc	a
	push	af		;5304h @ fcf4h
	rrc	a
	push	af		;a985h @ fcf2h
	rrc	a
	push	af		;d485h @ fcf0h
	rrc	a
	push	af		;6a04h @ fceeh
	rrc	a
	push	af		;3504h @ fcech
	rl	a
	push	af		;6a04h @ fceah
	rl	a
	push	af		;d484h @ fce8h
	rl	a
	push	af		;a881h @ fce6h
	rl	a
	push	af		;5101h @ fce4h
	rl	a
	push	af		;a384h @ fce2h
	rr	a
	push	af		;5101h @ fce0h
	rr	a
	push	af		;a881h @ fcdeh
	rr	a
	push	af		;d484h @ fcdch
	rr	a
	push	af		;6a04h @ fcdah
	rr	a
	push	af		;3504h @ fcd8h
	sla	a
	push	af		;6a04h @ fcd6h
	sla	a
	push	af		;d484h @ fcd4h
	sla	a
	push	af		;a881h @ fcd2h
	sla	a
	push	af		;5005h @ fcd0h
	sla	a
	push	af		;a084h @ fcceh
	ld	a, 35h
	sra	a
	push	af		;1a01h @ fccch
	sra	a
	push	af		;0d00h @ fccah
	sra	a
	push	af		;0605h @ fcc8h
	ld	a, 86h
	sra	a
	push	af		;c384h @ fcc6h
	sra	a
	push	af		;e185h @ fcc4h
	ld	a, 35h
	srl	a
	push	af		;1a01h @ fcc2h
	srl	a
	push	af		;0d00h @ fcc0h
	srl	a
	push	af		;0605h @ fcbeh
	ld	a, 86h
	srl	a
	push	af		;4300h @ fcbch
	srl	a
	push	af		;2105h @ fcbah
	push	bc		;0000h @ fcb8h
	push	de		;0000h @ fcb6h
	push	hl		;0000h @ fcb4h
	xor	a
	ld	bc, 05867h
	ld	de, 09acbh
	ld	hl, 021f0h
	rlc	b
	push	bc		;b067h @ fcb2h
	rlc	c
	push	bc		;b0ceh @ fcb0h
	rlc	d
	push	de		;35cbh @ fcaeh
	rlc	e
	push	de		;3597h @ fcach
	rlc	h
	push	hl		;42f0h @ fcaah
	rlc	l
	push	hl		;42e1h @ fca8h
	push	af		;0085h @ fca6h
	ld	bc, 05867h
	ld	de, 09acbh
	ld	hl, 021f0h
	rrc	b
	push	bc		;2c67h @ fca4h
	rrc	c
	push	bc		;2cb3h @ fca2h
	rrc	d
	push	de		;4dcbh @ fca0h
	rrc	e
	push	de		;4de5h @ fc9eh
	rrc	h
	push	hl		;90f0h @ fc9ch
	rrc	l
	push	hl		;9078h @ fc9ah
	push	af		;0004h @ fc98h
	ld	bc, 05867h
	ld	de, 09acbh
	ld	hl, 021f0h
	rl	b
	push	bc		;b067h @ fc96h
	rl	c
	push	bc		;b0ceh @ fc94h
	rl	d
	push	de		;34cbh @ fc92h
	rl	e
	push	de		;3497h @ fc90h
	rl	h
	push	hl		;43f0h @ fc8eh
	rl	l
	push	hl		;43e0h @ fc8ch
	push	af		;0081h @ fc8ah
	ld	bc, 05867h
	ld	de, 09acbh
	ld	hl, 021f0h
	rr	b
	push	bc		;ac67h @ fc88h
	rr	c
	push	bc		;ac33h @ fc86h
	rr	d
	push	de		;cdcbh @ fc84h
	rr	e
	push	de		;cd65h @ fc82h
	rr	h
	push	hl		;90f0h @ fc80h
	rr	l
	push	hl		;90f8h @ fc7eh
	push	af		;0080h @ fc7ch
	ld	bc, 05867h
	ld	de, 09acbh
	ld	hl, 021f0h
	sla	b
	push	bc		;b067h @ fc7ah
	sla	c
	push	bc		;b0ceh @ fc78h
	sla	d
	push	de		;34cbh @ fc76h
	sla	e
	push	de		;3496h @ fc74h
	sla	h
	push	hl		;42f0h @ fc72h
	sla	l
	push	hl		;42e0h @ fc70h
	push	af		;0081h @ fc6eh
	ld	bc, 05867h
	ld	de, 09acbh
	ld	hl, 021f0h
	sra	b
	push	bc		;2c67h @ fc6ch
	sra	c
	push	bc		;2c33h @ fc6ah
	sra	d
	push	de		;cdcbh @ fc68h
	sra	e
	push	de		;cde5h @ fc66h
	sra	h
	push	hl		;10f0h @ fc64h
	sra	l
	push	hl		;10f8h @ fc62h
	push	af		;0080h @ fc60h
	ld	bc, 05867h
	ld	de, 09acbh
	ld	hl, 021f0h
	srl	b
	push	bc		;2c67h @ fc5eh
	srl	c
	push	bc		;2c33h @ fc5ch
	srl	d
	push	de		;4dcbh @ fc5ah
	srl	e
	push	de		;4d65h @ fc58h
	srl	h
	push	hl		;10f0h @ fc56h
	srl	l
	push	hl		;1078h @ fc54h
	push	af		;0004h @ fc52h
	ld	hl, 3008h
	rlc	(hl)		;  c5h @ 3008h read
				;  8bh @ 3008h write
	push	af		;0085h @ fc50h
	inc	hl
	rrc	(hl)		;  c5h @ 3009h read
				;  e2h @ 3009h write
	push	af		;0085h @ fc4eh
	inc	hl
	rl	(hl)		;  c5h @ 300ah read
				;  8bh @ 300ah write
	push	af		;0085h @ fc4ch
	inc	hl
	rr	(hl)		;  c4h @ 300bh read
				;  e2h @ 300bh write
	push	af		;0084h @ fc4ah
	inc	hl
	sla	(hl)		;  c5h @ 300ch read
				;  8ah @ 300ch write
	push	af		;0081h @ fc48h
	ccf
	inc	hl
	sra	(hl)		;  c5h @ 300dh read
				;  e2h @ 300dh write
	push	af		;0085h @ fc46h
	inc	hl
	srl	(hl)		;  c5h @ 300eh read
				;  62h @ 300eh write
	push	af		;0001h @ fc44h
	rlc	(ix+8h)		;  67h @ 1008h read
				;  ceh @ 1008h write
	push	af		;0080h @ fc42h
	rrc	(ix+9h)		;  67h @ 1009h read
				;  b3h @ 1009 write
	push	af		;0081h @ fc40h
	rl	(ix+0ah)	;  67h @ 100ah read
				;  cfh @ 100ah write
	push	af		;0084h @ fc3eh
	rr	(ix+0bh)	;  67h @ 100bh read
				;  33h @ 100bh write
	push	af		;0005h @ fc3ch
	sla	(ix+0ch)	;  67h @ 100ch read
				;  ceh @ 100ch write
	push	af		;0080h @ fc3ah
	sra	(ix+0dh)	;  67h @ 100dh read
				;  33h @ 100dh write
	push	af		;0005h @ fc38h
	srl	(ix+0eh)	;  67h @ 100eh read
				;  33h @ 100eh write
	push	af		;0005h @ fc36h
	rlc	(iy+8h)		;  f0h @ 2008h read
				;  e1h @ 2008h write
	push	af		;0085h @ fc34h
	rrc	(iy+9h)		;  f0h @ 2009h read
				;  78h @ 2009 write
	push	af		;0004h @ fc32h
	rl	(iy+0ah)	;  f0h @ 200ah read
				;  e0h @ 200ah write
	push	af		;0081h @ fc30h
	rr	(iy+0bh)	;  f0h @ 200bh read
				;  f8h @ 200bh write
	push	af		;0080h @ fc2eh
	sla	(iy+0ch)	;  f0h @ 200ch read
				;  e0h @ 200ch write
	push	af		;0081h @ fc2ch
	sra	(iy+0dh)	;  f0h @ 200dh read
				;  f8h @ 200dh write
	push	af		;0080h @ fc2ah
	srl	(iy+0eh)	;  f0h @ 200eh read
				;  78h @ 200eh write
	push	af		;0004h @ fc28h
	xor	a
	ld	b, a
	ld	c, a
	ld	d, a
	ld	e, a
	ld	h, a
	ld	l, a
	ld	a, 35h
	rlca
	push	af		;6a44h @ fc26h
	rlca
	push	af		;d444h @ fc24h
	rlca
	push	af		;a945h @ fc22h
	rlca
	push	af		;5345h @ fc20h
	rlca
	push	af		;a644h @ fc1eh
	rrca
	push	af		;5344h @ fc1ch
	rrca
	push	af		;a945h @ fc1ah
	rrca
	push	af		;d445h @ fc18h
	rrca
	push	af		;6a44h @ fc16h
	rrca
	push	af		;3544h @ fc14h
	rla
	push	af		;6a44h @ fc12h
	rla
	push	af		;d444h @ fc10h
	rla
	push	af		;a845h @ fc0eh
	rla
	push	af		;5145h @ fc0ch
	rla
	push	af		;a344h @ fc0ah
	rra
	push	af		;5145h @ fc08h
	rra
	push	af		;a845h @ fc06h
	rra
	push	af		;d444h @ fc04h
	rra
	push	af		;6a44h @ fc02h
	rra
	push	af		;3544h @ fc00h
	ld	bc, 05867h
	ld	de, 09acbh
	ld	hl, 021f0h
	ld	sp, 0fd48h
	cp	a
	ld	a, 35h
	sll	a
	push	af		;6b00h @ fd46h
	sll	a
	push	af		;d784h @ fd44h
	sll	a
	push	af		;af85h @ fd42h
	add	a,a		;set H flag
	ld	a,0afh
	sll	a
	push	af		;5f05h @ fd40h
	sll	a
	push	af		;bf80h @ fd3eh
	push	bc		;5867h @ fd3ch
	push	de		;9acbh @ fd3ah
	push	hl		;21f0h @ fd38h
	sll	b
	push	bc		;b167h @ fd36h
	sll	c
	push	bc		;b1cfh @ fd34h
	sll	d
	push	de		;35cbh @ fd32h
	sll	e
	push	de		;3597h @ fd30h
	sll	h
	push	hl		;43f0h @ fd2eh
	sll	l
	push	hl		;43e1h @ fd2ch
	push	af		;bf85h @ fd2ah
	cp	a
	ld	hl, 03011h
	sll	(hl)		;  c5h @ 3011h read
				;  8bh @ 3011h write
	push	af		;bf85h @ fd28h
	cp	a
	sll	(ix+0fh)	;  66h @ 100fh read
				;  cdh @ 100fh write
	push	af		;bf80h @ fd26h
	cp	a
	sll	(iy+0fh)	;  f0h @ 200fh read
				;  e1h @ 200fh write
	push	af		;bf85h @ fd24h
	ld	sp, 0fa00h
	pop	af		;9900h @ fa00h
	ld	sp, 0fb00h
	daa
	push	af		;9984h @ fafeh
	ld	sp, 0fa02h
	pop	af		;8a00h @ fa02h
	ld	sp, 0fafeh
	daa
	push	af		;9094h @ fafch
	ld	sp, 0fa04h
	pop	af		;7210h @ fa04h
	ld	sp, 0fafch
	daa
	push	af		;7804h @ fafah
	ld	sp, 0fa06h
	pop	af		;a600h @ fa06h
	ld	sp, 0fafah
	daa
	push	af		;0605h @ faf8h
	ld	sp, 0fa08h
	pop	af		;9b00h @ fa08h
	ld	sp, 0faf8h
	daa
	push	af		;0111h @ faf6h
	ld	sp, 0fa0ah
	pop	af		;b110h @ fa0ah
	ld	sp, 0faf6h
	daa
	push	af		;1705h @ faf4h
	ld	sp, 0fa0ch
	pop	af		;2401h @ fa0ch
	ld	sp, 0faf4h
	daa
	push	af		;8485h @ faf2h
	ld	sp, 0fa0eh
	pop	af		;1f01h @ fa0eh
	ld	sp, 0faf2h
	daa
	push	af		;8591h @ faf0h
	ld	sp, 0fa10h
	pop	af		;0111h @ fa10h
	ld	sp, 0faf0h
	daa
	push	af		;6701h @ faeeh
	ld	sp, 0fa12h
	pop	af		;7702h @ fa12h
	ld	sp, 0faeeh
	daa
	push	af		;7706h @ faech
	ld	sp, 0fa14h
	pop	af		;8812h @ fa14h
	ld	sp, 0faech
	daa
	push	af		;8296h @ faeah
	ld	sp, 0fa16h
	pop	af		;7303h @ fa16h
	ld	sp, 0faeah
	daa
	push	af		;1303h @ fae8h
	ld	sp, 0fa18h
	pop	af		;6613h @ fa18h
	ld	sp, 0fae8h
	daa
	push	af		;0057h @ fae6h

	xor	a
	ld	sp, 0facch
	ld	hl, 0300fh
	ld	a, 67h
	rld			;  2fh @ 300fh read
				;  f7h @ 300fh write
	push	af		;6200h @ facah
	inc	hl
	rrd			;  e3h @ 3010h read
				;  2eh @ 3010h write
	push	af		;6304h @ fac8h
;--------
	ld	hl,0aaaah
	ld	bc,0bcbch
	ld	de,0dedeh
	ld	sp,0fc00h
	ld	ix, 06030h
	ld	iy, 0ae07h
	ld	a, 0aah
	adc	a,xh
	push	af		;0a01h @ fbfeh
	ld	a, 0aah
	adc	a,xl
	push	af		;db80h @ fbfch
	ld	a, 0aah
	adc	a,yh
	push	af		;5815h @ fbfah
	ld	a, 0aah
	adc	a,yl
	push	af		;b290h @ fbf8h
	ld	a, 0aah
	add	a,xh
	push	af		;0a01h @ fbf6h
	ld	a, 0aah
	add	a,xl
	push	af		;da80h @ fbf4h
	ld	a, 0aah
	add	a,yh
	push	af		;5815h @ fbf2h
	ld	a, 0aah
	add	a,yl
	push	af		;b190h @ fbf0h
	ld	a,0aah
	and	xh
	push	af		;2010h @ fbeeh
	ld	a,0aah
	and	xl
	push	af		;2010h @ fbech
	ld	a,0aah
	and	yh
	push	af		;aa94h @ fbeah
	ld	a,0aah
	and	yl
	push	af		;0210h @ fbe8h
	ld	a,0aah
	ld	ix,0101h
	ld	iy,0101h
	scf
	dec	xh
	push	af		;aa43h @ fbe6h
	ccf
	dec	xh
	push	af		;aa92h @ fbe4h
	dec	xl
	push	af		;aa42h @ fbe2h
	scf
	dec	xl
	push	af		;aa93h @ fbe0h
	dec	yh
	push	af		;aa43h @ fbdeh
	dec	yh
	ccf
	push	af		;aa90h @ fbdch
	dec	yl
	push	af		;aa42h @ fbdah
	dec	yl
	push	af		;aa92h @ fbd8h
	push	ix		;ffffh @ fbd6h
	push	iy		;ffffh @ fbd4h
	inc	xh
	push	af		;aa50h @ fbd2h
	inc	xl
	push	af		;aa50h @ fbd0h
	scf
	inc	yh
	push	af		;aa51h @ fbceh
	inc	yl
	push	af		;aa51h @ fbcch
	inc	xh
	push	af		;aa01h @ fbcah
	ccf
	inc	xl
	push	af		;aa00h @ fbc8h
	scf
	inc	yh
	push	af		;aa01h @ fbc6h
	ccf
	inc	yl
	push	af		;aa00h @ fbc4h
	push	ix		;0101h @ fbc2h
	push	iy		;0101h @ fbc0h
	ld	ix, 06030h
	ld	iy, 0ae07h
	ld	a,0aah
	or	xh
	push	af		;ea80h @ fbbeh
	ld	a, 0aah
	scf
	or	xl
	push	af		;ba80h @ fbbch
	scf
	ld	a, 0aah
	or	yh
	push	af		;ae80h @ fbbah
	ld	a, 0aah
	or	yl
	push	af		;af84h @ fbb8h
	ld	a, 0aah
	xor	xh
	push	af		;ca84h @ fbb6h
	ld	a, 0aah
	xor	xl
	push	af		;9a84h @ fbb4h
	ld	a, 0aah
	xor	yh
	push	af		;0400h @ fbb2h
	ld	a, 0aah
	xor	yl
	push	af		;ad80h @ fbb0h
	ld	a, 060h
	cp	xh
	push	af		;6042h @ fbaeh
	cp	xl
	push	af		;6002h @ fbach
	cp	yh
	push	af		;6097h @ fbaah
	cp	yl
	push	af		;6012h @ fba8h
	ld	a, 0aah
	sbc	a,xh
	push	af		;4a06h @ fba6h
	ld	a, 0aah
	sbc	a,xl
	push	af		;7a06h @ fba4h
	ld	a, 0aah
	sbc	a,yh
	push	af		;fc93h @ fba2h
	ld	a, 0aah
	sbc	a,yl
	push	af		;a282h @ fba0h
	ld	a, 0aah
	sub	xh
	push	af		;4a06h @ fb9eh
	ld	a, 0aah
	sub	xl
	push	af		;7a06h @ fb9ch
	ld	a, 0aah
	sub	yh
	push	af		;fc93h @ fb9ah
	ld	a, 0aah
	sub	yl
	push	af		;a382h @ fb98h
	push	bc		;bcbch @ fb96h
	push	de		;dedeh @ fb94h
	push	hl		;aaaah @ fb92h
	push	ix		;6030h @ fb90h
;--------
;	ld	sp,0fb80h
;	ld	ix,04000h
;	ld	iy,04100h
;	xor	a
;	set	0,(ix+0),a	;a0h @ 4000h read
;				;a1h @ 4000h write
;	push	af		;a140h @ fb7eh
;	and	a
;	scf
;	set	1,(iy+0),b	;e0h @ 4100h read
;				;e2h @ 4100h write
;	set	2,(ix+1),c	;b0h @ 4001h read
;				;b4h @ 4001h write
;	set	3,(iy+1),d	;f0h @ 4101h read
;				;f8h @ 4101h write
;	set	4,(ix+2),e	;0ch @ 4002h read
;				;1ch @ 4002h write
;	set	5,(iy+2),h	;03h @ 4102h read
;				;23h @ 4102h write
;	set	6,(ix+3),l	;0dh @ 4003h read
;				;4dh @ 4003h write
;	set	7,(iy+3),a	;05h @ 4103h read
;				;85h @ 4103h write
;	push	af		;8501h @ fb7ch
;	push	bc		;e2b4h @ fb7ah
;	push	de		;f81ch @ fb78h
;	push	hl		;234dh @ fb76h
;--------
	ld	hl, 0100h
	jp	0c0h

	org	1000h
	db	0c7h, 0a2h, 080h, 001h, 001h, 001h, 001h, 001h
	db	067h, 067h, 067h, 067h, 067h, 067h, 067h, 066h

	org	2000h
	db	082h, 0abh, 078h, 078h, 060h, 060h, 078h, 060h
	db	0f0h, 0f0h, 0f0h, 0f0h, 0f0h, 0f0h, 0f0h, 0f0h

	org	3000h
	db	03ch, 055h, 055h, 0ffh, 0aah, 0aah, 0ffh, 0aah
	db	0c5h, 0c5h, 0c5h, 0c4h, 0c5h, 0c5h, 0c5h, 02fh
	db	0e3h, 0c5h
	
;	org	4000h
;	db	0a0h, 0b0h, 00ch, 00dh

;	org	4100h
;	db	0e0h, 0f0h, 003h, 005h

	org	078cbh
	db	02eh, 0c0h

	org	0bc9eh
	db	0f0h,	080h

	org	0ca02h
	db	01fh, 00h

	org	0fa00h
	dw	09900h, 08a00h, 07210h, 0a600h
	dw	09b00h, 0b110h, 02401h, 01f01h
	dw	00111h, 07702h, 08812h, 07303h
	dw	06613h
	end
