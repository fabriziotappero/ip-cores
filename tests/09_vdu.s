.code16
start:
movw $0xb800, %dx
movw %dx, %ds
movw $0x20, %cx
movw $11, %bx

b:
movw $0x4d03, (%bx)
addw $2, %bx
loop b

movb $0x36, %al
outb %al, $0xb7

movw $0x0, %dx
movw %dx, %ds

movw $0x1234, (2)
movb $0x56, (5)
movb $0x26, (6)
movw $0x4567, (9)

movw (5), %ax
movw %ax, (0)

hlt

.org 65520
jmp start

.org 65535
.byte 0xff
