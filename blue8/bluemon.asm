/* Monitor V0.4 */
/* Note: because of the monitors relocation
   You can't use the # form of immediate addressing now 
   supported by the assembler */
		 	
#define CODEOFFSET 0xED0
#define FIRSTCODE 0xED1
#include "blue.inc"
	

	ORG 0
start:	jmp reload
	DEFSTACK
	;; Need to eventually copy all code to top of memory
	call print_msgcr+CODEOFFSET
	ds "Blue Monitor 0.4\xFF"
prompt:	call print_msg+CODEOFFSET
	ds "\r\r\nBLUE> \xFF"	
prompt0:	
	call waitcharecho+CODEOFFSET
	JMPIF(lf+CODEOFFSET,prompt0+CODEOFFSET)
	JMPIF(space+CODEOFFSET,prompt0+CODEOFFSET)
	ior makelower+CODEOFFSET
	JMPIF(cmdl+CODEOFFSET,load+CODEOFFSET)
	JMPIF(cmdd+CODEOFFSET,dump+CODEOFFSET)
	JMPIF(cmdg+CODEOFFSET,go+CODEOFFSET)
	JMPIF(cmdi+CODEOFFSET,intel+CODEOFFSET)
	;; unknown command
	call print_msgcr+CODEOFFSET
	ds "?\xFF"
	jmp prompt+CODEOFFSET
	
	;; load command (ESC ends)
load:	call hexin4+CODEOFFSET  		; set X=address
	ldxa
load1:	
	call hexin4+CODEOFFSET		; get next word
	lda numin+CODEOFFSET		; get number
	stax			; put it away
	incx			; next word
	lda hexsep+CODEOFFSET		; if escape goto prompt
	JMPIF(escape+CODEOFFSET,prompt+CODEOFFSET)
	jmp load1+CODEOFFSET		; keep going
	
	;; dump command
dump:	
	call hexin4+CODEOFFSET		; get address
	ldxa
	;;  would like to spin excess 8 words
dump1:	
	stx			; see if are on xx0 or xx8
	and bits3+CODEOFFSET
	sz
	jmp dump2+CODEOFFSET
	;;  do we want out? -- only test at end of lines
	lda uart+1
	spos
	jmp prompt+CODEOFFSET

	;; new line
	call hexaddr+CODEOFFSET
dump2:		
	ldax			; get word
	call hexout4+CODEOFFSET	; print it
	ldi ' '			; space
	call printchar+CODEOFFSET
	incx			; next word
	jmp dump1+CODEOFFSET		; keep going
	
	;; show XXXX:	(address)
hexaddr:	
	call crlf+CODEOFFSET
	stx
	call hexout4+CODEOFFSET
	ldi ':'
	call printchar+CODEOFFSET
	ldi ' '
	jmp printchar+CODEOFFSET

	
	;; go command
	;; escape cancels
go:	call hexin4+CODEOFFSET
	lda hexsep+CODEOFFSET		; see if we cancelled
	cmp escape+CODEOFFSET
	snz
	jmp prompt+CODEOFFSET
	lda numin+CODEOFFSET		; nope. get number and jump
	jmpa

intel:	call waitcharecho+CODEOFFSET
	cmp escape+CODEOFFSET
	snz
	jmp prompt+CODEOFFSET
	cmp colon+CODEOFFSET
	sz
	jmp intel+CODEOFFSET
	ldi 2
	call hexinct+CODEOFFSET
	;; count of bytes
	rar 			; divide by 2
	and hexnib+CODEOFFSET   ;  max of 16
	sta icount+CODEOFFSET
	ldi 4
	call hexinct+CODEOFFSET
	rar			;  divide by 2
	push
	popx
	ldi 2
	call hexinct+CODEOFFSET
	add hexzero+CODEOFFSET
	sz
	jmp inteldone+CODEOFFSET
intelloop:		
	ldi 4
	call hexinct+CODEOFFSET
	stax
	incx
	lda icount+CODEOFFSET
	deca
	sta icount+CODEOFFSET
	sz
	jmp intelloop+CODEOFFSET
	jmp intel+CODEOFFSET 	; ignore checksum crlf
inteldone:
	call waitcharecho+CODEOFFSET
	cmp lf+CODEOFFSET
	sz
	jmp inteldone+CODEOFFSET
	jmp prompt+CODEOFFSET	


	;; commands
cmdl:	dw 'l'
cmdd:	dw 'd'
cmdg:	dw 'g'
cmdi:	dw 'i'
colon:	dw ':'
	;; cancel key
escape:	dw 0x1b
	;; bit to OR to make upper case lower case
makelower:	dw 0x20
	;; constants
zero:	dw '0'
hexzero:	dw 0
nine:	dw '9'
hexa:	dw 'a'
hexmask:	dw 0xFFF0
// The below doesn't work because lf isn't defined in pass1
//ten:	equ lf
#define ten lf	
hexnib:	 dw 0xF
bits3:	dw 0x7

	;; number in winds up here (and in ACC)
numin:	dw 0

hextmp:	dw 0
hextmp2: dw 0
hexsep:	dw 0			; hexin separator
bs:	dw 8
hexct:	dw 4
mask3:	 dw 0xFFF
icount:	dw 0
space:	dw ' '
		
	;; read 4 hex characters, result in acc and numin
	;; also set hexsep to the "ending character" (e.g., space, CR, etc.)
hexin4:	ldi 0xFFFF
hexinct:		
	sta hexct+CODEOFFSET
	ldi 0			; clear acc
	sta numin+CODEOFFSET		; store acc
hexinl:		
	call waitcharecho+CODEOFFSET	; get character
	JMPIF(space+CODEOFFSET,hexinl+CODEOFFSET)
	SKIP
hexinl2:	call waitcharecho+CODEOFFSET ;  character after first
	cmp bs+CODEOFFSET
	snz
	jmp hexbs+CODEOFFSET
	cmp zero+CODEOFFSET    		; if <'0' then done
	snz
	jmp hexin09+CODEOFFSET
	sc
	jmp hexin4done+CODEOFFSET
	cmp nine+CODEOFFSET		; if <='9' then number
	sc
	jmp hexin09+CODEOFFSET		
	snz
	jmp hexin09+CODEOFFSET
	;; TODO:	 need to test that not above 'F'
	;; if here we have a non number (A-F)
	ior makelower+CODEOFFSET   		;  make lower case
	sub hexa+CODEOFFSET
	sc
	jmp hexin4done+CODEOFFSET
	add ten+CODEOFFSET
	SKIP
hexin09:	
	sub zero+CODEOFFSET
	sta hextmp+CODEOFFSET
	lda numin+CODEOFFSET		; shift number over
	ral
	ral
	ral
	ral
	and hexmask+CODEOFFSET
	ior hextmp+CODEOFFSET		; put in our current number
	sta numin+CODEOFFSET		; store acc
	lda hexct+CODEOFFSET
	deca
	sta hexct+CODEOFFSET
	sz
	jmp hexinl2+CODEOFFSET
hexin4done:
	sta hexsep+CODEOFFSET		; remember why we quit
	lda numin+CODEOFFSET		; load the number and return
	ret

hexbs:	lda numin+CODEOFFSET
	rar
	rar
	rar
	rar
	and mask3+CODEOFFSET
	sta numin+CODEOFFSET
	;; assume hextct will equal FFFF if backspaces occur
	jmp hexinl2+CODEOFFSET
	
	;; print out 4 hex digits
hexout4:	sta hextmp+CODEOFFSET
		swap
		call hexout2+CODEOFFSET
		lda hextmp+CODEOFFSET
hexout2:	sta hextmp2+CODEOFFSET
		rar
		rar
		rar
		rar
		call hexout1+CODEOFFSET
		lda hextmp2+CODEOFFSET
hexout1:	and hexnib+CODEOFFSET
		cmp ten+CODEOFFSET
		snc
		jmp hexouta+CODEOFFSET
		add zero+CODEOFFSET
		jmp printchar+CODEOFFSET
hexouta:	sub ten+CODEOFFSET
		add hexa+CODEOFFSET
		jmp printchar+CODEOFFSET 	;  hidden return
		
		


#include "syslib.inc"
reload:	ldx 0
reloadx:		
	ldax 0
	stax CODEOFFSET
	incx
	stx
	sub limit
	sz
	jmp reloadx
	jmp FIRSTCODE
	
limit:	dw reload	

	END
