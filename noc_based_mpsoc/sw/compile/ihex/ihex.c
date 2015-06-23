/* Intel HEX read/write functions, Paul Stoffregen, paul@ece.orst.edu */
/* This code is in the public domain.  Please retain my name and */
/* email address in distributed copies, and let me know about any bugs */

/* I, Paul Stoffregen, give no warranty, expressed or implied for */
/* this software and/or documentation provided, including, without */
/* limitation, warranty of merchantability and fitness for a */
/* particular purpose. */


#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* some ansi prototypes.. maybe ought to make a .h file */

/* this loads an intel hex file into the memory[] array */
void load_file(char *filename);

/* this writes a part of memory[] to an intel hex file */
void save_file(char *command);

/* this is used by load_file to get each line of intex hex */
int parse_hex_line(char *theline, int bytes[], int *addr, int *num, int *code);

/* this does the dirty work of writing an intel hex file */
/* caution, static buffering is used, so it is necessary */
/* to call it with end=1 when finsihed to flush the buffer */
/* and close the file */
void hexout(FILE *fhex, int byte, int memory_location, int end);


extern int	memory[65536];		/* the memory is global */

/* parses a line of intel hex code, stores the data in bytes[] */
/* and the beginning address in addr, and returns a 1 if the */
/* line was valid, or a 0 if an error occured.  The variable */
/* num gets the number of bytes that were stored into bytes[] */

int parse_hex_line(theline, bytes, addr, num, code)
char *theline;
int *addr, *num, *code, bytes[];
{
	int sum, len, cksum;
	char *ptr;
	
	*num = 0;
	if (theline[0] != ':') return 0;
	if (strlen(theline) < 11) return 0;
	ptr = theline+1;
	if (!sscanf(ptr, "%02x", &len)) return 0;
	ptr += 2;
	if ( strlen(theline) < (11 + (len * 2)) ) return 0;
	if (!sscanf(ptr, "%04x", addr)) return 0;
	ptr += 4;
	  /* printf("Line: length=%d Addr=%d\n", len, *addr); */
	if (!sscanf(ptr, "%02x", code)) return 0;
	ptr += 2;
	sum = (len & 255) + ((*addr >> 8) & 255) + (*addr & 255) + (*code & 255);
	while(*num != len) {
		if (!sscanf(ptr, "%02x", &bytes[*num])) return 0;
		ptr += 2;
		sum += bytes[*num] & 255;
		(*num)++;
		if (*num >= 256) return 0;
	}
	if (!sscanf(ptr, "%02x", &cksum)) return 0;
	if ( ((sum & 255) + (cksum & 255)) & 255 ) return 0; /* checksum error */
	return 1;
}

/* loads an intel hex file into the global memory[] array */
/* filename is a string of the file to be opened */

void load_file(filename)
char *filename;
{
	char line[1000];
	FILE *fin;
	int addr, n, status, bytes[256];
	int i, total=0, lineno=1;
	int minaddr=65536, maxaddr=0;

	if (strlen(filename) == 0) {
		printf("   Can't load a file without the filename.");
		printf("  '?' for help\n");
		return;
	}
	fin = fopen(filename, "r");
	if (fin == NULL) {
		printf("   Can't open file '%s' for reading.\n", filename);
		//return;
		exit(1);
	}
	while (!feof(fin) && !ferror(fin)) {
		line[0] = '\0';
		fgets(line, 1000, fin);
		if (line[strlen(line)-1] == '\n') line[strlen(line)-1] = '\0';
		if (line[strlen(line)-1] == '\r') line[strlen(line)-1] = '\0';
		if (parse_hex_line(line, bytes, &addr, &n, &status)) {
			if (status == 0) {  /* data */
				for(i=0; i<=(n-1); i++) {
					memory[addr] = bytes[i] & 255;
					total++;
					if (addr < minaddr) minaddr = addr;
					if (addr > maxaddr) maxaddr = addr;
					addr++;
				}
			}
			if (status == 1) {  /* end of file */
				fclose(fin);
				printf("   Loaded %d bytes between:", total);
				printf(" %04X to %04X\n", minaddr, maxaddr);
				return;
			}
			if (status == 2) ;  /* begin of file */
		} else {
			printf("   Error: '%s', line: %d\n", filename, lineno);
		}
		lineno++;
	}
}


/* the command string format is "S begin end filename" where */
/* "begin" and "end" are the locations to dump to the intel */
/* hex file, specified in hexidecimal. */

void save_file(command)
char *command;
{
	int begin, end, addr;
	char *ptr, filename[200];
	FILE *fhex;

	ptr = command+1;
	while (isspace(*ptr)) ptr++;
	if (*ptr == '\0') {
		printf("   Must specify address range and filename\n");
		return;
		}
	if (sscanf(ptr, "%x%x%s", &begin, &end, filename) < 3) {
		printf("   Invalid addresses or filename,\n");
		printf("    usage: S begin_addr end_addr filename\n");
		printf("    the addresses must be hexidecimal format\n");
		return;
	}
	begin &= 65535;
	end &= 65535;
	if (begin > end) {
		printf("   Begin address must be less than end address.\n");
		return;
	}
	fhex = fopen(filename, "w");
	if (fhex == NULL) {
		printf("   Can't open '%s' for writing.\n", filename);
		return;
	}
	for (addr=begin; addr <= end; addr++)
		hexout(fhex, memory[addr], addr, 0);
	hexout(fhex, 0, 0, 1);
	printf("Memory %04X to %04X written to '%s'\n", begin, end, filename);
}


/* produce intel hex file output... call this routine with */
/* each byte to output and it's memory location.  The file */
/* pointer fhex must have been opened for writing.  After */
/* all data is written, call with end=1 (normally set to 0) */
/* so it will flush the data from its static buffer */

#define MAXHEXLINE 32	/* the maximum number of bytes to put in one line */

void hexout(fhex, byte, memory_location, end)
FILE *fhex;  /* the file to put intel hex into */
int byte, memory_location, end;
{
	static int byte_buffer[MAXHEXLINE];
	static int last_mem, buffer_pos, buffer_addr;
	static int writing_in_progress=0;
	register int i, sum;

	if (!writing_in_progress) {
		/* initial condition setup */
		last_mem = memory_location-1;
		buffer_pos = 0;
		buffer_addr = memory_location;
		writing_in_progress = 1;
		}

	if ( (memory_location != (last_mem+1)) || (buffer_pos >= MAXHEXLINE) \
	 || ((end) && (buffer_pos > 0)) ) {
		/* it's time to dump the buffer to a line in the file */
		fprintf(fhex, ":%02X%04X00", buffer_pos, buffer_addr);
		sum = buffer_pos + ((buffer_addr>>8)&255) + (buffer_addr&255);
		for (i=0; i < buffer_pos; i++) {
			fprintf(fhex, "%02X", byte_buffer[i]&255);
			sum += byte_buffer[i]&255;
		}
		fprintf(fhex, "%02X\n", (-sum)&255);
		buffer_addr = memory_location;
		buffer_pos = 0;
	}

	if (end) {
		fprintf(fhex, ":00000001FF\n");  /* end of file marker */
		fclose(fhex);
		writing_in_progress = 0;
	}
		
	last_mem = memory_location;
	byte_buffer[buffer_pos] = byte & 255;
	buffer_pos++;
}


