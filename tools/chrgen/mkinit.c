/*
 * mkinit.c -- generate Verilog defparam statements from C data
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define LO_FILE_NAME	"chrgenlo.init"
#define HI_FILE_NAME	"chrgenhi.init"


unsigned char data[] = {
  #include "font-8x16"
};


unsigned char reflect(unsigned char c) {
  unsigned char r;
  int i;

  r = 0;
  for (i = 0; i < 8; i++) {
    r <<= 1;
    if (c & 1) {
      r |= 1;
    }
    c >>= 1;
  }
  return r;
}


int main(void) {
  FILE *outFile;
  int i, j;
  unsigned char b[32];

  if (sizeof(data) != 256 * 16) {
    printf("Error: wrong size of data\n");
    exit(1);
  }
  outFile = fopen(LO_FILE_NAME, "w");
  if (outFile == NULL) {
    printf("Error: cannot open file '%s'\n", LO_FILE_NAME);
    exit(1);
  }
  for (i = 0; i < 64; i++) {
    fprintf(outFile, "  defparam character_rom_lo.INIT_%02X = 256'h", i);
    for (j = 0; j < 32; j++) {
      b[j] = data[i * 32 + j + 0 * 16];
    }
    for (j = 31; j >= 0; j--) {
      fprintf(outFile, "%02X", reflect(b[j]));
    }
    fprintf(outFile, ";\n");
  }
  fclose(outFile);
  outFile = fopen(HI_FILE_NAME, "w");
  if (outFile == NULL) {
    printf("Error: cannot open file '%s'\n", HI_FILE_NAME);
    exit(1);
  }
  for (i = 0; i < 64; i++) {
    fprintf(outFile, "  defparam character_rom_hi.INIT_%02X = 256'h", i);
    for (j = 0; j < 32; j++) {
      b[j] = data[i * 32 + j + 128 * 16];
    }
    for (j = 31; j >= 0; j--) {
      fprintf(outFile, "%02X", reflect(b[j]));
    }
    fprintf(outFile, ";\n");
  }
  fclose(outFile);
  return 0;
}
