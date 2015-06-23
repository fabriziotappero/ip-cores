		ldi r0,0
		csr negro
		ldi r1,25
		stm r1,21
		stm r1,22
		ldi r1,5
		stm r1,11
		ldi r1,75
		stm r1,12
		stm r0,5
		stm r0,6
		ldi r1,1
		stm r0,8
		stm r1,9
punto	ldi r1,40
		stm r1,10
		ldi r1,30
		stm r1,20
		csr dbl
		csr dbl
		csr dbl
		csr dbl
		csr dbl
		csr dbl
		csr dbl
		csr dbl
		csr dbl
		csr dbl
		csr dbl
		csr dbl
		csr dbl
		csr dbl
inicio	csr marca
		csr vermarc
		csr negro
		csr marca
		ldm r2,21
		ldm r5,32
		ldi r6,1
		and r6,r5
		ldi r7,2
		and r7,r5
		sr0 r7
		csr moli
		stm r2,21
		ldm r2,22
		ldm r5,32
		ldi r6,4
		and r6,r5
		sr0 r6
		sr0 r6
		ldi r7,8
		and r7,r5
		sr0 r7
		sr0 r7
		sr0 r7
		csr moli
		stm r2,22
		csr cobo
		csr mobo
		ldm r1,11
		ldm r2,21
		ldi r4,7
		csr lineav
		ldm r1,12
		ldm r2,22
		ldi r4,7
		csr lineav
		csr bola
		csr delay
		csr delay
		csr delay
		csr delay
		ldi r7,1
		stm r7,128
		stm r0,128
		jmp inicio
delay	ldi r1,0
		ldi r2,0
		ldi r3,255
pat04	cmp r1,r3
		jpz pat03
pat02	cmp r2,r3
		jpz pat01
		adi r2,1
		jmp pat02
pat01	adi r1,1
		ldi r2,0
		jmp pat04
pat03	ret
bola	ldm r1,10
		ldm r2,20
		ldi r4,7
		stm r1,32
		stm r2,64
		stm r4,96
		csr we
		ret
mobo	ldm r1,10
		ldm r2,20
		ldm r3,8
		ldm r4,9
		ldi r5,1
		cmp r3,r5
		jpz comp12
		sub r2,r5
		jmp comp13
comp12	adi r2,1
comp13	cmp r4,r5
		jnz comp14
		adi r1,1
		jmp comp15
comp14	sub r1,r5
comp15	stm r1,10
		stm r2,20
		ret
cobo	ldm r1,10
		ldm r2,20
		ldi r3,78
		ldi r4,58
		ldi r7,2
		cmp r1,r7
		jnz comp04
		ldm r6,6
		adi r6,1
		stm r6,6
		ldi r6,1
		stm r6,9
		jmp punto
comp04	cmp r1,r3
		jnz comp05
		ldm r6,5
		adi r6,1
		stm r6,5
		stm r0,9
		jmp punto
comp05	cmp r2,r7
		jnz comp06
		ldi r6,1
		stm r6,8
comp06	cmp r2,r4
		jnz comp07
		stm r0,8
comp07	ldm r3,11
		ldm r4,21
		adi r3,1
		cmp r1,r3
		jnz comp08
		cmp r2,r4
		jpz comp09
		adi r4,1
		cmp r2,r4
		jpz comp09
		adi r4,1
		cmp r2,r4
		jpz comp09
		adi r4,1
		cmp r2,r4
		jpz comp09
		adi r4,1
		cmp r2,r4
		jpz comp09
		adi r4,1
		cmp r2,r4
		jnz comp08
comp09	ldi r6,1
		stm r6,9
comp08	ldm r3,12
		ldi r6,1
		ldm r4,22
		sub r4,r6
		cmp r1,r3
		jnz comp10
		cmp r2,r4
		jpz comp11
		adi r4,1
		cmp r2,r4
		jpz comp11
		adi r4,1
		cmp r2,r4
		jpz comp11
		adi r4,1
		cmp r2,r4
		jpz comp11
		adi r4,1
		cmp r2,r4
		jpz comp11
		adi r4,1
		cmp r2,r4
		jnz comp10
comp11	stm r0,9
comp10	ret
moli	ldi r3,1
		ldi r4,55
		ldi r5,2
		cmp r6,r3
		jnz comp03
		cmp r2,r3
		jpz finmol
		sub	r2,r5
comp03	cmp r7,r3
		jnz finmol
		cmp r2,r4
		jpz finmol
		add r2,r5
finmol	ret
marca	ldm r5,5
		ldi r1,19
		ldi r2,5
		ldi r4,6
		csr impnum
		ldm r5,6
		ldi r1,57
		ldi r2,5
		csr impnum
		ret
vermarc	ldm r1,5
		ldm r2,6
		ldi r3,6			
		cmp r1,r3
		jnz comp01
		ldm r1,12
		ldm r2,22
		ldi r4,4
		csr lineav
gana1	jmp gana1
comp01	ldi r3,6
		cmp r2,r3
		jnz comp02
		ldm r1,11
		ldm r2,21
		ldi r4,4
		csr lineav
gana2	jmp gana2
comp02	ret
lineav	ldi r3,5
		add r3,r2
con		cmp r2,r3
		jnc ter
		stm r2, 64
		stm r1, 32
		stm r4, 96
		csr we
		adi r2,1
		jmp con
ter		ret
negro	ldi r7,1
		stm r7,160
		stm r0,96
		ldi r1,80    
		ldi r2,60  
		ldi r3,0   
		ldi r4,0   
nextc	cmp r4,r1
		jpz inc_fil
		stm r3,64
		stm r4,32
		adi r4,1
		jmp nextc
inc_fil	ldi r4,0
		cmp r3,r2
		jpz fneg
		adi r3,1
		jmp nextc
fneg 	stm r0,160
		ret
we 		ldi r7,1
		stm r7,160
		ldi r7,0
		stm r7,160
		ret
dbl		csr delay
		csr delay
		csr delay
		ldm r1,11
		ldm r2,21
		ldi r4,2
		csr lineav
		ldm r1,12
		ldm r2,22
		ldi r4,2
		csr lineav
		csr bola
		ret
segh	ldi r3,3
		add r3,r1
pon1	cmp r1,r3
		jpz mer1
		stm r2, 64
		stm r1, 32
		stm r4, 96
		csr we
		adi r1,1
		jmp pon1
mer1	ldi r3,3
		sub r1,r3
		ret
segv	ldi r3,3
		add r3,r2
pon2	cmp r2,r3
		jpz mer2
		stm r2, 64
		stm r1, 32
		stm r4, 96
		csr we
		adi r2,1
		jmp pon2
mer2	ldi r3,3
		sub r2,r3
		ret
sega	csr segh
		ret
segb	ldi r7,2
		add r1,r7
		csr segv
		ldi r7,2
		sub r1,r7
		ret
segc	ldi r7,2
		add r1,r7
		add r2,r7
		csr segv
		ldi r7,2
		sub r1,r7
		sub r2,r7
		ret
segd	ldi r7,4
		adi r2,4
		csr segh
		ldi r7,4
		sub r2,r7
		ret
sege	ldi r7,2
		adi r2,2
		csr segv
		ldi r7,2
		sub r2,r7
		ret
segf	csr segv
		ret
segg	ldi r7,2
		adi r2,2
		csr segh
		ldi r7,2
		sub r2,r7
		ret
impnum	ldi r7,1
		cmp r5,r7
		jpz num01
		ldi r7,4
		cmp r5,r7
		jpz num01
		csr sega		
num01	ldi r7,5
		cmp r5,r7
		jpz num02
		ldi r7,6
		cmp r5,r7
		jpz num02
		csr segb		
num02	ldi r7,2
		cmp r5,r7
		jpz num03
		csr segc		
num03	ldi r7,1
		cmp r5,r7
		jpz num04
		ldi r7,4
		cmp r5,r7
		jpz num04
		ldi r7,7
		cmp r5,r7
		jpz num04
		csr segd		
num04	ldi r7,0
		cmp r5,r7
		jpz num05
		ldi r7,2
		cmp r5,r7
		jpz num05
		ldi r7,6
		cmp r5,r7
		jpz num05
		ldi r7,8
		cmp r5,r7
		jnz num06
num05	csr sege		
num06	ldi r7,1
		cmp r5,r7
		jpz num07
		ldi r7,2
		cmp r5,r7
		jpz num07
		ldi r7,3
		cmp r5,r7
		jpz num07
		ldi r7,7
		cmp r5,r7
		jpz num07
		csr segf
num07	ldi r7,0
		cmp r5,r7
		jpz num08
		ldi r7,1
		cmp r5,r7
		jpz num08
		csr segg
num08	ret