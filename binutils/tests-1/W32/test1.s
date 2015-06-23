	.nosyn

	.export	C_global
	.import	C_extern
	.export	D_global
	.import	D_extern
	.export	B_global
	.import	B_extern

	.code

	add	$3,$2,$1
	add	$3,$2,$1
	.word	C_local+10
	.word	C_global+20
	.word	C_extern+30
	.word	D_local+40
	.word	D_global+50
	.word	D_extern+60
	.word	B_local+70
	.word	B_global+80
	.word	B_extern+90
	add	$3,$2,$1
	add	$3,$2,$1
C_local:
	add	$3,$2,$1
C_global:
	add	$3,$2,$1

	.data

	.word	0x55AA55AA
	.word	0x55AA55AA
	.word	C_local+10
	.word	C_global+20
	.word	C_extern+30
	.word	D_local+40
	.word	D_global+50
	.word	D_extern+60
	.word	B_local+70
	.word	B_global+80
	.word	B_extern+90
	.word	0x55AA55AA
	.word	0x55AA55AA
D_local:
	.word	0x55AA55AA
D_global:
	.word	0x55AA55AA

	.bss

	.space	0x100
B_local:
	.space	0x100
B_global:
	.space	0x100
