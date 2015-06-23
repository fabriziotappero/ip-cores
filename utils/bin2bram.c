// bin2bram : program to fill the template "bootram" with the provided
// 	      binary code

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_RAM		2048
#define MAX_LINE		128
#define DUMP_TOKEN	"$DUMP_INIT_RAM"
#define DUMP_LINE		"defparam MEM%u.INIT_%02X = 256'h%s;\n"	/* memory content */
#define DUMP_INITIAL_1	"defparam MEM%u.INIT_%c = 9'h0%02X;\n"	/* dword 0 at startupt */
#define DUMP_INITIAL_2	"defparam MEM%u.SRVAL_%c = 9'h0%02X;\n" /* dword 0 at reset */

int main(int argn, char **argc)
{
  char line[MAX_LINE], hexcodes[MAX_LINE], tmp[MAX_LINE];
  char memory[MAX_RAM][4];		// code loaded from BIN file
  int count, offset = 0;
  FILE *f, *ftemplate;

  if(argn != 4)
  {
    printf("usage: %s <template file> <binary file> <output file>\n", argc[0]);
    exit(1);
  }

  memset(memory, 0, MAX_RAM * 4);				// initialize memory
  if( (f = fopen(argc[2], "rb")) == NULL )	// open binary file
  {
    printf("error: binary file <%s> does not exist\n", argc[2]);
    exit(1);
  }

  do
  {
    count = (unsigned short) fread(memory[offset++], 4, 1, f);	// read instructions (32 bits)
  } while(count > 0);
  fclose(f);

  if( (ftemplate = fopen(argc[1], "r")) == NULL )	// open template file
  {
    printf("error: template file <%s> does not exist\n", argc[1]);
    exit(1);
  }

  if( (f = fopen(argc[3], "w")) == NULL )				// create destination file
  {
    printf("error: output file <%s> can't be created\n", argc[3]);
    exit(1);
  }

  while(!feof(ftemplate))		// read the template file
  {
	 line[0] =0;
    fgets(line, MAX_LINE - 1, ftemplate);		// read a template line
    if( strstr(line, DUMP_TOKEN) != NULL )	// dump memory token found?
    {
      int ptr1 = 0, ptr2, byte;

	   for(byte = 0; byte < 4; byte++)
      {
        fprintf(f, DUMP_INITIAL_1, 3 - byte, 'A', memory[0][byte] & 0xff);
        fprintf(f, DUMP_INITIAL_1, 3 - byte, 'B', memory[0][byte] & 0xff);
        fprintf(f, DUMP_INITIAL_2, 3 - byte, 'A', memory[0][byte] & 0xff);
        fprintf(f, DUMP_INITIAL_2, 3 - byte, 'B', memory[0][byte] & 0xff);
        fprintf(f, "\n");
      }

      while(ptr1 <= offset)
      {
        for(byte = 0; byte < 4; byte++)
        {
          hexcodes[0] = 0;						// initialize line
		    ptr2 = ptr1 + 31;					// start from the end of the line
          while(ptr2 >= ptr1)
          {
            sprintf(tmp, "%02X", (memory[ptr2--][byte]) & 0xff);	// hexcode (big endian)
            strcat(hexcodes, tmp);							// concatenate to the hexcode string
          }
          sprintf(tmp, DUMP_LINE, 3 - byte, ptr1 / 32, hexcodes);	// compose defparam line
          fputs(tmp, f);		// write to file
        }
        fputs("\n", f);		// space between 32 byte blocks
        ptr1 += (unsigned short) 32;
      }
    }
    else fputs(line, f);							// if not, copy the template line
  }
  fclose(ftemplate);
  fclose(f);
  return 0;
}