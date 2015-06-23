	.file	1 "dhry21_tak.c"

 # -G value = 8, Cpu = 3000, ISA = 1
 # GNU C version egcs-2.90.23 980102 (egcs-1.0.1 release) (sde) [AL 1.1, MM 40] Algorithmics SDE-MIPS v4.0.5 compiled by GNU C version egcs-2.91.57 19980901 (egcs-1.1 release).
 # options passed:  -O2 -O -Wall
 # options enabled:  -fdefer-pop -fomit-frame-pointer -fthread-jumps
 # -fpeephole -finline -fkeep-static-consts -fpcc-struct-return
 # -fdelayed-branch -fcommon -fverbose-asm -fgnu-linker -falias-check
 # -fargument-alias -msplit-addresses -mgas -mrnames -mgpOPT -mgpopt
 # -membedded-data -meb -mmad -marg32 -mdebugh -mdebugi -mmadd -mno-gpconst
 # -mcpu=3000

gcc2_compiled.:
	.globl	Reg_Define
	.data
	.align	0
	.align	2
Reg_Define:
	.size	Reg_Define,26
	.ascii	"Register option selected.\000"
	.rdata
	.align	0
	.align	2
.LC0:
	.ascii	"\n\rDhrystone Benchmark\n\r\000"
	.align	2
.LC1:
	.ascii	"DHRYSTONE PROGRAM, SOME STRING\000"
	.align	2
.LC2:
	.ascii	"DHRYSTONE PROGRAM, 1'ST STRING\000"
	.align	2
.LC3:
	.ascii	"Execution starts\000"
	.align	2
.LC4:
	.ascii	" runs through Dhrystone\n\r\000"
	.align	2
.LC5:
	.ascii	"$time\000"
	.align	2
.LC6:
	.ascii	"\n\000"
	.align	2
.LC7:
	.ascii	"DHRYSTONE PROGRAM, 2'ND STRING\000"
	.align	2
.LC8:
	.ascii	"DHRYSTONE PROGRAM, 3'RD STRING\000"
	.align	2
.LC9:
	.ascii	"Execution ends\n\r\000"
	.align	2
.LC10:
	.ascii	"$finish\000"

	.comm	Ptr_Glob,4

	.comm	Next_Ptr_Glob,4

	.comm	Int_Glob,4

	.comm	Bool_Glob,4

	.comm	Ch_1_Glob,1

	.comm	Ch_2_Glob,1

	.comm	Arr_1_Glob,200

	.comm	Arr_2_Glob,10000

	.text
	.text
	.align	2
	.globl	print
	.ent	print
print:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lbu	$v0,0($a0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L3
	move	$v1,$v0
	.set	macro
	.set	reorder

	li	$a1,16368			# 0x00003ff0
	move	$v0,$v1
.L6:
	#.set	volatile
	sb	$v0,0($a1)
	#.set	novolatile
	addu	$a0,$a0,1
	lbu	$v1,0($a0)
	.set	noreorder
	.set	nomacro
	bne	$v1,$zero,.L6
	move	$v0,$v1
	.set	macro
	.set	reorder

.L3:
	li	$v0,16368			# 0x00003ff0
	#.set	volatile
	sb	$zero,0($v0)
	#.set	novolatile
	j	$ra
	.end	print
	.size	print,.-print
	.align	2
	.globl	print_char
	.ent	print_char
print_char:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	andi	$a0,$a0,0x00ff
	li	$v0,16369			# 0x00003ff1
	#.set	volatile
	sb	$a0,0($v0)
	#.set	novolatile
	j	$ra
	.end	print_char
	.size	print_char,.-print_char
	.align	2
	.globl	print_short
	.ent	print_short
print_short:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	sll	$a0,$a0,16
	sra	$a0,$a0,16
	li	$v0,16370			# 0x00003ff2
	#.set	volatile
	sh	$a0,0($v0)
	#.set	novolatile
	j	$ra
	.end	print_short
	.size	print_short,.-print_short
	.align	2
	.globl	print_long
	.ent	print_long
print_long:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	li	$v0,16372			# 0x00003ff4
	#.set	volatile
	sw	$a0,0($v0)
	#.set	novolatile
	j	$ra
	.end	print_long
	.size	print_long,.-print_long
	.align	2
	.globl	strcpy
	.ent	strcpy
strcpy:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lbu	$v0,0($a1)
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L12
	move	$v1,$v0
	.set	macro
	.set	reorder

.L13:
	sb	$v1,0($a0)
	addu	$a1,$a1,1
	lbu	$v1,0($a1)
	.set	noreorder
	.set	nomacro
	bne	$v1,$zero,.L13
	addu	$a0,$a0,1
	.set	macro
	.set	reorder

.L12:
	.set	noreorder
	.set	nomacro
	j	$ra
	sb	$zero,0($a0)
	.set	macro
	.set	reorder

	.end	strcpy
	.size	strcpy,.-strcpy
	.text
	.align	2
	.globl	main2
	.ent	main2
main2:
	.frame	$sp,224,$ra		# vars= 176, regs= 7/0, args= 16, extra= 0
	.mask	0x803f0000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,224
	sw	$ra,216($sp)
	sw	$s5,212($sp)
	sw	$s4,208($sp)
	sw	$s3,204($sp)
	sw	$s2,200($sp)
	sw	$s1,196($sp)
	sw	$s0,192($sp)
	lui	$a0,%hi(.LC0) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC0) # low
	.set	macro
	.set	reorder

	addu	$v0,$sp,80
	sw	$v0,Next_Ptr_Glob
	addu	$v1,$sp,128
	sw	$v1,Ptr_Glob
	sw	$v0,128($sp)
	sw	$zero,4($v1)
	li	$v0,2			# 0x00000002
	sw	$v0,8($v1)
	li	$v0,40			# 0x00000028
	sw	$v0,12($v1)
	addu	$a0,$sp,144
	lui	$a1,%hi(.LC1) # high
	.set	noreorder
	.set	nomacro
	jal	strcpy
	addiu	$a1,$a1,%lo(.LC1) # low
	.set	macro
	.set	reorder

	addu	$a0,$sp,16
	lui	$a1,%hi(.LC2) # high
	.set	noreorder
	.set	nomacro
	jal	strcpy
	addiu	$a1,$a1,%lo(.LC2) # low
	.set	macro
	.set	reorder

	lui	$v1,%hi(Arr_2_Glob+1628) # high
	li	$v0,10			# 0x0000000a
	sw	$v0,%lo(Arr_2_Glob+1628)($v1)
	move	$s5,$v0
	lui	$a0,%hi(.LC3) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC3) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_long
	li	$a0,10			# 0x0000000a
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC4) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC4) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC5) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC5) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC6) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC6) # low
	.set	macro
	.set	reorder

	li	$s2,1			# 0x00000001
	addu	$s3,$sp,48
	lui	$s4,%hi(.LC8) # high
.L19:
	.set	noreorder
	.set	nomacro
	jal	Proc_5
	li	$s1,3			# 0x00000003
	.set	macro
	.set	reorder

	jal	Proc_4
	li	$v0,2			# 0x00000002
	sw	$v0,184($sp)
	lui	$a1,%hi(.LC7) # high
	move	$a0,$s3
	.set	noreorder
	.set	nomacro
	jal	strcpy
	addiu	$a1,$a1,%lo(.LC7) # low
	.set	macro
	.set	reorder

	li	$v0,1			# 0x00000001
	sw	$v0,180($sp)
	addu	$a0,$sp,16
	.set	noreorder
	.set	nomacro
	jal	Func_2
	move	$a1,$s3
	.set	macro
	.set	reorder

	sltu	$v0,$v0,1
	sw	$v0,Bool_Glob
	lw	$v0,184($sp)
	move	$a0,$v0
	slt	$v0,$v0,3
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L21
	sll	$v0,$a0,2
	.set	macro
	.set	reorder

.L31:
	addu	$v0,$v0,$a0
	subu	$v0,$v0,$s1
	sw	$v0,176($sp)
	move	$a1,$s1
	.set	noreorder
	.set	nomacro
	jal	Proc_7
	addu	$a2,$sp,176
	.set	macro
	.set	reorder

	lw	$v0,184($sp)
	addu	$v0,$v0,1
	sw	$v0,184($sp)
	move	$a0,$v0
	slt	$v0,$v0,$s1
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L31
	sll	$v0,$a0,2
	.set	macro
	.set	reorder

.L21:
	lui	$a0,%hi(Arr_1_Glob) # high
	lui	$a1,%hi(Arr_2_Glob) # high
	addiu	$a0,$a0,%lo(Arr_1_Glob) # low
	lw	$a2,184($sp)
	lw	$a3,176($sp)
	.set	noreorder
	.set	nomacro
	jal	Proc_8
	addiu	$a1,$a1,%lo(Arr_2_Glob) # low
	.set	macro
	.set	reorder

	lw	$a0,Ptr_Glob
	.set	noreorder
	.set	nomacro
	jal	Proc_1
	li	$s0,65			# 0x00000041
	.set	macro
	.set	reorder

	lbu	$v0,Ch_2_Glob
	sltu	$v0,$v0,65
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L25
	move	$a0,$s0
	.set	macro
	.set	reorder

.L33:
	.set	noreorder
	.set	nomacro
	jal	Func_1
	li	$a1,67			# 0x00000043
	.set	macro
	.set	reorder

	lw	$v1,180($sp)
	.set	noreorder
	.set	nomacro
	bne	$v1,$v0,.L32
	addu	$v0,$s0,1
	.set	macro
	.set	reorder

	move	$a0,$zero
	.set	noreorder
	.set	nomacro
	jal	Proc_6
	addu	$a1,$sp,180
	.set	macro
	.set	reorder

	addu	$a0,$sp,48
	.set	noreorder
	.set	nomacro
	jal	strcpy
	addiu	$a1,$s4,%lo(.LC8) # low
	.set	macro
	.set	reorder

	move	$s1,$s2
	sw	$s2,Int_Glob
	addu	$v0,$s0,1
.L32:
	andi	$s0,$v0,0x00ff
	lbu	$v0,Ch_2_Glob
	sltu	$v0,$v0,$s0
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L33
	move	$a0,$s0
	.set	macro
	.set	reorder

.L25:
	lw	$v0,184($sp)
	mult	$s1,$v0
	mflo	$s1
	lw	$v0,176($sp)
	div	$v0,$s1,$v0
	sw	$v0,184($sp)
	.set	noreorder
	.set	nomacro
	jal	Proc_2
	addu	$a0,$sp,184
	.set	macro
	.set	reorder

	addu	$s2,$s2,1
	slt	$v0,$s5,$s2
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L19
	lui	$a0,%hi(.LC5) # high
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC5) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC6) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC6) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC9) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC9) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC10) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC10) # low
	.set	macro
	.set	reorder

	lw	$ra,216($sp)
	lw	$s5,212($sp)
	lw	$s4,208($sp)
	lw	$s3,204($sp)
	lw	$s2,200($sp)
	lw	$s1,196($sp)
	lw	$s0,192($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,224
	.set	macro
	.set	reorder

	.end	main2
	.size	main2,.-main2
	.align	2
	.globl	Proc_1
	.ent	Proc_1
Proc_1:
	.frame	$sp,32,$ra		# vars= 0, regs= 3/0, args= 16, extra= 0
	.mask	0x80030000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	sw	$ra,24($sp)
	sw	$s1,20($sp)
	sw	$s0,16($sp)
	move	$s1,$a0
	lw	$s0,0($s1)
	move	$v1,$s0
	lw	$v0,Ptr_Glob
	addu	$a0,$v0,48
.L35:
	lw	$a3,0($v0)
	lw	$t0,4($v0)
	lw	$t1,8($v0)
	lw	$t2,12($v0)
	sw	$a3,0($v1)
	sw	$t0,4($v1)
	sw	$t1,8($v1)
	sw	$t2,12($v1)
	addu	$v0,$v0,16
	.set	noreorder
	.set	nomacro
	bne	$v0,$a0,.L35
	addu	$v1,$v1,16
	.set	macro
	.set	reorder

	li	$v0,5			# 0x00000005
	sw	$v0,12($s1)
	sw	$v0,12($s0)
	lw	$v0,0($s1)
	sw	$v0,0($s0)
	.set	noreorder
	.set	nomacro
	jal	Proc_3
	move	$a0,$s0
	.set	macro
	.set	reorder

	lw	$v0,4($s0)
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L36
	move	$v1,$s1
	.set	macro
	.set	reorder

	li	$v0,6			# 0x00000006
	sw	$v0,12($s0)
	lw	$a0,8($s1)
	.set	noreorder
	.set	nomacro
	jal	Proc_6
	addu	$a1,$s0,8
	.set	macro
	.set	reorder

	lw	$v0,Ptr_Glob
	lw	$v0,0($v0)
	sw	$v0,0($s0)
	lw	$a0,12($s0)
	li	$a1,10			# 0x0000000a
	.set	noreorder
	.set	nomacro
	jal	Proc_7
	addu	$a2,$s0,12
	.set	macro
	.set	reorder

	b	.L37
.L36:
	lw	$v0,0($s1)
	addu	$a0,$v0,48
.L38:
	lw	$a3,0($v0)
	lw	$t0,4($v0)
	lw	$t1,8($v0)
	lw	$t2,12($v0)
	sw	$a3,0($v1)
	sw	$t0,4($v1)
	sw	$t1,8($v1)
	sw	$t2,12($v1)
	addu	$v0,$v0,16
	.set	noreorder
	.set	nomacro
	bne	$v0,$a0,.L38
	addu	$v1,$v1,16
	.set	macro
	.set	reorder

.L37:
	lw	$ra,24($sp)
	lw	$s1,20($sp)
	lw	$s0,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,32
	.set	macro
	.set	reorder

	.end	Proc_1
	.size	Proc_1,.-Proc_1
	.align	2
	.globl	Proc_2
	.ent	Proc_2
Proc_2:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lw	$v0,0($a0)
	addu	$v1,$v0,10
	li	$a2,65			# 0x00000041
.L40:
	lbu	$v0,Ch_1_Glob
	bne	$v0,$a2,.L42
	addu	$v1,$v1,-1
	lw	$v0,Int_Glob
	subu	$v0,$v1,$v0
	sw	$v0,0($a0)
	move	$a1,$zero
.L42:
	bne	$a1,$zero,.L40
	j	$ra
	.end	Proc_2
	.size	Proc_2,.-Proc_2
	.align	2
	.globl	Proc_3
	.ent	Proc_3
Proc_3:
	.frame	$sp,24,$ra		# vars= 0, regs= 1/0, args= 16, extra= 0
	.mask	0x80000000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	sw	$ra,16($sp)
	lw	$v0,Ptr_Glob
	beq	$v0,$zero,.L46
	lw	$v0,0($v0)
	sw	$v0,0($a0)
.L46:
	lw	$a2,Ptr_Glob
	li	$a0,10			# 0x0000000a
	lw	$a1,Int_Glob
	.set	noreorder
	.set	nomacro
	jal	Proc_7
	addu	$a2,$a2,12
	.set	macro
	.set	reorder

	lw	$ra,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	Proc_3
	.size	Proc_3,.-Proc_3
	.align	2
	.globl	Proc_4
	.ent	Proc_4
Proc_4:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lbu	$v0,Ch_1_Glob
	xori	$v0,$v0,0x0041
	sltu	$v0,$v0,1
	lw	$v1,Bool_Glob
	or	$v0,$v0,$v1
	sw	$v0,Bool_Glob
	li	$v0,66			# 0x00000042
	sb	$v0,Ch_2_Glob
	j	$ra
	.end	Proc_4
	.size	Proc_4,.-Proc_4
	.align	2
	.globl	Proc_5
	.ent	Proc_5
Proc_5:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	li	$v0,65			# 0x00000041
	sb	$v0,Ch_1_Glob
	sw	$zero,Bool_Glob
	j	$ra
	.end	Proc_5
	.size	Proc_5,.-Proc_5
	.align	2
	.globl	Proc_6
	.ent	Proc_6
Proc_6:
	.frame	$sp,32,$ra		# vars= 0, regs= 3/0, args= 16, extra= 0
	.mask	0x80030000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	sw	$ra,24($sp)
	sw	$s1,20($sp)
	sw	$s0,16($sp)
	move	$s1,$a0
	move	$s0,$a1
	.set	noreorder
	.set	nomacro
	jal	Func_3
	sw	$s1,0($s0)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L63
	sltu	$v0,$s1,5
	.set	macro
	.set	reorder

	li	$v0,3			# 0x00000003
	sw	$v0,0($s0)
	sltu	$v0,$s1,5
.L63:
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L51
	sll	$v1,$s1,2
	.set	macro
	.set	reorder

	lui	$v0,%hi(.L59) # high
	addiu	$v0,$v0,%lo(.L59) # low
	addu	$v1,$v1,$v0
	lw	$v0,0($v1)
	j	$v0
	.rdata
	.align	0
	.align	3
.L59:
	.word	.L61
	.word	.L53
	.word	.L56
	.word	.L51
	.word	.L58
	.text
.L53:
	lw	$v0,Int_Glob
	slt	$v0,$v0,101
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L62
	li	$v0,3			# 0x00000003
	.set	macro
	.set	reorder

.L61:
	.set	noreorder
	.set	nomacro
	b	.L51
	sw	$zero,0($s0)
	.set	macro
	.set	reorder

.L56:
	.set	noreorder
	.set	nomacro
	b	.L62
	li	$v0,1			# 0x00000001
	.set	macro
	.set	reorder

.L58:
	li	$v0,2			# 0x00000002
.L62:
	sw	$v0,0($s0)
.L51:
	lw	$ra,24($sp)
	lw	$s1,20($sp)
	lw	$s0,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,32
	.set	macro
	.set	reorder

	.end	Proc_6
	.size	Proc_6,.-Proc_6
	.align	2
	.globl	Proc_7
	.ent	Proc_7
Proc_7:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	addu	$a0,$a0,2
	addu	$a1,$a1,$a0
	.set	noreorder
	.set	nomacro
	j	$ra
	sw	$a1,0($a2)
	.set	macro
	.set	reorder

	.end	Proc_7
	.size	Proc_7,.-Proc_7
	.align	2
	.globl	Proc_8
	.ent	Proc_8
Proc_8:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	addu	$t0,$a2,5
	sll	$v0,$t0,2
	addu	$v0,$v0,$a0
	sw	$a3,0($v0)
	sw	$a3,4($v0)
	sw	$t0,120($v0)
	addu	$a2,$a2,6
	slt	$a2,$a2,$t0
	.set	noreorder
	.set	nomacro
	bne	$a2,$zero,.L67
	move	$v1,$t0
	.set	macro
	.set	reorder

	sll	$v0,$t0,1
	addu	$v0,$v0,$t0
	sll	$v0,$v0,3
	addu	$v0,$v0,$t0
	sll	$v0,$v0,3
	addu	$a3,$v0,$a1
	addu	$a2,$t0,1
	sll	$v0,$v1,2
.L71:
	addu	$v0,$v0,$a3
	sw	$t0,0($v0)
	addu	$v1,$v1,1
	slt	$v0,$a2,$v1
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L71
	sll	$v0,$v1,2
	.set	macro
	.set	reorder

.L67:
	sll	$v1,$t0,1
	addu	$v1,$v1,$t0
	sll	$v0,$v1,4
	addu	$v1,$v1,$v0
	sll	$v1,$v1,2
	addu	$v1,$v1,$a1
	lw	$v0,-4($v1)
	addu	$v0,$v0,1
	sw	$v0,-4($v1)
	sll	$v0,$t0,2
	addu	$v0,$v0,$a0
	lw	$v0,0($v0)
	sw	$v0,4000($v1)
	li	$v0,5			# 0x00000005
	sw	$v0,Int_Glob
	j	$ra
	.end	Proc_8
	.size	Proc_8,.-Proc_8
	.align	2
	.globl	Func_1
	.ent	Func_1
Func_1:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	andi	$a0,$a0,0x00ff
	andi	$a1,$a1,0x00ff
	.set	noreorder
	.set	nomacro
	bne	$a0,$a1,.L73
	move	$v0,$zero
	.set	macro
	.set	reorder

	sb	$a0,Ch_1_Glob
	li	$v0,1			# 0x00000001
.L73:
	j	$ra
	.end	Func_1
	.size	Func_1,.-Func_1
	.align	2
	.globl	Func_2
	.ent	Func_2
Func_2:
	.frame	$sp,40,$ra		# vars= 0, regs= 5/0, args= 16, extra= 0
	.mask	0x800f0000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,40
	sw	$ra,32($sp)
	sw	$s3,28($sp)
	sw	$s2,24($sp)
	sw	$s1,20($sp)
	sw	$s0,16($sp)
	move	$s2,$a0
	move	$s3,$a1
	li	$s0,2			# 0x00000002
	addu	$v0,$s2,$s0
.L90:
	addu	$v1,$s0,$s3
	lbu	$a0,0($v0)
	lbu	$a1,1($v1)
	jal	Func_1
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L89
	slt	$v0,$s0,3
	.set	macro
	.set	reorder

	li	$s1,65			# 0x00000041
	addu	$s0,$s0,1
	slt	$v0,$s0,3
.L89:
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L90
	addu	$v0,$s2,$s0
	.set	macro
	.set	reorder

	addu	$v0,$s1,-87
	sltu	$v0,$v0,3
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L91
	li	$v0,82			# 0x00000052
	.set	macro
	.set	reorder

	li	$s0,7			# 0x00000007
.L91:
	.set	noreorder
	.set	nomacro
	beq	$s1,$v0,.L88
	move	$a0,$s2
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	strcmp
	move	$a1,$s3
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bgtz	$v0,.L85
	addu	$s0,$s0,7
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L87
	move	$v0,$zero
	.set	macro
	.set	reorder

.L85:
	sw	$s0,Int_Glob
.L88:
	li	$v0,1			# 0x00000001
.L87:
	lw	$ra,32($sp)
	lw	$s3,28($sp)
	lw	$s2,24($sp)
	lw	$s1,20($sp)
	lw	$s0,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,40
	.set	macro
	.set	reorder

	.end	Func_2
	.size	Func_2,.-Func_2
	.align	2
	.globl	Func_3
	.ent	Func_3
Func_3:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	xori	$v0,$a0,0x0002
	.set	noreorder
	.set	nomacro
	j	$ra
	sltu	$v0,$v0,1
	.set	macro
	.set	reorder

	.end	Func_3
	.size	Func_3,.-Func_3
