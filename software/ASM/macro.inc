@ ###########################################
@ #  STORM CORE Processor assembler macros  #
@ # +-------------------------------------+ #
@ # Version 1.0, 06.09.2011                 #
@ ###########################################

@ Return from subroutine
.macro RET
	MOV PC, LR
.endm

@ Return from exception
.macro RETI
	MOVS PC, LR
.endm

@ Push register on stack
.macro PUSH REG
	STR &REG, [SP], #-4
.endm

@ Pop register from stack
.macro POP REG
	LDR &REG, [SP, #+4]!
.endm

@ Simple increment
.macro INC REG
	ADD &REG, &REG, #1
.endm

@ Simple decrement
.macro DEC REG
	SUB &REG, &REG, #1
.endm

@ Clear register
.macro CLR REG
	XOR &REG, &REG,& REG
.endm
