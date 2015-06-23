.code16
start:
movw $0, %cx
movw $64, %bx
movw $0x1000, %sp
movw %sp, %ss
push %bx
jmp j00

# ja/jnbe
j00err:
jmp jerr
j00:
stc
ja  j00err     # (1)
clc
ja  j01

# jae/jnb/jnc
j01err:
jmp jerr
j01:
stc
jae j01err     # (2)
clc
jae j02

# jb/jnae/jc
j02err:
jmp jerr
j02:
jb  j02err     # (3)
stc
jb  j03

# jbe/jna
j03err:
jmp jerr
j03:
clc
jbe j03err     # (4)
popf
jbe j04

# je/jz
j04err:
jmp jerr
j04:
push %cx
popf
je  j04err     # (5)
push %bx
popf
je  j05

# jg/jnle
j05err:
jmp jerr
j05:
movw $0x08c0, %dx
push %dx
popf
jg  j05err     # (6)
movw $0x0880, %dx
push %dx
popf
jg  j06

# jge/jnl
j06err:
jmp jerr
j06:
movw $0x80, %dx
push %dx
popf
jge j06err     # (7)
push %cx
popf
jge j07

# jl/jnge
j07err:
jmp jerr
j07:
jl  j07err     # (8)
movw $0x0800, %dx
push %dx
popf
jl  j08

# jle/jng
j08err:
jmp jerr
j08:
push %cx
popf
jle j08err     # (9)
push %bx
popf
jle j09

# jne/jnz
j09err:
jmp jerr
j09:
jne j09err     # (10)
movw $0xcbf, %dx
push %dx
popf
jne j10

# jno
j10err:
jmp jerr
j10:
movw $0x0800, %dx
push %dx
popf
jno j10err     # (11)
movw $0x6ff, %dx
push %dx
popf
jno j11

# jnp/jpo
j11err:
jmp jerr
j11:
movw $0x4, %dx
push %dx
popf
jnp j11err     # (12)
push %cx
popf
jnp j12

# jns
j12err:
jmp jerr
j12:
movw $0xeff, %dx
push %dx
popf
jns j12err     # (13)
push %cx
popf
jns j13

# jo
j13err:
jmp jerr
j13:
jo  j13err     # (14)
movw $0x800, %dx
push %dx
popf
jo  j14

# jp/jpe
j14err:
jmp jerr
j14:
jp  j14err     # (15)
movw $0x804, %dx
push %dx
popf
jp  j15

# js
j15err:
jmp jerr
j15:
js  j15err     # (16)
movw $0x884, %dx
push %dx
popf
js  j16
jmp jerr

# All correct
j16:
movw $0x1234, (0)
hlt

.org 65520
jmp start

jerr:
hlt

.org 65535
.byte 0xff
