; Program tests all instructions except:
; MOVX(1-4) and RETI

	; Clear RAM
	mov  r0,#128
ram_clr:
	dec  r0
	mov  @r0,#0
	mov  a,r0
	jnz  ram_clr
	mov  PSW,#0

;;;;;;;;;;;;;;;;;   INST 1 ;;;;;;;;;;;;;;;;;;;;;;;

;; acall addr11
	mov  a,#85
	acall testret
	inc  a
	jc   fail1
	subb a,#87
	jz   done1
fail1:
	mov  P1,1
	ljmp failed
done1:

;;;;;;;;;;;;;;;;   INST 2 ;;;;;;;;;;;;;;;;;;;;;;;

;; add a,Rn (2) -- test if ALU and flag setting works
	mov  a,#10
	mov  r0,#117
	mov  r1,#10
	mov  r2,#127
	mov  r3,#128
	mov  r5,#245
	mov  r7,#250

	mov  a,#10
	add  a,r0
	jc   fail2 
	subb a,#127
	jnz  fail2

	mov  a,#10
	add  a,r2
	jc   fail2 
	subb a,#137
	jnz  fail2

	mov  a,#10
	add  a,r3
	jc   fail2 
	subb a,#138
	jnz  fail2

	mov  a,#10
	add  a,r5
	jc   fail2 
	subb a,#255
	jnz  fail2

	mov  a,#10
	add  a,r7
	jnc  fail2
	clr  c
	subb a,#4
	jnz  fail2

	mov  a,#117
	add  a,r1
	jc   fail2 
	subb a,#127
	jnz  fail2

	mov  a,#127
	add  a,r1
	jc   fail2 
	subb a,#137
	jnz  fail2

	mov  a,#128
	add  a,r1
	jc   fail2 
	subb a,#138
	jnz  fail2

	mov  a,#245
	add  a,r1
	jc   fail2 
	subb a,#255
	jnz  fail2

	mov  a,#250
	add  a,r1
	jnc   fail2 
	clr  c
	subb a,#4
	jnz  fail2

	ljmp done2

fail2:
	mov  P1,#2
	ljmp failed
done2:

;;;;;;;;;;;;;;;;   INST 3 ;;;;;;;;;;;;;;;;;;;;;;;

;; add a,direct (3) -- test if ALU and flag setting works

	mov  100,#117
	mov  a,#10
	add  a,100
	jc   fail3
	subb a,#127
	jnz  fail3

	mov  100,#127
	mov  a,#10
	add  a,100
	jc   fail3 
	subb a,#137
	jnz  fail3

	mov  100,#128
	mov  a,#10
	add  a,100
	jc   fail3 
	subb a,#138
	jnz  fail3

	mov  100,#245
	mov  a,#10
	add  a,100
	jc   fail3 
	subb a,#255
	jnz  fail3

	mov  100,#250
	mov  a,#10
	add  a,100
	jnc   fail3 
	clr  c
	subb a,#4
	jnz  fail3

	mov  a,#117
	mov  100,#10
	add  a,100
	jc   fail3 
	subb a,#127
	jnz  fail3

	mov  a,#127
	mov  100,#10
	add  a,100
	jc   fail3
	subb a,#137
	jnz  fail3

	mov  a,#128
	add  a,100
	jc   fail3 
	subb a,#138
	jnz  fail3

	mov  a,#245
	add  a,100
	jc   fail3 
	subb a,#255
	jnz  fail3

	mov  a,#250
	add  a,100
	jnc  fail3 
	clr  c
	subb a,#4
	jnz  fail3

	ljmp done3

fail3:
	jz   done3
	mov  P1,#3
	ljmp failed
done3:

;;;;;;;;;;;;;;;;   INST 4 ;;;;;;;;;;;;;;;;;;;;;;;

;; add a,@Ri (4) -- indexed and simple CY
	mov  a,#40
	mov  r0,#100
	mov  100,#10
	mov  r1,#101
	mov  101,#100

	add  a,@r0
	jc   fail4
	subb a,#50
	jnz  fail4

	mov  a,#40
	add  a,@r1
	jc   fail4
	subb a,#140
	jnz  fail4

	mov  a,#10
	mov  r1,#102
	mov  102,#250
	add  a,@r1
	jnc   fail4
	clr  c
	subb a,#4
	jnz  fail4
	ljmp done4

fail4:
	mov  P1,#4
	ljmp failed
done4:

;;;;;;;;;;;;;;;;   INST 5 ;;;;;;;;;;;;;;;;;;;;;;;

;; add a,#data (5)
	mov  a,#10

	add  a,#117
	jc   fail5
	subb a,#127
	jnz  fail5

	mov  a,#10
	add  a,#127
	jc   fail5
	subb a,#137
	jnz  fail5

	mov  a,#10
	add  a,#128
	jc   fail5 
	subb a,#138
	jnz  fail5

	mov  a,#10
	add  a,#245
	jc   fail5 
	subb a,#255
	jnz  fail5

	mov  a,#10
	add  a,#250
	jnc   fail5 
	clr  c
	subb a,#4
	jnz  fail5

	mov  a,#117
	add  a,#10
	jc   fail5 
	subb a,#127
	jnz  fail5

	mov  a,#127
	add  a,#10
	jc   fail5 
	subb a,#137
	jnz  fail5

	mov  a,#128
	add  a,#10
	jc   fail5 
	subb a,#138
	jnz  fail5

	mov  a,#245
	add  a,#10
	jc   fail5 
	subb a,#255
	jnz  fail5

	mov  a,#250
	add  a,#10
	jnc  fail5 
	clr  c
	subb a,#4
	jnz  fail5

	ljmp done5

fail5:
	jz   done5
	mov  P1,#5
	ljmp failed
	mov  P1,#5
	ljmp failed
done5:

;;;;;;;;;;;;;;;;   INST 6 ;;;;;;;;;;;;;;;;;;;;;;;

;; addc a,Rn (6)
	mov  a,#10
	mov  r0,#10

	clr  c
	addc a,r0
	jc   fail6
	subb a,#20
	jnz  fail6

	mov  a,#10
	setb c
	addc a,r0
	jc   fail6
	subb a,#21
	jnz  fail6

	mov  a,#100
	clr  c
	addc a,r0
	jc   fail6
	subb a,#110
	jnz  fail6

	mov  a,#100
	setb c
	addc a,r0
	jc   fail6
	subb a,#111
	jnz  fail6

	mov  a,#250
	clr  c
	addc a,r0
	jnc  fail6
	clr  c
	subb a,#4
	jnz  fail6

	mov  a,#250
	setb c
	addc a,r0
	jnc  fail6
	clr  c
	subb a,#5
	jnz  fail6

	ljmp done6
fail6:
	mov  P1,#6
	ljmp failed
done6:

;;;;;;;;;;;;;;;;   INST 7 ;;;;;;;;;;;;;;;;;;;;;;;

;; addc a,direct (7)
	mov  a,#10
	mov  100,#10

	clr  c
	addc a,100
	jc   fail7
	subb a,#20
	jnz  fail7

	mov  a,#10
	setb c
	addc a,100
	jc   fail7
	subb a,#21
	jnz  fail7

	mov  a,#100
	clr  c
	addc a,100
	jc   fail7
	subb a,#110
	jnz  fail7

	mov  a,#100
	setb c
	addc a,100
	jc   fail7
	subb a,#111
	jnz  fail7

	mov  a,#250
	clr  c
	addc a,100
	jnc  fail7
	clr  c
	subb a,#4
	jnz  fail7

	mov  a,#250
	setb c
	addc a,100
	jnc  fail7
	clr  c
	subb a,#5
	jnz  fail7

	ljmp done7
fail7:
	mov  P1,#7
	ljmp failed
done7:

;;;;;;;;;;;;;;;;   INST 8 ;;;;;;;;;;;;;;;;;;;;;;;

;; addc a,@Ri (8)
	mov  a,#10
	mov  r0,#100
	mov  100,#11

	clr  c
	addc a,@r0
	jc   fail8
	subb a,#21
	jnz  fail8

	mov  a,#10
	setb c
	addc a,@r0
	jc   fail8
	subb a,#22
	jnz  fail8

	mov  a,#100
	clr  c
	addc a,@r0
	jc   fail8
	subb a,#111
	jnz  fail8

	mov  a,#100
	setb c
	addc a,@r0
	jc   fail8
	subb a,#112
	jnz  fail8

	mov  a,#250
	clr  c
	addc a,@r0
	jnc  fail8
	clr  c
	subb a,#5
	jnz  fail8

	mov  a,#250
	setb c
	addc a,@r0
	jnc  fail8
	clr  c
	subb a,#6
	jnz  fail8

	ljmp done8
fail8:
	mov  P1,#8
	ljmp failed
done8:


;;;;;;;;;;;;;;;;   INST 9 ;;;;;;;;;;;;;;;;;;;;;;;

;; addc a,#data (9)
	mov  a,#14

	clr  c
	addc a,#14
	jc   fail9
	subb a,#28
	jnz  fail9

	mov  a,#14
	setb c
	addc a,#15
	jc   fail9
	subb a,#30
	jnz  fail9

	mov  a,#110
	clr  c
	addc a,#20
	jc   fail9
	subb a,#130
	jnz  fail9

	mov  a,#110
	setb c
	addc a,#20
	jc   fail9
	subb a,#131
	jnz  fail9

	mov  a,#250
	clr  c
	addc a,#11
	jnc  fail9
	clr  c
	subb a,#5
	jnz  fail9

	mov  a,#250
	setb c
	addc a,#11
	jnc  fail9
	clr  c
	subb a,#6
	jnz  fail9

	ljmp done9
fail9:
	mov  P1,#9
	ljmp failed
done9:

;;;;;;;;;;;;;;;;  INST 10 ;;;;;;;;;;;;;;;;;;;;;;;

;; ajmp (10)
	setb c
	ajmp done10
fail10:
	mov  P1,#10
	ljmp failed
done10:clr  c
	jc   fail10

;;;;;;;;;;;;;;;;  INST 11 ;;;;;;;;;;;;;;;;;;;;;;;

;; anl a,Rn (11)
	mov  r0,#250
	clr  c
	clr  a
	mov  a,#171
	anl  a,r0
	jc   fail11
	jz   fail11
	subb a,#170
	jnz  fail11

	mov  r0,#190
	mov  a,#84
	inc  a
	setb c
	anl  a,r0
	jz   fail11
	jnc  fail11
	clr  c
	subb a,#20
	jnz  fail11
	ljmp done11

fail11:
	mov  P1,#11
	ljmp failed
done11:

;;;;;;;;;;;;;;;;  INST 12 ;;;;;;;;;;;;;;;;;;;;;;;

;; anl a,direct (12)
	mov  127,#250
	clr  c
	clr  a
	mov  a,#171
	anl  a,127
	jc   fail12
	jz   fail12
	subb a,#170
	jnz  fail12

	mov  127,#190
	mov  a,#84
	inc  a
	setb c
	anl  a,127
	jz   fail12
	jnc  fail12
	clr  c
	subb a,#20
	jnz  fail12
	ljmp done12

fail12:
	mov  P1,#12
	ljmp failed
done12:

;;;;;;;;;;;;;;;;  INST 13 ;;;;;;;;;;;;;;;;;;;;;;;

;; anl a,@Ri (13)
	mov  r0,#127
	clr  c
	clr  a
	mov  127,#171
	mov  a,#250
	anl  a,@r0
	jc   fail13
	jz   fail13
	subb a,#170
	jnz  fail13

	mov  127,#190
	mov  a,#84
	inc  a
	setb c
	anl  a,@r0
	jz   fail13
	jnc  fail13
	clr  c
	subb a,#20
	jnz  fail13
	ljmp done13

fail13:
	anl  a,@r0
	jz   done13
	mov  P1,#13
	ljmp failed
done13:

;;;;;;;;;;;;;;;;  INST 14 ;;;;;;;;;;;;;;;;;;;;;;;

;; anl a,#data (14)
	clr  c
	clr  a
	mov  a,#250
	anl  a,#171
	jc   fail14
	jz   fail14
	subb a,#170
	jnz  fail14

	mov  a,#190
	mov  a,#84
	inc  a
	setb c
	anl  a,@r0
	jz   fail14
	jnc  fail14
	clr  c
	subb a,#20
	jnz  fail14
	ljmp done14

fail14:
	subb a,#255
	jz   done14
	mov  P1,#14
	ljmp failed
done14:

;;;;;;;;;;;;;;;;  INST 15 ;;;;;;;;;;;;;;;;;;;;;;;

;; anl direct,a (15)
	mov  127,#250
	clr  c
	clr  a
	mov  a,#171
	anl  127,a
	jc   fail15
	mov  a,127
	jz   fail15
	subb a,#170
	jnz  fail15

	mov  127,#190
	mov  a,#84
	inc  a
	setb c
	anl  127,a
	mov  a,127
	jz   fail15
	jnc  fail15
	clr  c
	subb a,#20
	jnz  fail15
	ljmp done15

fail15:
	mov  P1,#15
	ljmp failed
done15:

;;;;;;;;;;;;;;;;  INST 16 ;;;;;;;;;;;;;;;;;;;;;;;

;; anl direct,#data (16)
	mov  127,#250
	clr  c
	clr  a
	anl  127,#171
	jc   fail16
	mov  a,127
	jz   fail16
	subb a,#170
	jnz  fail16

	mov  127,#190
	setb c
	anl  127,#85
	mov  a,127
	jz   fail16
	jnc  fail16
	clr  c
	subb a,#20
	jnz  fail16
	ljmp done16

fail16:
	mov  P1,#16
	ljmp failed
done16:

;;;;;;;;;;;;;;;;  INST 17 ;;;;;;;;;;;;;;;;;;;;;;;

;; anl c,bit (17)
	mov  a,#128
	clr  c
	anl  c,acc.7
	jc   fail17
	mov  a,#128
	setb c
	anl  c,acc.7
	jnc  fail17
	ljmp done17

fail17: 
	mov  P1,#17
	ljmp failed
done17:

;;;;;;;;;;;;;;;;  INST 18 ;;;;;;;;;;;;;;;;;;;;;;;

;; anl c,/bit (18)
	mov  a,#128
	clr  c
	anl  c,/acc.7
	jc   fail18
	mov  a,#128
	setb c
	anl  c,/acc.7
	jc   fail18
	mov  a,#128
	setb c
	anl  c,/acc.5
	jnc  fail18
	ljmp done18

fail18:
	mov  P1,#18
	ljmp failed
done18:

;;;;;;;;;;;;;;;;  INST 19 ;;;;;;;;;;;;;;;;;;;;;;;

;; cjne a,direct,rel (19)
	mov  a,#228
	mov  100,#228
	cjne a,100,fail19
	jc   fail19

	mov  a,#227
	cjne a,100,CHECK_C_19
	ljmp fail19
CHECK_C_19:	;Checks that carry was set
	jnc  fail19
 
	mov  a,#229
	cjne a,100,CHECK_NC_19
	ljmp fail19

CHECK_NC_19:	;Checks that carry was not set
	jc   fail19
	ljmp done19

fail19:
	mov  P1,#19
	ljmp failed
done19:
	
;;;;;;;;;;;;;;;;  INST 20 ;;;;;;;;;;;;;;;;;;;;;;;

;; cjne a,#data,rel (20)
	mov  a,#100
	cjne a,#100,fail20
	jc   fail20

	mov  a,#99
	cjne a,#100,CHECK_C_20
	ljmp fail20
CHECK_C_20:	;Checks that carry was set
	jnc  fail20
 
	mov  a,#101
	cjne a,#100,CHECK_NC_20
	ljmp fail20

CHECK_NC_20:	;Checks that carry was not set
	jc   fail20
	ljmp done20

fail20:
	mov  P1,#20
	ljmp failed
done20:

;;;;;;;;;;;;;;;;  INST 21 ;;;;;;;;;;;;;;;;;;;;;;;

;; cjne Rn,#data,rel (21)
	mov  r1,#100
	cjne r1,#100,fail21
	jc   fail21

	mov  r1,#99
	cjne r1,#100,CHECK_C_21
	ljmp fail21
CHECK_C_21:	;Checks that carry was set
	jnc  fail21
 
	mov  r1,#101
	cjne r1,#100,CHECK_NC_21
	ljmp fail21

CHECK_NC_21:	;Checks that carry was not set
	jc   fail21
	ljmp done21

fail21:
	mov  P1,#21
	ljmp failed
done21:

;;;;;;;;;;;;;;;;  INST 22 ;;;;;;;;;;;;;;;;;;;;;;;

;; cjne @Ri,#data,rel (22)
	mov  125,#99
	mov  126,#100
	mov  127,#101
	mov  r1,#125
	cjne @r1,#100, CHECK_EQ_22
  ljmp fail22

CHECK_EQ_22:
	jnc  fail22
	mov  r1,#126
	cjne @r1,#100,fail22
	jc   fail22
 
	mov  r1,#127
	cjne @r1,#100,CHECK_NC_22
	ljmp fail22

CHECK_NC_22:	;Checks that carry was not set
	jc   fail22
	ljmp done22

fail22:
	mov  P1,#22
	ljmp failed
done22:

;;;;;;;;;;;;;;;;  INST 23 ;;;;;;;;;;;;;;;;;;;;;;;

;; clr a (23)
	mov  a,#86
	clr  a
	jnz  fail23
	mov  a,#86
	clr  a
	mov  r0,a
	mov  a,r0
	jnz  fail23
	ljmp done23

fail23:
	mov  P1,#23
	ljmp failed
done23:

;;;;;;;;;;;;;;;;  INST 24 ;;;;;;;;;;;;;;;;;;;;;;;

;; clr c (24)
	setb c
	clr  c
	jc   fail24
	clr  c
	jc   fail24
	ljmp done24

fail24:
	mov  P1,#24
	ljmp failed
done24:

;;;;;;;;;;;;;;;;  INST 25 ;;;;;;;;;;;;;;;;;;;;;;;

;; clr bit (25)
	mov  a, #02h
	jz   fail25
	clr  acc.1
	jnz   fail25

	setb 7
        mov  c, 7
        jc clr1;
        ljmp fail25;
clr1:
	clr  7
        mov  c, 7
	jc   fail25
	clr  7
        mov  c, 7
	jc   fail25
	ljmp done25

fail25:
	mov  P1,#25
	ljmp failed
done25:

;;;;;;;;;;;;;;;;  INST 26 ;;;;;;;;;;;;;;;;;;;;;;;

;; cpl a (26)
	mov  a,#255
	cpl  a
	jnz  fail26

	mov  a,#85
	cpl  a
	clr  c
	subb a,#170
	jnz  fail26
	ljmp done26

fail26:
	mov  P1,#26
	ljmp failed
done26:

;;;;;;;;;;;;;;;;  INST 27 ;;;;;;;;;;;;;;;;;;;;;;;

;; cpl c (27)
	setb c
	cpl  c
	jc   fail27
	clr  c
	cpl  c
	jnc  fail27
	ljmp done27

fail27:
	mov  P1,#27
	ljmp failed
done27:

;;;;;;;;;;;;;;;;  INST 28 ;;;;;;;;;;;;;;;;;;;;;;;

;; cpl bit (28)
	clr  a
	setb acc.5
	cpl  acc.5
	jnz  fail28
	clr  acc.5
	cpl  acc.5
	jz   fail28
	ljmp done28

fail28:
	mov  P1,#28
	ljmp failed
done28:

;;;;;;;;;;;;;;;;  INST 29 ;;;;;;;;;;;;;;;;;;;;;;;

;; DA a (29)
	mov  a,#80h
	add  a,#99h
	da   a
	subb a,#78h	;Will clr acc if c set
	jz   tst2

fail_da:
	mov  P1,#29
	ljmp failed
tst2:
	mov psw, #00h
	mov r3, #67h
	mov a, #56h
	addc a, r3
	da  a
	subb a, #24h
	jnz fail_da

	mov psw, #00h
	mov a, #30h
	addc a, #99h
	da  a
	subb a, #28h
	jnz fail_da


done29:


;;;;;;;;;;;;;;;;;  INST 30 ;;;;;;;;;;;;;;;;;;;;;;

;; dec a (30)
	mov  a,#10
	setb c
	dec  a
	jnc  fail30
	clr  c
	subb a,#9
	jnz  fail30

	mov  a,#0
	clr  c
	dec  a
	jc   fail30
	subb a,#255
	jnz  fail30
	ljmp done30

fail30:
	mov  P1,#30
	ljmp failed
done30:  

;;;;;;;;;;;;;;;;;  INST 31 ;;;;;;;;;;;;;;;;;;;;;;

;; dec Rn (31)
	mov  r2,#10
	setb c
	dec  r2
	jnc  fail31
	clr  c
	mov  a,r2
	subb a,#9
	jnz  fail31

	mov  r2,#0
	clr  c
	dec  r2
	jc   fail31
	mov  a,r2
	subb a,#255
	jnz  fail31
	ljmp done31

fail31:
	mov  P1,#31
	ljmp failed
done31:  

;;;;;;;;;;;;;;;;;  INST 32 ;;;;;;;;;;;;;;;;;;;;;;

;; dec direct (32)
	mov  127,#10
	setb c
	dec  127
	jnc  fail32
	clr  c
	mov  a,127
	subb a,#9
	jnz  fail32

	mov  127,#0
	clr  c
	dec  127
	jc   fail32
	mov  a,127
	subb a,#255
	jnz  fail32
	ljmp done32

fail32:
	mov  P1,#32
	ljmp failed
done32:
  
;;;;;;;;;;;;;;;;;  INST 33 ;;;;;;;;;;;;;;;;;;;;;;

;; dec @Ri (33)
	mov  r0,#127
	mov  @r0,#10
	setb c
	dec  @r0
	jnc  fail33
	clr  c
	mov  a,@r0
	subb a,#9
	jnz  fail33

	mov  @r0,#0
	clr  c
	dec  @r0
	jc   fail33
	mov  a,@r0
	subb a,#255
	jnz  fail33
	ljmp done33

fail33:
	mov  P1,#33
	ljmp failed
done33:  


;;;;;;;;;;;;;;;;;  INST 34 ;;;;;;;;;;;;;;;;;;;;;;

;; div AB (34)
	mov  a,#251
	mov  B,#18
	div  AB
	jc   fail34
	mov  c,OV 
	jc   fail34
	subb a,#13
	jnz  fail34
	mov  a,B
	subb a,#17
	jnz  fail34

	mov  a,#180
	mov  B,#15
	div  AB
	jc   fail34
	mov  c,OV 
	jc   fail34
	subb a,#12
	jnz  fail34
	mov  a,B
	jnz  fail34

	mov  a,#0
	mov  B,#15
	div  AB
	jc   fail34
	mov  c,OV 
	jc   fail34
	jnz  fail34
	mov  a,B
	subb a,#15

	mov  a,#0
	mov  B,#0
	div  AB
	jc   fail34
	mov  c,OV 
	jnc  fail34

	mov  a,#170
	mov  B,#0
	div  AB
	jc   fail34
	mov  c,OV 
	jnc  fail34
	ljmp done34
fail34:
	mov  P1,#34
	ljmp failed
done34:


;;;;;;;;;;;;;;;;;  INST 35 ;;;;;;;;;;;;;;;;;;;;;;

;; djnz Rn,rel (35)
	mov  r0,#10
	djnz r0,JUMP_35	;Should jump
	mov  P1,#35
	ljmp failed
JUMP_35:
	mov  r0,#0
	djnz r0,JUMP_35B	;Should jump
	mov  P1,#35
	ljmp failed
JUMP_35B:
	mov  r0,#1
	djnz r0,NOT_JUMP_35	;Should not jump
	ajmp done35
NOT_JUMP_35:
	mov  P1,#35
	ljmp failed
done35:  

;;;;;;;;;;;;;;;;;  INST 36 ;;;;;;;;;;;;;;;;;;;;;;

;; djnz direct,rel (36)
	mov  127,#10
	djnz 127,JUMP_36	;Should jump
	mov  P1,#36
	ljmp failed
JUMP_36:
	mov  127,#0
	djnz 127,JUMP_36B	;Should jump
	mov  P1,#36
	ljmp failed
JUMP_36B:
	mov  127,#1
	djnz 127,NOT_JUMP_36	;Should not jump
	ajmp done36
NOT_JUMP_36:
	mov  P1,#36
	ljmp failed

done86:

;;;;;;;;;;;;;;;;  INST 88 ;;;;;;;;;;;;;;;;;;;;;;;

	ljmp done88
	clr  a
testret:	     ;; subroutine called from acall and lcall
	inc  a
	ret
	clr  a

done36:  

;;;;;;;;;;;;;;;;;  INST 37 ;;;;;;;;;;;;;;;;;;;;;;
	
;; inc a (37)
	mov  a,#10
	clr  c
	inc  a
	jc   fail37
	subb a,#11
	jnz  fail37

	mov  a,#255
	setb c
	inc  a
	jnc  fail37
	jnz  fail37
	ljmp done37

fail37:
	mov  P1,#37
	ljmp failed
done37:  

;;;;;;;;;;;;;;;;;  INST 38 ;;;;;;;;;;;;;;;;;;;;;;

;; inc Rn (38)
	mov  r3,#10
	clr  c
	inc  r3
	jc   fail38
	mov  a,r3
	subb a,#11
	jnz  fail38

	mov  r4,#255
	setb c
	inc  r4
	jnc  fail38
	mov  a,r4
	jnz  fail38
	ljmp done38

fail38:
	mov  P1,#38
	ljmp failed
done38:  

;;;;;;;;;;;;;;;;;  INST 39 ;;;;;;;;;;;;;;;;;;;;;;
	
;; inc direct (39)
	mov  127,#10
	clr  c
	inc  127
	jc   fail39
	mov  a,127
	subb a,#11
	jnz  fail39

	mov  127,#255
	setb c
	inc  127
	jnc  fail39
	mov  a,127
	jnz  fail39
	ljmp done39

fail39:
	mov  P1,#39
	ljmp failed
done39:

;;;;;;;;;;;;;;;;;  INST 40 ;;;;;;;;;;;;;;;;;;;;;;
	
;; inc @Ri (40)
	mov  r1,#126
	mov  @r1,#10
	clr  c
	inc  @r1
	jc   fail40
	mov  a,@r1
	subb a,#11
	jnz  fail40

	mov  @r1,#255
	setb c
	inc  @r1
	jnc  fail40
	mov  a,@r1
	jnz  fail40
	ljmp done40

fail40:
	mov  P1,#40
	ljmp failed
done40:  


;;;;;;;;;;;;;;;;;  INST 41 ;;;;;;;;;;;;;;;;;;;;;;

;; inc dptr (41)
  clr  c;
	mov  dptr,#12ffh
	inc  dptr
	mov  a,DPH
	subb a,#13h
	jz   DPH_OK_41
	mov  P1,#41
	ljmp failed
DPH_OK_41:
	mov  a,DPL
	jz   done41
	mov  P1,#41
	ljmp failed
done41:  


;;;;;;;;;;;;;;;;;  INST 42 ;;;;;;;;;;;;;;;;;;;;;;
	
;; JB bit,rel (42)
	mov  a,#16
	jb   acc.3,fail42
	jb   acc.4,done42

fail42:
	mov  P1,#42
	ljmp failed
done42:


;;;;;;;;;;;;;;;;;  INST 43 ;;;;;;;;;;;;;;;;;;;;;;
	
;; jbc bit,rel (43)
	mov  a,#8
	jbc  acc.3,CHECK_BIT_43
	mov  P1,#43
	ljmp failed
CHECK_BIT_43:
	jz   done43
	mov  P1,#43
	ljmp failed
done43:

;;;;;;;;;;;;;;;;;  INST 44 ;;;;;;;;;;;;;;;;;;;;;;
	
;; jc rel (44)
	clr  c
	jc   fail44
	cpl  c
	jc   done44
fail44:
	mov  P1,#44
	ljmp failed
done44:

;;;;;;;;;;;;;;;;;  INST 45 ;;;;;;;;;;;;;;;;;;;;;;
	
;; jmp @a+dptr (45)
	mov  a,#4
	mov  dptr,#JMP_TBL
	jmp  @a+dptr
JMP_TBL:
	ajmp JUMP_0
	ajmp JUMP_2
	ajmp JUMP_4
	ajmp JUMP_6
JUMP_0:
JUMP_2:
JUMP_6:
	mov  P1,#43
	ljmp failed
JUMP_4:

;;;;;;;;;;;;;;;;;  INST 46 ;;;;;;;;;;;;;;;;;;;;;;

;; jnb bit,rel (46)
	mov  a,#16
	jnb  acc.4,fail42
	jnb  acc.5,done46
fail46:
	mov  P1,#46
	ljmp failed
done46:

;;;;;;;;;;;;;;;;;  INST 47 ;;;;;;;;;;;;;;;;;;;;;;
	
;; jnc rel (47)
	setb c
	jnc  fail47
	cpl  c
	jnc  done47
fail47:
	mov  P1,#47
	ljmp failed



done47:

;;;;;;;;;;;;;;;;;  INST 48 ;;;;;;;;;;;;;;;;;;;;;;
	
;; jnz rel (48)
	mov  r1,#0
	mov  a,0
	inc  r1
	jnz  fail48

	mov  a,#1
	dec  r1
	jnz  done48
fail48:
	mov  P1,#48
	ljmp failed
done48:

;;;;;;;;;;;;;;;;;  INST 49 ;;;;;;;;;;;;;;;;;;;;;;
	
;; jz rel (49)
	mov  r1,1
	mov  a,#2
	dec  r1
	jz   fail49

	mov  a,#0
	inc  r1
	jz   done49
fail49:
	mov  P1,#49
	ljmp failed
done49:

;;;;;;;;;;;;;;;;   INST 50 ;;;;;;;;;;;;;;;;;;;;;;

;; lcall addr11
	mov  a,#85
	lcall testret
	inc  a
	jc   fail50
	subb a,#87
	jz   done50
fail50:
	mov  P1,1
	ljmp failed
done50:
;;;;;;;;;;;;;;;;;  INST 51 ;;;;;;;;;;;;;;;;;;;;;;

;; ljmp (51)
	ljmp done51
	mov  P1,#51
	ljmp failed
done51:

;;;;;;;;;;;;;;;;;  INST 52 ;;;;;;;;;;;;;;;;;;;;;;

;; mov a,Rn (52)
	mov  r0,#10
	clr  a
	setb c
	mov  a,r0
	jnc  fail52
  clr  c
	subb a,#10
	jz   done52
fail52:
	mov  P1,#52
	ljmp failed
done52:  


;;;;;;;;;;;;;;;;;  INST 53 ;;;;;;;;;;;;;;;;;;;;;;

;; mov a,direct (53)
	mov  127,#10
	clr  a
	setb c
	mov  a,127
	jnc  fail53
  clr  c
	subb a,#10
	jz   done53
fail53:
	mov  P1,#53
	ljmp failed
done53:  

;;;;;;;;;;;;;;;;;  INST 54 ;;;;;;;;;;;;;;;;;;;;;;

;; mov a,@Ri (54)
	mov  r0,#127
	mov  127,#10
	clr  a
	setb c
	mov  a,@r0
	jnc  fail54
  clr  c
	subb a,#10
	jz   done54
fail54:
	mov  P1,#54
	ljmp failed
done54:  


;;;;;;;;;;;;;;;;;  INST 55 ;;;;;;;;;;;;;;;;;;;;;;

;; mov a,#data (55)
	clr  a
	setb c
	mov  a,#10
	jnc  fail55
  clr  c
	subb a,#10
	jz   done55
fail55:
	mov  P1,#55
	ljmp failed
done55:  

;;;;;;;;;;;;;;;;;  INST 56 ;;;;;;;;;;;;;;;;;;;;;;

;; mov Rn,a (56)
	mov  a,#10
	mov  r0,#0
	setb c
	mov  r0,a
	jnc  fail56
	clr  a
	mov  a,r0
  clr  c
	subb a,#10
	jz   done56
fail56:
	mov  P1,#56
	ljmp failed
done56:  

;;;;;;;;;;;;;;;;;  INST 57 ;;;;;;;;;;;;;;;;;;;;;;

;; mov Rn,direct (57)
	mov  127,#10
	mov  r0,#0
	setb c
	mov  r0,127
	jnc  fail57
	mov  a,r0
  clr  c
	subb a,#10
	jz   done57
fail57:
	mov  P1,#57
	ljmp failed
done57:  

;;;;;;;;;;;;;;;;;  INST 58 ;;;;;;;;;;;;;;;;;;;;;;

;; mov Rn,#data (58)
	mov  r0,#0
	clr  a
	setb c
	mov  r0,#10
	jnc  fail58
	mov  a,r0
  clr  c
	subb a,#10
	jz   done58
fail58:
	mov  P1,#58
	ljmp failed
done58:  

;;;;;;;;;;;;;;;;;  INST 59 ;;;;;;;;;;;;;;;;;;;;;;

;; mov direct,a (59)
	mov  a,#10
	clr  127
	setb c
	mov  127,a
	jnc  fail59
	clr  a
	mov  a,127
  clr  c
	subb a,#10
	jz   done59
fail59:
	mov  P1,#59
	ljmp failed
done59:  

;;;;;;;;;;;;;;;;;  INST 60 ;;;;;;;;;;;;;;;;;;;;;;

;; mov direct,Rn (60)
	mov  r0,#10
	clr  127
	setb c
	clr  a
	mov  127,r0
	jnz  fail60
	jnc  fail60
	mov  a,127
  clr  c
	subb a,#10
	jz   done60
fail60:
	mov  P1,#60
	ljmp failed
done60:  

;;;;;;;;;;;;;;;;;  INST 61 ;;;;;;;;;;;;;;;;;;;;;;

;; mov direct,direct (61)
	mov  127,#10
	clr  126
	clr  a
	setb c
	mov  126,127
	jnz  fail61
	jnc  fail61
	mov  a,126
  clr  c
	subb a,#10
	jz   done61
fail61:
	mov  P1,#61
	ljmp failed
done61:  

;;;;;;;;;;;;;;;;;  INST 62 ;;;;;;;;;;;;;;;;;;;;;;

;; mov direct,@Ri (62)
	mov  127,#10
	mov  r0,#127
	clr  126
	clr  a
	setb c
	mov  126,@r0
	jnz  fail62
	jnc  fail62
	mov  a,126
  clr  c
	subb a,#10
	jz   done62
fail62:
	mov  P1,#62
	ljmp failed
done62:  

;;;;;;;;;;;;;;;;;  INST 63 ;;;;;;;;;;;;;;;;;;;;;;

;; mov direct,#data (63)
	clr  127
	clr  a
	setb c
	mov  127,#10
	jnz  fail63
	jnc  fail63
	mov  a,127
  clr  c
	subb a,#10
	jz   done63
fail63:
	mov  P1,#63
	ljmp failed
done63:  

;;;;;;;;;;;;;;;;;  INST 64 ;;;;;;;;;;;;;;;;;;;;;;

;; mov @Ri,a (64)
	mov  a,#10
	mov  r0,#127
	mov  @r0,#0
	setb c
	mov  @r0,a
	jnc  fail64
	clr  a
	mov  a,127
  clr  c
	subb a,#10
	jz   done64
fail64:
	mov  P1,#64
	ljmp failed
done64:  

;;;;;;;;;;;;;;;;;  INST 65 ;;;;;;;;;;;;;;;;;;;;;;

;; mov @Ri,direct (65)
	mov  127,#10
	mov  r0,#126
	mov  @r0,#0
	clr  a
	setb c
	mov  @r0,127
	jnc  fail65
	jnz  fail65
	mov  a,126
  clr  c
	subb a,#10
	jz   done65
fail65:
	mov  P1,#65
	ljmp failed
done65:  

;;;;;;;;;;;;;;;;;  INST 66 ;;;;;;;;;;;;;;;;;;;;;;

;; mov @Ri,#data (66)
	mov  r0,#127
	mov  @r0,#0
	clr  a
	setb c
	mov  @r0,#10
	jnz  fail66
	jnc  fail66
	mov  a,127
  clr  c
	subb a,#10
	jz   done66
fail66:
	mov  P1,#66
	ljmp failed
done66:  

;;;;;;;;;;;;;;;;;  INST 67 ;;;;;;;;;;;;;;;;;;;;;;

;; mov c,bit (67)
	mov  a,#1
	clr  c
	mov  c,acc.0
	jnc  fail67
	setb c
	mov  c,acc.1
	jnc  done67
fail67:
	mov  P1,#67
	ljmp failed
done67:  

;;;;;;;;;;;;;;;;;  INST 68 ;;;;;;;;;;;;;;;;;;;;;;

;; mov bit,c (68)
	setb c
	mov  acc.0,c
	cpl  c
	subb a,#1
	jz   done68
	mov  P1,#68
	ljmp failed
done68:  

;;;;;;;;;;;;;;;;;  INST 69 ;;;;;;;;;;;;;;;;;;;;;;

;; mov dptr,#data (69)
	mov  dptr,#1234h
	mov  a,DPH
	subb a,#12h
	jnz  fail69
	mov  a,DPL
	subb a,#34h
	jz   done69
fail69:
	mov  P1,#69
	ljmp failed
done69:


;;;;;;;;;;;;;;;;;  INST 70 ;;;;;;;;;;;;;;;;;;;;;;

;; movc a,@a+dptr (70)
	clr  a
	mov  dptr,#DB_TBL
	movc a,@a+dptr
	subb a,#66h
	jnz  fail70
	mov  a,#1
	movc a,@a+dptr
	subb a,#77h
	jz   done70
	jnz  fail70
DB_TBL:
	db   66h
	db   77h
fail70:	
	mov  P1,#70
	ljmp failed
done70:


;;;;;;;;;;;;;;;;;  INST 71 ;;;;;;;;;;;;;;;;;;;;;;

;; movc a,@a+PC (71)
	mov  a,#13
	movc a,@a+pc
	subb a,#66h
	jnz  fail71
	mov  a,#7
	movc a,@a+pc
	subb a,#77h
	jz   done71
	jnz  fail71
	db   66h
	db   77h
fail71:	
	mov  P1,#71
	ljmp failed
done71:


;;;;;;;;;;;;;;;;  INST 76 ;;;;;;;;;;;;;;;;;;;;;;;

;; mul AB (76)
	mov  a,#80
	mov  B,#160
	mul  AB	; = 3200h
	jc   fail76
	jnz  fail76
  mov  c, ov
  jnc  fail76
	mov  a,B
	clr  c
	subb a,#32h
	jnz  fail76

	mov  a,#111
	mov  B,#87
	mul  AB	; = 25b9h
	jc   fail76
  mov  c, ov
  jnc  fail76

	clr  c
	subb a,#0b9h
	jnz  fail76
	mov  a,B
	subb a,#25h
	jnz  fail76

	mov  a,#11
	mov  B,#17
	mul  AB	; = 00BBh
	jc   fail76
  mov  c, ov 
  jc   fail76
	clr  c
	subb a,#0bbh
	jnz  fail76
	mov  a,B
	jnz  fail76
	ljmp done76

fail76:	
	mov  P1,#76
	ljmp failed
done76:  

;;;;;;;;;;;;;;;;  INST 77 ;;;;;;;;;;;;;;;;;;;;;;;

;; nop
	mov  a,#85
	setb c
	nop
	jnc  fail77
	subb a,#84
	jnz  fail77

	mov  a,#123
	clr  c
	nop
	jc   fail77
	subb a,#123
	jz   done77
fail77:
	mov  P1,#77
	ljmp failed
done77:
	

;;;;;;;;;;;;;;;;  INST 78 ;;;;;;;;;;;;;;;;;;;;;;;

;; orl a,Rn (78)
	mov  a,#90h
	mov  r0,#09h
	setb c
	orl  a,r0
	jnc  fail78
	clr  c
	subb a,#99h
	jnz  fail78

	mov  a,#48h
	mov  r0,#19h
	clr  c
	orl  a,r0
	jc   fail78
	subb a,#59h
	jz   done78
fail78:
	mov  P1,#78
	ljmp failed
done78:

;;;;;;;;;;;;;;;;  INST 79 ;;;;;;;;;;;;;;;;;;;;;;;

;; orl a,direct (79)
	mov  a,#90h
	mov  127,#09h
	setb c
	orl  a,127
	jnc  fail79
	clr  c
	subb a,#99h
	jnz  fail79

	mov  a,#48h
	mov  127,#19h
	clr  c
	orl  a,127
	jc   fail79
	subb a,#59h
	jz   done79
fail79:
	mov  P1,#79
	ljmp failed
done79:

;;;;;;;;;;;;;;;;  INST 80 ;;;;;;;;;;;;;;;;;;;;;;;
;; orl a,@Ri (80)
	mov  a,#90h
	mov  r1,#127
	mov  @r1,#09h
	setb c
	orl  a,@r1
	jnc  fail80
	clr  c
	subb a,#99h
	jnz  fail80

	mov  a,#48h
	mov  @r1,#19h
	clr  c
	orl  a,@r1
	jc   fail80
	subb a,#59h
	jz   done80
fail80:
	mov  P1,#80
	ljmp failed
done80:

;;;;;;;;;;;;;;;;  INST 81 ;;;;;;;;;;;;;;;;;;;;;;;

;; orl a,#data (81)
	mov  a,#90h
	setb c
	orl  a,#09h
	jnc  fail81
	clr  c
	subb a,#99h
	jnz  fail81

	mov  a,#48h
	clr  c
	orl  a,#19h
	jc   fail81
	subb a,#59h
	jz   done81
fail81:
	mov  P1,#81
	ljmp failed
done81:

;;;;;;;;;;;;;;;;  INST 82 ;;;;;;;;;;;;;;;;;;;;;;;

;; orl direct,a (82)
	mov  a,#90h
	mov  127,#09h
	setb c
	orl  127,a
	jnc  fail82
	clr  c
	subb a,#90h
	jnz  fail82
	mov  a,127
	clr  c
	subb a,#99h
	jnz  fail82

	mov  a,#48h
	mov  127,#19h
	clr  c
	orl  127,a
	jc   fail82
	subb a,#48h
	jnz  fail82
	mov  a,127
	clr  c
	subb a,#59h
	jz   done82
fail82:
	mov  P1,#82
	ljmp failed
done82:

;;;;;;;;;;;;;;;;  INST 83 ;;;;;;;;;;;;;;;;;;;;;;;
;; orl direct,#data (83)
	mov  a,#91h
	mov  127,#09h
	setb c
	orl  127,#90h
	jnc  fail83
	clr  c
	subb a,#91h
	jnz  fail83
	mov  a,127
	clr  c
	subb a,#99h
	jnz  fail83

	mov  a,#49h
	mov  127,#19h
	clr  c
	orl  127,#48h
	jc   fail83
	subb a,#49h
	jnz  fail83
	mov  a,127
	clr  c
	subb a,#59h
	jz   done83
fail83:
	mov  P1,#83
	ljmp failed
done83:

;;;;;;;;;;;;;;;;  INST 84 ;;;;;;;;;;;;;;;;;;;;;;;

;; orl c,bit (84)
	mov  a,#1
	orl  c,acc.1
	jc   fail84
	orl  c,acc.0
	jnc  fail84
	orl  c,acc.1
	jc   done84
fail84:
	mov  P1,#84
	ljmp failed
done84:

;;;;;;;;;;;;;;;;  INST 85 ;;;;;;;;;;;;;;;;;;;;;;;

;; orl c,/bit (85)
	mov  a,#1
  clr  c
	orl  c,/acc.0
	jc   fail85
	orl  c,/acc.1
	jnc  fail85
  setb c
	orl  c,/acc.0
	jc   done85
fail85:
	mov  P1,#85
	ljmp failed
done85:

;;;;;;;;;;;;;;;;  INST 86,87 ;;;;;;;;;;;;;;;;;;;;;;;

;; push direct (87)
  clr  c
	mov  dptr,#0123h
	mov  127,#8
	push DPL
	push DPH
	push 127
	mov  a,8
	subb a,#23h
	jnz  fail87
	mov  a,9
	subb a,#1
	jnz fail87
	mov  a,10
	subb a,#8
	jz   done87
fail87:
	mov  P1,#87
	ljmp failed
done87:

;; pop direct (86)
	pop  SP
	pop  100
	mov  a,100
	subb a,#23h
	jz   done88
	mov  P1,#86
	ljmp failed

done88:

;;;;;;;;;;;;;;;;  INST 90 ;;;;;;;;;;;;;;;;;;;;;;;

;; rl a (90)
	mov  a,#129
	rl   a
	subb a,#3
	jz   done90
	mov  P1,#90
	ljmp failed
done90:

;;;;;;;;;;;;;;;;  INST 91 ;;;;;;;;;;;;;;;;;;;;;;;

;; rlc a (91)
	setb c
	mov  a,#129
	rlc  a
	subb a,#2	;a(3)-c(1)-1
	jnz  fail91
	clr  c
	mov  a,#129
	rlc  a
	subb a,#1	;a(2)-c(1)-1
	jz   done91
fail91:
	mov  P1,#91
	ljmp failed
done91:

;;;;;;;;;;;;;;;;  INST 92 ;;;;;;;;;;;;;;;;;;;;;;;

;; rr a (92)
	mov  a,#129
	rr   a
	subb a,#192
	jz   done92
	mov  P1,#92
	ljmp failed
done92:


;;;;;;;;;;;;;;;;  INST 93 ;;;;;;;;;;;;;;;;;;;;;;;

;; rrc a (93)
	setb c
	mov  a,#3
	rrc  a
	subb a,#128	;a(129)-c(1)-0
	jnz  fail93
	clr  c
	mov  a,#3
	rrc  a
	subb a,#0	;a(1)-c(1)-0
	jz   done93
fail93:
	mov  P1,#93
	ljmp failed
done93:

;;;;;;;;;;;;;;;;  INST 94 ;;;;;;;;;;;;;;;;;;;;;;;

;; setb c (94)
	clr  c
	setb c
	mov  a,#1
	subb a,#0	;a(1)-c(1)-0
	jz   done94
	mov  P1,#94
	ljmp failed
done94:

;;;;;;;;;;;;;;;;  INST 95 ;;;;;;;;;;;;;;;;;;;;;;;

;; setb bit (95)
	clr  a
	setb acc.7
	subb a,#128
	jz   done95
	mov  P1,#95
	ljmp failed
done95:

;;;;;;;;;;;;;;;;  INST 96 ;;;;;;;;;;;;;;;;;;;;;;;

;; sjmp (96)
	sjmp done96
	mov  P1,#96
	ljmp failed
done96:

;;;;;;;;;;;;;;;;  INST 97 ;;;;;;;;;;;;;;;;;;;;;;;

;; subb a,Rn (97)
	setb c
	mov  a,#100
	mov  r0,#10
	subb a,r0     ; 100 - 10 - 1 = 89 
	jc   fail97
	add  a,#167    ; 167 + 89 = 0
	jnz  fail97
	clr  c
	mov  a,#10
	mov  r0,#100
	subb a,r0     ; 10 - 100 - 0 = 166
	jnc  fail97
	add  a,#90     ; 166 + 90 = 0
	jz   done97
fail97:
	mov  P1,#97
	ljmp failed
done97:

;;;;;;;;;;;;;;;;  INST 98 ;;;;;;;;;;;;;;;;;;;;;;;

;; subb a,direct (98)
	setb c
	mov  a,#100
	mov  127,#10
	subb a,127    ; 100 - 10 - 1 = 89 
	jc   fail98
	add  a,#167    ; 167 + 89 = 0
	jnz  fail98
	clr  c
	mov  a,#10
	mov  127,#100
	subb a,127    ; 10 - 100 - 0 = 166
	jnc  fail98
	add  a,#90     ; 166 + 90 = 0
	jz   done98
fail98:
	mov  P1,#98
	ljmp failed
done98:  

;;;;;;;;;;;;;;;;  INST 99 ;;;;;;;;;;;;;;;;;;;;;;;

;; subb a,@Ri (99)
	setb c
	mov  r0,#126
	mov  a,#100
	mov  @r0,#10
	subb a,@r0    ; 100 - 10 - 1 = 89 
	jc   fail99
	add  a,#167    ; 167 + 89 = 0
	jnz  fail99
	clr  c
	mov  a,#10
	mov  @r0,#100
	subb a,@r0    ; 10 - 100 - 0 = 166
	jnc  fail99
	add  a,#90     ; 166 + 90 = 0
	jz   done99
fail99:
	mov  P1,#99
	ljmp failed
done99:


;;;;;;;;;;;;;;;; INST 100 ;;;;;;;;;;;;;;;;;;;;;;;

;; subb a,#data (100)
	setb c
	mov  a,#100
	subb a,#10    ; 100 - 10 - 1 = 89 
	jc   fail100
	add  a,#167    ; 167 + 89 = 0
	jnz  fail100
	clr  c
	mov  a,#10
	subb a,#100   ; 10 - 100 - 0 = 166
	jnc  fail100
	add  a,#90     ; 166 + 90 = 0
	jz   done100
fail100:
	mov  P1,#100
	ljmp failed
done100:  

;;;;;;;;;;;;;;;; INST 101 ;;;;;;;;;;;;;;;;;;;;;;;

;; swap a (101)
	clr  c
	mov  a,#23h
	swap a
	jc   fail101
	subb a,#32h
	jnz  fail101
	mov  a,#0C3h
	setb c
	swap a
	jnc  fail101
  clr  c
	subb a,#3Ch
	jz   done101
fail101:
	mov  P1,#101
	ljmp failed
done101:  

;;;;;;;;;;;;;;;; INST 102 ;;;;;;;;;;;;;;;;;;;;;;;

;; xch a,Rn (102)
	mov  a,#10
	mov  r0,#97
	xch  a,r0
	subb a,#97
	jnz  fail102
	mov  a,r0
	subb a,#10
	jz   done102
fail102:
	mov  P1,#102
	ljmp failed
done102:

;;;;;;;;;;;;;;;; INST 103 ;;;;;;;;;;;;;;;;;;;;;;;

;; xch a,direct (103)
	mov  a,#10
	mov  127,#99
	xch  a,127
	subb a,#99
	jnz  fail103
	mov  a,127
	subb a,#10
	jz   done103
fail103:
	mov  P1,#103
	ljmp failed
done103:  

;;;;;;;;;;;;;;;; INST 104 ;;;;;;;;;;;;;;;;;;;;;;;

;; xch a,@Ri (104)
	mov  a,#10
	mov  r0,#127
	mov  127,#99
	xch  a,@r0
	subb a,#99
	jnz  fail104
	mov  a,127
	subb a,#10
	jz   done104
fail104:
	mov  P1,#104
	ljmp failed
done104:

;;;;;;;;;;;;;;;; INST 105 ;;;;;;;;;;;;;;;;;;;;;;;

;; xchd a,@Ri (105)
	mov  a,#44h
	mov  r0,#127
	mov  127,#55h
	xchd a,@r0
	subb a,#45h
	jnz  fail105
	mov  a,127
	subb a,#54h
	jz   done105
fail105:
	mov  P1,#105
	ljmp failed
done105:


;;;;;;;;;;;;;;;; INST 106 ;;;;;;;;;;;;;;;;;;;;;;;

;; xrl a,Rn (106)
	mov  a,#35h
	mov  r0,#0C3h
	xrl  a,r0
	subb a,#0F6h
	jz   done106
	mov  P1,#106
	ljmp failed
done106:

;;;;;;;;;;;;;;;; INST 107 ;;;;;;;;;;;;;;;;;;;;;;;

;; xrl a,direct (107)
	mov  a,#0C3h
	mov  127,#35h
	xrl  a,127
	subb a,#0F6h
	jz   done107
	mov  P1,#107
	ljmp failed
done107:


;;;;;;;;;;;;;;;; INST 108 ;;;;;;;;;;;;;;;;;;;;;;;

;; xrl a,@Ri (108)
	mov  a,#35h
	mov  r0,#127
	mov  127,#0C3h
	xrl  a,@r0
	subb a,#0F6h
	jz   done108
	mov  P1,#108
	ljmp failed
done108:


;;;;;;;;;;;;;;;; INST 109 ;;;;;;;;;;;;;;;;;;;;;;;

;; xrl a,#data (109)
	mov  a,#35h
	xrl  a,#0C3h
	subb a,#0F6h
	jz   done109
	mov  P1,#109
	ljmp failed
done109:


;;;;;;;;;;;;;;;; INST 110 ;;;;;;;;;;;;;;;;;;;;;;;

;; xrl direct,a (110)
	mov  a,#35h
	mov  127,#0C3h
	xrl  127,a
	clr  a
	mov  a,127
	subb a,#0F6h
	jz   done110
	mov  P1,#110
	ljmp failed
done110:


;;;;;;;;;;;;;;;; INST 111 ;;;;;;;;;;;;;;;;;;;;;;;

;; xrl direct,#data (111)
	mov  127,#35h
	xrl  127,#0C3h
	mov  a,127
	subb a,#0F6h
	jz   done111
	mov  P1,#111
	ljmp failed
done111:


;;;;;;;;;;;;;;;;;  DONE    ;;;;;;;;;;;;;;;;;;;;;;

	mov  P1,#127	; All instructions passed


failed:
  nop;
  nop;
  sjmp failed;

end
