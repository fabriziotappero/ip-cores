.code16
start:

# Trivial cases. With %cx 0, nothing is executed
rep movsb
repz movsb
repnz movsb
rep cmpsb
repz cmpsb
repnz cmpsb
rep scasb
repz scasb
repnz scasb
rep lodsb
repz lodsb
repnz lodsb
rep stosb
repz stosb
repnz stosb


movw $0x40, %bx
push %bx
popf

# Now we have the zero flag set, nothing is executed because of %cx

rep movsb
repnz movsb
repz cmpsb
repnz cmpsb
repz scasb
repnz scasb
rep lodsb
repnz lodsb
rep stosb
repnz stosb

movw %di, %ax
movb $0x10, %ah
jmp *%ax            # jump to 0xf1000
hlt 

.org 0x102
jmp rep_stos_z

.org 0x607
jmp rep_lods_nz

.org 0x809
jmp rep_movs_nz

.org 0x0ffc
jmp cont_n5
.org 0x0ffe
jmp cont_n10
# Prefixes do not affect normal instructions
.org 0x1000
movw $0, %cx
.byte 0xf3 
push %cx
jmp *%sp

cont_n10:
movw $0x110a, %cx
.byte 0xf3 
push %cx
jmp *%sp

cont_n5:
jmp *%cx

.org 0x110a
movw $0x5, %cx

movw $0, %dx
push %dx
popf
.byte 0xf2
pop  %cx

movw %cx, %ax
movb $0x20, %ah
jmp *%ax            # jump to 0xf200a

.org 0x122c
jmp repz_cmps_nz

.org 0x122f
jmp repz_scas

# rep movs ZF=1
.org 0x200a
push %bx
popf
movw $2, %cx
movw $0x3000, %si
movw $0xf000, %ax
movw %ax, %ds
movw $0x1000, %ax
movw %ax, %es
movw $0x0000, %di

rep movsb

movw %ax, %ds
movw (0x0000), %ax
movw %di, %bp
movw %ax, (%bp,%si)
jcxz comp_disi
hlt
comp_disi:
jmp *(0x3004)

.org 0x3000
.byte 0x09,0x08,0x07,0x06,0x5,0x4,0x3,0x2,0x1,0xa,0xb,0xc,0xd


# rep movs ZF=0
rep_movs_nz:
movw $0xf000, %ax
movw %ax, %ds
movw $0x1, %cx
movw $0, %ax
pushw %ax
popf

rep movsw

movw $0x1000, %ax
movw %ax, %ds
movw (0x0002), %ax
movw %di, %bp
movw %ax, (%bp,%si)
jcxz movs_nz
hlt
movs_nz:
jmp *(0x3008)

# rep lods ZF=0
rep_lods_nz:
movw $0xf000, %ax
movw %ax, %ds
movw $0x3, %cx
rep lodsb

jmp *%ax
hlt
rep_lods_z:
# rep lods ZF=1
movw $0x40, %bx
push %bx
popf
movw $0xf000, %ax
movw %ax, %ds
movw $0x1, %cx
rep lodsw
jmp *%ax

# rep stos ZF=1
rep_stos_z:
movw $0x2, %cx
movw $0x4000, %ax
rep stosw
movw $0x1000, %ax
movw %ax, %ds
jmp *(0x0006)
hlt

.org 0x4000
# rep stos ZF=0
movw $0x0, %bx
push %bx
popf
movw $0x4, %cx
rep stosw
jcxz repz_cmps_z
hlt

# repz cmps ZF=1, but ZF=0 before %cx=0
repz_cmps_z:
movw $0x40, %bx
push %bx
popf
movw $0x1234, %cx
movw $0x3000, %si
movw $0, %di
movw $0xf000, %ax
movw %ax, %ds
repz cmpsb

jmp *%cx

# repz scas ZF=1, but ZF=0 before %cx=0
repz_scas:
movw $0x40, %bx
push %bx
popf
movw $0x0040, %ax
repz scasw
jmp *%cx

# repz cmps scas ZF=0, they do only one iteration
repz_cmps_nz:
movw $0x0607, %ax
movw $0x5004, %cx
repz cmpsw
repz scasw
movw $0x40, %bx
push %bx
popf
movw $0x3000, %si
movw $0x0, %di
# repnz cmps scas ZF=1, they do only one iteration
repnz cmpsw
repnz scasw
jmp *%cx
hlt

.org 0x5000
# repnz movs ZF=1 all iterations
repnz_movs:
movw $0x2, %cx
repnz movsb
jcxz repnz_lods
hlt

# repnz lods ZF=1 all iterations
repnz_lods:
movw $0x2, %cx
repnz lodsb
jcxz repnz_stos
hlt

# repnz stos ZF=1 all iterations
repnz_stos:
movw $0x2, %cx
repnz stosb
jcxz repnz_cmps
hlt

# repnz cmps ZF=0, but ZF=1 before %cx=0
repnz_cmps:
movw $0, %bx
push %bx
popf
movw $0x6023, %cx
std
movw $0x6, %di
movw $0x3006, %si
repnz cmpsw

# repnz scas ZF=0, but ZF=1 before %cx=0
movw $0x1000, %ax
movw $0, %bx
push %bx
popf
cld
repnz scasw
jmp *%cx
hlt

.org 0x601b
movw $0, %dx
movw %dx, %ds
movw $0x1234, (4)
hlt

.org 0xf003
jmp rep_lods_z

.org 65520
movw $0x1000, %sp
movw %sp, %ss
jmp start

.org 65535
.byte 0xff
