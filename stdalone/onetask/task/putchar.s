;
; putchar.s -- putchar library function
;

	.code
	.export	putchar

putchar:
	trap
	jr	$31
