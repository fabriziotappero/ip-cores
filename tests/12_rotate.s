.code16
start:

# rcl word operations
movw $0x3b5e, %ax
movw $0xc8a7, %bx
movw $0x2072, (0)
movw $0x3e79, (2)

movw $160, %sp

rcl  %ax        # (1)
pushf
mov  %ax, (32)

rclw (0)        # (2)
pushf

movw $0x100, %cx
rcl  %cl, %bx   # (3), zero bit shift
pushf
movw %bx, (34)

movw $0xffff, %cx
movw %bx, %dx
rcl  %cl, %dx   # (3), -1, result 0
pushf
movw %dx, (36)

movb $0x8, %cl
rcl  %cl, %bx   # (3) normal
pushf
movw %bx, (38)

movb $0x4, %cl
rclw %cl, (2)   # (4)
pushf

# rcl byte operations
movw $0x5904, %dx
movw $0xbe7c, %ax
movw $0xd62f, (4)
movw $0x6fd8, (6)

rcl  %ah        # (5)
pushf
mov  %ax, (40)

rclb (5)        # (6)
pushf

movb $0x7, %cl
rcl  %cl, %dl   # (7)
pushf
movw %dx, (42)

rclb %cl, (6)   # (8)
pushf

# rcr word operations
movw $0x15d6, %ax
movw $0x8307, %bx
movw $0x9ab7, (8)
movw $0x28b6, (10)

rcr  %ax        # (9)
pushf
mov  %ax, (44)

rcrw (8)        # (10)
pushf

movw $0x100, %cx
rcr  %cl, %bx   # (11), zero bit shift
pushf
movw %bx, (46)

movw $0xffff, %cx
movw %bx, %dx
rcr  %cl, %dx   # (11), -1, result 0
pushf
movw %dx, (48)

movb $0x5, %cl
rcr  %cl, %bx   # (11) normal
pushf
movw %bx, (50)

movb $0x4, %cl
rcrw %cl, (10)  # (12)
pushf

# rcr byte operations
movw $0x7eaa, %dx
movw $0x3a8d, %ax
movw $0xa414, (12)
movw $0x2838, (14)

rcr  %ah        # (13)
pushf
mov  %ax, (52)

rcrb (13)       # (14)
pushf

movb $0x7, %cl
rcr  %cl, %dl   # (15)
pushf
movw %dx, (54)

rcrb %cl, (14)  # (16)
pushf

# rol word operations
movw $0x020d, %ax
movw $0x8d5a, %bx
movw $0x28dd, (16)
movw $0xd74a, (18)

rol  %ax        # (17)
pushf
mov  %ax, (56)

rolw (16)       # (18)
pushf

movw $0x100, %cx
rol  %cl, %bx   # (19), zero bit shift
pushf
movw %bx, (58)

movw $0xffff, %cx
movw %bx, %dx
rol  %cl, %dx   # (19), -1, result 0
pushf
movw %dx, (60)

movb $0x4, %cl
rol  %cl, %bx   # (19) normal
pushf
movw %bx, (62)

movb $0x4, %cl
rolw %cl, (18)  # (20)
pushf

# rol byte operations
movw $0x9d09, %dx
movw $0xc948, %ax
movw $0x0b80, (20)
movw $0x48e8, (22)

rol  %ah        # (21)
pushf
mov  %ax, (64)

rolb (21)       # (22)
pushf

movb $0x7, %cl
rol  %cl, %dl   # (23)
pushf
movw %dx, (66)

rolb %cl, (22)  # (24)
pushf


# ror word operations
movw $0xf25e, %ax
movw $0x2eb5, %bx
movw $0x0151, (24)
movw $0x7237, (26)

ror  %ax        # (25)
pushf
mov  %ax, (68)

rorw (24)       # (26)
pushf

movw $0x100, %cx
ror  %cl, %bx   # (27), zero bit shift
pushf
movw %bx, (70)

movw $0xffff, %cx
movw %bx, %dx
ror  %cl, %dx   # (27), -1, result 0
pushf
movw %dx, (72)

movb $0x4, %cl
ror  %cl, %bx   # (27) normal
pushf
movw %bx, (74)

movb $0x4, %cl
rorw %cl, (26)  # (28)
pushf

# ror byte operations
movw $0x4288, %dx
movw $0x8bab, %ax
movw $0x5dd9, (28)
movw $0xc7f7, (30)

ror  %ah        # (29)
pushf
mov  %ax, (76)

rorb (29)       # (30)
pushf

movb $0x7, %cl
ror  %cl, %dl   # (31)
pushf
movw %dx, (78)

rorb %cl, (30)  # (32)
pushf


hlt

.org 65520
jmp start
.org 65535
.byte 0xff
