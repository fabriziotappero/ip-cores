.code16
start:
movw $208, %sp

# Exception 0 handler
movw $0x1000, (0)
movw $0xf000, (2)

movw $208, %bp

# div word tests
# easy test
movw $0x0, %dx
movw $0x14, %ax
movw $0x5, %bx

movw $0x2, (%bp)
divw %bx
addw $0x2, %bp

movw %ax, (128)
movw %bx, (130)
movw %dx, (4)
pushf


movw $0xa320, %dx
movw $0xc3da, %ax
movw $0xffff, (6)

movw $0x4, (%bp)
divw (6)
addw $0x2, %bp

movw %ax, (8)
movw %dx, (10)
pushf


movw $0xffff, %dx
movw $0xffff, %ax
movw $0x1, %cx

movw $0x2, (%bp)
divw %cx
addw $0x2, %bp

movw %ax, (12)
movw %cx, (14)
movw %dx, (16)
pushf


movw $0xffff, %dx
movw $0xffff, %ax
movw $0xffff, (18)

movw $0x4, (%bp)
divw (18)
addw $0x2, %bp

movw %ax, (20)
movw %dx, (22)
pushf


movw $0xfbb4, %dx
movw $0xc3da, %ax
movw $0xae8e, %cx

movw $0x2, (%bp)
divw %cx
addw $0x2, %bp

movw %ax, (24)
movw %cx, (26)
movw %dx, (28)
pushf


movw $0x25c9, %dx
movw $0xf110, %ax

movw $0x2, (%bp)
divw %ax
addw $0x2, %bp

movw %ax, (30)
movw %dx, (32)
pushf


# div byte tests
# easy test
movw $0x14, %ax
movw $0x5, %bx

movw $0x2, (%bp)
divb %bl
addw $0x2, %bp

movw %ax, (34)
movw %bx, (36)
movw %dx, (38)
pushf

movw $0xa320, %dx
movw $0xc3da, %ax
movw $0xff, (40)

movw $0x4, (%bp)
divb (40)
addw $0x2, %bp

movw %ax, (42)
movw %dx, (44)
pushf

movw $0xffff, %ax
movb $0x1, %dh

movw $0x2, (%bp)
divb %dh
addw $0x2, %bp

movw %ax, (46)
movw %dx, (48)
pushf

movw $0xffff, %ax
movw $0xffff, (50)

movw $0x4, (%bp)
divb (51)
addw $0x2, %bp

movw %ax, (52)
movw %dx, (54)
pushf

movw $0x008a, %ax
movw $0xae8e, %cx

movw $0x2, (%bp)
divb %cl
addw $0x2, %bp

movw %ax, (56)
movw %cx, (58)
pushf

movw $0x0669, %dx
movw $0x89f3, %ax

movw $0x2, (%bp)
divb %al
addw $0x2, %bp

movw %ax, (60)
movw %dx, (62)
pushf

# idiv word tests
# easy test
movw $0x0, %dx
movw $0x14, %ax
movw $0xfa, %bx

movw $0x2, (%bp)
idivw %bx
addw $0x2, %bp

movw %ax, (64)
movw %bx, (66)
movw %dx, (68)
pushf


movw $0xa320, %dx
movw $0xc3da, %ax
movw $0xffff, (70)

movw $0x4, (%bp)
idivw (70)
addw $0x2, %bp

movw %ax, (72)
movw %dx, (74)
pushf


movw $0xffff, %dx
movw $0xffff, %ax
movw $0x1, %cx

movw $0x2, (%bp)
idivw %cx
addw $0x2, %bp

movw %ax, (76)
movw %cx, (78)
movw %dx, (80)
pushf


movw $0xffff, %dx
movw $0xffff, %ax
movw $0xffff, (82)

movw $0x4, (%bp)
idivw (82)
addw $0x2, %bp

movw %ax, (84)
movw %dx, (86)
pushf


movw $0xfbb4, %dx
movw $0xc3da, %ax
movw $0xae8e, %cx

movw $0x2, (%bp)
idivw %cx
addw $0x2, %bp

movw %ax, (88)
movw %cx, (90)
movw %dx, (92)
pushf


movw $0x25c9, %dx
movw $0xf110, %ax

movw $0x2, (%bp)
idivw %ax
addw $0x2, %bp

movw %ax, (94)
movw %dx, (96)
pushf

# idiv byte tests
# easy test
movw $0x14, %ax
movw $0x5, %bx

movw $0x2, (%bp)
idivb %bl
addw $0x2, %bp

movw %ax, (98)
movw %bx, (100)
movw %dx, (102)
pushf


movw $0xa320, %dx
movw $0xc3da, %ax
movw $0xff, (104)

movw $0x4, (%bp)
idivb (104)
addw $0x2, %bp

movw %ax, (106)
movw %dx, (108)
pushf


movw $0xffff, %ax
movb $0x1, %dh

movw $0x2, (%bp)
idivb %dh
addw $0x2, %bp

movw %ax, (110)
movw %dx, (112)
pushf


movw $0xffff, %ax
movw $0xffff, (114)

movw $0x4, (%bp)
idivb (115)
addw $0x2, %bp

movw %ax, (116)
movw %dx, (118)
pushf


movw $0x008a, %ax
movw $0xae8e, %cx

movw $0x2, (%bp)
idivb %cl
addw $0x2, %bp

movw %ax, (120)
movw %cx, (122)
pushf


movw $0x0669, %dx
movw $0x89f3, %ax

movw $0x2, (%bp)
idivb %al
addw $0x2, %bp

movw %ax, (124)
movw %dx, (126)
pushf


# AAM tests
movw $0xffff, %ax

movw $0x2, (%bp)
aam $0
addw $0x2, %bp
movw %ax, (132)
pushf

movw $0x2, (%bp)
aam $1
addw $0x2, %bp
movw %ax, (134)
pushf

movw $0xffff, %ax
movw $0x2, (%bp)
aam
addw $0x2, %bp
movw %ax, (136)
pushf

movw $0xff00, %ax
movw $0x2, (%bp)
aam $0
addw $0x2, %bp
movw %ax, (138)
pushf

movw $0x2, (%bp)
aam $1
addw $0x2, %bp
movw %ax, (140)
pushf

movw $0x3ffb, %ax
movw $0x2, (%bp)
aam
addw $0x2, %bp
movw %ax, (142)
pushf

hlt

# Exception handler (int 0)
.org 0x1000
push %ax
push %di
movw (%bp), %ax
movw %sp, %si
addw $4, %si
movw (%si), %si
movw %si, (%bp)
addw %ax, %si
movw %sp, %di
addw $4, %di
movw %si, (%di)
pop %di
pop %ax
iret

.org 65520
jmp start
.org 65535
.byte 0xff
