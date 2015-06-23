	ORG 0
	lds 0x0FF
	lda 0x20
	push
	lda 0x33
	call test
	nop
	nop
	nop
test:	
	nop
	nop
	pop
	nop
t1:	jmp t1	
	hlt
	END
	