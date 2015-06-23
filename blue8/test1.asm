	;; This is a test program so it won't always
	;; be efficient
	;; 
	;; The expressions can be perl expressions

	ORG 0

value:	equ 10	
start:	ldi
	dw value
	sta thevar  		;  not really used
loop:	inca
	sz
	jmp loop
	qtog		
	jmp start
	
thevar:	DW 0

	END
				