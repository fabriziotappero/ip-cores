.code16
start:
movw $0xf100, %bx
movw %bx, %es

es movw (0), %bx
es movw (2), %ax
movw %ax, (2)
movw $0x2, %sp
es push %bx

es les (0), %dx
movw %dx, (4)
movw %es, %dx
movw %dx, (6)

movw $5, %di
cs lea 23(%bp,%di), %si
movw %si, (8)

movw $0x0005, %bx
movw $0x0005, %ax
movw $0x2345, (10)
movw $0xf100, %dx
movw %dx, %es
es xlat
movw %ax, (12)

# inc with segment
movw $0x1, %ax
movw %ax, %ss
movw $0x6, (16)
ss incw (0)

# div with interrupt
movw $32, %sp
movw $0x0, (18)
ss
.byte 0xf3
divw (2)
subw $6, %sp

movw $0x1200, (20)
movw $5, %bx
movw $3, %si
# repz prefix (do not affect)
.byte 0xf3
ss call *-4(%bx,%si)

hlt

.org 0x1000
.word 0x1100
.word 0xf000

.org 0x100a
.word 0x5678

.org 0x1100
movw %sp, %si
ss movw (%si), %si
movw %si, (14)
addw $6, %si
movw %sp, %di
ss movw %si, (%di)
iret

.org 0x1200
movw $0xf120, %cx
movw %cx, %es
movw $0x0200, %si
movw $0x0e01, %di

es cmpsb
pushf

movw $0x1, %ax
movw %ax, %es
movw $6, %di
movw $0x1400, %si
movw $0x6, %cx
# Two prefixes
rep cs movsb
hlt

.org 0x1400
.byte 0x01,0xff,0xff,0x80
.word 0x0002
.byte 0xc2

.org 0x2001
.byte 0x02,0xff,0x01,0x01
.word 0x8001

.org 65520
jmp start
.org 65535
.byte 0xff
