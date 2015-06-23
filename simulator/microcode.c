#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <err.h>

#include "types.h"
#include "microcode.h"

#define INSTR_SZ 6 // byte

static int microcodefd;
static uint8_t *microcodebuffer;
static size_t microcodesize;

int
microcode_init(const char *path)
{
	int fd;
	struct stat sb;

	if ((fd = open(path, O_RDONLY)) == -1)
		return 0;

	if (fstat(fd, &sb) == -1) {
		close(fd);
		return 0;
	}
	
	microcodebuffer = mmap(NULL, sb.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
	if (microcodebuffer == MAP_FAILED) {
		close(fd);
		return 0;
	}
	microcodesize = sb.st_size;
	if ((microcodesize % INSTR_SZ) != 0) {
		close(fd);
		warnx("microcode size not dividable by INSTR_SZ (%d)", INSTR_SZ);
		return 0;
	}

	printf("Microcode size: %d\n", (int)microcodesize/INSTR_SZ);
	/*
	for (int i = 0; i < microcodesize/4; i++) {
		printf("inst: 0x%x\n", microcode_fetch_instr(i));
	}
	*/
	microcodefd = fd;

	return 1;
}

uint64_t
microcode_fetch_instr(reg_t place)
{
	int byteplace, i;
	uint64_t val;

	if (place < 0 || place >= (microcodesize/INSTR_SZ))
		errx(1, "Trying to access out of bounds microcode: 0x%x", place);
	byteplace = place*INSTR_SZ;
	//printf("place: %d, byteplace: %d\n", place, byteplace);

	val = 0;
	for (i = 0; i < INSTR_SZ; i++) {
		val = (val << 8) | (microcodebuffer[byteplace+i]&0xFF);
	}
	
	return val;
}

size_t
microcode_size(void)
{
	return microcodesize/INSTR_SZ;
}
