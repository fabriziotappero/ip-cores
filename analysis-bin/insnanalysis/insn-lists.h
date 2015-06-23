/*
  Instruction list-keeping functions, aiding analysis

  Julius Baxter, julius.baxter@orsoc.se

*/

#define IS_UNIQUE -1


// Function prototypes
// 
// Reset the variables/counters
void insn_lists_init(void);

// Report a new incidence of an instruction
void insn_lists_add(instruction insn,
		    instruction_properties *insn_props);

// Record occurance of last n instructions
void insn_lists_group_add(int n,
			  instruction_properties *insn_props);

// Free, clean up, anything we need to
void insn_lists_free(void);
