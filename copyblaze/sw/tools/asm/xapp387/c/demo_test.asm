	Constant shifter_port, 01	;declare port 
	Namereg s7, shifter_reg		;declare register
	Load shifter_reg, 01		;init shifter reg
Loop1:	Output shifter_reg, shifter_port
	RL shifter_reg			;rotate left
	Jump loop1			;goto loop1
