#include <stdio.h>
#include <err.h>
#include <string.h>
#include <errno.h>

#include "types.h"
#include "object.h"
#include "memory.h"
#include "debug.h"

#define LINE_LEN 64

int memtool_size = 0;
int memtool_start = 0;

void
memory_load_from_file_s(char *memfile)
{
	char line[LINE_LEN];
	char cmd[LINE_LEN];
	char *args;
	FILE *f;
	int linenr, i, c, addr, intarg, addrarg, store_obj;
	reg_t obj = 0;

	addr = 0;

	f = fopen(memfile, "r");
	if (f == NULL)
		errx(1, "could not open memory file %s for reading: %s",
		     memfile, strerror(errno));

	for (linenr = 1; !feof(f); linenr++) {
		for (i = 0, c = fgetc(f);
		     i < LINE_LEN-1 && c != '\n' && c != EOF;
		     i++, c = fgetc(f))
			line[i] = c;
		if (c == EOF)
			break;
		line[i] = '\0';
		while (c != '\n' && c != EOF)
			c = fgetc(f);

		if (line[0] == '#' || i == 0)
			continue;

		for (i = 0; i < LINE_LEN-2 && line[i] != ' '; i++)
			cmd[i] = line[i];
		cmd[i] = '\0';
		args = &line[i+1];

		sscanf(args, "%X", &intarg);
		addrarg = intarg;
		if (args[0]=='+' || args[0]=='-')
			addrarg += addr;

		store_obj = 1;
		if (strcmp(cmd, "addr")==0) {
			addr = intarg;
			store_obj = 0;
		} else if (strcmp(cmd, "size")==0) {
			memtool_size = intarg;
			store_obj = 0;
		} else if (strcmp(cmd, "start")==0) {
			memtool_start = intarg;
			store_obj = 0;
		} else if (strcmp(cmd, "nil")==0) {
			obj = object_make(TYPE_NIL, 0);
		} else if (strcmp(cmd, "t")==0) {
			obj = object_make(TYPE_T, 0);
		} else if (strcmp(cmd, "int")==0) {
			obj = object_make(TYPE_INT, intarg);
		} else if (strcmp(cmd, "char")==0) {
			obj = object_make(TYPE_CHAR, intarg);
		} else if (strcmp(cmd, "array")==0) {
			obj = object_make(TYPE_ARRAY, intarg);
		} else if (strcmp(cmd, "ptr")==0) {
			obj = object_make(TYPE_PTR, addrarg);
		} else if (strcmp(cmd, "symbol")==0) {
			obj = object_make(TYPE_SYMBOL, addrarg);
		} else if (strcmp(cmd, "builtin")==0) {
			obj = object_make(TYPE_BUILTIN, addrarg);
		} else if (strcmp(cmd, "cons")==0) {
			obj = object_make(TYPE_CONS, addrarg);
		} else if (strcmp(cmd, "snoc")==0) {
			obj = object_make(TYPE_SNOC, addrarg);
		} else if (strcmp(cmd, "none")==0) {
			obj = object_make(TYPE_NONE, intarg);
		} else {
			warnx("I don't know what %s is", cmd);
			store_obj = 0;
		}

		if (store_obj) {
			if (object_get_type(memory_get(addr)) != TYPE_NONE)
				errx(1, "overwriting memory at address 0x%07X", addr);
			if ((memtool_size>0 && addr >= memtool_size+memtool_start) ||
			    (memtool_start>0 && addr < memtool_start))
				errx(1, "storing at address 0x%07X, which is outside "
				     "used region 0x%07X-0x%07X",
				     addr, memtool_start, memtool_size+memtool_start);
			memory_set(addr++, obj);
		}
	}
}

int
memory_used_amount(void)
{
	int i;
	for (i = memory_size()-1; i >= 0; i--) {
		if (memory_get(i))
			return i+1;
	}
	return 0;
}

void
create_memory_file(char *infile, char *outfile)
{
	int size;
	memory_init(DEFAULT_MEMORY_SIZE, NULL);
	memory_load_from_file_s(infile);
	size = memtool_size>0 ? memtool_size : (memory_used_amount()-memtool_start);
	memory_write_part_to_file(outfile, memtool_start, size);
}

extern int verify_written_memory;

int
main(int argc, char **argv)
{
	if (argc < 3) {
		fprintf(stderr,
			"usage: %s INFILE OUTFILE\n"
			"Translates textual description of memory in INFILE to\n"
			"binary representation of memory (suitable for loading\n"
			"into the emulator) in OUTFILE\n",
			argv[0]);
		return 1;
	}

	verify_written_memory = 0;
	debuginfo = NULL;
	create_memory_file(argv[1], argv[2]);
	return 0;
}

