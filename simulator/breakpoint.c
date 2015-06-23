#include <stdio.h>

#include "breakpoint.h"
#include "instructions.h"
#include "microcode.h"

int breakpoints[MICROCODE_MAX_SIZE];

void
breakpoint_init(void)
{
	int i;
	for (i = 0; i < MICROCODE_MAX_SIZE; i++) {
		breakpoints[i] = 0;
	}
}

void
breakpoint_list(void)
{
	int i, num;
	printf("breakpoints:\n");
	for (i = 0, num = 0; i < MICROCODE_MAX_SIZE; i++) {
		if (breakpoints[i]) {
			num++;
			print_instruction(i);
		}
	}
	printf("%d breakpoints\n", num);
}

void
breakpoint_set(reg_t addr)
{
	breakpoints[addr] = 1;
}

void
breakpoint_del(reg_t addr)
{
	breakpoints[addr] = 0;
}

int
breakpoint_at(reg_t addr)
{
	return breakpoints[addr];
}
