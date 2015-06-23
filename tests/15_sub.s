.code16
start:

movw $160, %sp

# sub word tests
movw $0x0001, %ax
movw $0x0002, %bx
subw %bx, %ax
movw %ax, (0)
movw %bx, (2)
pushf

movw $0xffff, %dx
movw $0xffff, (4)
subw %dx, (4)
movw %dx, (6)
pushf

movw $0xffff, %cx
movw $0x0001, (8)
subw (8), %cx
movw %cx, (10)
pushf

movw $0x8000, %ax
subw $0x0001, %ax
movw %ax, (12)
pushf

movw $0x8000, %bp
.byte 0x83,0xed,0xff
movw %bp, (14)
pushf

movw $0x7f81, %si
subw $0x903c, %si
movw %si, (16)
pushf

movw $0xefc3, (18)
subw $0xc664, (18)
pushf

movw $0xe933, (20)
.word 0x2e83, 0x0014
.byte 0x64
pushf

# sub byte tests
movb $0x01, (22)
subb $0x02, (22)
pushf

movb $0xff, %dh
subb $0xff, %dh
movw %dx, (23)
pushf

movb $0xff, %al
subb $0x01, %al
movw %ax, (25)
pushf

movb $0x80, (27)
movb $0x01, %ch
subb (27), %ch
movw %cx, (28)
pushf

movb $0x80, %bl
movb $0x7f, (30)
subb %bl, (30)
movw %bx, (31)
pushf

movb $0xbc, %al
movb $0x8e, %ah
subb %al, %ah
movw %ax, (33)
pushf

# sbb word tests
movw $0x0001, %ax
movw $0x0002, %bx
sbbw %ax, %bx
movw %ax, (35)
movw %bx, (37)
pushf

movw $0xffff, %dx
movw $0xffff, (39)
sbbw %dx, (39)
movw %dx, (41)
pushf

movw $0xffff, %cx
movw $0x0001, (43)
sbbw (43), %cx
movw %cx, (45)
pushf

movw $0x8000, %ax
sbbw $0x0001, %ax
movw %ax, (47)
pushf

movw $0x8000, %bp
.byte 0x83,0xdd,0xff
movw %bp, (49)
pushf

movw $0x52c3, %si
sbbw $0xe248, %si
movw %si, (51)
pushf

movw $0xe74c, (53)
sbbw $0x22c0, (53)
pushf

movw $0xfd85, (55)
.word 0x1e83, 0x0037
.byte 0xf5
pushf

# sbb byte tests
movb $0x01, (57)
sbbb $0x02, (57)
pushf

movb $0xff, %dh
sbbb $0xff, %dh
movw %dx, (58)
pushf

movb $0xff, %al
sbbb $0x01, %al
movw %ax, (60)
pushf

movb $0x80, (62)
movb $0x01, %ch
sbbb (62), %ch
movw %cx, (63)
pushf

movb $0x80, %bl
movb $0xff, (65)
sbbb %bl, (65)
movw %bx, (66)
pushf

movb $0xb9, %al
movb $0xd3, %ah
sbbb %al, %ah
movw %ax, (68)
pushf

# dec word tests
movw $0x0000, %di
decw %di
movw %di, (70)
pushf

movw $0x8000, %bp
.byte 0xff, 0xcd
movw %bp, (72)
pushf

movw $0x7412, (74)
decw (74)
pushf

# dec byte tests
movb $0x00, %dl
decb %dl
movw %dx, (76)
pushf

movb $0x80, (77)
decb (77)
pushf

movb $0xb5, (78)
decb (78)
pushf
hlt

.org 65520
jmp start
.org 65535
.byte 0xff

