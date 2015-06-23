crlf:
	lda cr+CODEOFFSET
	call printchar+CODEOFFSET
	lda lf+CODEOFFSET
printchar:
	call xmitwait+CODEOFFSET
	sta uart+1
	ret	

print_msgcr: 
	popx
	call print_msgx+CODEOFFSET
	call crlf+CODEOFFSET
	incx
	pushx
	ret

print_msg:
	popx
	call print_msgx+CODEOFFSET
	incx
	pushx
	ret


print_msgx:
	ldax 0
	spos
	ret
	swap
	call printchar+CODEOFFSET
	ldax 0
	swap
	spos
	ret
	swap
	call printchar+CODEOFFSET
	incx
	jmp print_msgx+CODEOFFSET
	
		
xmitwait:		
	push
 	lda uart
	sneg
	jmp xmitwait+1+CODEOFFSET
	pop
	ret	


waitchar:
	lda uart+1
	sneg
	jmp waitchar+CODEOFFSET
	and ff+CODEOFFSET
	ret
ff:	dw 0xFF
cr:	dw 0x0d
lf:	dw 0x0a
; note this is a bit wasteful since it sends 2xCR+LF
; also, it converts \r to \n 
waitcharecho:
	call waitchar+CODEOFFSET
	call printchar+CODEOFFSET
	cmp cr+CODEOFFSET
	snz
	call crlf+CODEOFFSET
	ret
	








