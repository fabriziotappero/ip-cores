// Test code

// first instruction is not executed
	nop
// second instruction is executed twice

// Test jal for function calls
//
// jump and link has one cycle delay
// for target address in accu
//
start:
	load 1
	store r1
	store r2
	store r3
end:

