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
	j	C_local+10
	j	C_global+20
	j	C_extern+30
	j	D_local+40
	j	D_global+50
	j	D_extern+60
	j	B_local+70
	j	B_global+80
	j	B_extern+90
	add	$3,$2,$1
	add	$3,$2,$1
C_local:
	add	$3,$2,$1
C_global:
	add	$3,$2,$1

	.data

	.word	0x55AA55AA
	.word	0x55AA55AA
	j	C_local+10
	j	C_global+20
	j	C_extern+30
	j	D_local+40
	j	D_global+50
	j	D_extern+60
	j	B_local+70
	j	B_global+80
	j	B_extern+90
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
