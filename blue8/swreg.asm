	ORG 0
	ldi 0
top:		
	sta 0xFF0
	inca
	hlt
	jmp top
	end
	