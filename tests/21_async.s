.code16
start:
movw $0x1000, (12)
movw $0xf000, (14)

movw $0x200, %ax
push %ax
popf

movw $0xffff, %cx
#repz lodsb
a: jmp a

hlt

.org 0x1000
movb $0x41, (0)
iret

.org 65520
jmp start

.org 65535
.byte 0xff
