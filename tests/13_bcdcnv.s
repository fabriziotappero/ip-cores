.code16
start:

movw $1, %bx
movw $0, %cx
movw $144, %sp

# aaa
movw $0x000a, %ax
aaa                # (1) adjusted
movw %ax, (0)
pushf

movw $0xfff9, %ax
aaa                # (2) adjusted by AF
movw %ax, (2)
pushf

push %bx
popf
movw $0xfff9, %ax
aaa                # (3) not adjusted
movw %ax, (4)
pushf

movw $0x5d50, %ax
aaa                # (4) aaa random
movw %ax, (6)
pushf

movw $0x4726, %ax
aaa                # (5) aaa random
movw %ax, (8)
pushf

# aas
movw $0x000a, %ax
aas                # (6) adjusted
movw %ax, (10)
pushf

movw $0xfff9, %ax
aas                # (7) adjusted by AF
movw %ax, (12)
pushf

push %bx
popf
movw $0xfff9, %ax
aas                # (8) not adjusted
movw %ax, (14)
pushf

movw $0xdcc0, %ax
aas                # (9) aas random
movw %ax, (16)
pushf

movw $0x5ffb, %ax
aas                # (10) aas random
movw %ax, (18)
pushf

# daa
movw $0x00ac, %ax
daa                # (11) daa, adj 1st & 3rd cond
movw %ax, (20)
pushf

movw $0xfff9, %ax
daa
movw %ax, (22)     # (12) daa, adj 2nd & 3rd cond
pushf

push %bx
popf               # carry set
movw $0xfff8, %ax
daa                # (13) daa, adj 4th cond
movw %ax, (24)
pushf

push %cx
popf               # zero flags
movw $0xff8b, %ax
daa                # (14) daa, adj 1st cond
movw %ax, (26)
pushf

push %cx
popf
movw $0x0082, %ax
daa                # (15) daa, not adjusted
movw %ax, (28)
pushf

movw $cd3c, %ax
daa                # (16) daa, random
movw %ax, (30)
pushf

movw $0x3f00, %ax
daa                # (17) daa, random
movw %ax, (32)
pushf

# das
movw $0x00ac, %ax
das                # (18) das, adj 1st & 3rd cond
movw %ax, (34)
pushf

movw $0xfff9, %ax
das
movw %ax, (36)     # (19) das, adj 2nd & 3rd cond
pushf

push %bx
popf               # carry set
movw $0xfff8, %ax
das                # (20) das, adj 4th cond
movw %ax, (38)
pushf

push %cx
popf               # zero flags
movw $0xff8b, %ax
das                # (21) das, adj 1st cond
movw %ax, (40)
pushf

push %cx
popf
movw $0x0082, %ax
das                # (22) das, not adjusted
movw %ax, (42)
pushf

movw $0x059a, %ax
das                # (23) das, random
movw %ax, (44)
pushf

movw $0x54f6, %ax
das                # (24) das, random
movw %ax, (46)
pushf

# cbw
movw $0xff7f, %ax
cbw                # (25) cbw, positive
movw %ax, (48)
movw %dx, (50)
pushf

movw $0x0080, %ax
cbw                # (26) cbw, negative
movw %ax, (52)
movw %dx, (54)
pushf

movw $0xf1ed, %ax
cbw                # (27) cbw, random
movw %ax, (56)
movw %dx, (58)
pushf

# cwd
movw $0x8000, %ax
cwd                # (28) cwd, negative
movw %ax, (60)
movw %dx, (62)
pushf

movw $0x7fff, %ax
cwd                # (29) cwd, positive
movw %ax, (64)
movw %dx, (66)
pushf

movw $0x43f1, %ax
cwd                # (30) cwd, random
movw %ax, (68)
movw %dx, (70)
pushf

hlt

.org 65520
jmp start

.org 65535
.byte 0xff
