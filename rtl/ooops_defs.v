/*
  Josh Smith
 
  File: oops_defs.v
  Description: File for the global defines
*/
`timescale 1ns/10ps
`define SD            #1

// Common field widths
`define ADDR_SZ       32                                  // Address width/size
`define INSTR_SZ      32                                  // Instruction width/size
`define DATA_SZ       32                                  // Data width/size
`define IMM_SZ        16                                  // Immediate width/size

// ROB defines
`define ROB_ENTRIES   8                                   // Size of ReorderBuffer
`define ROB_PTR_SZ    4                                   // Size of ROB ptr (1 extra bit for full/empty detection)

// Register file and map table/free list defines
`define ARCH_REGS     34                                  // GPR 0-31, HI/LO
`define REG_IDX_SZ    6                                   // Architected register index size (6 bits to include HI/LO)
`define TAG_SZ        6                                   // Register tag size
`define TAGS          (`ARCH_REGS+`ROB_ENTRIES)           // 32 GPRs, HI/LO, and ROB size
`define FL_SZ         (`TAGS)
`define FL_PTR_SZ     `TAG_SZ                               
`define LO_REG        `TAG_SZ'd33
`define ZERO_REG      `TAG_SZ'd0

`define CHKPT_NUM     4                                   // Number of RAT checkpoints
`define CHKPT_PTR_SZ  2

// CDB defines
`define NUM_CDB       4                                     // 2 ALU, 1 LD/ST, 1 MULT/DIV
`define CDB_SZ        (1+`TAG_SZ+`REG_IDX_SZ+`ROB_PTR_SZ)   // 1 valid bit, 1 tag, 1 architectural reg index, 1 ROB index
`define CDB_VLD       `TAG_SZ+`REG_IDX_SZ+`ROB_PTR_SZ       // Valid field of CDB
`define CDB_ROB_IDX   `TAG_SZ+`REG_IDX_SZ+`ROB_PTR_SZ-1:`TAG_SZ+`REG_IDX_SZ
`define CDB_TAG       `REG_IDX_SZ+`TAG_SZ-1:`REG_IDX_SZ     // Tag field of CDB
`define CDB_REG_IDX   `REG_IDX_SZ-1:0                       // Arch. reg index field of CDB
`define CDB_BUS_SZ    (`NUM_CDB*`CDB_SZ)                    // `NUM_CDB valid bits and tags
`define CDB_DATA_SZ   (`NUM_CDB*`DATA_SZ)

// Branch prediction defines
`define BP_IDX_SZ     4                                   // Size of Index into branch predictor
`define BP_ENTRIES    (1 << `BP_IDX_SZ)                   // Number of branch predictor entries

// System Bus defines
`define SYS_BUS_SZ    64
`define SYS_BUS_BE_SZ 8

// Instruction Cache defines
`define IC_LINE_SZ    (2*`INSTR_SZ)                       // Size of instruction cache line
`define IC_BO_SZ      3                                   // Block-offset size
`define IC_SI_SZ      8                                   // Set index size
`define IC_TAG_SZ     (`ADDR_SZ-`IC_SI_SZ-`IC_BO_SZ)      // Tag size
`define IC_TAG        `ADDR_SZ-1 -: `IC_TAG_SZ            // Tag field of PC
`define IC_SI         `IC_SI_SZ+`IC_BO_SZ-1:`IC_BO_SZ     // Set index field of PC
`define IC_NUM_LINES  (1<<`IC_SI_SZ)                      // Number of instruction cache lines
`define IC_TAGRAM_SZ  (1+1+`IC_TAG_SZ)                    // +2 bits for valid/dirty (dirty not used)
`define IC_TAGRAM_VLD `IC_TAG_SZ+1                        // Valid field
`define IC_TAGRAM_DRT `IC_TAG_SZ                          // Dirty field
`define IC_TAGRAM_TAG `IC_TAG_SZ-1:0                      // tag field

// Data Cache defines
`define DC_LINE_SZ    (2*`DATA_SZ)                        // Size of data cache line
`define DC_BO_SZ      2                                   // Block-offset size
`define DC_SI_SZ      8                                   // Set index size
`define DC_TAG_SZ     (`ADDR_SZ-`DC_SI_SZ-`DC_BO_SZ)      // Tag size
`define DC_TAG        `ADDR_SZ-1 -: `DC_TAG_SZ            // Tag field of PC
`define DC_SI         `ADDR_SZ-1-`DC_TAG_SZ -: `DC_SI_SZ  // Set index field of PC
`define DC_TAGRAM_SZ  (1+1+`DC_TAG_SZ)                    // +2 bits for valid/dirty
`define DC_NUM_LINES  (1<<`DC_SI_SZ)                      // Number of data cache lines
`define DC_TAGRAM_VLD `DC_TAG_SZ+1                        // Valid field
`define DC_TAGRAM_DRT `DC_TAG_SZ                          // Dirty field
`define DC_TAGRAM_TAG `DC_TAG_SZ-1:0                      // tag field

`define RESET_ADDR 32'h0                                  // FPC reset address

// Fields of branch prediction bus
`define BP_SZ     34
`define BP_TRGT   33:2
`define BP_TKN    1
`define BP_VLD    0

// Fields of Decode bus
/*
`define DEC_BUS_SZ        84
`define DEC_IMM_DATA      83:68   // Immediate data for ALU and MEM
`define DEC_TYPE_INFO     67:65   // Instruction type info group
`define DEC_TYPE_ALU      67      // ALU/Branch instruction type
`define DEC_TYPE_MULT_DIV 66      // MULT/DIV instruction type
`define DEC_TYPE_MEM      65      // Load/Store instruction type
`define DEC_REG_INFO      64:44   // Register info group
`define DEC_REG_D_WR      64      // Writes to dest register
`define DEC_REG_T_NEED    63      // Need register T operand
`define DEC_REG_S_NEED    62      // Need register S operand
`define DEC_REG_D_INDX    61:56   // Destination register index
`define DEC_REG_T_INDX    55:50   // Operand register T index
`define DEC_REG_S_INDX    49:44   // Operand register S index
`define DEC_MULTDIV_SZ    8       // MULT/DIV info group
`define DEC_MULTDIV_INFO  43:36   // MULT/DIV info group
`define DEC_MTLO          43      // Move to LO
`define DEC_MTHI          42      // Move to HI
`define DEC_MFLO          41      // Move from LO
`define DEC_MFHI          40      // Move from HI
`define DEC_MD_SIGNED     39      // Mult/Div signed
`define DEC_DIV           38      // Divide
`define DEC_MULT          37      // Multiply
`define DEC_WR_HILO       36      // Write to HI and LO registers
`define DEC_MEM_SZ        6
`define DEC_MEM_INFO      35:30   // Load/Store info group
`define DEC_MEM_W         35      // Word load/store
`define DEC_MEM_HW        34      // Halfword load/store
`define DEC_MEM_B         33      // Byte load/store
`define DEC_MEM_ST        32      // Memory store
`define DEC_MEM_SIGNED    31      // Load Signed
`define DEC_MEM_LD        30      // Memory load
`define DEC_CP_SZ         7
`define DEC_CP_INFO       29:23   // Coprocessor info group
`define DEC_CP_SEL        29:27   // Coprocessor Sel index
`define DEC_CP_NUM        26:25   // Coprocessor number
`define DEC_CP_TO         24      // Move To coprocessor (from if 0)
`define DEC_CP_OP         23      // Coprocessor Operation
`define DEC_BR_SZ         10
`define DEC_BR_INFO       22:13   // Branch info group
`define DEC_BR_SYS        22      // SYSCALL
`define DEC_BR_BRK        21      // BREAK
`define DEC_BR_LINK       20      // Branch/Jump and link
`define DEC_BR_JR         19      // JR/JALR
`define DEC_BR_J          18      // J/JAL
`define DEC_BR_NEG        17      // Negate condition (to get the rest of the conditions)
`define DEC_BR_BGT        16      // BGTZ condition
`define DEC_BR_BGE        15      // BGEZ condition
`define DEC_BR_BEQ        14      // BEQ condition
`define DEC_BR_INST       13      // Branch instruction
`define DEC_ALU_SZ        13      
`define DEC_ALU_INFO      12:0    // ALU info group
`define DEC_ALU_SIGNED    12      // Signed operation
`define DEC_ALU_IMM       11      // Use immediate instead of register
`define DEC_ALU_LUI       10      // LUI (will treat as shift operation with immediate inputs)
`define DEC_ALU_S_A       9       // Shift arithmetic (if 1, logical if 0)
`define DEC_ALU_SR        8       // Shift right
`define DEC_ALU_SL        7       // Shift left
`define DEC_ALU_CMP       6       // Compare (SLT)
`define DEC_ALU_OR        5       // Logical OR
`define DEC_ALU_NOR       4       // Logical NOR
`define DEC_ALU_XOR       3       // Logical XOR
`define DEC_ALU_AND       2       // Logical AND
`define DEC_ALU_SUB       1       // Subtraction
`define DEC_ALU_ADD       0       // Addition
*/

// Fields of instruction decode bus from ID stage.
// Note: to save on flops, ID stage will only determine basic instruction type
// and register operand/destination information.  Complete instruction decoding
// will happen during last Dispatch cycle into Reservation Station.
`define DEC_BUS_SZ            26
`define DEC_REG_D_IDX         25:20   // Rd index
`define DEC_REG_T_IDX         19:14   // Rt index
`define DEC_REG_S_IDX         13:8    // Rs index
`define DEC_REG_D_WR          7       // Writes to Rd
`define DEC_REG_T_NEED        6       // Needs Rt operand
`define DEC_REG_S_NEED        5       // Needs Rs operand
`define DEC_TYPE_CP           4       // CP move instruction
`define DEC_TYPE_BR           3       // Branch instruction
`define DEC_TYPE_LDST         2       // Instruction handled by LDST unit
`define DEC_TYPE_MULTDIV      1       // Instruction handled by MULT/DIV unit
`define DEC_TYPE_ALU          0       // Instruction handled by ALU unit

// ALU control bus for ALU operation.
`define ALU_CTL_SZ            1

// Fields of Branch/Jump operation bus
`define BR_INFO_SZ  10
`define BR_SYS      9     // SYSCALL
`define BR_BRK      8     // BREAK
`define BR_LINK     7     // Branch/Jump and link
`define BR_JR       6     // JR/JALR
`define BR_J        5     // J/JAL
`define BR_NEG      4     // Negate condition (to get the rest of the conditions)
`define BR_BGT      3     // BGTZ condition
`define BR_BGE      2     // BGEZ condition
`define BR_BEQ      1     // BEQ condition
`define BR_INST     0     // Branch instruction

// Fields of ALU information bus
`define ALU_INFO_SZ   13
`define ALU_SIGNED    12          // Signed operation
`define ALU_IMM       11          // Use immediate instead of register
`define ALU_LUI       10          // LUI (treated as shift op)
`define ALU_S_A       9           // Shift arithmetic (if 1, logical if 0)
`define ALU_SR        8           // Shift right
`define ALU_SL        7           // Shift left
`define ALU_CMP       6           // Compare (SLT)
`define ALU_OR        5           // Logical OR
`define ALU_NOR       4           // Logical NOR
`define ALU_XOR       3           // Logical XOR
`define ALU_AND       2           // Logical AND
`define ALU_SUB       1           // Subtraction
`define ALU_ADD       0           // Addition

// Fields of rename information
`define REN_BUS_SZ        35
`define REN_DEST_IDX      34:29       // Destination (reg_d) index
`define REN_DEST_VLD      28          // Writes to destination
`define REN_DEST_TAG_OLD  27:22       // Destination (reg_d) old tag
`define REN_DEST_TAG      21:16       // Destination (reg_d) tag
`define REN_SRC2_VLD      15          // Source 2 data valid in register file
`define REN_SRC2_NEED     14          // Need source 2 register data
`define REN_SRC2_TAG      13:8        // Source 2 (reg_s) tag
`define REN_SRC1_VLD      7           // Source 1 data valid in register file
`define REN_SRC1_NEED     6           // Need source 1 register data
`define REN_SRC1_TAG      5:0         // Source 1 (reg_s) tag

// Reservation Station defines
`define ALU_RS_ENTRIES      4                             // Size of Reservation Station for ALU and branch
`define ALU_RS_CNT_SZ       3                             // Size of occupancy counter
//`define ALU_RS_CNTL_SZ      (`DEC_ALU_SZ+`DEC_BR_SZ+`DEC_CP_SZ+`ADDR_SZ+`IMM_SZ)
`define MULTDIV_RS_ENTRIES  2                             // Size of Reservation Station for MULT/DIV
`define MULTDIV_RS_CNT_SZ   2                             // Size of occupancy counter
//`define MULTDIV_RS_CNTL_SZ  (`DEC_MULTDIV_SZ)
`define LDST_RS_ENTRIES     2                             // Size of Reservation Station for Load/Store
`define LDST_RS_CNT_SZ      2                             // Size of occupancy counter
//`define LDST_RS_CNTL_SZ     (`DEC_MEM_SZ+`IMM_SZ)

// CP0 Register fields
`define CP0_STATUS_EXL  1

// Feature ifdefs
// Comment out define to remove feature from compilation
//`define USE_PLL                 // Include PLL (exclude for simulation)
`define USE_IC                    // include Instruction cache
`define USE_DC                    // include Data cache
//`define DYN_BPRD                // TODO: Add back in later
`define USE_IFB                   // Include instruction buffer between IF and ID stages

`ifdef USE_IFB
  `define IFB_ENTRIES   4         // Number of fetch buffer entries
  `define IFB_ENTRY_SZ        (`INSTR_SZ+`ADDR_SZ+`BP_SZ+1)
  `define IFB_PTR_SZ    2         // Fetch buffer pointer width
`endif

//`define TIMING_OPT                // Use timing-optimized RTL in some portions (area affected)
//`define ALTERA                    // Used to instantiate ALTERA megafunctions over generic logic
