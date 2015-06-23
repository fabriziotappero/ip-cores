@00000000	 MIPS (ID): j 16
@00000004	 MIPS (ID): nop
@00000008	 MIPS (ID): j 64
@0000000c	 MIPS (ID): nop
@00000010	 MIPS (ID): lui $29, 0
@00000014	 MIPS (ID): addiu $29, $29, 16368
@00000018	 MIPS (ID): addiu $8, $0, 0
@0000001c	 MIPS (ID): lui $9, 0
@00000020	 MIPS (ID): addiu $9, $9, 16384
@00000024	 MIPS (ID): MFC0 
@00000028	 MIPS (ID): addi $26, $26, 3
@0000002c	 MIPS (ID): MTC0 
@00000030	 MIPS (ID): jal 716
@00000034	 MIPS (ID): nop
@00000038	 MIPS (ID): j 124
@0000003c	 MIPS (ID): nop
@00000040	 MIPS (ID): nop
@00000044	 MIPS (ID): MFC0 
@00000048	 MIPS (ID): MFC0 
@0000004c	 MIPS (ID): srl $26, $26, 2
@00000050	 MIPS (ID): andi $26, $26, 0x1f
@00000054	 MIPS (ID): beq $0, $26, 6
@00000058	 MIPS (ID): nop
@0000005c	 MIPS (ID): add $11, $0, $0
@00000060	 MIPS (ID): addiu $11, $27, 4
@00000064	 MIPS (ID): MTC0 
@00000068	 MIPS (ID): ERET 
@0000006c	 MIPS (ID): nop
@00000070	 MIPS (ID): nop
@00000074	 MIPS (ID): ERET 
@00000078	 MIPS (ID): nop
@0000007c	 MIPS (ID): j 124
@00000080	 MIPS (ID): addiu $29, $29, -40
@00000084	 MIPS (ID): sw $31, 36($29) (36)
@00000088	 MIPS (ID): sw $30, 32($29) (32)
@0000008c	 MIPS (ID): or $30, $29, $0
@00000090	 MIPS (ID): sw $4, 40($30) (40)
@00000094	 MIPS (ID): sw $5, 44($30) (44)
@00000098	 MIPS (ID): sw $6, 48($30) (48)
@0000009c	 MIPS (ID): lw $2, 44($30) (44)
@000000a0	 MIPS (ID): nop
@000000a4	 MIPS (ID): sw $2, 16($30) (16)
@000000a8	 MIPS (ID): lw $2, 48($30) (48)
@000000ac	 MIPS (ID): nop
@000000b0	 MIPS (ID): sw $2, 20($30) (20)
@000000b4	 MIPS (ID): lw $3, 44($30) (44)
@000000b8	 MIPS (ID): lw $2, 48($30) (48)
@000000bc	 MIPS (ID): nop
@000000c0	 MIPS (ID): addu $3, $3, $2
@000000c4	 MIPS (ID): sra $2, $3, 31
@000000c8	 MIPS (ID): srl $2, $2, 31
@000000cc	 MIPS (ID): addu $2, $3, $2
@000000d0	 MIPS (ID): sra $2, $2, 1
@000000d4	 MIPS (ID): sll $3, $2, 2
@000000d8	 MIPS (ID): lw $2, 40($30) (40)
@000000dc	 MIPS (ID): nop
@000000e0	 MIPS (ID): addu $2, $3, $2
@000000e4	 MIPS (ID): lw $2, 0($2) (0)
@000000e8	 MIPS (ID): nop
@000000ec	 MIPS (ID): sw $2, 28($30) (28)
@000000f0	 MIPS (ID): lw $2, 16($30) (16)
@000000f4	 MIPS (ID): nop
@000000f8	 MIPS (ID): sll $3, $2, 2
@000000fc	 MIPS (ID): lw $2, 40($30) (40)
@00000100	 MIPS (ID): nop
@00000104	 MIPS (ID): addu $2, $3, $2
@00000108	 MIPS (ID): lw $3, 0($2) (0)
@0000010c	 MIPS (ID): lw $2, 28($30) (28)
@00000110	 MIPS (ID): nop
@00000114	 MIPS (ID): slt $2, $3, $2
@00000118	 MIPS (ID): bne $0, $2, 3
@0000011c	 MIPS (ID): nop
@00000120	 MIPS (ID): beq $0, $0, 6
@00000124	 MIPS (ID): nop
@00000128	 MIPS (ID): lw $2, 16($30) (16)
@0000012c	 MIPS (ID): nop
@00000130	 MIPS (ID): addiu $2, $2, 1
@00000134	 MIPS (ID): beq $0, $0, -18
@00000138	 MIPS (ID): sw $2, 16($30) (16)
@0000013c	 MIPS (ID): nop
@00000140	 MIPS (ID): lw $2, 20($30) (20)
@00000144	 MIPS (ID): nop
@00000148	 MIPS (ID): sll $3, $2, 2
@0000014c	 MIPS (ID): lw $2, 40($30) (40)
@00000150	 MIPS (ID): nop
@00000154	 MIPS (ID): addu $2, $3, $2
@00000158	 MIPS (ID): lw $3, 0($2) (0)
@0000015c	 MIPS (ID): lw $2, 28($30) (28)
@00000160	 MIPS (ID): nop
@00000164	 MIPS (ID): slt $2, $2, $3
@00000168	 MIPS (ID): bne $0, $2, 3
@0000016c	 MIPS (ID): nop
@00000170	 MIPS (ID): beq $0, $0, 6
@00000174	 MIPS (ID): nop
@00000178	 MIPS (ID): lw $2, 20($30) (20)
@0000017c	 MIPS (ID): nop
@00000180	 MIPS (ID): addiu $2, $2, -1
@00000184	 MIPS (ID): beq $0, $0, -18
@00000188	 MIPS (ID): sw $2, 20($30) (20)
@0000018c	 MIPS (ID): lw $2, 16($30) (16)
@00000190	 MIPS (ID): lw $3, 20($30) (20)
@00000194	 MIPS (ID): nop
@00000198	 MIPS (ID): slt $2, $3, $2
@0000019c	 MIPS (ID): bne $0, $2, 42
@000001a0	 MIPS (ID): nop
@000001a4	 MIPS (ID): lw $2, 16($30) (16)
@000001a8	 MIPS (ID): nop
@000001ac	 MIPS (ID): sll $3, $2, 2
@000001b0	 MIPS (ID): lw $2, 40($30) (40)
@000001b4	 MIPS (ID): nop
@000001b8	 MIPS (ID): addu $2, $3, $2
@000001bc	 MIPS (ID): lw $2, 0($2) (0)
@000001c0	 MIPS (ID): nop
@000001c4	 MIPS (ID): sw $2, 24($30) (24)
@000001c8	 MIPS (ID): lw $2, 16($30) (16)
@000001cc	 MIPS (ID): nop
@000001d0	 MIPS (ID): sll $3, $2, 2
@000001d4	 MIPS (ID): lw $2, 40($30) (40)
@000001d8	 MIPS (ID): nop
@000001dc	 MIPS (ID): addu $4, $3, $2
@000001e0	 MIPS (ID): lw $2, 20($30) (20)
@000001e4	 MIPS (ID): nop
@000001e8	 MIPS (ID): sll $3, $2, 2
@000001ec	 MIPS (ID): lw $2, 40($30) (40)
@000001f0	 MIPS (ID): nop
@000001f4	 MIPS (ID): addu $2, $3, $2
@000001f8	 MIPS (ID): lw $2, 0($2) (0)
@000001fc	 MIPS (ID): nop
@00000200	 MIPS (ID): sw $2, 0($4) (0)
@00000204	 MIPS (ID): lw $2, 20($30) (20)
@00000208	 MIPS (ID): nop
@0000020c	 MIPS (ID): sll $3, $2, 2
@00000210	 MIPS (ID): lw $2, 40($30) (40)
@00000214	 MIPS (ID): nop
@00000218	 MIPS (ID): addu $3, $3, $2
@0000021c	 MIPS (ID): lw $2, 24($30) (24)
@00000220	 MIPS (ID): nop
@00000224	 MIPS (ID): sw $2, 0($3) (0)
@00000228	 MIPS (ID): lw $2, 16($30) (16)
@0000022c	 MIPS (ID): nop
@00000230	 MIPS (ID): addiu $2, $2, 1
@00000234	 MIPS (ID): sw $2, 16($30) (16)
@00000238	 MIPS (ID): lw $2, 20($30) (20)
@0000023c	 MIPS (ID): nop
@00000240	 MIPS (ID): addiu $2, $2, -1
@00000244	 MIPS (ID): sw $2, 20($30) (20)
@00000248	 MIPS (ID): lw $2, 16($30) (16)
@0000024c	 MIPS (ID): lw $3, 20($30) (20)
@00000250	 MIPS (ID): nop
@00000254	 MIPS (ID): slt $2, $3, $2
@00000258	 MIPS (ID): beq $0, $2, -91
@0000025c	 MIPS (ID): nop
@00000260	 MIPS (ID): lw $2, 44($30) (44)
@00000264	 MIPS (ID): lw $3, 20($30) (20)
@00000268	 MIPS (ID): nop
@0000026c	 MIPS (ID): slt $2, $2, $3
@00000270	 MIPS (ID): beq $0, $2, 6
@00000274	 MIPS (ID): nop
@00000278	 MIPS (ID): lw $4, 40($30) (40)
@0000027c	 MIPS (ID): lw $5, 44($30) (44)
@00000280	 MIPS (ID): lw $6, 20($30) (20)
@00000284	 MIPS (ID): jal 128
@00000288	 MIPS (ID): nop
@0000028c	 MIPS (ID): lw $2, 16($30) (16)
@00000290	 MIPS (ID): lw $3, 48($30) (48)
@00000294	 MIPS (ID): nop
@00000298	 MIPS (ID): slt $2, $2, $3
@0000029c	 MIPS (ID): beq $0, $2, 6
@000002a0	 MIPS (ID): nop
@000002a4	 MIPS (ID): lw $4, 40($30) (40)
@000002a8	 MIPS (ID): lw $5, 16($30) (16)
@000002ac	 MIPS (ID): lw $6, 48($30) (48)
@000002b0	 MIPS (ID): jal 128
@000002b4	 MIPS (ID): nop
@000002b8	 MIPS (ID): or $29, $30, $0
@000002bc	 MIPS (ID): lw $31, 36($29) (36)
@000002c0	 MIPS (ID): lw $30, 32($29) (32)
@000002c4	 MIPS (ID): jr $31
 * UNKNOWN FUNCTION CODE FOR R-format
@000002c8	 MIPS (ID): addiu $29, $29, 40
@000002cc	 MIPS (ID): addiu $29, $29, -80
@000002d0	 MIPS (ID): sw $30, 72($29) (72)
@000002d4	 MIPS (ID): or $30, $29, $0
@000002d8	 MIPS (ID): addiu $2, $0, 23
@000002dc	 MIPS (ID): sw $2, 52($30) (52)
@000002e0	 MIPS (ID): addiu $2, $0, 24
@000002e4	 MIPS (ID): sw $2, 56($30) (56)
@000002e8	 MIPS (ID): addiu $2, $0, 13
@000002ec	 MIPS (ID): sw $2, 0($30) (0)
@000002f0	 MIPS (ID): addiu $2, $0, 34
@000002f4	 MIPS (ID): sw $2, 4($30) (4)
@000002f8	 MIPS (ID): addiu $2, $0, 86
@000002fc	 MIPS (ID): sw $2, 8($30) (8)
@00000300	 MIPS (ID): addiu $2, $0, 23
@00000304	 MIPS (ID): sw $2, 12($30) (12)
@00000308	 MIPS (ID): addiu $2, $0, 52
@0000030c	 MIPS (ID): sw $2, 16($30) (16)
@00000310	 MIPS (ID): addiu $2, $0, 43
@00000314	 MIPS (ID): sw $2, 20($30) (20)
@00000318	 MIPS (ID): addiu $2, $0, 45
@0000031c	 MIPS (ID): sw $2, 24($30) (24)
@00000320	 MIPS (ID): addiu $2, $0, 87
@00000324	 MIPS (ID): sw $2, 28($30) (28)
@00000328	 MIPS (ID): addiu $2, $0, 12
@0000032c	 MIPS (ID): sw $2, 32($30) (32)
@00000330	 MIPS (ID): addiu $2, $0, 24
@00000334	 MIPS (ID): sw $2, 36($30) (36)
@00000338	 MIPS (ID): addiu $2, $0, 35
@0000033c	 MIPS (ID): sw $2, 40($30) (40)
@00000340	 MIPS (ID): addiu $2, $0, 100
@00000344	 MIPS (ID): sw $2, 44($30) (44)
@00000348	 MIPS (ID): lw $3, 52($30) (52)
@0000034c	 MIPS (ID): lw $2, 56($30) (56)
@00000350	 MIPS (ID): nop
@00000354	 MIPS (ID): mult [Hi,Lo], $3, $2
 * UNKNOWN FUNCTION CODE FOR R-format
@00000358	 MIPS (ID): mflo $2 [Lo]
 * UNKNOWN FUNCTION CODE FOR R-format
@0000035c	 MIPS (ID): sw $2, 48($30) (48)
@00000360	 MIPS (ID): nop
@00000364	 MIPS (ID): sw $0, 60($30) (60)
@00000368	 MIPS (ID): lw $2, 60($30) (60)
@0000036c	 MIPS (ID): nop
@00000370	 MIPS (ID): slti $2, $2, 12
@00000374	 MIPS (ID): bne $0, $2, 3
@00000378	 MIPS (ID): nop
@0000037c	 MIPS (ID): beq $0, $0, 16
@00000380	 MIPS (ID): nop
@00000384	 MIPS (ID): lw $2, 60($30) (60)
@00000388	 MIPS (ID): nop
@0000038c	 MIPS (ID): sll $2, $2, 2
@00000390	 MIPS (ID): addu $4, $30, $2
@00000394	 MIPS (ID): lw $3, 52($30) (52)
@00000398	 MIPS (ID): lw $2, 60($30) (60)
@0000039c	 MIPS (ID): nop
@000003a0	 MIPS (ID): mult [Hi,Lo], $3, $2
 * UNKNOWN FUNCTION CODE FOR R-format
@000003a4	 MIPS (ID): mflo $2 [Lo]
 * UNKNOWN FUNCTION CODE FOR R-format
@000003a8	 MIPS (ID): sw $2, 0($4) (0)
@000003ac	 MIPS (ID): lw $2, 60($30) (60)
@000003b0	 MIPS (ID): nop
@000003b4	 MIPS (ID): addiu $2, $2, 1
@000003b8	 MIPS (ID): beq $0, $0, -21
@000003bc	 MIPS (ID): sw $2, 60($30) (60)
@000003c0	 MIPS (ID): addiu $2, $0, 4096
@000003c4	 MIPS (ID): sw $2, 64($30) (64)
@000003c8	 MIPS (ID): lw $3, 64($30) (64)
@000003cc	 MIPS (ID): lw $2, 0($30) (0)
@000003d0	 MIPS (ID): nop
@000003d4	 MIPS (ID): sw $2, 0($3) (0)
@000003d8	 MIPS (ID): addiu $2, $0, 4100
@000003dc	 MIPS (ID): sw $2, 64($30) (64)
@000003e0	 MIPS (ID): lw $3, 64($30) (64)
@000003e4	 MIPS (ID): lw $2, 4($30) (4)
@000003e8	 MIPS (ID): nop
@000003ec	 MIPS (ID): sw $2, 0($3) (0)
@000003f0	 MIPS (ID): addiu $2, $0, 4104
@000003f4	 MIPS (ID): sw $2, 64($30) (64)
@000003f8	 MIPS (ID): lw $3, 64($30) (64)
@000003fc	 MIPS (ID): lw $2, 8($30) (8)
@00000400	 MIPS (ID): nop
@00000404	 MIPS (ID): sw $2, 0($3) (0)
@00000408	 MIPS (ID): addiu $2, $0, 4108
@0000040c	 MIPS (ID): sw $2, 64($30) (64)
@00000410	 MIPS (ID): lw $3, 64($30) (64)
@00000414	 MIPS (ID): lw $2, 12($30) (12)
@00000418	 MIPS (ID): nop
@0000041c	 MIPS (ID): sw $2, 0($3) (0)
@00000420	 MIPS (ID): addiu $2, $0, 4112
@00000424	 MIPS (ID): sw $2, 64($30) (64)
@00000428	 MIPS (ID): lw $3, 64($30) (64)
@0000042c	 MIPS (ID): lw $2, 16($30) (16)
@00000430	 MIPS (ID): nop
@00000434	 MIPS (ID): sw $2, 0($3) (0)
@00000438	 MIPS (ID): addiu $2, $0, 4116
@0000043c	 MIPS (ID): sw $2, 64($30) (64)
@00000440	 MIPS (ID): lw $3, 64($30) (64)
@00000444	 MIPS (ID): lw $2, 20($30) (20)
@00000448	 MIPS (ID): nop
@0000044c	 MIPS (ID): sw $2, 0($3) (0)
@00000450	 MIPS (ID): addiu $2, $0, 4120
@00000454	 MIPS (ID): sw $2, 64($30) (64)
@00000458	 MIPS (ID): lw $3, 64($30) (64)
@0000045c	 MIPS (ID): lw $2, 24($30) (24)
@00000460	 MIPS (ID): nop
@00000464	 MIPS (ID): sw $2, 0($3) (0)
@00000468	 MIPS (ID): addiu $2, $0, 4124
@0000046c	 MIPS (ID): sw $2, 64($30) (64)
@00000470	 MIPS (ID): lw $3, 64($30) (64)
@00000474	 MIPS (ID): lw $2, 28($30) (28)
@00000478	 MIPS (ID): nop
@0000047c	 MIPS (ID): sw $2, 0($3) (0)
@00000480	 MIPS (ID): addiu $2, $0, 4128
@00000484	 MIPS (ID): sw $2, 64($30) (64)
@00000488	 MIPS (ID): lw $3, 64($30) (64)
@0000048c	 MIPS (ID): lw $2, 32($30) (32)
@00000490	 MIPS (ID): nop
@00000494	 MIPS (ID): sw $2, 0($3) (0)
@00000498	 MIPS (ID): addiu $2, $0, 4132
@0000049c	 MIPS (ID): sw $2, 64($30) (64)
@000004a0	 MIPS (ID): lw $3, 64($30) (64)
@000004a4	 MIPS (ID): lw $2, 36($30) (36)
@000004a8	 MIPS (ID): nop
@000004ac	 MIPS (ID): sw $2, 0($3) (0)
@000004b0	 MIPS (ID): addiu $2, $0, 4136
@000004b4	 MIPS (ID): sw $2, 64($30) (64)
@000004b8	 MIPS (ID): lw $3, 64($30) (64)
@000004bc	 MIPS (ID): lw $2, 40($30) (40)
@000004c0	 MIPS (ID): nop
@000004c4	 MIPS (ID): sw $2, 0($3) (0)
@000004c8	 MIPS (ID): addiu $2, $0, 4140
@000004cc	 MIPS (ID): sw $2, 64($30) (64)
@000004d0	 MIPS (ID): lw $3, 64($30) (64)
@000004d4	 MIPS (ID): lw $2, 44($30) (44)
@000004d8	 MIPS (ID): nop
@000004dc	 MIPS (ID): sw $2, 0($3) (0)
@000004e0	 MIPS (ID): addiu $2, $0, 4144
@000004e4	 MIPS (ID): sw $2, 64($30) (64)
@000004e8	 MIPS (ID): lw $3, 64($30) (64)
@000004ec	 MIPS (ID): lw $2, 48($30) (48)
@000004f0	 MIPS (ID): nop
@000004f4	 MIPS (ID): sw $2, 0($3) (0)
@000004f8	 MIPS (ID): lui $2, 32767
@000004fc	 MIPS (ID): ori $2, $2, 0xfffffffc
@00000500	 MIPS (ID): sw $2, 64($30) (64)
@00000504	 MIPS (ID): lw $2, 64($30) (64)
@00000508	 MIPS (ID): nop
@0000050c	 MIPS (ID): sw $0, 0($2) (0)
@00000510	 MIPS (ID): or $2, $0, $0
@00000514	 MIPS (ID): or $29, $30, $0
@00000518	 MIPS (ID): lw $30, 72($29) (72)
@0000051c	 MIPS (ID): jr $31
 * UNKNOWN FUNCTION CODE FOR R-format
@00000520	 MIPS (ID): addiu $29, $29, 80
@00000524	 MIPS (ID): nop
@00000528	 MIPS (ID): nop
@0000052c	 MIPS (ID): nop
@00000530	 MIPS (ID): sw $0, 2816($0) (2816)
@00000534	 MIPS (ID): nop
@00000538	 MIPS (ID): nop
@0000053c	 MIPS (ID): nop
@00000540	 MIPS (ID): nop
@00000544	 MIPS (ID): nop
