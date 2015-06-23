// Test code

// first instruction is not executed
	nop
// second instruction is executed twice

start:
	load 127
	store r1
	load 7
	store r3
	nop // there is a store/load delay on registers, right?
	load 15
	loadaddr r3
	store (ar+1)
	load 0
	loadaddr r3
	load (ar+1)
	load r1
	out 0



