.code16
start:
movw $0xfffc, %ax
movw $0xffff, %dx
movw $0xfffd, %cx
idiv %cx
hlt


.org 65520
jmp start
.org 65535
.byte 0xff
