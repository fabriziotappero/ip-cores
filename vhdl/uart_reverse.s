.data
	data 0x0A
	data 0x0D
buffer:
		
.text
;;; initialization
	ldib	r0, -8		; config/status
	ldib	r1, -6		; data
	
	ldil	r2,  lo(buffer)	; buffer address
	ldih	r2,  hi(buffer)	; buffer address
	
	ldib	r3,  0x0A	; newline character
	ldib    r4,  0x0D       ; carriage return
	
	ldib	r5,  0		; mode

	ldib	r7,  isr	; register isr
	stvec	r7,  3

	ldib    r7, (1 << 3)	; enable receive interrupts
	store	r7,  r0
	
	sei			; enable interrupts

;;; loop forever
loop:	br loop

	
;;; ISR
isr:
	cmpi	r5, 0		; check mode
	brnz	write_mode

;;; reading
read_mode:
	load	r7, r1		; read data

	cmp	r7, r3		; change mode upon newline
	brnz	read_CR

	ldib	r7, (1 << 2)	; do the change
	store   r7, r0
	ldib	r5, 1
	reti
	
read_CR:
	cmp	r7, r4		; ignore carriage return
	brnz	read_cont
	reti

read_cont:	
	storel  r7, r2		; store date
	addi	r2,  1
	reti

;;; writing
write_mode:
	addi	r2, -1

	cmpi	r2, -1		; change mode if there is no more data
	brnz	write_cont

	ldil	r2,  lo(buffer)	; correct pointer to buffer
	ldih	r2,  hi(buffer)
			
	ldib	r7, (1 << 3)	; do the change
	store   r7, r0
	ldib	r5, 0
	reti

write_cont:
	loadl	r7, r2		; write data
	store	r7, r1
	reti

	
	
