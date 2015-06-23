/*
 * File          : bintoxum.c
 * Project       : University of Utah, XUM Project
 * Creator(s)    : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   7-3-2012     GEA       Initial Design.
 *
 * Standards/Formatting:
 *   C, 8 hard tab, 80 column
 *
 * Description:
 *    Combines the text (instruction) and data sections of an
 *    executable into one file. You can think of this as a very
 *    simple version of ELF or a.out files.
 *
 *    The XUM processor has a simple flat physical address space
 *    which contains instructions and data. The output file from
 *    this utility is directly loadable into this memory, byte-for-byte,
 *    without using any kind of "intelligent" loader. It takes two
 *    binary input files, the instructions and data, and an offset
 *    address (decimal) for the data segment to begin, and outputs
 *    a file which can be sent directly to hardware via the XUM
 *    bootloader or other means.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void usage(void);
void read_file(char *name, int *size, char **buf);

int main(int argc, char **argv)
{
	FILE *file;
	char *it_name, *id_name, *o_name;
	int it_size, id_size;
	char *it_buf, *id_buf;
	int data_start_addr;
	int pad;
	int ch;

	while ((ch = getopt(argc, argv, "d:")) != -1) {
		switch (ch) {
			case 'd':
				data_start_addr = (int)strtol(optarg,
					(char **)NULL, 10);
				break;
			default:
				usage();
		}
	}

	argc -= optind;
	argv += optind;

	if (argc != 3) {
		usage();
	}

	it_name = argv[0];
	id_name = argv[1];
	o_name  = argv[2];

	read_file(it_name, &it_size, &it_buf);
	read_file(id_name, &id_size, &id_buf);

	/* Open the output file */
	file = fopen(o_name, "wb+");
	if (file == NULL) {
		fprintf(stderr, "Error: Could not open \"%s\" for "
			"writing.\n", o_name);
		exit(1);
	}
	
	/* Copy text segment directly to output file */
	if (fwrite((void *)it_buf, 1, it_size, file) != it_size) {
		fprintf(stderr, "Error writing to output file.\n");
		exit(1);
	}

	/* Pad until the data segment */
	it_buf[0] = 0;
	while (it_size < data_start_addr) {
		if (fwrite((void *)it_buf, 1, 1, file) != 1) {
			fprintf(stderr, "Error writing to output file.\n");
			exit(1);
		}
		it_size++;
	}

	/* Copy data segment to output file */
	if (fwrite((void *)id_buf, 1, id_size, file) != id_size) {
		fprintf(stderr, "Error writing to output file.\n");
		exit(1);
	}

	/* Pad the data section to word length if needed */
	/* NOTE: Assumes only padding needed would be at the end. */
	pad = ((id_size % 4) != 0) ? 4 - (id_size % 4) : 0;
	if (pad != 0) {
		memset((void *)id_buf, 0, 4);
		if (fwrite((void *)id_buf, 1, pad, file) != pad) {
			fprintf(stderr, "Error writing to output file.\n");
			exit(1);
		}
	}

	fclose(file);

	return 0;
}

void usage(void)
{
	fprintf(stderr, "Usage: bintoxum [-d data start address] "
		"<text file> <data file> <output file>\n");
	exit(1);
}

void read_file(char *name, int *size, char **buf)
{
	FILE *file;

	file = fopen(name, "rb");
	if (file == NULL) {
		fprintf(stderr, "Error: Could not open \"%s\".\n", name);
		exit(1);
	}
	fseek(file, 0L, SEEK_END);
	*size = (int)ftell(file);
	if ((*size < 0) || (ftell(file) > (long)*size)) {
		fprintf(stderr, "Error: Input file is too large.\n");
		exit(1);
	}
	fseek(file, 0L, SEEK_SET);
	*buf = (char *)malloc(*size);
	if (*buf == NULL) {
		fprintf(stderr, "Error: Could not allocate %d bytes "
			"of memory.\n", *size);
		exit(1);
	}
	if (fread(*buf, 1, *size, file) != *size) {
		fprintf(stderr, "Error reading input file.\n");
		exit(1);
	}
	fclose(file);
}
