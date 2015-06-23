	code
	align	16
my_org:
	     			org	0x100800200
		db	"BOOT"
		jmp	crt_start
		.align 8
sp_save:
		dw	0
		fill.b	0x0200,0xff
L_1:
L_0:
main:
	subui	sp,sp,#24
	sw   	bp,[sp]
	sw   	xlr,8[sp]
	sw   	lr,16[sp]
	lea  	xlr,L_5
	mov  	bp,sp
	subui	sp,sp,#12800040
	subui	sp,sp,#56
	sw   	r11,[sp]
	sw   	r12,8[sp]
	sw   	r13,16[sp]
	sw   	r14,24[sp]
	sw   	r15,32[sp]
	sw   	r16,40[sp]
	sw   	r17,48[sp]
	ori  	r15,r0,#-1
	lea  	r3,-12000016[bp]
	mov  	r16,r3
;		lw		r1,#0x17
;		mov		r2,sp
;		syscall	#410
		lw		r1,#0xAB
		outb	r1,0xdc0600
	
	call 	get_tick
	mov  	r3,r1
	mov  	r17,r3
	     			lw		r1,#0xAC
		outb	r1,0xdc0600
		lw		r1,#0x17
		mov		r2,sp
		syscall	#410
	subui	sp,sp,#8
	fip
	nop
	nop
	nop
	nop
	sw   	r4,[sp]
;	fip
		lw		r1,#0xAE
		outb	r1,0xdc0600
	nop
	nop
	nop
	nop
	nop
	subui	sp,sp,#16
	fip
	nop
	nop
	nop
	nop
	nop
	sw   	r17,8[sp]
	fip
	nop
	nop
	nop
	nop
	nop
	ori  	r3,r0,#L_0
	fip
	nop
	nop
	nop
	nop
	nop
	sw   	r3,[sp]
	nop
	nop
	nop
	nop
	nop
		lw		r1,#0xAE
		outb	r1,0xdc0600
	wait
	call 	printf
	addui	sp,sp,#16
	lw   	r4,[sp]
	addui	sp,sp,#8
	mov  	r3,r1
	     			lw		r1,#0xAD
		outb	r1,0xdc0600
		cli
	
	ori  	r3,r0,#1500000
	mov  	r14,r3
	ori  	r3,r0,#0
	mov  	r11,r3
L_6:
	bge  	r11,r14,L_7
	add  	r3,r11,#2
	sw   	r3,[r16+r11*8]
	addui	r11,r11,#1
	bra  	L_6
L_7:
	ori  	r3,r0,#0
	mov  	r11,r3
L_8:
	bge  	r11,r14,L_9
	lw   	r3,[r16+r11*8]
	beq  	r3,r15,L_10
	lw   	r3,[r16+r11*8]
	shli 	r4,r3,#1
	sub  	r3,r4,#2
	mov  	r12,r3
L_12:
	bge  	r12,r14,L_13
	sw   	r15,[r16+r12*8]
	lw   	r3,[r16+r11*8]
	add  	r12,r12,r3
	bra  	L_12
L_13:
L_10:
	addui	r11,r11,#1
	bra  	L_8
L_9:
	ori  	r3,r0,#0
	mov  	r12,r3
	ori  	r3,r0,#0
	mov  	r11,r3
L_14:
	bge  	r11,r14,L_15
	bge  	r12,#100000,L_15
	lw   	r3,[r16+r11*8]
	beq  	r3,r15,L_16
	lw   	r3,[r16+r11*8]
	add  	r12,r12,#1
	lea  	r4,-12800016[bp]
	sw   	r3,[r4+r12*8]
L_16:
	addui	r11,r11,#1
	bra  	L_14
L_15:
	subui	sp,sp,#16
	sw   	r4,8[sp]
	sw   	r5,[sp]
	call 	get_tick
	lw   	r4,8[sp]
	lw   	r5,[sp]
	addui	sp,sp,#16
	mov  	r3,r1
	mov  	r13,r3
	subui	sp,sp,#16
	sw   	r4,8[sp]
	sw   	r5,[sp]
	subui	sp,sp,#16
	sub  	r3,r13,r17
	sw   	r3,8[sp]
	ori  	r3,r0,#L_0
	sw   	r3,[sp]
	call 	printf
	addui	sp,sp,#16
	lw   	r4,8[sp]
	lw   	r5,[sp]
	addui	sp,sp,#16
	mov  	r3,r1
	ori  	r3,r0,#0
	mov  	r11,r3
L_18:
	bge  	r11,#100000,L_19
	subui	sp,sp,#16
	sw   	r4,8[sp]
	sw   	r5,[sp]
	subui	sp,sp,#16
	lea  	r3,-12800016[bp]
	lw   	r4,[r3+r11*8]
	sw   	r4,8[sp]
	ori  	r4,r0,#L_0
	sw   	r4,[sp]
	call 	printf
	addui	sp,sp,#16
	lw   	r4,8[sp]
	lw   	r5,[sp]
	addui	sp,sp,#16
	mov  	r4,r1
	addui	r11,r11,#1
	bra  	L_18
L_19:
	ori  	r1,r0,#0
L_20:
	lw   	r17,48[sp]
	lw   	r16,40[sp]
	lw   	r15,32[sp]
	lw   	r14,24[sp]
	lw   	r13,16[sp]
	lw   	r12,8[sp]
	lw   	r11,[sp]
	addui	sp,sp,#56
	mov  	sp,bp
	lw   	bp,[sp]
	lw   	xlr,8[sp]
	lw   	lr,16[sp]
	ret  	#24
L_5:
	lw   	lr,8[bp]
	sw   	lr,16[bp]
	bra  	L_20
printf:
	     			lw		r1,#0xB0
		outb	r1,0xdc0600
	subui	sp,sp,#24
	sw   	bp,[sp]
	sw   	xlr,8[sp]
	sw   	lr,16[sp]
	lea  	xlr,L_21
	mov  	bp,sp
	subui	sp,sp,#8
	subui	sp,sp,#24
	sw   	r11,[sp]
	sw   	r12,8[sp]
	sw   	r13,16[sp]
	lw   	r3,24[bp]
	mov  	r12,r3
	ori  	r13,r0,#putch
	     			lw		r1,#0xAE
		outb	r1,0xdc0600
	
	lea  	r3,24[bp]
	mov  	r11,r3
L_22:
	lc   	r3,[r12]
	beq  	r3,r0,L_23
	lc   	r3,[r12]
	bne  	r3,#37,L_24
	addui	r12,r12,#2
	lc   	r3,[r12]
	sext16	r3,r3
	or   	r1,r3,r0
	beq  	r1,#37,L_27
	beq  	r1,#99,L_28
	beq  	r1,#100,L_29
	beq  	r1,#115,L_30
	bra  	L_26
L_27:
	subui	sp,sp,#16
	sw   	r4,8[sp]
	sw   	r5,[sp]
	subui	sp,sp,#8
	ori  	r3,r0,#37
	sw   	r3,[sp]
	jal  	lr,[r13]
	addui	sp,sp,#8
	lw   	r4,8[sp]
	lw   	r5,[sp]
	addui	sp,sp,#16
	mov  	r3,r1
	bra  	L_26
L_28:
	addui	r11,r11,#8
	subui	sp,sp,#16
	sw   	r4,8[sp]
	sw   	r5,[sp]
	subui	sp,sp,#8
	lw   	r3,[r11]
	sw   	r3,[sp]
	jal  	lr,[r13]
	addui	sp,sp,#8
	lw   	r4,8[sp]
	lw   	r5,[sp]
	addui	sp,sp,#16
	mov  	r3,r1
	bra  	L_26
L_29:
	addui	r11,r11,#8
	subui	sp,sp,#16
	sw   	r4,8[sp]
	sw   	r5,[sp]
	subui	sp,sp,#8
	lw   	r3,[r11]
	sw   	r3,[sp]
	call 	putnum
	addui	sp,sp,#8
	lw   	r4,8[sp]
	lw   	r5,[sp]
	addui	sp,sp,#16
	mov  	r3,r1
	bra  	L_26
L_30:
	addui	r11,r11,#8
	subui	sp,sp,#16
	sw   	r4,8[sp]
	sw   	r5,[sp]
	subui	sp,sp,#8
	lw   	r3,[r11]
	sw   	r3,[sp]
	call 	putstr
	addui	sp,sp,#8
	lw   	r4,8[sp]
	lw   	r5,[sp]
	addui	sp,sp,#16
	mov  	r3,r1
	bra  	L_26
L_26:
	bra  	L_25
L_24:
	subui	sp,sp,#16
	sw   	r4,8[sp]
	sw   	r5,[sp]
	subui	sp,sp,#8
	lc   	r3,[r12]
	sext16	r3,r3
	sw   	r3,[sp]
	jal  	lr,[r13]
	addui	sp,sp,#8
	lw   	r4,8[sp]
	lw   	r5,[sp]
	addui	sp,sp,#16
	mov  	r3,r1
L_25:
	addui	r12,r12,#2
	bra  	L_22
L_23:
L_31:
	lw   	r13,16[sp]
	lw   	r12,8[sp]
	lw   	r11,[sp]
	addui	sp,sp,#24
	mov  	sp,bp
	lw   	bp,[sp]
	lw   	xlr,8[sp]
	lw   	lr,16[sp]
	ret  	#24
L_21:
	lw   	lr,8[bp]
	sw   	lr,16[bp]
	bra  	L_31
putch:
	subui	sp,sp,#24
	sw   	bp,[sp]
	mov  	bp,sp
	     			lw		r1,#0xAF
		outb	r1,0xdc0600
	
	     			lw		r1,#0x0a
		lw		r2,24[bp]
		lw		r3,#1
		syscall	#410
	
	     			lw		r1,#0xB0
		outb	r1,0xdc0600
	
L_33:
	mov  	sp,bp
	lw   	bp,[sp]
	ret  	#24
L_32:
putnum:
	subui	sp,sp,#24
	sw   	bp,[sp]
	mov  	bp,sp
	     			lw		r1,#0xB1
		outb	r1,0xdc0600
	
	     			lw		r1,#0x15
		lw		r2,24[bp]
		lw		r3,#5
		syscall	#410
	
	     			lw		r1,#0xB2
		outb	r1,0xdc0600
	
L_35:
	mov  	sp,bp
	lw   	bp,[sp]
	ret  	#24
L_34:
putstr:
	subui	sp,sp,#24
	sw   	bp,[sp]
	mov  	bp,sp
	     			lw		r1,#0x14
		lw		r2,24[bp]
		syscall	#410
	
L_37:
	mov  	sp,bp
	lw   	bp,[sp]
	ret  	#24
L_36:
get_tick:
	subui	sp,sp,#24
	sw   	bp,[sp]
	mov  	bp,sp
	     			lw		r1,#0
		syscall	#416
	
L_39:
	mov  	sp,bp
	lw   	bp,[sp]
	ret  	#24
L_38:
crt_start:
	subui	sp,sp,#24
	sw   	bp,[sp]
	sw   	xlr,8[sp]
	sw   	lr,16[sp]
	lea  	xlr,L_41
	mov  	bp,sp
	     			lw		r1,#0xAA
		outb	r1,0xdc0600
		sw		sp,sp_save
		lw		sp,#0x1_07FFFFF8
		lw		r1,#0x17
		mov		r2,sp
		syscall	#410
		lea		xlr,prog_abort
		call	main
		lw		sp,sp_save
		bra		retcode
prog_abort:
	
	subui	sp,sp,#16
	sw   	r4,8[sp]
	sw   	r5,[sp]
	subui	sp,sp,#8
	ori  	r3,r0,#L_0
	sw   	r3,[sp]
	call 	putstr
	addui	sp,sp,#8
	lw   	r4,8[sp]
	lw   	r5,[sp]
	addui	sp,sp,#16
	     			lw	sp,sp_save
retcode:
	
L_42:
	mov  	sp,bp
	lw   	bp,[sp]
	lw   	xlr,8[sp]
	lw   	lr,16[sp]
	ret  	#24
L_41:
	lw   	lr,8[bp]
	sw   	lr,16[bp]
	bra  	L_42
	align	8
L_40:
	dc	80,114,111,103,114,97,109,32
	dc	97,98,111,114,116,101,100,32
	dc	97,98,110,111,114,109,97,108
	dc	108,121,46,0
L_4:
	dc	37,100,10,0
L_3:
	dc	67,108,111,99,107,32,116,105
	dc	99,107,115,32,37,100,13,10
	dc	0
L_2:
	dc	83,116,97,114,116,32,116,105
	dc	99,107,32,37,100,13,10,0
;	global	putch
;	global	get_tick
;	global	my_org
;	global	printf
;	global	main
;	global	putnum
;	global	putstr
;	global	crt_start
