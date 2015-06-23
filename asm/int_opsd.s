;**********************************************************************************
;*                                                                                *
;* int_ops compare data                                                           *
;*                                                                                *
;**********************************************************************************
	org	03cc4h
	db	0c4h
	db	0c5h
	db	0c6h
	db	0c7h
	db	0c8h
	db	0c9h
	db	0cah
	db	0cbh
	db	0cch
	db	0cdh
	db	0ceh
	db	0cfh
	db	0d0h
	db	0d1h
	db	0d2h
	db	0d3h
	db	0d4h


	org	05a3ch
	db	05ah


	org	0966ah
	db	003h
	db	005h
	db	007h
	db	009h
	db	00bh
	db	00dh
	db	00fh
	db	011h
	db	013h
	db	015h
	db	017h
	db	019h
	db	01bh
	db	01dh
	db	01fh
	db	021h
	db	023h
	db	025h
	db	027h
	db	029h


	org	0ff2eh
	dw	0d747h, 0d633h, 03cceh			;ff2eh
	dw	08421h, 0edb7h, 0ff92h, 0d610h, 09678h	;ff34h
	dw	02e00h, 00100h, 0001fh, 05a44h, 05a44h	;ff3eh
	dw	06900h, 02e00h, 00100h, 0001fh, 0de00h	;ff48h
	dw	06900h, 02d00h, 00100h, 0001eh, 0dd00h	;ff52h
	dw	06900h, 02c00h, 00100h, 0001dh, 0dc01h	;ff5ch
	dw	06900h, 02b00h, 00100h, 0001ch, 0db01h	;ff66h
	dw	06916h, 02a00h, 00100h, 0001bh, 0da00h	;ff70h
	dw	09394h, 02900h, 00100h, 0001ah, 0d900h	;ff7ah
	dw	06a04h, 02800h, 00100h, 00019h, 0d800h	;ff84h
	dw	04204h, 02700h, 00100h, 00018h, 0d700h	;ff8eh

	dw	05500h, 02600h, 00100h, 00017h	;ff98h
	dw	0d512h, 00016h, 0d412h, 00015h	;ffa0h
	dw	0d311h, 05500h, 05500h, 00014h	;ffa8h
	dw	0d300h, 00044h, 00044h, 00013h	;ffb0h
	dw	0d200h, 00012h, 0d104h, 00011h	;ffb8h
	dw	0d001h, 00010h, 0cf01h, 0000fh	;ffc0h
	dw	0ce01h, 0000eh, 0ccffh, 0000dh	;ffc8h
	dw	0cc00h, 0000ch, 0cb00h, 0000bh	;ffd0h
	dw	0c9ffh, 0000ah, 0c8ffh, 00009h	;ffd8h
	dw	0c7feh, 00008h, 0c6feh, 00007h	;ffe0h
	dw	0c601h, 00006h, 0c501h, 00005h	;ffe8h
	dw	05000h, 00004h, 05000h, 00003h	;fff0h
	dw	0c202h, 00002h, 0c102h, 00001h	;fff8h

	end
