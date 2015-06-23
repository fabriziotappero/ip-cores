	.file	1 "uart_echo_test.c"

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
	.globl	int_flag
	.sdata
	.align	0
	.align	2
int_flag:
	.size	int_flag,4
	.word	0
	.rdata
	.align	0
	.align	2
.LC0:
	.ascii	"PError!\n\000"
	.align	2
.LC1:
	.ascii	"Sorry Overflow..!\n\000"
	.rdata
	.align	0
	.align	2
.LC2:
	.ascii	"\n"
	.ascii	" parse error occurred\n\000"
	.rdata
	.align	0
	.align	2
.LC3:
	.ascii	"Welcome to YACC World.Apr.8.2005 www.sugawara-systems.co"
	.ascii	"m\000"
	.align	2
.LC4:
	.ascii	"YACC>\000"

	.comm	read_ptr,4

	.comm	buffer,160

	.comm	result_buffer,8

	.comm	sym,1

	.comm	char_ptr,4

	.comm	buf,2

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
	beq	$v0,$zero,.L19
	move	$v1,$v0
	.set	macro
	.set	reorder

	li	$a1,16368			# 0x00003ff0
	move	$v0,$v1
.L22:
	#.set	volatile
	sb	$v0,0($a1)
	#.set	novolatile
	addu	$a0,$a0,1
	lbu	$v1,0($a0)
	.set	noreorder
	.set	nomacro
	bne	$v1,$zero,.L22
	move	$v0,$v1
	.set	macro
	.set	reorder

.L19:
	li	$v0,16368			# 0x00003ff0
	#.set	volatile
	sb	$zero,0($v0)
	#.set	novolatile
	j	$ra
	.end	print
	.size	print,.-print
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
	.text
	.align	2
	.globl	interrupt
	.ent	interrupt
interrupt:
	.frame	$sp,24,$ra		# vars= 0, regs= 2/0, args= 16, extra= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	sw	$ra,20($sp)
	sw	$s0,16($sp)
 #APP
	addiu	$sp,$sp,-52 ;
		sw	$a0,($sp)
		sw  $v0,4($sp)
		sw  $v1,8($sp)
		sw  $a1,12($sp)
		sw  $s0,16($sp)
		sw  $s1,20($sp)
		sw  $s2,24($sp)
		sw  $a3,28($sp)
		sw  $s4,32($sp)
		sw  $s5,36($sp)
		sw  $s6,40($sp)
		sw  $s7,44($sp)
		sw  $a2,48($sp)
 #NO_APP
	jal	read_uart
	move	$s0,$v0
	xori	$v1,$s0,0x000a
	sltu	$v1,$v1,1
	xori	$v0,$s0,0x000d
	sltu	$v0,$v0,1
	or	$v1,$v1,$v0
	.set	noreorder
	.set	nomacro
	beq	$v1,$zero,.L26
	li	$v0,8			# 0x00000008
	.set	macro
	.set	reorder

	lw	$v0,read_ptr
	sb	$zero,0($v0)
	lui	$v0,%hi(buffer) # high
	addiu	$v0,$v0,%lo(buffer) # low
	sw	$v0,read_ptr
	.set	noreorder
	.set	nomacro
	jal	putc_uart
	li	$a0,10			# 0x0000000a
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	putc_uart
	li	$a0,13			# 0x0000000d
	.set	macro
	.set	reorder

	#.set	volatile
	lw	$v0,int_flag
	#.set	novolatile
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L27
	lui	$a0,%hi(.LC0) # high
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print
	addiu	$a0,$a0,%lo(.LC0) # low
	.set	macro
	.set	reorder

	b	.L29
.L27:
	li	$v0,1			# 0x00000001
	#.set	volatile
	sw	$v0,int_flag
	#.set	novolatile
	b	.L29
.L26:
	.set	noreorder
	.set	nomacro
	bne	$s0,$v0,.L30
	lui	$v0,%hi(buffer) # high
	.set	macro
	.set	reorder

	lw	$v1,read_ptr
	addiu	$v0,$v0,%lo(buffer) # low
	sltu	$v0,$v0,$v1
	beq	$v0,$zero,.L35
	.set	noreorder
	.set	nomacro
	jal	putc_uart
	li	$a0,8			# 0x00000008
	.set	macro
	.set	reorder

	lw	$v0,read_ptr
	.set	noreorder
	.set	nomacro
	b	.L34
	addu	$v0,$v0,-1
	.set	macro
	.set	reorder

.L30:
	lw	$v1,read_ptr
.L35:
	lui	$v0,%hi(buffer+160) # high
	addiu	$a0,$v0,%lo(buffer+160) # low
	sltu	$v0,$v1,$a0
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L32
	addu	$v0,$a0,-160
	.set	macro
	.set	reorder

	sb	$zero,0($v1)
	sw	$v0,read_ptr
	lui	$a0,%hi(.LC1) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC1) # low
	.set	macro
	.set	reorder

	b	.L29
.L32:
	.set	noreorder
	.set	nomacro
	jal	putc_uart
	move	$a0,$s0
	.set	macro
	.set	reorder

	lw	$v0,read_ptr
	sb	$s0,0($v0)
	addu	$v0,$v0,1
.L34:
	sw	$v0,read_ptr
.L29:
 #APP
		lw	$a0,($sp)
		lw  $v0,4($sp)
		lw  $v1,8($sp)
		lw  $a1,12($sp)
		lw  $s0,16($sp)
		lw  $s1,20($sp)
		lw  $s2,24($sp)
		lw  $a3,28($sp)
		lw  $s4,32($sp)
		lw  $s5,36($sp)
		lw  $s6,40($sp)
		lw  $s7,44($sp)
		lw  $a2,48($sp)
	addiu	$sp,$sp,52 ;
	lw	$ra,20($sp);
	addiu	$sp,$sp,24 ;
	jr	$26
	nop
 #NO_APP
	lw	$ra,20($sp)
	lw	$s0,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	interrupt
	.size	interrupt,.-interrupt
	.align	2
	.globl	print_longlong
	.ent	print_longlong
print_longlong:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	li	$a2,16372			# 0x00003ff4
	sra	$v1,$a0,0
	sra	$v0,$a0,31
	#.set	volatile
	sw	$v1,0($a2)
	#.set	novolatile
	#.set	volatile
	sw	$a1,0($a2)
	#.set	novolatile
	j	$ra
	.end	print_longlong
	.size	print_longlong,.-print_longlong
	.align	2
	.globl	getsym
	.ent	getsym
getsym:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lw	$v0,char_ptr
	lbu	$a0,0($v0)
	.set	noreorder
	.set	nomacro
	b	.L47
	xori	$v1,$a0,0x0020
	.set	macro
	.set	reorder

.L42:
	lw	$v1,char_ptr
	addu	$v0,$v1,1
	sw	$v0,char_ptr
	lbu	$a0,1($v1)
	xori	$v1,$a0,0x0020
.L47:
	sltu	$v1,$v1,1
	xori	$v0,$a0,0x000a
	sltu	$v0,$v0,1
	or	$v1,$v1,$v0
	.set	noreorder
	.set	nomacro
	bne	$v1,$zero,.L42
	li	$v0,13			# 0x0000000d
	.set	macro
	.set	reorder

	beq	$a0,$v0,.L42
	lw	$v0,char_ptr
	lbu	$v0,0($v0)
	bne	$v0,$zero,.L44
	sb	$zero,sym
	b	.L45
.L44:
	lw	$v0,char_ptr
	lbu	$v1,0($v0)
	sb	$v1,sym
	addu	$v0,$v0,1
	sw	$v0,char_ptr
.L45:
	j	$ra
	.end	getsym
	.size	getsym,.-getsym
	.align	2
	.globl	evaluate_number
	.ent	evaluate_number
evaluate_number:
	.frame	$sp,24,$ra		# vars= 0, regs= 2/0, args= 16, extra= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	sw	$ra,20($sp)
	sw	$s0,16($sp)
	lbu	$s0,sym
	lw	$v0,char_ptr
	move	$v1,$v0
	lbu	$v0,0($v0)
	.set	noreorder
	.set	nomacro
	b	.L55
	addu	$s0,$s0,-48
	.set	macro
	.set	reorder

.L53:
	addu	$v0,$v0,$s0
	sll	$v0,$v0,1
	move	$a0,$v1
	lbu	$v1,0($a0)
	addu	$v0,$v0,$v1
	addu	$s0,$v0,-48
	addu	$v0,$a0,1
	sw	$v0,char_ptr
	move	$v1,$v0
	lbu	$v0,1($a0)
.L55:
	addu	$v0,$v0,-48
	sltu	$v0,$v0,10
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L53
	sll	$v0,$s0,2
	.set	macro
	.set	reorder

	jal	getsym
	move	$v0,$s0
	lw	$ra,20($sp)
	lw	$s0,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	evaluate_number
	.size	evaluate_number,.-evaluate_number
	.align	2
	.globl	expression
	.ent	expression
expression:
	.frame	$sp,32,$ra		# vars= 0, regs= 4/0, args= 16, extra= 0
	.mask	0x80070000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	sw	$ra,28($sp)
	sw	$s2,24($sp)
	sw	$s1,20($sp)
	sw	$s0,16($sp)
	lbu	$s0,sym
	xori	$v1,$s0,0x002b
	sltu	$v1,$v1,1
	xori	$v0,$s0,0x002d
	sltu	$v0,$v0,1
	or	$v1,$v1,$v0
	beq	$v1,$zero,.L57
	jal	getsym
.L57:
	jal	term
	move	$s1,$v0
	li	$v0,45			# 0x0000002d
	bne	$s0,$v0,.L58
	subu	$s1,$zero,$s1
.L58:
	lbu	$v0,sym
	move	$a0,$v0
	andi	$v0,$v0,0x00ff
	xori	$v1,$v0,0x002b
	sltu	$v1,$v1,1
	xori	$v0,$v0,0x002d
	sltu	$v0,$v0,1
	or	$v1,$v1,$v0
	.set	noreorder
	.set	nomacro
	beq	$v1,$zero,.L60
	li	$s2,43			# 0x0000002b
	.set	macro
	.set	reorder

.L61:
	.set	noreorder
	.set	nomacro
	jal	getsym
	move	$s0,$a0
	.set	macro
	.set	reorder

	jal	term
	bne	$s0,$s2,.L62
	.set	noreorder
	.set	nomacro
	b	.L59
	addu	$s1,$s1,$v0
	.set	macro
	.set	reorder

.L62:
	subu	$s1,$s1,$v0
.L59:
	lbu	$a0,sym
	andi	$v0,$a0,0x00ff
	xori	$v1,$v0,0x002b
	sltu	$v1,$v1,1
	xori	$v0,$v0,0x002d
	sltu	$v0,$v0,1
	or	$v1,$v1,$v0
	bne	$v1,$zero,.L61
.L60:
	move	$v0,$s1
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

	.end	expression
	.size	expression,.-expression
	.align	2
	.globl	term
	.ent	term
term:
	.frame	$sp,32,$ra		# vars= 0, regs= 3/0, args= 16, extra= 0
	.mask	0x80030000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	sw	$ra,24($sp)
	sw	$s1,20($sp)
	.set	noreorder
	.set	nomacro
	jal	factor
	sw	$s0,16($sp)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L66
	move	$s1,$v0
	.set	macro
	.set	reorder

.L68:
	lbu	$s0,sym
	jal	getsym
	jal	factor
	move	$v1,$v0
	li	$v0,42			# 0x0000002a
	.set	noreorder
	.set	nomacro
	beq	$s0,$v0,.L70
	slt	$v0,$s0,43
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L75
	li	$v0,37			# 0x00000025
	.set	macro
	.set	reorder

	beq	$s0,$v0,.L72
	b	.L66
.L75:
	li	$v0,47			# 0x0000002f
	beq	$s0,$v0,.L71
	b	.L66
.L70:
	mult	$s1,$v1
	mflo	$s1
	b	.L66
.L71:
	div	$s1,$s1,$v1
	b	.L66
.L72:
	rem	$s1,$s1,$v1
.L66:
	lbu	$a0,sym
	xori	$v1,$a0,0x002a
	sltu	$v1,$v1,1
	xori	$v0,$a0,0x002f
	sltu	$v0,$v0,1
	or	$v1,$v1,$v0
	.set	noreorder
	.set	nomacro
	bne	$v1,$zero,.L68
	li	$v0,37			# 0x00000025
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$a0,$v0,.L68
	move	$v0,$s1
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

	.end	term
	.size	term,.-term
	.text
	.align	2
	.globl	factor
	.ent	factor
factor:
	.frame	$sp,24,$ra		# vars= 0, regs= 2/0, args= 16, extra= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	sw	$ra,20($sp)
	sw	$s0,16($sp)
	lbu	$v0,sym
	addu	$v0,$v0,-48
	sltu	$v0,$v0,10
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L80
	li	$v0,40			# 0x00000028
	.set	macro
	.set	reorder

	jal	evaluate_number
	b	.L89
.L80:
	lbu	$v1,sym
	bne	$v1,$v0,.L82
	jal	getsym
	jal	expression
	move	$s0,$v0
	lbu	$v1,sym
	li	$v0,41			# 0x00000029
	.set	noreorder
	.set	nomacro
	beq	$v1,$v0,.L83
	lui	$a0,%hi(.LC2) # high
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC2) # low
	.set	macro
	.set	reorder

.L83:
	jal	getsym
	.set	noreorder
	.set	nomacro
	b	.L89
	move	$v0,$s0
	.set	macro
	.set	reorder

.L82:
	lbu	$v0,sym
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L89
	move	$v0,$zero
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC2) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC2) # low
	.set	macro
	.set	reorder

	move	$v0,$zero
.L89:
	lw	$ra,20($sp)
	lw	$s0,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	factor
	.size	factor,.-factor
	.align	2
	.globl	strrev
	.ent	strrev
strrev:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	move	$a2,$a0
	lbu	$v0,0($a0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L99
	move	$a1,$a0
	.set	macro
	.set	reorder

	addu	$a1,$a1,1
.L101:
	lbu	$v0,0($a1)
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L101
	addu	$a1,$a1,1
	.set	macro
	.set	reorder

	addu	$a1,$a1,-1
	.set	noreorder
	.set	nomacro
	b	.L100
	addu	$a1,$a1,-1
	.set	macro
	.set	reorder

.L97:
	lbu	$v0,0($a2)
	lbu	$v1,0($a1)
	sb	$v1,0($a2)
	sb	$v0,0($a1)
	addu	$a2,$a2,1
.L99:
	addu	$a1,$a1,-1
.L100:
	sltu	$v0,$a2,$a1
	bne	$v0,$zero,.L97
	.set	noreorder
	.set	nomacro
	j	$ra
	move	$v0,$a0
	.set	macro
	.set	reorder

	.end	strrev
	.size	strrev,.-strrev
	.align	2
	.globl	itoa
	.ent	itoa
itoa:
	.frame	$sp,24,$ra		# vars= 0, regs= 1/0, args= 16, extra= 0
	.mask	0x80000000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	.set	noreorder
	.set	nomacro
	bgez	$a0,.L103
	sw	$ra,16($sp)
	.set	macro
	.set	reorder

	li	$v0,45			# 0x0000002d
	sb	$v0,0($a1)
	addu	$a1,$a1,1
	subu	$a0,$zero,$a0
.L103:
	.set	noreorder
	.set	nomacro
	beq	$a0,$zero,.L105
	move	$a3,$a1
	.set	macro
	.set	reorder

	li	$t0,1717960704			# 0x66660000
	ori	$t0,$t0,0x6667
.L106:
	mult	$a0,$t0
	mfhi	$t1
	sra	$v1,$t1,2
	sra	$v0,$a0,31
	subu	$a2,$v1,$v0
	move	$v1,$a2
	sll	$v0,$a2,2
	addu	$v0,$v0,$a2
	sll	$v0,$v0,1
	subu	$a2,$a0,$v0
	addu	$v0,$a2,48
	sb	$v0,0($a3)
	move	$a0,$v1
	.set	noreorder
	.set	nomacro
	bne	$a0,$zero,.L106
	addu	$a3,$a3,1
	.set	macro
	.set	reorder

.L105:
	.set	noreorder
	.set	nomacro
	bne	$a1,$a3,.L108
	li	$v0,48			# 0x00000030
	.set	macro
	.set	reorder

	sb	$v0,0($a1)
	addu	$a3,$a1,1
.L108:
	sb	$zero,0($a3)
	.set	noreorder
	.set	nomacro
	jal	strrev
	move	$a0,$a1
	.set	macro
	.set	reorder

	lw	$ra,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	itoa
	.size	itoa,.-itoa
	.align	2
	.globl	calculator
	.ent	calculator
calculator:
	.frame	$sp,32,$ra		# vars= 0, regs= 3/0, args= 16, extra= 0
	.mask	0x80030000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	sw	$ra,24($sp)
	sw	$s1,20($sp)
	sw	$s0,16($sp)
	lui	$s0,%hi(buffer) # high
	addiu	$s0,$s0,%lo(buffer) # low
	sw	$s0,char_ptr
	jal	getsym
	jal	expression
	move	$s1,$v0
	.set	noreorder
	.set	nomacro
	jal	print_uart
	move	$a0,$s0
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	putc_uart
	li	$a0,61			# 0x0000003d
	.set	macro
	.set	reorder

	la	$a1,result_buffer
	.set	noreorder
	.set	nomacro
	jal	itoa
	move	$a0,$s1
	.set	macro
	.set	reorder

	la	$a0,result_buffer
	jal	print_uart
	.set	noreorder
	.set	nomacro
	jal	putc_uart
	li	$a0,10			# 0x0000000a
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	putc_uart
	li	$a0,10			# 0x0000000a
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	putc_uart
	li	$a0,13			# 0x0000000d
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

	.end	calculator
	.size	calculator,.-calculator
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
	beq	$v0,$zero,.L113
	move	$v1,$v0
	.set	macro
	.set	reorder

.L114:
	sb	$v1,0($a0)
	addu	$a1,$a1,1
	lbu	$v1,0($a1)
	.set	noreorder
	.set	nomacro
	bne	$v1,$zero,.L114
	addu	$a0,$a0,1
	.set	macro
	.set	reorder

.L113:
	.set	noreorder
	.set	nomacro
	j	$ra
	sb	$zero,0($a0)
	.set	macro
	.set	reorder

	.end	strcpy
	.size	strcpy,.-strcpy
	.align	2
	.globl	calculator_test
	.ent	calculator_test
calculator_test:
	.frame	$sp,24,$ra		# vars= 0, regs= 1/0, args= 16, extra= 0
	.mask	0x80000000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	sw	$ra,16($sp)
	move	$a1,$a0
	lui	$a0,%hi(buffer) # high
	.set	noreorder
	.set	nomacro
	jal	strcpy
	addiu	$a0,$a0,%lo(buffer) # low
	.set	macro
	.set	reorder

	jal	calculator
	lw	$ra,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	calculator_test
	.size	calculator_test,.-calculator_test
	.text
	.align	2
	.globl	main2
	.ent	main2
main2:
	.frame	$sp,24,$ra		# vars= 0, regs= 1/0, args= 16, extra= 0
	.mask	0x80000000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	sw	$ra,16($sp)
	li	$v1,16376			# 0x00003ff8
	lui	$v0,%hi(interrupt) # high
	addiu	$v0,$v0,%lo(interrupt) # low
	#.set	volatile
	sw	$v0,0($v1)
	#.set	novolatile
	lui	$v0,%hi(buffer) # high
	addiu	$v0,$v0,%lo(buffer) # low
	sw	$v0,read_ptr
	.set	noreorder
	.set	nomacro
	jal	putc_uart
	li	$a0,10			# 0x0000000a
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	putc_uart
	li	$a0,13			# 0x0000000d
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
	jal	putc_uart
	li	$a0,10			# 0x0000000a
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	putc_uart
	li	$a0,13			# 0x0000000d
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC4) # high
.L122:
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC4) # low
	.set	macro
	.set	reorder

.L119:
	#.set	volatile
	lw	$v0,int_flag
	#.set	novolatile
	beq	$v0,$zero,.L119
	#.set	volatile
	sw	$zero,int_flag
	#.set	novolatile
	jal	calculator
	.set	noreorder
	.set	nomacro
	b	.L122
	lui	$a0,%hi(.LC4) # high
	.set	macro
	.set	reorder

	.end	main2
	.size	main2,.-main2
	.align	2
	.globl	set_interrupt_address
	.ent	set_interrupt_address
set_interrupt_address:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	li	$v0,16376			# 0x00003ff8
	lui	$v1,%hi(interrupt) # high
	addiu	$v1,$v1,%lo(interrupt) # low
	#.set	volatile
	sw	$v1,0($v0)
	#.set	novolatile
	lui	$v0,%hi(buffer) # high
	addiu	$v0,$v0,%lo(buffer) # low
	sw	$v0,read_ptr
	j	$ra
	.end	set_interrupt_address
	.size	set_interrupt_address,.-set_interrupt_address
	.align	2
	.globl	init_parser
	.ent	init_parser
init_parser:
	.frame	$sp,24,$ra		# vars= 0, regs= 1/0, args= 16, extra= 0
	.mask	0x80000000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	sw	$ra,16($sp)
	lui	$v0,%hi(buffer) # high
	addiu	$v0,$v0,%lo(buffer) # low
	sw	$v0,char_ptr
	jal	getsym
	lw	$ra,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	init_parser
	.size	init_parser,.-init_parser
	.align	2
	.globl	parse_error
	.ent	parse_error
parse_error:
	.frame	$sp,24,$ra		# vars= 0, regs= 1/0, args= 16, extra= 0
	.mask	0x80000000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	sw	$ra,16($sp)
	lui	$a0,%hi(.LC2) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC2) # low
	.set	macro
	.set	reorder

	move	$v0,$zero
	lw	$ra,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	parse_error
	.size	parse_error,.-parse_error
