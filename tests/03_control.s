.code16
start:
movw $0x1000, %ax
movw %ax, %ss
movw $0x1000, %sp

movw $0xfeff, %cx
push %cx
popf

clc                # (1)
cld                # (2)
cli                # (3)

nop                # (6)

pushf
pop   %ax          # %ax = 0x08d6

movw $0x1, %dx
push %dx
popf

cmc                # (4)
stc                # (7)
std                # (8)
sti                # (9)

pushf
pop   %bx          # %bx = 0x0603

movw $0x0, %cx
movw %cx, %ds
movw %ax, (0)
movw %bx, (2)

hlt                # (5)

.org 65520
jmp start

.org 65535
.byte 0xff
