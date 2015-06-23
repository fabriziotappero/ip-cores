#ifndef _REGS_H_
#define _REGS_H_

#include "types.h"

#define N_SKRATCH_SZ 0x400
#define N_MAGIC_REGS 0x010
#define N_REGS ((N_SKRATCH_SZ)+(N_MAGIC_REGS))

extern reg_t registers[N_REGS];

// magical registers (outside skratch memory):
#define REG_SP ((N_SKRATCH_SZ)+0x0)
#define REG_PC ((N_SKRATCH_SZ)+0x1)
#define REG_ST ((N_SKRATCH_SZ)+0x2)

#define ST_O 0 // overflow
#define ST_C 1 // carry
#define ST_N 2 // negative
#define ST_Z 3 // zero
#define ST_T 4 // type error
#define ST_I 5 // I/O error

extern char status_flags[8];

void regs_init(char *regfile);

void reg_set(int reg, reg_t value);
reg_t reg_get(int reg);
void reg_dump(void);

int get_status_flag(int flag);
void set_status_flag(int flag, int value);
int get_flags(uint16_t mask);
int get_all_status_flags(void);

#endif /* _REGS_H_ */
