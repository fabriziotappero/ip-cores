.code16
start:

movw $160, %sp

# add word tests
movw $0xffff, %ax
movw $0x0001, %bx
addw %ax, %bx        # (1) addw reg16, reg16
movw %ax, (0)
movw %bx, (2)
pushf

movw $0xffff, %dx
movw $0xffff, (4)
addw %dx, (4)        # (2) addw reg16, mem16
movw %dx, (6)
pushf

movw $0x0001, %cx
movw $0x0002, (8)
addw (8), %cx        # (3) addw mem16, reg16
movw %cx, (10)
pushf

movw $0x0001, %ax
addw $0x7fff, %ax    # (4) addw imm16, ac16
movw %ax, (12)
pushf

movw $0x8000, %bp
.byte 0x83,0xc5,0xff # (5) addw imm8, reg16
movw %bp, (14)
pushf

movw $0xc783, %si
addw $0xeb2a, %si    # (6) addw imm16, reg16
movw %si, (16)
pushf

movw $0x8960, (18)
addw $0x0a95, (18)   # (7) addw imm16, mem16
pushf

movw $0xf1e1, (20)
.word 0x0683, 0x0014 # (8) addw imm8, mem16
.byte 0x64
pushf

# add byte tests
movb $0x01, (22)
addb $0xff, (22)     # (9) addb imm8, mem8
pushf

movb $0xff, %dh
addb $0xff, %dh      # (10) addb imm8, reg8
movw %dx, (23)
pushf

movb $0x01, %al
addb $0x02, %al      # (11) addb imm8, acum8
movw %ax, (25)
pushf

movb $0x7f, (27)
movb $0x01, %ch
addb (27), %ch       # (12) addb mem8, reg8
movw %cx, (28)
pushf

movb $0x80, %bl
movb $0xff, (30)
addb %bl, (30)       # (13) addb reg8, mem8
movw %bx, (31)
pushf

movb $0xa6, %al
movb $0x86, %ah
addb %al, %ah        # (14) addb reg8, reg8
movw %ax, (33)
pushf

# adc word tests
movw $0xffff, %ax
movw $0x0001, %bx
adcw %ax, %bx        # (15) adcw reg16, reg16
movw %ax, (35)
movw %bx, (37)
pushf

movw $0xffff, %dx
movw $0xffff, (39)
adcw %dx, (39)       # (16) adcw reg16, mem16
movw %dx, (41)
pushf

movw $0x0001, %cx
movw $0x0002, (43)
adcw (43), %cx       # (17) adcw mem16, reg16
movw %cx, (45)
pushf

movw $0x0001, %ax
adcw $0x7fff, %ax    # (18) adcw imm16, ac16
movw %ax, (47)
pushf

movw $0x8000, %bp
.byte 0x83,0xd5,0xff # (19) adcw imm8, reg16
movw %bp, (49)
pushf

movw $0x77d3, %si
adcw $0x8425, %si    # (20) adcw imm16, reg16
movw %si, (51)
pushf

movw $0xeba0, (53)
adcw $0xd3c1, (53)   # (21) adcw imm16, mem16
pushf

movw $0x7f50, (55)
.word 0x1683, 0x0037
.byte 0xf5
pushf

# adc byte tests
movb $0x01, (57)
adcb $0xff, (57)
pushf

movb $0xff, %dh
adcb $0xff, %dh
movw %dx, (58)
pushf

movb $0x01, %al
adcb $0x02, %al
movw %ax, (60)
pushf

movb $0x7f, (62)
movb $0x01, %ch
adcb (62), %ch
movw %cx, (63)
pushf

movb $0x80, %bl
movb $0xff, (65)
adcb %bl, (65)
movw %bx, (66)
pushf

movb $0xb9, %al
movb $0xd3, %ah
adcb %al, %ah
movw %ax, (68)
pushf

# inc word tests
movw $0xffff, %di
incw %di
movw %di, (70)
pushf

movw $0x7fff, %bp
.byte 0xff, 0xc5
movw %bp, (72)
pushf

movw $0x7412, (74)
incw (74)
pushf

# inc byte tests
movb $0x7f, %dl
incb %dl
movw %dx, (76)
pushf

movb $0xff, (77)
incb (77)
pushf

movb $0xb5, (78)
incb (78)
pushf
hlt

.org 65520
jmp start
.org 65535
.byte 0xff
