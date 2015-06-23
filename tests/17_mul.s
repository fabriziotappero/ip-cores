.code16
start:

movw $192, %sp

# mul word
movw $0x0003, %bx
movw $0x0007, %ax
movw $0xffff, %dx
mulw %bx

movw %ax, (0)
movw %dx, (2)
pushf

movw $0xa320, %dx
movw $0xffff, %ax
mulw %dx
movw %ax, (4)
movw %dx, (6)
pushf

movw $0xffff, %ax
movw $0x1, (8)
mulw (8)
movw %ax, (10)
movw %dx, (12)
pushf

movw $0xffff, %ax
movw $0xffff, (14)
mulw (14)
movw %ax, (16)
movw %dx, (18)
pushf

movw $0x46db, %ax
movw $0x0000, %bp
mulw %bp
movw %bp, (20)
movw %ax, (22)
movw %dx, (24)
pushf

movw $0x46db, %ax
movw $0xeeeb, %si
mulw %si
movw %si, (26)
movw %ax, (28)
movw %dx, (30)
pushf

# mul byte
movb $0x14, %bl
movw $0xff07, %ax
movw $0xffff, %dx
mulb %bl

movw %ax, (32)
movw %dx, (34)
pushf

movb $0x24, %ch
movw $0x00ff, %ax
mulb %ch
movw %ax, (36)
movw %dx, (38)
pushf

movw $0xff, %ax
movb $0x1, (40)
mulb (40)
movw %ax, (41)
movw %dx, (43)
pushf

movw $0xffff, %ax
movb $0xff, (45)
mulb (45)
movw %ax, (46)
movw %dx, (46)
pushf

movw $0xc5, %ax
movw $0x00, %dx
mulb %dl
movw %dx, (48)
movw %ax, (50)
pushf

movb $0xb5, %al
movb $0xf9, %dh
mulb %dh
movw %si, (52)
movw %ax, (54)
movw %dx, (56)
pushf

# imul word
movw $0x0003, %bx
movw $0x0007, %ax
movw $0xffff, %dx
imulw %bx

movw %ax, (60)
movw %dx, (62)
pushf

movw $0xa320, %dx
movw $0xffff, %ax
imulw %dx
movw %ax, (64)
movw %dx, (66)
pushf

movw $0xffff, %ax
movw $0x1, (68)
imulw (68)
movw %ax, (70)
movw %dx, (72)
pushf

movw $0xffff, %ax
movw $0xffff, (74)
imulw (74)
movw %ax, (76)
movw %dx, (78)
pushf

movw $0x46db, %ax
movw $0x0000, %bp
imulw %bp
movw %bp, (80)
movw %ax, (82)
movw %dx, (84)
pushf

movw $0x46db, %ax
movw $0xeeeb, %si
imulw %si
movw %si, (86)
movw %ax, (88)
movw %dx, (90)
pushf

# imul byte
movb $0x14, %bl
movw $0xff07, %ax
movw $0xffff, %dx
imulb %bl

movw %ax, (92)
movw %dx, (94)
pushf

movb $0x24, %ch
movw $0x00ff, %ax
imulb %ch
movw %ax, (96)
movw %dx, (98)
pushf

movw $0xff, %ax
movb $0x1, (100)
imulb (100)
movw %ax, (101)
movw %dx, (103)
pushf

movw $0xffff, %ax
movb $0xff, (105)
imulb (105)
movw %ax, (106)
movw %dx, (106)
pushf

movw $0xc5, %ax
movw $0x00, %dx
imulb %dl
movw %dx, (108)
movw %ax, (110)
pushf

movb $0xb5, %al
movb $0xf9, %dh
imulb %dh
movw %si, (112)
movw %ax, (114)
movw %dx, (116)
pushf

# aad tests
movw $0xff00, %ax
aad
movw %ax, (118)
pushf

movw $0xffff, %ax
aad $0x12
movw %ax, (120)
pushf

movw $0x00ff, %ax
aad $0xff
movw %ax, (122)
pushf

movw $0x532d, %ax
aad $0x39
movw %ax, (124)
pushf

hlt

.org 65520
jmp start

.org 65535
.byte 0xff
