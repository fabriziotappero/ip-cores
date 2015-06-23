	.file	1 "test.c"

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
	.globl	name
	.data
	.align	0
	.align	2
name:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.word	.LC5
	.word	.LC6
	.word	.LC7
	.word	.LC8
	.word	.LC9
	.word	.LC10
	.word	.LC11
	.word	.LC12
	.word	.LC13
	.word	.LC14
	.word	.LC15
	.word	.LC16
	.word	.LC17
	.word	.LC18
	.word	.LC19
	.word	.LC0
	.word	.LC10
	.word	.LC20
	.word	.LC21
	.word	.LC22
	.word	.LC23
	.word	.LC24
	.word	.LC25
	.word	.LC26
	.word	.LC27
	.rdata
	.align	0
	.align	2
.LC27:
	.ascii	"ninety\000"
	.align	2
.LC26:
	.ascii	"eighty\000"
	.align	2
.LC25:
	.ascii	"seventy\000"
	.align	2
.LC24:
	.ascii	"sixty\000"
	.align	2
.LC23:
	.ascii	"fifty\000"
	.align	2
.LC22:
	.ascii	"forty\000"
	.align	2
.LC21:
	.ascii	"thirty\000"
	.align	2
.LC20:
	.ascii	"twenty\000"
	.align	2
.LC19:
	.ascii	"nineteen\000"
	.align	2
.LC18:
	.ascii	"eighteen\000"
	.align	2
.LC17:
	.ascii	"seventeen\000"
	.align	2
.LC16:
	.ascii	"sixteen\000"
	.align	2
.LC15:
	.ascii	"fifteen\000"
	.align	2
.LC14:
	.ascii	"fourteen\000"
	.align	2
.LC13:
	.ascii	"thirteen\000"
	.align	2
.LC12:
	.ascii	"twelve\000"
	.align	2
.LC11:
	.ascii	"eleven\000"
	.align	2
.LC10:
	.ascii	"ten\000"
	.align	2
.LC9:
	.ascii	"nine\000"
	.align	2
.LC8:
	.ascii	"eight\000"
	.align	2
.LC7:
	.ascii	"seven\000"
	.align	2
.LC6:
	.ascii	"six\000"
	.align	2
.LC5:
	.ascii	"five\000"
	.align	2
.LC4:
	.ascii	"four\000"
	.align	2
.LC3:
	.ascii	"three\000"
	.align	2
.LC2:
	.ascii	"two\000"
	.align	2
.LC1:
	.ascii	"one\000"
	.align	2
.LC0:
	.ascii	"\000"
	.size	name,120

	.lcomm	buf.12,12
	.rdata
	.align	0
	.align	2
.LC28:
	.ascii	": \000"
	.align	2
.LC29:
	.ascii	" billion \000"
	.align	2
.LC30:
	.ascii	" hundred \000"
	.align	2
.LC31:
	.ascii	"million \000"
	.align	2
.LC32:
	.ascii	" million \000"
	.align	2
.LC33:
	.ascii	"thousand \000"
	.align	2
.LC34:
	.ascii	" thousand \000"

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
	.globl	itoa
	.ent	itoa
itoa:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	move	$a2,$a0
	lui	$v0,%hi(buf.12+10) # high
	sb	$zero,%lo(buf.12+10)($v0)
	li	$a1,9			# 0x00000009
	lui	$v0,%hi(buf.12) # high
	addiu	$t0,$v0,%lo(buf.12) # low
	li	$a3,-858993459			# 0xcccccccd
.L27:
	addu	$a0,$a1,$t0
	multu	$a2,$a3
	mfhi	$t1
	srl	$v1,$t1,3
	sll	$v0,$v1,2
	addu	$v0,$v0,$v1
	sll	$v0,$v0,1
	subu	$v0,$a2,$v0
	addu	$v0,$v0,48
	sb	$v0,0($a0)
	addu	$a1,$a1,-1
	.set	noreorder
	.set	nomacro
	bgez	$a1,.L27
	move	$a2,$v1
	.set	macro
	.set	reorder

	lui	$v0,%hi(buf.12) # high
	.set	noreorder
	.set	nomacro
	j	$ra
	addiu	$v0,$v0,%lo(buf.12) # low
	.set	macro
	.set	reorder

	.end	itoa
	.size	itoa,.-itoa
	.text
	.align	2
	.globl	number_text
	.ent	number_text
number_text:
	.frame	$sp,32,$ra		# vars= 0, regs= 3/0, args= 16, extra= 0
	.mask	0x80030000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	sw	$ra,24($sp)
	sw	$s1,20($sp)
	sw	$s0,16($sp)
	.set	noreorder
	.set	nomacro
	jal	itoa
	move	$s1,$a0
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print
	move	$a0,$v0
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC28) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC28) # low
	.set	macro
	.set	reorder

	li	$v0,999948288			# 0x3b9a0000
	ori	$v0,$v0,0xc9ff
	sltu	$v0,$v0,$s1
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L30
	srl	$v1,$s1,9
	.set	macro
	.set	reorder

	li	$v0,262144			# 0x00040000
	ori	$v0,$v0,0x4b83
	multu	$v1,$v0
	mfhi	$a1
	srl	$s0,$a1,7
	lui	$v1,%hi(name) # high
	addiu	$v1,$v1,%lo(name) # low
	sll	$v0,$s0,2
	addu	$v0,$v0,$v1
	lw	$a0,0($v0)
	jal	print
	lui	$a0,%hi(.LC29) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC29) # low
	.set	macro
	.set	reorder

	sll	$v0,$s0,5
	subu	$v0,$v0,$s0
	sll	$v0,$v0,2
	subu	$v0,$v0,$s0
	sll	$v0,$v0,4
	addu	$v0,$v0,$s0
	sll	$v0,$v0,3
	subu	$v0,$v0,$s0
	sll	$v1,$v0,5
	subu	$v1,$v1,$v0
	sll	$v1,$v1,2
	addu	$v1,$v1,$s0
	sll	$v1,$v1,9
	subu	$s1,$s1,$v1
.L30:
	li	$v0,99942400			# 0x05f50000
	ori	$v0,$v0,0xe0ff
	sltu	$v0,$v0,$s1
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L31
	li	$v0,1441136640			# 0x55e60000
	.set	macro
	.set	reorder

	ori	$v0,$v0,0x3b89
	multu	$s1,$v0
	mfhi	$a1
	srl	$s0,$a1,25
	lui	$v1,%hi(name) # high
	addiu	$v1,$v1,%lo(name) # low
	sll	$v0,$s0,2
	addu	$v0,$v0,$v1
	lw	$a0,0($v0)
	jal	print
	lui	$a0,%hi(.LC30) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC30) # low
	.set	macro
	.set	reorder

	sll	$v0,$s0,1
	addu	$v0,$v0,$s0
	sll	$v0,$v0,6
	subu	$v0,$v0,$s0
	sll	$v0,$v0,2
	subu	$v0,$v0,$s0
	sll	$v0,$v0,4
	subu	$v0,$v0,$s0
	sll	$v0,$v0,5
	addu	$v0,$v0,$s0
	sll	$v0,$v0,8
	subu	$s1,$s1,$v0
	li	$v0,983040			# 0x000f0000
	ori	$v0,$v0,0x423f
	sltu	$v0,$v0,$s1
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L45
	li	$v0,19988480			# 0x01310000
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC31) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC31) # low
	.set	macro
	.set	reorder

.L31:
	li	$v0,19988480			# 0x01310000
.L45:
	ori	$v0,$v0,0x2cff
	sltu	$v0,$v0,$s1
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L33
	li	$v0,1801388032			# 0x6b5f0000
	.set	macro
	.set	reorder

	ori	$v0,$v0,0xca6b
	multu	$s1,$v0
	mfhi	$a1
	srl	$s0,$a1,22
	lui	$v1,%hi(name) # high
	addiu	$v1,$v1,%lo(name) # low
	addu	$v0,$s0,20
	sll	$v0,$v0,2
	addu	$v0,$v0,$v1
	lw	$a0,0($v0)
	jal	print
	.set	noreorder
	.set	nomacro
	jal	print_char
	li	$a0,32			# 0x00000020
	.set	macro
	.set	reorder

	sll	$v1,$s0,5
	subu	$v1,$v1,$s0
	sll	$v0,$v1,6
	subu	$v0,$v0,$v1
	sll	$v0,$v0,3
	addu	$v0,$v0,$s0
	sll	$v1,$v0,2
	addu	$v0,$v0,$v1
	sll	$v0,$v0,7
	subu	$s1,$s1,$v0
	li	$v0,983040			# 0x000f0000
	ori	$v0,$v0,0x423f
	sltu	$v0,$v0,$s1
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L46
	li	$v0,1125842944			# 0x431b0000
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC31) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC31) # low
	.set	macro
	.set	reorder

.L33:
	li	$v0,983040			# 0x000f0000
	ori	$v0,$v0,0x423f
	sltu	$v0,$v0,$s1
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L35
	li	$v0,1125842944			# 0x431b0000
	.set	macro
	.set	reorder

.L46:
	ori	$v0,$v0,0xde83
	multu	$s1,$v0
	mfhi	$a1
	srl	$s0,$a1,18
	lui	$v1,%hi(name) # high
	addiu	$v1,$v1,%lo(name) # low
	sll	$v0,$s0,2
	addu	$v0,$v0,$v1
	lw	$a0,0($v0)
	jal	print
	lui	$a0,%hi(.LC32) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC32) # low
	.set	macro
	.set	reorder

	sll	$v1,$s0,5
	subu	$v1,$v1,$s0
	sll	$v0,$v1,6
	subu	$v0,$v0,$v1
	sll	$v0,$v0,3
	addu	$v0,$v0,$s0
	sll	$v0,$v0,6
	subu	$s1,$s1,$v0
.L35:
	li	$v0,65536			# 0x00010000
	ori	$v0,$v0,0x869f
	sltu	$v0,$v0,$s1
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L36
	srl	$v1,$s1,5
	.set	macro
	.set	reorder

	li	$v0,175898624			# 0x0a7c0000
	ori	$v0,$v0,0x5ac5
	multu	$v1,$v0
	mfhi	$a1
	srl	$s0,$a1,7
	lui	$v1,%hi(name) # high
	addiu	$v1,$v1,%lo(name) # low
	sll	$v0,$s0,2
	addu	$v0,$v0,$v1
	lw	$a0,0($v0)
	jal	print
	lui	$a0,%hi(.LC30) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC30) # low
	.set	macro
	.set	reorder

	sll	$v0,$s0,1
	addu	$v0,$v0,$s0
	sll	$v1,$v0,6
	addu	$v0,$v0,$v1
	sll	$v0,$v0,2
	addu	$v0,$v0,$s0
	sll	$v0,$v0,2
	addu	$v0,$v0,$s0
	sll	$v0,$v0,5
	subu	$s1,$s1,$v0
	sltu	$v0,$s1,1000
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L47
	sltu	$v0,$s1,20000
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC33) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC33) # low
	.set	macro
	.set	reorder

.L36:
	sltu	$v0,$s1,20000
.L47:
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L48
	sltu	$v0,$s1,1000
	.set	macro
	.set	reorder

	li	$v0,-776530087			# 0xd1b71759
	multu	$s1,$v0
	mfhi	$a1
	srl	$s0,$a1,13
	lui	$v1,%hi(name) # high
	addiu	$v1,$v1,%lo(name) # low
	addu	$v0,$s0,20
	sll	$v0,$v0,2
	addu	$v0,$v0,$v1
	lw	$a0,0($v0)
	jal	print
	.set	noreorder
	.set	nomacro
	jal	print_char
	li	$a0,32			# 0x00000020
	.set	macro
	.set	reorder

	sll	$v0,$s0,2
	addu	$v0,$v0,$s0
	sll	$v0,$v0,3
	subu	$v0,$v0,$s0
	sll	$v0,$v0,4
	addu	$v0,$v0,$s0
	sll	$v0,$v0,4
	subu	$s1,$s1,$v0
	sltu	$v0,$s1,1000
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L49
	li	$v0,274857984			# 0x10620000
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC33) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC33) # low
	.set	macro
	.set	reorder

	sltu	$v0,$s1,1000
.L48:
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L50
	sltu	$v0,$s1,100
	.set	macro
	.set	reorder

	li	$v0,274857984			# 0x10620000
.L49:
	ori	$v0,$v0,0x4dd3
	multu	$s1,$v0
	mfhi	$a1
	srl	$s0,$a1,6
	lui	$v1,%hi(name) # high
	addiu	$v1,$v1,%lo(name) # low
	sll	$v0,$s0,2
	addu	$v0,$v0,$v1
	lw	$a0,0($v0)
	jal	print
	lui	$a0,%hi(.LC34) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC34) # low
	.set	macro
	.set	reorder

	sll	$v0,$s0,5
	subu	$v0,$v0,$s0
	sll	$v0,$v0,2
	addu	$v0,$v0,$s0
	sll	$v0,$v0,3
	subu	$s1,$s1,$v0
	sltu	$v0,$s1,100
.L50:
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L51
	sltu	$v0,$s1,20
	.set	macro
	.set	reorder

	li	$v0,1374355456			# 0x51eb0000
	ori	$v0,$v0,0x851f
	multu	$s1,$v0
	mfhi	$a1
	srl	$s0,$a1,5
	lui	$v1,%hi(name) # high
	addiu	$v1,$v1,%lo(name) # low
	sll	$v0,$s0,2
	addu	$v0,$v0,$v1
	lw	$a0,0($v0)
	jal	print
	lui	$a0,%hi(.LC30) # high
	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC30) # low
	.set	macro
	.set	reorder

	sll	$v0,$s0,1
	addu	$v0,$v0,$s0
	sll	$v0,$v0,3
	addu	$v0,$v0,$s0
	sll	$v0,$v0,2
	subu	$s1,$s1,$v0
	sltu	$v0,$s1,20
.L51:
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L52
	lui	$v1,%hi(name) # high
	.set	macro
	.set	reorder

	li	$v0,-858993459			# 0xcccccccd
	multu	$s1,$v0
	mfhi	$a1
	srl	$s0,$a1,3
	addiu	$v1,$v1,%lo(name) # low
	addu	$v0,$s0,20
	sll	$v0,$v0,2
	addu	$v0,$v0,$v1
	lw	$a0,0($v0)
	jal	print
	.set	noreorder
	.set	nomacro
	jal	print_char
	li	$a0,32			# 0x00000020
	.set	macro
	.set	reorder

	sll	$v0,$s0,2
	addu	$v0,$v0,$s0
	sll	$v0,$v0,1
	subu	$s1,$s1,$v0
	lui	$v1,%hi(name) # high
.L52:
	addiu	$v1,$v1,%lo(name) # low
	sll	$v0,$s1,2
	addu	$v0,$v0,$v1
	lw	$a0,0($v0)
	jal	print
	.set	noreorder
	.set	nomacro
	jal	print_char
	li	$a0,13			# 0x0000000d
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_char
	li	$a0,10			# 0x0000000a
	.set	macro
	.set	reorder

	lw	$ra,24($sp)
	lw	$s1,20($sp)
	lw	$s0,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,32
	.set	macro
	.set	reorder

	.end	number_text
	.size	number_text,.-number_text
	.align	2
	.globl	main2
	.ent	main2
main2:
	.frame	$sp,4024,$ra		# vars= 4000, regs= 2/0, args= 16, extra= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,4024
	sw	$ra,4020($sp)
	sw	$s0,4016($sp)
	move	$s0,$zero
.L57:
	.set	noreorder
	.set	nomacro
	jal	read_uart
	addu	$s0,$s0,1
	.set	macro
	.set	reorder

	sltu	$v0,$s0,10000
	bne	$v0,$zero,.L57
	lw	$ra,4020($sp)
	lw	$s0,4016($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,4024
	.set	macro
	.set	reorder

	.end	main2
	.size	main2,.-main2
