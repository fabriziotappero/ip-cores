.code16
start:

movw $96, %sp

# cmp word tests
movw $0x0001, %ax
movw $0x0002, %bx
cmpw %bx, %ax
movw %ax, (0)
movw %bx, (2)
pushf

movw $0xffff, %dx
movw $0xffff, (4)
cmpw %dx, (4)
movw %dx, (6)
pushf

movw $0xffff, %cx
movw $0x0001, (8)
cmpw (8), %cx
movw %cx, (10)
pushf

movw $0x8000, %ax
cmpw $0x0001, %ax
movw %ax, (12)
pushf

movw $0x8000, %bp
.byte 0x83,0xfd,0xff
movw %bp, (14)
pushf

movw $0x7f81, %si
cmpw $0x903c, %si
movw %si, (16)
pushf

movw $0xefc3, (18)
cmpw $0xc664, (18)
pushf

movw $0xe933, (20)
.word 0x3e83, 0x0014
.byte 0x64
pushf

# cmp byte tests
movb $0x01, (22)
cmpb $0x02, (22)
pushf

movb $0xff, %dh
cmpb $0xff, %dh
movw %dx, (23)
pushf

movb $0xff, %al
cmpb $0x01, %al
movw %ax, (25)
pushf

movb $0x80, (27)
movb $0x01, %ch
cmpb (27), %ch
movw %cx, (28)
pushf

movb $0x80, %bl
movb $0x7f, (30)
cmpb %bl, (30)
movw %bx, (31)
pushf

movb $0xbc, %al
movb $0x8e, %ah
cmpb %al, %ah
movw %ax, (33)
pushf

# neg word tests
movw $0x0, %cx
negw %cx
movw %cx, (34)
pushf

movw $0x7fff, (36)
negw (36)
pushf

movw $0x8000, %bp
negw %bp
movw %bp, (38)
pushf

movw $0xace9, (40)
negw (40)
pushf

# neg byte tests
movb $0x0, %ah
negb %ah
movw %ax, (42)
pushf

movb $0x7f, (44)
negb (44)
pushf

movb $0xc9, %cl
negb %cl
movw %cx, (45)
pushf

movb $0x80, (47)
negb (47)
pushf
hlt

.org 65520
jmp start
.org 65535
.byte 0xff

