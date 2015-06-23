;**********************************************************************************
;*                                                                                *
;* bit_ops compare data                                                           *
;*                                                                                *
;**********************************************************************************
	org	07000h
	db	001h, 002h, 004h, 008h, 010h, 020h, 040h, 080h

	org	07100h
	db	0feh, 0fdh, 0fbh, 0f7h, 0efh, 0dfh, 0bfh, 07fh

	org	71f8h
	db	001h, 080h, 040h, 020h, 010h, 008h, 004h, 002h
	db	001h, 000h, 000h, 000h, 000h, 000h, 000h, 000h

	org	073fah
	db	07fh, 0bfh, 0dfh, 0efh, 0f7h, 0fbh, 0fdh, 0feh

	org	7ff8h
	db	000h, 000h, 000h, 000h, 000h, 000h, 080h, 040h
	db	020h, 010h, 008h, 004h, 002h, 001h, 000h, 000h

	org	08480h
	db	0feh, 0fdh, 0fbh, 0f7h, 0efh, 0dfh, 0bfh, 07fh

	org	0bf60h
	dw	00054h, 00014h, 00054h, 00014h	;bf60h
	dw	00014h, 00054h, 00014h, 00054h	;bf68h
	dw	00054h, 00054h, 00014h, 00014h	;bf70h
	dw	00014h, 00014h, 00054h, 00054h	;bf78h
	dw	00054h, 00054h, 00054h, 00054h	;bf80h
	dw	00014h, 00014h, 00054h, 00014h	;bf88h
	dw	00014h, 00054h, 00014h, 00054h	;bf90h
	dw	00014h, 00054h, 00014h, 00054h	;bf98h
	dw	00014h, 00014h, 00054h, 00054h	;bfa0h
	dw	00014h, 00014h, 00054h, 00054h	;bfa8h
	dw	00014h, 00014h, 00014h, 00014h	;bfb0h
	dw	00054h, 00054h, 00054h, 00054h	;bfb8h
	dw	00054h, 00014h, 00054h, 00014h	;bfc0h
	dw	00054h, 00014h, 00054h, 00014h	;bfc8h
	dw	00054h, 00054h, 00014h, 00014h	;bfd0h
	dw	00054h, 00054h, 00014h, 00014h	;bfd8h
	dw	00054h, 00054h, 00054h, 00054h	;bfe0h
	dw	00014h, 00014h, 00014h, 00014h	;bfe8h
	dw	00110h, 0fd50h, 00410h, 0f750h	;bff0h
	dw	01010h, 0df50h, 040bdh, 07ffdh	;bff8h

	org	0fef8h
	dw	08487h, 0ffffh, 0ffffh, 0ff84h	;fef8h
	dw	08406h, 0ffffh, 0ffffh, 0ff84h	;ff00h
	dw	00485h, 0ffffh, 0ffffh, 0ff84h	;ff08h
	dw	08484h, 0ff7fh, 0ffffh, 0ff84h	;ff10h
	dw	08483h, 07fffh, 0ffffh, 0ff84h	;ff18h
	dw	08482h, 0ffffh, 0ff7fh, 0ff84h	;ff20h
	dw	08481h, 0ffffh, 07fffh, 0ff84h	;ff28h
	dw	08480h, 0ffffh, 0ffffh, 07f84h	;ff30h
	dw	0bffeh, 0efdfh, 0fbf7h, 0fd84h	;ff38h
	dw	0fefdh, 0dfbfh, 0f7efh, 0fb84h	;ff40h
	dw	0fdfbh, 0bffeh, 0efdfh, 0f784h	;ff48h
	dw	0fbf7h, 0fefdh, 0dfbfh, 0ef84h	;ff50h
	dw	0f7efh, 0fdfbh, 0bffeh, 0df84h	;ff58h
	dw	0efdfh, 0fbf7h, 0fefdh, 0bf84h	;ff60h
	dw	0dfbfh, 0f7efh, 0fdfbh, 0fe84h	;ff68h
	dw	070feh, 07401h, 0ffffh, 0ffffh	;ff70h
	dw	0ffffh, 0ff84h, 07007h, 00000h	;ff78h
	dw	00000h, 00044h, 07086h, 00000h	;ff80h
	dw	00000h, 00044h, 0f005h, 00000h	;ff88h
	dw	00000h, 00044h, 07004h, 00080h	;ff90h
	dw	00000h, 00044h, 07003h, 08000h	;ff98h
	dw	00000h, 00044h, 07002h, 00000h	;ffa0h
	dw	00080h, 00044h, 07001h, 00000h	;ffa8h
	dw	08000h, 00044h, 07000h, 00000h	;ffb0h
	dw	00000h, 08044h, 04001h, 01020h	;ffb8h
	dw	00408h, 00244h, 00102h, 02040h	;ffc0h
	dw	00810h, 00444h, 00204h, 04001h	;ffc8h
	dw	01020h, 00844h, 00408h, 00102h	;ffd0h
	dw	02040h, 01044h, 00810h, 00204h	;ffd8h
	dw	04001h, 02044h, 01020h, 00408h	;ffe0h
	dw	00102h, 04044h, 02040h, 00810h	;ffe8h
	dw	00204h, 00144h, 07201h, 07ffeh	;fff0h
	dw	00000h, 00000h, 00000h, 00044h	;fff8h

