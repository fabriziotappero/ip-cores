	.code

	.import	lbl2
	.export	lbl1

	add	$1,$2,$3
	add	$4,$5,$6
lbl1:	j	lbl2
	add	$7,$8,$9
	add	$10,$11,$12
