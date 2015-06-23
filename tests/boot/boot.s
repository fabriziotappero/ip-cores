# Minimal SIMPLE boot code

	.text

	# Global Pointer ($gp) initialization is done by the linker
	la $gp, _gp
	
	# Stack Pointer ($sp) initialization makes the program fit into 4 KByte
	addi $29,$0,0x1000

	# Initialize Return Address ($ra) to jump to the "end-of-test" special address
	lui $31,0xDEAD
	ori $31,0xBEEF

	# Continue to the main test
