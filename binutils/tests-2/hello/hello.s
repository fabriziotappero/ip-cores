;
; hello.s -- Hello, world!
;

; $11  I/O base address
; $12  temporary value
; $13  character
; $14  pointer to string
; $29 stack pointer
; $31 return address

	.set	tba,0xF0300000

reset:	add	$29,$0,0xC0010000
	jal	start
reset1:	j	reset1

start:	sub	$29,$29,4	; save return register
	stw	$31,$29,0
	add	$11,$0,tba	; set I/O base address
	add	$14,$0,hello	; pointer to string
	or	$14,$14,hello
loop:	ldbu	$13,$14,0	; get char
	beq	$13,$0,stop	; null - finished
	jal	out		; output char
	add	$14,$14,1	; bump pointer
	j	loop		; next char
stop:	ldw	$31,$29,0	; restore return register
	add	$29,$29,4
	jr	$31		; return

out:	ldw	$12,$11,8	; get status
	and	$12,$12,1	; xmtr ready?
	beq	$12,$0,out	; no - wait
	stw	$13,$11,12	; send char
	jr	$31		; return

hello:	.byte	"Hello, world!"
	.byte	0x0D, 0x0A, 0
