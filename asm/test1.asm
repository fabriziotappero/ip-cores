	;;  Test program to debug the BCD math
	ORG 0
	SFT 8,0  		; read switches to AC
	STO 70 			
top:	
	OUT 70 			
	SFT 9,0			; read pushbutton (-1 or 1)
	TAC exe			; button down? 
	SFT 0,9			; read other pushbutton
	TAC exe2
	JMP top			
exe:  				; add 1 to count
	LOD 70			
	ADD one			
	STO 70 			
wait:	SFT 9,0			; wait for button up
	TAC wait
	JMP top

exe2:	LOD 70			; decrease count
	SUB one
	STO 70
wait2:	SFT 0,9			; wait for button up
	TAC wait2
	JMP top

one:	DATA 1			; Needed a 1
	END
	
