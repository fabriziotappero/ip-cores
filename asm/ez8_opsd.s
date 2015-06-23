;**********************************************************************************
;*                                                                                *
;* ez8_ops compare data                                                           *
;*                                                                                *
;**********************************************************************************
	org	00130h
	db	061h

	org	00231h
	db	002h

	org	00332h
	db	033h

	org	00433h
	db	0f4h

	org	00534h
	db	0e5h

	org	00635h
	db	0a6h

	org	00175h
	db	061h

	org	00274h
	db	002h

	org	00373h
	db	033h

	org	00472h
	db	0f4h

	org	00571h
	db	0e5h

	org	00670h
	db	0a6h

	org	09dfeh
	db	077h, 077h, 077h, 077h	;09f00h
	
	org	09efeh
	db	0cch, 0cch, 0cch, 0cch	;09f04h

	org	09ff8h
	db	0ffh, 0ffh, 0ffh, 007h, 006h, 005h, 004h, 0aah	;09ff8h
	db	055h, 001h, 002h, 003h, 0ffh, 0ffh, 0ffh, 0ffh	;0a000h


	org	0d000h
	dw	00123h, 04567h, 0d004h, 089abh, 0cdefh

	org	0d700h
	db	071h, 018h, 006h, 005h, 002h, 003h, 004h, 0aah	;for inim/indm/inimr/indmr

	org	0d800h
	db	0a6h, 0a5h, 0f4h, 022h, 002h, 061h	;for ini2

	org	0d900h
	db	061h, 002h, 022h, 0f4h, 0a5h, 0a6h	;for ind2
	
	org	0da15h
	db	0eeh, 011h

	org	0e040h
	dw	00123h, 04567h, 0d008h, 0e080h, 0dff0h

	org	0fbe0h
	dw	09f02h, 0e733h, 00000h, 0aac2h	;fbe0h
	dw	09dfdh, 0e732h, 00000h, 0abd2h	;fbe8h
	dw	04b02h, 0da16h, 00000h, 0abc2h	;fbf0h
	dw	049fdh, 0da15h, 00000h, 0aad6h	;fbf8h

	org	0fcd6h
	dw	04ff9h
	dw	09ffah, 00000h, 0aac6h, 05005h	;fcd8h
	dw	0a004h, 00000h, 0aac6h, 04ff9h	;fce0h
	dw	04806h, 00076h, 0aac6h, 04805h	;fce8h
	dw	00175h, 00006h, 048ffh, 0002fh	;fcf0h
	dw	05546h, 04900h, 00130h, 00006h	;fcf8h

	org	0fdd6h
	dw	04ff9h
	dw	09ffah, 00000h, 0aac6h, 05005h	;fdd8h
	dw	0a004h, 00000h, 0aac6h, 00304h	;fde0h
	dw	0d806h, 00066h, 0aac6h, 0d805h	;fde8h
	dw	00165h, 00006h, 0d8ffh, 0003fh	;fdf0h
	dw	05546h, 0d900h, 00140h, 00006h	;fdf8h

	org	0feceh
	dw	0d6ffh
	dw	00304h, 000cfh, 0aa42h, 0d700h	;fed0h
	dw	000d0h, 0aac6h, 0d701h, 000d1h	;fed8h
	dw	00042h, 0d706h, 005d6h, 00002h	;fee0h
	dw	0d708h, 000d8h, 00042h, 0d707h	;fee8h
	dw	000d7h, 00046h, 0d706h, 000d6h	;fef0h
	dw	00046h, 0d701h, 005d1h, 00006h	;fef8h

	org	0ffc4h
	dw	00044h, 0aa02h
	dw	0aa01h, 0aa00h, 0a9ffh, 0a9feh	;ffc8h
	dw	07e4eh, 07e4fh, 07e4dh, 07e4ch	;ffd0h
	dw	07e4bh, 09a1fh, 07e4dh, 0e800h	;ffd8h
	dw	05183h, 0dbach, 02006h, 089abh	;ffe0h
	dw	0cdefh, 04567h, 00123h, 09a1fh	;ffe8h
	dw	07e4dh, 0e800h, 05183h, 0dbach	;fff0h
	dw	0cdefh, 089abh, 0cd9ah, 08a00h	;fff8h
	
	end
