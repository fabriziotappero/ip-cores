/*
 * bin2exo.c -- convert binary data to Motorola S-records
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>


#define S1	1
#define S2	2
#define S3	3


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
  int type;
  unsigned int loadAddrMsk;
  char *loadAddrStr;
  char *infileStr;
  char *outfileStr;
  char *endptr;
  unsigned int loadAddr;
  unsigned int startAddr;
  FILE *infile;
  FILE *outfile;
  int numBytes, i;
  int c;
  unsigned char lineData[16];
  unsigned int chksum;

  if (argc != 5) {
    printf("Usage: %s -S1|-S2|-S3 <load addr, hex> ", argv[0]);
    printf("<input file> <output file>\n");
    exit(1);
  }
  if (strcmp(argv[1], "-S1") == 0) {
    type = S1;
    loadAddrMsk = 0x0000FFFF;
  } else
  if (strcmp(argv[1], "-S2") == 0) {
    type = S2;
    loadAddrMsk = 0x00FFFFFF;
  } else
  if (strcmp(argv[1], "-S3") == 0) {
    type = S3;
    loadAddrMsk = 0xFFFFFFFF;
  } else {
    error("exactly one of -S1, -S2, or -S3 must be specified");
  }
  loadAddrStr = argv[2];
  infileStr = argv[3];
  outfileStr = argv[4];
  loadAddr = strtoul(loadAddrStr, &endptr, 16);
  if (*endptr != '\0') {
    error("illegal load address %s", loadAddrStr);
  }
  if (loadAddr & ~loadAddrMsk) {
    error("load address too big");
  }
  startAddr = loadAddr;
  infile = fopen(infileStr, "rb");
  if (infile == NULL) {
    error("cannot open input file %s", infileStr);
  }
  outfile = fopen(outfileStr, "wt");
  if (outfile == NULL) {
    error("cannot open output file %s", outfileStr);
  }
  while (1) {
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
    switch (type) {
      case S1:
        fprintf(outfile, "S1%02X%04X", numBytes + 3, loadAddr);
        break;
      case S2:
        fprintf(outfile, "S2%02X%06X", numBytes + 4, loadAddr);
        break;
      case S3:
        fprintf(outfile, "S3%02X%08X", numBytes + 5, loadAddr);
        break;
    }
    for (i = 0; i < numBytes; i++) {
      fprintf(outfile, "%02X", lineData[i]);
    }
    switch (type) {
      case S1:
        chksum += numBytes + 3 +
                  ((loadAddr >>  0) & 0xFF) +
                  ((loadAddr >>  8) & 0xFF);
        break;
      case S2:
        chksum += numBytes + 4 +
                  ((loadAddr >>  0) & 0xFF) +
                  ((loadAddr >>  8) & 0xFF) +
                  ((loadAddr >> 16) & 0xFF);
        break;
      case S3:
        chksum += numBytes + 5 +
                  ((loadAddr >>  0) & 0xFF) +
                  ((loadAddr >>  8) & 0xFF) +
                  ((loadAddr >> 16) & 0xFF) +
                  ((loadAddr >> 24) & 0xFF);
        break;
    }
    fprintf(outfile, "%02X\n", 0xFF - (chksum & 0xFF));
    loadAddr += numBytes;
    if (c == EOF) {
      break;
    }
  }
  switch (type) {
    case S1:
      fprintf(outfile, "S903%04X", startAddr);
      chksum = 3 +
               ((startAddr >>  0) & 0xFF) +
               ((startAddr >>  8) & 0xFF);
      break;
    case S2:
      fprintf(outfile, "S804%06X", startAddr);
      chksum = 4 +
               ((startAddr >>  0) & 0xFF) +
               ((startAddr >>  8) & 0xFF) +
               ((startAddr >> 16) & 0xFF);
      break;
    case S3:
      fprintf(outfile, "S705%08X", startAddr);
      chksum = 5 +
               ((startAddr >>  0) & 0xFF) +
               ((startAddr >>  8) & 0xFF) +
               ((startAddr >> 16) & 0xFF) +
               ((startAddr >> 24) & 0xFF);
      break;
  }
  fprintf(outfile, "%02X\n", 0xFF - (chksum & 0xFF));
  fclose(infile);
  fclose(outfile);
  return 0;
}
