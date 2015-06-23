/*
  Header for instruction analysis program. 

  Have appropriate defines/typedefs for desired instruction set.

  Todo: #ifdefs for other instruction sets

*/



// OpenRISC 1000 32-bit compiler output analysis settings:

#include "stdint.h"
#include "or1k-32-insn.h"

// 4 bytes per instruction
#define INSN_SIZE_BYTES 4

typedef uint32_t instruction;

typedef struct or1k_32_instruction_properties instruction_properties ;

#define reset_instruction_properties(x) memset(x, 0, sizeof(instruction_properties))

