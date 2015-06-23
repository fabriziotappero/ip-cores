AltOR32 Instruction Set
=======================

### l.add rD,rA,rB

##### Description
The contents of register rA are added to the contents of register rB to form the result.  
The result is placed into register rD.  
The carry flag is set on unsigned arithmetic overflow.

##### Implementation
`rD[31:0] = rA[31:0] + rB[31:0]`  
`SR[CY]   = carry out`

##### Encoding
`opcode[31:26] == 0x38`  
`opcode[9:8]   == 0x0`  
`opcode[3:0]   == 0x0`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.addc rD,rA,rB

##### Description
The contents of register rA are added to the contents of register rB and carry SR[CY] to form the result.  
The result is placed into register rD.  
The carry flag is set on unsigned arithmetic overflow.

##### Implementation
`rD[31:0] = rA[31:0] + rB[31:0] + SR[CY]`  
`SR[CY]   = carry out`

##### Encoding
`opcode[31:26] == 0x38`  
`opcode[9:8]   == 0x0`  
`opcode[3:0]   == 0x1`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.addi rD,rA,I

##### Description
The immediate value is sign-extended and added to the contents of register rA to form the result.  
The result is placed into register rD.  
The carry flag is set on unsigned arithmetic overflow.

##### Implementation
`rD[31:0] = rA[31:0] + sign_extend(Immediate)`  
`SR[CY]   = carry out`

##### Encoding
`opcode[31:26] == 0x27`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.and rD,rA,rB

##### Description
The contents of register rA are combined with the contents of register rB in a bit-wise logical AND operation.  
The result is placed into register rD.

##### Implementation
`rD[31:0] = rA[31:0] AND rB[31:0]`

##### Encoding
`opcode[31:26] == 0x38`  
`opcode[9:8]   == 0x0`  
`opcode[3:0]   == 0x3`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.andi rD,rA,K

##### Description
The immediate value is zero-extended and combined with the contents of register rA in a bit-wise logical AND operation.  
The result is placed into register rD.

##### Implementation
`rD[31:0] = rA[31:0] AND unsigned_extend(Immediate)`

##### Encoding
`opcode[31:26] == 0x29`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.bf N

##### Description
The immediate value is shifted left two bits, sign-extended to program counter width, and then added to the address of the branch instruction.  
If the flag is set, the program branches to the calculated address.

##### Implementation
`ADDR = sign_extend(Immediate << 2) + CurrentPC`  
`PC   = ADDR if SR[F] set`

##### Encoding
`opcode[31:26] == 0x4`  
`opcode[25:0]  == N`

### l.bnf N

##### Description
The immediate value is shifted left two bits, sign-extended to program counter width, and then added to the address of the branch instruction.  
If the flag is not set, the program branches to the calculated address.

##### Implementation
`ADDR = sign_extend(Immediate << 2) + CurrentPC`  
`PC   = ADDR if SR[F] cleared`

##### Encoding
`opcode[31:26] == 0x3`  
`opcode[25:0]  == N`

### l.j N

##### Description
The immediate value is shifted left two bits, sign-extended to program counter width, and then added to the address of the jump instruction.  
The program unconditionally jumps to the calculated address.

##### Implementation
`PC = sign_extend(Immediate << 2) + CurrentPC`

##### Encoding
`opcode[31:26] == 0x0`  
`opcode[25:0]  == N`

### l.jal N

##### Description
The immediate value is shifted left two bits, sign-extended to program counter width, and then added to the address of the jump instruction.  
The program unconditionally jumps to the calculated address and the instruction address after the jump location is stored in R9 (LR).

##### Implementation
`PC = sign_extend(Immediate << 2) + CurrentPC`  
`LR = CurrentPC + 4`

##### Encoding
`opcode[31:26] == 0x1`  
`opcode[25:0]  == N`

### l.jalr rB

##### Description
The contents of register rB is the effective address of the jump.  
The program unconditionally jumps to the address held in rB and the instruction address after the jump location is stored in R9 (LR).

##### Implementation
`PC = rB`  
`LR = CurrentPC + 4`

##### Encoding
`opcode[31:26] == 0x12`  
`opcode[15:11] == rB`

### l.jr rB

##### Description
The contents of register rB is the effective address of the jump.  
The program unconditionally jumps to the address in rB.

##### Implementation
`PC = rB`

##### Encoding
`opcode[31:26] == 0x11`  
`opcode[15:11] == rB`

### l.lbs rD,I(rA)

##### Description
The offset is sign-extended and added to the contents of register rA.  
The byte in memory addressed by ADDR is loaded into the low-order eight bits of register rD. High-order bits of register rD are replaced with bit 7 of the loaded value.

##### Implementation
`ADDR     = sign_extend(Immediate) + rA[31:0]`  
`rD[7:0]  = ADDR[7:0]`  
`rD[31:8] = ADDR[7]`

##### Encoding
`opcode[31:26] == 0x24`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.lbz rD,I(rA)

##### Description
The offset is sign-extended and added to the contents of register rA.  
The byte in memory addressed by ADDR is loaded into the low-order eight bits of register rD. High-order bits of register rD are replaced with zero.

##### Implementation
`ADDR     = sign_extend(Immediate) + rA[31:0]`  
`rD[7:0]  = ADDR[7:0]`  
`rD[31:8] = 0`

##### Encoding
`opcode[31:26] == 0x23`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.lhs rD,I(rA)

##### Description
The offset is sign-extended and added to the contents of register rA.  
The half word in memory addressed by ADDR is loaded into the low-order 16 bits of register rD. High-order bits of register rD are replaced with bit 15 of the loaded value.

##### Implementation
`ADDR        = sign_extend(Immediate) + rA[31:0]`  
`rD[15:0]    = ADDR[15:0]`  
`rD[31:16]   = ADDR[15]`

##### Encoding
`opcode[31:26] == 0x26`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.lhz rD,I(rA)

##### Description
The offset is sign-extended and added to the contents of register rA.  
The half word in memory addressed by ADDR is loaded into the low-order 16 bits of register rD. High-order bits of register rD are replaced with zero.

##### Implementation
`ADDR        = sign_extend(Immediate) + rA[31:0]`  
`rD[15:0]    = ADDR[15:0]`  
`rD[31:16]   = 0`

##### Encoding
`opcode[31:26] == 0x25`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.lws rD,I(rA)

##### Description
The offset is sign-extended and added to the contents of register rA.  
The single word in memory addressed by ADDR is loaded into the low-order 32 bits of register rD. High-order bits of register rD are replaced with bit 31 of the loaded value.

##### Implementation
`ADDR		= sign_extend(Immediate) + rA[31:0]`  
`rD[31:0]	= ADDR[31:0]`  

##### Encoding
`opcode[31:26] == 0x22`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.lwz rD,I(rA)

##### Description
The offset is sign-extended and added to the contents of register rA.  
The single word in memory addressed by ADDR is loaded into the low-order 32 bits of register rD. High-order bits of register rD are replaced with zero.

##### Implementation
`ADDR		= sign_extend(Immediate) + rA[31:0]`  
`rD[31:0]	= ADDR[31:0]`

##### Encoding
`opcode[31:26] == 0x21`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.mfspr rD,rA,K

##### Description
The contents of the special register, defined by contents of rA logically ORed with immediate value, are moved into register rD.

##### Implementation
`rD[31:0] = spr(rA OR Immediate)`

##### Encoding
`opcode[31:26] == 0x2d`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.movhi rD,K

##### Description
The 16-bit immediate value is zero-extended, shifted left by 16 bits, and placed into register rD.

##### Implementation
`rD[31:0] = unsigned_extend(Immediate) << 16`

##### Encoding
`opcode[31:26] == 0x6`  
`opcode[25:21] == rD`  
`opcode[15:0]  == Immediate`

### l.mtspr rA,rB,K

##### Description
The contents of register rB are moved into the special register defined by contents of register rA logically ORed with the immediate value.

##### Implementation
`spr(rA OR Immediate) = rB[31:0]`

##### Encoding
`opcode[31:26] == 0x30`  
`opcode[25:21] == Immediate[15:11]`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`  
`opcode[10:0]  == Immediate[10:0]`

### l.nop K

##### Description
This instruction does not normally do anything other than consume a cycle. In simulation, the immediate value may be used to control various settings / print to the console.

##### Implementation
`null operation`

##### Encoding
`opcode[31:26] == 0x15`  
`opcode[15:0] == Immediate`

### l.or rD,rA,rB

##### Description
The contents of register rA are combined with the contents of register rB in a bit-wise logical OR operation.  
The result is placed into register rD.

##### Implementation
`rD[31:0] = rA[31:0] OR rB[31:0]`

##### Encoding
`opcode[31:26] == 0x38`  
`opcode[9:8]   == 0x0`  
`opcode[3:0]   == 0x4`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.ori rD,rA,K

##### Description
The immediate value is zero-extended and combined with the contents of register rA in a bit-wise logical OR operation. The result is placed into register rD.

##### Implementation
`rD[31:0] = rA[31:0] OR unsigned_extend(Immediate)`

##### Encoding
`opcode[31:26] == 0x2a`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.rfe 

##### Description
Execution of this instruction restores PC and SR (status register) registers. Intended as a return from interrupt instruction.

##### Implementation
`PC = EPC`  
`SR = ESR`

##### Encoding
`opcode[31:26] == 0x9`

### l.sb I(rA),rB

##### Description
The offset is sign-extended and added to the contents of register rA. The sum represents an effective address. The low-order 8 bits of register rB are stored to memory location addressed by ADDR.

##### Implementation
`ADDR		= sign_extend(Immediate) + rA[31:0]`  
`ADDR[7:0]  = rB[7:0]`

##### Encoding
`opcode[31:26] == 0x36`  
`opcode[25:21] == Immediate[15:11]`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`  
`opcode[10:0]  == Immediate[10:0]`

### l.sfeq rA,rB

##### Description
The contents of registers rA and rB are compared. If the contents are equal, the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] == rB[31:0]`

##### Encoding
`opcode[31:21] == 0x720`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.sfeqi rA,I

##### Description
The contents of register rA and the sign-extended immediate value are compared. If the two values are equal, the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] == sign_extend(Immediate)`

##### Encoding
`opcode[31:21] == 0x5e0`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.sfges rA,rB

##### Description
The contents of registers rA and rB are compared as signed integers. If the contents of the first register are greater than or equal to the contents of the second register, the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] >= rB[31:0]`

##### Encoding
`opcode[31:21] == 0x72b`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.sfgesi rA,I

##### Description
The contents of register rA and the sign-extended immediate value are compared as signed integers. If the contents of the first register are greater than or equal to the immediate value the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] >= sign_extend(Immediate)`

##### Encoding
`opcode[31:21] == 0x5eb`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.sfgeu rA,rB

##### Description
The contents of registers rA and rB are compared as unsigned integers. If the contents of the first register are greater than or equal to the contents of the second register, the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] >= rB[31:0]`

##### Encoding
`opcode[31:21] == 0x723`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.sfgeui rA,I

##### Description
The contents of register rA and the sign-extended immediate value are compared as unsigned integers. If the contents of the first register are greater than or equal to the immediate value the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] >= sign_extend(Immediate)`

##### Encoding
`opcode[31:21] == 0x5e3`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.sfgts rA,rB

##### Description
The contents of registers rA and rB are compared as signed integers. If the contents of the first register are greater than the contents of the second register, the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] > rB[31:0]`

##### Encoding
`opcode[31:21] == 0x72a`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.sfgtsi rA,I

##### Description
The contents of register rA and the sign-extended immediate value are compared as signed integers. If the contents of the first register are greater than the immediate value the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] > sign_extend(Immediate)`

##### Encoding
`opcode[31:21] == 0x5ea`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.sfgtu rA,rB

##### Description
The contents of registers rA and rB are compared as unsigned integers. If the contents of the first register are greater than the contents of the second register, the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] > rB[31:0]`

##### Encoding
`opcode[31:21] == 0x722`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.sfgtui rA,I

##### Description
The contents of register rA and the sign-extended immediate value are compared as unsigned integers. If the contents of the first register are greater than the immediate value the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] > sign_extend(Immediate)`

##### Encoding
`opcode[31:21] == 0x5e2`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.sfles rA,rB

##### Description
The contents of registers rA and rB are compared as signed integers. If the contents of the first register are less than or equal to the contents of the second register, the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] <= rB[31:0]`

##### Encoding
`opcode[31:21] == 0x72d`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.sflesi rA,I

##### Description
The contents of register rA and the sign-extended immediate value are compared as signed integers. If the contents of the first register are less than or equal to the immediate value the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] <= sign_extend(Immediate)`

##### Encoding
`opcode[31:21] == 0x5ed`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.sfleu rA,rB

##### Description
The contents of registers rA and rB are compared as unsigned integers. If the contents of the first register are less than or equal to the contents of the second register, the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] <= rB[31:0]`

##### Encoding
`opcode[31:21] == 0x725`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.sfleui rA,I

##### Description
The contents of register rA and the sign-extended immediate value are compared as unsigned integers. If the contents of the first register are less than or equal to the immediate value the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] <= sign_extend(Immediate)`

##### Encoding
`opcode[31:21] == 0x5e5`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.sflts rA,rB

##### Description
The contents of registers rA and rB are compared as signed integers. If the contents of the first register are less than the contents of the second register, the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] < rB[31:0]`

##### Encoding
`opcode[31:21] == 0x72c`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.sfltsi rA,I

##### Description
The contents of register rA and the sign-extended immediate value are compared as signed integers. If the contents of the first register are less than the immediate value the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] < sign_extend(Immediate)`

##### Encoding
`opcode[31:21] == 0x5ec`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.sfltu rA,rB

##### Description
The contents of registers rA and rB are compared as unsigned integers. If the contents of the first register are less than the contents of the second register, the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] < rB[31:0]`

##### Encoding
`opcode[31:21] == 0x724`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.sfltui rA,I

##### Description
The contents of register rA and the sign-extended immediate value are compared as unsigned integers. If the contents of the first register are less than the immediate value the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] < sign_extend(Immediate)`

##### Encoding
`opcode[31:21] == 0x5e4`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.sfne rA,rB

##### Description
The contents of registers rA and rB are compared. If the contents are not equal, the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] != rB[31:0]`

##### Encoding
`opcode[31:21] == 0x721`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.sfnei rA,I

##### Description
The contents of register rA and the sign-extended immediate value are compared. If the two values are not equal, the compare flag is set; otherwise the compare flag is cleared.

##### Implementation
`SR[F] = rA[31:0] != sign_extend(Immediate)`

##### Encoding
`opcode[31:21] == 0x5e1`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

### l.sh I(rA),rB

##### Description
The offset is sign-extended and added to the contents of register rA. The sum represents an effective address. The low-order 16 bits of register rB are stored to memory location addressed by ADDR.

##### Implementation
`ADDR		 = sign_extend(Immediate) + rA[31:0]`  
`ADDR[15:0]  = rB[15:0]`

##### Encoding
`opcode[31:26] == 0x37`  
`opcode[25:21] == Immediate[15:11]`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`  
`opcode[10:0]  == Immediate[10:0]`

### l.sll rD,rA,rB

##### Description
Register rB specifies the number of bit positions; the contents of register rA are shifted left, inserting zeros into the low-order bits.  
The result is written into rD.

##### Implementation
`rD[31:rB[4:0]]  = rA[31-rB[4:0]:0]`  
`rD[rB[4:0]-1:0] = 0`

##### Encoding
`opcode[31:26] == 0x38`  
`opcode[9:8]   == 0x0`  
`opcode[3:0]   == 0x8`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.slli rD,rA,L

##### Description
The immediate value specifies the number of bit positions; the contents of register rA are shifted left, inserting zeros into the low-order bits.  
The result is written into register rD.

##### Implementation
`rD[31:L]  = rA[31-L:0]`  
`rD[L-1:0] = 0`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`

##### Encoding
`opcode[31:26] == 0x2e`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[5:0]   == Immediate`

### l.sra rD,rA,rB

##### Description
Register rB specifies the number of bit positions; the contents of register rA are shifted right, sign-extending the high-order bits.  
The result is written into register rD.

##### Implementation
`rD[31-rB[4:0]:0]  = rA[31:rB[4:0]]`  
`rD[31:32-rB[4:0]] = rA[31]`

##### Encoding
`opcode[31:26] == 0x38`  
`opcode[9:8]   == 0x2`  
`opcode[3:0]   == 0x8`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.srai rD,rA,L

##### Description
The 6-bit immediate value specifies the number of bit positions; the contents of register rA are shifted right, sign-extending the high-order bits.  
The result is written into register rD.

##### Implementation
`rD[31-L:0]  = rA[31:L]`  
`rD[31:32-L] = rA[31]`

##### Encoding
`opcode[31:26] == 0x2e`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[5:0]   == Immediate`

### l.srl rD,rA,rB

##### Description
Register rB specifies the number of bit positions; the contents of register rA are shifted right, inserting zeros into the high-order bits.  
The result is written into register rD.

##### Implementation
`rD[31-rB[4:0]:0]  = rA[31:rB[4:0]]`  
`rD[31:32-rB[4:0]] = 0`

##### Encoding
`opcode[31:26] == 0x38`  
`opcode[9:8]   == 0x1`  
`opcode[3:0]   == 0x8`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.srli rD,rA,L

##### Description
The 6-bit immediate value specifies the number of bit positions; the contents of register rA are shifted right, inserting zeros into the high-order bits.  
The result is written into register rD.

##### Implementation
`rD[31-L:0]  = rA[31:L]`  
`rD[31:32-L] = 0`

##### Encoding
`opcode[31:26] == 0x2e`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[5:0]   == Immediate`

### l.sub rD,rA,rB

##### Description
The contents of register rB are subtracted from the contents of register rA to form the result. The result is placed into register rD.

##### Implementation
`rD[31:0] = rA[31:0] - rB[31:0]`

##### Encoding
`opcode[31:26] == 0x38`  
`opcode[9:8]   == 0x0`  
`opcode[3:0]   == 0x2`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.sw I(rA),rB

##### Description
The offset is sign-extended and added to the contents of register rA. The sum represents an effective address. The low-order 32 bits of register rB are stored to memory location addressed by ADDR.

##### Implementation
`ADDR		 = sign_extend(Immediate) + rA[31:0]`  
`ADDR[31:0]  = rB[31:0]`

##### Encoding
`opcode[31:26] == 0x35`  
`opcode[25:21] == Immediate[15:11]`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`  
`opcode[10:0]  == Immediate[10:0]`

### l.sys K

##### Description
Execution of the system call instruction results in the system call exception. The system calls exception is a request to the operating system to provide operating system services. The immediate value can be used to specify which system service is requested, alternatively a GPR defined by the ABI can be used to specify system service.

Because an l.sys causes an intentional exception, rather than an interruption of normal processing, the matching l.rfe returns to the next instruction.

##### Implementation
`jump_to_sys_vector(K)`

##### Encoding
`opcode[31:16] == 0x2000`  
`opcode[15:0]  == Immediate`

### l.trap K

##### Description
Trap exception is a request to the operating system or to the debug facility to execute certain debug services. The immediate value is not used by the CPU itself, but can be used by trap handling software as an argument for handling the breakpoint.

##### Implementation
`jump_to_trap_vector(K)`

##### Encoding
`opcode[31:16] == 0x2100`  
`opcode[15:0]  == Immediate`

### l.xor rD,rA,rB

##### Description
The contents of register rA are combined with the contents of register rB in a bit-wise logical XOR operation.  
The result is placed into register rD.

##### Implementation
`rD[31:0] = rA[31:0] XOR rB[31:0]`

##### Encoding
`opcode[31:26] == 0x38`  
`opcode[9:8]   == 0x0`  
`opcode[3:0]   == 0x5`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:11] == rB`

### l.xori rD,rA,I

##### Description
The immediate value is sign-extended and combined with the contents of register rA in a bit-wise logical XOR operation.  
The result is placed into register rD.

##### Implementation
`rD[31:0] = rA[31:0] XOR sign_extend(Immediate)`

##### Encoding
`opcode[31:26] == 0x2b`  
`opcode[25:21] == rD`  
`opcode[20:16] == rA`  
`opcode[15:0]  == Immediate`
