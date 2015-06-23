/*
 * Simply RISC M1 Defines
 */

// Useful constants
`define NOP          32'h00000000
`define BUBBLE       32'hFFFFFFFF
`define BOOT_ADDRESS 32'h00000000  /* could be 32'hBFC00000 */
`define STACK_TOP    32'h00000FF0  /* for 4 KBytes Internal SRAM */

// Load/Store size
`define SIZE_BYTE    3'b000
`define SIZE_HALF    3'b001
`define SIZE_WORD    3'b011
`define SIZE_LEFT    3'b100
`define SIZE_RIGHT   3'b101

// System Configuration Coprocessor (CP0) registers for TLB-less systems
`define SYSCON_BADVADDR  8
`define SYSCON_STATUS   12
`define SYSCON_CAUSE    13
`define SYSCON_EPC      14
`define SYSCON_PRID     15

// Opcodes (ordered by binary value)
`define OPCODE_SPECIAL   6'b000000  // SPECIAL instruction class
`define OPCODE_BCOND     6'b000001  // BCOND instruction class
`define OPCODE_J         6'b000010  // Jump
`define OPCODE_JAL       6'b000011  // Jump and link
`define OPCODE_BEQ       6'b000100  // Branch on equal
`define OPCODE_BNE       6'b000101  // Branch on not equal
`define OPCODE_BLEZ      6'b000110  // Branch on less than or equal to zero
`define OPCODE_BGTZ      6'b000111  // Branch on greater than zero
`define OPCODE_ADDI      6'b001000  // Add immediate
`define OPCODE_ADDIU     6'b001001  // Add immediate unsigned
`define OPCODE_SLTI      6'b001010  // Set on less than immediate
`define OPCODE_SLTIU     6'b001011  // Set on less than immediate unsigned
`define OPCODE_ANDI      6'b001100  // Bitwise AND immediate
`define OPCODE_ORI       6'b001101  // Bitwise OR immediate
`define OPCODE_XORI      6'b001110  // Bitwise XOR immediate
`define OPCODE_LUI       6'b001111  // Load upper immediate
`define OPCODE_COP0      6'b010000  // Coprocessor 0 Operation   TODO
`define OPCODE_COP1      6'b010001  // Coprocessor 1 Operation (optional)
`define OPCODE_COP2      6'b010010  // Coprocessor 2 Operation (optional)
`define OPCODE_COP3      6'b010011  // Coprocessor 3 Operation (optional)
`define OPCODE_LB        6'b100000  // Load byte
`define OPCODE_LH        6'b100001  // Load halfword
`define OPCODE_LWL       6'b100010  // Load word left            TODO
`define OPCODE_LW        6'b100011  // Load word
`define OPCODE_LBU       6'b100100  // Load byte unsigned
`define OPCODE_LHU       6'b100101  // Load halfword unsigned
`define OPCODE_LWR       6'b100110  // Load word right           TODO
`define OPCODE_SB        6'b101000  // Store byte
`define OPCODE_SH        6'b101001  // Store halfword
`define OPCODE_SWL       6'b101010  // Store word left           TODO
`define OPCODE_SW        6'b101011  // Store word
`define OPCODE_SWR       6'b101110  // Store word right          TODO
`define OPCODE_LWC1      6'b110001  // Load word to Coprocessor 1 (optional)
`define OPCODE_LWC2      6'b110010  // Load word to Coprocessor 2 (optional)
`define OPCODE_LWC3      6'b110011  // Load word to Coprocessor 3 (optional)
`define OPCODE_SWC1      6'b111001  // Store word from Coprocessor 1 (optional)
`define OPCODE_SWC2      6'b111010  // Store word from Coprocessor 2 (optional)
`define OPCODE_SWC3      6'b111011  // Store word from Coprocessor 3 (optional)

// SPECIAL instruction class functions (ordered by binary value)
`define FUNCTION_SLL	 6'b000000  // Shift left logical
`define FUNCTION_SRL	 6'b000010  // Shift right logical
`define FUNCTION_SRA	 6'b000011  // Shift right arithmetic
`define FUNCTION_SLLV    6'b000100  // Shift left logical variable
`define FUNCTION_SRLV    6'b000110  // Shift right logical variable
`define FUNCTION_SRAV    6'b000111  // Shift right arithmetic variable
`define FUNCTION_JR 	 6'b001000  // Jump register
`define FUNCTION_JALR 	 6'b001001  // Jump and link register
`define FUNCTION_SYSCALL 6'b001100  // System call                TODO
`define FUNCTION_BREAK   6'b001101  // Breakpoint                 TODO
`define FUNCTION_MFHI    6'b010000  // Move from HI register      TODO
`define FUNCTION_MTHI    6'b010001  // Move to HI register        TODO
`define FUNCTION_MFLO    6'b010010  // Move from LO register      TODO
`define FUNCTION_MTLO    6'b010011  // Move to LO register        TODO
`define FUNCTION_MULT    6'b011000  // Multiply                   TODO
`define FUNCTION_MULTU   6'b011001  // Multiply unsigned          TODO
`define FUNCTION_DIV     6'b011010  // Divide                     TODO
`define FUNCTION_DIVU    6'b011011  // Divide unsigned            TODO
`define FUNCTION_ADD 	 6'b100000  // Add
`define FUNCTION_ADDU    6'b100001  // Add unsigned
`define FUNCTION_SUB 	 6'b100010  // Subtract
`define FUNCTION_SUBU 	 6'b100011  // Subtract unsigned
`define FUNCTION_AND 	 6'b100100  // Bitwise AND
`define FUNCTION_OR 	 6'b100101  // Bitwise OR
`define FUNCTION_XOR	 6'b100110  // Bitwise XOR
`define FUNCTION_NOR     6'b100111  // Bitwise NOR
`define FUNCTION_SLT     6'b101010  // Set on less than
`define FUNCTION_SLTU    6'b101011  // Set on less than unsigned

// BCOND instruction class rt fields (ordered by binary value)
`define BCOND_BLTZ       5'b00000  // Branch on less than zero
`define BCOND_BGEZ       5'b00001  // Branch on greater than or equal to zero
`define BCOND_BLTZAL     5'b10000  // Branch on less than zero and link
`define BCOND_BGEZAL     5'b10001  // Branch on greater than or equal to zero and link

// Coprocessors instruction class rs fields (ordered by binary value)
`define COP_MFCz         5'b00000  // Move from Coprocessor z
`define COP_CFCz         5'b00010  // Copy from Coprocessor z
`define COP_MTCz         5'b00100  // Move to Coprocessor z
`define COP_CTCz         5'b00110  // Copy to Coprocessor z
`define COP_BCOND        5'b01000  // Branch condition for Coprocessor z

// ALU operation codes used internally (please note that signed/unsigned is another input)
`define ALU_OP_SLL       5'b00001
`define ALU_OP_SRL       5'b00010
`define ALU_OP_SRA       5'b00011
`define ALU_OP_ADD       5'b00100
`define ALU_OP_SUB       5'b00101
`define ALU_OP_AND       5'b00110
`define ALU_OP_OR        5'b00111
`define ALU_OP_XOR       5'b01000
`define ALU_OP_NOR       5'b01001
`define ALU_OP_SEQ       5'b01010
`define ALU_OP_SNE       5'b01011
`define ALU_OP_SLT       5'b01100
`define ALU_OP_SLE       5'b01101
`define ALU_OP_SGT       5'b01110
`define ALU_OP_SGE       5'b01111
`define ALU_OP_MULT      5'b10000
`define ALU_OP_DIV       5'b10001

