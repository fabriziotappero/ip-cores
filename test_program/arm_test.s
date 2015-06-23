@ This file is part of ARM4U CPU
@ 
@ This is a creation of the Laboratory of Processor Architecture
@ of Ecole Polytechnique Fédérale de Lausanne ( http://lap.epfl.ch )
@
@ asm_test.s ---  Test program which uses all the instruction set
@                 to be assembled with GCC assembler
@
@ Written By -  Jonathan Masur and Xavier Jimenez (2013)
@
@ This program is free software; you can redistribute it and/or modify it
@ under the terms of the GNU General Public License as published by the
@ Free Software Foundation; either version 2, or (at your option) any
@ later version.
@
@ This program is distributed in the hope that it will be useful,
@ but WITHOUT ANY WARRANTY; without even the implied warranty of
@ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
@ GNU General Public License for more details.
@
@ In other words, you are welcome to use, share and improve this program.
@ You are forbidden to forbid anyone else to use, share and improve2
@ what you give them.   Help stamp out software-hoarding!

	.text
	.global test_cond, test_fwd, test_bshift, test_logic, test_adder, test_bshift_reg, test_load
	.global test_store, test_byte, test_cpsr, test_mul, test_ldmstm, test_r15jumps, test_rti

_start:
	bl test_cond
fail1:
	teq r0, #0
	bne fail1

	bl test_fwd
fail2:
	teq r0, #0
	bne fail2

	bl test_bshift
fail3:
	teq r0, #0
	bne fail3

	bl test_logic
fail4:
	teq r0, #0
	bne fail4

	bl test_adder
fail5:
	teq r0, #0
	bne fail5

	bl test_bshift_reg
fail6:
	teq r0, #0
	bne fail6

	bl test_load
fail7:
	teq r0, #0
	bne fail7

	bl test_store
fail8:
	teq r0, #0
	bne fail8

	bl test_byte
fail9:
	teq r0, #0
	bne fail9

	bl test_cpsr
fail10:
	teq r0, #0
	bne fail10

	bl test_mul
fail11:
	teq r0, #0
	bne fail11

	bl test_ldmstm
fail12:
	teq r0, #0
	bne fail12

	bl test_r15jumps
fail13:
	teq r0, #0
	bne fail13

	bl test_rti
passed:
	b passed

	@test N and Z flags conditional execution
test_cond:
	mov r0, #1

	@ test 1 - test that the Z flag is set properly, and N flag clear properly
	movs r5, #0
	bne fail
	bmi fail
	add r0, #1

	@test 2 - test that an instruction without 'S' does not affect the flags
	movs r5, #1
	mov r5, #0
	beq fail
	bmi fail
	add r0, #1

	@test 3 - test that the N flag is set properly
	movs r5, #-2
	mov r5, #0
	beq fail
	bpl fail
	add r0, #1

	@test4 - make sure conditional MOV are skipped, and that flags are not updated on a skipped instruction
	movs r5, #1
	movpls r5, #0	@valid
	movnes r5, #1	@invalid
	movmis r5, #2	@invalid
	bne fail
	cmp r5, #0
	bne fail
	add r0, #1

	@ test 5 - make sure instructions after a branch are skipped completely
	b .dummy
	movs r5, #-1
	movs r5, #-2
	movs r5, #-3
.dummy:
	bne fail
	bmi fail

	@condition test passed
	mov r0, #0
fail:
	bx lr

test_fwd:
	mov r0, #1

	@test forwarding and register file for OPA
	mov r1, #1
	add r1, r1, #1
	add r1, r1, #1
	add r1, r1, #1
	add r1, r1, #1
	add r1, r1, #1
	cmp r1, #6
	bne fail
	add r0, #1

	@test forwarding priority for opb
	mov r1, #1
	mov r1, #2
	mov r1, #3
	mov r1, #4
	mov r1, #5
	cmp r1, #5
	bne fail
	add r0, #1

	@forwarding test passed
	mov r0, #0
	bx lr

test_bshift:
	@test barrel shifter all modes (shift by literal const. only for now)
	mov r0, #1

	@test 1 - test LSL output
	movs r5, #0xf0000000
	mov r1, #0x0f
	mov r2, r1, lsl #28
	cmp r5, r2
	bne fail
	add r0, #1

	@test 2 - test ROR output
	mov r3, r1, ror #4
	cmp r5, r3
	bne fail
	add r0, #1

	@test 3 - test LSR output
	mov r4, r5, lsr #28
	cmp r4, r1
	bne fail
	add r0, #1

	@test 4 - test ASR output
	mov r1, #0x80000000
	mov r2, r1, asr #3
	cmp r5 ,r2
	bne fail
	add r0, #1

	@test 5 - test RRX output and carry
	mov r1, #1
	movs r1, r1, rrx
	bcc fail
	movs r1, r1, rrx
	beq fail
	bcs fail
	add r0, #1

	@test 6 - test carry output from rotated constant
	movs r5, #0xf0000000
	bcc fail
	movs r5, #0xf
	bcc fail
	movs r5, #0x100
	bcs fail
	add r0, #1

	@test 7 - test carry output from LSL
	mov r5, #0x1
	movs r5, r5, lsl #1
	bcs fail
	mov r5, #0x80000000
	movs r5, r5, lsl #1
	bcc fail
	add r0, #1

	@test 8 - test carry output from LSR
	mov r5, #2
	movs r5, r5, lsr #1
	bcs fail
	movs r5, r5, lsr #1
	bcc fail
	bne fail
	add r0, #1

	@test 9 - test carry output from ASR
	mvn r5, #0x01
	movs r5, r5, asr #1
	bcs fail
	movs r5, r5, asr #1
	bcc fail
	add r0, #1

	@test 10 - check for LSR #32 to behave correctly
	mov r1, #0xa5000000
	mvn r2, r1
	lsrs r3, r1, #32
	bcc fail
	lsrs r3, r2, #32
	bcs fail
	add r0, #1

	@test 11 - check for ASR #32 to behave correctly
	asrs r3, r1, #32
	bcc fail
	cmp r3, #-1
	bne fail
	asrs r3, r2, #32
	bcs fail
	bne fail

	@barrelshift test passed
	mov r0, #0
	bx lr

	@test logical operations
test_logic:
	mov r0, #1

	@test 1 - NOT operation
	mov r5, #-1
	mvns r5, r5
	bne fail
	add r0, #1

	@test 2 - AND operation
	mov r5, #0xa0
	mov r1, #0x0b
	mov r2, #0xab
	mov r3, #0xba

	ands r4, r5, r1
	bne fail
	ands r4, r5, r2
	cmp r4, r5
	bne fail
	add r0, #1

	@test 3 - ORR and EOR operations
	orr r4, r5, r1
	eors r4, r2, r4
	bne fail
	orr r4, r1, r5
	teq	r4, r2
	bne fail
	add r0, #1

	@test 4 - TST opcode
	tst r1, r5
	bne fail
	tst r4, r2
	beq fail
	add r0, #1

	@test 5 - BIC opcode
	bics r4, r2, r3
	cmp r4, #1
	bne fail

	@logical test passed
	mov r0, #0
	bx lr

	@test adder, substracter, C and V flags
test_adder:
	mov r0, #1

	@test 1 - check for carry when adding
	mov r5, #0xf0000000
	mvn r1, r5			@0x0fffffff
	adds r2, r1, r5
	bcs fail
	bvs fail

	adds r2, #1
	bcc fail
	bvs fail

	adc r2, #120
	cmp r2, #121
	bne fail
	bvs fail
	add r0, #1

	@test 2 - check for overflow when adding
	mov r3, #0x8fffffff		@two large negative numbers become positive
	adds r3, r5
	bvc fail
	bcc fail
	bmi fail

	mov r3, #0x10000000
	adds r3, r1				@r3 = 0x1fffffff
	bvs fail
	bcs fail

	adds r3, #0x60000001	@two large positive numbers become negative
	bvc fail
	bpl fail

	add r0, #1

	@test 3 - check for carry when substracting
	mov r5, #0x10000000
	subs r2, r5, r1
	bcc fail
	bvs fail

	subs r2, #1
	bcc fail
	bvs fail

	subs r2, #1
	bcs fail
	bvs fail

	add r0, #1

	@test 4 - check for overflow when substracting
	mov r3, #0x90000000
	subs r3, r5
	bvs fail
	bcc fail

	subs r3, #1		@substract a positive num from a large negative make the result positive
	bvc fail
	bcc fail

	@test 5 - check for carry when reverse substracting
	mov r3, #1
	rsbs r2, r1, r5
	bcc fail
	bvs fail
	rsbs r2, r3, r2
	bcc fail
	bvs fail
	rscs r2, r3, r2
	bcs fail
	bvs fail

	add r0, #1

	@test 6 - check for overflow when reverse substracting
	mov r2, #0x80000000
	mov r1, #-1
	rsbs r2, r1
	bvs fail
	bmi fail
	bcc fail

	mov r0, #0
	bx lr

@test barrelshift with register controler rotates
test_bshift_reg:
	mov r0, #1

	mov r1, #0
	mov r2, #7
	mov r3, #32
	mov r4, #33
	mov r5, #127
	mov r6, #256
	add r7, r6, #7
	mov r8, #0xff000000

	@test 1 LSL mode with register shift
	movs r9, r8, lsl r2
	bpl fail
	bcc fail
	@make sure lsl #0 does not affect carry
	movs r9, r2, lsl r1
	bcc fail
	@test using the same register twice
	mov r9, r2, lsl r2
	cmp r9, #0x380
	bne fail

	add r0, #1

	@test 2 - LSL mode with barrelshift > 31
	movs r9, r2, lsl r3
	bcc fail
	bne fail
	movs r9, r2, lsl r4
	bcs fail
	bne fail
	add r0, #1

	@test 3 - LSL mode with barrelshift >= 256 (only 8 bits used)
	movs r9, r2, lsl r6
	bcs fail
	cmp r9, #7
	bne fail

	mov r9, r2, lsl r7
	cmp r9, #0x380
	bne fail

	movs r9, r8, lsl r7
	bpl fail
	bcc fail

	add r0, #1

	@test 4 - LSR mode with register shift
	mov r2, #4
	add r7, r6, #4

	movs r9, r8, lsr r2
	bmi fail
	bcs fail
	@make sure lsr #0 does not affect carry
	movs r9, r2, lsr r1
	bcs fail
	cmp r9, #4
	bne fail

	movs r9, r8, lsr r2
	bcs fail
	cmp r9, #0xff00000
	bne fail

	add r0, #1

	@test 5 - LSR mode with barrelshift > 31
	movs r9, r8, lsr r3
	bcc fail
	bne fail
	movs r9, r8, lsr r4
	bcs fail
	bne fail
	add r0, #1

	@test 6 - LSR mode with barrelshift >= 256 (only 8 bits used)
	movs r9, r8, lsr r6
	bcs fail
	cmp r9, #0xff000000
	bne fail

	movs r9, r8, lsr r7
	cmp r9, #0xff00000
	bne fail

	mov r0, #0
	bx lr

array:
	.word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
array2:
	.word 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
	
test_load:
	mov r0, #1

	@ Test1 basic load operations
	ldr r1, .larray1
	ldr r2, .larray2

	ldr r3, [r1]
	teq r3, #0
	bne fail

	ldr r3, [r2]
	teq r3, #16
	bne fail
	add r0, #1

	@ Test 2 load operations with offsets
	ldr r3, [r2, #-60]
	teq r3, #1
	bne fail

	ldr r3, [r1, #20]
	teq r3, #5
	bne fail
	add r0, #1

	@ Test 3 - test positive register offset addressing
	mov r3, #124
.lloop:
	ldr r4, [r1, r3]
	cmp r4, r3, lsr #2
	bne fail
	subs r3, #4
	bpl .lloop
	add r0, #1

	@ Test 4 - test negative register offset addressing
	mov r3, #64
.lloop2:
	ldr r4, [r2, -r3]
	rsb r4, #0x10
	cmp r4, r3, lsr #2
	bne fail
	subs r3, #4
	bne .lloop2
	add r0, #1

	@ Test 5 - test positive register offset addressing with shift
	mov r3, #0
.lloop3:
	ldr r4, [r1, r3, lsl #2]
	cmp r4, r3
	bne fail
	add r3, #1
	cmp r3, #32
	bne .lloop3
	add r0, #1

	@ Test 6 - test negative register offset addressing with shift
	mov r3, #0
.lloop4:
	ldr r4, [r2, -r3, lsl #2]
	rsb r4, #0x10
	cmp r4, r3
	bne fail
	add r3, #1
	cmp r3, #16
	bne .lloop4
	add r0, #1

	@ Test 7 - test offset with pre-increment
	mov r3, #31
	mov r5, r1
.lloop5:
	ldr r4, [r5, #4]!
	rsb r4, #32
	cmp r4, r3
	bne fail
	subs r3, #1
	bne .lloop5
	add r0, #1

	@ Test 8 - test offset with pre-degrement
	mov r3, #31
	add r5, r1, #128
.lloop6:
	ldr r4, [r5, #-4]!
	cmp r4, r3
	bne fail
	subs r3, #1
	bpl .lloop6
	add r0, #1

	@ Test 9 - test offset with post-increment
	mov r3, #32
	mov r5, r1
.lloop7:
	ldr r4, [r5], #4
	rsb r4, #32
	cmp r4, r3
	bne fail
	subs r3, #1
	bne .lloop7
	add r0, #1

	@ Test 10 - test offset with post-decrement
	mov r3, #31
	add r5, r1, #124
.lloop8:
	ldr r4, [r5], #-4
	cmp r3, r4
	bne fail
	subs r3, #1
	bpl .lloop8
	add r0, #1

	@ Test 11 - test register post-increment with a negative value
	mov r6, #0xfffffff0
	mov r5, r2
	mov r3, #16
.lloop9:
	ldr r4, [r5], r6, asr #2
	cmp r4, r3
	bne fail
	subs r3, #1
	bpl .lloop9

	mov r0, #0
	bx lr

.larray1:
	.word array
.larray2:
	.word array2

test_store:
	mov r0, #1

	@ Test 1 - test basic store opperation
	ldr r1, .larray1
	mov r2, #0x24
	str r2, [r1]
	ldr r2, [r1]
	cmp r2, #0x24
	bne fail
	add r0, #1

	@ Test 2 - check for post-increment and pre-decrement writes
	mov r2, #0xab
	mov r3, #0xbc
	str r2, [r1, #4]!		@ array[1] = 0xab
	str r3, [r1], #4		@ array[1] = 0xbc
	ldr r2, [r1, #-4]!		@ read 0xbc
	ldr r3, [r1, #-4]!		@ read 0x24
	cmp r3, #0x24
	bne fail
	cmp r2, #0xbc
	bne fail
	add r0, #1

	@ Test 3 - check for register post-increment addressing
	mov r2, #8
	mov r3, #20
	mov r4, r1
	str r2, [r4], r2
	str r3, [r4], r2
	sub r4, #16
	cmp r4, r1
	bne fail
	ldr r2, [r1]
	cmp r2, #8
	bne fail
	ldr r2, [r1, #8]
	cmp r2, #20
	bne fail

	mov r0, #0
	bx lr

	@ Tests byte loads and store
test_byte:
	mov r0, #1

	@ test 1 - test store bytes
	ldr r1, .larray1
	mov r2, #8
.bloop:
	strb r2, [r1], #1
	subs r2, #1
	bne .bloop

	ldr r2, .ref_words+4
	ldr r3, [r1, #-4]!
	cmp r2, r3
	bne fail

	ldr r2, .ref_words
	ldr r3, [r1, #-4]!
	cmp r2, r3
	bne fail
	add r0, #1

	@ test 2 - test load bytes
	mov r2, #8
.bloop2:
	ldrb r3, [r1], #1
	cmp r3, r2
	bne fail
	subs r2, #1
	bne .bloop2

	mov r0, #0
	bx lr

.ref_words:
	@ Table for ARMs who access bytes in a little-endian order
	.word 0x05060708, 0x01020304

	@ Table for ARMs who access bytes in a big-endian order
@	.word 0x08070605, 0x04030201

	@ Good source for flags info :
	@ http://blogs.arm.com/software-enablement/206-condition-codes-1-condition-flags-and-codes/
test_cpsr:
	mov r0, #1

	@ Test 1 - in depth test for the condition flags
	mrs r1, cpsr
	and r1, #0x000000ff
	msr cpsr_flg, r1
	@ NZCV = {0000}
	bvs fail
	bcs fail
	beq fail
	bmi fail
	bhi fail		@ bhi <-> bls
	blt fail		@ blt <-> bge
	ble fail		@ ble <-> bgt

	add r1, #0x10000000
	msr cpsr, r1
	@ NZCV = {0001}
	bvc fail
	bhi fail
	bge fail
	bgt fail

	add r1, #0x10000000
	msr cpsr, r1
	@ NZCV = {0010}
	bvs fail
	bcc fail
	bls fail

	add r1, #0x10000000
	msr cpsr, r1
	@ NZCV = {0011}
	bls fail
	bge fail
	bgt fail

	add r1, #0x10000000
	msr cpsr, r1
	@ NZCV = {0100}
	bne fail
	bhi fail
	bgt fail

	add r1, #0x10000000
	msr cpsr, r1
	@ NZCV = {0101}
	bgt fail

	add r1, #0x10000000
	msr cpsr, r1
	@ NZCV = {0110}
	bhi fail

	add r1, #0x20000000
	msr cpsr, r1
	@ NZCV = {1000}
	bpl fail
	bge fail
	bgt fail

	add r1, #0x10000000
	msr cpsr, r1
	@ NZCV = {1001}
	blt fail

	add r1, #0x30000000
	msr cpsr, r1
	@ NZCV = {1100}
	bgt fail

	add r0, #1

	@ Test 2 - test for the FIQ processor mode
	mov r1, r14			@ save our link register and stack pointer
	mov r2, r13
	mov r3, #30
	mov r4, #40
	mov r5, #50
	mov r6, #60
	mov r7, #70
	mov r8, #80
	mov r9, #90
	mov r10, #100
	mov r11, #110
	mov r12, #120
	mov r13, #130
	mov r14, #140

	msr cpsr, #0xd1		@ go into FIQ mode, disable all interrupts (F and I bits set)
	cmp r3, #30
	bne .fail
	mov r8, #8			@ overwrite fiq regs...
	mov r9, #9
	mov r10, #10
	mov r11, #11
	mov r12, #12
	mov r13, #13
	mov r14, #14
	mov r3, #3			@ also overwrite some user regs
	mov r4, #4
	mov r5, #5
	mov r6, #6
	mov r7, #7
	msr cpsr, #0x10		@ back to user mode
	cmp r3, #3			@ r3-7 should have been affected, but not r8-r14
	bne .fail
	cmp r4, #4
	bne .fail
	cmp r5, #5
	bne .fail
	cmp r6, #6
	bne .fail
	cmp r7, #7
	bne .fail
	cmp r8, #80
	bne .fail
	cmp r9, #90
	bne .fail
	cmp r10, #100
	bne .fail
	cmp r11, #110
	bne .fail
	cmp r12, #120
	bne .fail
	cmp r13, #130
	bne .fail
	cmp r14, #140
	bne .fail
	add r0, #1


	@ Test 3 - test for the SUP processor mode
	mov r12, #120
	mov r13, #130
	mov r14, #140
	msr cpsr, #0x13		@ enter SUP mode
	cmp r12, #120
	bne .fail
	mov r12, #12
	mov r13, #13
	mov r14, #14
	msr cpsr, #0x10		@ back into user mode
	cmp r12, #12
	bne .fail
	cmp r13, #130
	bne .fail
	cmp r14, #140
	bne .fail
	add r0, #1

	@ Test 4 - test for the UND processor mode
	mov r12, #120
	mov r13, #130
	mov r14, #140
	msr cpsr, #0x1b		@ enter UND mode
	cmp r12, #120
	bne .fail
	mov r12, #12
	mov r13, #13
	mov r14, #14
	msr cpsr, #0x10		@ back into user mode
	cmp r12, #12
	bne .fail
	cmp r13, #130
	bne .fail
	cmp r14, #140
	bne .fail
	add r0, #1

	@ Test 5 - test for the IRQ processor mode
	mov r12, #120
	mov r13, #130
	mov r14, #140
	msr cpsr, #0x92		@ enter IRQ mode, IRQ disabled
	cmp r12, #120
	bne .fail
	mov r12, #12
	mov r13, #13
	mov r14, #14
	msr cpsr, #0x10		@ back into user mode
	cmp r12, #12
	bne .fail
	cmp r13, #130
	bne .fail
	cmp r14, #140
	bne .fail

	mov r0, #0

.fail:
	msr cpsr, #0x10		@ back into user mode
	mov r13, r2
	bx r1				@ return

	@ Test multiplier and how it affects the flags
test_mul:
	mov r0, #1

	@ Test 1 - MUL instruction
	mov r1, #0
	mov r2, #2
	mov r3, #3
	mul r4, r2, r3
	cmp r4, #6
	bne fail
	bmi fail

	muls r5, r1, r2
	bne fail
	bmi fail

	muls r4, r2
	cmp r4, #12
	bne fail
	bmi fail

@	mul r3, r3, r4		@ no joke, verified to fail on a real ARM !
@	cmp r4, #36
@	bne fail

	mov r3, #-3			@ multiply positive * negative
	muls r5, r2, r3
	bpl fail	
	cmp r5, #-6
	bne fail

	mov r2, #-2			@ multiply negative * negative
	muls r5, r2, r3
	bmi fail
	cmp r5, #6
	bne fail
	add r0, #1

	@ Test 2 - MLA instruction
	mov r1, #10
	mov r2, #2
	mov r3, #5
	mlas r4, r1, r2, r3		@ 2*10 + 5 = 25
	bmi fail
@	bcs fail			@ on a real ARM, C flag after MLA is unpredictable
	bvs fail
	cmp r4, #25
	bne fail

	mov r1, #-10
	mlas r4, r1, r2, r3		@ 2*-10 + 5 = -15
	bpl fail
	bvs fail
	cmp r4, #-15
	bne fail

	mov r3, #0x80000001		@ causes addition overflow
	mlas r4, r1, r2, r3
	bmi fail
@	bvc fail			@ on a real ARM, V flag is not updated ?

	mov r0, #0
	bx lr

	@ Test load multiple and store multiple instructions
test_ldmstm:
	mov r0, #1

	@ Test 1 - STMIA
	mov r1, #1
	mov r2, #2
	mov r3, #3
	mov r4, #4
	ldr r5, .larray1
	mov r6, r5

	stmia r6!, {r1-r4}
	sub r6, r5
	cmp r6, #16
	bne fail

	ldr r6, [r5]
	cmp r6, #1
	bne fail
	ldr r6, [r5, #4]
	cmp r6, #2
	bne fail
	ldr r6, [r5, #8]
	cmp r6, #3
	bne fail
	ldr r6, [r5, #12]
	cmp r6, #4
	bne fail
	add r0, #1

	@ Test 2 - STMIB
	mov r6, r5
	stmib r6!, {r1-r3}
	sub r6, r5
	cmp r6, #12
	bne fail

	ldr r6, [r5, #4]
	cmp r6, #1
	bne fail
	ldr r6, [r5, #8]
	cmp r6, #2
	bne fail
	ldr r6, [r5, #12]
	cmp r6, #3
	bne fail
	add r0, #1

	@ Test 3 - STMDB
	add r6, r5, #12
	stmdb r6!, {r1-r3}
	cmp r6, r5
	bne fail

	ldr r6, [r5]
	cmp r6, #1
	bne fail
	ldr r6, [r5, #8]
	cmp r6, #3
	bne fail
	add r0, #1

	@ Test 4 - STMDA
	add r6, r5, #12
	stmda r6!, {r1-r3}
	cmp r6, r5
	bne fail
	ldr r6, [r5, #4]
	cmp r6, #1
	bne fail
	ldr r6, [r5, #12]
	cmp r6, #3
	bne fail
	add r0, #1

	@ Test 5 - LDMIA
	ldr r5, .larray2
	ldmia r5, {r1-r4}
	cmp r1, #16
	bne fail
	cmp r2, #17
	bne fail
	cmp r3, #18
	bne fail
	cmp r4, #19
	bne fail
	add r0, #1

	@ Test 6 - LDMIB
	ldmib r5!, {r1-r4}
	cmp r1, #17
	bne fail
	cmp r2, #18
	bne fail
	cmp r3, #19
	bne fail
	cmp r4, #20
	bne fail
	add r0, #1

	@ Test 7 - LDMDB
	ldmdb r5!, {r1-r3}
	cmp r3, #19
	bne fail
	cmp r2, #18
	bne fail
	cmp r1, #17
	bne fail
	add r0, #1

	@ Test 8 - LDMDA
	ldmda r5, {r1-r2}
	cmp r1, #16
	bne fail
	cmp r2, #17
	bne fail

	mov r0, #0
	bx lr

	@ Test proper jumping on instructions that affect R15
test_r15jumps:
	mov r0, #1

	@ Test 1 - a standard, conditional jump instruction
	ldr r3, .llabels
	mov r1, #0
	movs r2, #0
	moveq r15, r3		 @ jump to label 1
	movs r2, #12
	movs r1, #13		@ make sure fetched/decoded instructions do no execute
.label1:
	bne fail
	cmp r1, #0
	bne fail
	cmp r2, #0
	bne fail
	add r0, #1

	@ Test 2 - a jump instruction is not executed
	ldr r3, .llabels+4
	movs r2, #12
	moveq r15, r3
	movs r2, #0
.label2:
	cmp r2, #0
	bne fail
	add r0, #1

	@ Test 3 - add instruction to calculate new address
	ldr r3, .llabels+8
	movs r1, #0
	movs r2, #0
	add r15, r3, #8		@go 2 instructions after label 3
.label3:
	movs r1, #12
	movs r2, #13
	bne fail		@ program executions continues here
	bne fail
	add r0, #1

	@ Test 4 - use an addition directly from PC+8 (r15)
	movs r2, #0
	movs r1, #0
	add r15, r15, #4	@ Skip 2 instructions This could actually be used for a nice jump table if a register were used instead of #4
	movs r1, #1
	movs r2, #2
	bne fail
	bne fail
	add r0, #1

	@ Test 5 - load r15 directly from memory
	movs r1, #1
	movs r2, #2
	ldrne r15, .llabels+12		@ Makes sure code after a ldr r15 is not executed
	movs r1, #0
	movs r2, #0
.label4:
	beq fail
	beq fail

	ldreq r15, .llabels+16		@ Makes sure everything is right when a ldr r15 is not taken
	movs r2, #-2
.label5:
	bpl fail
	cmp r2, #-2
	bne fail
	add r0, #1

	@ Test 6 - load r15 as the last step of a LDM instruction
	ldr r3, .llabels + 6*4
	movs r1, #0
	movs r2, #0
	ldmia r3, {r4-r8, r15}		@jump to label6
	movs r1, #4
	movs r2, #2
.label6:
	bne fail
	bne fail

	mov r0, #0
	bx lr

.align 8
.llabels:
	.word .label1, .label2, .label3, .label4, .label5, .label6, .llabels

test_rti:
	mov r0, #1

	@ Test 1 - test normal RTI
	msr cpsr, #0xd1			@ enter into FIQ mode (interrupt disabled)
	msr spsr, #0x40000010	@ emulate a saved CPSR in user mode, with NZCV = {0100}

	movs r8, #-12			@ now the FIQ sets it's CPSR to NZCV = {1000}
	ldr r8, .rtilabels		@ simulate an interrupt return
	movs r15, r8			@ return from interrupt and move SPSR to CPSR

.rtilabel1:
	bmi .rtifail			@ ?!? WTF !?!
	bne .rtifail
	add r0, #1

	@ Test 2 - test LDM instruction with S flag
	msr cpsr, #0xd1
	ldr r8, .rtilabels + 20
	ldmib r8!, {r9, r10}		@ fiq_r9 = 1, fiq_r10 = 2
	ldmib r8, {r9, r10}^		@ r8 = 3, r9 = 4 ( ^ => load to user registers )
	cmp r9, #1
	bne .rtifail
	cmp r10, #2
	bne .rtifail
	msr cpsr, #0x10
	cmp r9, #3
	bne .rtifail
	cmp r10, #4
	bne .rtifail
	add r0, #1

	@ Test 3 - test LDM instruction with S flag for returning from an interrupt
	msr cpsr, #0xd1				@ FIQ mode, NZCV = {0000}
	msr spsr_c, #0x80000010		@ saved is normal mode with NZCV = {1000}

	ldr r8, .rtilabels + 20
	add r8, #8

	movs r9, #0					@ NZCV = {0100}
	ldmib r8, {r9-r11, r15}^	@ This should return to user mode and restore CPSR to NZCV = {1000}

.rtilabel2:
	bpl .rtifail
	beq .rtifail

	mov r0, #0

.rtifail:
	msr cpsr, #0x10
	bx lr


.rtilabels:
	.word .rtilabel1, 1, 2, 3, 4, .rtilabels, .rtilabel2
