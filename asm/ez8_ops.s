;**********************************************************************************
;*                                                                                *
;* checks ez80 specific instructions                                              *
;*                                                                                *
;**********************************************************************************
	aseg

	org	00h
	jp	01000h

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

	org	0d0h
	db	071h, 018h, 006h, 005h, 002h, 003h, 004h, 0aah

	org	0e0h
	dw	0abcdh, 0fe10h, 03254h, 07698h

	org	00140h
	db	061h

	org	00241h
	db	002h

	org	00342h
	db	033h

	org	00443h
	db	0f4h

	org	00544h
	db	0e5h

	org	00645h
	db	0a6h

	org	00165h
	db	061h

	org	00264h
	db	002h

	org	00363h
	db	033h

	org	00462h
	db	0f4h

	org	00561h
	db	0e5h

	org	00660h
	db	0a6h

	org	01000h
	di
	xor	a
	ld	sp, 00000h
	ld	bc, 00123h
	ld	de, 04567h
	ld	hl, 0d000h
	ld	ix, 089abh
	ld	iy, 0cdefh

	ld	(hl),bc		;0123h @ d000h
	inc	hl
	inc	hl
	ld	(hl),de		;4567h @ d002h
	inc	hl
	inc	hl
	ld	(hl),hl		;d004h @ d004h
	inc	hl
	inc	hl
	ld	(hl),ix		;89abh @ d006h
	inc	hl
	inc	hl
	ld	(hl),iy		;cdefh @ d008h

	pea	ix+055h		;8a00h @ fffeh
	pea	iy-055h		;cd9ah @ fffch
	push	ix		;89abh @ fffah
	push	iy		;cdefh @ fff8h

	ld	ix, 0e080h
	ld	iy, 0dff0h
	ld	(ix-040h),bc	;0123h @ e040h
	ld	(ix-03eh),de	;4567h @ e042h
	ld	(ix-03ch),hl	;d008h @ e044h
	ld	(ix-03ah),ix	;e080h @ e046h
	ld	(ix-038h),iy	;dff0h @ e048h
	ld	(iy+050h),bc	;0123h @ e040h
	ld	(iy+052h),de	;4567h @ e042h
	ld	(iy+054h),hl	;d008h @ e044h
	ld	(iy+056h),ix	;e080h @ e046h
	ld	(iy+058h),iy	;dff0h @ e048h

	ld	ix,02004h
	ld	bc,(ix-04h)
	ld	de,(ix-02h)
	ld	hl,(ix+00h)
	ld	iy,(ix+02h)
	ld	ix,(ix+04h)
	push	bc		;dbach @ fff6h
	push	de		;5183h @ fff4h
	push	hl		;e800h @ fff2h
	push	iy		;7e4dh @ fff0h
	push	ix		;9a1fh @ ffeeh

	ld	bc,(hl)
	inc	hl
	inc	hl
	ld	de,(hl)
	inc	hl
	inc	hl
	ld	ix,(hl)
	inc	hl
	inc	hl
	ld	iy,(hl)
	inc	hl
	inc	hl
	ld	hl,(hl)
	push	bc		;0123h @ ffech
	push	de		;4567h @ ffeah
	push	hl		;cdefh @ ffe8h
	push	ix		;89abh @ ffe6h
	push	iy		;2006h @ ffe4h

	ld	bc,(iy-06h)
	ld	de,(iy-04h)
	ld	hl,(iy-02h)
	ld	ix,(iy+00h)
	ld	iy,(iy+02h)	
	push	bc		;dbach @ ffe2h
	push	de		;5183h @ ffe0h
	push	hl		;e800h @ ffdeh
	push	ix		;7e4dh @ ffdch
	push	iy		;9a1fh @ ffdah

	lea	bc,ix-2
	lea	de,ix-1
	lea	hl,ix+0
	lea	iy,ix+1
	lea	ix,ix+2
	push	bc		;7e4bh @ ffd8h
	push	de		;7e4ch @ ffd6h
	push	hl		;7e4dh @ ffd4h
	push	ix		;7e4fh @ ffd2h
	push	iy		;7e4eh @ ffd0h

	ld	iy, 0aa00h

	lea	bc,iy-2
	lea	de,iy-1
	lea	hl,iy+0
	lea	ix,iy+1
	lea	iy,iy+2
	push	bc		;a9feh @ ffceh
	push	de		;a9ffh @ ffcah
	push	hl		;aa00h @ ffcch
	push	ix		;aa01h @ ffc8h
	push	iy		;aa02h @ ffc6h
	push	af		;0044h @ ffc4h

;---------

	ld	sp,0ff00h
	xor	a
	ld	hl, 0d700h
	ld	de, 00304h
	ld	bc, 006d0h
	jp	011feh
	org	011feh
	inim			;read  71h @ 00d0h
				;write 71h @ d700h 
	push	af		;0006h @ fefeh
	push	bc		;05d1h @ fefch
	push	hl		;d701h @ fefah
	jp	012feh
	org	012feh
	inimr			;read  18h @ 00d1h
				;write 18h @ d701h
				;read  06h @ 00d2h
				;write 06h @ d702h
				;read  05h @ 00d3h
				;write 05h @ d703h
				;read  02h @ 00d4h
				;write 02h @ d704h
				;read  03h @ 00d5h
				;write 03h @ d705h
	push	af		;0046h @ fef8h
	push	bc		;00d6h @ fef6h
	push	hl		;d706h @ fef4h
	ld	b,1
	jp	013ffh
	org	013ffh
	inimr			;read  04h @ 00d6h
				;write 04h @ d706h
	push	af		;0046h @ fef2h
	push	bc		;00d7h @ fef0h
	push	hl		;d707h @ feeeh
	inc	b
	jp	014ffh
	org	014ffh
	inim			;read  aah @ 00d7h
				;write aah @ d707h
	push	af		;0042h @ feech
	push	bc		;00d8h @ feeah
	push	hl		;d708h @ fee8h
	ld	hl, 0d707h
	ld	bc, 006d7h
	jp	015feh
	org	015feh
	indm			;read  aah @ 0037h
				;write aah @ d707h
	push	af		;0002h @ fee6h
	push	bc		;05d6h @ fee4h
	push	hl		;d706h @ fee2h
	jp	016feh
	org	016feh
	indmr			;read  04h @ 00d6h
				;write 04h @ d706h
				;read  03h @ 00d5h
				;write 03h @ d705h
				;read  02h @ 00d4h
				;write 02h @ d704h
				;read  05h @ 00d3h
				;write 05h @ d703h
				;read  06h @ 00d2h
				;write 06h @ d702h
	push	af		;0042h @ fee0h
	push	bc		;00d1h @ fedeh
	push	hl		;d701h @ fedch
	inc	b
	xor	0aah
	jp	017ffh
	org	017ffh
	indmr			;read  18h @ 00d1h
				;write 18h @ d701h
	push	af		;aac6h @ fedah
	push	bc		;00d0h @ fed8h
	push	hl		;d700h @ fed6h
	inc	b
	jp	018ffh
	org	018ffh
	indm			;read  71h @ 00d0h
				;write 71h @ d700h
	push	af		;aa42h @ fed4h
	push	bc		;00cfh @ fed2h
	push	de		;0304h @ fed0h
	push	hl		;d6ffh @ feceh

;---------
	ld	sp, 0fe00h
	xor	a
	ld	hl, 0d901h
	ld	bc, 00241h
	jp	019feh
	org	019feh
	ind2			;read  60h @ 0041h
				;write 60h @ d901h
	push	af		;0006h @ fdfeh
	push	bc		;01d0h @ fdfch
	push	hl		;d900h @ fdfah
	ld	a, 055h
	jp	01affh
	org	01affh
	ind2			;read  02h @ 0040h
				;write 02h @ d900h
	push	af		;5546h @ fdf8h
	push	bc		;00cfh @ fdf6h
	push	hl		;d8ffh @ fdf4h

	xor	a
	ld	hl,0d804h
	ld	bc,00264h
	jp	01bfeh
	org	01bfeh
	ini2			;read  02h @ 0064h
				;write 02h @ d804h
	push	af		;0006h @ fdf2h
	push	bc		;0165h @ fdf0h
	push	hl		;d805h @ fdeeh
	xor	0aah
	jp	01cffh
	org	01cffh
	ini2			;read  61h @ 0065h
				;write 61h @ d805h
	push	af		;aac6h @ fdech
	push	bc		;0066h @ fdeah
	push	hl		;d806h @ fde8h
	push	de		;0304h @ fde6h
	
	ld	bc, 0003h
	ld	hl, 0a001h
	ld	de, 05002h
	jp	01dfeh
	org	01dfeh
	ini2r			;read  01h @ 5002h
				;write 01h @ a001h
				;read  02h @ 5003h
				;write 02h @ a002h
				;read  03h @ 5004h
				;write 03h @ a003h
	push	af		;aac6h @ fde4h
	push	bc		;0000h @ fde2h
	push	hl		;a004h @ fde0h
	push	de		;5005h @ fddeh
	ld	bc, 0004h
	ld	hl, 09ffeh
	ld	de, 04ffdh
	jp	01efeh
	org	01efeh
	ind2r			;read  04h @ 4ffdh
				;write 04h @ 9ffeh
				;read  05h @ 4ffch
				;write 05h @ 9ffdh
				;read  06h @ 4ffbh
				;write 06h @ 9ffch
				;read  07h @ 4ffah
				;write 07h @ 9ffbh
	push	af		;aac6h @ fddch
	push	bc		;0000h @ fddah
	push	hl		;9ffah @ fdd8h
	push	de		;4ff9h @ fdd6h


;---------
	ld	sp, 0fd00h
	xor	a
	ld	hl, 04901h
	ld	bc, 00231h
	outd2			;read  02h @ 4901h
				;write 02h @ 0231h
	push	af		;0006h @ fcfeh
	push	bc		;0130h @ fcfch
	push	hl		;4900h @ fcfah
	ld	a, 055h
	outd2			;read  61h @ 4900h
				;write 61h @ 0130h
	push	af		;5546h @ fcf8h
	push	bc		;002fh @ fcf6h
	push	hl		;48ffh @ fcf4h

	xor	a
	ld	hl,04804h
	ld	bc,00274h
	outi2			;read  02h @ 4804h
				;write 02h @ 0274h
	push	af		;0006h @ fcf2h
	push	bc		;0175h @ fcf0h
	push	hl		;4805h @ fceeh
	xor	0aah
	outi2			;read  61h @ 4805h
				;write 61h @ 0175h
	push	af		;aac6h @ fcech
	push	bc		;0076h @ fceah
	push	hl		;4806h @ fce8h
	push	de		;4ff9h @ fce6h
	
	ld	bc, 0003h
	ld	de, 0a001h
	ld	hl, 05002h
	oti2r			;read  01h @ 5002h
				;write 01h @ a001h
				;read  02h @ 5003h
				;write 02h @ a002h
				;read  03h @ 5004h
				;write 03h @ a003h
	push	af		;aac6h @ fce4h
	push	bc		;0000h @ fce2h
	push	de		;a004h @ fce0h
	push	hl		;5005h @ fcdeh
	ld	bc, 0004h
	ld	de, 09ffeh
	ld	hl, 04ffdh
	otd2r			;read  04h @ 4ffdh
				;write 04h @ 9ffeh
				;read  05h @ 4ffch
				;write 05h @ 9ffdh
				;read  06h @ 4ffbh
				;write 06h @ 9ffch
				;read  07h @ 4ffah
				;write 07h @ 9ffbh
	push	af		;aac6h @ fcdch
	push	bc		;0000h @ fcdah
	push	de		;9ffah @ fcd8h
	push	hl		;4ff9h @ fcd6h

;---------

	ld	sp, 0fc00h
	and	a		;AF = aa94h
	ld	de, 0da15h
	ld	hl, 049feh + 3
	ld	bc, 4
	otdrx			;read  eeh @ 4a01h
				;write eeh @ da15h
				;read  eeh @ 4a00h
				;write eeh @ da15h
				;read  eeh @ 49ffh
				;write eeh @ da15h
				;read  eeh @ 49feh
				;write eeh @ da15h
	push	af		;aad6h @ fbfeh
	push	bc		;0000h @ fbfch
	push	de		;da15h @ fbfah
	push	hl		;49fdh @ fbf8h

	inc	de
	inc	a		;a = abh
	ld	hl, 04afeh
	ld	bc, 4
	otirx			;read  11h @ 4afeh
				;write 11h @ da16h
				;read  11h @ 4affh
				;write 11h @ da16h
				;read  11h @ 4b00h
				;write 11h @ da16h
				;read  11h @ 4b01h
				;write 11h @ da16h
	push	af		;abc2h @ fbf6h
	push	bc		;0000h @ fbf4h
	push	de		;da16h @ fbf2h
	push	hl		;4b02h @ fbf0h

	and	a
	ld	hl, 09dfeh + 3
	ld	de, 0e732h
	ld	bc, 4
	indrx			;read  77h @ e732h
				;write 77h @ 9e01h
				;read  77h @ e732h
				;write 77h @ 9e00h
				;read  77h @ e732h
				;write 77h @ 9dffh
				;read  77h @ e732h
				;write 77h @ 9dfeh
	push	af		;abd2h @ fbeeh
	push	bc		;0000h @ fbech
	push	de		;e732h @ fbeah
	push	hl		;9dfdh @ fbe8h

	inc	de
	dec	a		;A = aah
	ld	hl, 09efeh
	ld	bc, 4
	inirx			;read  cch @ e733h
				;write cch @ 9efeh
				;read  cch @ e733h
				;write cch @ 9effh
				;read  cch @ e733h
				;write cch @ 9f00h
				;read  cch @ e733h
				;write cch @ 9f01h
	push	af		;aac2h @ fbe6h
	push	bc		;0000h @ fbe4h
	push	de		;e733h @ fbe2h
	push	hl		;9f02h @ fbe0h

	ld	hl,0100h
	jp	0c0h

	org	02000h
	dw	0dbach, 05183h, 0e800h, 07e4dh, 09a1fh

	org	04800h
	db	0a6h, 0a5h, 0f4h, 022h, 002h, 061h	;for ini2

	org	04900h
	db	061h, 002h, 022h, 0f4h, 0a5h, 0a6h	;for ind2
	
	org	049feh
	db	0eeh, 0eeh, 0eeh, 0eeh
	
	org	04afeh
	db	011h, 011h, 011h, 011h

	org	04fe8h
	db	0ffh, 0ffh, 0a8h, 027h, 026h, 01ch, 01bh, 01ah
	db	019h, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 043h, 00ah
	db	009h, 008h, 007h, 006h, 005h, 004h, 0ffh, 0aah
	db	055h, 0ffh, 001h, 002h, 003h, 00bh, 00ch, 00dh
	db	00eh, 00fh, 0ffh, 0ffh, 0ffh, 0ffh, 01dh, 01eh
	db	01fh, 020h, 0a1h, 022h, 023h, 022h, 025h, 0ffh

	org	0e732h
	db	077h, 0cch

	org	0e800h
	dw	00123h, 04567h, 089abh, 02006h, 0cdefh

	end
