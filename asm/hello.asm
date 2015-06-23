//
// A small hello world
//
// write Leros to the UART
//

	nop	// first instruction is not executed


start:
	load 76
	store r0
	load <send
	nop
	jal r1

	load 101
	store r0
	load <send
	nop
	jal r1

	load 114
	store r0
	load <send
	nop
	jal r1

	load 111
	store r0
	load <send
	nop
	jal r1

	load 115
	store r0
	load <send
	nop
	jal r1

	load 13
	store r0
	load <send
	nop
	jal r1

	load 10
	store r0
	load <send
	nop
	jal r1

end:
	branch start

send:
	in 0	// check tdre
	and 1
	nop	// one delay slot
	brz send
	load r0
	out 1
	load r1	// that's return
	nop
	jal r1	// here r1 is just dummy
