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
	load <function
	loadh >function // can be omitted for small programs
	nop
	jal r3
	load 1
	load 2
	load 3
	branch end
function:
	load 5
	store r0
	load r3
	nop
	jal r3
end:
	load 76
	out 0

