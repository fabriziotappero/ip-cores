	code
	align	16
main:
	subui	sp,sp,#24
	sm   	[sp],r27/r28/r31
	lea  	xlr,L_1
	mov  	bp,sp
	subui	sp,sp,#12800024
	ori  	r3,r0,#1500000
	sw   	r3,-12800024[bp]
	ori  	r3,r0,#0
	sw   	r3,-8[bp]
L_2:
	lw   	r3,-8[bp]
	lw   	r4,-12800024[bp]
	bge  	r3,r4,L_3
	lw   	r3,-8[bp]
	add  	r3,r3,#2
	lw   	r4,-8[bp]
	mului	r4,r4,#8
	lea  	r5,-12000016[bp]
	sw   	r3,0[r4+r5]
	lw   	r3,-8[bp]
	addui	r3,r3,#1
	sw   	r3,-8[bp]
	bra  	L_2
L_3:
	ori  	r3,r0,#0
	sw   	r3,-8[bp]
L_4:
	lw   	r3,-8[bp]
	lw   	r4,-12800024[bp]
	bge  	r3,r4,L_5
	lw   	r3,-8[bp]
	mului	r3,r3,#8
	lea  	r4,-12000016[bp]
	lw   	r3,0[r3+r4]
	ori  	r5,r0,#1
	neg  	r5,r5
	beq  	r3,r5,L_6
	lw   	r3,-8[bp]
	mului	r3,r3,#8
	lea  	r4,-12000016[bp]
	lw   	r3,0[r3+r4]
	mulsi	r3,r3,#2
	sub  	r3,r3,#2
	sw   	r3,-16[bp]
L_8:
	lw   	r3,-16[bp]
	lw   	r4,-12800024[bp]
	bge  	r3,r4,L_9
	ori  	r3,r0,#1
	neg  	r3,r3
	lw   	r4,-16[bp]
	mului	r4,r4,#8
	lea  	r5,-12000016[bp]
	sw   	r3,0[r4+r5]
	lw   	r3,-8[bp]
	mului	r3,r3,#8
	lea  	r4,-12000016[bp]
	lw   	r3,0[r3+r4]
	lw   	r5,-16[bp]
	add  	r5,r5,r3
	sw   	r5,-16[bp]
	bra  	L_8
L_9:
L_6:
	lw   	r3,-8[bp]
	addui	r3,r3,#1
	sw   	r3,-8[bp]
	bra  	L_4
L_5:
	ori  	r3,r0,#0
	sw   	r3,-16[bp]
	ori  	r3,r0,#0
	sw   	r3,-8[bp]
L_10:
	lw   	r3,-8[bp]
	lw   	r4,-12800024[bp]
	bge  	r3,r4,L_11
	lw   	r3,-16[bp]
	lea  	r4,-12800016[bp]
	bge  	r3,r4,L_11
	lw   	r3,-8[bp]
	mului	r3,r3,#8
	lea  	r4,-12000016[bp]
	lw   	r3,0[r3+r4]
	ori  	r5,r0,#1
	neg  	r5,r5
	beq  	r3,r5,L_12
	lw   	r3,-8[bp]
	mului	r3,r3,#8
	lea  	r4,-12000016[bp]
	lw   	r3,0[r3+r4]
	lw   	r5,-16[bp]
	addui	r5,r5,#1
	sw   	r5,-16[bp]
	mului	r5,r5,#8
	lea  	r6,-12800016[bp]
	sw   	r3,0[r5+r6]
L_12:
	lw   	r3,-8[bp]
	addui	r3,r3,#1
	sw   	r3,-8[bp]
	bra  	L_10
L_11:
	ori  	r3,r0,#0
	sw   	r3,-8[bp]
L_14:
	lw   	r3,-8[bp]
	bge  	r3,#100000,L_15
	subui	sp,sp,#16
	sm   	[sp],r4/r6
	subui	sp,sp,#16
	lw   	r3,-8[bp]
	mului	r3,r3,#8
	lea  	r4,-12800016[bp]
	lw   	r3,0[r3+r4]
	sw   	r3,8[sp]
	ori  	r3,r0,#L_0
	sw   	r3,0[sp]
	call 	printf
	addui	sp,sp,#16
	lm   	[sp],r4/r6
	addui	sp,sp,#16
	or   	r3,r1,r0
	lw   	r3,-8[bp]
	addui	r3,r3,#1
	sw   	r3,-8[bp]
	bra  	L_14
L_15:
	ori  	r1,r0,#0
L_16:
	mov  	sp,bp
	lm   	[sp],r27/r28/r31
	ret  	#24
	bra  	L_16
L_1:
	lw   	lr,16[bp]
	sw   	lr,[bp]
	bra  	L_16
	align	8
L_0:
	dc	37,100,10,0
	extern	printf
;	global	main
