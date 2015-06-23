/*
  Or1K instruction set-specific decoding and analysis functions.

  Julius Baxter, julius.baxter@orsoc.se

*/


// Enable debug printf'ing straight to stdout -- will be a LOT of output
#define DEBUG_PRINT 0

// Choose the output format, uncomment only one
//#define DISPLAY_STRING
#define DISPLAY_CSV


// Struct for information about the register to be confugred
// Set to 1 to enable
struct or1k_32_instruction_properties 
{
  int has_jumptarg;
  int has_branchtarg;

  int has_imm;
  int has_split_imm;

  int has_rD;
  int has_rA;
  int has_rB;

  char *insn_string;
  int insn_index;

};


// Structs for internal statistics keeping

struct or1k_value_list
{

#define OR1K_VALUE_MAX_ENTRIES 64
  int count;
  // [value][occurances_of_value]
  int32_t values[OR1K_VALUE_MAX_ENTRIES][2];
  
};

struct or1k_insn_info
{
  char* insn_string;

  int count;
  
  int has_branchtarg;
  struct or1k_value_list branch_info;

  int has_imm;
  struct or1k_value_list imm_info;

  int has_rD;
  int rD_use_freq[32];
  int has_rA;
  int rA_use_freq[32];
  int has_rB;
  int rB_use_freq[32];

  // Set maximum instructions in a row we'll keep track of, starting at pairs
#define OR1K_MAX_GROUPINGS_ANALYSIS 4
#define OR1K_MAX_ENTRIES_PER_GROUP 500
  // Format of grouping data:
  //
  // 1st dimension: A list for each n-tuple group we're keeping track of 
  // (starting at pairs of instructions)
  //
  // 2nd dimension: Stores the list entries for the 1st dimension-tuple 
  // grouping. The number in [x][0][0] is the number of entries in the list so 
  // far, beginning at 0. The actual entries with data for grouping x start at 
  // [x][1][], where that entry holds the 1st x+2-tuple grouping information 
  // (eg. at x=0, [0][1][] is the first entry for/ pair instruction 
  // information, x=1, is for triples, x=2 quadruples, etc)
  //
  // 3rd dimension: Store up to x+2 instruction indexes (where x is the first 
  // dimension index, meaning this particular data is for a (x+2)-tuple set) 
  // and then a frequency count for this set (in index (x+2) of the third 
  // dimension array). Note we will have the index for the instruction this 
  // struct corresponds to in [x][n][(x+2)-1], which seems redundant, but can 
  // help processing later on. The final entry after the instruction indexes
  // is the occurance count for this particular set (at [x][n][x+2])
  // 
  // Note that we will have empty entries in the third dimension arrays for all
  // but the last in the list of n-tuples. This is to save doing tricky naming
  // defines and, in the future, if we would like to analyse sets that are 
  // bigger or smaller, hopefully all we need to do is change a single define.
  //
  int groupings[OR1K_MAX_GROUPINGS_ANALYSIS][OR1K_MAX_ENTRIES_PER_GROUP+1][OR1K_MAX_GROUPINGS_ANALYSIS+1];

};

// This number should correspond to the maximum insn_index we assign in the 
// analyse function
#define OR1K_32_MAX_INSNS 118
extern struct or1k_insn_info * or1k_32_insns[OR1K_32_MAX_INSNS];


// OpenRISC 1000 32-bit instruction defines, helping us
// extract fields of the instructions

// Instruction decode/set its options
int or1k_32_analyse_insn(uint32_t insn, 
			 struct or1k_32_instruction_properties *insn_props);


// Stat collection entry-oint
void or1k_32_collect_stats(uint32_t insn,
			   struct or1k_32_instruction_properties  * insn_props,
			   int record_bin_insns);


// List management/analysis functions
// Reset lists
void or1k_32_insn_lists_init(void);

// Add the stats for this one
void or1k_32_insn_lists_add(uint32_t insn, 
			    struct or1k_32_instruction_properties *insn_props);

// Record the occurance of a group of instructions
void or1k_32_ntuple_add(int n, 
			struct or1k_32_instruction_properties *insn_props);

// Print out some useful information
void or1k_32_generate_stats(FILE * stream);

// Free lists
void or1k_32_insn_lists_free(void);

#define JUMPTARG_MASK 0x3ffffff

#define insn_or1k_opcode(x) (x>>26 & 0x3f)

#define insn_or1k_32_rD(x) (((x>>21)&0x1f))
#define insn_or1k_32_rA(x) (((x>>16)&0x1f))
#define insn_or1k_32_rB(x) (((x>>11)&0x1f))
#define insn_or1k_32_imm(x) (x&0xffff)
#define insn_or1k_32_split_imm(x) ((((x>>21)&0x1f)<<11)|(x&0x7ff))

#define insn_or1k_opcode_0x00_get_jumptarg(x) (x&JUMPTARG_MASK)

#define insn_or1k_opcode_0x01_get_jumptarg(x) (x&JUMPTARG_MASK)

#define insn_or1k_opcode_0x03_get_branchoff(x) (x&JUMPTARG_MASK)

#define insn_or1k_opcode_0x04_get_branchoff(x) (x&JUMPTARG_MASK)

#define insn_or1k_opcode_0x05_get_noop_id(x) ((x>>24) & 0x3)
#define insn_or1k_opcode_0x05_get_imm(x) insn_or1k_32_imm(x)

#define insn_or1k_opcode_0x06_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x06_get_id(x) ((x>>16) & 0x1)
#define insn_or1k_opcode_0x06_get_imm(x) insn_or1k_32_imm(x)

/* N/A: opcode 0x7 */

#define insn_or1k_opcode_0x08_get_id(x) ((x>>23)&0x7)
#define insn_or1k_opcode_0x08_get_imm(x) insn_or1k_32_imm(x)

#define insn_or1k_opcode_0x0a_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x0a_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x0a_get_rB(x) insn_or1k_32_rB(x)
#define insn_or1k_opcode_0x0a_get_op_hi(x) ((x>>4)&0xf)
#define insn_or1k_opcode_0x0a_get_op_lo(x) (x&0xf)

/* N/A: opcodes 0xb,c,d,e,f,10 */

#define insn_or1k_opcode_0x11_get_rB(x)  insn_or1k_32_rB(x)

#define insn_or1k_opcode_0x12_get_rB(x)  insn_or1k_32_rB(x)

#define insn_or1k_opcode_0x13_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x13_get_imm(x) insn_or1k_32_split_imm(x)

/* N/A: opcodes 0x14,15, 16, 17, 18, 19, 1a, 1b */

#define insn_or1k_opcode_0x20_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x20_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x20_get_imm(x) insn_or1k_32_imm(x)


#define insn_or1k_opcode_0x21_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x21_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x21_get_imm(x) insn_or1k_32_imm(x)


#define insn_or1k_opcode_0x22_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x22_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x22_get_imm(x) insn_or1k_32_imm(x)


#define insn_or1k_opcode_0x23_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x23_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x23_get_imm(x) insn_or1k_32_imm(x)


#define insn_or1k_opcode_0x24_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x24_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x24_get_imm(x) insn_or1k_32_imm(x)


#define insn_or1k_opcode_0x25_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x25_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x25_get_imm(x) insn_or1k_32_imm(x)


#define insn_or1k_opcode_0x26_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x26_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x26_get_imm(x) insn_or1k_32_imm(x)


#define insn_or1k_opcode_0x27_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x27_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x27_get_imm(x) insn_or1k_32_imm(x)

#define insn_or1k_opcode_0x28_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x28_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x28_get_imm(x) insn_or1k_32_imm(x)


#define insn_or1k_opcode_0x29_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x29_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x29_get_imm(x) insn_or1k_32_imm(x)


#define insn_or1k_opcode_0x2a_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x2a_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x2a_get_imm(x) insn_or1k_32_imm(x)


#define insn_or1k_opcode_0x2b_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x2b_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x2b_get_imm(x) insn_or1k_32_imm(x)


#define insn_or1k_opcode_0x2c_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x2c_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x2c_get_imm(x) insn_or1k_32_imm(x)


#define insn_or1k_opcode_0x2d_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x2d_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x2d_get_imm(x) insn_or1k_32_imm(x)


#define insn_or1k_opcode_0x2e_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x2e_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x2e_get_op(x) ((x>>6)&0x3)
#define insn_or1k_opcode_0x2e_get_imm(x) ((x&3f))


#define insn_or1k_opcode_0x2f_get_op(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x2f_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x2f_get_imm(x) insn_or1k_32_imm(x)


#define insn_or1k_opcode_0x30_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x30_get_rB(x) insn_or1k_32_rB(x)
#define insn_or1k_opcode_0x30_get_imm(x) insn_or1k_32_split_imm(x)


#define insn_or1k_opcode_0x31_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x31_get_rB(x) insn_or1k_32_rB(x)
#define insn_or1k_opcode_0x31_get_op(x) (x&0xf)


#define insn_or1k_opcode_0x32_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x32_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x32_get_rB(x) insn_or1k_32_rB(x)
#define insn_or1k_opcode_0x32_get_op_hi(x) ((x>>4)&0xf)
#define insn_or1k_opcode_0x32_get_op_lo(x) ((x&0xf))

/* N/A: opcodes 0x33 */

#define insn_or1k_opcode_0x34_get_rD(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x34_get_rB(x) insn_or1k_32_rB(x)
#define insn_or1k_opcode_0x34_get_imm(x) insn_or1k_32_split_imm(x)


#define insn_or1k_opcode_0x35_get_rD(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x35_get_rB(x) insn_or1k_32_rB(x)
#define insn_or1k_opcode_0x35_get_imm(x) insn_or1k_32_split_imm(x)


#define insn_or1k_opcode_0x36_get_rD(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x36_get_rB(x) insn_or1k_32_rB(x)
#define insn_or1k_opcode_0x36_get_imm(x) insn_or1k_32_split_imm(x)


#define insn_or1k_opcode_0x37_get_rD(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x37_get_rB(x) insn_or1k_32_rB(x)
#define insn_or1k_opcode_0x37_get_imm(x) insn_or1k_32_split_imm(x)


#define insn_or1k_opcode_0x38_get_rD(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x38_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x38_get_rB(x) insn_or1k_32_rB(x)
#define insn_or1k_opcode_0x38_get_op_hi_2bit(x) ((x>>8)&0x3)
#define insn_or1k_opcode_0x38_get_op_hi_4bit(x) ((x>>6)&0xf)
#define insn_or1k_opcode_0x38_get_op_lo(x) ((x&0xf))

#define insn_or1k_opcode_0x39_get_op(x) insn_or1k_32_rD(x)
#define insn_or1k_opcode_0x39_get_rA(x) insn_or1k_32_rA(x)
#define insn_or1k_opcode_0x39_get_rB(x) insn_or1k_32_rB(x)

/* N/A: opcodes 0x3a,3b */
