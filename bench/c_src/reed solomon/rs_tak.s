	.file	1 "rs_tak.c"

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
	.sdata
	.align	0
	.align	2
lfsr_state:
	.size	lfsr_state,4
	.word	1
	.globl	Pp
	.data
	.align	0
	.align	2
Pp:
	.size	Pp,36
	.word	1
	.word	0
	.word	1
	.word	1
	.word	1
	.word	0
	.word	0
	.word	0
	.word	1
	.rdata
	.align	0
	.align	2
.LC0:
	.ascii	"index dump\n\000"
	.align	2
.LC1:
	.ascii	" \000"
	.align	2
.LC2:
	.ascii	"\n\000"
	.align	2
.LC3:
	.ascii	"Alpha_to dump\n\000"
	.rdata
	.align	0
	.align	2
.LC4:
	.ascii	"Gg dump\n\000"
	.rdata
	.align	0
	.align	2
.LC5:
	.ascii	"It takes very very long time for RTL Simulation.\n\000"
	.align	2
.LC6:
	.ascii	"Reed-Solomon code is \000"
	.align	2
.LC7:
	.ascii	"over GF(\000"
	.align	2
.LC8:
	.ascii	")\n\000"
	.align	2
.LC9:
	.ascii	"test erasures: \000"
	.align	2
.LC10:
	.ascii	"errors \000"
	.align	2
.LC11:
	.ascii	"Warning: \000"
	.align	2
.LC12:
	.ascii	"errors and \000"
	.align	2
.LC13:
	.ascii	"erasures exceeds the correction ability of the code\n\000"
	.align	2
.LC14:
	.ascii	"Init_RS Done\000"
	.align	2
.LC15:
	.ascii	" Trial \000"
	.align	2
.LC16:
	.ascii	"Making Encode Data\000"
	.align	2
.LC17:
	.ascii	"\n"
	.ascii	" erasing:\000"
	.align	2
.LC18:
	.ascii	" erroring:\000"
	.align	2
.LC19:
	.ascii	"errs + erasures corrected: \000"
	.align	2
.LC20:
	.ascii	"RS decoder detected failure\n\000"
	.align	2
.LC21:
	.ascii	" Undetected decoding failure!\n\000"
	.align	2
.LC22:
	.ascii	" \n\n"
	.ascii	"Trials: \000"
	.align	2
.LC23:
	.ascii	" decoding failures: \000"
	.align	2
.LC24:
	.ascii	" not detected by decoder: \000"
	.align	2
.LC25:
	.ascii	"$finish\000"

	.comm	Alpha_to,1024

	.comm	Index_of,1024

	.comm	Gg,132

	.comm	data,255

	.comm	tdata,255

	.comm	ddata,255

	.comm	eras_pos,1020

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
	.globl	read_uart
	.ent	read_uart
read_uart:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	li	$v0,16380			# 0x00003ffc
	#.set	volatile
	lw	$v0,0($v0)
	#.set	novolatile
	.set	noreorder
	.set	nomacro
	j	$ra
	andi	$v0,$v0,0x00ff
	.set	macro
	.set	reorder

	.end	read_uart
	.size	read_uart,.-read_uart
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
	beq	$v0,$zero,.L18
	move	$v1,$v0
	.set	macro
	.set	reorder

	li	$a1,16368			# 0x00003ff0
	move	$v0,$v1
.L21:
	#.set	volatile
	sb	$v0,0($a1)
	#.set	novolatile
	addu	$a0,$a0,1
	lbu	$v1,0($a0)
	.set	noreorder
	.set	nomacro
	bne	$v1,$zero,.L21
	move	$v0,$v1
	.set	macro
	.set	reorder

.L18:
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
	.globl	print_uchar
	.ent	print_uchar
print_uchar:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	andi	$a0,$a0,0x00ff
	li	$v0,16369			# 0x00003ff1
	#.set	volatile
	sb	$a0,0($v0)
	#.set	novolatile
	j	$ra
	.end	print_uchar
	.size	print_uchar,.-print_uchar
	.text
	.align	2
	.globl	random
	.ent	random
random:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lw	$v1,lfsr_state
	andi	$v0,$v1,0x0001
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L25
	srl	$v0,$v1,1
	.set	macro
	.set	reorder

	li	$v1,-2147483648			# 0x80000000
	ori	$v1,$v1,0x0057
	.set	noreorder
	.set	nomacro
	b	.L27
	xor	$v0,$v0,$v1
	.set	macro
	.set	reorder

.L25:
	lw	$v0,lfsr_state
	srl	$v0,$v0,1
.L27:
	sw	$v0,lfsr_state
	lw	$v0,lfsr_state
	j	$ra
	.end	random
	.size	random,.-random
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
.L32:
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
	bne	$s1,$zero,.L32
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
	.align	2
	.globl	memcpy
	.ent	memcpy
memcpy:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	beq	$a2,$zero,.L36
	move	$v1,$zero
	.set	macro
	.set	reorder

.L38:
	lbu	$v0,0($a1)
	sb	$v0,0($a0)
	addu	$a1,$a1,1
	addu	$v1,$v1,1
	sltu	$v0,$v1,$a2
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L38
	addu	$a0,$a0,1
	.set	macro
	.set	reorder

.L36:
	j	$ra
	.end	memcpy
	.size	memcpy,.-memcpy
	.align	2
	.globl	memcmp
	.ent	memcmp
memcmp:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	beq	$a2,$zero,.L42
	move	$a3,$zero
	.set	macro
	.set	reorder

.L44:
	lbu	$v1,0($a0)
	lbu	$v0,0($a1)
	addu	$a1,$a1,1
	.set	noreorder
	.set	nomacro
	beq	$v1,$v0,.L43
	addu	$a0,$a0,1
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L47
	li	$v0,1			# 0x00000001
	.set	macro
	.set	reorder

.L43:
	addu	$a3,$a3,1
	sltu	$v0,$a3,$a2
	bne	$v0,$zero,.L44
.L42:
	move	$v0,$zero
.L47:
	j	$ra
	.end	memcmp
	.size	memcmp,.-memcmp
	.text
	.align	2
	.globl	init_rs
	.ent	init_rs
init_rs:
	.frame	$sp,24,$ra		# vars= 0, regs= 1/0, args= 16, extra= 0
	.mask	0x80000000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	sw	$ra,16($sp)
	jal	generate_gf
	jal	gen_poly
	lw	$ra,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	init_rs
	.size	init_rs,.-init_rs
	.text
	.align	2
	.globl	generate_gf
	.ent	generate_gf
generate_gf:
	.frame	$sp,32,$ra		# vars= 0, regs= 4/0, args= 16, extra= 0
	.mask	0x80070000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	sw	$ra,28($sp)
	sw	$s2,24($sp)
	sw	$s1,20($sp)
	sw	$s0,16($sp)
	li	$a1,1			# 0x00000001
	lui	$v0,%hi(Alpha_to+32) # high
	sw	$zero,%lo(Alpha_to+32)($v0)
	move	$s0,$zero
	lui	$v0,%hi(Alpha_to) # high
	addiu	$a0,$v0,%lo(Alpha_to) # low
	lui	$v0,%hi(Index_of) # high
	addiu	$a3,$v0,%lo(Index_of) # low
	lui	$v0,%hi(Pp) # high
	addiu	$a2,$v0,%lo(Pp) # low
.L63:
	sll	$v1,$s0,2
	addu	$v0,$v1,$a0
	sw	$a1,0($v0)
	sll	$v0,$a1,2
	addu	$v0,$v0,$a3
	sw	$s0,0($v0)
	addu	$v1,$v1,$a2
	lw	$v0,0($v1)
	beq	$v0,$zero,.L64
	lw	$v0,32($a0)
	xor	$v0,$a1,$v0
	sw	$v0,32($a0)
.L64:
	addu	$s0,$s0,1
	slt	$v0,$s0,8
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L63
	sll	$a1,$a1,1
	.set	macro
	.set	reorder

	lui	$v1,%hi(Index_of) # high
	addiu	$v1,$v1,%lo(Index_of) # low
	lui	$v0,%hi(Alpha_to+32) # high
	lw	$v0,%lo(Alpha_to+32)($v0)
	sll	$v0,$v0,2
	addu	$v0,$v0,$v1
	li	$v1,8			# 0x00000008
	sw	$v1,0($v0)
	sra	$a1,$a1,1
	li	$s0,9			# 0x00000009
	lui	$v0,%hi(Alpha_to) # high
	addiu	$a2,$v0,%lo(Alpha_to) # low
	lui	$v0,%hi(Index_of) # high
	addiu	$a3,$v0,%lo(Index_of) # low
	addu	$v0,$s0,-1
.L84:
	sll	$v0,$v0,2
	addu	$v0,$v0,$a2
	lw	$v1,0($v0)
	slt	$v0,$v1,$a1
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L70
	sll	$v0,$s0,2
	.set	macro
	.set	reorder

	addu	$v0,$v0,$a2
	xor	$v1,$a1,$v1
	sll	$v1,$v1,1
	lw	$a0,32($a2)
	.set	noreorder
	.set	nomacro
	b	.L83
	xor	$v1,$v1,$a0
	.set	macro
	.set	reorder

.L70:
	addu	$v0,$v0,$a2
	addu	$v1,$s0,-1
	sll	$v1,$v1,2
	addu	$v1,$v1,$a2
	lw	$v1,0($v1)
	sll	$v1,$v1,1
.L83:
	sw	$v1,0($v0)
	sll	$v0,$s0,2
	addu	$v0,$v0,$a2
	lw	$v0,0($v0)
	sll	$v0,$v0,2
	addu	$v0,$v0,$a3
	sw	$s0,0($v0)
	addu	$s0,$s0,1
	slt	$v0,$s0,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L84
	addu	$v0,$s0,-1
	.set	macro
	.set	reorder

	lui	$v1,%hi(Index_of) # high
	li	$v0,255			# 0x000000ff
	sw	$v0,%lo(Index_of)($v1)
	lui	$v0,%hi(Alpha_to+1020) # high
	sw	$zero,%lo(Alpha_to+1020)($v0)
	lui	$a0,%hi(.LC0) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC0) # low
	.set	macro
	.set	reorder

	move	$s0,$zero
	lui	$v0,%hi(Index_of) # high
	addiu	$s2,$v0,%lo(Index_of) # low
	lui	$s1,%hi(.LC1) # high
	sll	$v0,$s0,2
.L85:
	addu	$v0,$v0,$s2
	lbu	$a0,3($v0)
	.set	noreorder
	.set	nomacro
	jal	print_uchar
	addu	$s0,$s0,1
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$s1,%lo(.LC1) # low
	.set	macro
	.set	reorder

	slt	$v0,$s0,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L85
	sll	$v0,$s0,2
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC2) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC2) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC3) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC3) # low
	.set	macro
	.set	reorder

	move	$s0,$zero
	lui	$v0,%hi(Alpha_to) # high
	addiu	$s2,$v0,%lo(Alpha_to) # low
	lui	$s1,%hi(.LC1) # high
	sll	$v0,$s0,2
.L86:
	addu	$v0,$v0,$s2
	lbu	$a0,3($v0)
	.set	noreorder
	.set	nomacro
	jal	print_uchar
	addu	$s0,$s0,1
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$s1,%lo(.LC1) # low
	.set	macro
	.set	reorder

	slt	$v0,$s0,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L86
	sll	$v0,$s0,2
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC2) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC2) # low
	.set	macro
	.set	reorder

	lw	$ra,28($sp)
	lw	$s2,24($sp)
	lw	$s1,20($sp)
	lw	$s0,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,32
	.set	macro
	.set	reorder

	.end	generate_gf
	.size	generate_gf,.-generate_gf
	.text
	.align	2
	.globl	gen_poly
	.ent	gen_poly
gen_poly:
	.frame	$sp,32,$ra		# vars= 0, regs= 4/0, args= 16, extra= 0
	.mask	0x80070000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	sw	$ra,28($sp)
	sw	$s2,24($sp)
	sw	$s1,20($sp)
	sw	$s0,16($sp)
	lui	$v1,%hi(Gg) # high
	addiu	$a0,$v1,%lo(Gg) # low
	lui	$v0,%hi(Alpha_to+4) # high
	lw	$v0,%lo(Alpha_to+4)($v0)
	sw	$v0,%lo(Gg)($v1)
	li	$v0,1			# 0x00000001
	sw	$v0,4($a0)
	li	$s0,2			# 0x00000002
	move	$t1,$v1
	move	$v0,$v1
	addiu	$a2,$v0,%lo(Gg) # low
	li	$t2,1			# 0x00000001
	lui	$v0,%hi(Index_of) # high
	addiu	$t0,$v0,%lo(Index_of) # low
	lui	$v0,%hi(Alpha_to) # high
	addiu	$a3,$v0,%lo(Alpha_to) # low
	sll	$v0,$s0,2
.L125:
	addu	$v0,$v0,$a2
	addu	$a1,$s0,-1
	.set	noreorder
	.set	nomacro
	blez	$a1,.L93
	sw	$t2,0($v0)
	.set	macro
	.set	reorder

	sll	$v0,$a1,2
.L122:
	addu	$v0,$v0,$a2
	lw	$v0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L96
	sll	$v0,$v0,2
	.set	macro
	.set	reorder

	addu	$v0,$v0,$t0
	lw	$v0,0($v0)
	addu	$v1,$s0,$v0
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L120
	sll	$a0,$a1,2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L121:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L121
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$a0,$a1,2
.L120:
	addu	$a0,$a0,$a2
	addu	$v0,$a1,-1
	sll	$v0,$v0,2
	addu	$v0,$v0,$a2
	sll	$v1,$v1,2
	addu	$v1,$v1,$a3
	lw	$v0,0($v0)
	lw	$v1,0($v1)
	xor	$v0,$v0,$v1
	.set	noreorder
	.set	nomacro
	b	.L94
	sw	$v0,0($a0)
	.set	macro
	.set	reorder

.L96:
	sll	$v0,$a1,2
	addu	$v0,$v0,$a2
	addu	$v1,$a1,-1
	sll	$v1,$v1,2
	addu	$v1,$v1,$a2
	lw	$v1,0($v1)
	sw	$v1,0($v0)
.L94:
	addu	$a1,$a1,-1
	.set	noreorder
	.set	nomacro
	bgtz	$a1,.L122
	sll	$v0,$a1,2
	.set	macro
	.set	reorder

.L93:
	lw	$v0,%lo(Gg)($t1)
	sll	$v0,$v0,2
	addu	$v0,$v0,$t0
	lw	$v0,0($v0)
	addu	$v1,$s0,$v0
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L123
	sll	$v0,$v1,2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L124:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L124
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$v1,2
.L123:
	addu	$v0,$v0,$a3
	lw	$v0,0($v0)
	sw	$v0,%lo(Gg)($t1)
	addu	$s0,$s0,1
	slt	$v0,$s0,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L125
	sll	$v0,$s0,2
	.set	macro
	.set	reorder

	move	$s0,$zero
	lui	$v0,%hi(Gg) # high
	addiu	$a1,$v0,%lo(Gg) # low
	lui	$v0,%hi(Index_of) # high
	addiu	$a0,$v0,%lo(Index_of) # low
	sll	$v1,$s0,2
.L126:
	addu	$v1,$v1,$a1
	lw	$v0,0($v1)
	sll	$v0,$v0,2
	addu	$v0,$v0,$a0
	lw	$v0,0($v0)
	sw	$v0,0($v1)
	addu	$s0,$s0,1
	slt	$v0,$s0,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L126
	sll	$v1,$s0,2
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC4) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC4) # low
	.set	macro
	.set	reorder

	move	$s0,$zero
	lui	$v0,%hi(Gg) # high
	addiu	$s2,$v0,%lo(Gg) # low
	lui	$s1,%hi(.LC1) # high
	sll	$v0,$s0,2
.L127:
	addu	$v0,$v0,$s2
	lbu	$a0,3($v0)
	.set	noreorder
	.set	nomacro
	jal	print_uchar
	addu	$s0,$s0,1
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$s1,%lo(.LC1) # low
	.set	macro
	.set	reorder

	slt	$v0,$s0,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L127
	sll	$v0,$s0,2
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC2) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC2) # low
	.set	macro
	.set	reorder

	lw	$ra,28($sp)
	lw	$s2,24($sp)
	lw	$s1,20($sp)
	lw	$s0,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,32
	.set	macro
	.set	reorder

	.end	gen_poly
	.size	gen_poly,.-gen_poly
	.align	2
	.globl	encode_rs
	.ent	encode_rs
encode_rs:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	move	$t6,$a0
	li	$v1,31			# 0x0000001f
.L132:
	addu	$v0,$a1,$v1
	addu	$v1,$v1,-1
	.set	noreorder
	.set	nomacro
	bgez	$v1,.L132
	sb	$zero,0($v0)
	.set	macro
	.set	reorder

	li	$t0,222			# 0x000000de
	lui	$v0,%hi(Index_of) # high
	addiu	$t5,$v0,%lo(Index_of) # low
	li	$t2,255			# 0x000000ff
	lui	$t4,%hi(Gg) # high
	move	$v0,$t4
	addiu	$t3,$v0,%lo(Gg) # low
	lui	$v0,%hi(Alpha_to) # high
	addiu	$t1,$v0,%lo(Alpha_to) # low
.L137:
	addu	$v0,$t6,$t0
	lbu	$v0,0($v0)
	lbu	$v1,31($a1)
	xor	$v0,$v0,$v1
	sll	$v0,$v0,2
	addu	$v0,$v0,$t5
	lw	$a3,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$a3,$t2,.L138
	li	$a2,31			# 0x0000001f
	.set	macro
	.set	reorder

	sll	$v0,$a2,2
.L165:
	addu	$v0,$v0,$t3
	lw	$v0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$t2,.L143
	addu	$v1,$a3,$v0
	.set	macro
	.set	reorder

	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L163
	addu	$a0,$a1,$a2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L164:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L164
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	addu	$a0,$a1,$a2
.L163:
	sll	$v0,$v1,2
	addu	$v0,$v0,$t1
	lbu	$v1,-1($a0)
	lbu	$v0,3($v0)
	xor	$v1,$v1,$v0
	.set	noreorder
	.set	nomacro
	b	.L141
	sb	$v1,0($a0)
	.set	macro
	.set	reorder

.L143:
	addu	$v0,$a1,$a2
	lbu	$v1,-1($v0)
	sb	$v1,0($v0)
.L141:
	addu	$a2,$a2,-1
	.set	noreorder
	.set	nomacro
	bgtz	$a2,.L165
	sll	$v0,$a2,2
	.set	macro
	.set	reorder

	lw	$v0,%lo(Gg)($t4)
	addu	$v1,$a3,$v0
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L166
	sll	$v0,$v1,2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L167:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L167
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$v1,2
.L166:
	addu	$v0,$v0,$t1
	lbu	$v0,3($v0)
	.set	noreorder
	.set	nomacro
	b	.L136
	sb	$v0,0($a1)
	.set	macro
	.set	reorder

.L138:
.L160:
	addu	$v0,$a1,$a2
	lbu	$v1,-1($v0)
	addu	$a2,$a2,-1
	.set	noreorder
	.set	nomacro
	bgtz	$a2,.L160
	sb	$v1,0($v0)
	.set	macro
	.set	reorder

	sb	$zero,0($a1)
.L136:
	addu	$t0,$t0,-1
	bgez	$t0,.L137
	.set	noreorder
	.set	nomacro
	j	$ra
	move	$v0,$zero
	.set	macro
	.set	reorder

	.end	encode_rs
	.size	encode_rs,.-encode_rs
	.align	2
	.globl	eras_dec_rs
	.ent	eras_dec_rs
eras_dec_rs:
	.frame	$sp,2104,$ra		# vars= 2096, regs= 2/0, args= 0, extra= 0
	.mask	0x00030000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,2104
	sw	$s1,2100($sp)
	sw	$s0,2096($sp)
	move	$s0,$a0
	li	$a3,254			# 0x000000fe
	lui	$v0,%hi(Index_of) # high
	addiu	$a0,$v0,%lo(Index_of) # low
.L172:
	sll	$v0,$a3,2
	addu	$v1,$sp,$v0
	addu	$v0,$s0,$a3
	lbu	$v0,0($v0)
	sll	$v0,$v0,2
	addu	$v0,$v0,$a0
	lw	$v0,0($v0)
	addu	$a3,$a3,-1
	.set	noreorder
	.set	nomacro
	bgez	$a3,.L172
	sw	$v0,0($v1)
	.set	macro
	.set	reorder

	move	$a0,$zero
	li	$a3,1			# 0x00000001
	li	$t3,255			# 0x000000ff
	lui	$v0,%hi(Alpha_to) # high
	addiu	$t2,$v0,%lo(Alpha_to) # low
	lui	$v0,%hi(Index_of) # high
	addiu	$t4,$v0,%lo(Index_of) # low
.L177:
	move	$t1,$zero
	move	$t0,$t1
	sll	$v0,$t0,2
.L375:
	addu	$v0,$sp,$v0
	lw	$v0,0($v0)
	beq	$v0,$t3,.L180
	mult	$a3,$t0
	mflo	$s1
	addu	$v1,$s1,$v0
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L373
	sll	$v0,$v1,2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L374:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L374
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$v1,2
.L373:
	addu	$v0,$v0,$t2
	lw	$v0,0($v0)
	xor	$t1,$t1,$v0
.L180:
	addu	$t0,$t0,1
	slt	$v0,$t0,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L375
	sll	$v0,$t0,2
	.set	macro
	.set	reorder

	sll	$v0,$a3,2
	addu	$v1,$sp,$v0
	sll	$v0,$t1,2
	addu	$v0,$v0,$t4
	lw	$v0,0($v0)
	sw	$v0,1160($v1)
	addu	$a3,$a3,1
	slt	$v0,$a3,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L177
	or	$a0,$a0,$t1
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bne	$a0,$zero,.L190
	li	$v1,31			# 0x0000001f
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L364
	move	$v0,$zero
	.set	macro
	.set	reorder

.L190:
	addu	$a0,$sp,1028
.L194:
	sll	$v0,$v1,2
	addu	$v0,$a0,$v0
	addu	$v1,$v1,-1
	.set	noreorder
	.set	nomacro
	bgez	$v1,.L194
	sw	$zero,0($v0)
	.set	macro
	.set	reorder

	li	$v0,1			# 0x00000001
	.set	noreorder
	.set	nomacro
	blez	$a2,.L196
	sw	$v0,1024($sp)
	.set	macro
	.set	reorder

	lui	$v1,%hi(Alpha_to) # high
	addiu	$v1,$v1,%lo(Alpha_to) # low
	lw	$v0,0($a1)
	sll	$v0,$v0,2
	addu	$v0,$v0,$v1
	lw	$v0,0($v0)
	sw	$v0,1028($sp)
	li	$a3,1			# 0x00000001
	slt	$v0,$a3,$a2
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L196
	lui	$v0,%hi(Index_of) # high
	.set	macro
	.set	reorder

	addiu	$t6,$v0,%lo(Index_of) # low
	addu	$t2,$sp,1024
	li	$t5,255			# 0x000000ff
	lui	$v0,%hi(Alpha_to) # high
	addiu	$t4,$v0,%lo(Alpha_to) # low
	sll	$v0,$a3,2
.L378:
	addu	$v0,$v0,$a1
	lw	$t3,0($v0)
	addu	$t0,$a3,1
	.set	noreorder
	.set	nomacro
	blez	$t0,.L199
	addu	$v0,$t0,-1
	.set	macro
	.set	reorder

.L377:
	sll	$v0,$v0,2
	addu	$v0,$t2,$v0
	lw	$v0,0($v0)
	sll	$v0,$v0,2
	addu	$v0,$v0,$t6
	lw	$t1,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$t1,$t5,.L203
	addu	$v1,$t3,$t1
	.set	macro
	.set	reorder

	slt	$v0,$v1,255
	bne	$v0,$zero,.L208
	addu	$v1,$v1,-255
.L376:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L376
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
.L208:
	sll	$a0,$t0,2
	addu	$a0,$t2,$a0
	sll	$v0,$v1,2
	addu	$v0,$v0,$t4
	lw	$v1,0($a0)
	lw	$v0,0($v0)
	xor	$v1,$v1,$v0
	sw	$v1,0($a0)
.L203:
	addu	$t0,$t0,-1
	.set	noreorder
	.set	nomacro
	bgtz	$t0,.L377
	addu	$v0,$t0,-1
	.set	macro
	.set	reorder

.L199:
	addu	$a3,$a3,1
	slt	$v0,$a3,$a2
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L378
	sll	$v0,$a3,2
	.set	macro
	.set	reorder

.L196:
	move	$a3,$zero
	addu	$a1,$sp,1296
	lui	$v0,%hi(Index_of) # high
	addiu	$t0,$v0,%lo(Index_of) # low
	addu	$a0,$sp,1024
	sll	$v0,$a3,2
.L379:
	addu	$v1,$a1,$v0
	addu	$v0,$a0,$v0
	lw	$v0,0($v0)
	sll	$v0,$v0,2
	addu	$v0,$v0,$t0
	lw	$v0,0($v0)
	sw	$v0,0($v1)
	addu	$a3,$a3,1
	slt	$v0,$a3,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L379
	sll	$v0,$a3,2
	.set	macro
	.set	reorder

	move	$t1,$a2
	move	$t6,$t1
	addu	$t1,$t1,1
	slt	$v0,$t1,33
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L219
	li	$t4,255			# 0x000000ff
	.set	macro
	.set	reorder

	addu	$t2,$sp,1024
	addu	$t7,$sp,1160
	lui	$v0,%hi(Index_of) # high
	addiu	$t5,$v0,%lo(Index_of) # low
	lui	$v0,%hi(Alpha_to) # high
	addiu	$t8,$v0,%lo(Alpha_to) # low
	move	$a1,$zero
.L387:
	.set	noreorder
	.set	nomacro
	blez	$t1,.L222
	move	$a3,$a1
	.set	macro
	.set	reorder

	sll	$v0,$a3,2
.L381:
	addu	$v0,$t2,$v0
	lw	$a0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$a0,$zero,.L223
	subu	$v0,$t1,$a3
	.set	macro
	.set	reorder

	sll	$v0,$v0,2
	addu	$v0,$t7,$v0
	lw	$v1,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v1,$t4,.L223
	sll	$v0,$a0,2
	.set	macro
	.set	reorder

	addu	$v0,$v0,$t5
	lw	$v0,0($v0)
	.set	noreorder
	.set	nomacro
	b	.L370
	addu	$v1,$v0,$v1
	.set	macro
	.set	reorder

.L380:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
.L370:
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L380
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$v1,2
	addu	$v0,$v0,$t8
	lw	$v0,0($v0)
	xor	$a1,$a1,$v0
.L223:
	addu	$a3,$a3,1
	slt	$v0,$a3,$t1
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L381
	sll	$v0,$a3,2
	.set	macro
	.set	reorder

.L222:
	sll	$v0,$a1,2
	addu	$v0,$v0,$t5
	lw	$a1,0($v0)
	.set	noreorder
	.set	nomacro
	bne	$a1,$t4,.L232
	move	$a3,$zero
	.set	macro
	.set	reorder

	li	$a0,31			# 0x0000001f
	addu	$a3,$sp,1300
	addu	$a1,$sp,1296
.L236:
	sll	$v0,$a0,2
	addu	$v1,$a3,$v0
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	addu	$a0,$a0,-1
	.set	noreorder
	.set	nomacro
	bgez	$a0,.L236
	sw	$v0,0($v1)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L218
	sw	$t4,1296($sp)
	.set	macro
	.set	reorder

.L232:
	lw	$v0,1024($sp)
	sw	$v0,1432($sp)
	addu	$t3,$sp,1296
	addu	$t0,$sp,1432
	sll	$v0,$a3,2
.L384:
	addu	$v0,$t3,$v0
	lw	$v0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$t4,.L243
	addu	$v1,$a1,$v0
	.set	macro
	.set	reorder

	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L382
	addu	$v0,$a3,1
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L383:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L383
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	addu	$v0,$a3,1
.L382:
	sll	$v0,$v0,2
	addu	$a0,$t0,$v0
	addu	$v0,$t2,$v0
	sll	$v1,$v1,2
	addu	$v1,$v1,$t8
	lw	$v0,0($v0)
	lw	$v1,0($v1)
	xor	$v0,$v0,$v1
	.set	noreorder
	.set	nomacro
	b	.L241
	sw	$v0,0($a0)
	.set	macro
	.set	reorder

.L243:
	addu	$v0,$a3,1
	sll	$v0,$v0,2
	addu	$v1,$t0,$v0
	addu	$v0,$t2,$v0
	lw	$v0,0($v0)
	sw	$v0,0($v1)
.L241:
	addu	$a3,$a3,1
	slt	$v0,$a3,32
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L384
	sll	$v0,$a3,2
	.set	macro
	.set	reorder

	sll	$v1,$t6,1
	addu	$a0,$t1,$a2
	addu	$v0,$a0,-1
	slt	$v0,$v0,$v1
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L251
	addu	$a3,$sp,1300
	.set	macro
	.set	reorder

	subu	$t6,$a0,$t6
	move	$a3,$zero
	addu	$t0,$sp,1296
	sll	$v0,$a3,2
.L386:
	addu	$a0,$t0,$v0
	addu	$v0,$t2,$v0
	lw	$v0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L256
	sll	$v0,$v0,2
	.set	macro
	.set	reorder

	addu	$v0,$v0,$t5
	lw	$v0,0($v0)
	subu	$v0,$v0,$a1
	addu	$v1,$v0,255
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L257
	move	$v0,$v1
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L385:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L385
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	.set	noreorder
	.set	nomacro
	b	.L257
	move	$v0,$v1
	.set	macro
	.set	reorder

.L256:
	li	$v0,255			# 0x000000ff
.L257:
	sw	$v0,0($a0)
	addu	$a3,$a3,1
	slt	$v0,$a3,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L386
	sll	$v0,$a3,2
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L371
	li	$a0,32			# 0x00000020
	.set	macro
	.set	reorder

.L251:
	li	$a0,31			# 0x0000001f
	addu	$a1,$sp,1296
.L268:
	sll	$v0,$a0,2
	addu	$v1,$a3,$v0
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	addu	$a0,$a0,-1
	.set	noreorder
	.set	nomacro
	bgez	$a0,.L268
	sw	$v0,0($v1)
	.set	macro
	.set	reorder

	sw	$t4,1296($sp)
	li	$a0,32			# 0x00000020
.L371:
	addu	$a1,$sp,1432
.L273:
	sll	$v0,$a0,2
	addu	$v1,$t2,$v0
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	addu	$a0,$a0,-1
	.set	noreorder
	.set	nomacro
	bgez	$a0,.L273
	sw	$v0,0($v1)
	.set	macro
	.set	reorder

.L218:
	addu	$t1,$t1,1
	slt	$v0,$t1,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L387
	move	$a1,$zero
	.set	macro
	.set	reorder

.L219:
	move	$t4,$zero
	move	$a3,$t4
	addu	$a0,$sp,1024
	lui	$v0,%hi(Index_of) # high
	addiu	$a2,$v0,%lo(Index_of) # low
	li	$a1,255			# 0x000000ff
	sll	$v0,$a3,2
.L388:
	addu	$v0,$a0,$v0
	lw	$v1,0($v0)
	sll	$v1,$v1,2
	addu	$v1,$v1,$a2
	lw	$v1,0($v1)
	.set	noreorder
	.set	nomacro
	beq	$v1,$a1,.L278
	sw	$v1,0($v0)
	.set	macro
	.set	reorder

	move	$t4,$a3
.L278:
	addu	$a3,$a3,1
	slt	$v0,$a3,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L388
	sll	$v0,$a3,2
	.set	macro
	.set	reorder

	li	$a0,31			# 0x0000001f
	addu	$a2,$sp,1836
	addu	$a1,$sp,1028
.L285:
	sll	$v0,$a0,2
	addu	$v1,$a2,$v0
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	addu	$a0,$a0,-1
	.set	noreorder
	.set	nomacro
	bgez	$a0,.L285
	sw	$v0,0($v1)
	.set	macro
	.set	reorder

	move	$t5,$zero
	li	$a3,1			# 0x00000001
	addu	$a1,$sp,1832
	li	$a2,255			# 0x000000ff
	lui	$v0,%hi(Alpha_to) # high
	addiu	$t1,$v0,%lo(Alpha_to) # low
.L290:
	move	$t0,$t4
	.set	noreorder
	.set	nomacro
	blez	$t0,.L292
	li	$a0,1			# 0x00000001
	.set	macro
	.set	reorder

	sll	$v0,$t0,2
.L391:
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$a2,.L293
	addu	$v1,$t0,$v0
	.set	macro
	.set	reorder

	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L389
	sll	$v0,$t0,2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L390:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L390
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$t0,2
.L389:
	addu	$v0,$a1,$v0
	sw	$v1,0($v0)
	sll	$v0,$v1,2
	addu	$v0,$v0,$t1
	lw	$v0,0($v0)
	xor	$a0,$a0,$v0
.L293:
	addu	$t0,$t0,-1
	.set	noreorder
	.set	nomacro
	bgtz	$t0,.L391
	sll	$v0,$t0,2
	.set	macro
	.set	reorder

.L292:
	.set	noreorder
	.set	nomacro
	bne	$a0,$zero,.L289
	sll	$v1,$t5,2
	.set	macro
	.set	reorder

	addu	$v0,$sp,$v1
	sw	$a3,1704($v0)
	move	$v1,$v0
	subu	$v0,$a2,$a3
	sw	$v0,1968($v1)
	addu	$t5,$t5,1
.L289:
	addu	$a3,$a3,1
	slt	$v0,$a3,256
	bne	$v0,$zero,.L290
	.set	noreorder
	.set	nomacro
	beq	$t4,$t5,.L304
	move	$t9,$zero
	.set	macro
	.set	reorder

.L368:
	.set	noreorder
	.set	nomacro
	b	.L364
	li	$v0,-1			# 0xffffffff
	.set	macro
	.set	reorder

.L304:
	move	$a3,$t9
	addu	$a2,$sp,1160
	li	$t2,255			# 0x000000ff
	addu	$a1,$sp,1024
	lui	$v0,%hi(Alpha_to) # high
	addiu	$t3,$v0,%lo(Alpha_to) # low
.L308:
	move	$t1,$zero
	slt	$v0,$t4,$a3
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L309
	move	$t0,$a3
	.set	macro
	.set	reorder

	move	$t0,$t4
.L309:
	.set	noreorder
	.set	nomacro
	bltz	$t0,.L365
	addu	$v0,$t0,-1
	.set	macro
	.set	reorder

.L393:
	subu	$v0,$a3,$v0
	sll	$v0,$v0,2
	addu	$v0,$a2,$v0
	lw	$v1,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v1,$t2,.L313
	sll	$v0,$t0,2
	.set	macro
	.set	reorder

	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$t2,.L313
	addu	$v1,$v0,$v1
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L403
	slt	$v0,$v1,255
	.set	macro
	.set	reorder

.L392:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
.L403:
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L392
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$v1,2
	addu	$v0,$v0,$t3
	lw	$v0,0($v0)
	xor	$t1,$t1,$v0
.L313:
	addu	$t0,$t0,-1
	.set	noreorder
	.set	nomacro
	bgez	$t0,.L393
	addu	$v0,$t0,-1
	.set	macro
	.set	reorder

.L365:
	.set	noreorder
	.set	nomacro
	beq	$t1,$zero,.L394
	sll	$v0,$a3,2
	.set	macro
	.set	reorder

	move	$t9,$a3
.L394:
	addu	$a0,$sp,$v0
	lui	$v1,%hi(Index_of) # high
	addiu	$v1,$v1,%lo(Index_of) # low
	sll	$v0,$t1,2
	addu	$v0,$v0,$v1
	lw	$v0,0($v0)
	sw	$v0,1568($a0)
	addu	$a3,$a3,1
	slt	$v0,$a3,32
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L308
	li	$v0,255			# 0x000000ff
	.set	macro
	.set	reorder

	addu	$t0,$t5,-1
	.set	noreorder
	.set	nomacro
	bltz	$t0,.L325
	sw	$v0,1696($sp)
	.set	macro
	.set	reorder

	addu	$t7,$sp,1568
	move	$t8,$v0
	addu	$t6,$sp,1704
	lui	$v0,%hi(Alpha_to) # high
	addiu	$t3,$v0,%lo(Alpha_to) # low
.L327:
	move	$a3,$t9
	.set	noreorder
	.set	nomacro
	bltz	$a3,.L329
	move	$a2,$zero
	.set	macro
	.set	reorder

	sll	$v0,$t0,2
	addu	$a0,$t6,$v0
	sll	$v0,$a3,2
.L397:
	addu	$v0,$t7,$v0
	lw	$v1,0($v0)
	beq	$v1,$t8,.L330
	lw	$v0,0($a0)
	mult	$a3,$v0
	mflo	$s1
	addu	$v1,$s1,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L395
	sll	$v0,$v1,2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L396:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L396
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$v1,2
.L395:
	addu	$v0,$v0,$t3
	lw	$v0,0($v0)
	xor	$a2,$a2,$v0
.L330:
	addu	$a3,$a3,-1
	.set	noreorder
	.set	nomacro
	bgez	$a3,.L397
	sll	$v0,$a3,2
	.set	macro
	.set	reorder

.L329:
	li	$v1,255			# 0x000000ff
	addu	$v1,$v1,-255
.L398:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L398
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$v1,2
	addu	$v0,$t3,$v0
	lw	$t2,0($v0)
	move	$v1,$t4
	slt	$v0,$v1,32
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L344
	move	$a1,$zero
	.set	macro
	.set	reorder

	li	$v1,31			# 0x0000001f
.L344:
	li	$v0,-2			# 0xfffffffe
	and	$a3,$v1,$v0
	bltz	$a3,.L346
	addu	$t1,$sp,1024
	sll	$v0,$t0,2
	addu	$a0,$t6,$v0
.L348:
	addu	$v0,$a3,1
	sll	$v0,$v0,2
	addu	$v0,$t1,$v0
	lw	$v1,0($v0)
	beq	$v1,$t8,.L347
	lw	$v0,0($a0)
	mult	$a3,$v0
	mflo	$s1
	addu	$v1,$s1,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L399
	sll	$v0,$v1,2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L400:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L400
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$v1,2
.L399:
	addu	$v0,$v0,$t3
	lw	$v0,0($v0)
	xor	$a1,$a1,$v0
.L347:
	addu	$a3,$a3,-2
	bgez	$a3,.L348
.L346:
	beq	$a1,$zero,.L368
	beq	$a2,$zero,.L326
	lui	$a0,%hi(Index_of) # high
	addiu	$a0,$a0,%lo(Index_of) # low
	sll	$v1,$a2,2
	addu	$v1,$v1,$a0
	sll	$v0,$t2,2
	addu	$v0,$v0,$a0
	lw	$v1,0($v1)
	lw	$v0,0($v0)
	addu	$v1,$v1,$v0
	sll	$v0,$a1,2
	addu	$v0,$v0,$a0
	lw	$v0,0($v0)
	addu	$v0,$v0,-255
	subu	$v1,$v1,$v0
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L401
	sll	$v0,$t0,2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L402:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L402
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$t0,2
.L401:
	addu	$v0,$sp,$v0
	lw	$a0,1968($v0)
	addu	$a0,$s0,$a0
	sll	$v0,$v1,2
	addu	$v0,$v0,$t3
	lbu	$v1,0($a0)
	lbu	$v0,3($v0)
	xor	$v1,$v1,$v0
	sb	$v1,0($a0)
.L326:
	addu	$t0,$t0,-1
	bgez	$t0,.L327
.L325:
	move	$v0,$t5
.L364:
	lw	$s1,2100($sp)
	lw	$s0,2096($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,2104
	.set	macro
	.set	reorder

	.end	eras_dec_rs
	.size	eras_dec_rs,.-eras_dec_rs
	.align	2
	.globl	fill_eras
	.ent	fill_eras
fill_eras:
	.frame	$sp,1064,$ra		# vars= 1024, regs= 5/0, args= 16, extra= 0
	.mask	0x800f0000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,1064
	sw	$ra,1056($sp)
	sw	$s3,1052($sp)
	sw	$s2,1048($sp)
	sw	$s1,1044($sp)
	sw	$s0,1040($sp)
	move	$s3,$a0
	move	$s2,$a1
	move	$a0,$zero
	addu	$v1,$sp,16
	sll	$v0,$a0,2
.L420:
	addu	$v0,$v1,$v0
	sw	$a0,0($v0)
	addu	$a0,$a0,1
	slt	$v0,$a0,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L420
	sll	$v0,$a0,2
	.set	macro
	.set	reorder

	li	$s0,254			# 0x000000fe
	addu	$s1,$sp,16
.L413:
	jal	random
	remu	$a0,$v0,$s0
	sll	$a0,$a0,2
	addu	$a0,$s1,$a0
	lw	$a1,0($a0)
	sll	$v1,$s0,2
	addu	$v1,$s1,$v1
	lw	$v0,0($v1)
	sw	$v0,0($a0)
	addu	$s0,$s0,-1
	.set	noreorder
	.set	nomacro
	bgtz	$s0,.L413
	sw	$a1,0($v1)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	blez	$s2,.L416
	move	$a0,$zero
	.set	macro
	.set	reorder

	addu	$a1,$sp,16
	sll	$v0,$a0,2
.L421:
	addu	$v1,$v0,$s3
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	sw	$v0,0($v1)
	addu	$a0,$a0,1
	slt	$v0,$a0,$s2
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L421
	sll	$v0,$a0,2
	.set	macro
	.set	reorder

.L416:
	lw	$ra,1056($sp)
	lw	$s3,1052($sp)
	lw	$s2,1048($sp)
	lw	$s1,1044($sp)
	lw	$s0,1040($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,1064
	.set	macro
	.set	reorder

	.end	fill_eras
	.size	fill_eras,.-fill_eras
	.align	2
	.globl	randomnz
	.ent	randomnz
randomnz:
	.frame	$sp,24,$ra		# vars= 0, regs= 1/0, args= 16, extra= 0
	.mask	0x80000000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	sw	$ra,16($sp)
.L423:
	jal	random
	andi	$v0,$v0,0x00ff
	beq	$v0,$zero,.L423
	lw	$ra,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	randomnz
	.size	randomnz,.-randomnz
	.text
	.align	2
	.globl	main2
	.ent	main2
main2:
	.frame	$sp,72,$ra		# vars= 16, regs= 10/0, args= 16, extra= 0
	.mask	0xc0ff0000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,72
	sw	$ra,68($sp)
	sw	$fp,64($sp)
	sw	$s7,60($sp)
	sw	$s6,56($sp)
	sw	$s5,52($sp)
	sw	$s4,48($sp)
	sw	$s3,44($sp)
	sw	$s2,40($sp)
	sw	$s1,36($sp)
	sw	$s0,32($sp)
	li	$fp,11			# 0x0000000b
	li	$s3,10			# 0x0000000a
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

	.set	noreorder
	.set	nomacro
	jal	print_num
	li	$a0,255			# 0x000000ff
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC1) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC1) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	li	$a0,223			# 0x000000df
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC7) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC7) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	li	$a0,256			# 0x00000100
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC8) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC8) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC9) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC9) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	move	$a0,$s3
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC10) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC10) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	move	$a0,$fp
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC2) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC2) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	init_rs
	move	$s4,$zero
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC14) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC14) # low
	.set	macro
	.set	reorder

	sw	$zero,16($sp)
	li	$a3,3			# 0x00000003
	.set	noreorder
	.set	nomacro
	beq	$a3,$zero,.L429
	sw	$zero,20($sp)
	.set	macro
	.set	reorder

	lui	$v0,%hi(data) # high
	addiu	$s5,$v0,%lo(data) # low
	li	$a3,1			# 0x00000001
	sltu	$a3,$zero,$a3
	sw	$a3,24($sp)
	lui	$s7,%hi(.LC1) # high
	lui	$v0,%hi(eras_pos) # high
	addiu	$s6,$v0,%lo(eras_pos) # low
	li	$a3,1			# 0x00000001
.L471:
	beq	$a3,$zero,.L432
	lui	$a0,%hi(.LC15) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC15) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	move	$a0,$s4
	.set	macro
	.set	reorder

	lui	$a3,%hi(.LC2) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a3,%lo(.LC2) # low
	.set	macro
	.set	reorder

.L432:
	lui	$a0,%hi(.LC16) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC16) # low
	.set	macro
	.set	reorder

	move	$s0,$zero
.L436:
	jal	random
	addu	$v1,$s0,$s5
	sb	$v0,0($v1)
	addu	$s0,$s0,1
	slt	$v0,$s0,223
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L436
	move	$a0,$s5
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	encode_rs
	addu	$a1,$s5,223
	.set	macro
	.set	reorder

	lui	$a3,%hi(eras_pos) # high
	addiu	$a0,$a3,%lo(eras_pos) # low
	.set	noreorder
	.set	nomacro
	jal	fill_eras
	addu	$a1,$s3,$fp
	.set	macro
	.set	reorder

	sltu	$v0,$zero,$s3
	lw	$a3,24($sp)
	and	$v0,$a3,$v0
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L467
	sltu	$v0,$zero,$fp
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC17) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC17) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$s3,$zero,.L440
	move	$s0,$zero
	.set	macro
	.set	reorder

.L442:
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$s7,%lo(.LC1) # low
	.set	macro
	.set	reorder

	sll	$v0,$s0,2
	addu	$v0,$v0,$s6
	lw	$a0,0($v0)
	.set	noreorder
	.set	nomacro
	jal	print_num
	addu	$s0,$s0,1
	.set	macro
	.set	reorder

	slt	$v0,$s0,$s3
	bne	$v0,$zero,.L442
.L440:
	lui	$a3,%hi(.LC2) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a3,%lo(.LC2) # low
	.set	macro
	.set	reorder

	sltu	$v0,$zero,$fp
	lw	$a3,24($sp)
.L467:
	and	$v0,$a3,$v0
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L468
	li	$a3,1			# 0x00000001
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC18) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC18) # low
	.set	macro
	.set	reorder

	move	$s0,$s3
	addu	$v0,$s0,$fp
	slt	$v0,$s0,$v0
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L469
	lui	$a3,%hi(.LC2) # high
	.set	macro
	.set	reorder

	addu	$s1,$s3,$fp
.L448:
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$s7,%lo(.LC1) # low
	.set	macro
	.set	reorder

	sll	$v0,$s0,2
	addu	$v0,$v0,$s6
	lw	$a0,0($v0)
	.set	noreorder
	.set	nomacro
	jal	print_num
	addu	$s0,$s0,1
	.set	macro
	.set	reorder

	slt	$v0,$s0,$s1
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L448
	lui	$a3,%hi(.LC2) # high
	.set	macro
	.set	reorder

.L469:
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a3,%lo(.LC2) # low
	.set	macro
	.set	reorder

	li	$a3,1			# 0x00000001
.L468:
	.set	noreorder
	.set	nomacro
	beq	$a3,$zero,.L450
	move	$s0,$zero
	.set	macro
	.set	reorder

	addu	$v0,$s0,$s5
.L470:
	lbu	$a0,0($v0)
	.set	noreorder
	.set	nomacro
	jal	print_uchar
	addu	$s0,$s0,1
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$s7,%lo(.LC1) # low
	.set	macro
	.set	reorder

	slt	$v0,$s0,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L470
	addu	$v0,$s0,$s5
	.set	macro
	.set	reorder

	lui	$a3,%hi(.LC2) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a3,%lo(.LC2) # low
	.set	macro
	.set	reorder

.L450:
	lui	$a3,%hi(ddata) # high
	addiu	$a0,$a3,%lo(ddata) # low
	lui	$a3,%hi(data) # high
	addiu	$a1,$a3,%lo(data) # low
	.set	noreorder
	.set	nomacro
	jal	memcpy
	li	$a2,255			# 0x000000ff
	.set	macro
	.set	reorder

	addu	$v0,$s3,$fp
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L457
	move	$s0,$zero
	.set	macro
	.set	reorder

	lui	$v0,%hi(ddata) # high
	addiu	$s2,$v0,%lo(ddata) # low
	addu	$s1,$s3,$fp
.L459:
	jal	randomnz
	sll	$v1,$s0,2
	addu	$v1,$v1,$s6
	lw	$a0,0($v1)
	addu	$a0,$a0,$s2
	lbu	$v1,0($a0)
	xor	$v1,$v1,$v0
	addu	$s0,$s0,1
	slt	$v0,$s0,$s1
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L459
	sb	$v1,0($a0)
	.set	macro
	.set	reorder

.L457:
	lui	$a3,%hi(ddata) # high
	addiu	$a0,$a3,%lo(ddata) # low
	lui	$a3,%hi(eras_pos) # high
	addiu	$a1,$a3,%lo(eras_pos) # low
	.set	noreorder
	.set	nomacro
	jal	eras_dec_rs
	move	$a2,$s3
	.set	macro
	.set	reorder

	li	$a3,1			# 0x00000001
	.set	noreorder
	.set	nomacro
	beq	$a3,$zero,.L461
	move	$s0,$v0
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC19) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC19) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	move	$a0,$s0
	.set	macro
	.set	reorder

.L461:
	li	$v0,-1			# 0xffffffff
	.set	noreorder
	.set	nomacro
	bne	$s0,$v0,.L462
	lui	$a3,%hi(ddata) # high
	.set	macro
	.set	reorder

	lw	$a3,16($sp)
	addu	$a3,$a3,1
	sw	$a3,16($sp)
	lui	$a0,%hi(.LC20) # high
	.set	noreorder
	.set	nomacro
	b	.L466
	addiu	$a0,$a0,%lo(.LC20) # low
	.set	macro
	.set	reorder

.L462:
	addiu	$a0,$a3,%lo(ddata) # low
	lui	$a3,%hi(data) # high
	addiu	$a1,$a3,%lo(data) # low
	.set	noreorder
	.set	nomacro
	jal	memcmp
	li	$a2,255			# 0x000000ff
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L430
	lui	$a0,%hi(.LC21) # high
	.set	macro
	.set	reorder

	lw	$a3,20($sp)
	addu	$a3,$a3,1
	sw	$a3,20($sp)
	addiu	$a0,$a0,%lo(.LC21) # low
.L466:
	jal	print
.L430:
	addu	$s4,$s4,1
	slt	$v0,$s4,3
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L471
	li	$a3,1			# 0x00000001
	.set	macro
	.set	reorder

.L429:
	lui	$a0,%hi(.LC22) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC22) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	li	$a0,3			# 0x00000003
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC23) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC23) # low
	.set	macro
	.set	reorder

	lw	$a0,16($sp)
	jal	print_num
	lui	$a0,%hi(.LC24) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC24) # low
	.set	macro
	.set	reorder

	lw	$a0,20($sp)
	jal	print_num
	lui	$a0,%hi(.LC2) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC2) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC25) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC25) # low
	.set	macro
	.set	reorder

	move	$v0,$zero
	lw	$ra,68($sp)
	lw	$fp,64($sp)
	lw	$s7,60($sp)
	lw	$s6,56($sp)
	lw	$s5,52($sp)
	lw	$s4,48($sp)
	lw	$s3,44($sp)
	lw	$s2,40($sp)
	lw	$s1,36($sp)
	lw	$s0,32($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,72
	.set	macro
	.set	reorder

	.end	main2
	.size	main2,.-main2
