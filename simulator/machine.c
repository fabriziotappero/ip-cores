#include <stdio.h>
#include <err.h>

#include "memory.h"
#include "regs.h"
#include "instructions.h"
#include "microcode.h"
#include "object.h"
#include "breakpoint.h"
#include "print.h"
#include "machine.h"
#include "profiler.h"

static int running = 0;

void
machine_init(char *microcodepath, char *memorypath, unsigned int availmem, char *regpath, int cache_size)
{
	if (!memory_init(availmem, memorypath))
		err(1, "Unable to allocate memory");
	if (!microcode_init(microcodepath))
		err(1, "Unable to initialize microcode");
	instructions_init();
	regs_init(regpath);
	breakpoint_init();
	print_init();
}

void
machine_shutdown(void)
{
#if 0
	reg_t r;
	int i;
#endif

	running = 0;

	printf("Machine halted.\n\n");

#if 0
	printf("Lowest part of memory:\n");
	for (i = 0; i < 32; i++) {
		r = memory_get(i);
		printf("\t0x%07X ", i);
		object_dump(r);
	}

	printf("Lowest part of skratch:\n");
	for (i = 0; i < 32; i++) {
		r = reg_get(i);
		printf("\t0x%07X ", i);
		object_dump(r);
	}
#endif

	printf("Status flags:\n");
	printf("\tOCNZTI\n");
	printf("\t%d%d%d%d%d%d\n",
	       get_status_flag(ST_O),
	       get_status_flag(ST_C),
	       get_status_flag(ST_N),
	       get_status_flag(ST_Z),
	       get_status_flag(ST_T),
	       get_status_flag(ST_I));
}

void
machine_shutup(void)
{
	reg_set(REG_ST, 0);
	reg_set(REG_PC, 0);
	running = 1;
}

int
machine_up(void)
{
	return running;
}

