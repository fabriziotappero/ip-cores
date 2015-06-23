#ifndef _INSTRUCTIONS_H_
#define _INSTRUCTIONS_H_

#include <stdio.h>

#include "types.h"

#define NUM_INSTRUCTIONS			64
#define INS_NOP               0x00
#define INS_HALT              0x01

#define INS_ADD               0x02
#define INS_SUB               0x03
#define INS_MUL               0x04
#define INS_DIV               0x05
#define INS_AND               0x06
#define INS_OR                0x07
#define INS_XOR               0x08
#define INS_NOT               0x09
#define INS_SHIFT_L           0x0A
#define INS_MOD               0x0B
#define INS_SHIFT_R           0x0C

#define INS_LOAD              0x10
#define INS_STORE             0x11

#define INS_BRANCH            0x15
#define INS_BRANCH_REG        0x16

#define INS_SET_FLAG          0x17
#define INS_CLEAR_FLAG        0x18
#define INS_GET_FLAG          0x19

#define INS_GET_TYPE          0x20
#define INS_SET_TYPE          0x21
#define INS_SET_TYPE_IMM      0x22
#define INS_GET_DATUM         0x23
#define INS_SET_DATUM_IMM     0x24
#define INS_GET_GC            0x25
#define INS_SET_GC            0x26
#define INS_SET_GC_IMM        0x27
#define INS_CPY               0x28

#define INS_CMP_TYPE          0x29
#define INS_CMP_TYPE_IMM      0x2A
#define INS_CMP_DATUM         0x2B
#define INS_CMP_DATUM_IMM     0x2C
#define INS_CMP_GC            0x2D
#define INS_CMP_GC_IMM        0x2E
#define INS_CMP               0x2F

#define OP_0R 0
#define OP_1R 1
#define OP_2R 2
#define OP_BR 3

#define FORMAT_OPC "%s"
#define FORMAT_REG "%s"
#define FORMAT_IMM "(0x%X)"

#define FORMAT_IBR FORMAT_OPC" "FORMAT_REG" fmask"FORMAT_IMM" fval"FORMAT_IMM" addr"FORMAT_IMM
#define FORMAT_I2R FORMAT_OPC" "FORMAT_REG" "FORMAT_REG" "FORMAT_IMM""
#define FORMAT_I1R FORMAT_OPC" "FORMAT_REG" "FORMAT_IMM""
#define FORMAT_I0R FORMAT_OPC" "FORMAT_IMM""


#define REG_INSTR(opcode,_format,_func)				\
	do {							\
		instructions[INS_##opcode].format=_format;	\
		instructions[INS_##opcode].func=_func;		\
		instructions[INS_##opcode].name=#opcode; }	\
	while (0)


typedef struct {
	int pointer;
	int addr;
} instr_reg_t;

typedef struct {
	int op;
	instr_reg_t r1, r2;
	int imm;
	// for load/store:
	int disp;
	// for branch instructions:
	int flag_mask, flag_values, addr;
	// for flag manipulation instructions:
	int fnr, fmask, fimm;
	// for data movement and comparison operations:
	int immval;
} instr_t;

extern int print_instructions;

void instructions_init(void);
instr_t decode_instruction(uint64_t ins);
char* instruction_type(int i);
void print_instruction(reg_t addr);
void print_instruction_to_file(FILE *f, reg_t addr);
void do_instruction(reg_t addr);
void do_next_instruction(void);
reg_t next_instr_addr(void);
reg_t instr_get_reg(instr_reg_t r);
void instr_set_reg(instr_reg_t r, reg_t val);
#endif /* _INSTRUCTIONS_H_ */
