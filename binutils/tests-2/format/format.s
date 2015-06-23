
	.export	label

	.code

; formatN
	trap

; formatRH
	mvfs	$23,1

; formatRHH
	ldhi	$23,0x12345678
	ldhi	$23,label+4

; formatRRX
	and	$23,$24,$25
	and	$23,$24,0x00005678
	and	$23,$24,0x12340000
	and	$23,$24,0x12345678
	and	$23,$24,label+4

; formatRRY
	add	$23,$24,$25
	add	$23,$24,0x00005678
	add	$23,$24,0x12340000
	add	$23,$24,0x12345678
	add	$23,$24,label+4

	.bss
	.space	0x1234
label:	.word	0
