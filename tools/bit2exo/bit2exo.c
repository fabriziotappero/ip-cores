/*
 * bit2exo.c -- convert Xilinx bitfile data to Motorola S-records
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>


unsigned char bitHeader[13] = {
  0x00, 0x09, 0x0F, 0xF0,
  0x0F, 0xF0, 0x0F, 0xF0,
  0x0F, 0xF0, 0x00, 0x00,
  0x01
};


void error(char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  printf("Error: ");
  vprintf(fmt, ap);
  printf("\n");
  va_end(ap);
  exit(1);
}


unsigned int getCount2(FILE *infile) {
  unsigned char b1, b2;

  b1 = fgetc(infile);
  b2 = fgetc(infile);
  return ((unsigned int) b1 << 8) | (unsigned int) b2;
}


unsigned int getCount4(FILE *infile) {
  unsigned char b1, b2, b3, b4;

  b1 = fgetc(infile);
  b2 = fgetc(infile);
  b3 = fgetc(infile);
  b4 = fgetc(infile);
  return ((unsigned int) b1 << 24) | ((unsigned int) b2 << 16) |
         ((unsigned int) b3 <<  8) | ((unsigned int) b4 <<  0);
}


void show(char *name, FILE *infile, int count) {
  int c;

  printf("%s", name);
  while (count--) {
    c = fgetc(infile);
    if (c >= 0x20 && c <= 0x7E) {
      printf("%c", c);
    }
  }
  printf("\n");
}


unsigned char mirror(unsigned char n) {
  unsigned char m;
  int i;

  m = 0;
  for (i = 0; i < 8; i++) {
    m <<= 1;
    if (n & 1) {
      m |= 1;
    }
    n >>= 1;
  }
  return m;
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
  int totalBytes;

  if (argc != 4) {
    printf("Usage: %s <load addr, hex> <input file> <output file>\n",
           argv[0]);
    printf("    ROM quadrant 0: load addr = 0x000000\n");
    printf("    ROM quadrant 1: load addr = 0x080000\n");
    printf("    ROM quadrant 2: load addr = 0x100000\n");
    printf("    ROM quadrant 3: load addr = 0x180000\n");
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
  /* 13 bytes header */
  for (i = 0; i < 13; i++) {
    if (fgetc(infile) != bitHeader[i]) {
      error("input file header is not a '.bit' header");
    }
  }
  /* section 'a' */
  if (fgetc(infile) != 'a') {
    error("section 'a' not found");
  }
  i = getCount2(infile);
  show("design name:\t\t", infile, i);
  /* section 'b' */
  if (fgetc(infile) != 'b') {
    error("section 'b' not found");
  }
  i = getCount2(infile);
  show("part name:\t\t", infile, i);
  /* section 'c' */
  if (fgetc(infile) != 'c') {
    error("section 'c' not found");
  }
  i = getCount2(infile);
  show("creation date:\t\t", infile, i);
  /* section 'd' */
  if (fgetc(infile) != 'd') {
    error("section 'd' not found");
  }
  i = getCount2(infile);
  show("creation time:\t\t", infile, i);
  /* section 'e' */
  if (fgetc(infile) != 'e') {
    error("section 'e' not found");
  }
  i = getCount4(infile);
  printf("bit stream size:\t0x%08X\n", i);
  totalBytes = 0;
  while (1) {
    chksum = 0;
    for (numBytes = 0; numBytes < 16; numBytes++) {
      c = fgetc(infile);
      if (c == EOF) {
        break;
      }
      c = mirror(c & 0xFF);
      lineData[numBytes] = c;
      chksum += c;
    }
    if (numBytes == 0) {
      break;
    }
    totalBytes += numBytes;
    fprintf(outfile, "S2%02X%06X", numBytes + 4, loadAddr);
    for (i = 0; i < numBytes; i++) {
      fprintf(outfile, "%02X", lineData[i]);
    }
    chksum += numBytes + 4;
    chksum += ((loadAddr >>  0) & 0xFF) +
              ((loadAddr >>  8) & 0xFF) +
              ((loadAddr >> 16) & 0xFF);
    fprintf(outfile, "%02X\n", 0xFF - (chksum & 0xFF));
    loadAddr += numBytes;
    if (c == EOF) {
      break;
    }
  }
  fprintf(outfile, "S804000000FB\n");
  fclose(infile);
  fclose(outfile);
  printf("bytes converted:\t0x%08X\n", totalBytes);
  return 0;
}
