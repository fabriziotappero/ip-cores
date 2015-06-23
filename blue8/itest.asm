	/* Now C comments work too but don't show in list */


#include "blue.inc"	


;; This tests the indexing
;; by using index to point to the UART in some way
	ORG 0
start0:	DEFSTACK
	call print_msg		 
	ds "BLUE: \r\n"
	dw 0xffff 
	

start:	ldx uart		; contrived: use index register to uart
	LDIM('0',var)
loop:		
	call xmitwait		; wait for transmit ready
	lda var
	stax 1			; write and recycle if necessary	
	cmp nine
	snz
	lda zero
	inca
	sta var
	call waitchar
	lda var
	jmp loop

var:	DW 0
zero:	DW 0x002F
nine:	DW 0x0039	
tmask:	DW 0x7FFF
	ds 'Test single'
	ds "Test double"
	ds '\r\n'
	dw 'A'			; test
	dw 'XY'  		; test

#include "syslib.inc"	

	END

