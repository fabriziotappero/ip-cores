;**********************************************************************************
;*                                                                                *
;* io_ops compare data                                                            *
;*                                                                                *
;**********************************************************************************
	org	000h
	db	025h

	org	0f8h
	db	0ffh, 0a8h, 027h, 026h, 025h, 024h, 023h, 022h	;00f8h

	org	01e3h
	db	01ch, 0a1h

	org	02e3h
	db	01bh, 020h

	org	03e3h
	db	01ah, 01fh

	org	04e3h
	db	019h, 01eh

	org	05e4h
	db	01dh

	org	04ff0h
	db	0ffh, 088h, 017h, 016h, 015h, 014h, 0ffh, 0ffh	;4ff0h

	org	05008h
	db	0ffh, 0ffh, 010h, 011h, 012h, 013h, 0ffh, 0ffh	;5008h

	org	05a3ch
	db	05ah

	org	09ff8h
	db	0ffh, 0ffh, 0ffh, 007h, 006h, 005h, 004h, 0aah	;09ff8h
	db	055h, 001h, 002h, 003h, 0ffh, 0ffh, 0ffh, 0ffh	;0a000h

	org	0c610h
	db	0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0c6h, 016h, 0a0h	;c610h
	db	0eah, 066h, 000h, 043h, 08fh, 0ffh, 0ffh, 0ffh	;c618h

	org	0fee8h
	dw	0ffffh, 0ffffh, 0ffffh, 0ffffh	;fee8h
	dw	0ffffh, 0ffffh, 0ffffh, 0ffffh	;fef0h
	dw	0ffffh, 0ffffh, 0ffffh, 0ffffh	;fef8h
	dw	0ffffh, 0ffffh, 0ffffh, 0ffffh	;ff00h
	dw	0ffffh, 0ffffh, 0ffffh, 05013h	;ff08h
	dw	09ffah, 000e4h, 04352h, 0500fh	;ff10h
	dw	09ffah, 004e4h, 04310h, 04fech	;ff18h
	dw	09ffah, 000e3h, 04350h, 04fefh	;ff20h
	dw	09ffah, 003e3h, 04310h, 04ff0h	;ff28h
	dw	09ffah, 000e2h, 04352h, 04ff4h	;ff30h
	dw	09ffah, 004e2h, 04310h, 0500eh	;ff38h
	dw	09ffah, 000e1h, 04350h, 0500bh	;ff40h
	dw	09ffah, 0ffe0h, 04310h, 0500ah	;ff48h
	dw	09ffah, 00000h, 04312h, 05006h	;ff50h
	dw	09ffah, 07fffh, 04316h, 04ff5h	;ff58h
	dw	09ffah, 00004h, 04346h, 04ff8h	;ff60h
	dw	09ffah, 0ffffh, 04316h, 04ff9h	;ff68h
	dw	09ffah, 00000h, 04380h, 05005h	;ff70h
	dw	0a004h, 00000h, 04380h, 05000h	;ff78h
	dw	0a000h, 07ffeh, 04384h, 04fffh	;ff80h
	dw	09fffh, 07fffh, 04384h, 0ffffh	;ff88h
	dw	0ffffh, 0ffffh, 0ffffh, 0ffffh	;ff90h
	dw	0ffffh, 0ffffh, 0ffffh, 0ffffh	;ff98h
	dw	0ffffh, 0ffffh, 0ffffh, 06600h	;ffa0h
	dw	0a0eah, 0c614h, 04300h, 06600h	;ffa8h
	dw	0a0eah, 0c613h, 0ff44h, 066aah	;ffb0h
	dw	0a0eah, 0c612h, 0ff04h, 0a0eah	;ffb8h
	dw	0c611h, 0ff80h, 0a021h, 0c610h	;ffc0h
	dw	0ff84h, 0c610h, 0ff00h, 0c623h	;ffc8h
	dw	0ff84h, 0ffffh, 0ffffh, 0ffffh	;ffd0h
	dw	0ffffh, 0ffffh, 0ffffh, 0ffffh	;ffd8h
	dw	0ffffh, 0ffffh, 0ffffh, 0ffffh	;ffe0h
	dw	0ffffh, 0ffffh, 0ffffh, 0ffffh	;ffe8h
	dw	0ffffh, 0ffffh, 0ffffh, 0ffffh	;fff0h
	dw	0ffffh, 0ffffh, 0ffffh, 05a44h	;fff8h

