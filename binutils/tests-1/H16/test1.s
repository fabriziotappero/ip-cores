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
	ldhi	$3,C_local+10
	ldhi	$3,C_global+20
	ldhi	$3,C_extern+30
	ldhi	$3,D_local+40
	ldhi	$3,D_global+50
	ldhi	$3,D_extern+60
	ldhi	$3,B_local+70
	ldhi	$3,B_global+80
	ldhi	$3,B_extern+90
	add	$3,$2,$1
	add	$3,$2,$1
C_local:
	add	$3,$2,$1
C_global:
	add	$3,$2,$1

	.data

	.word	0x55AA55AA
	.word	0x55AA55AA
	ldhi	$3,C_local+10
	ldhi	$3,C_global+20
	ldhi	$3,C_extern+30
	ldhi	$3,D_local+40
	ldhi	$3,D_global+50
	ldhi	$3,D_extern+60
	ldhi	$3,B_local+70
	ldhi	$3,B_global+80
	ldhi	$3,B_extern+90
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
