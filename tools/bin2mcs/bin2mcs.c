/*
 * bin2mcs.c -- convert binary data to Intel hex records
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>


void error(char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  printf("Error: ");
  vprintf(fmt, ap);
  printf("\n");
  va_end(ap);
  exit(1);
}


int main(int argc, char *argv[]) {
  char *endptr;
  unsigned int loadAddr;
  FILE *infile;
  FILE *outfile;
  int numBytes, i;
  int c;
  unsigned char lineData[16];
  unsigned int chksum;

  if (argc != 4) {
    printf("Usage: %s <load addr, hex> <input file> <output file>\n",
           argv[0]);
    exit(1);
  }
  loadAddr = strtoul(argv[1], &endptr, 16);
  if (*endptr != '\0') {
    error("illegal load address %s", argv[1]);
  }
  infile = fopen(argv[2], "rb");
  if (infile == NULL) {
    error("cannot open input file %s", argv[2]);
  }
  outfile = fopen(argv[3], "wt");
  if (outfile == NULL) {
    error("cannot open output file %s", argv[3]);
  }
  while (1) {
    if ((loadAddr & 0xFFFF) == 0) {
      fprintf(outfile, ":02000004");
      fprintf(outfile, "%04X", loadAddr >> 16);
      chksum = 0x02 + 0x04 +
               ((loadAddr >> 24) & 0xFF) +
               ((loadAddr >> 16) & 0xFF);
      fprintf(outfile, "%02X\n", (-chksum) & 0xFF);
    }
    chksum = 0;
    for (numBytes = 0; numBytes < 16; numBytes++) {
      c = fgetc(infile);
      if (c == EOF) {
        break;
      }
      lineData[numBytes] = c;
      chksum += c;
    }
    if (numBytes == 0) {
      break;
    }
    fprintf(outfile, ":%02X%04X00", numBytes, loadAddr & 0xFFFF);
    for (i = 0; i < numBytes; i++) {
      fprintf(outfile, "%02X", lineData[i]);
    }
    chksum += numBytes;
    chksum += ((loadAddr >> 8) & 0xFF) +
              ((loadAddr >> 0) & 0xFF);
    fprintf(outfile, "%02X\n", (-chksum) & 0xFF);
    loadAddr += numBytes;
    if (c == EOF) {
      break;
    }
  }
  fprintf(outfile, ":00000001FF\n");
  fclose(infile);
  fclose(outfile);
  return 0;
}
