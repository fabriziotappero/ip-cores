.code16
start:
movw $0xb800, %dx
movw $0x0105, %ax
outw %ax, %dx
hlt


.org 65520
jmp start

.org 65535
.byte 0xff
