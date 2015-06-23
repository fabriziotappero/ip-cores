/*
 * mkdisk.c -- make an empty physical disk
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>


#define SECTOR_SIZE		512
#define MIN_NUMBER_SECTORS	100
#define SECTORS_PER_MB		((1 << 20) / SECTOR_SIZE)
#define DATA_BYTE		0xE5


void error(char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  fprintf(stderr, "Error: ");
  vfprintf(stderr, fmt, ap);
  fprintf(stderr, "\n");
  va_end(ap);
  exit(1);
}


void usage(void) {
  fprintf(stderr, "Usage: mkdisk <file name> <n>[M]\n");
  fprintf(stderr, "       <n>: decimal number of sectors\n");
  fprintf(stderr, "       if 'M' appended: megabytes instead of sectors\n");
  fprintf(stderr, "       (sector size is always %d bytes)\n", SECTOR_SIZE);
  exit(1);
}


int main(int argc, char *argv[]) {
  FILE *dskFile;
  int numSectors;
  unsigned char sectorBuffer[SECTOR_SIZE];
  int i;

  if (argc != 3) {
    usage();
  }
  numSectors = atoi(argv[2]);
  i = strlen(argv[2]) - 1;
  if (argv[2][i] == 'M') {
    numSectors *= SECTORS_PER_MB;
  }
  if (numSectors < MIN_NUMBER_SECTORS) {
    error("this disk is too small to be useful (minimum size is %d sectors)",
          MIN_NUMBER_SECTORS);
  }
  dskFile = fopen(argv[1], "wb");
  if (dskFile == NULL) {
    error("cannot open file '%s' for write", argv[1]);
  }
  fprintf(stdout,
          "Creating disk '%s' with %d sectors (around %d MB)...\n",
          argv[1], numSectors,
          (numSectors + SECTORS_PER_MB / 2) / SECTORS_PER_MB);
  for (i = 0; i < SECTOR_SIZE; i++) {
    sectorBuffer[i] = DATA_BYTE;
  }
  for (i = 0; i < numSectors; i++) {
    if (fwrite(sectorBuffer, SECTOR_SIZE, 1, dskFile) != 1) {
      error("write error on file '%s', sector %d", argv[1], i);
    }
  }
  fclose(dskFile);
  return 0;
}
