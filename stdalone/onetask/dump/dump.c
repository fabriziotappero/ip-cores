/*
 * dump.c -- dump a binary file as contents of a C array
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(int argc, char *argv[]) {
  FILE *infile, *outfile;
  int c, n;

  if (argc != 3) {
    printf("Usage: %s <infile> <outfile>\n", argv[0]);
    return 1;
  }
  infile = fopen(argv[1], "rb");
  if (infile == NULL) {
    printf("Error: cannot open file '%s' for input\n", argv[1]);
    return 1;
  }
  outfile = fopen(argv[2], "wt");
  if (outfile == NULL) {
    printf("Error: cannot open file '%s' for output\n", argv[2]);
    return 1;
  }
  n = 0;
  while (1) {
    c = getc(infile);
    if (c == EOF) {
      break;
    }
    fprintf(outfile, "0x%02X, ", c);
    n++;
    if (n == 8) {
      n = 0;
      fprintf(outfile, "\n");
    }
  }
  if (n != 0) {
    fprintf(outfile, "\n");
  }
  fclose(infile);
  fclose(outfile);
  return 0;
}
