#include <assert.h>
#include <stdio.h>
#include <err.h>
#include <errno.h>
#include <string.h>

#include "types.h"
#include "object.h"
#include "regs.h"

reg_t registers[N_REGS];
char status_flags[8] = { 'O', 'C', 'N', 'Z', 'B', 'U', 'U', 'U' };

void regs_load_from_file(char *regfile);

void
regs_init(char *regfile)
{
	int i;
	for (i = 0; i < N_REGS; i++)
		registers[i] = 0;
	if (regfile != NULL)
		regs_load_from_file(regfile);
}

void
regs_load_from_file(char *regfile)
{
	FILE *f = fopen(regfile, "r");
	if (f == NULL)
		errx(1, "could not open register file %s: %s",
		     regfile, strerror(errno));

	if (!object_read(registers, N_REGS, f))
		errx(1, "error reading register file %s: %s",
		     regfile, strerror(errno));

	printf("0x%X register objects read from %s\n",
	       N_REGS, regfile);

	fclose(f);
}

void
reg_set(int reg, reg_t value)
{
	assert(reg >= 0 && reg < N_REGS);
	registers[reg] = value;
}

reg_t
reg_get(int reg)
{
	assert(reg >= 0 && reg < N_REGS);
	return registers[reg];
}


void
reg_dump(void)
{
	printf("Dumping registers:\n");
	for (int i = 0; i < N_REGS; i++) {
		printf("\tr%d: ", i);
		object_dump(registers[i]);
	}
}


int
get_status_flag(int flag)
{
	return (reg_get(REG_ST) >> flag) & 0x1;
}

void
set_status_flag(int flag, int value)
{
	reg_t stval;
	if (value != 0 && value != 1)
		errx(1, "Tried to set status flag %d to %d\n", flag, value);
	stval = reg_get(REG_ST);
	if (value)
		stval |= 1<<flag;
	else
		stval &= ~(1<<flag);
	reg_set(REG_ST, stval);
}

int
get_all_status_flags(void)
{
	return object_get_datum(reg_get(REG_ST));
}

int
get_flags(uint16_t mask)
{
	uint16_t masked_flags;
	masked_flags = mask & OBJECT_DATUM(reg_get(REG_ST));
	printf("get_flags: mask=%X, masked_flags=%X\n", mask, masked_flags);
	return (masked_flags != 0 ? 1 : 0);
}


