// Program tests all instructions except:
// ACALL, LCALL, MOVX(1-4), NOP, RET,and RETI


void main() {

	#pragma asm

////////////////   INST 2 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_2:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_2
		MOV  PSW,#0

// ADD A,Rn (2)
		MOV  A,#10
		MOV  R0,#10
		ADD  A,R0
		SUBB A,#20
		JZ   DONE_2
		MOV  P1,#2
		LJMP FAILED
	DONE_2:


////////////////   INST 3 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_3:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_3
		MOV  PSW,#0

// ADD A,direct (3)
		MOV  A,#10
		MOV  100,#10
		ADD  A,100
		SUBB A,#20
		JZ   DONE_3
		MOV  P1,#3
		LJMP FAILED
	DONE_3:


////////////////   INST 4 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_4:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_4
		MOV  PSW,#0

// ADD A,@Ri (4)
		MOV  A,#10
		MOV  R0,#100
		MOV  100,#10
		ADD  A,@R0
		SUBB A,#20
		JZ   DONE_4
		MOV  P1,#4
		LJMP FAILED
	DONE_4:


////////////////   INST 5 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_5:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_5
		MOV  PSW,#0

// ADD A,#data (5)
		MOV  A,#10
		ADD  A,#5
		SUBB A,#15
		JZ   DONE_5
		MOV  P1,#5
		LJMP FAILED
	DONE_5:

////////////////   INST 6 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_6:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_6
		MOV  PSW,#0

// ADDC A,Rn (6)
		MOV  A,#10
		MOV  R0,#10
		CPL  C
		ADDC A,R0
		SUBB A,#21
		JZ   DONE_6
		MOV  P1,#6
		LJMP FAILED
	DONE_6:


////////////////   INST 7 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_7:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_7
		MOV  PSW,#0

// ADDC A,direct (7)
		MOV  A,#10
		MOV  100,#10
		CPL  C
		ADDC A,100
		SUBB A,#21
		JZ   DONE_7
		MOV  P1,#7
		LJMP FAILED
	DONE_7:


////////////////   INST 8 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_8:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_8
		MOV  PSW,#0

// ADDC A,@Ri (8)
		MOV  A,#10
		MOV  R0,#100
		MOV  100,#10
		CPL  C
		ADDC A,@R0
		SUBB A,#21
		JZ   DONE_8
		MOV  P1,#8
		LJMP FAILED
	DONE_8:


////////////////   INST 9 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_9:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_9
		MOV  PSW,#0

// ADDC A,#data (9)
		MOV  A,#10
		CPL  C
		ADDC A,#5
		SUBB A,#16
		JZ   DONE_9
		MOV  P1,#9
		LJMP FAILED
	DONE_9:

////////////////  INST 10 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_10:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_10
		MOV  PSW,#0

// AJMP (10)
		AJMP DONE_10
		MOV  P1,#10
		LJMP FAILED
	DONE_10:

////////////////  INST 11 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_11:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_11
		MOV  PSW,#0

// ANL A,Rn (11)
		MOV  R0,#255
		MOV  A,#170
		ANL  A,R0
		SUBB A,#170
		JZ   DONE_11
		MOV  P1,#11
		LJMP FAILED
	DONE_11:

////////////////  INST 12 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_12:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_12
		MOV  PSW,#0

// ANL A,direct (12)
		MOV  127,#0
		MOV  A,#255
		ANL  A,127
		JZ   DONE_12
		MOV  P1,#12
		LJMP FAILED
	DONE_12:

////////////////  INST 13 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_13:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_13
		MOV  PSW,#0

// ANL A,@Ri (13)
		MOV  R0,#127
		MOV  127,#1
		MOV  A,#254
		ANL  A,@R0
		JZ   DONE_13
		MOV  P1,#13
		LJMP FAILED
	DONE_13:

////////////////  INST 14 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_14:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_14
		MOV  PSW,#0

// ANL A,#data (14)
		MOV  A,#255
		ANL  A,#255
		SUBB A,#255
		JZ   DONE_14
		MOV  P1,#14
		LJMP FAILED
	DONE_14:

////////////////  INST 15 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_15:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_15
		MOV  PSW,#0

// ANL direct,A (15)
		MOV  50,#255
		MOV  A,#0
		ANL  50,A
		MOV  A,50
		JZ   DONE_15
		MOV  P1,#15
		LJMP FAILED
	DONE_15:

////////////////  INST 16 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_16:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_16
		MOV  PSW,#0

// ANL direct,#data (16)
		MOV  25,#128
		ANL  25,#255
		MOV  A,25
		SUBB A,#128
		JZ   DONE_16
		MOV  P1,#16
		LJMP FAILED
	DONE_16:

////////////////  INST 17 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_17:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_17
		MOV  PSW,#0

// ANL C,bit (17)
		MOV  A,#128
		CPL  C
		ANL  C,ACC.7
		SUBB A,#127
		JZ   DONE_17
		MOV  P1,#17
		LJMP FAILED
	DONE_17:

////////////////  INST 18 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_18:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_18
		MOV  PSW,#0

// ANL C,/bit (18)
		MOV  A,#128
		CPL  C
		ANL  C,/ACC.7
		SUBB A,#128
		JZ   DONE_18
		MOV  P1,#18
		LJMP FAILED
	DONE_18:

////////////////  INST 19 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_19:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_19
		MOV  PSW,#0

// CJNE A,direct,rel (19)
		MOV  A,#128
		MOV  100,#128
		CJNE A,100,ERROR_19
		MOV  A,#127
		CJNE A,100,CHECK_C_19
	ERROR_19:
		MOV  P1,#19
		LJMP FAILED
	CHECK_C_19:		;Checks that carry was set
		JC   DONE_19
		MOV  P1,#19
		LJMP FAILED
	DONE_19:

		
////////////////  INST 20 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_20:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_20
		MOV  PSW,#0
		
// CJNE A,#data,rel (20)
		MOV  A,#128
		CJNE A,#128,ERROR_20
		MOV  A,#127
		CJNE A,#128,CHECK_C_20
	ERROR_20:
		MOV  P1,#20
		LJMP FAILED
	CHECK_C_20:		;Checks that carry was set
		JC   DONE_20
		MOV  P1,#20
		LJMP FAILED
	DONE_20:


////////////////  INST 21 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_21:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_21
		MOV  PSW,#0

// CJNE Rn,#data,rel (21)
		MOV  R1,#128
		CJNE R1,#128,ERROR_21
		MOV  R1,#127
		CJNE R1,#128,CHECK_C_21
	ERROR_21:
		MOV  P1,#21
		LJMP FAILED
	CHECK_C_21:		;Checks that carry was set
		JC   DONE_21
		MOV  P1,#21
		LJMP FAILED
	DONE_21:

////////////////  INST 22 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_22:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_22
		MOV  PSW,#0

// CJNE @Ri,#data,rel (22)
		MOV  R1,#100
		MOV  100,#128
		CJNE @R1,#128,ERROR_22
		MOV  100,#127
		CJNE @R1,#128,CHECK_C_22
	ERROR_22:
		MOV  P1,#22
		LJMP FAILED
	CHECK_C_22:		;Checks that carry was set
		JC   DONE_22
		MOV  P1,#22
		LJMP FAILED
	DONE_22:


////////////////  INST 23 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_23:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_23
		MOV  PSW,#0

// CLR A (23)
		MOV  A,#128
		CLR  A
		JZ   DONE_23
		MOV  P1,#23
		LJMP FAILED
	DONE_23:


////////////////  INST 24 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_24:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_24
		MOV  PSW,#0

// CLR C (24)
		CPL  C
		CLR  C
		JNC   DONE_24
		MOV  P1,#24
		LJMP FAILED
	DONE_24:

////////////////  INST 25 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_25:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_25
		MOV  PSW,#0

// CLR bit (25)
		MOV  A,#64
		CLR  ACC.6
		JZ   DONE_25
		MOV  P1,#25
		LJMP FAILED
	DONE_25:

////////////////  INST 26 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_26:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_26
		MOV  PSW,#0

// CPL A (26)
		MOV  A,#255
		CPL  A
		JZ   DONE_26
		MOV  P1,#26
		LJMP FAILED
	DONE_26:


////////////////  INST 27 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_27:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_27
		MOV  PSW,#0

// CPL C (27)
		CPL  C
		JC   DONE_27
		MOV  P1,#27
		LJMP FAILED
	DONE_27:


////////////////  INST 28 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_28:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_28
		MOV  PSW,#0

// CPL bit (28)
		MOV  A,#32
		CPL  ACC.5
		JZ   DONE_28
		MOV  P1,#28
		LJMP FAILED
	DONE_28:


////////////////  INST 29 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_29:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_29
		MOV  PSW,#0

// DA A (29)
		MOV  A,#80H
		ADD  A,#99H
		DA   A
		SUBB A,#78H	;Will clr ACC if C set
		JZ   DONE_29
		MOV  P1,#29
		LJMP FAILED		
	DONE_29:


/////////////////  INST 30 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_30:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_30
		MOV  PSW,#0

// DEC A (30)
		MOV  A,#10
		DEC  A
		SUBB A,#9
		JZ   DONE_30
		MOV  P1,#30
		LJMP FAILED
	DONE_30:  

/////////////////  INST 31 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_31:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_31
		MOV  PSW,#0

// DEC Rn (31)
		MOV  R0,#10
		DEC  R0
		MOV  A,R0
		SUBB A,#9
		JZ   DONE_31
		MOV  P1,#31
		LJMP FAILED
	DONE_31:  

/////////////////  INST 32 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_32:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_32
		MOV  PSW,#0

// DEC direct (32)
		MOV  127,#10
		DEC  127
		MOV  A,127
		SUBB A,#9
		JZ   DONE_32
		MOV  P1,#32
		LJMP FAILED
	DONE_32:
  
/////////////////  INST 33 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_33:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_33
		MOV  PSW,#0

// DEC @Ri (33)
		MOV  R0,#127
		MOV  127,#10
		DEC  @R0
		MOV  A,@R0
		SUBB A,#9
		JZ   DONE_33
		MOV  P1,#33
		LJMP FAILED
	DONE_33:  


/////////////////  INST 34 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_34:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_34
		MOV  PSW,#0

// DIV AB (34)
		MOV  A,#251
		MOV  B,#18
		DIV  AB
		SUBB A,#13
		JZ   CHECK_B_34
		MOV  P1,#34
	CHECK_B_34:
		MOV  A,B
		SUBB A,#17
		JZ   DONE_34
		MOV  P1,#34
		LJMP FAILED
	DONE_34:


/////////////////  INST 35 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_35:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_35
		MOV  PSW,#0
		
// DJNZ Rn,rel (35)
		MOV  R0,#10
		DJNZ R0,JUMP_35		;Should jump
		MOV  P1,#35
		LJMP FAILED
	JUMP_35:
		MOV  R0,#1
		DJNZ R0,NOT_JUMP_35	;Should not jump
		AJMP DONE_35
	NOT_JUMP_35:
		MOV  P1,#35
		LJMP FAILED
	DONE_35:  

/////////////////  INST 36 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_36:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_36
		MOV  PSW,#0

// DJNZ direct,rel (36)
		MOV  127,#10
		DJNZ 127,JUMP_36	;Should jump
		MOV  P1,#36
		LJMP FAILED
	JUMP_36:
		MOV  127,#1
		DJNZ 127,NOT_JUMP_36	;Should not jump
		AJMP DONE_36
	NOT_JUMP_36:
		MOV  P1,#36
		LJMP FAILED
	DONE_36:  

/////////////////  INST 37 //////////////////////
	
	// Clear RAM
		MOV  R0,#128
	RAM_CLR_37:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_37
		MOV  PSW,#0

// INC A (37)
		MOV  A,#10
		INC  A
		SUBB A,#11
		JZ   DONE_37
		MOV  P1,#37
		LJMP FAILED
	DONE_37:  

/////////////////  INST 38 //////////////////////
	
	// Clear RAM
		MOV  R0,#128
	RAM_CLR_38:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_38
		MOV  PSW,#0

// INC Rn (38)
		MOV  R0,#10
		INC  R0
		MOV  A,R0
		SUBB A,#11
		JZ   DONE_38
		MOV  P1,#38
		LJMP FAILED
	DONE_38:  

/////////////////  INST 39 //////////////////////
	
	// Clear RAM
		MOV  R0,#128
	RAM_CLR_39:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_39
		MOV  PSW,#0

// INC direct (39)
		MOV  127,#10
		INC  127
		MOV  A,127
		SUBB A,#11
		JZ   DONE_39
		MOV  P1,#39
		LJMP FAILED
	DONE_39:

/////////////////  INST 40 //////////////////////
	
	// Clear RAM
		MOV  R0,#128
	RAM_CLR_40:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_40
		MOV  PSW,#0

// INC @Ri (40)
		MOV  127,#10
		MOV  R0,#127
		INC  @R0
		MOV  A,@R0
		SUBB A,#11
		JZ   DONE_40
		MOV  P1,#40
		LJMP FAILED
	DONE_40:  


/////////////////  INST 41 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_41:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_41
		MOV  PSW,#0

// INC DPTR (41)
		MOV  DPTR,#12FFH
		INC  DPTR
		MOV  A,DPH
		SUBB A,#13H
		JZ   DPH_OK_41
		MOV  P1,#41
		LJMP FAILED
	DPH_OK_41:
		MOV  A,DPL
		JZ   DONE_41
		MOV  P1,#41
		LJMP FAILED
	DONE_41:  


/////////////////  INST 42 //////////////////////
	
	// Clear RAM
		MOV  R0,#128
	RAM_CLR_42:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_42
		MOV  PSW,#0

// JB bit,rel (42)
		MOV  A,#16
		JB   ACC.4,DONE_42
		MOV  P1,#42
		LJMP FAILED
	DONE_42:


/////////////////  INST 43 //////////////////////
	
	// Clear RAM
		MOV  R0,#128
	RAM_CLR_43:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_43
		MOV  PSW,#0

// JBC bit,rel (43)
		MOV  A,#8
		JBC  ACC.3,CHECK_BIT_43
		MOV  P1,#43
		LJMP FAILED
	CHECK_BIT_43:
		JZ   DONE_43
		MOV  P1,#43
		LJMP FAILED
	DONE_43:

/////////////////  INST 44 //////////////////////
	
	// Clear RAM
		MOV  R0,#128
	RAM_CLR_44:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_44
		MOV  PSW,#0

// JC rel (44)
		JC   ERROR_44
		CPL  C
		JC   DONE_44
	ERROR_44:
		MOV  P1,#44
		LJMP FAILED
	DONE_44:

/////////////////  INST 45 //////////////////////
	
	// Clear RAM
		MOV  R0,#128
	RAM_CLR_45:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_45
		MOV  PSW,#0

// JMP @A+DPTR (45)
		MOV  A,#4
		MOV  DPTR,#JMP_TBL
		JMP  @A+DPTR
	JMP_TBL:
		AJMP JUMP_0
		AJMP JUMP_2
		AJMP JUMP_4
		AJMP JUMP_6
	JUMP_0:
	JUMP_2:
	JUMP_6:
		MOV  P1,#43
		LJMP FAILED
	JUMP_4:

/////////////////  INST 46 //////////////////////
	
	// Clear RAM
		MOV  R0,#128
	RAM_CLR_46:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_46
		MOV  PSW,#0

// JNB bit,rel (46)
		MOV  A,#4
		JNB  ACC.2,ERROR_46
		JNB  ACC.1,DONE_46
	ERROR_46:
		MOV  P1,#46
		LJMP FAILED
	DONE_46:

/////////////////  INST 47 //////////////////////
	
	// Clear RAM
		MOV  R0,#128
	RAM_CLR_47:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_47
		MOV  PSW,#0

// JNC rel (47)
		CPL  C
		JNC  ERROR_47
		CPL  C
		JNC  DONE_47
	ERROR_47:
		MOV  P1,#47
		LJMP FAILED
	DONE_47:

/////////////////  INST 48 //////////////////////
	
	// Clear RAM
		MOV  R0,#128
	RAM_CLR_48:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_48
		MOV  PSW,#0

// JNZ rel (48)
		JNZ ERROR_48
		MOV A,#1
		JNZ DONE_48
	ERROR_48:
		MOV  P1,#48
		LJMP FAILED
	DONE_48:

/////////////////  INST 49 //////////////////////
	
	// Clear RAM
		MOV  R0,#128
	RAM_CLR_49:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_49
		MOV  PSW,#0

// JZ rel (49)
		MOV  A,#2
		JZ   ERROR_49
		MOV  A,#0
		JZ   DONE_49
	ERROR_49:
		MOV  P1,#49
		LJMP FAILED
	DONE_49:

/////////////////  INST 51 //////////////////////
	
	// Clear RAM
		MOV  R0,#128
	RAM_CLR_51:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_51
		MOV  PSW,#0

// LJMP (51)
	      LJMP DONE_51
		MOV  P1,#51
		LJMP FAILED
	DONE_51:

/////////////////  INST 52 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_52:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_52
		MOV  PSW,#0

// MOV A,Rn (52)
		MOV  R0,#10
		MOV  A,R0
		SUBB A,#10
		JZ   DONE_52
		MOV  P1,#52
		LJMP FAILED
	DONE_52:  


/////////////////  INST 53 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_53:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_53
		MOV  PSW,#0

// MOV A,direct (53)
		MOV  127,#10
		MOV  A,127
		SUBB A,#10
		JZ   DONE_53
		MOV  P1,#53
		LJMP FAILED
	DONE_53:  

/////////////////  INST 54 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_54:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_54
		MOV  PSW,#0

// MOV A,@Ri (54)
		MOV  R0,#127
		MOV  127,#10
		MOV  A,@R0
		SUBB A,#10
		JZ   DONE_54
		MOV  P1,#54
		LJMP FAILED
	DONE_54:  


/////////////////  INST 55 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_55:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_55
		MOV  PSW,#0

// MOV A,#data (55)
		MOV  A,#10
		SUBB A,#10
		JZ   DONE_55
		MOV  P1,#55
		LJMP FAILED
	DONE_55:  

/////////////////  INST 56 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_56:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_56
		MOV  PSW,#0

// MOV Rn,A (56)
		MOV  A,#10
		MOV  R0,A
		CLR  A
		MOV  A,R0
		SUBB A,#10
		JZ   DONE_56
		MOV  P1,#56
		LJMP FAILED
	DONE_56:  

/////////////////  INST 57 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_57:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_57
		MOV  PSW,#0

// MOV Rn,direct (57)
		MOV  127,#10
		MOV  R0,127
		MOV  A,R0
		SUBB A,#10
		JZ   DONE_57
		MOV  P1,#57
		LJMP FAILED
	DONE_57:  

/////////////////  INST 58 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_58:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_58
		MOV  PSW,#0

// MOV Rn,#data (58)
		MOV  R0,#10
		MOV  A,R0
		SUBB A,#10
		JZ   DONE_58
		MOV  P1,#58
		LJMP FAILED
	DONE_58:  

/////////////////  INST 59 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_59:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_59
		MOV  PSW,#0

// MOV direct,A (59)
		MOV  A,#10
		MOV  127,A
		CLR  A
		MOV  A,127
		SUBB A,#10
		JZ   DONE_59
		MOV  P1,#59
		LJMP FAILED
	DONE_59:  

/////////////////  INST 60 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_60:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_60
		MOV  PSW,#0

// MOV direct,Rn (60)
		MOV  R0,#10
		MOV  127,R0
		MOV  A,127
		SUBB A,#10
		JZ   DONE_60
		MOV  P1,#60
		LJMP FAILED
	DONE_60:  

/////////////////  INST 61 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_61:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_61
		MOV  PSW,#0

// MOV direct,direct (61)
		MOV  127,#10
		MOV  126,127
		MOV  A,126
		SUBB A,#10
		JZ   DONE_61
		MOV  P1,#61
		LJMP FAILED
	DONE_61:  

/////////////////  INST 62 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_62:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_62
		MOV  PSW,#0

// MOV direct,@Ri (62)
		MOV  127,#10
		MOV  R0,#127
		MOV  126,@R0
		MOV  A,126
		SUBB A,#10
		JZ   DONE_62
		MOV  P1,#62
		LJMP FAILED
	DONE_62:  

/////////////////  INST 63 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_63:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_63
		MOV  PSW,#0

// MOV direct,#data (63)
		MOV  127,#10
		MOV  A,127
		SUBB A,#10
		JZ   DONE_63
		MOV  P1,#63
		LJMP FAILED
	DONE_63:  

/////////////////  INST 64 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_64:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_64
		MOV  PSW,#0

// MOV @Ri,A (64)
		MOV  A,#10
		MOV  R0,#127
		MOV  @R0,A
		CLR  A
		MOV  A,127
		SUBB A,#10
		JZ   DONE_64
		MOV  P1,#64
		LJMP FAILED
	DONE_64:  

/////////////////  INST 65 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_65:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_65
		MOV  PSW,#0

// MOV @Ri,direct (65)
		MOV  127,#10
		MOV  R0,#126
		MOV  @R0,127
		MOV  A,126
		SUBB A,#10
		JZ   DONE_65
		MOV  P1,#65
		LJMP FAILED
	DONE_65:  

/////////////////  INST 66 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_66:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_66
		MOV  PSW,#0

// MOV @Ri,#data (66)
		MOV  R0,#127
		MOV  @R0,#10
		MOV  A,127
		SUBB A,#10
		JZ   DONE_66
		MOV  P1,#66
		LJMP FAILED
	DONE_66:  

/////////////////  INST 67 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_67:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_67
		MOV  PSW,#0

// MOV C,bit (67)
		MOV  A,#1
		MOV  C,ACC.0
		JC   DONE_67
		MOV  P1,#67
		LJMP FAILED
	DONE_67:  

/////////////////  INST 68 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_68:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_68
		MOV  PSW,#0

// MOV bit,C (68)
		CPL  C
		MOV  ACC.0,C
		CPL  C
		SUBB A,#1
		JZ   DONE_68
		MOV  P1,#68
		LJMP FAILED
	DONE_68:  

/////////////////  INST 69 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_69:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_69
		MOV  PSW,#0

// MOVC DPTR,#data (69)
		MOV  DPTR,#1234H
		MOV  A,DPH
		SUBB A,#12H
		JNZ  ERROR_69
		MOV  A,DPL
		SUBB A,#34H
		JZ   DONE_69
	ERROR_69:
		MOV  P1,#69
		LJMP FAILED
	DONE_69:


/////////////////  INST 70 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_70:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_70
		MOV  PSW,#0

// MOVC A,@A+DPTR (70)
		MOV  DPTR,#DB_TBL
		MOVC A,@A+DPTR
		SUBB A,#66H
		JNZ  ERROR_70
		MOV  A,#1
		MOVC A,@A+DPTR
		SUBB A,#77H
		JZ   DONE_70
		JNZ  ERROR_70
	DB_TBL:
		DB   66H
		DB   77H
	ERROR_70:	
		MOV  P1,#70
		LJMP FAILED
	DONE_70:


/////////////////  INST 71 //////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_71:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_71
		MOV  PSW,#0

// MOVC A,@A+PC (71)
		MOV  A,#13
		MOVC A,@A+PC
		SUBB A,#66H
		JNZ  ERROR_71
		MOV  A,#7
		MOVC A,@A+PC
		SUBB A,#77H
		JZ   DONE_71
		JNZ  ERROR_71
		DB   66H
		DB   77H
	ERROR_71:	
		MOV  P1,#71
		LJMP FAILED
	DONE_71:


////////////////  INST 76 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_76:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_76
		MOV  PSW,#0

// MUL AB (76)
		MOV  A,#80
		MOV  B,#160
		MUL  AB		; = 3200H
		JNZ  ERROR_76
		MOV  A,B
		SUBB A,#32H
		JZ   DONE_76
	ERROR_76:	
		MOV  P1,#76
		LJMP FAILED
	DONE_76:  


////////////////  INST 78 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_78:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_78
		MOV  PSW,#0

// ORL A,Rn (78)
		MOV  A,#90H
		MOV  R0,#9H
		ORL  A,R0
		SUBB A,#99H
		JZ   DONE_78
		MOV  P1,#78
		LJMP FAILED
	DONE_78:

////////////////  INST 79 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_79:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_79
		MOV  PSW,#0

// ORL A,direct (79)
		MOV  A,#9H
		MOV  127,#90H
		ORL  A,127
		SUBB A,#99H
		JZ   DONE_79
		MOV  P1,#79
		LJMP FAILED
	DONE_79:

////////////////  INST 80 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_80:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_80
		MOV  PSW,#0

// ORL A,@Ri (80)
		MOV  A,#90H
		MOV  R0,#127
		MOV  127,#06H
		ORL  A,@R0
		SUBB A,#96H
		JZ   DONE_80
		MOV  P1,#80
		LJMP FAILED
	DONE_80:

////////////////  INST 81 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_81:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_81
		MOV  PSW,#0

// ORL A,#data (81)
		MOV  A,#11H
		ORL  A,#22H
		SUBB A,#33H
		JZ   DONE_81
		MOV  P1,#81
		LJMP FAILED
	DONE_81:

////////////////  INST 82 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_82:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_82
		MOV  PSW,#0

// ORL direct,A (82)
		MOV  A,#90H
		MOV  127,#9H
		ORL  127,A
		CLR  A
		MOV  A,127
		SUBB A,#99H
		JZ   DONE_82
		MOV  P1,#82
		LJMP FAILED
	DONE_82:

////////////////  INST 83 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_83:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_83
		MOV  PSW,#0

// ORL direct,#data (83)
		MOV  127,#90H
		ORL  127,#9H
		MOV  A,127
		SUBB A,#99H
		JZ   DONE_83
		MOV  P1,#83
		LJMP FAILED
	DONE_83:

////////////////  INST 84 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_84:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_84
		MOV  PSW,#0

// ORL C,bit (84)
		ORL  C,ACC.0
		JC   ERROR_84
		MOV  A,#1
		ORL  C,ACC.0
		JNC  ERROR_84
		ORL  C,ACC.1
		JC   DONE_84
	ERROR_84:
		MOV  P1,#84
		LJMP FAILED
	DONE_84:

////////////////  INST 85 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_85:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_85
		MOV  PSW,#0

// ORL C,/bit (85)
		MOV  A,#1
		ORL  C,/ACC.0
		JC   ERROR_85
		ORL  C,/ACC.1
		JNC  ERROR_85
		ORL  C,/ACC.0
		JC   DONE_85
	ERROR_85:
		MOV  P1,#85
		LJMP FAILED
	DONE_85:


////////////////  INST 86,87 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_87:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_87
		MOV  PSW,#0

// PUSH direct (87)
		MOV  DPTR,#0123H
		MOV  127,#8
		PUSH DPL
		PUSH DPH
		PUSH 127
		MOV  A,8
		SUBB A,#23H
		JNZ  ERROR_87
		MOV  A,9
		SUBB A,#1
		JNZ ERROR_87
		MOV  A,10
		SUBB A,#8
		JZ   DONE_87
	ERROR_87:
		MOV  P1,#87
		LJMP FAILED
	DONE_87:

// POP direct (86)
		POP  SP
		POP  100
		MOV  A,100
		SUBB A,#23H
		JZ   DONE_86
		MOV  P1,#86
		LJMP FAILED
	DONE_86:

////////////////  INST 90 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_90:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_90
		MOV  PSW,#0

// RL A (90)
		MOV  A,#129
		RL   A
		SUBB A,#3
		JZ   DONE_90
		MOV  P1,#90
		LJMP FAILED
	DONE_90:


////////////////  INST 91 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_91:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_91
		MOV  PSW,#0

// RLC A (91)
		MOV  A,#129
		RLC  A
		SUBB A,#1	;A(2)-C(1)-1
		JZ   DONE_91
		MOV  P1,#91
		LJMP FAILED
	DONE_91:

////////////////  INST 92 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_92:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_92
		MOV  PSW,#0

// RR A (92)
		MOV  A,#129
		RR   A
		SUBB A,#192
		JZ   DONE_92
		MOV  P1,#92
		LJMP FAILED
	DONE_92:


////////////////  INST 93 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_93:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_93
		MOV  PSW,#0

// RRC A (93)
		MOV  A,#3
		RRC  A
		SUBB A,#0	;A(1)-C(1)-0
		JZ   DONE_93
		MOV  P1,#93
		LJMP FAILED
	DONE_93:

////////////////  INST 94 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_94:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_94
		MOV  PSW,#0

// SETB C (94)
		SETB C
		MOV  A,#1
		SUBB A,#0	;A(1)-C(1)-0
		JZ   DONE_94
		MOV  P1,#94
		LJMP FAILED
	DONE_94:

////////////////  INST 95 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_95:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_95
		MOV  PSW,#0

// SETB bit (95)
		SETB ACC.7
		SUBB A,#128
		JZ   DONE_95
		MOV  P1,#95
		LJMP FAILED
	DONE_95:

////////////////  INST 96 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_96:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_96
		MOV  PSW,#0

// SJMP (96)
		SJMP DONE_96
		MOV  P1,#96
		LJMP FAILED
	DONE_96:

////////////////  INST 97 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_97:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_97
		MOV  PSW,#0

// SUBB A,Rn (97)
		MOV  A,#10
		MOV  R0,#10
		SUBB A,R0
		JZ   DONE_97
		MOV  P1,#97
		LJMP FAILED
	DONE_97:

////////////////  INST 98 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_98:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_98
		MOV  PSW,#0

// SUBB A,direct (98)
		MOV  A,#10
		MOV  127,#10
		SUBB A,127
		JZ   DONE_98
		MOV  P1,#98
		LJMP FAILED
	DONE_98:  

////////////////  INST 99 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_99:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_99
		MOV  PSW,#0

// SUBB A,@Ri (99)
		MOV  A,#10
		MOV  R0,#127
		MOV  127,#10
		SUBB A,@R0
		JZ   DONE_99
		MOV  P1,#99
		LJMP FAILED
	DONE_99:


//////////////// INST 100 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_100:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_100
		MOV  PSW,#0

// SUBB A,#data (100)
		MOV  A,#10
		SUBB A,#10
		JZ   DONE_100
		MOV  P1,#100
		LJMP FAILED
	DONE_100:  

//////////////// INST 101 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_101:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_101
		MOV  PSW,#0

// SWAP A (101)
		MOV  A,#23H
		SWAP A
		SUBB A,#32H
		JZ   DONE_101
		MOV  P1,#101
		LJMP FAILED
	DONE_101:  

//////////////// INST 102 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_102:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_102
		MOV  PSW,#0

// XCH A,Rn (102)
		MOV  A,#10
		MOV  R0,#99
		XCH  A,R0
		SUBB A,#99
		JNZ  ERROR_102
		MOV  A,R0
		SUBB A,#10
		JZ   DONE_102
	ERROR_102:
		MOV  P1,#102
		LJMP FAILED
	DONE_102:

//////////////// INST 103 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_103:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_103
		MOV  PSW,#0

// XCH A,direct (103)
		MOV  A,#10
		MOV  127,#99
		XCH  A,127
		SUBB A,#99
		JNZ  ERROR_103
		MOV  A,127
		SUBB A,#10
		JZ   DONE_103
	ERROR_103:
		MOV  P1,#103
		LJMP FAILED
	DONE_103:  

//////////////// INST 104 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_104:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_104
		MOV  PSW,#0

// XCH A,@Ri (104)
		MOV  A,#10
		MOV  R0,#127
		MOV  127,#99
		XCH  A,@R0
		SUBB A,#99
		JNZ  ERROR_104
		MOV  A,127
		SUBB A,#10
		JZ   DONE_104
	ERROR_104:
		MOV  P1,#104
		LJMP FAILED
	DONE_104:

//////////////// INST 105 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_105:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_105
		MOV  PSW,#0

// XCHD A,@Ri (105)
		MOV  A,#44H
		MOV  R0,#127
		MOV  127,#55H
		XCHD A,@R0
		SUBB A,#45H
		JNZ  ERROR_105
		MOV  A,127
		SUBB A,#54H
		JZ   DONE_105
	ERROR_105:
		MOV  P1,#105
		LJMP FAILED
	DONE_105:


//////////////// INST 106 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_106:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_106
		MOV  PSW,#0

// XRL A,Rn (106)
		MOV  A,#35H
		MOV  R0,#53H
		XRL  A,R0
		SUBB A,#66H
		JZ   DONE_106
		MOV  P1,#106
		LJMP FAILED
	DONE_106:

//////////////// INST 107 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_107:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_107
		MOV  PSW,#0

// XRL A,direct (107)
		MOV  A,#53H
		MOV  127,#35H
		XRL  A,127
		SUBB A,#66H
		JZ   DONE_107
		MOV  P1,#107
		LJMP FAILED
	DONE_107:


//////////////// INST 108 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_108:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_108
		MOV  PSW,#0

// XRL A,@Ri (108)
		MOV  A,#35H
		MOV  R0,#127
		MOV  127,#53H
		XRL  A,@R0
		SUBB A,#66H
		JZ   DONE_108
		MOV  P1,#108
		LJMP FAILED
	DONE_108:


//////////////// INST 109 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_109:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_109
		MOV  PSW,#0

// XRL A,#data (109)
		MOV  A,#35H
		XRL  A,#53H
		SUBB A,#66H
		JZ   DONE_109
		MOV  P1,#109
		LJMP FAILED
	DONE_109:


//////////////// INST 110 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_110:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_110
		MOV  PSW,#0

// XRL direct,A (110)
		MOV  A,#35H
		MOV  127,#53H
		XRL  127,A
		CLR  A
		MOV  A,127
		SUBB A,#66H
		JZ   DONE_110
		MOV  P1,#110
		LJMP FAILED
	DONE_110:


//////////////// INST 111 ///////////////////////

	// Clear RAM
		MOV  R0,#128
	RAM_CLR_111:
		DEC  R0
		MOV  @R0,#0
		MOV  A,R0
		JNZ  RAM_CLR_111
		MOV  PSW,#0

// XRL direct,#data (111)
		MOV  127,#35H
		XRL  127,#53H
		MOV  A,127
		SUBB A,#66H
		JZ   DONE_111
		MOV  P1,#111
		LJMP FAILED
	DONE_111:


/////////////////  DONE    //////////////////////

		MOV  P1,#127		; All instructions passed


	FAILED:

	#pragma endasm
		
	while(1);		  
}



