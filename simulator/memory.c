#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <string.h>
#include <errno.h>

#include "memory.h"

#include "types.h"
#include "regs.h"
#include "io.h"
#include "object.h"

static reg_t *memorybuf;
static unsigned int memorysize;
static char *memoryused;
int verify_written_memory;

int
memory_init(unsigned int memsz, char *memfile)
{
	printf("Allocating memory: 0x%X\n", memsz);
	memorybuf = calloc(memsz, sizeof(reg_t));
	if (memorybuf == NULL)
		return 0;
	memorysize = memsz;
	reg_set(REG_SP, memorysize);
	if (memfile != NULL)
		memory_load_from_file(memfile);
	memoryused = malloc(memsz);
	if (memoryused == NULL)
		err(1, "malloc(memoryused)");
	memset(memoryused, '\0', memsz);

	return 1;
}

void
memory_load_from_file(char *memfile)
{
	int i;
	FILE *f = fopen(memfile, "r");
	if (f == NULL)
		errx(1, "could not open memory file %s: %s",
		     memfile, strerror(errno));

	i = object_read(memorybuf, memorysize, f);

	if (ferror(f)) {
		err(1, "error reading memory file %s", memfile);
	}

	printf("0x%X memory objects read from %s\n",
	       i, memfile);

	fclose(f);
}

void
memory_write_to_file(char *memfile)
{
	memory_write_part_to_file(memfile, 0, memorysize);
}

void
memory_write_part_to_file(char *memfile, int start, int length)
{
	FILE *f = fopen(memfile, "w");
	if (f == NULL)
		errx(1, "could not open memory file %s for writing: %s",
		     memfile, strerror(errno));

	if (object_write(&memorybuf[start], length, f) < length)
		err(1, "error writing memory file %s", memfile);

	fclose(f);
}


void
memory_set(unsigned int pos, reg_t value)
{
	if ((pos & IO_AREA_MASK) == IO_AREA_MASK) {
		io_memory_set(pos & ~IO_AREA_MASK, value);
		return;
	}
	if (pos < 0 || pos >= memorysize)
		errx(1, "Trying to store outside of memory region: 0x%X", pos);
	memorybuf[pos] = value;
	memoryused[pos] = 1;
}

reg_t
memory_get(unsigned int pos)
{
	if ((pos & IO_AREA_MASK) == IO_AREA_MASK) {
		return io_memory_get(pos & ~IO_AREA_MASK);
	}
	if (pos < 0 || pos >= memorysize)
		errx(1, "Trying to load outside of memory region: 0x%X", pos);
	if (memoryused[pos] == 0 && verify_written_memory == 1)
		warnx("Reading from unwritten memory position: 0x%X", pos);

	return memorybuf[pos];
}

int
memory_size(void)
{
	return memorysize;
}
