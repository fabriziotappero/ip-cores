;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; factorial
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; compute factorials of 1 to 9 and write results to
;;; the PC via UART
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
.data

;;; the numbers to be written are placed here
iobuf:
	data 0x0A
	data 0x0D
	data 0
	data 0
	data 0
	data 0
	data 0
	data 0

;;; stack for recursive calls of factorial()
stack:	

.text	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; main()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ldib	r15, 1		; number to start
	ldib	r5, 10		; number to stop

	ldil	r1, lo(stack)   ; setup for factorial()
	ldih	r1, hi(stack)
	ldil	r2, lo(factorial)
	ldih	r2, hi(factorial)

	ldib	r6, 0x30        ; setup for convert()
	ldib	r7, 10
	ldil	r8, lo(iobuf)
	ldih	r8, hi(iobuf)
	ldil	r9, lo(convert)
	ldih	r9, hi(convert)

	ldib	r12, -8		; enable write interrupts
	ldib	r11, (1 << 2)
	store	r11, r12

	ldil	r12, lo(isr)    ; register isr() to be called upon
	ldih	r12, hi(isr)    ; interrupt #3
	stvec	r12, 3

	ldib	r12, -6         ; address where to write data
	                        ; to the UART

loop:
	mov	r0, r15         ; r0 is the argument
	call	r2, r3          ; call factorial()
	call	r9, r3          ; call convert()

wait:   getfl   r13
	btest   r13, 4          ; interrupts still enabled?
	brnz	wait

	addi	r15, 1		; loop
	cmp	r15, r5
	brnz	loop

exit:	br	exit		; stop here after all

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; converting content of r4 to a string
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
convert:
	addi	r8, 2
convert_loop:
	umod	r4, r7, r10    ; the conversion
	add	r10, r6, r10
	storel	r10, r8
	addi	r8, 1	

	udiv	r4, r7, r4     ; next digit

	cmpi	r4, 0
	brnz	convert_loop

	sei                    ; trigger write
	jmp	r3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; write out content of iobuf
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
isr:
	cmpi	r8, iobuf	; reached end?
	brz	written

	addi	r8, -1		; write data to UART
	loadb	r10, r8
	store	r10, r12

	reti

written:
	getshfl r10
	bclr	r10, 4		; clear interrupt flag
	setshfl	r10
	reti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; recursively compute factorial
;;; argument:		r0
;;; return value:	r4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
factorial:
	cmpi	r0, 1		; reached end?
	brule	fact_leaf

	store	r0, r1		; push argument and return
	addi	r1,  2		; address onto stack
	store	r3, r1
	addi	r1,  2
	
	addi	r0, -1		; call factorial(r0-1)
	call	r2, r3

	addi	r1, -2		; pop argument and return
	load	r3, r1		; address from stack
	addi	r1, -2
	load	r0, r1

	mul	r0, r4, r4	; return r0*factorial(r0-1)
	jmp	r3
	
fact_leaf:			; factorial(1) = 1
	ldib	r4, 1
	jmp	r3
