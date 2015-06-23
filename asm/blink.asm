// Register definitions

//R0 = ?
//R1 = ?
//R2 = ?

// first instruction is not executed
	nop
// second instruction is executed twice

// A real blink in SW with 0.5 Hz
//	100.000.000 cycle loop
// 100 MHz clock, inner loop is 3 cycles
// inner loop 65635*3 = 196605
// outer loop 509 ca. 512 is ok

start:
	load 0
	loadh 2
	store r0
ll1:	load 255
	loadh 255
ll2:	sub 1
	nop		// we don't know yet about branch slot
	brnz ll2
	nop
	load r0
	sub 1
	store r0
	brnz ll1	
	nop

	load 0
	out 0

	load 0
	loadh 2
	store r0
ll3:	load 255
	loadh 255
ll4:	sub 1
	nop		// we don't know yet about branch slot
	brnz ll4
	nop
	load r0
	sub 1
	store r0
	brnz ll3	
	nop

	load 1
	out 0

	load 1
	nop
	brnz start

