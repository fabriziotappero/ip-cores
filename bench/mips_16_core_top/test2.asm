;multiply R3=R1*R2 using add and shift instructions
;	R1: number 1
;	R2: number 2
;	R3: ACC
;	R4: masked R2
;	R5: 16
;	R6: mask, {15'b0,1'b1}
;	R7: conuter

	ADDI	R1,R0,28
	ADDI	R2,R0,17
	ADDI	R6,R0,1
	ADDI	R7,R0,0
	ADDI	R5,R0,16	;R5=16
L1:	ADDI	R7,R7,1		;R7++
	AND		R4,R6,R2
	BZ		R4,L2		;dont need add, skip
	NOP
	ADD		R3,R3,R1	;accumulate
L2:	SL		R1,R1,R6	;R1=R1<<1
	SRU		R2,R2,R6	;R2=R2>>1
	SUB		R4,R5,R7	;R4=R5-R7
	BZ		R4,L3		;shift over, go to stop
	NOP
	BZ		R0,L1		;continue
	NOP
L3:	BZ		R0,L3		;stop here
	NOP
	