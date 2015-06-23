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
	.ascii	"It takes very long time for RTL Simulation.\000"
	.align	2
.LC1:
	.ascii	"Reed-Solomon code is \000"
	.align	2
.LC2:
	.ascii	" \000"
	.align	2
.LC3:
	.ascii	"over GF(\000"
	.align	2
.LC4:
	.ascii	")\n\000"
	.align	2
.LC5:
	.ascii	"i=\000"
	.align	2
.LC6:
	.ascii	"\n\000"
	.align	2
.LC7:
	.ascii	"test erasures: \000"
	.align	2
.LC8:
	.ascii	"errors \000"
	.align	2
.LC9:
	.ascii	"Warning: \000"
	.align	2
.LC10:
	.ascii	"errors and \000"
	.align	2
.LC11:
	.ascii	"erasures exceeds the correction ability of the code\n\000"
	.align	2
.LC12:
	.ascii	"Init_RS Done\000"
	.align	2
.LC13:
	.ascii	"\n"
	.ascii	" Trial \000"
	.align	2
.LC14:
	.ascii	" erasing:\000"
	.align	2
.LC15:
	.ascii	" erroring:\000"
	.align	2
.LC16:
	.ascii	"errs + erasures corrected: \000"
	.align	2
.LC17:
	.ascii	"RS decoder detected failure\n\000"
	.align	2
.LC18:
	.ascii	" Undetected decoding failure!\n\000"
	.align	2
.LC19:
	.ascii	"Compare Done. Passed.\n\000"
	.align	2
.LC20:
	.ascii	"\n\n\n"
	.ascii	" Total Trials: \000"
	.align	2
.LC21:
	.ascii	" decoding failures: \000"
	.align	2
.LC22:
	.ascii	" not detected by decoder: \000"
	.align	2
.LC23:
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
	jal	putc_uart
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
	.align	2
	.globl	generate_gf
	.ent	generate_gf
generate_gf:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	li	$a2,1			# 0x00000001
	lui	$v0,%hi(Alpha_to+32) # high
	sw	$zero,%lo(Alpha_to+32)($v0)
	move	$a1,$zero
	lui	$v0,%hi(Alpha_to) # high
	addiu	$a0,$v0,%lo(Alpha_to) # low
	lui	$v0,%hi(Index_of) # high
	addiu	$t0,$v0,%lo(Index_of) # low
	lui	$v0,%hi(Pp) # high
	addiu	$a3,$v0,%lo(Pp) # low
.L63:
	sll	$v1,$a1,2
	addu	$v0,$v1,$a0
	sw	$a2,0($v0)
	sll	$v0,$a2,2
	addu	$v0,$v0,$t0
	sw	$a1,0($v0)
	addu	$v1,$v1,$a3
	lw	$v0,0($v1)
	beq	$v0,$zero,.L64
	lw	$v0,32($a0)
	xor	$v0,$a2,$v0
	sw	$v0,32($a0)
.L64:
	addu	$a1,$a1,1
	slt	$v0,$a1,8
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L63
	sll	$a2,$a2,1
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
	sra	$a2,$a2,1
	li	$a1,9			# 0x00000009
	lui	$v0,%hi(Alpha_to) # high
	addiu	$a3,$v0,%lo(Alpha_to) # low
	lui	$v0,%hi(Index_of) # high
	addiu	$t0,$v0,%lo(Index_of) # low
	addu	$v0,$a1,-1
.L74:
	sll	$v0,$v0,2
	addu	$v0,$v0,$a3
	lw	$v1,0($v0)
	slt	$v0,$v1,$a2
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L70
	sll	$v0,$a1,2
	.set	macro
	.set	reorder

	addu	$v0,$v0,$a3
	xor	$v1,$a2,$v1
	sll	$v1,$v1,1
	lw	$a0,32($a3)
	.set	noreorder
	.set	nomacro
	b	.L73
	xor	$v1,$v1,$a0
	.set	macro
	.set	reorder

.L70:
	addu	$v0,$v0,$a3
	addu	$v1,$a1,-1
	sll	$v1,$v1,2
	addu	$v1,$v1,$a3
	lw	$v1,0($v1)
	sll	$v1,$v1,1
.L73:
	sw	$v1,0($v0)
	sll	$v0,$a1,2
	addu	$v0,$v0,$a3
	lw	$v0,0($v0)
	sll	$v0,$v0,2
	addu	$v0,$v0,$t0
	sw	$a1,0($v0)
	addu	$a1,$a1,1
	slt	$v0,$a1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L74
	addu	$v0,$a1,-1
	.set	macro
	.set	reorder

	lui	$v0,%hi(Index_of) # high
	li	$v1,255			# 0x000000ff
	sw	$v1,%lo(Index_of)($v0)
	lui	$v0,%hi(Alpha_to+1020) # high
	.set	noreorder
	.set	nomacro
	j	$ra
	sw	$zero,%lo(Alpha_to+1020)($v0)
	.set	macro
	.set	reorder

	.end	generate_gf
	.size	generate_gf,.-generate_gf
	.align	2
	.globl	gen_poly
	.ent	gen_poly
gen_poly:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lui	$v1,%hi(Gg) # high
	addiu	$a0,$v1,%lo(Gg) # low
	lui	$v0,%hi(Alpha_to+4) # high
	lw	$v0,%lo(Alpha_to+4)($v0)
	sw	$v0,%lo(Gg)($v1)
	li	$v0,1			# 0x00000001
	sw	$v0,4($a0)
	li	$a2,2			# 0x00000002
	move	$t2,$v1
	move	$v0,$v1
	addiu	$a3,$v0,%lo(Gg) # low
	li	$t3,1			# 0x00000001
	lui	$v0,%hi(Index_of) # high
	addiu	$t1,$v0,%lo(Index_of) # low
	lui	$v0,%hi(Alpha_to) # high
	addiu	$t0,$v0,%lo(Alpha_to) # low
	sll	$v0,$a2,2
.L108:
	addu	$v0,$v0,$a3
	addu	$a1,$a2,-1
	.set	noreorder
	.set	nomacro
	blez	$a1,.L81
	sw	$t3,0($v0)
	.set	macro
	.set	reorder

	sll	$v0,$a1,2
.L105:
	addu	$v0,$v0,$a3
	lw	$v0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L84
	sll	$v0,$v0,2
	.set	macro
	.set	reorder

	addu	$v0,$v0,$t1
	lw	$v0,0($v0)
	addu	$v1,$a2,$v0
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L103
	sll	$a0,$a1,2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L104:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L104
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$a0,$a1,2
.L103:
	addu	$a0,$a0,$a3
	addu	$v0,$a1,-1
	sll	$v0,$v0,2
	addu	$v0,$v0,$a3
	sll	$v1,$v1,2
	addu	$v1,$v1,$t0
	lw	$v0,0($v0)
	lw	$v1,0($v1)
	xor	$v0,$v0,$v1
	.set	noreorder
	.set	nomacro
	b	.L82
	sw	$v0,0($a0)
	.set	macro
	.set	reorder

.L84:
	sll	$v0,$a1,2
	addu	$v0,$v0,$a3
	addu	$v1,$a1,-1
	sll	$v1,$v1,2
	addu	$v1,$v1,$a3
	lw	$v1,0($v1)
	sw	$v1,0($v0)
.L82:
	addu	$a1,$a1,-1
	.set	noreorder
	.set	nomacro
	bgtz	$a1,.L105
	sll	$v0,$a1,2
	.set	macro
	.set	reorder

.L81:
	lw	$v0,%lo(Gg)($t2)
	sll	$v0,$v0,2
	addu	$v0,$v0,$t1
	lw	$v0,0($v0)
	addu	$v1,$a2,$v0
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L106
	sll	$v0,$v1,2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L107:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L107
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$v1,2
.L106:
	addu	$v0,$v0,$t0
	lw	$v0,0($v0)
	sw	$v0,%lo(Gg)($t2)
	addu	$a2,$a2,1
	slt	$v0,$a2,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L108
	sll	$v0,$a2,2
	.set	macro
	.set	reorder

	move	$a2,$zero
	lui	$v0,%hi(Gg) # high
	addiu	$a1,$v0,%lo(Gg) # low
	lui	$v0,%hi(Index_of) # high
	addiu	$a0,$v0,%lo(Index_of) # low
.L101:
	sll	$v1,$a2,2
	addu	$v1,$v1,$a1
	lw	$v0,0($v1)
	sll	$v0,$v0,2
	addu	$v0,$v0,$a0
	lw	$v0,0($v0)
	sw	$v0,0($v1)
	addu	$a2,$a2,1
	slt	$v0,$a2,33
	bne	$v0,$zero,.L101
	j	$ra
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
.L113:
	addu	$v0,$a1,$v1
	addu	$v1,$v1,-1
	.set	noreorder
	.set	nomacro
	bgez	$v1,.L113
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
.L118:
	addu	$v0,$t6,$t0
	lbu	$v0,0($v0)
	lbu	$v1,31($a1)
	xor	$v0,$v0,$v1
	sll	$v0,$v0,2
	addu	$v0,$v0,$t5
	lw	$a3,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$a3,$t2,.L119
	li	$a2,31			# 0x0000001f
	.set	macro
	.set	reorder

	sll	$v0,$a2,2
.L146:
	addu	$v0,$v0,$t3
	lw	$v0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$t2,.L124
	addu	$v1,$a3,$v0
	.set	macro
	.set	reorder

	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L144
	addu	$a0,$a1,$a2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L145:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L145
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	addu	$a0,$a1,$a2
.L144:
	sll	$v0,$v1,2
	addu	$v0,$v0,$t1
	lbu	$v1,-1($a0)
	lbu	$v0,3($v0)
	xor	$v1,$v1,$v0
	.set	noreorder
	.set	nomacro
	b	.L122
	sb	$v1,0($a0)
	.set	macro
	.set	reorder

.L124:
	addu	$v0,$a1,$a2
	lbu	$v1,-1($v0)
	sb	$v1,0($v0)
.L122:
	addu	$a2,$a2,-1
	.set	noreorder
	.set	nomacro
	bgtz	$a2,.L146
	sll	$v0,$a2,2
	.set	macro
	.set	reorder

	lw	$v0,%lo(Gg)($t4)
	addu	$v1,$a3,$v0
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L147
	sll	$v0,$v1,2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L148:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L148
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$v1,2
.L147:
	addu	$v0,$v0,$t1
	lbu	$v0,3($v0)
	.set	noreorder
	.set	nomacro
	b	.L117
	sb	$v0,0($a1)
	.set	macro
	.set	reorder

.L119:
.L141:
	addu	$v0,$a1,$a2
	lbu	$v1,-1($v0)
	addu	$a2,$a2,-1
	.set	noreorder
	.set	nomacro
	bgtz	$a2,.L141
	sb	$v1,0($v0)
	.set	macro
	.set	reorder

	sb	$zero,0($a1)
.L117:
	addu	$t0,$t0,-1
	bgez	$t0,.L118
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
.L153:
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
	bgez	$a3,.L153
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
.L158:
	move	$t1,$zero
	move	$t0,$t1
	sll	$v0,$t0,2
.L356:
	addu	$v0,$sp,$v0
	lw	$v0,0($v0)
	beq	$v0,$t3,.L161
	mult	$a3,$t0
	mflo	$s1
	addu	$v1,$s1,$v0
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L354
	sll	$v0,$v1,2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L355:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L355
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$v1,2
.L354:
	addu	$v0,$v0,$t2
	lw	$v0,0($v0)
	xor	$t1,$t1,$v0
.L161:
	addu	$t0,$t0,1
	slt	$v0,$t0,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L356
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
	bne	$v0,$zero,.L158
	or	$a0,$a0,$t1
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bne	$a0,$zero,.L171
	li	$v1,31			# 0x0000001f
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L345
	move	$v0,$zero
	.set	macro
	.set	reorder

.L171:
	addu	$a0,$sp,1028
.L175:
	sll	$v0,$v1,2
	addu	$v0,$a0,$v0
	addu	$v1,$v1,-1
	.set	noreorder
	.set	nomacro
	bgez	$v1,.L175
	sw	$zero,0($v0)
	.set	macro
	.set	reorder

	li	$v0,1			# 0x00000001
	.set	noreorder
	.set	nomacro
	blez	$a2,.L177
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
	beq	$v0,$zero,.L177
	lui	$v0,%hi(Index_of) # high
	.set	macro
	.set	reorder

	addiu	$t6,$v0,%lo(Index_of) # low
	addu	$t2,$sp,1024
	li	$t5,255			# 0x000000ff
	lui	$v0,%hi(Alpha_to) # high
	addiu	$t4,$v0,%lo(Alpha_to) # low
	sll	$v0,$a3,2
.L359:
	addu	$v0,$v0,$a1
	lw	$t3,0($v0)
	addu	$t0,$a3,1
	.set	noreorder
	.set	nomacro
	blez	$t0,.L180
	addu	$v0,$t0,-1
	.set	macro
	.set	reorder

.L358:
	sll	$v0,$v0,2
	addu	$v0,$t2,$v0
	lw	$v0,0($v0)
	sll	$v0,$v0,2
	addu	$v0,$v0,$t6
	lw	$t1,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$t1,$t5,.L184
	addu	$v1,$t3,$t1
	.set	macro
	.set	reorder

	slt	$v0,$v1,255
	bne	$v0,$zero,.L189
	addu	$v1,$v1,-255
.L357:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L357
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
.L189:
	sll	$a0,$t0,2
	addu	$a0,$t2,$a0
	sll	$v0,$v1,2
	addu	$v0,$v0,$t4
	lw	$v1,0($a0)
	lw	$v0,0($v0)
	xor	$v1,$v1,$v0
	sw	$v1,0($a0)
.L184:
	addu	$t0,$t0,-1
	.set	noreorder
	.set	nomacro
	bgtz	$t0,.L358
	addu	$v0,$t0,-1
	.set	macro
	.set	reorder

.L180:
	addu	$a3,$a3,1
	slt	$v0,$a3,$a2
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L359
	sll	$v0,$a3,2
	.set	macro
	.set	reorder

.L177:
	move	$a3,$zero
	addu	$a1,$sp,1296
	lui	$v0,%hi(Index_of) # high
	addiu	$t0,$v0,%lo(Index_of) # low
	addu	$a0,$sp,1024
	sll	$v0,$a3,2
.L360:
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
	bne	$v0,$zero,.L360
	sll	$v0,$a3,2
	.set	macro
	.set	reorder

	move	$t1,$a2
	move	$t6,$t1
	addu	$t1,$t1,1
	slt	$v0,$t1,33
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L200
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
.L368:
	.set	noreorder
	.set	nomacro
	blez	$t1,.L203
	move	$a3,$a1
	.set	macro
	.set	reorder

	sll	$v0,$a3,2
.L362:
	addu	$v0,$t2,$v0
	lw	$a0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$a0,$zero,.L204
	subu	$v0,$t1,$a3
	.set	macro
	.set	reorder

	sll	$v0,$v0,2
	addu	$v0,$t7,$v0
	lw	$v1,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v1,$t4,.L204
	sll	$v0,$a0,2
	.set	macro
	.set	reorder

	addu	$v0,$v0,$t5
	lw	$v0,0($v0)
	.set	noreorder
	.set	nomacro
	b	.L351
	addu	$v1,$v0,$v1
	.set	macro
	.set	reorder

.L361:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
.L351:
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L361
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$v1,2
	addu	$v0,$v0,$t8
	lw	$v0,0($v0)
	xor	$a1,$a1,$v0
.L204:
	addu	$a3,$a3,1
	slt	$v0,$a3,$t1
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L362
	sll	$v0,$a3,2
	.set	macro
	.set	reorder

.L203:
	sll	$v0,$a1,2
	addu	$v0,$v0,$t5
	lw	$a1,0($v0)
	.set	noreorder
	.set	nomacro
	bne	$a1,$t4,.L213
	move	$a3,$zero
	.set	macro
	.set	reorder

	li	$a0,31			# 0x0000001f
	addu	$a3,$sp,1300
	addu	$a1,$sp,1296
.L217:
	sll	$v0,$a0,2
	addu	$v1,$a3,$v0
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	addu	$a0,$a0,-1
	.set	noreorder
	.set	nomacro
	bgez	$a0,.L217
	sw	$v0,0($v1)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L199
	sw	$t4,1296($sp)
	.set	macro
	.set	reorder

.L213:
	lw	$v0,1024($sp)
	sw	$v0,1432($sp)
	addu	$t3,$sp,1296
	addu	$t0,$sp,1432
	sll	$v0,$a3,2
.L365:
	addu	$v0,$t3,$v0
	lw	$v0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$t4,.L224
	addu	$v1,$a1,$v0
	.set	macro
	.set	reorder

	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L363
	addu	$v0,$a3,1
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L364:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L364
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	addu	$v0,$a3,1
.L363:
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
	b	.L222
	sw	$v0,0($a0)
	.set	macro
	.set	reorder

.L224:
	addu	$v0,$a3,1
	sll	$v0,$v0,2
	addu	$v1,$t0,$v0
	addu	$v0,$t2,$v0
	lw	$v0,0($v0)
	sw	$v0,0($v1)
.L222:
	addu	$a3,$a3,1
	slt	$v0,$a3,32
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L365
	sll	$v0,$a3,2
	.set	macro
	.set	reorder

	sll	$v1,$t6,1
	addu	$a0,$t1,$a2
	addu	$v0,$a0,-1
	slt	$v0,$v0,$v1
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L232
	addu	$a3,$sp,1300
	.set	macro
	.set	reorder

	subu	$t6,$a0,$t6
	move	$a3,$zero
	addu	$t0,$sp,1296
	sll	$v0,$a3,2
.L367:
	addu	$a0,$t0,$v0
	addu	$v0,$t2,$v0
	lw	$v0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L237
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
	bne	$v0,$zero,.L238
	move	$v0,$v1
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L366:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L366
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	.set	noreorder
	.set	nomacro
	b	.L238
	move	$v0,$v1
	.set	macro
	.set	reorder

.L237:
	li	$v0,255			# 0x000000ff
.L238:
	sw	$v0,0($a0)
	addu	$a3,$a3,1
	slt	$v0,$a3,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L367
	sll	$v0,$a3,2
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L352
	li	$a0,32			# 0x00000020
	.set	macro
	.set	reorder

.L232:
	li	$a0,31			# 0x0000001f
	addu	$a1,$sp,1296
.L249:
	sll	$v0,$a0,2
	addu	$v1,$a3,$v0
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	addu	$a0,$a0,-1
	.set	noreorder
	.set	nomacro
	bgez	$a0,.L249
	sw	$v0,0($v1)
	.set	macro
	.set	reorder

	sw	$t4,1296($sp)
	li	$a0,32			# 0x00000020
.L352:
	addu	$a1,$sp,1432
.L254:
	sll	$v0,$a0,2
	addu	$v1,$t2,$v0
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	addu	$a0,$a0,-1
	.set	noreorder
	.set	nomacro
	bgez	$a0,.L254
	sw	$v0,0($v1)
	.set	macro
	.set	reorder

.L199:
	addu	$t1,$t1,1
	slt	$v0,$t1,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L368
	move	$a1,$zero
	.set	macro
	.set	reorder

.L200:
	move	$t4,$zero
	move	$a3,$t4
	addu	$a0,$sp,1024
	lui	$v0,%hi(Index_of) # high
	addiu	$a2,$v0,%lo(Index_of) # low
	li	$a1,255			# 0x000000ff
	sll	$v0,$a3,2
.L369:
	addu	$v0,$a0,$v0
	lw	$v1,0($v0)
	sll	$v1,$v1,2
	addu	$v1,$v1,$a2
	lw	$v1,0($v1)
	.set	noreorder
	.set	nomacro
	beq	$v1,$a1,.L259
	sw	$v1,0($v0)
	.set	macro
	.set	reorder

	move	$t4,$a3
.L259:
	addu	$a3,$a3,1
	slt	$v0,$a3,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L369
	sll	$v0,$a3,2
	.set	macro
	.set	reorder

	li	$a0,31			# 0x0000001f
	addu	$a2,$sp,1836
	addu	$a1,$sp,1028
.L266:
	sll	$v0,$a0,2
	addu	$v1,$a2,$v0
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	addu	$a0,$a0,-1
	.set	noreorder
	.set	nomacro
	bgez	$a0,.L266
	sw	$v0,0($v1)
	.set	macro
	.set	reorder

	move	$t5,$zero
	li	$a3,1			# 0x00000001
	addu	$a1,$sp,1832
	li	$a2,255			# 0x000000ff
	lui	$v0,%hi(Alpha_to) # high
	addiu	$t1,$v0,%lo(Alpha_to) # low
.L271:
	move	$t0,$t4
	.set	noreorder
	.set	nomacro
	blez	$t0,.L273
	li	$a0,1			# 0x00000001
	.set	macro
	.set	reorder

	sll	$v0,$t0,2
.L372:
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$a2,.L274
	addu	$v1,$t0,$v0
	.set	macro
	.set	reorder

	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L370
	sll	$v0,$t0,2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L371:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L371
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$t0,2
.L370:
	addu	$v0,$a1,$v0
	sw	$v1,0($v0)
	sll	$v0,$v1,2
	addu	$v0,$v0,$t1
	lw	$v0,0($v0)
	xor	$a0,$a0,$v0
.L274:
	addu	$t0,$t0,-1
	.set	noreorder
	.set	nomacro
	bgtz	$t0,.L372
	sll	$v0,$t0,2
	.set	macro
	.set	reorder

.L273:
	.set	noreorder
	.set	nomacro
	bne	$a0,$zero,.L270
	sll	$v1,$t5,2
	.set	macro
	.set	reorder

	addu	$v0,$sp,$v1
	sw	$a3,1704($v0)
	move	$v1,$v0
	subu	$v0,$a2,$a3
	sw	$v0,1968($v1)
	addu	$t5,$t5,1
.L270:
	addu	$a3,$a3,1
	slt	$v0,$a3,256
	bne	$v0,$zero,.L271
	.set	noreorder
	.set	nomacro
	beq	$t4,$t5,.L285
	move	$t9,$zero
	.set	macro
	.set	reorder

.L349:
	.set	noreorder
	.set	nomacro
	b	.L345
	li	$v0,-1			# 0xffffffff
	.set	macro
	.set	reorder

.L285:
	move	$a3,$t9
	addu	$a2,$sp,1160
	li	$t2,255			# 0x000000ff
	addu	$a1,$sp,1024
	lui	$v0,%hi(Alpha_to) # high
	addiu	$t3,$v0,%lo(Alpha_to) # low
.L289:
	move	$t1,$zero
	slt	$v0,$t4,$a3
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L290
	move	$t0,$a3
	.set	macro
	.set	reorder

	move	$t0,$t4
.L290:
	.set	noreorder
	.set	nomacro
	bltz	$t0,.L346
	addu	$v0,$t0,-1
	.set	macro
	.set	reorder

.L374:
	subu	$v0,$a3,$v0
	sll	$v0,$v0,2
	addu	$v0,$a2,$v0
	lw	$v1,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v1,$t2,.L294
	sll	$v0,$t0,2
	.set	macro
	.set	reorder

	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$t2,.L294
	addu	$v1,$v0,$v1
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L384
	slt	$v0,$v1,255
	.set	macro
	.set	reorder

.L373:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
.L384:
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L373
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$v1,2
	addu	$v0,$v0,$t3
	lw	$v0,0($v0)
	xor	$t1,$t1,$v0
.L294:
	addu	$t0,$t0,-1
	.set	noreorder
	.set	nomacro
	bgez	$t0,.L374
	addu	$v0,$t0,-1
	.set	macro
	.set	reorder

.L346:
	.set	noreorder
	.set	nomacro
	beq	$t1,$zero,.L375
	sll	$v0,$a3,2
	.set	macro
	.set	reorder

	move	$t9,$a3
.L375:
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
	bne	$v0,$zero,.L289
	li	$v0,255			# 0x000000ff
	.set	macro
	.set	reorder

	addu	$t0,$t5,-1
	.set	noreorder
	.set	nomacro
	bltz	$t0,.L306
	sw	$v0,1696($sp)
	.set	macro
	.set	reorder

	addu	$t7,$sp,1568
	move	$t8,$v0
	addu	$t6,$sp,1704
	lui	$v0,%hi(Alpha_to) # high
	addiu	$t3,$v0,%lo(Alpha_to) # low
.L308:
	move	$a3,$t9
	.set	noreorder
	.set	nomacro
	bltz	$a3,.L310
	move	$a2,$zero
	.set	macro
	.set	reorder

	sll	$v0,$t0,2
	addu	$a0,$t6,$v0
	sll	$v0,$a3,2
.L378:
	addu	$v0,$t7,$v0
	lw	$v1,0($v0)
	beq	$v1,$t8,.L311
	lw	$v0,0($a0)
	mult	$a3,$v0
	mflo	$s1
	addu	$v1,$s1,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L376
	sll	$v0,$v1,2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L377:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L377
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$v1,2
.L376:
	addu	$v0,$v0,$t3
	lw	$v0,0($v0)
	xor	$a2,$a2,$v0
.L311:
	addu	$a3,$a3,-1
	.set	noreorder
	.set	nomacro
	bgez	$a3,.L378
	sll	$v0,$a3,2
	.set	macro
	.set	reorder

.L310:
	li	$v1,255			# 0x000000ff
	addu	$v1,$v1,-255
.L379:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L379
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
	bne	$v0,$zero,.L325
	move	$a1,$zero
	.set	macro
	.set	reorder

	li	$v1,31			# 0x0000001f
.L325:
	li	$v0,-2			# 0xfffffffe
	and	$a3,$v1,$v0
	bltz	$a3,.L327
	addu	$t1,$sp,1024
	sll	$v0,$t0,2
	addu	$a0,$t6,$v0
.L329:
	addu	$v0,$a3,1
	sll	$v0,$v0,2
	addu	$v0,$t1,$v0
	lw	$v1,0($v0)
	beq	$v1,$t8,.L328
	lw	$v0,0($a0)
	mult	$a3,$v0
	mflo	$s1
	addu	$v1,$s1,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L380
	sll	$v0,$v1,2
	.set	macro
	.set	reorder

	addu	$v1,$v1,-255
.L381:
	sra	$v0,$v1,8
	andi	$v1,$v1,0x00ff
	addu	$v1,$v0,$v1
	slt	$v0,$v1,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L381
	addu	$v1,$v1,-255
	.set	macro
	.set	reorder

	addu	$v1,$v1,255
	sll	$v0,$v1,2
.L380:
	addu	$v0,$v0,$t3
	lw	$v0,0($v0)
	xor	$a1,$a1,$v0
.L328:
	addu	$a3,$a3,-2
	bgez	$a3,.L329
.L327:
	beq	$a1,$zero,.L349
	beq	$a2,$zero,.L307
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
	bne	$v0,$zero,.L382
	sll	$v0,$t0,2
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
	sll	$v0,$t0,2
.L382:
	addu	$v0,$sp,$v0
	lw	$a0,1968($v0)
	addu	$a0,$s0,$a0
	sll	$v0,$v1,2
	addu	$v0,$v0,$t3
	lbu	$v1,0($a0)
	lbu	$v0,3($v0)
	xor	$v1,$v1,$v0
	sb	$v1,0($a0)
.L307:
	addu	$t0,$t0,-1
	bgez	$t0,.L308
.L306:
	move	$v0,$t5
.L345:
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
.L401:
	addu	$v0,$v1,$v0
	sw	$a0,0($v0)
	addu	$a0,$a0,1
	slt	$v0,$a0,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L401
	sll	$v0,$a0,2
	.set	macro
	.set	reorder

	li	$s0,254			# 0x000000fe
	addu	$s1,$sp,16
.L394:
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
	bgtz	$s0,.L394
	sw	$a1,0($v1)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	blez	$s2,.L397
	move	$a0,$zero
	.set	macro
	.set	reorder

	addu	$a1,$sp,16
	sll	$v0,$a0,2
.L402:
	addu	$v1,$v0,$s3
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	sw	$v0,0($v1)
	addu	$a0,$a0,1
	slt	$v0,$a0,$s2
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L402
	sll	$v0,$a0,2
	.set	macro
	.set	reorder

.L397:
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
.L404:
	jal	random
	andi	$v0,$v0,0x00ff
	beq	$v0,$zero,.L404
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
	li	$s6,11			# 0x0000000b
	li	$s3,10			# 0x0000000a
	lui	$a0,%hi(.LC0) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC0) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC1) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC1) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	li	$a0,255			# 0x000000ff
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC2) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC2) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	li	$a0,223			# 0x000000df
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC3) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC3) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	li	$a0,256			# 0x00000100
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC4) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC4) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC5) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC5) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	move	$a0,$s0
	.set	macro
	.set	reorder

	lui	$s0,%hi(.LC6) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$s0,%lo(.LC6) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC7) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC7) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	move	$a0,$s3
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC8) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC8) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	move	$a0,$s6
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$s0,%lo(.LC6) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	init_rs
	move	$s4,$zero
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC12) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC12) # low
	.set	macro
	.set	reorder

	sw	$zero,16($sp)
	li	$a3,120			# 0x00000078
	.set	noreorder
	.set	nomacro
	beq	$a3,$zero,.L410
	sw	$zero,20($sp)
	.set	macro
	.set	reorder

	move	$s7,$s0
	lui	$v0,%hi(data) # high
	addiu	$fp,$v0,%lo(data) # low
	li	$a3,1			# 0x00000001
	sltu	$a3,$zero,$a3
	sw	$a3,24($sp)
	lui	$v0,%hi(eras_pos) # high
	addiu	$s5,$v0,%lo(eras_pos) # low
	li	$a3,1			# 0x00000001
.L447:
	.set	noreorder
	.set	nomacro
	beq	$a3,$zero,.L413
	lui	$a0,%hi(.LC13) # high
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC13) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	move	$a0,$s4
	.set	macro
	.set	reorder

.L413:
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$s7,%lo(.LC6) # low
	.set	macro
	.set	reorder

	move	$s0,$zero
.L417:
	jal	random
	addu	$v1,$s0,$fp
	sb	$v0,0($v1)
	addu	$s0,$s0,1
	slt	$v0,$s0,223
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L417
	move	$a0,$fp
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	encode_rs
	addu	$a1,$fp,223
	.set	macro
	.set	reorder

	lui	$a3,%hi(eras_pos) # high
	addiu	$a0,$a3,%lo(eras_pos) # low
	.set	noreorder
	.set	nomacro
	jal	fill_eras
	addu	$a1,$s3,$s6
	.set	macro
	.set	reorder

	sltu	$v0,$zero,$s3
	lw	$a3,24($sp)
	and	$v0,$a3,$v0
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L444
	sltu	$v0,$zero,$s6
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC14) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC14) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$s3,$zero,.L421
	move	$s0,$zero
	.set	macro
	.set	reorder

	lui	$a3,%hi(.LC2) # high
.L445:
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a3,%lo(.LC2) # low
	.set	macro
	.set	reorder

	sll	$v0,$s0,2
	addu	$v0,$v0,$s5
	lw	$a0,0($v0)
	.set	noreorder
	.set	nomacro
	jal	print_num
	addu	$s0,$s0,1
	.set	macro
	.set	reorder

	slt	$v0,$s0,$s3
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L445
	lui	$a3,%hi(.LC2) # high
	.set	macro
	.set	reorder

.L421:
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$s7,%lo(.LC6) # low
	.set	macro
	.set	reorder

	sltu	$v0,$zero,$s6
	lw	$a3,24($sp)
.L444:
	and	$v0,$a3,$v0
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L425
	lui	$a0,%hi(.LC15) # high
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC15) # low
	.set	macro
	.set	reorder

	move	$s0,$s3
	addu	$v0,$s0,$s6
	slt	$v0,$s0,$v0
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L427
	lui	$a3,%hi(.LC2) # high
	.set	macro
	.set	reorder

	addu	$s1,$s3,$s6
.L446:
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a3,%lo(.LC2) # low
	.set	macro
	.set	reorder

	sll	$v0,$s0,2
	addu	$v0,$v0,$s5
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
	bne	$v0,$zero,.L446
	lui	$a3,%hi(.LC2) # high
	.set	macro
	.set	reorder

.L427:
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$s7,%lo(.LC6) # low
	.set	macro
	.set	reorder

.L425:
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

	addu	$v0,$s3,$s6
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L433
	move	$s0,$zero
	.set	macro
	.set	reorder

	lui	$v0,%hi(ddata) # high
	addiu	$s2,$v0,%lo(ddata) # low
	addu	$s1,$s3,$s6
.L435:
	jal	randomnz
	sll	$v1,$s0,2
	addu	$v1,$v1,$s5
	lw	$a0,0($v1)
	addu	$a0,$a0,$s2
	lbu	$v1,0($a0)
	xor	$v1,$v1,$v0
	addu	$s0,$s0,1
	slt	$v0,$s0,$s1
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L435
	sb	$v1,0($a0)
	.set	macro
	.set	reorder

.L433:
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
	beq	$a3,$zero,.L437
	move	$s0,$v0
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC16) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC16) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	move	$a0,$s0
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$s7,%lo(.LC6) # low
	.set	macro
	.set	reorder

.L437:
	li	$v0,-1			# 0xffffffff
	.set	noreorder
	.set	nomacro
	bne	$s0,$v0,.L438
	lui	$a3,%hi(ddata) # high
	.set	macro
	.set	reorder

	lw	$a3,16($sp)
	addu	$a3,$a3,1
	sw	$a3,16($sp)
	lui	$a0,%hi(.LC17) # high
	.set	noreorder
	.set	nomacro
	b	.L443
	addiu	$a0,$a0,%lo(.LC17) # low
	.set	macro
	.set	reorder

.L438:
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
	beq	$v0,$zero,.L440
	lui	$a0,%hi(.LC18) # high
	.set	macro
	.set	reorder

	lw	$a3,20($sp)
	addu	$a3,$a3,1
	sw	$a3,20($sp)
	.set	noreorder
	.set	nomacro
	b	.L443
	addiu	$a0,$a0,%lo(.LC18) # low
	.set	macro
	.set	reorder

.L440:
	lui	$a0,%hi(.LC19) # high
	addiu	$a0,$a0,%lo(.LC19) # low
.L443:
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addu	$s4,$s4,1
	.set	macro
	.set	reorder

	slt	$v0,$s4,120
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L447
	li	$a3,1			# 0x00000001
	.set	macro
	.set	reorder

.L410:
	lui	$a0,%hi(.LC20) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC20) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	li	$a0,120			# 0x00000078
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC21) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC21) # low
	.set	macro
	.set	reorder

	lw	$a0,16($sp)
	jal	print_num
	lui	$a0,%hi(.LC22) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC22) # low
	.set	macro
	.set	reorder

	lw	$a0,20($sp)
	jal	print_num
	lui	$a0,%hi(.LC6) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC6) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC23) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC23) # low
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
