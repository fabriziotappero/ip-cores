/*
 * File         : MIPS_Parameters.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   26-May-2012  GEA       Release version.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   Provides a language abstraction for the MIPS32-specific op-codes and
 *   the processor-specific datapath, hazard, and exception bits which
 *   control the processor. These parameter names are used extensively
 *   throughout the processor HDL modules.
 */


/*** Exception Vector Locations ***
     
     When the CPU powers up or is reset, it will begin execution at 'EXC_Vector_Base_Reset'.
     All other exceptions are the sum of a base address and offset:
      - The base address is either a bootstrap or normal value. It is controlled by
        the 'BEV' bit in the CP0 'Status' register. Both base addresses can be mapped to 
        the same location.
      - The offset address is either a standard offset (which is always used for
        non-interrupt general exceptions in this processor because it lacks TLB Refill
        and Cache errors), or a special interrupt-only offset for interrupts, which is
        enabled with the 'IV' bit in the CP0 'Cause' register.
      
     Current Setup:
        General exceptions go to 0x0. Interrupts go to 0x8. Booting starts at 0x10.
*/   
parameter [31:0] EXC_Vector_Base_Reset          = 32'h0000_0010;    // MIPS Standard is 0xBFC0_0000
parameter [31:0] EXC_Vector_Base_Other_NoBoot   = 32'h0000_0000;    // MIPS Standard is 0x8000_0000
parameter [31:0] EXC_Vector_Base_Other_Boot     = 32'h0000_0000;    // MIPS Standard is 0xBFC0_0200
parameter [31:0] EXC_Vector_Offset_General      = 32'h0000_0000;    // MIPS Standard is 0x0000_0180
parameter [31:0] EXC_Vector_Offset_Special      = 32'h0000_0008;    // MIPS Standard is 0x0000_0200



/*** Kernel/User Memory Areas ***

     Kernel memory starts at address 0x0. User memory starts at 'UMem_Lower' and extends to
     the end of the address space.
     
     A distinction is made to protect against accesses to kernel memory while the processor
     is in user mode. Lacking MMU hardware, these addresses are physical, not virtual.
     This simple two-part division of the address space can be extended almost arbitrarily
     in the Data Memory Controller. Note that there is currently no user/kernel space check
     for the Instruction Memory, because it is assumed that instructions are in the kernel space.
*/
parameter [31:0] UMem_Lower = 32'h08000000;



/*** Processor Endianness ***

     The MIPS Configuration Register (CP0 Register 16 Select 0) specifies the processor's
     endianness. A processor in user mode may switch to reverse endianness, which will be
     the opposite of this parameter.
*/
parameter Big_Endian = 1;



/*** Encodings for MIPS32 Release 1 Architecture ***/


/* Op Code Categories */
parameter [5:0] Op_Type_R   = 6'b00_0000;  // Standard R-Type instructions
parameter [5:0] Op_Type_R2  = 6'b01_1100;  // Extended R-Like instructions
parameter [5:0] Op_Type_BI  = 6'b00_0001;  // Branch/Trap extended instructions
parameter [5:0] Op_Type_CP0 = 6'b01_0000;  // Coprocessor 0 instructions
parameter [5:0] Op_Type_CP1 = 6'b01_0001;  // Coprocessor 1 instructions (not implemented)
parameter [5:0] Op_Type_CP2 = 6'b01_0010;  // Coprocessor 2 instructions (not implemented)
parameter [5:0] Op_Type_CP3 = 6'b01_0011;  // Coprocessor 3 instructions (not implemented)
// --------------------------------------
parameter [5:0] Op_Add      = Op_Type_R;
parameter [5:0] Op_Addi     = 6'b00_1000;
parameter [5:0] Op_Addiu    = 6'b00_1001;
parameter [5:0] Op_Addu     = Op_Type_R;
parameter [5:0] Op_And      = Op_Type_R;
parameter [5:0] Op_Andi     = 6'b00_1100;
parameter [5:0] Op_Beq      = 6'b00_0100;
parameter [5:0] Op_Bgez     = Op_Type_BI;
parameter [5:0] Op_Bgezal   = Op_Type_BI;
parameter [5:0] Op_Bgtz     = 6'b00_0111;
parameter [5:0] Op_Blez     = 6'b00_0110;
parameter [5:0] Op_Bltz     = Op_Type_BI;
parameter [5:0] Op_Bltzal   = Op_Type_BI;
parameter [5:0] Op_Bne      = 6'b00_0101;
parameter [5:0] Op_Break    = Op_Type_R;
parameter [5:0] Op_Clo      = Op_Type_R2;
parameter [5:0] Op_Clz      = Op_Type_R2;
parameter [5:0] Op_Div      = Op_Type_R;
parameter [5:0] Op_Divu     = Op_Type_R;
parameter [5:0] Op_Eret     = Op_Type_CP0;
parameter [5:0] Op_J        = 6'b00_0010;
parameter [5:0] Op_Jal      = 6'b00_0011;
parameter [5:0] Op_Jalr     = Op_Type_R;
parameter [5:0] Op_Jr       = Op_Type_R;
parameter [5:0] Op_Lb       = 6'b10_0000;
parameter [5:0] Op_Lbu      = 6'b10_0100;
parameter [5:0] Op_Lh       = 6'b10_0001;
parameter [5:0] Op_Lhu      = 6'b10_0101;
parameter [5:0] Op_Ll       = 6'b11_0000;
parameter [5:0] Op_Lui      = 6'b00_1111;
parameter [5:0] Op_Lw       = 6'b10_0011;
parameter [5:0] Op_Lwl      = 6'b10_0010;
parameter [5:0] Op_Lwr      = 6'b10_0110;
parameter [5:0] Op_Madd     = Op_Type_R2;
parameter [5:0] Op_Maddu    = Op_Type_R2;
parameter [5:0] Op_Mfc0     = Op_Type_CP0;
parameter [5:0] Op_Mfhi     = Op_Type_R;
parameter [5:0] Op_Mflo     = Op_Type_R;
parameter [5:0] Op_Movn     = Op_Type_R;
parameter [5:0] Op_Movz     = Op_Type_R;
parameter [5:0] Op_Msub     = Op_Type_R2;
parameter [5:0] Op_Msubu    = Op_Type_R2;
parameter [5:0] Op_Mtc0     = Op_Type_CP0;
parameter [5:0] Op_Mthi     = Op_Type_R;
parameter [5:0] Op_Mtlo     = Op_Type_R;
parameter [5:0] Op_Mul      = Op_Type_R2;
parameter [5:0] Op_Mult     = Op_Type_R;
parameter [5:0] Op_Multu    = Op_Type_R;
parameter [5:0] Op_Nor      = Op_Type_R;
parameter [5:0] Op_Or       = Op_Type_R;
parameter [5:0] Op_Ori      = 6'b00_1101;
parameter [5:0] Op_Pref     = 6'b11_0011; // Prefetch does nothing in this implementation.
parameter [5:0] Op_Sb       = 6'b10_1000;
parameter [5:0] Op_Sc       = 6'b11_1000;
parameter [5:0] Op_Sh       = 6'b10_1001;
parameter [5:0] Op_Sll      = Op_Type_R;
parameter [5:0] Op_Sllv     = Op_Type_R;
parameter [5:0] Op_Slt      = Op_Type_R;
parameter [5:0] Op_Slti     = 6'b00_1010;
parameter [5:0] Op_Sltiu    = 6'b00_1011;
parameter [5:0] Op_Sltu     = Op_Type_R;
parameter [5:0] Op_Sra      = Op_Type_R;
parameter [5:0] Op_Srav     = Op_Type_R;
parameter [5:0] Op_Srl      = Op_Type_R;
parameter [5:0] Op_Srlv     = Op_Type_R;
parameter [5:0] Op_Sub      = Op_Type_R;
parameter [5:0] Op_Subu     = Op_Type_R;
parameter [5:0] Op_Sw       = 6'b10_1011;
parameter [5:0] Op_Swl      = 6'b10_1010;
parameter [5:0] Op_Swr      = 6'b10_1110;
parameter [5:0] Op_Syscall  = Op_Type_R;
parameter [5:0] Op_Teq      = Op_Type_R;
parameter [5:0] Op_Teqi     = Op_Type_BI;
parameter [5:0] Op_Tge      = Op_Type_R;
parameter [5:0] Op_Tgei     = Op_Type_BI;
parameter [5:0] Op_Tgeiu    = Op_Type_BI;
parameter [5:0] Op_Tgeu     = Op_Type_R;
parameter [5:0] Op_Tlt      = Op_Type_R;
parameter [5:0] Op_Tlti     = Op_Type_BI;
parameter [5:0] Op_Tltiu    = Op_Type_BI;
parameter [5:0] Op_Tltu     = Op_Type_R;
parameter [5:0] Op_Tne      = Op_Type_R;
parameter [5:0] Op_Tnei     = Op_Type_BI;
parameter [5:0] Op_Xor      = Op_Type_R;
parameter [5:0] Op_Xori     = 6'b00_1110;

/* Op Code Rt fields for Branches & Traps */
parameter [4:0] OpRt_Bgez   = 5'b00001;
parameter [4:0] OpRt_Bgezal = 5'b10001;
parameter [4:0] OpRt_Bltz   = 5'b00000;
parameter [4:0] OpRt_Bltzal = 5'b10000;
parameter [4:0] OpRt_Teqi   = 5'b01100;
parameter [4:0] OpRt_Tgei   = 5'b01000;
parameter [4:0] OpRt_Tgeiu  = 5'b01001;
parameter [4:0] OpRt_Tlti   = 5'b01010;
parameter [4:0] OpRt_Tltiu  = 5'b01011;
parameter [4:0] OpRt_Tnei   = 5'b01110;

/* Op Code Rs fields for Coprocessors */
parameter [4:0] OpRs_MF     = 5'b00000;
parameter [4:0] OpRs_MT     = 5'b00100;

/* Special handling for ERET */
parameter [4:0] OpRs_ERET   = 5'b10000;
parameter [5:0] Funct_ERET  = 6'b011000;

/* Function Codes for R-Type Op Codes */
parameter [5:0] Funct_Add     = 6'b10_0000;
parameter [5:0] Funct_Addu    = 6'b10_0001;
parameter [5:0] Funct_And     = 6'b10_0100;
parameter [5:0] Funct_Break   = 6'b00_1101;
parameter [5:0] Funct_Clo     = 6'b10_0001; // same as Addu
parameter [5:0] Funct_Clz     = 6'b10_0000; // same as Add
parameter [5:0] Funct_Div     = 6'b01_1010;
parameter [5:0] Funct_Divu    = 6'b01_1011;
parameter [5:0] Funct_Jr      = 6'b00_1000;
parameter [5:0] Funct_Jalr    = 6'b00_1001;
parameter [5:0] Funct_Madd    = 6'b00_0000;
parameter [5:0] Funct_Maddu   = 6'b00_0001;
parameter [5:0] Funct_Mfhi    = 6'b01_0000;
parameter [5:0] Funct_Mflo    = 6'b01_0010;
parameter [5:0] Funct_Movn    = 6'b00_1011;
parameter [5:0] Funct_Movz    = 6'b00_1010;
parameter [5:0] Funct_Msub    = 6'b00_0100; // same as Sllv
parameter [5:0] Funct_Msubu   = 6'b00_0101;
parameter [5:0] Funct_Mthi    = 6'b01_0001;
parameter [5:0] Funct_Mtlo    = 6'b01_0011;
parameter [5:0] Funct_Mul     = 6'b00_0010; // same as Srl
parameter [5:0] Funct_Mult    = 6'b01_1000;
parameter [5:0] Funct_Multu   = 6'b01_1001;
parameter [5:0] Funct_Nor     = 6'b10_0111;
parameter [5:0] Funct_Or      = 6'b10_0101;
parameter [5:0] Funct_Sll     = 6'b00_0000;
parameter [5:0] Funct_Sllv    = 6'b00_0100;
parameter [5:0] Funct_Slt     = 6'b10_1010;
parameter [5:0] Funct_Sltu    = 6'b10_1011;
parameter [5:0] Funct_Sra     = 6'b00_0011;
parameter [5:0] Funct_Srav    = 6'b00_0111;
parameter [5:0] Funct_Srl     = 6'b00_0010;
parameter [5:0] Funct_Srlv    = 6'b00_0110;
parameter [5:0] Funct_Sub     = 6'b10_0010;
parameter [5:0] Funct_Subu    = 6'b10_0011;
parameter [5:0] Funct_Syscall = 6'b00_1100;
parameter [5:0] Funct_Teq     = 6'b11_0100;
parameter [5:0] Funct_Tge     = 6'b11_0000;
parameter [5:0] Funct_Tgeu    = 6'b11_0001;
parameter [5:0] Funct_Tlt     = 6'b11_0010;
parameter [5:0] Funct_Tltu    = 6'b11_0011;
parameter [5:0] Funct_Tne     = 6'b11_0110;
parameter [5:0] Funct_Xor     = 6'b10_0110;

/* ALU Operations (Implementation) */
parameter [4:0] AluOp_Add    = 5'd1;
parameter [4:0] AluOp_Addu   = 5'd0;
parameter [4:0] AluOp_And    = 5'd2;
parameter [4:0] AluOp_Clo    = 5'd3;
parameter [4:0] AluOp_Clz    = 5'd4;
parameter [4:0] AluOp_Div    = 5'd5;
parameter [4:0] AluOp_Divu   = 5'd6;
parameter [4:0] AluOp_Madd   = 5'd7;
parameter [4:0] AluOp_Maddu  = 5'd8;
parameter [4:0] AluOp_Mfhi   = 5'd9;
parameter [4:0] AluOp_Mflo   = 5'd10;
parameter [4:0] AluOp_Msub   = 5'd13;
parameter [4:0] AluOp_Msubu  = 5'd14;
parameter [4:0] AluOp_Mthi   = 5'd11;
parameter [4:0] AluOp_Mtlo   = 5'd12;
parameter [4:0] AluOp_Mul    = 5'd15;
parameter [4:0] AluOp_Mult   = 5'd16;
parameter [4:0] AluOp_Multu  = 5'd17;
parameter [4:0] AluOp_Nor    = 5'd18;
parameter [4:0] AluOp_Or     = 5'd19;
parameter [4:0] AluOp_Sll    = 5'd20;
parameter [4:0] AluOp_Sllc   = 5'd21;  // Move this if another AluOp is needed
parameter [4:0] AluOp_Sllv   = 5'd22;
parameter [4:0] AluOp_Slt    = 5'd23;
parameter [4:0] AluOp_Sltu   = 5'd24;
parameter [4:0] AluOp_Sra    = 5'd25;
parameter [4:0] AluOp_Srav   = 5'd26;
parameter [4:0] AluOp_Srl    = 5'd27;
parameter [4:0] AluOp_Srlv   = 5'd28;
parameter [4:0] AluOp_Sub    = 5'd29;
parameter [4:0] AluOp_Subu   = 5'd30;
parameter [4:0] AluOp_Xor    = 5'd31;


// Movc:10->11, Trap:9->10, TrapCond:8->9, RegDst:7->8
            
/*** Datapath ***

     All Signals are Active High. Branching and Jump signals (determined by "PCSrc"),
     as well as ALU operation signals ("ALUOp") are handled by the controller and are not found here.

     Bit  Name          Description
     ------------------------------
     15:  PCSrc         (Instruction Type)
     14:                   11: Instruction is Jump to Register
                           10: Instruction is Branch
                           01: Instruction is Jump to Immediate
                           00: Instruction does not branch nor jump
     13:  Link          (Link on Branch/Jump)
     ------------------------------
     12:  ALUSrc        (ALU Source) [0=ALU input B is 2nd register file output; 1=Immediate value]
     11:  Movc          (Conditional Move)
     10:  Trap          (Trap Instruction)
     9 :  TrapCond      (Trap Condition) [0=ALU result is 0; 1=ALU result is not 0]
     8 :  RegDst        (Register File Target) [0=Rt field; 1=Rd field]
     ------------------------------
     7 :  LLSC          (Load Linked or Store Conditional)
     6 :  MemRead       (Data Memory Read)
     5 :  MemWrite      (Data Memory Write)
     4 :  MemHalf       (Half Word Memory Access)
     3 :  MemByte       (Byte size Memory Access)
     2 :  MemSignExtend (Sign Extend Read Memory) [0=Zero Extend; 1=Sign Extend]
     ------------------------------
     1 :  RegWrite      (Register File Write)
     0 :  MemtoReg      (Memory to Register) [0=Register File write data is ALU output; 1=Is Data Memory]
     ------------------------------
*/
parameter [15:0] DP_None        = 16'b000_00000_000000_00;    // Instructions which require nothing of the main datapath.
parameter [15:0] DP_RType       = 16'b000_00001_000000_10;    // Standard R-Type
parameter [15:0] DP_IType       = 16'b000_10000_000000_10;    // Standard I-Type
parameter [15:0] DP_Branch      = 16'b100_00000_000000_00;    // Standard Branch
parameter [15:0] DP_BranchLink  = 16'b101_00000_000000_10;    // Branch and Link
parameter [15:0] DP_HiLoWr      = 16'b000_00000_000000_00;    // Write to Hi/Lo ALU register (Div,Divu,Mult,Multu,Mthi,Mtlo). Currently 'DP_None'.
parameter [15:0] DP_Jump        = 16'b010_00000_000000_00;    // Standard Jump
parameter [15:0] DP_JumpLink    = 16'b011_00000_000000_10;    // Jump and Link
parameter [15:0] DP_JumpLinkReg = 16'b111_00000_000000_10;    // Jump and Link Register
parameter [15:0] DP_JumpReg     = 16'b110_00000_000000_00;    // Jump Register
parameter [15:0] DP_LoadByteS   = 16'b000_10000_010011_11;    // Load Byte Signed
parameter [15:0] DP_LoadByteU   = 16'b000_10000_010010_11;    // Load Byte Unsigned
parameter [15:0] DP_LoadHalfS   = 16'b000_10000_010101_11;    // Load Half Signed
parameter [15:0] DP_LoadHalfU   = 16'b000_10000_010100_11;    // Load Half Unsigned
parameter [15:0] DP_LoadWord    = 16'b000_10000_010000_11;    // Load Word
parameter [15:0] DP_ExtWrRt     = 16'b000_00000_000000_10;    // A DP-external write to Rt
parameter [15:0] DP_ExtWrRd     = 16'b000_00001_000000_10;    // A DP-external write to Rd
parameter [15:0] DP_Movc        = 16'b000_01001_000000_10;    // Conditional Move
parameter [15:0] DP_LoadLinked  = 16'b000_10000_110000_11;    // Load Linked
parameter [15:0] DP_StoreCond   = 16'b000_10000_101000_11;    // Store Conditional
parameter [15:0] DP_StoreByte   = 16'b000_10000_001010_00;    // Store Byte
parameter [15:0] DP_StoreHalf   = 16'b000_10000_001100_00;    // Store Half
parameter [15:0] DP_StoreWord   = 16'b000_10000_001000_00;    // Store Word
parameter [15:0] DP_TrapRegCNZ  = 16'b000_00110_000000_00;    // Trap using Rs and Rt,  non-zero ALU (Tlt,  Tltu,  Tne)
parameter [15:0] DP_TrapRegCZ   = 16'b000_00100_000000_00;    // Trap using RS and Rt,  zero ALU     (Teq,  Tge,   Tgeu)
parameter [15:0] DP_TrapImmCNZ  = 16'b000_10110_000000_00;    // Trap using Rs and Imm, non-zero ALU (Tlti, Tltiu, Tnei)
parameter [15:0] DP_TrapImmCZ   = 16'b000_10100_000000_00;    // Trap using Rs and Imm, zero ALU     (Teqi, Tgei,  Tgeiu)
//--------------------------------------------------------
parameter [15:0] DP_Add     = DP_RType;
parameter [15:0] DP_Addi    = DP_IType;
parameter [15:0] DP_Addiu   = DP_IType;
parameter [15:0] DP_Addu    = DP_RType;
parameter [15:0] DP_And     = DP_RType;
parameter [15:0] DP_Andi    = DP_IType;
parameter [15:0] DP_Beq     = DP_Branch;
parameter [15:0] DP_Bgez    = DP_Branch;
parameter [15:0] DP_Bgezal  = DP_BranchLink;
parameter [15:0] DP_Bgtz    = DP_Branch;
parameter [15:0] DP_Blez    = DP_Branch;
parameter [15:0] DP_Bltz    = DP_Branch;
parameter [15:0] DP_Bltzal  = DP_BranchLink;
parameter [15:0] DP_Bne     = DP_Branch;
parameter [15:0] DP_Break   = DP_None;
parameter [15:0] DP_Clo     = DP_RType;
parameter [15:0] DP_Clz     = DP_RType;
parameter [15:0] DP_Div     = DP_HiLoWr;
parameter [15:0] DP_Divu    = DP_HiLoWr;
parameter [15:0] DP_Eret    = DP_None;
parameter [15:0] DP_J       = DP_Jump;
parameter [15:0] DP_Jal     = DP_JumpLink;
parameter [15:0] DP_Jalr    = DP_JumpLinkReg;
parameter [15:0] DP_Jr      = DP_JumpReg;
parameter [15:0] DP_Lb      = DP_LoadByteS;
parameter [15:0] DP_Lbu     = DP_LoadByteU;
parameter [15:0] DP_Lh      = DP_LoadHalfS;
parameter [15:0] DP_Lhu     = DP_LoadHalfU;
parameter [15:0] DP_Ll      = DP_LoadLinked;
parameter [15:0] DP_Lui     = DP_IType;
parameter [15:0] DP_Lw      = DP_LoadWord;
parameter [15:0] DP_Lwl     = DP_LoadWord;
parameter [15:0] DP_Lwr     = DP_LoadWord;
parameter [15:0] DP_Madd    = DP_HiLoWr;
parameter [15:0] DP_Maddu   = DP_HiLoWr;
parameter [15:0] DP_Mfc0    = DP_ExtWrRt;
parameter [15:0] DP_Mfhi    = DP_ExtWrRd;
parameter [15:0] DP_Mflo    = DP_ExtWrRd;
parameter [15:0] DP_Movn    = DP_Movc;
parameter [15:0] DP_Movz    = DP_Movc;
parameter [15:0] DP_Msub    = DP_HiLoWr;
parameter [15:0] DP_Msubu   = DP_HiLoWr;
parameter [15:0] DP_Mtc0    = DP_None;
parameter [15:0] DP_Mthi    = DP_HiLoWr;
parameter [15:0] DP_Mtlo    = DP_HiLoWr;
parameter [15:0] DP_Mul     = DP_RType;
parameter [15:0] DP_Mult    = DP_HiLoWr;
parameter [15:0] DP_Multu   = DP_HiLoWr;
parameter [15:0] DP_Nor     = DP_RType;
parameter [15:0] DP_Or      = DP_RType;
parameter [15:0] DP_Ori     = DP_IType;
parameter [15:0] DP_Pref    = DP_None; // Not Implemented
parameter [15:0] DP_Sb      = DP_StoreByte;
parameter [15:0] DP_Sc      = DP_StoreCond;
parameter [15:0] DP_Sh      = DP_StoreHalf;
parameter [15:0] DP_Sll     = DP_RType;
parameter [15:0] DP_Sllv    = DP_RType;
parameter [15:0] DP_Slt     = DP_RType;
parameter [15:0] DP_Slti    = DP_IType;
parameter [15:0] DP_Sltiu   = DP_IType;
parameter [15:0] DP_Sltu    = DP_RType;
parameter [15:0] DP_Sra     = DP_RType;
parameter [15:0] DP_Srav    = DP_RType;
parameter [15:0] DP_Srl     = DP_RType;
parameter [15:0] DP_Srlv    = DP_RType;
parameter [15:0] DP_Sub     = DP_RType;
parameter [15:0] DP_Subu    = DP_RType;
parameter [15:0] DP_Sw      = DP_StoreWord;
parameter [15:0] DP_Swl     = DP_StoreWord;
parameter [15:0] DP_Swr     = DP_StoreWord;
parameter [15:0] DP_Syscall = DP_None;
parameter [15:0] DP_Teq     = DP_TrapRegCZ;
parameter [15:0] DP_Teqi    = DP_TrapImmCZ;
parameter [15:0] DP_Tge     = DP_TrapRegCZ;
parameter [15:0] DP_Tgei    = DP_TrapImmCZ;
parameter [15:0] DP_Tgeiu   = DP_TrapImmCZ;
parameter [15:0] DP_Tgeu    = DP_TrapRegCZ;
parameter [15:0] DP_Tlt     = DP_TrapRegCNZ;
parameter [15:0] DP_Tlti    = DP_TrapImmCNZ;
parameter [15:0] DP_Tltiu   = DP_TrapImmCNZ;
parameter [15:0] DP_Tltu    = DP_TrapRegCNZ;
parameter [15:0] DP_Tne     = DP_TrapRegCNZ;
parameter [15:0] DP_Tnei    = DP_TrapImmCNZ;
parameter [15:0] DP_Xor     = DP_RType;
parameter [15:0] DP_Xori    = DP_IType;




/*** Exception Information ***

     All signals are Active High.

     Bit  Meaning
     ------------
     2:   Instruction can cause exceptions in ID
     1:   Instruction can cause exceptions in EX
     0:   Instruction can cause exceptions in MEM
*/
parameter [2:0] EXC_None = 3'b000;
parameter [2:0] EXC_ID   = 3'b100;
parameter [2:0] EXC_EX   = 3'b010;
parameter [2:0] EXC_MEM  = 3'b001;
//--------------------------------
parameter [2:0] EXC_Add     = EXC_EX;
parameter [2:0] EXC_Addi    = EXC_EX;
parameter [2:0] EXC_Addiu   = EXC_None;
parameter [2:0] EXC_Addu    = EXC_None;
parameter [2:0] EXC_And     = EXC_None;
parameter [2:0] EXC_Andi    = EXC_None;
parameter [2:0] EXC_Beq     = EXC_None;
parameter [2:0] EXC_Bgez    = EXC_None;
parameter [2:0] EXC_Bgezal  = EXC_None;
parameter [2:0] EXC_Bgtz    = EXC_None;
parameter [2:0] EXC_Blez    = EXC_None;
parameter [2:0] EXC_Bltz    = EXC_None;
parameter [2:0] EXC_Bltzal  = EXC_None;
parameter [2:0] EXC_Bne     = EXC_None;
parameter [2:0] EXC_Break   = EXC_ID;
parameter [2:0] EXC_Clo     = EXC_None;
parameter [2:0] EXC_Clz     = EXC_None;
parameter [2:0] EXC_Div     = EXC_None;
parameter [2:0] EXC_Divu    = EXC_None;
parameter [2:0] EXC_Eret    = EXC_ID;
parameter [2:0] EXC_J       = EXC_None;
parameter [2:0] EXC_Jal     = EXC_None;
parameter [2:0] EXC_Jalr    = EXC_None;
parameter [2:0] EXC_Jr      = EXC_None;
parameter [2:0] EXC_Lb      = EXC_MEM;
parameter [2:0] EXC_Lbu     = EXC_MEM;
parameter [2:0] EXC_Lh      = EXC_MEM;
parameter [2:0] EXC_Lhu     = EXC_MEM;
parameter [2:0] EXC_Ll      = EXC_MEM;
parameter [2:0] EXC_Lui     = EXC_None;
parameter [2:0] EXC_Lw      = EXC_MEM;
parameter [2:0] EXC_Lwl     = EXC_MEM;
parameter [2:0] EXC_Lwr     = EXC_MEM;
parameter [2:0] EXC_Madd    = EXC_None;
parameter [2:0] EXC_Maddu   = EXC_None;
parameter [2:0] EXC_Mfc0    = EXC_ID;
parameter [2:0] EXC_Mfhi    = EXC_None;
parameter [2:0] EXC_Mflo    = EXC_None;
parameter [2:0] EXC_Movn    = EXC_None;
parameter [2:0] EXC_Movz    = EXC_None;
parameter [2:0] EXC_Msub    = EXC_None;
parameter [2:0] EXC_Msubu   = EXC_None;
parameter [2:0] EXC_Mtc0    = EXC_ID;
parameter [2:0] EXC_Mthi    = EXC_None;
parameter [2:0] EXC_Mtlo    = EXC_None;
parameter [2:0] EXC_Mul     = EXC_None;
parameter [2:0] EXC_Mult    = EXC_None;
parameter [2:0] EXC_Multu   = EXC_None;
parameter [2:0] EXC_Nor     = EXC_None;
parameter [2:0] EXC_Or      = EXC_None;
parameter [2:0] EXC_Ori     = EXC_None;
parameter [2:0] EXC_Pref    = EXC_None; // XXX
parameter [2:0] EXC_Sb      = EXC_MEM;
parameter [2:0] EXC_Sc      = EXC_MEM;
parameter [2:0] EXC_Sh      = EXC_MEM;
parameter [2:0] EXC_Sll     = EXC_None;
parameter [2:0] EXC_Sllv    = EXC_None;
parameter [2:0] EXC_Slt     = EXC_None;
parameter [2:0] EXC_Slti    = EXC_None;
parameter [2:0] EXC_Sltiu   = EXC_None;
parameter [2:0] EXC_Sltu    = EXC_None;
parameter [2:0] EXC_Sra     = EXC_None;
parameter [2:0] EXC_Srav    = EXC_None;
parameter [2:0] EXC_Srl     = EXC_None;
parameter [2:0] EXC_Srlv    = EXC_None;
parameter [2:0] EXC_Sub     = EXC_EX;
parameter [2:0] EXC_Subu    = EXC_None;
parameter [2:0] EXC_Sw      = EXC_MEM;
parameter [2:0] EXC_Swl     = EXC_MEM;
parameter [2:0] EXC_Swr     = EXC_MEM;
parameter [2:0] EXC_Syscall = EXC_ID;
parameter [2:0] EXC_Teq     = EXC_MEM;
parameter [2:0] EXC_Teqi    = EXC_MEM;
parameter [2:0] EXC_Tge     = EXC_MEM;
parameter [2:0] EXC_Tgei    = EXC_MEM;
parameter [2:0] EXC_Tgeiu   = EXC_MEM;
parameter [2:0] EXC_Tgeu    = EXC_MEM;
parameter [2:0] EXC_Tlt     = EXC_MEM;
parameter [2:0] EXC_Tlti    = EXC_MEM;
parameter [2:0] EXC_Tltiu   = EXC_MEM;
parameter [2:0] EXC_Tltu    = EXC_MEM;
parameter [2:0] EXC_Tne     = EXC_MEM;
parameter [2:0] EXC_Tnei    = EXC_MEM;
parameter [2:0] EXC_Xor     = EXC_None;
parameter [2:0] EXC_Xori    = EXC_None;




/*** Hazard & Forwarding Datapath ***

     All signals are Active High.
     
     Bit  Meaning
     ------------
     7:   Wants Rs by ID
     6:   Needs Rs by ID
     5:   Wants Rt by ID
     4:   Needs Rt by ID
     3:   Wants Rs by EX
     2:   Needs Rs by EX
     1:   Wants Rt by EX
     0:   Needs Rt by EX
*/
parameter [7:0] HAZ_Nothing  = 8'b00000000; // Jumps, Lui, Mfhi/lo, special, etc.
parameter [7:0] HAZ_IDRsIDRt = 8'b11110000; // Beq, Bne, Traps
parameter [7:0] HAZ_IDRs     = 8'b11000000; // Most branches, Jumps to registers
parameter [7:0] HAZ_IDRt     = 8'b00110000; // Mtc0
parameter [7:0] HAZ_IDRtEXRs = 8'b10111100; // Movn, Movz
parameter [7:0] HAZ_EXRsEXRt = 8'b10101111; // Many R-Type ops
parameter [7:0] HAZ_EXRs     = 8'b10001100; // Immediates: Loads, Clo/z, Mthi/lo, etc.
parameter [7:0] HAZ_EXRsWRt  = 8'b10101110; // Stores
parameter [7:0] HAZ_EXRt     = 8'b00100011; // Shifts using Shamt field
//-----------------------------------------
parameter [7:0] HAZ_Add     = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Addi    = HAZ_EXRs;
parameter [7:0] HAZ_Addiu   = HAZ_EXRs;
parameter [7:0] HAZ_Addu    = HAZ_EXRsEXRt;
parameter [7:0] HAZ_And     = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Andi    = HAZ_EXRs;
parameter [7:0] HAZ_Beq     = HAZ_IDRsIDRt;
parameter [7:0] HAZ_Bgez    = HAZ_IDRs;
parameter [7:0] HAZ_Bgezal  = HAZ_IDRs;
parameter [7:0] HAZ_Bgtz    = HAZ_IDRs;
parameter [7:0] HAZ_Blez    = HAZ_IDRs;
parameter [7:0] HAZ_Bltz    = HAZ_IDRs;
parameter [7:0] HAZ_Bltzal  = HAZ_IDRs;
parameter [7:0] HAZ_Bne     = HAZ_IDRsIDRt;
parameter [7:0] HAZ_Break   = HAZ_Nothing;
parameter [7:0] HAZ_Clo     = HAZ_EXRs;
parameter [7:0] HAZ_Clz     = HAZ_EXRs;
parameter [7:0] HAZ_Div     = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Divu    = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Eret    = HAZ_Nothing;
parameter [7:0] HAZ_J       = HAZ_Nothing;
parameter [7:0] HAZ_Jal     = HAZ_Nothing;
parameter [7:0] HAZ_Jalr    = HAZ_IDRs;
parameter [7:0] HAZ_Jr      = HAZ_IDRs;
parameter [7:0] HAZ_Lb      = HAZ_EXRs;
parameter [7:0] HAZ_Lbu     = HAZ_EXRs;
parameter [7:0] HAZ_Lh      = HAZ_EXRs;
parameter [7:0] HAZ_Lhu     = HAZ_EXRs;
parameter [7:0] HAZ_Ll      = HAZ_EXRs;
parameter [7:0] HAZ_Lui     = HAZ_Nothing;
parameter [7:0] HAZ_Lw      = HAZ_EXRs;
parameter [7:0] HAZ_Lwl     = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Lwr     = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Madd    = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Maddu   = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Mfc0    = HAZ_Nothing;
parameter [7:0] HAZ_Mfhi    = HAZ_Nothing;
parameter [7:0] HAZ_Mflo    = HAZ_Nothing;
parameter [7:0] HAZ_Movn    = HAZ_IDRtEXRs;
parameter [7:0] HAZ_Movz    = HAZ_IDRtEXRs;
parameter [7:0] HAZ_Msub    = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Msubu   = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Mtc0    = HAZ_IDRt;
parameter [7:0] HAZ_Mthi    = HAZ_EXRs;
parameter [7:0] HAZ_Mtlo    = HAZ_EXRs;
parameter [7:0] HAZ_Mul     = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Mult    = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Multu   = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Nor     = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Or      = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Ori     = HAZ_EXRs;
parameter [7:0] HAZ_Pref    = HAZ_Nothing; // XXX
parameter [7:0] HAZ_Sb      = HAZ_EXRsWRt;
parameter [7:0] HAZ_Sc      = HAZ_EXRsWRt;
parameter [7:0] HAZ_Sh      = HAZ_EXRsWRt;
parameter [7:0] HAZ_Sll     = HAZ_EXRt;
parameter [7:0] HAZ_Sllv    = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Slt     = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Slti    = HAZ_EXRs;
parameter [7:0] HAZ_Sltiu   = HAZ_EXRs;
parameter [7:0] HAZ_Sltu    = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Sra     = HAZ_EXRt;
parameter [7:0] HAZ_Srav    = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Srl     = HAZ_EXRt;
parameter [7:0] HAZ_Srlv    = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Sub     = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Subu    = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Sw      = HAZ_EXRsWRt;
parameter [7:0] HAZ_Swl     = HAZ_EXRsWRt;
parameter [7:0] HAZ_Swr     = HAZ_EXRsWRt;
parameter [7:0] HAZ_Syscall = HAZ_Nothing;
parameter [7:0] HAZ_Teq     = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Teqi    = HAZ_EXRs;
parameter [7:0] HAZ_Tge     = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Tgei    = HAZ_EXRs;
parameter [7:0] HAZ_Tgeiu   = HAZ_EXRs;
parameter [7:0] HAZ_Tgeu    = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Tlt     = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Tlti    = HAZ_EXRs;
parameter [7:0] HAZ_Tltiu   = HAZ_EXRs;
parameter [7:0] HAZ_Tltu    = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Tne     = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Tnei    = HAZ_EXRs;
parameter [7:0] HAZ_Xor     = HAZ_EXRsEXRt;
parameter [7:0] HAZ_Xori    = HAZ_EXRs;

