.code16
start:

# sal/shl word operations
movw $0x6ec5, %ax
movw $0xb1a8, %bx
movw $0x5338, (0)
movw $0x31fe, (2)

movw $128, %sp

sal  %ax        # (1)
pushf
mov  %ax, (32)

shlw (0)        # (2)
pushf

movw $0x100, %cx
shl  %cl, %bx   # (3), zero bit shift
pushf
movw %bx, (34)

movw $0xffff, %cx
movw %bx, %dx
sal  %cl, %dx   # (3), -1, result 0
pushf
movw %dx, (36)

movb $0x8, %cl
sal  %cl, %bx   # (3) normal
pushf
movw %bx, (38)

movb $0x4, %cl
sal  %cl, (2)   # (4)
pushf

# sal/shl byte operations
movw $0x956f, %dx
movw $0x4293, %ax
movw $0x33c0, (4)
movw $0x64ff, (6)

shl  %ah        # (5)
pushf
mov  %ax, (40)

salb (5)        # (6)
pushf

movb $0x7, %cl
shl  %cl, %dl   # (7)
pushf
movw %dx, (42)

salb %cl, (6)   # (8)
pushf

# sar word operations
movw $0xfb72, %ax
movw $0xdfb9, %bx
movw $0x1ebb, (8)
movw $0x742f, (10)

sar  %ax        # (9)
pushf
mov  %ax, (44)

sarw (8)        # (10)
pushf

movw $0x100, %cx
sar  %cl, %bx   # (11), zero bit shift
pushf
movw %bx, (46)

movw $0xffff, %cx
movw %bx, %dx
sar  %cl, %dx   # (11), -1, result 0
pushf
movw %dx, (48)

movb $0x5, %cl
sar  %cl, %bx   # (11) normal
pushf
movw %bx, (50)

movb $0x4, %cl
sar  %cl, (10)  # (12)
pushf

# sar byte operations
movw $0x93b8, %dx
movw $0x6688, %ax
movw $0xcad4, (12)
movw $0x6ec9, (14)

sar  %ah        # (13)
pushf
mov  %ax, (52)

sarb (13)       # (14)
pushf

movb $0x7, %cl
sar  %cl, %dl   # (15)
pushf
movw %dx, (54)

sarb %cl, (14)  # (16)
pushf

# shr word operations
movw $0x7ba1, %ax
movw $0x54e8, %bx
movw $0xbaaa, (16)
movw $0x3431, (18)

shr  %ax        # (17)
pushf
mov  %ax, (56)

shrw (16)       # (18)
pushf

movw $0x100, %cx
shr  %cl, %bx   # (19), zero bit shift
pushf
movw %bx, (58)

movw $0xffff, %cx
movw %bx, %dx
shr  %cl, %dx   # (19), -1, result 0
pushf
movw %dx, (60)

movb $0x4, %cl
shr  %cl, %bx   # (19) normal
pushf
movw %bx, (62)

movb $0x4, %cl
shr  %cl, (18)  # (20)
pushf

# shr byte operations
movw $0x0410, %dx
movw $0x1628, %ax
movw $0x3b26, (20)
movw $0x8d0d, (22)

shr  %ah        # (21)
pushf
mov  %ax, (64)

shrb (21)       # (22)
pushf

movb $0x7, %cl
shr  %cl, %dl   # (23)
pushf
movw %dx, (66)

shrb %cl, (22)  # (24)
pushf




hlt

.org 65520
jmp start
.org 65535
.byte 0xff
