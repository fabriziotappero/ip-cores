/*
 * File          : bintohex.c
 * Project       : University of Utah, XUM Project
 * Creator(s)    : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   4-1-2011     GEA       Initial design.
 *
 * Standards/Formatting:
 *   C, 8 hard tab, 80 column
 *
 * Description:
 *   Converts binary data into human-readable hex data.
 *   This is useful for FPGA block RAM initialization data,
 *   which is typically read in from a file in hex format.
 *   For block RAM cores, a .COE file is required, which is
 *   basically a hex file with some additional syntax. This
 *   utility will output in either format and can pad with
 *   zeros to a certain length.
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>


void usage(void);
unsigned int doEndian(unsigned int val, int bigEndian);

int main(int argc, char **argv)
{
	FILE *file;
	char *i_name, *o_name;
	int  i_size;
	unsigned int *input;
	unsigned int data = 0;
	int  pad_length = 0;
	int  endian = -1;
	int  coe = 0;
	int  ch, i;

	while ((ch = getopt(argc, argv, "chbp:")) != -1)
	{
		switch (ch)
		{
			case 'c':
				coe = 1;
				break;
			case 'h':
				usage();
				break;
			case 'b':
				endian = 1;
				break;
			case 'p':
				pad_length = (int)strtol(optarg, 
					(char **)NULL, 10);
				break;
			default:
				usage();
		}
	}

	argc -= optind;
	argv += optind;

	if (argc != 2)
	{
		usage();
	}

	i_name = argv[0];
	o_name = argv[1];

	
	/* Read the input file */
	file = fopen(i_name, "rb");
	if (file == NULL) {
		fprintf(stderr, "Error: Could not open \"%s\".\n", i_name);
		exit(1);
	}
	fseek(file, 0L, SEEK_END);
	i_size = (int)ftell(file);
	if ((i_size < 0) || (ftell(file) > (long)i_size)) {
		fprintf(stderr, "Error: Input file is too large.\n");
		exit(1);
	}
	fseek(file, 0L, SEEK_SET);
	input = (unsigned int*)malloc(i_size);
	if (input == NULL) {
		fprintf(stderr, "Error: Could not allocate %d bytes of "
			"memory.\n", i_size);
		exit(1);
	}
	if (fread(input, 1, i_size, file) != i_size) {
		fprintf(stderr, "Error reading input file.\n");
		exit(1);
	}
	fclose(file);

	/* Write the output file */
	file = fopen(o_name, "wb+");
	if (file == NULL) {
		fprintf(stderr, "Error: Could not open \"%s\" for "
			"writing.\n", o_name);
		exit(1);
	}
	if (coe) {
		fprintf(file, "memory_initialization_radix=16;\n"
			"memory_initialization_vector=\n");
	}
	for (i=0; i<(i_size/4); i++) {
		if (i != 0) {
			if (coe) {
				fprintf(file, ",\n");
			}
			else {
				fprintf(file, "\n");
			}
		}
		fprintf(file, "%08x", doEndian(input[i], endian));
	}
	if (coe) {
		fprintf(file, ";\n");
	}
	else {
		fprintf(file, "\n");
	}
	for (i=((i_size/4)*4); i<(i_size); i++) {
		if (endian < 0) {
			data <<= 8;
			data |= (0x000000FF & ((char*)input)[i]);
		}
		else {
			data >>= 8;
			data |= (0xFF000000 & (((char*)input)[i] << 24));
		}
	}
	if ((i_size%4) != 0) {
		if (coe) {
			fprintf(file, "%08x;\n", data);
		}
		else {
			fprintf(file, "%08x\n", data);
		}
	}
	
	/* Pad the output for non-COE files */
	if ((pad_length > 0) && !coe) {
		ch = (i_size/4) + (((i_size%4) != 0) ? 1 : 0);
		for (i=ch; i<pad_length; i++) {
			fprintf(file, "00000000\n");
		}
	}

	fclose(file);

	return 0;
}

void usage(void)
{
	printf("Usage: bintohex [-p <pad length>] [-b (Big Endian)] "
		"[-c (Make COE file)] <input> <output>\n");
	exit(1);
}

unsigned int doEndian(unsigned int val, int bigEndian)
{
	if (bigEndian == 1) {
		return (((val >> 24)&0xff) | ((val<<8)&0xff0000) |
			((val>>8)&0xff00) | ((val<<24)&0xff000000));
	}
	else {
		return val;
	}
}

