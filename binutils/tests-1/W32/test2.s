	.nosyn

	.export	C_extern
	.export	D_extern
	.export	B_extern

	.code

	add	$3,$2,$1
	add	$3,$2,$1
	add	$3,$2,$1
C_extern:
	add	$3,$2,$1
	add	$3,$2,$1
	add	$3,$2,$1

	.data

	.word	0x55AA55AA
	.word	0x55AA55AA
	.word	0x55AA55AA
D_extern:
	.word	0x55AA55AA
	.word	0x55AA55AA
	.word	0x55AA55AA

	.bss
	.space	0x100
B_extern:
	.space	0x100
