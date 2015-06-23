	.code
	.import	fptr
	.export	call
	.word	0x11111111
call:	.word	fptr
