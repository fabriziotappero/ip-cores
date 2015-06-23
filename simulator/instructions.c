
#include <stdio.h>
#include <stdlib.h>
#include <err.h>

#include "regs.h"
#include "types.h"
#include "object.h"
#include "memory.h"
#include "microcode.h"
#include "machine.h"
#include "instructions.h"
#include "debug.h"
#include "bits.h"
#include "profiler.h"

typedef void (instr_f)(instr_t);

typedef struct {
	int format;
	instr_f *func;
	char *name;
} instr_spec_t;

instr_spec_t instructions[64];

int print_instructions = 0;

const char *
register_string(instr_reg_t r)
{
	struct di_const *c;
	static int regnum;
	int curreg;
	static char regs[12][128];

	c = debug_get1_filter(r.addr, "reg");

	if (c == NULL) {
		snprintf(regs[regnum], 128, "r%03X[%d]", r.addr, r.pointer);
	} else {
		snprintf(regs[regnum], 128, "%%%s(r%03X)[%d]", c->name, r.addr,
		    r.pointer);
	}
	curreg = regnum;

	regnum = (regnum+1)%12;

	return regs[curreg];
}

int
instr_reg(instr_reg_t r)
{
	if (r.pointer)
		return object_get_datum(reg_get(r.addr));
	return r.addr;
}

reg_t
instr_get_reg(instr_reg_t r)
{
	return reg_get(instr_reg(r));
}

void
instr_set_reg(instr_reg_t r, reg_t val)
{
	reg_set(instr_reg(r), val);
}

instr_reg_t
decode_instruction_reg(uint32_t r)
{
	instr_reg_t reg;
	reg.pointer = (r>>10) & 1;
	reg.addr = r & 0x3FF;
	return reg;
}

void
decode_instruction_imm(instr_t *instr)
{
	switch (instr->op) {
	case INS_LOAD:
	case INS_STORE:
		instr->disp = sign_extend(bitfield(instr->imm, 0, 17), 18);
		break;
	case INS_SET_FLAG:
	case INS_GET_FLAG:
		instr->fmask = bitfield(instr->imm, 0, 8);
		instr->fnr = bitfield(instr->imm, 9, 11);
		instr->fimm = bitfield(instr->imm, 12, 12);
		break;
	case INS_SET_TYPE_IMM:
	case INS_CMP_TYPE_IMM:
		instr->immval = bitfield(instr->imm, 0, 4);
		break;
	case INS_SET_DATUM_IMM:
	case INS_CMP_DATUM_IMM:
		instr->immval = sign_extend(instr->imm, 18);
		break;
	case INS_SET_GC_IMM:
	case INS_CMP_GC_IMM:
		instr->immval = bitfield(instr->imm, 0, 1);
		break;
	}
}

instr_t
decode_instruction(uint64_t raw_instr)
{
	instr_t instr = { };

	instr.op = bitfield(raw_instr, 42, 47);
	instr_spec_t instr_spec = instructions[instr.op];

	if (instr_spec.format < 0 || instr_spec.format > 3)
		errx(1, "Unknown instruction format: %d", instr_spec.format);

	if (instr_spec.format == OP_BR) {
		instr.r1 = decode_instruction_reg(bitfield(raw_instr, 29, 39));
		instr.flag_mask = bitfield(raw_instr, 21, 28);
		instr.flag_values = bitfield(raw_instr, 13, 20);
		instr.addr = sign_extend(bitfield(raw_instr, 0, 12), 13);
		return instr;
	}

	switch (instr_spec.format) {
	case OP_2R: instr.r2 = decode_instruction_reg(bitfield(raw_instr, 18, 28));
	case OP_1R: instr.r1 = decode_instruction_reg(bitfield(raw_instr, 29, 39));
	}

	instr.imm = bitfield(raw_instr, 0, 17);
	decode_instruction_imm(&instr);

	return instr;
}

char* instruction_type(int index)
{
	return instructions[index].name;
}

void
print_instruction(reg_t addr)
{
	print_instruction_to_file(stdout, addr);
}

void
print_instruction_to_file(FILE *f, reg_t addr)
{
	instr_t instr = decode_instruction(microcode_fetch_instr(addr));
	instr_spec_t instr_spec = instructions[instr.op];
	struct di_const *c;
	int i;

	c = debug_get1_filter(addr, "label");
	if (c != NULL)
		fprintf(f, "%s:", c->name);

	fprintf(f, "0x%04X ", addr);

	switch (instr_spec.format) {
	case OP_BR:
		//fprintf(f, "address: 0x%X\n", instr.addr);
		fprintf(f, FORMAT_IBR, instr_spec.name,
			register_string(instr.r1),
			instr.flag_mask, instr.flag_values,
			instr.addr);
		break;
	case OP_2R:
		fprintf(f, FORMAT_I2R, instr_spec.name,
			register_string(instr.r1),
			register_string(instr.r2),
			instr.imm);
		break;
	case OP_1R:
		fprintf(f, FORMAT_I1R, instr_spec.name,
			register_string(instr.r1),
			instr.imm);
		break;
	case OP_0R:
		fprintf(f, FORMAT_I0R, instr_spec.name,
			instr.imm);
		break;
	default:
		errx(1, "Unknown instruction format: %d", instr_spec.format);
	}

	switch (instr.op) {
	case INS_BRANCH:
	case INS_BRANCH_REG:
		fprintf(f, " [");
		for (i = 0; i < 8; i++) {
			if ((instr.flag_mask >> i) & 1)
				fprintf(f, " %s%c", ((instr.flag_values>>i)&1) ? "" : "!",
					status_flags[i]);
		}
		fprintf(f, "]");
		c = debug_get1_filter(instr.addr, "label");
		if (c != NULL)
			fprintf(f, " label: %s", c->name);
		fputs("\n", f);
		break;
	case INS_SET_TYPE_IMM:
		c = debug_get1_filter(instr.immval, "type");
		fprintf(f, " %s\n", c ? c->name : "unresolved");
		break;
	default:
		fputs("\n", f);
#if 0 // XXX: Pass file here as well
		if (instr.imm > 1)
			debug_show(instr.imm);
#endif
		break;
	}
}



void
i_nop(instr_t ins)
{
	// is this implementation correct?
}

void
i_halt(instr_t ins)
{
	machine_shutdown();
}

void
i_alu(instr_t ins)
{
	reg_t v1, v2;
	int a, b, res;

	v1 = instr_get_reg(ins.r1);
	v2 = instr_get_reg(ins.r2);

	//instr_spec_t instr_spec = instructions[ins.op];

	if (OBJECT_TYPE(v1) != OBJECT_TYPE(v2)) {
		// TODO set type error flag
		//warnx("ALU operation on two objects of different types");
		/*
		errx(1, "(%s) Can't operate on two objects of different types",
		     instr_spec.name);
		*/
	}
	if (OBJECT_TYPE(v1) != TYPE_INT) {
		//warnx("ALU operation on non-integer values");
		/*
		errx(1, "(%s) Can't operate on non-integer values",
		     instr_spec.name);
		*/
	}

	a = object_get_datum_signed(v1);
	b = object_get_datum_signed(v2);

	//printf("alu, a=%d, b=%d\n", a, b);

	switch (ins.op) {
	case INS_ADD:
		res = a+b;
		break;
	case INS_SUB:
		res = a-b;
		break;
	case INS_MUL:
		res = a*b;
		break;
	case INS_DIV:
		res = a/b;
		break;
	case INS_MOD:
		res = a%b;
		break;
	case INS_AND:
		res = a&b;
		break;
	case INS_OR:
		res = a|b;
		break;
	case INS_XOR:
		res = a^b;
		break;
	case INS_NOT:
		res = ~b;
		break;
	case INS_SHIFT_L:
		res = a << b;
		break;
	case INS_SHIFT_R:
		res = a >> b;
		break;
	default:
		errx(1, "this is not an ALU opcode: %d", ins.op);
	}

	//printf("alu, res=%d 0x%X\n", res, res);
	instr_set_reg(ins.r1, object_set_datum(v1, res));
	set_status_flag(ST_N, res<0);
	set_status_flag(ST_Z, res==0);
	set_status_flag(ST_O, res<-(1<<25) || res>=(1<<25));
}


void
i_load(instr_t ins)
{
	uint32_t addr = OBJECT_DATUM(instr_get_reg(ins.r2))+ins.disp;
	instr_set_reg(ins.r1, memory_get(addr));
}

void
i_store(instr_t ins)
{
	uint32_t addr = OBJECT_DATUM(instr_get_reg(ins.r2))+ins.disp;
	reg_t val = instr_get_reg(ins.r1);

	if (print_instructions) {
		printf("\tStoring (at 0x%07X): ", addr);
		object_dump(val);
	}
	memory_set(addr, val);
}



void
i_branch(instr_t ins)
{
	if ((ins.flag_mask & get_all_status_flags()) == ins.flag_values)
		reg_set(REG_PC, ins.addr);
}


void
i_branch_reg(instr_t ins)
{
	uint32_t addr = object_get_datum(instr_get_reg(ins.r1)) + ins.addr;
	if ((ins.flag_mask & get_all_status_flags()) == ins.flag_values)
		reg_set(REG_PC, addr);
}


void
i_set_flag(instr_t ins)
{
	printf("i_set_flag: fnr=%X, fmask=%X, fimm=%X, reg=%X\n",
	       ins.fnr, ins.fmask, ins.fimm, instr_get_reg(ins.r1));
	set_status_flag(ins.fnr,
			get_flags(ins.fmask)
			|| ins.fimm
			|| object_get_datum(instr_get_reg(ins.r1)));
}

void
i_clear_flag(instr_t ins)
{
	set_status_flag(ins.fnr, 0);
}

void
i_get_flag(instr_t ins)
{
	instr_set_reg(ins.r1, get_flags(ins.fmask));
}


void
i_get_type(instr_t ins)
{
	int type = OBJECT_TYPE(instr_get_reg(ins.r2));
	reg_t val = instr_get_reg(ins.r1);
	val = object_set_datum(val, type);
	val = object_set_type(val, TYPE_INT);
	instr_set_reg(ins.r1, val);
}

void
i_set_type(instr_t ins)
{
	//printf("SET-TYPE r%x <- %x\n", ins.r1, ins.imm);
	reg_t val = instr_get_reg(ins.r1);
	if (ins.op == INS_SET_TYPE_IMM) {
		val = object_set_type(val, ins.immval);
	} else {
		val = object_set_type(val, object_get_datum(instr_get_reg(ins.r2)));
	}
	instr_set_reg(ins.r1, val);
}

void
i_get_datum(instr_t ins)
{
	reg_t val1, val2;

	val1 = instr_get_reg(ins.r1);
	val2 = instr_get_reg(ins.r2);
	val1 = object_set_datum(val1, object_get_datum(val2));
	instr_set_reg(ins.r1, val1);
}

void
i_set_datum(instr_t ins)
{
	//printf("SET-DATUM r%x <- %x\n", ins.r1, ins.imm);

	reg_t val = instr_get_reg(ins.r1);
	instr_set_reg(ins.r1, object_set_datum(val, ins.immval));
}

void
i_get_gc(instr_t ins)
{
	reg_t val1, val2;
	val1 = instr_get_reg(ins.r1);
	val2 = instr_get_reg(ins.r2);
	val1 = object_set_datum(val1, object_get_gc(val2));
	instr_set_reg(ins.r1, val1);
}

void
i_set_gc(instr_t ins)
{
	reg_t val = instr_get_reg(ins.r1);
	if (ins.op == INS_SET_GC_IMM) {
		val = object_set_gc(val, ins.immval);
	} else {
		val = object_set_gc(val, object_get_datum(instr_get_reg(ins.r2)));
	}
	instr_set_reg(ins.r1, val);
}

void
i_cpy(instr_t ins)
{
	instr_set_reg(ins.r1, instr_get_reg(ins.r2));
}


void
i_cmp(instr_t ins)
{
	int diff = 0;
	switch (ins.op) {
	case INS_CMP_TYPE:
		diff = object_get_type(instr_get_reg(ins.r1))
			- object_get_type(instr_get_reg(ins.r2));
		break;
	case INS_CMP_TYPE_IMM:
		diff = object_get_type(instr_get_reg(ins.r1))
			- ins.immval;
		break;
	case INS_CMP_DATUM:
		diff = object_get_datum_signed(instr_get_reg(ins.r1))
			- object_get_datum_signed(instr_get_reg(ins.r2));
		break;
	case INS_CMP_DATUM_IMM:
		diff = object_get_datum_signed(instr_get_reg(ins.r1))
			- ins.immval;
		break;
	case INS_CMP_GC:
		diff = object_get_gc(instr_get_reg(ins.r1))
			- object_get_gc(instr_get_reg(ins.r2));
		break;
	case INS_CMP_GC_IMM:
		diff = object_get_gc(instr_get_reg(ins.r1))
			- ins.immval;
		break;
	case INS_CMP:
		// TODO fix
		if (object_get_type(instr_get_reg(ins.r1)) !=
		    object_get_type(instr_get_reg(ins.r2))) {
			//errx(1, "(CMP) Cannot compare two objects of different types");
			set_status_flag(ST_T, 1);
			return;
		}
		//if (object_get_type(instr_get_reg(ins.r1)) == TYPE_INT) {
		diff = object_get_datum_signed(instr_get_reg(ins.r1))
			- object_get_datum_signed(instr_get_reg(ins.r2));
		break;
	default:
		errx(1, "(i_cmp) Unknown comparison instruction %d",
		     ins.op);
	}

	//printf("compare, diff=%d\n", diff);

	set_status_flag(ST_T, 0);
	set_status_flag(ST_Z, diff==0);
	set_status_flag(ST_N, diff<0);
}


/*
void
i_check_type(instr_t ins)
{
	int reg = ins.r2;
	int type = ins.imm;

	set_status_flag(ST_B, OBJECT_TYPE(reg_get(reg)) == type);
}
*/

/*
void
i_push(instr_t ins)
{
	reg_set(REG_SP, reg_get(REG_SP)-1);
	memory_set(reg_get(REG_SP), reg_get(ins.r1));
}

void
i_pull(instr_t ins)
{
	reg_set(ins.r1, memory_get(reg_get(REG_SP)));
	reg_set(REG_SP, reg_get(REG_SP)+1);
}
*/

void
instructions_init(void)
{
	REG_INSTR(NOP, OP_2R, i_nop);
	REG_INSTR(HALT, OP_2R, i_halt);

	REG_INSTR(ADD, OP_2R, i_alu);
	REG_INSTR(SUB, OP_2R, i_alu);
	REG_INSTR(MUL, OP_2R, i_alu);
	REG_INSTR(DIV, OP_2R, i_alu);
	REG_INSTR(AND, OP_2R, i_alu);
	REG_INSTR(OR,  OP_2R, i_alu);
	REG_INSTR(XOR, OP_2R, i_alu);
	REG_INSTR(NOT, OP_2R, i_alu);
	REG_INSTR(SHIFT_L, OP_2R, i_alu);
	REG_INSTR(MOD, OP_2R, i_alu);
	REG_INSTR(SHIFT_R, OP_2R, i_alu);

	REG_INSTR(LOAD, OP_2R, i_load);
	REG_INSTR(STORE, OP_2R, i_store);

	REG_INSTR(BRANCH, OP_BR, i_branch);
	REG_INSTR(BRANCH_REG, OP_BR, i_branch_reg);

	REG_INSTR(GET_FLAG, OP_1R, i_get_flag);
	REG_INSTR(CLEAR_FLAG, OP_0R, i_clear_flag);
	REG_INSTR(SET_FLAG, OP_1R, i_set_flag);

	REG_INSTR(GET_TYPE, OP_2R, i_get_type);
	REG_INSTR(SET_TYPE, OP_2R, i_set_type);
	REG_INSTR(SET_TYPE_IMM, OP_1R, i_set_type);
	REG_INSTR(GET_DATUM, OP_2R, i_get_datum);
	REG_INSTR(SET_DATUM_IMM, OP_1R, i_set_datum);
	REG_INSTR(GET_GC, OP_2R, i_get_gc);
	REG_INSTR(SET_GC, OP_2R, i_set_gc);
	REG_INSTR(SET_GC_IMM, OP_1R, i_set_gc);
	REG_INSTR(CPY, OP_2R, i_cpy);

	REG_INSTR(CMP_TYPE, OP_2R, i_cmp);
	REG_INSTR(CMP_TYPE_IMM, OP_1R, i_cmp);
	REG_INSTR(CMP_DATUM, OP_2R, i_cmp);
	REG_INSTR(CMP_DATUM_IMM, OP_1R, i_cmp);
	REG_INSTR(CMP_GC, OP_2R, i_cmp);
	REG_INSTR(CMP_GC_IMM, OP_1R, i_cmp);
	REG_INSTR(CMP, OP_2R, i_cmp);
}


void
execute_instruction(instr_t ins)
{
	//printf("Looking for opcode: %d\n", ins.op);
	instructions[ins.op].func(ins);
}

void
set_instruction_printing(int s)
{
	print_instructions = s;
}

void
do_instruction(reg_t addr)
{
	instr_t instr;
	if (print_instructions)
		print_instruction(addr);
	instr = decode_instruction(microcode_fetch_instr(addr));
	execute_instruction(instr);
	profiler_add_execution(addr, instr, get_all_status_flags());
}

void
do_next_instruction(void)
{
	reg_t pc;

	if (!machine_up())
		errx(1, "(do_next_instruction) cannot do that: machine down\n");

	pc = reg_get(REG_PC);
	reg_set(REG_PC, pc+1);
	do_instruction(pc);
}

reg_t
next_instr_addr(void)
{
	return reg_get(REG_PC);
}

