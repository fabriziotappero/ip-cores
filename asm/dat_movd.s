;**********************************************************************************
;*                                                                                *
;* dat_mov compare data                                                           *
;*                                                                                *
;**********************************************************************************
	org	0102h
	db	0f0h

	org	0408h
	db	00fh

	org	01020h
	db	00fh, 001h, 002h, 004h, 008h, 010h, 026h, 03ch

	org	6780h
	db	0ffh, 00fh, 00dh, 00bh, 009h, 007h, 005h, 003h
	db	001h

	org	07895h
	db	0d2h                          	;7895h
	dw	0e1f0h                        	;7896h
	dw	00f1eh, 02d3ch, 04b5ah, 06978h	;7898h
	dw	0fe00h                        	;78a0h

	org	0aa50h
	dw	0ffffh, 0aa56h, 00f00h, 0ffffh	;aa50h

	org	0abc0h
	db	0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 00fh, 00dh, 00bh
	db	009h, 007h, 005h, 003h, 001h

	org	0bb40h
	dw	0bb44h, 00f00h, 0ffffh, 0ffffh	;bb40h

	org	0cc30h
	dw	0cc34h, 00f00h, 0ffffh, 0ffffh	;cc30h

	org	0fbb8h
	dw	02222h, 0fe7eh, 07efeh, 005adh	;fbb8h
	dw	0fe7eh, 0fe7eh, 0ad05h, 005adh	;fbc0h
	dw	07efeh, 0fe7eh, 005adh, 005adh	;fbc8h
	dw	07e44h, 0fe7eh, 0fe7eh, 0ad05h	;fbd0h
	dw	0ad05h, 07efeh, 0fe7eh, 005adh	;fbd8h
	dw	0ad05h, 07e44h, 0fe7eh, 0ad05h	;fbe0h
	dw	03d44h, 0be44h, 05744h, 0a544h	;fbe8h
	dw	02222h, 05555h, 0aaaah, 00044h	;fbf0h
	dw	0be3dh, 0beffh, 0a557h, 0a500h	;fbf8h

	org	0fcc8h
	dw	0ffffh, 0ffffh, 0ffffh, 05500h	;fcc8h
	dw	05504h, 05500h, 00044h, 00000h	;fcd0h
	dw	00000h, 00000h, 05544h, 00000h	;fcd8h
	dw	00000h, 00000h, 0ff80h, 00044h	;fce0h
	dw	00000h, 00000h, 00000h, 0ff44h	;fce8h
	dw	00b0dh, 00709h, 00305h, 00100h	;fcf0h
	dw	0f5f3h, 0f9f7h, 0fdfbh, 0ff00h	;fcf8h
	dw	0cc34h, 0bb44h, 0aa56h, 0ffffh	;fd00h

	org	0fdf0h
	dw	0ffffh, 0ffffh, 0aa55h, 0bb44h	;fdf0h
	dw	0cc33h, 0dd22h, 0ee11h, 00f00h	;fdf8h

	org	0ff58h
	dw	0ffffh, 0d244h, 0c344h, 0b444h	;ff58h
	dw	020a5h, 09624h, 02024h, 07887h	;ff60h
	dw	05a69h, 02044h, 02020h, 02020h	;ff68h
	dw	02020h, 02044h, 02010h, 02010h	;ff70h
	dw	02010h, 01044h, 02008h, 00810h	;ff78h
	dw	01020h, 00844h, 00810h, 02004h	;ff80h
	dw	00810h, 00444h, 00204h, 01020h	;ff88h
	dw	00408h, 00244h, 02001h, 00810h	;ff90h
	dw	00204h, 00184h, 01020h, 00408h	;ff98h
	dw	00102h, 0ff84h, 0efdfh, 0fbf7h	;ffa0h
	dw	0fefdh, 0ff84h, 0fbf7h, 0efdfh	;ffa8h
	dw	0fefdh, 0ff84h, 01020h, 00408h	;ffb0h
	dw	00102h, 0ff84h, 00408h, 01020h	;ffb8h
	dw	00102h, 0ff84h, 0fbf7h, 0efdfh	;ffc0h
	dw	0fefdh, 0ff84h, 0efdfh, 0fbf7h	;ffc8h
	dw	0fefdh, 0ff84h, 00408h, 01020h	;ffd0h
	dw	00102h, 0ff84h, 01020h, 00408h	;ffd8h
	dw	00102h, 0ff84h, 0efdfh, 0fbf7h	;ffe0h
	dw	0fefdh, 0ff84h, 01020h, 00408h	;ffe8h
	dw	00102h, 00f44h, 05555h, 0aaaah	;fff0h
	dw	01020h, 00408h, 00102h, 00044h	;fff8h

	end
