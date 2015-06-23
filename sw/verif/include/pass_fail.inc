
FAIL	MACRO
	mov	a, #0AAH
	mov	a, #055H
	mov	a, #000H
	ENDM

PASS	MACRO
	mov	a, #0AAH
	mov	a, #055H
	mov	a, #001H
	ENDM
