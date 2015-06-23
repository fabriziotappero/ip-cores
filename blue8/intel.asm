#define BLUEMON 1
#include "blue.inc"
			
     ORG 0x100
	call print_msgcr
	ds "Use Escape to exit\xff"
toploop:
	call crlf
	lda #'?'   
	call printchar
	lda #' '
	call printchar
	call waitcharecho
	cmp escape
	snz
	jmp bluemon
	push
	call crlf
	pop
	push
	call printchar
	lda #'='
	call printchar
	pop
	call hexout2
	jmp toploop
	
	END
	