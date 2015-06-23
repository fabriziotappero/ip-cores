#define MCFG1 0x10380233
#define MCFG2 0xe6A06e60
#define MCFG3 0x000ff000
#define ASDCFG 0xfff00100
#define DSDCFG 0xe6A06e60
#define L2MCTRLIO 0x80000000
#define IRQCTRL   0x80000200
#define RAMSTART  0x40000000
#define RAMSIZE   0x00100000
#define STACKSIZE 0x00002000
	
	.seg	"text"
	.proc	0
	.align	4
	.global start
start:

	flush
	set 0x10e0, %g1		! init IU
	mov %g1, %psr
	mov %g0, %wim
	mov %g0, %tbr
	mov %g0, %y
	nop
	set  0x81000f, %g1
	sta %g1, [%g0] 2
/*
	set 0x80000200, %g3
	st  %g0, [%g3+0]
	st  %g0, [%g3+4]
	st  %g0, [%g3+8]
	st  %g0, [%g3+0xC]
	set -1, %g2
	st  %g2, [%g3+0x40]
	st  %g2, [%g3+0x44]

	set 0x80000300, %g3
	set 15, %g2
	st  %g2, [%g3+0]
	st  %g2, [%g3+4]
	st  %g2, [%g3+0x10]
	st  %g2, [%g3+0x14]
	st  %g2, [%g3+0x18]

	mov %g0, %asr19
*/
2:
	mov %asr17, %g3
	and %g3, 0x1f, %g3
	mov %g0, %g4
	mov %g0, %g5
	mov %g0, %g6
	mov %g0, %g7
1:
	mov %g0, %l0
	mov %g0, %l1
	mov %g0, %l2
	mov %g0, %l3
	mov %g0, %l4
	mov %g0, %l5
	mov %g0, %l6
	mov %g0, %l7
	mov %g0, %o0
	mov %g0, %o1
	mov %g0, %o2
	mov %g0, %o3
	mov %g0, %o4
	mov %g0, %o5
	mov %g0, %o6
	mov %g0, %o7
	subcc %g3, 1, %g3
	bge 1b
	save

	mov	2, %g1
	mov	%g1, %wim
	set 0x10e0, %g1		! enable traps
	mov %g1, %psr
	nop; nop; nop;

	mov %asr17, %g3
	srl %g3, 28, %g3
	andcc %g3, 0x0f, %g3
	bne 1f

	set L2MCTRLIO, %g1
	set MCFG1, %g2
	st  %g2, [%g1]
	set MCFG2, %g2
	st  %g2, [%g1+4]
	set MCFG3, %g2
	st  %g2, [%g1+8]
!	set IRQCTRL, %g1
!	set 0x0ffff, %g2
!	st  %g2, [%g1+0x10]

	set 0xFFFFF860, %g1
	ld  [%g1], %g2
	srl %g2, 12, %g2
	set 0x01009, %g1
	subcc %g1, %g2, %g0
	bne 1f

	set ASDCFG, %g1
	set DSDCFG, %g2
	st  %g2, [%g1]

	! %g3 = cpu index
1:	set STACKSIZE, %g2
        mov %g0, %g1
2:	subcc %g3, 0, %g0
	be 3f
	nop									
	add %g1, %g2, %g1
	ba 2b
	sub %g3, 1, %g3		
				
3:	set RAMSTART+ RAMSIZE-32, %fp
	sub %fp, %g1, %fp
	sub %fp, 96, %sp

	set RAMSTART, %g1
	jmp %g1
	nop	

.align	32
