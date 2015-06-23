.code16
start:
movw $0xf000, %bx
movw %bx, %ds
movw $0x1290, %ax

movw $0x5, %cx
again:
push %cx
loop again              # (6)

call *%ax               # (2)
ret                     # (9)

.org 0x1290
ag2:
movw $0xffff, %cx
loope ag2               # (7) branch not taken
movw $64, %dx
push %dx
popf
loope cont              # (7) branch taken
hlt
cont:
lcall $0xe342, $0xebe0  # (4)
jcxz cont               # (13) branch not taken
movw $0, %cx
jcxz exit               # (13) branch taken
hlt
exit:
ret $10                 # (10)

.org 0x2000
call *(0x3000)          # (3)
movw $0, %dx
push %dx
popf
hang:
movw $1, %cx
loopnz hang             # (8) branch not taken
loopne cont1            # (8) branch taken
hlt
cont1:
lret                    # (11)
.org 0x3000
.word 0xfde0
.word 0x4000
.word 0xf000

.org 0x3200
movw $0x2ff0, %bx
movw $0x10, %si
push %dx
lcall *2(%bx,%si)       # (5)
ret

.org 0x4000
lret $2                 # (12)

.org 65520
movw $0x1000, %sp
movw %sp, %ss
call start              # (1)
movw %cx, %ds
movw %bx, (0)
hlt
.org 65535
.byte 0xff
