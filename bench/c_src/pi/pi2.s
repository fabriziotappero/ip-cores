	.file	1 "pi2.c"

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
	.globl	a
	.sdata
	.align	0
	.align	2
a:
	.size	a,4
	.word	10000
	.globl	c
	.align	2
c:
	.size	c,4
	.word	56
	.rdata
	.align	0
	.align	2
.LC0:
	.ascii	"Calculating pi, it may take some minutes.\n\000"
	.align	2
.LC1:
	.ascii	"\000"
	.align	2
.LC2:
	.ascii	"$finish\000"

	.comm	b,4

	.comm	d,4

	.comm	e,4

	.comm	f,228

	.comm	g,4

	.text
	.text
	.align	2
	.globl	print_uart
	.ent	print_uart
print_uart:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lbu	$v0,0($a0)
	beq	$v0,$zero,.L3
	li	$v1,16380			# 0x00003ffc
.L5:
	#.set	volatile
	lw	$v0,0($v1)
	#.set	novolatile
	andi	$v0,$v0,0x0100
	bne	$v0,$zero,.L5
	lbu	$v0,0($a0)
	#.set	volatile
	sb	$v0,0($v1)
	#.set	novolatile
	addu	$a0,$a0,1
	lbu	$v0,0($a0)
	bne	$v0,$zero,.L5
.L3:
	j	$ra
	.end	print_uart
	.size	print_uart,.-print_uart
	.align	2
	.globl	putc_uart
	.ent	putc_uart
putc_uart:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	andi	$a0,$a0,0x00ff
	li	$v1,16380			# 0x00003ffc
.L11:
	#.set	volatile
	lw	$v0,0($v1)
	#.set	novolatile
	andi	$v0,$v0,0x0100
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L11
	li	$v0,16380			# 0x00003ffc
	.set	macro
	.set	reorder

	#.set	volatile
	sb	$a0,0($v0)
	#.set	novolatile
	j	$ra
	.end	putc_uart
	.size	putc_uart,.-putc_uart
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
	beq	$v0,$zero,.L17
	move	$v1,$v0
	.set	macro
	.set	reorder

	li	$a1,16368			# 0x00003ff0
	move	$v0,$v1
.L20:
	#.set	volatile
	sb	$v0,0($a1)
	#.set	novolatile
	addu	$a0,$a0,1
	lbu	$v1,0($a0)
	.set	noreorder
	.set	nomacro
	bne	$v1,$zero,.L20
	move	$v0,$v1
	.set	macro
	.set	reorder

.L17:
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
	li	$v0,16368			# 0x00003ff0
	#.set	volatile
	sb	$a0,0($v0)
	#.set	novolatile
	j	$ra
	.end	print_char
	.size	print_char,.-print_char
	.align	2
	.globl	print_num
	.ent	print_num
print_num:
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
	li	$s1,1000			# 0x000003e8
	li	$s3,-858993459			# 0xcccccccd
.L26:
	divu	$s0,$s2,$s1
	addu	$a0,$s0,48
	.set	noreorder
	.set	nomacro
	jal	print_char
	andi	$a0,$a0,0x00ff
	.set	macro
	.set	reorder

	mult	$s0,$s1
	mflo	$v0
	subu	$s2,$s2,$v0
	multu	$s1,$s3
	mfhi	$v0
	srl	$s1,$v0,3
	bne	$s1,$zero,.L26
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

	.end	print_num
	.size	print_num,.-print_num
	.text
	.align	2
	.globl	main2
	.ent	main2
main2:
	.frame	$sp,24,$ra		# vars= 0, regs= 2/0, args= 16, extra= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	sw	$ra,20($sp)
	sw	$s0,16($sp)
	lui	$a0,%hi(.LC0) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC0) # low
	.set	macro
	.set	reorder

	lw	$v1,b
	lw	$v0,c
	.set	noreorder
	.set	nomacro
	beq	$v1,$v0,.L30
	lui	$v0,%hi(f) # high
	.set	macro
	.set	reorder

	addiu	$a2,$v0,%lo(f) # low
	lw	$v0,a
	li	$v1,1717960704			# 0x66660000
	ori	$v1,$v1,0x6667
	mult	$v0,$v1
	mfhi	$t0
	sra	$v1,$t0,1
	sra	$v0,$v0,31
	subu	$a1,$v1,$v0
	lw	$a0,c
.L32:
	lw	$v1,b
	sll	$v0,$v1,2
	addu	$v0,$v0,$a2
	sw	$a1,0($v0)
	addu	$v1,$v1,1
	sw	$v1,b
	bne	$v1,$a0,.L32
.L30:
	sw	$zero,d
	lw	$v0,c
	sll	$v0,$v0,1
	sw	$v0,g
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L44
	lui	$v0,%hi(f) # high
	.set	macro
	.set	reorder

	addiu	$s0,$v0,%lo(f) # low
.L37:
	lw	$v0,c
	sw	$v0,b
	lw	$a3,a
	b	.L38
.L40:
	lw	$v1,d
	lw	$v0,b
	mult	$v1,$v0
	mflo	$t0
	sw	$t0,d
.L38:
	lw	$a2,b
	sll	$a1,$a2,2
	addu	$a1,$a1,$s0
	lw	$v0,0($a1)
	mult	$v0,$a3
	mflo	$v0
	lw	$v1,d
	addu	$v1,$v0,$v1
	sw	$v1,d
	lw	$a0,g
	addu	$v0,$a0,-1
	sw	$v0,g
	div	$v1,$v1,$v0
	mfhi	$v0
	sw	$v0,0($a1)
	sw	$v1,d
	addu	$a0,$a0,-2
	sw	$a0,g
	addu	$a2,$a2,-1
	sw	$a2,b
	bne	$a2,$zero,.L40
	lw	$v0,c
	addu	$v0,$v0,-14
	sw	$v0,c
	lw	$v0,a
	div	$v1,$v1,$v0
	lw	$a0,e
	.set	noreorder
	.set	nomacro
	jal	print_num
	addu	$a0,$v1,$a0
	.set	macro
	.set	reorder

	lw	$v1,d
	lw	$v0,a
	rem	$v0,$v1,$v0
	sw	$v0,e
	sw	$zero,d
	lw	$v0,c
	sll	$v0,$v0,1
	sw	$v0,g
	bne	$v0,$zero,.L37
.L44:
	.set	noreorder
	.set	nomacro
	jal	print_char
	li	$a0,10			# 0x0000000a
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC1) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC1) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC2) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC2) # low
	.set	macro
	.set	reorder

	lw	$ra,20($sp)
	lw	$s0,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	main2
	.size	main2,.-main2
