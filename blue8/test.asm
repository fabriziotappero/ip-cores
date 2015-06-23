	;; This is a test program so it won't always
	;; be efficient
	;; 
	;; The expressions can be perl expressions

	ORG 0
value:	equ 0x10+2
offset:	equ 2
start:	lda thevar
loop:	add sum
	 xor flip
	not
	inca
	deca
	sta thevar  		; this is wasteful, but tests
	jmp start
	
thevar:	DW value
sum:	DW offset*2
flip:	DW 0xFFFF
test:	DW _location_*2
	END
				