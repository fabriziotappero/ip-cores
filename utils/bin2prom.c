#include <stdio.h>
#include <stdlib.h>

#define PROM_SYNC_PATTERN  	"8F9FAFBF"

long filesize(FILE *stream)
{
   long curpos, length;

   curpos = ftell(stream);
   fseek(stream, 0L, SEEK_END);
   length = ftell(stream);
   fseek(stream, curpos, SEEK_SET);
   return length;
}

void main(int argn, char **argc)
{
  int len, k;
  FILE *f1, *f2;
  char c;

  if(argn < 4 || argn > 5)
  {
    printf("usage: bin2prom bin-file prom-file file-num [sync pattern]\n");
    exit(1);
  }
  f1 = fopen(argc[1], "rb");		// open bin file
  if(f1 == NULL)
  {
    printf("error: can't open BIN file %s\n", argc[1]);
    exit(1);
  }
  len = filesize(f1);				// get file size
  f2 = fopen(argc[2], "w");		// create prom file (ascii)
  // headers (for info)
  fprintf(f2, "# SYNC PATTERN: 0x%s\n", argn == 5 ? argc[4] : PROM_SYNC_PATTERN);
  fprintf(f2, "# FILE NUMBER : 0x%02X\n", atoi(argc[3]) );
  fprintf(f2, "# FILE SIZE   : 0x%06X\n", len & 0xFFFFFF);

  fprintf(f2, "%s",   argn == 5 ? argc[4] : PROM_SYNC_PATTERN);	// 4 bytes	 write header
  fprintf(f2, "%02X", atoi(argc[3]));	// 1 bytes
  fprintf(f2, "%06X", len & 0xFFFFFF);	// 3 bytes

  k = 8;								// current header is 8 bytes length
  while(len-- > 0)
  {
    fread(&c, sizeof(char), 1, f1);		// read current byte
	 fprintf(f2, "%02X", ((unsigned) c) & 0xff);
    if(++k == 16) { fprintf(f2, "\n"); k = 0; }
  }
  for(; k < 16; k++) fprintf(f2, "00");

  fprintf(f2, "\n");
  fclose(f2);
  fclose(f1);
}