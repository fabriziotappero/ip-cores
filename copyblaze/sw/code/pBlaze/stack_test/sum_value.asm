; this programm calculate the sum of the "value" 16bit.
; value = 5; total = 5 + 3 + 2 + 1 = 15
; the result is 16bit outputed 
		waveform_port		.EQU	0x02
		counter_port		.EQU	0x04
	
		total_low	.EQU   s0
		total_high	.EQU   s1
		value		.EQU   s8
		;
start:
		LOAD	value,		0x1F	; find sum of all values to 1F
		LOAD	total_low,	0x00	; clear 16-bit total
		LOAD	total_high,	0x00
		
		CALL	sum_to_value		; calculate sum of all numbers up to value
		
		OUTPUT	total_high,	counter_port	; Result will be 496 (1F0 hex)
		OUTPUT	total_low,	waveform_port 

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
