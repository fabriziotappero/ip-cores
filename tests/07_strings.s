.code16
start:
movw $0xf000, %cx
movw %cx, %ds
movw %cx, %es
movw $0x1000, %si
movw $0x2001, %di

cmpsb              # (1) flags=0x97 (SAPC)
pushf
ret

.org 0x46
cmpsb              # (1) flags=0x82 (S)
pushf
ret

.org 0x82
cmpsb              # (1) flags=0x812 (OA)
pushf
ret

.org 0x97
cmpsb              # (1) flags=0x46 (ZP)
pushf
ret

.org 0x812
cmpsw              # (2)
pushf
ret                # jump to f000:0883

.org 0x883
movb $0x10, %ah
std
lodsb              # (3)
jmp *%ax           # jump to f000:10c2

.org 0x1000
.byte 0x01,0xff,0xff,0x80
.word 0x0002
.byte 0xc2

.org 0x10c2
lodsw              # (4)
jmp *%ax

.org 0x1300
movw %ax, (%di)
movw %dx, %es
scasw              # (8)
jz stor

.org 0x1350
stor:
movb  $0x80, %al
std
stosb              # (9)
jmp  *(%di)

.org 0x2001
.byte 0x02,0xff,0x01,0x01
.word 0x8001

.org 0x8013
movw $0xd000, %ax
stosw              # (10)
jmp *2(%di)

.org 0x80c2
movw %cx, %ds
movsw              # (6)
movw %dx, %ds
jmp *2(%di)

.org 0x80ff
movw $0x2002, %di
movw %cx, %es
cld
scasb              # (7)
lahf
jmp *%ax

.org 0xc200
movw $0x1000, %dx
movw %dx, %es
movw $0xffff, %di
movsb              # (5) 
movw %dx, %ds
movb $0xc2, (%di)
jmp *(%di)

.org 0xd000
movw $0, %dx
movw %dx, %ds
movw $0x1234, (2)

hlt

.org 65520
jmp start

.org 65535
.byte 0xff
