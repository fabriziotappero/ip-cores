.code16
start:
movb $0xed, %ah
sahf                    # (1)
lahf                    # (2) Now %ah must have 0xc7
movb %ah, (0)
movb %ah, %al
outb %al, $0xb7         # (19)
movw $0xb7, %ax
movw %ax, %dx
movb $0xa5, %ah
inb  %dx, %al           # (24)
movw %ax, (2)
sahf
lahf                # Now %ax must have 0x87c7
movw %ax, (32)

outw %ax, %dx           # (22)
movw $0xf752, %ax
movw %ax, %bx
inw  %dx, %ax           # (26)
xchg %bx, %ax       # (16)
movw %ax, %ds
lds  781(%bx), %si  # (3)  %ds=0x5678 and %si=0x1234
movw $0, %ax
movw %ds, %bx
movw %ax, %ds
movw %bx, (4)
movw %si, (6)
movw %bx, %ds

movw $-1, %bx

movw $0x1000, %ax
outw %ax, $0xb7         # (21)

movw $0x5798, %ax
movw %ax, %ss
movw $9, %sp
movw $0xabcd, %cx
push %cx                # (10)
movw $0x8cf1, %cx
movw %cx, %es
push %es                # (11)
popf                    # (9)
les  -46(%bx,%si), %di  # (5) %di=0x8cf1, %es=%0xabcd
lea  -452(%bp,%di), %si # (4) %si=0x8b2d
pushf                   # (13)
movw $0, %ax
movw %ax, %ds
movw %di, (8)
movw %es, %ax
movw %ax, (10)
movw %si, (12)
inw  $0xb7, %ax         # (25)
movw %ax, %ds
pop  1(%si)             # (8)
xchg 2(%bx,%si), %di    # (15) %di=0x0cd3
push 2(%bx,%si)         # (12)
pop  %es                # (7)  %es=0x8cf1
movw %es, %dx


movw %ds, %ax
movw $0, %cx
movw %cx, %ds
movw %di, (14)
movw %dx, (16)
movw %ax, %ds
pop  %dx                # (6)
push %dx
.byte 0x8f,0xc1         # (6) pop %cx (non-standard)
xchg %bx, %cx           # (14) %bx=0xabcd, %cx=0xffff

movw %ds, %ax
movw $0, %dx
movw %dx, %ds
movw %bx, (18)
movw %cx, (20)
movw %ax, %ds
movw %es, (%bx,%di)
movw $0xb800, %bx
movw $0xa0a1, %ax
xlat                    # (18) %al=0x8c
xchg %al, %ah           # (17)
xlat                    # %ax=0x8cf1
movw $0, %dx
movw %dx, %ds
movw %ax, (22)
movw $0xb7, %dx
outb %al, %dx           # (20)
movb $0xff, %al
inb  $0xb7, %al         # (23) %ax=0x8cf1
movw %ax, (24)
hlt

.org 65520
jmp start

.org 65524
.word 0x1234
.word 0x5678

.org 65535
.byte 0xff
