#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void main(int argn, char **argc)
{
  FILE *f1, *f2;
  unsigned char bloque[4];
  int swap;

  if(argn < 3 || argn > 4)
  {
    printf("uso: bin2rom <fichero.bin> <fichero.rom> [-swap]\n");
    exit(1);
  }
  if(argn == 4 && strcmpi(argc[3], "-swap") == 1) swap = 1; else swap = 0;

  f1 = fopen(argc[1], "rb");
  f2 = fopen(argc[2], "w");

  while( !feof(f1) )
  {
    fread(bloque, 4, 1, f1);
    if(swap)
      fprintf(f2, "%02x%02x%02x%02x\n", ((unsigned)bloque[3]) & 0xff,
      ((unsigned)bloque[2])&0xff, ((unsigned)bloque[1])&0xff,
      ((unsigned)bloque[0])&0xff);
    else
      fprintf(f2, "%02x%02x%02x%02x\n", ((unsigned)bloque[0]) & 0xff,
      ((unsigned)bloque[1])&0xff, ((unsigned)bloque[2])&0xff,
      ((unsigned)bloque[3])&0xff);
  }
  fclose(f1);
  fclose(f2);
}


