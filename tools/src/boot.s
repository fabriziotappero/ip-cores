# Minimal SIMPLE boot code

	.text

	# Initialize Stack Pointer ($sp) to make the program fit into 1 KByte of memory space
	addi $29,$29,1024

	# Initialize Return Address ($ra) to jump to the "end-of-test" special address
	lui $31,0xDEAD
	ori $31,0xBEEF

	# Continue to the main test
