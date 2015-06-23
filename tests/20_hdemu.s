.code16
start:
# First sector
movw $0x100, %cx
movw $0xe000, %dx
movw $0x1000, %ax
movw $0x0, %bx
movw %ax, %ds

a:
inw  %dx, %ax
movw %ax, (%bx)
addw $2, %dx
addw $2, %bx
loop a

movw $2844, %ax
movw $0xe000, %dx
outw %ax, %dx

# Fifth sector
movw $0x100, %cx
movw $0xe000, %dx
movw $0x2000, %ax
movw $0x0, %bx
movw %ax, %ds

b:
inw  %dx, %ax
movw %ax, (%bx)
addw $2, %dx
addw $2, %bx
loop b



hlt




.org 65520
jmp start

.org 65535
.byte 0xff
