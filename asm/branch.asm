// Test code

// first instruction is not executed
	nop
// second instruction is executed twice

// conditional branch has one cycle delay
// for the condition
//
// test of branch conditions - should never loop
//
start:
	load 1
	load 0
	load 0
	load 7 // branch condidition
	load 0
	brnz brnzok
	branch start
brnzok:
	load 127
	load 0
	load 127
	brz brzok
	branch start
brzok:
	load 0
	load -1
	load 0
	brn brnok
	branch start
brnok:
	load -1
	load 5
	load -1
	brp brpok
	branch start
brpok:
	nop
	branch brok
	branch start
brok:
	nop
	out 0

