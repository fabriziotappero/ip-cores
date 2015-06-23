.code16
start:

# Some random stuff to start with
movw $0x7659, %ax
movw $0x4bb8, %bx
movw $0x3c84, %cx
movw $0x1b76, (0)
movw $0x240b, (2)

movw $256, %sp

# Word AND
andw %ax, %bx      # (1)
pushf
movw %bx, (32)
andw (2), %cx      # (2)
pushf
movw %cx, (34)
andw %cx, (0)      # (3)
pushf
andw $0x4571, %ax  # (4)
pushf
movw %ax, (36)
andw $0x27e9, %bx  # (5)
pushf
movw %bx, (38)
andw $0x3549, (2)  # (6)
pushf

# Byte AND
andb %al, %ah      # (7)
pushf
movb %ah, (40)
andb (1), %cl      # (8)
pushf
movb %cl, (41)
andb %ch, (3)      # (9)
pushf
andb $0x46, %al    # (10)
pushf
movb %al, (42)
andb $0x2d, %bl    # (11)
pushf
movb %bl, (43)
andb $0xc6, (2)    # (12)
pushf

movw $0x05e3, %ax
movw $0xf877, %bx
movw $0x4ae8, %cx
movw $0x3b69, %dx
movw $0x30c0, (4)
movw $0x5775, (6)
movw $0xfe66, (8)

# Word OR
orw  %ax, %bx      # (13)
pushf
movw %bx, (44)
orw  (4), %cx      # (14)
pushf
movw %cx, (46)
orw  %ax, (6)      # (15)
pushf
orw  $0x41c3, %ax  # (16)
pushf
movw %ax, (48)
orw  $0xb05d, %dx  # (17)
pushf
movw %dx, (50)
orw  $0x8d4c, (8)  # (18)
pushf

# Byte OR
orb %al, %ah       # (19)
pushf
movb %ah, (52)
orb (5), %cl       # (20)
pushf
movb %cl, (53)
orb %ch, (6)       # (21)
pushf
orb $0x43, %al     # (22)
pushf
movb %al, (54)
orb $0x57, %bl     # (23)
pushf
movb %bl, (55)
orb $0x54, (7)     # (24)
pushf

movw $0xd0b4, %ax
movw $0x1bb8, %bx
movw $0x2b03, %cx
movw $0xc3e6, %dx
movw $0x3939, (10)
movw $0x864b, (12)
movw $0x8587, (14)

# Word XOR
xorw  %ax, %bx     # (25)
pushf
movw %bx, (56)
xorw (10), %cx     # (26)
pushf
movw %cx, (58)
xorw %ax, (12)     # (27)
pushf
xorw $0x3d03, %ax  # (28)
pushf
movw %ax, (60)
xorw $0x632d, %dx  # (29)
pushf
movw %dx, (62)
xorw $0xcf07, (14) # (30)
pushf

# Byte XOR
xorb %al, %ah      # (31)
pushf
movb %ah, (64)
xorb (11), %cl     # (32)
pushf
movb %cl, (65)
xorb %ch, (12)     # (33)
pushf
xorb $0xb6, %al    # (34)
pushf
movb %al, (66)
xorb $0xae, %bl    # (35)
pushf
movb %bl, (67)
xorb $0xdf, (13)   # (36)
pushf

movw $0x4d37, %ax
movw $0xdbe1, %bx
movw $0x6549, %cx
movw $0x5cc4, %dx
movw $0xa8a8, (16)
movw $0x35f6, (18)
movw $0x4f00, (20)

# Word TEST
testw  %ax, %bx     # (37)
pushf
movw %bx, (68)
testw (16), %cx     # (38)
pushf
movw %cx, (70)
testw %ax, (18)     # (39)
pushf
testw $0xdc6f, %ax  # (40)
pushf
movw %ax, (72)
testw $0x3046, %dx  # (41)
pushf
movw %dx, (74)
testw $0x96e4, (20) # (42)
pushf

# Byte TEST
testb %al, %ah      # (43)
pushf
movb %ah, (76)
testb (15), %cl     # (44)
pushf
movb %cl, (77)
testb %ch, (16)     # (45)
pushf
testb $0xc0, %al    # (46)
pushf
movb %al, (78)
testb $0xe0, %bl    # (47)
pushf
movb %bl, (79)
testb $0xbb, (17)   # (48)
pushf

movw $0xbfa5, %dx
movw $0x4be6, (22)
movw $0xe9d2, (24)

movw $0x12b1, %ax
pushw %ax
popf

# Word NOT
notw %dx            # (49)
pushf
movw %dx, (80)
notw (22)           # (50)
pushf

# Byte NOT
notb %dl            # (51)
pushf
movb %dl, (82)
notb (24)           # (52)
pushf

hlt


.org 65520
jmp start
.org 65535
.byte 0xff
