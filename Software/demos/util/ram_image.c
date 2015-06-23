/*
 * File          : ram_image.c
 * Project       : University of Utah, XUM Project
 * Creator(s)    : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   7-8-2011     GEA       Initial design.
 *
 * Standards/Formatting:
 *   C, 8 hard tab, 80 column
 *
 * Description:
 *   Fills a specific type of Verilog file which contains a
 *   Block RAM primitive with the initialization vectors from
 *   'code.txt' and outputs 'imem_filled.v'.
 *
 *   This utility is useful for filling simple and small block
 *   RAMs, especially for basic simulations. However it is no
 *   longer used for the production XUM project.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void quit(int val);
int  inject(char* vectors, char* output);

FILE* verilog;
FILE* vectors;
FILE* output;
char* out_buf = NULL;
char* vec_buf = NULL;

int main(int argc, char* argv[])
{
	int verilog_size, vectors_size;
	int inst_written;


	if (argc < 4)
	{
		fprintf(stderr, "Usage: %s: <in.v> <in_code.txt> <out.v>\n", argv[0]);
		fprintf(stderr, "Usage: %s: ram_xilinx.v code.txt ram_image.v\n", argv[0]);
		quit(1);
	}

	/* Open the Verilog source file and copy it into a buffer */
	verilog = fopen(argv[1], "rb");
	if (!verilog)
	{
		fprintf(stderr, "Could not open \"%s\".\n", argv[1]);
		quit(1);
	}
	fseek(verilog, 0L, SEEK_END);
	verilog_size = ftell(verilog);
	fseek(verilog, 0L, SEEK_SET);
	if (verilog_size == 0)
	{
		fprintf(stderr, "Error: Empty verilog input file.\n");
		quit(1);
	}
	out_buf = malloc(verilog_size);
	if (!out_buf)
	{
		fprintf(stderr, "Error allocating memory.\n");
		quit(1);
	}	
	if (fread(out_buf, 1, verilog_size, verilog) != verilog_size)
	{
		fprintf(stderr, "Error reading input file.\n");
		quit(1);
	}


	/* Open code vectors and copy them into a buffer */
	vectors = fopen(argv[2], "rb");
	if (!vectors)
	{
		fprintf(stderr, "Could not open \"%s\".\n", argv[2]);
		quit(1);
	}
	fseek(vectors, 0L, SEEK_END);
	vectors_size = ftell(vectors);
	fseek(vectors, 0L, SEEK_SET);
	if (vectors_size == 0)
	{
		fprintf(stderr, "Error: Empty vectors file.\n");
		quit(1);
	}
	//printf("Vectors size is %d bytes.\n", vectors_size);
	vec_buf = malloc(vectors_size+1);
	if (!vec_buf)
	{
		fprintf(stderr, "Error allocating memory.\n");
		quit(1);
	}
	if (fread(vec_buf, 1, vectors_size, vectors) != vectors_size)
	{
		fprintf(stderr, "Error reading vectors file.\n");
		quit(1);
	}
	vec_buf[vectors_size] = '\0';

	/* Inject code */
	inst_written = inject(vec_buf, out_buf);
	printf("Wrote %d instructions.\n", inst_written);

	/* Write output file */
	output = fopen(argv[3], "wb");
	if (output == NULL)
	{
		fprintf(stderr, "Error writing %s!\n", argv[3]);
		quit(1);
	}
	fwrite(out_buf, 1, verilog_size, output);
	fclose(output);

	
	// Exit
	quit(0);
	return 0;
}


int inject(char* vectors, char* output)
{
	const char* delimeters = " \t\r\n";
	char  row_key[15];  // ".INIT_XX(256'h"
	char* token;
	char* position;
	int   row = 0;
	int   col = 7;
	int   total = 0;

	token = strtok(vectors, delimeters);
	snprintf(row_key, 14, ".INIT_%02X(256'h", row);
	while ((token != NULL) && (row < 128))
	{
		//printf("Got a token: \"%s\"\n", token);
		if (strlen(token) != 8)
		{
			fprintf(stderr, "Error: Vector \"%s\" is not "
				"a 32-bit hexadecimal number.\n", token);
			quit(1);
		}
		position = strstr(output, row_key);
		if (position == NULL)
		{
			fprintf(stderr, "Error: Could not find initialization "
				"row %02X (hex) in the Block RAM. Check that "
				"it has sufficient memory.\n", row);
			printf("\n\n\nDEBUG\n%s\n", output);
			quit(1);
		}
		//position += (14 + col + (8 * col));
		position += (14 + (8 * col));
		memcpy(position, token, 8);
		total++;
		col--;
		if (col < 0)
		{
			col = 7;
			row++;
			snprintf(row_key, 14, ".INIT_%02X(256'h", row);
		}
		//printf("Col is %d row is %d\n", col, row);
		token = strtok(NULL, delimeters);
	}
	return total;
}


void quit(int val)
{
	if (verilog) {
		fclose(verilog);
	}
	if (vectors) {
		fclose(vectors);
	}
	if (output) {
		fclose(output);
	}
	if (out_buf) {
		free(out_buf);
	}
	if (vec_buf) {
		free(vec_buf);
	}

	if (val != 0) {
		exit(val);
	}
}
	
