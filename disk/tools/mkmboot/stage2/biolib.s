;
; biolib.s -- basic I/O library
;

	.set	cin,0xC0000018
	.set	cout,0xC0000020
	.set	dskio,0xC0000028

	.export	getc
	.export	putc
	.export	rwscts

	.code
	.align	4

getc:
	add	$8,$0,cin
	jr	$8

putc:
	add	$8,$0,cout
	jr	$8

rwscts:
	add	$8,$0,dskio
	jr	$8
