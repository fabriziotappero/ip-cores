; this programm calculate the sum of the "value" 16bit.
; value = 5; total = 5 + 3 + 2 + 1 = 15
; the result is 16bit outputed 
		waveform_port		.EQU	0x02
		counter_port		.EQU	0x04
	
		total_low	.EQU   s0
		total_high	.EQU   s1
		value		.EQU   s8
		;

		; ==========================================================
start:
		LOAD	value,		0x1F	; find sum of all values to 1F
		LOAD	total_low,	0x00	; clear 16-bit total
		LOAD	total_high,	0x00
		
		CALL	sum_to_value		; calculate sum of all numbers up to value

		OUTPUT	total_low,	counter_port	;	result : Value.LOW
		OUTPUT	total_high,	waveform_port	;	result : Value.HIGH
		; ==========================================================

		; Test Wishbone Instructions		
		LOAD	value,		0x00	; clear the register
		LOAD	value,		0x01	; 
		LOAD	value,		0x02	; 

		WBWRSING	total_high,	0x04	; Result will be 496 (1F0 hex)
		LOAD	value,		0x03	; 
		LOAD	value,		0x04	; 
		LOAD	value,		0x05	; 
		WBWRSING	total_low,	0x04 
		LOAD	value,		0x06	; 
		LOAD	value,		0x07	; 
		LOAD	value,		0x08	; 
		WBRDSING	total_high,	0x01	; Result will be 496 (1F0 hex)
		LOAD	value,		0x0A	; 
		LOAD	value,		0x0B	; 
		LOAD	value,		0x0C	; 

end:		
		JUMP	end
		;
		
		; Subroutine called recursively
sum_to_value:
		ADD		total_low,	value	; perform 16-bit addition
		ADDCY	total_high,	00
		SUB		value,		01		; reduce value by 1
		RETURN	Z					; finished if down to zero
		CALL	sum_to_value		; recursively call of subroutine
		RETURN						; definitively finished!
