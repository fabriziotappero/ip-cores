/*
 * display.c -- LogicProbe data viewer
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>


static FILE *diskFile = NULL;


void error(char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  printf("Error: ");
  vprintf(fmt, ap);
  printf("\n");
  va_end(ap);
  if (diskFile != NULL) {
    fclose(diskFile);
    diskFile = NULL;
  }
  exit(1);
}


int main(int argc, char *argv[]) {
  unsigned char b;
  int i, j;

  if (argc != 2) {
    printf("Usage: %s <data_file>\n", argv[0]);
    exit(1);
  }
  diskFile = fopen(argv[1], "rb");
  if (diskFile == NULL) {
    error("cannot open data file %s for read", argv[1]);
  }
  for (i = 0; i < 512; i++) {
    printf("%03d:  ", i);
    for (j = 0; j < 16; j++) {
      if (fread(&b, 1, 1, diskFile) != 1) {
        error("cannot read from data file %s", argv[1]);
      }
      printf("%02X  ", b);
    }
    printf("\n");
  }
  if (diskFile != NULL) {
    fclose(diskFile);
    diskFile = NULL;
  }
  return 0;
}
