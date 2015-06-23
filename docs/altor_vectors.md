AltOR32 Exception Vectors
=========================

AltOR32 exception vectors apart from reset are relative to the 'ISR_VECTOR' constant.  
The reset vector is relative to 'BOOT_VECTOR'.

| Vector   | Priority | Description                    |  
|----------| ---------|--------------------------------|  
|  0x100   |    0     | Reset vector.                  |
|  0x200   |    1     | Illegal instruction vector.    |
|  0x300   |    5     | External interrupt vector.     |
|  0x400   |    3     | Syscall instruction vector.    |
|  0x500   |    -     | Unused vector.                 |
|  0x600   |    3     | Trap vector.                   |
|  0x700   |    4     | Non-maskable interrupt vector. |
|  0x800   |    2     | Bus (address) error vector.    |


### Exception Details

##### Reset (0x100)
On core reset (rst_i).

`EPC = 0`  
`ESR = 0`  
`PC  = BOOT_VECTOR + 0x100`  
`SR  = 0`  

##### Illegal Instruction (0x200)
Unsupported instruction executed.

`EPC = FAULT_PC + 4`  
`ESR = SR`  
`PC = ISR_VECTOR + 0x200`  
`SR = 0`  

##### External Interrupt (0x300)
External interrupt (intr_i) active whilst interrupts enabled (SR[IEE] == 1).

`EPC = PC (Next instruction to execute after return).`  
`ESR = SR`  
`PC = ISR_VECTOR + 0x300`  
`SR = 0`  

##### SYSCALL Exception (0x400)
On executing l.sys instruction.

`EPC = NEXT_PC (instruction after l.sys).`  
`ESR = SR`  
`PC  = ISR_VECTOR + 0x400`  
`SR  = 0`  

##### Trap Exception (0x600)
On executing l.trap instruction.

`EPC = NEXT_PC (instruction after l.trap).`  
`ESR = SR`  
`PC  = ISR_VECTOR + 0x600`  
`SR  = 0`  

##### Non-maskable Interrupt (NMI) (0x700)
Non-maskable interrupt (nmi_i) active. The non-maskable interrupt is latched internally so should not be asserted for longer than a single cycle.

`EPC = PC (Next instruction to execute after return).`  
`ESR = SR`  
`PC  = ISR_VECTOR + 0x700`  
`SR  = 0`  

##### Bus Error Exception (0x800)
Invalid PC (PC[1:0] != 0) or other erroneous memory access attempt.

`EPC = FAULT_PC + 4`  
`ESR = SR`  
`PC  = ISR_VECTOR + 0x800`  
`SR  = 0`  

